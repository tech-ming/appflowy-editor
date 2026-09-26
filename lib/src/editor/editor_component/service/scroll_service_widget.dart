import 'dart:async';
import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/desktop_scroll_service.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/mobile_scroll_service.dart';
import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

/// 视口单次缩小超过该值，视为键盘高度一次性下发（鸿蒙即如此），用动画跟随；
/// 逐帧下发的平台每帧只变几十像素，直接跟随即可，加动画反而拖在键盘后面。
const double _kViewportStepThreshold = 100.0;

/// 视口尺寸变化的容差，小于它视为没变
const double _kViewportTolerance = 0.5;

/// 点按落光标后等待键盘弹出的上限，超时仍没等到视口缩小就直接露出光标
const Duration _kKeyboardWaitTimeout = Duration(milliseconds: 400);

class ScrollServiceWidget extends StatefulWidget {
  const ScrollServiceWidget({
    super.key,
    required this.editorScrollController,
    required this.child,
  });

  final EditorScrollController editorScrollController;

  final Widget child;

  @override
  State<ScrollServiceWidget> createState() => _ScrollServiceWidgetState();
}

class _ScrollServiceWidgetState extends State<ScrollServiceWidget>
    implements AppFlowyScrollService {
  final _forwardKey =
      GlobalKey(debugLabel: 'forward_to_platform_scroll_service');
  late AppFlowyScrollService forward =
      _forwardKey.currentState as AppFlowyScrollService;

  late EditorState editorState = context.read<EditorState>();

  @override
  late ScrollController scrollController = ScrollController();

  Selection? lastSelection;

  /// 移动端最近一次已跟随的选区：同一选区的重复通知（如光标手柄自动隐藏）不再滚动
  Selection? _followedSelection;

  /// 编辑器视口上一次的高度，用于识别键盘弹出导致的视口缩小
  double? _lastViewportDimension;

  /// 上一次的最大滚动范围，用于识别尾部变短
  double? _lastMaxScrollExtent;

  /// 点按落光标后，等待键盘弹出期间的兜底计时
  Timer? _keyboardWaitTimer;

  /// 用户是否正在拖动编辑器列表（此时不接管视口变化引起的滚动）
  bool _userDragging = false;

  /// 上一次的可见区内缩，用于识别浮层遮挡变大
  late EdgeInsets _lastRevealPadding;

  @override
  void initState() {
    super.initState();
    editorState.selectionNotifier.addListener(_onSelectionChanged);
    _lastRevealPadding = widget.editorScrollController.revealPadding;
    widget.editorScrollController.revealPaddingNotifier
        .addListener(_onRevealPaddingChanged);
  }

  @override
  void didUpdateWidget(covariant ScrollServiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editorScrollController != widget.editorScrollController) {
      oldWidget.editorScrollController.revealPaddingNotifier
          .removeListener(_onRevealPaddingChanged);
      widget.editorScrollController.revealPaddingNotifier
          .addListener(_onRevealPaddingChanged);
      _lastRevealPadding = widget.editorScrollController.revealPadding;
    }
  }

  @override
  void dispose() {
    _keyboardWaitTimer?.cancel();
    scrollController.dispose();
    editorState.selectionNotifier.removeListener(_onSelectionChanged);
    widget.editorScrollController.revealPaddingNotifier
        .removeListener(_onRevealPaddingChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: widget.editorScrollController,
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: _onScrollMetricsChanged,
        child: NotificationListener<ScrollNotification>(
          onNotification: _trackUserDrag,
          child: Builder(
            builder: (context) {
              if (PlatformExtension.isDesktopOrWeb) {
                return _buildDesktopScrollService(context);
              } else if (PlatformExtension.isMobile) {
                return _buildMobileScrollService(context);
              }
              throw UnimplementedError();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopScrollService(
    BuildContext context,
  ) {
    return DesktopScrollService(
      key: _forwardKey,
      child: widget.child,
    );
  }

  Widget _buildMobileScrollService(
    BuildContext context,
  ) {
    return MobileScrollService(
      key: _forwardKey,
      child: widget.child,
    );
  }

  void _onSelectionChanged() {
    // should auto scroll after the cursor or selection updated.
    final selection = editorState.selection;
    if (selection == null ||
        [SelectionUpdateReason.selectAll]
            .contains(editorState.selectionUpdateReason)) {
      _followedSelection = null;
      _keyboardWaitTimer?.cancel();

      return;
    }

    final dynamic dragMode =
        editorState.selectionExtraInfo?['selection_drag_mode'];
    final isDragging =
        dragMode != null && dragMode.toString() != 'MobileSelectionDragMode.none';

    // 移动端非拖拽：光标跟随。拖拽手柄 / 光标时仍走下方的边缘自动滚动
    if (PlatformExtension.isMobile && !isDragging) {
      _followSelection(selection);

      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectionRects = editorState.selectionRects();
      if (selectionRects.isEmpty) {
        return;
      }

      Rect targetRect;
      AxisDirection? direction;

      // For desktop: if auto-scroller is already scrolling (from drag-to-select),
      // don't override it here. The desktop_selection_service handles drag scrolling.
      if (PlatformExtension.isDesktopOrWeb &&
          (editorState.autoScroller?.scrolling ?? false)) {
        return;
      }

      switch (dragMode?.toString()) {
        case 'MobileSelectionDragMode.leftSelectionHandle':
          targetRect = selectionRects.first;
          direction = AxisDirection.up;
          break;

        case 'MobileSelectionDragMode.rightSelectionHandle':
          targetRect = selectionRects.last;
          direction = AxisDirection.down;
          break;

        default:
          targetRect = selectionRects.last;

          // sometimes moving up in a long single node may be not working
          // so we need to special handle this case.
          final isLastSelectionSingle = lastSelection?.isSingle ?? false;
          final isLastSelectionPathEqual =
              lastSelection?.start.path.equals(selection.start.path) ?? false;
          final isInSingleNode =
              isLastSelectionSingle && isLastSelectionPathEqual;
          if (selection.isForward && isInSingleNode) {
            targetRect = selectionRects.first;
          }
      }

      lastSelection = selection;

      if (_forwardKey.currentContext == null) {
        return;
      }

      startAutoScroll(
        targetRect.centerRight,
        edgeOffset: editorState.autoScrollEdgeOffset,
        direction: direction,
        // 移动端拖拽需要持续小步滚动；原先对非拖拽的 250ms 等键盘补丁已由光标跟随取代
        duration: PlatformExtension.isMobile
            ? const Duration(milliseconds: 2)
            : Duration.zero,
      );
    });
  }

  // ------------ 移动端光标跟随 ------------
  //
  // 业界做法（Flutter EditableText / 原生输入框）：选区变化或视口因键盘缩小时，
  // 以最小滚动量把光标保持在可见区；不猜键盘何时弹完，也不一帧瞬移到位。

  /// 选区变化：等本帧布局完成后露出光标
  void _followSelection(Selection selection) {
    if (selection == _followedSelection) {
      return;
    }
    _followedSelection = selection;
    _keyboardWaitTimer?.cancel();

    // 点按落光标且键盘即将弹出：交给视口缩小时的跟随一次滚到位，避免先挪
    // 一下、键盘上来再挪一下；键盘迟迟没来（外接键盘等）时兜底露出
    final duration = widget.editorScrollController.caretRevealDuration;
    if (_isKeyboardComing()) {
      _keyboardWaitTimer = Timer(_kKeyboardWaitTimeout, () {
        if (mounted && editorState.selection == selection) {
          _revealSelection(duration: duration);
        }
      });

      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && editorState.selection == selection) {
        _revealSelection(duration: duration);
      }
    });
  }

  /// 本次选区变化是否会拉起软键盘：用户点按、需要接入输入法、且当前没有键盘
  bool _isKeyboardComing() {
    final doNotAttach =
        editorState.selectionExtraInfo?[selectionExtraInfoDoNotAttachTextService];

    return editorState.selectionUpdateReason == SelectionUpdateReason.uiEvent &&
        doNotAttach != true &&
        View.of(context).viewInsets.bottom == 0;
  }

  /// 焦点是否在编辑器之外的原生输入框上（编辑器本身不基于 EditableText）
  bool get _isOtherTextFieldFocused =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorStateOfType<EditableTextState>() !=
      null;

  /// 记录用户是否在拖动编辑器列表（仅看编辑器自身的纵向列表）
  bool _trackUserDrag(ScrollNotification notification) {
    if (notification.depth != 0) {
      return false;
    }
    if (notification is ScrollStartNotification) {
      _userDragging = notification.dragDetails != null;
    } else if (notification is ScrollUpdateNotification) {
      _userDragging = notification.dragDetails != null;
    } else if (notification is ScrollEndNotification) {
      _userDragging = false;
    }

    return false;
  }

  /// 视口尺寸变化：缩小（键盘弹出 / 候选栏变高）时把光标留在可见区；
  /// 变大（键盘收起）时收拢越界的滚动位置
  bool _onScrollMetricsChanged(ScrollMetricsNotification notification) {
    // 只看编辑器自身的纵向列表，块内的嵌套滚动（横向缩略图条等）不算
    if (notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final dimension = notification.metrics.viewportDimension;
    final previous = _lastViewportDimension;
    _lastViewportDimension = dimension;
    final maxExtent = notification.metrics.maxScrollExtent;
    final previousMaxExtent = _lastMaxScrollExtent;
    _lastMaxScrollExtent = maxExtent;
    if (!PlatformExtension.isMobile || previous == null) {
      return false;
    }

    final shrink = previous - dimension;
    if (shrink <= -_kViewportTolerance) {
      _settleAfterViewportGrow(-shrink);

      return false;
    }

    // 视口不变而尾部变短（悬浮菜单收起、文末内容删除），停在文末的位置会越界，
    // 回弹物理会让它弹一下；像 UIKit 调整 contentInset 那样逐帧夹紧跟随
    if (shrink.abs() < _kViewportTolerance &&
        previousMaxExtent != null &&
        maxExtent < previousMaxExtent - _kViewportTolerance) {
      _clampToContentEnd();

      return false;
    }

    // 键盘属于其他输入框（如标题）时不代它跟随编辑器光标
    if (shrink < _kViewportTolerance ||
        editorState.selection == null ||
        _isOtherTextFieldFocused) {
      return false;
    }

    _keyboardWaitTimer?.cancel();
    final controller = widget.editorScrollController;
    _revealSelection(
      duration: shrink > _kViewportStepThreshold
          ? controller.keyboardRevealDuration
          : Duration.zero,
    );

    return false;
  }

  /// 可见区内缩变化：浮层遮挡变大（悬浮菜单展开等）与视口缩小同理，
  /// 把原本看得到的光标留在可见区
  void _onRevealPaddingChanged() {
    final previous = _lastRevealPadding;
    final current = widget.editorScrollController.revealPadding;
    _lastRevealPadding = current;
    final grow = max(
      current.top - previous.top,
      current.bottom - previous.bottom,
    );
    if (!PlatformExtension.isMobile || grow < _kViewportTolerance) {
      return;
    }

    // 宿主可能在构建期更新内缩，此时布局未完成，等帧末再量光标
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _keepCaretClear(previous, grow));
    } else {
      _keepCaretClear(previous, grow);
    }
  }

  /// 光标被新增遮挡盖住时露出；[previous] 为变化前的内缩。
  /// 变化前就不在视野内（用户已滚走）的光标不拉回。
  void _keepCaretClear(EdgeInsets previous, double grow) {
    final selection = editorState.selection;
    if (!mounted ||
        selection == null ||
        _userDragging ||
        _isOtherTextFieldFocused) {
      return;
    }
    final controller = widget.editorScrollController;
    final caret = _caretRectOf(selection.end);
    final before = controller.visibleRegion(padding: previous);
    final after = controller.visibleRegion();
    if (caret == null || before == null || after == null) {
      return;
    }

    final wasVisible = caret.bottom > before.top && caret.top < before.bottom;
    final covered = caret.top < after.top - _kViewportTolerance ||
        caret.bottom > after.bottom + _kViewportTolerance;
    if (!wasVisible || !covered) {
      return;
    }
    // 菜单展开动画逐帧长高时直接跟随，一步长很多才用动画
    _revealSelection(
      duration: grow > _kViewportStepThreshold
          ? controller.keyboardRevealDuration
          : Duration.zero,
    );
  }

  /// 视口变大后停在文末的位置会越出新的滚动范围，默认由物理效果弹簧回弹。
  /// 改为按键盘节奏滑回（与 iOS 键盘收起时内容随之下落一致）：
  /// 一步变大用键盘动画时长，逐帧变大直接跟随。
  void _settleAfterViewportGrow(double grow) {
    final controller = widget.editorScrollController;
    final position = controller.position;
    if (_userDragging || position == null) {
      return;
    }
    final maxExtent = max(position.minScrollExtent, position.maxScrollExtent);
    if (position.pixels <= maxExtent + _kViewportTolerance) {
      return;
    }

    if (grow > _kViewportStepThreshold) {
      position.animateTo(
        maxExtent,
        duration: controller.keyboardRevealDuration,
        curve: controller.revealCurve,
      );
    } else {
      position.jumpTo(maxExtent);
    }
  }

  /// 越出滚动范围时直接落到文末；用户拖动中的越界回弹不接管
  void _clampToContentEnd() {
    final position = widget.editorScrollController.position;
    if (_userDragging || position == null) {
      return;
    }
    final maxExtent = max(position.minScrollExtent, position.maxScrollExtent);
    if (position.pixels > maxExtent + _kViewportTolerance) {
      position.jumpTo(maxExtent);
    }
  }

  /// 把选区的活动端（光标所在处）以最小滚动量露出来
  Future<void> _revealSelection({required Duration duration}) async {
    final selection = editorState.selection;
    if (selection == null) {
      return;
    }
    final controller = widget.editorScrollController;
    // 非文本块的光标是贯穿整块的竖线，放不下时：光标在块后（offset > 0）
    // 露出块尾，在块前露出块首——即接下来输入会落到的那一端
    final preferEnd = selection.end.offset > 0;

    final caret = _caretRectOf(selection.end);
    if (caret != null) {
      await controller.revealRect(
        caret,
        preferEnd: preferEnd,
        duration: duration,
      );

      return;
    }

    // 光标所在块还没构建（如从标题跳到文末续写）：先把块滚进来，
    // 构建出来后再精确对准光标
    final node = editorState.getNodeAtPath(selection.end.path);
    if (node == null) {
      return;
    }
    final revealed = await controller.revealNode(
      node,
      preferEnd: preferEnd,
      duration: duration,
    );
    if (!revealed || !mounted || editorState.selection != selection) {
      return;
    }
    // 滚动要到下一帧布局后才反映到坐标上，等一帧再量光标
    await SchedulerBinding.instance.endOfFrame;
    if (!mounted || editorState.selection != selection) {
      return;
    }
    final settled = _caretRectOf(selection.end);
    if (settled != null) {
      await controller.revealRect(
        settled,
        preferEnd: preferEnd,
        duration: Duration.zero,
      );
    }
  }

  /// 光标在全局坐标下的矩形，所在块未构建时返回 null
  Rect? _caretRectOf(Position position) {
    final node = editorState.getNodeAtPath(position.path);
    final box = node?.renderBox;
    final selectable = node?.selectable;
    if (box == null || !box.attached || !box.hasSize || selectable == null) {
      return null;
    }
    final rect = selectable.getCursorRectInPosition(
      position,
      shiftWithBaseOffset: true,
    );
    if (rect == null) {
      return null;
    }

    return selectable.transformRectToGlobal(rect, shiftWithBaseOffset: true);
  }

  @override
  void disable() => forward.disable();

  @override
  double get dy => forward.dy;

  @override
  void enable() => forward.enable();

  @override
  double get maxScrollExtent => forward.maxScrollExtent;

  @override
  double get minScrollExtent => forward.minScrollExtent;

  @override
  double? get onePageHeight => forward.onePageHeight;

  @override
  int? get page => forward.page;

  @override
  void scrollTo(
    double dy, {
    Duration duration = const Duration(milliseconds: 150),
  }) =>
      forward.scrollTo(dy, duration: duration);

  @override
  void jumpTo(int index) => forward.jumpTo(index);

  @override
  Future<bool> revealNodes(
    List<Node> nodes, {
    double? alignment,
    bool preferEnd = false,
    Duration? duration,
  }) =>
      forward.revealNodes(
        nodes,
        alignment: alignment,
        preferEnd: preferEnd,
        duration: duration,
      );

  @override
  void jumpToTop() {
    forward.jumpToTop();
  }

  @override
  void jumpToBottom() {
    forward.jumpToBottom();
  }

  @override
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 100,
    AxisDirection? direction,
    Duration? duration,
  }) {
    forward.startAutoScroll(
      offset,
      edgeOffset: edgeOffset,
      direction: direction,
      duration: duration,
    );
  }

  @override
  void stopAutoScroll() => forward.stopAutoScroll();

  @override
  void goBallistic(double velocity) => forward.goBallistic(velocity);
}
