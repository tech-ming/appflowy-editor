import 'dart:async';
import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/flutter/scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:appflowy_editor/src/flutter/scrollable_positioned_list/src/item_positions_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 程序化露出的位移容差：小于它视为已到位
const double _kRevealTolerance = 0.5;

/// 逐帧推进布局的最大帧数（约 1 秒），仍构建不出目标就放弃
const int _kMaxRevealFrames = 60;

/// 每次推进的距离（视口高度的倍数）
///
/// 列表缓存区是视口前后各 2 屏，一次推进 4 屏，新旧缓存区首尾相接不留空档。
const double _kRevealStepViewports = 4;

/// This class controls the scroll behavior of the editor.
///
/// It must be provided in the widget tree above the [PageComponent].
///
/// You can use [offsetNotifier] to get the current scroll offset.
/// And, you can use [visibleRangeNotifier] to get the first level visible items.
///
/// If the shrinkWrap is true, the scrollController must not be null
///   and the editor should be wrapped in a SingleChildScrollView.
class EditorScrollController {
  EditorScrollController({
    required this.editorState,
    this.shrinkWrap = false,
    this.physics,
    ScrollController? scrollController,
  }) {
    // if shrinkWrap is true, we will render the document with Column layout.
    // otherwise, we will render the document with ScrollablePositionedList.
    if (shrinkWrap) {
      void updateVisibleRange() {
        visibleRangeNotifier.value = (
          0,
          editorState.document.root.children.length - 1,
        );
      }

      updateVisibleRange();
      editorState.document.root.addListener(updateVisibleRange);

      shouldDisposeScrollController = scrollController == null;
      this.scrollController = scrollController ?? ScrollController();
      // listen to the scroll offset
      this.scrollController.addListener(
            () => offsetNotifier.value = this.scrollController.offset,
          );
    } else {
      // listen to the scroll offset
      _scrollOffsetSubscription = _scrollOffsetListener.changes.listen((value) {
        // 优先读当前绝对偏移：宿主重建时新控制器会接管原列表，累加增量会从 0 起算而失真
        offsetNotifier.value = position?.pixels ?? offsetNotifier.value + value;
      });

      _itemPositionsListener.itemPositions.addListener(_listenItemPositions);
    }
  }

  final EditorState editorState;
  final bool shrinkWrap;

  /// 滚动物理，null 时沿用全局 ScrollBehavior
  ///
  /// 整页编辑器应传 [AlwaysScrollableScrollPhysics]：内容不足一屏时也能拖动回弹。
  final ScrollPhysics? physics;

  // ------------ 程序化滚动（reveal）配置，由宿主按设计令牌注入 ------------

  /// 可见区内缩：视口中被宿主浮层压住、或需要留白的边距（如底部悬浮工具栏）
  ///
  /// 宿主按浮层实测高度更新（菜单展开时含面板）；遮挡变大时，光标跟随会把
  /// 原本看得到的光标留在可见区。
  final ValueNotifier<EdgeInsets> revealPaddingNotifier =
      ValueNotifier(EdgeInsets.zero);

  EdgeInsets get revealPadding => revealPaddingNotifier.value;

  set revealPadding(EdgeInsets value) => revealPaddingNotifier.value = value;

  /// 露出内容（如插入后露出新块）的默认动画时长，[Duration.zero] 为直接跳转
  Duration revealDuration = const Duration(milliseconds: 200);

  /// 光标跟随（打字、点按落光标）的动画时长
  Duration caretRevealDuration = const Duration(milliseconds: 100);

  /// 视口一步缩小（键盘高度一次性下发）时，光标跟随键盘的动画时长
  Duration keyboardRevealDuration = const Duration(milliseconds: 300);

  /// 露出动画曲线
  Curve revealCurve = Curves.easeOutCubic;

  // provide the current scroll offset
  final ValueNotifier<double> offsetNotifier = ValueNotifier(0);

  // provide the first level visible items, for example, if there're texts like this:
  //
  // 1. text1
  // 2. text2 ---
  //  2.1 text21|
  // ...        |
  // 5. text5   | screen
  // ...        |
  // 9. text9 ---
  // 10. text10
  //
  // So the visible range is (2-1, 9-1) = (1, 8), index start from 0.
  final ValueNotifier<(int, int)> visibleRangeNotifier =
      ValueNotifier((-1, -1));

  // these value is required by SingleChildScrollView
  // notes: don't use them if shrinkWrap is false
  // ------------ start ----------------
  late final ScrollController scrollController;
  bool shouldDisposeScrollController = false;
  // ------------ end ----------------

  // these values are required by ScrollablePositionedList
  // notes: don't use them if shrinkWrap is true
  // ------------ start ----------------
  ItemScrollController get itemScrollController {
    if (shrinkWrap) {
      throw UnsupportedError(
        'ItemScrollController is not supported '
        'when shrinkWrap is true',
      );
    }

    return _itemScrollController;
  }

  final ItemScrollController _itemScrollController = ItemScrollController();

  ScrollOffsetController get scrollOffsetController {
    if (shrinkWrap) {
      throw UnsupportedError(
        'ScrollOffsetController is not supported '
        'when shrinkWrap is true',
      );
    }

    return _scrollOffsetController;
  }

  final ScrollOffsetController _scrollOffsetController =
      ScrollOffsetController();

  ItemPositionsListener get itemPositionsListener {
    if (shrinkWrap) {
      throw UnsupportedError(
        'ItemPositionsListener is not supported '
        'when shrinkWrap is true',
      );
    }

    return _itemPositionsListener;
  }

  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  ScrollOffsetListener get scrollOffsetListener {
    if (shrinkWrap) {
      throw UnsupportedError(
        'ScrollOffsetListener is not supported '
        'when shrinkWrap is true',
      );
    }

    return _scrollOffsetListener;
  }

  final ScrollOffsetListener _scrollOffsetListener =
      ScrollOffsetListener.create();
  // ------------ end ----------------

  late final StreamSubscription<double> _scrollOffsetSubscription;

  // dispose the subscription
  void dispose() {
    if (shouldDisposeScrollController) {
      scrollController.dispose();
    }

    if (!shrinkWrap) {
      _scrollOffsetSubscription.cancel();
      _itemPositionsListener.itemPositions.removeListener(_listenItemPositions);
      (_itemPositionsListener as ItemPositionsNotifier?)
          ?.itemPositions
          .dispose();
    }

    offsetNotifier.dispose();
    visibleRangeNotifier.dispose();
    revealPaddingNotifier.dispose();
  }

  Future<void> animateTo({
    required double offset,
    required Duration duration,
    Curve curve = Curves.linear,
  }) async {
    if (shrinkWrap) {
      await scrollController.animateTo(
        offset.clamp(
          scrollController.position.minScrollExtent,
          scrollController.position.maxScrollExtent,
        ),
        duration: duration,
        curve: curve,
      );
    } else {
      await scrollOffsetController.animateTo(
        offset: max(0, offset),
        duration: duration,
        curve: curve,
      );
    }
  }

  void jumpTo({
    required double offset,
  }) async {
    if (shrinkWrap) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(
          offset.clamp(
            scrollController.position.minScrollExtent,
            scrollController.position.maxScrollExtent,
          ),
        );
      }

      return;
    }

    final index = offset.toInt();
    final (start, end) = visibleRangeNotifier.value;

    if (index < start || index > end) {
      itemScrollController.jumpTo(
        index: max(0, index),
        alignment: 0,
      );
    }
  }

  void jumpToTop() {
    if (shrinkWrap) {
      scrollController.jumpTo(0);
    } else {
      itemScrollController.jumpTo(index: 0);
    }
  }

  void jumpToBottom() {
    if (shrinkWrap) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    } else {
      itemScrollController.jumpTo(
        index: editorState.document.root.children.length - 1,
      );
    }
  }

  // ------------ 程序化滚动（reveal） ------------
  //
  // 这里只改绝对偏移，不调用 itemScrollController.jumpTo/scrollTo：那两者会把
  // 列表重新锚定到目标块（锚点之上的内容改为向上生长），且落位依赖视口高度，
  // 键盘一弹一收整篇内容都会跟着平移。

  /// 承载文档的滚动位置（列表未挂载或未完成首次布局时为 null）
  ScrollPosition? get position {
    final scrollable = editorState.scrollableState;
    if (scrollable == null || !scrollable.mounted) {
      return null;
    }
    final position = scrollable.position;
    if (!position.hasPixels ||
        !position.hasContentDimensions ||
        !position.hasViewportDimension) {
      return null;
    }

    return position;
  }

  /// 以最小滚动量把全局坐标下的 [rect] 滚入可见区
  ///
  /// - 已完整可见：不滚动；
  /// - [alignment] 非空：需要滚动时按比例落位——放得下时上下留白按它分配
  ///   （0 顶对齐、0.5 居中），放不下时顶对齐；
  /// - 放不下时默认露出开头，[preferEnd] 为 true 时露出结尾。
  ///
  /// 目标偏移夹紧在可滚动范围内，不会越界再回弹。
  Future<void> revealRect(
    Rect rect, {
    double? alignment,
    bool preferEnd = false,
    Duration? duration,
    Curve? curve,
  }) async {
    final position = this.position;
    final visible = visibleRegion();
    if (position == null || visible == null) {
      return;
    }

    final target = _offsetToReveal(
      position,
      visible,
      rect,
      alignment: alignment,
      preferEnd: preferEnd,
    );
    if (target == null || (target - position.pixels).abs() < _kRevealTolerance) {
      return;
    }

    final effectiveDuration = duration ?? revealDuration;
    if (effectiveDuration == Duration.zero) {
      position.jumpTo(target);

      return;
    }
    await position.animateTo(
      target,
      duration: effectiveDuration,
      curve: curve ?? revealCurve,
    );
  }

  /// 把单个节点滚入可见区，见 [revealNodes]
  Future<bool> revealNode(
    Node node, {
    double? alignment,
    bool preferEnd = false,
    Duration? duration,
    Curve? curve,
  }) {
    return revealNodes(
      [node],
      alignment: alignment,
      preferEnd: preferEnd,
      duration: duration,
      curve: curve,
    );
  }

  /// 把相邻的若干节点作为整体滚入可见区（落位规则同 [revealRect]）
  ///
  /// 首个节点还没构建（懒加载列表的缓存区之外）时，朝它的方向逐帧推进布局直到
  /// 构建出来；推进过就直接落位，不再接一段动画。返回是否成功露出。
  Future<bool> revealNodes(
    List<Node> nodes, {
    double? alignment,
    bool preferEnd = false,
    Duration? duration,
    Curve? curve,
  }) async {
    if (nodes.isEmpty) {
      return false;
    }
    final lead = nodes.first;
    var steps = 0;

    for (var frame = 0; frame < _kMaxRevealFrames; frame++) {
      // 等待期间节点被删除或编辑器被销毁
      if (editorState.isDisposed || lead.parent == null) {
        return false;
      }

      final rect = _unionRectOf(nodes);
      if (rect != null) {
        await revealRect(
          rect,
          alignment: alignment,
          preferEnd: preferEnd,
          duration: steps > 0 ? Duration.zero : duration,
          curve: curve,
        );

        return true;
      }

      final moved = _stepTowards(lead, estimate: steps == 0);
      if (moved == false) {
        return false;
      }
      if (moved == true) {
        steps++;
      }
      await SchedulerBinding.instance.endOfFrame;
    }

    return false;
  }

  /// 视口在全局坐标系下的可见区（扣除 [padding]，缺省为 [revealPadding]）
  Rect? visibleRegion({EdgeInsets? padding}) {
    final scrollable = editorState.scrollableState;
    if (scrollable == null || !scrollable.mounted) {
      return null;
    }
    final box = scrollable.context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) {
      return null;
    }

    final viewport = box.localToGlobal(Offset.zero) & box.size;
    final inset = padding ?? revealPadding;
    // 内缩超过视口（横屏 + 键盘这类极矮视口）时退回整个视口，避免可见区为负
    if (inset.vertical >= viewport.height) {
      return viewport;
    }

    return Rect.fromLTRB(
      viewport.left,
      viewport.top + inset.top,
      viewport.right,
      viewport.bottom - inset.bottom,
    );
  }

  /// 露出 [rect] 所需的目标偏移，已完整可见时返回 null
  double? _offsetToReveal(
    ScrollPosition position,
    Rect visible,
    Rect rect, {
    double? alignment,
    required bool preferEnd,
  }) {
    final fullyVisible = rect.top >= visible.top - _kRevealTolerance &&
        rect.bottom <= visible.bottom + _kRevealTolerance;
    if (fullyVisible) {
      return null;
    }

    final fits = rect.height <= visible.height;
    final double delta;
    if (alignment != null) {
      final desiredTop = fits
          ? visible.top + (visible.height - rect.height) * alignment
          : visible.top;
      delta = rect.top - desiredTop;
    } else if (!fits) {
      delta = preferEnd ? rect.bottom - visible.bottom : rect.top - visible.top;
    } else if (rect.top < visible.top) {
      delta = rect.top - visible.top;
    } else {
      delta = rect.bottom - visible.bottom;
    }

    final minExtent = position.minScrollExtent;
    final maxExtent = max(minExtent, position.maxScrollExtent);

    return (position.pixels + delta).clamp(minExtent, maxExtent);
  }

  /// 已构建节点的全局矩形并集；首个节点尚未构建时返回 null
  Rect? _unionRectOf(List<Node> nodes) {
    Rect? union;
    for (final node in nodes) {
      final box = node.renderBox;
      if (box == null || !box.attached || !box.hasSize) {
        if (union == null) {
          return null;
        }
        continue;
      }
      final rect = box.localToGlobal(Offset.zero) & box.size;
      union = union?.expandToInclude(rect) ?? rect;
    }

    return union;
  }

  /// 朝 [node] 所在方向推进一段布局
  ///
  /// [estimate] 为 true 时按下标比例直接跳到估计位置：懒加载列表的总高度本就按
  /// 平均块高估算，目标通常一步就进入缓存区，避免连跳数屏；估不准再按方向推进。
  ///
  /// 返回 true 已推进；null 需等一帧（列表未就绪 / 位置信息未刷新）；
  /// false 无法推进（已到边界，或 Column 布局下本就全部构建）。
  bool? _stepTowards(Node node, {required bool estimate}) {
    // Column 布局一次构建全部块，构建不出来说明它根本没有渲染（如被折叠）
    if (shrinkWrap) {
      return false;
    }
    final position = this.position;
    final items = _itemPositionsListener.itemPositions.value;
    if (position == null || items.isEmpty) {
      return null;
    }

    // 列表项下标：header 占 0 号位
    final target = node.path.first + (editorState.showHeader ? 1 : 0);
    var first = items.first.index;
    var last = first;
    for (final item in items) {
      first = min(first, item.index);
      last = max(last, item.index);
    }
    if (target >= first && target <= last) {
      return null;
    }

    final minExtent = position.minScrollExtent;
    final maxExtent = max(minExtent, position.maxScrollExtent);
    final forward = target > last;
    final step = position.viewportDimension * _kRevealStepViewports;
    var next = position.pixels + (forward ? step : -step);
    if (estimate) {
      final itemCount = editorState.document.root.children.length +
          (editorState.showHeader ? 1 : 0) +
          (editorState.showFooter ? 1 : 0);
      final contentExtent =
          maxExtent - minExtent + position.viewportDimension;
      final estimated =
          minExtent + contentExtent * target / max(1, itemCount);
      // 估计值与目标方向一致才采用，否则仍按方向推进
      if (forward ? estimated > position.pixels : estimated < position.pixels) {
        next = estimated;
      }
    }

    final clamped = next.clamp(minExtent, maxExtent);
    if ((clamped - position.pixels).abs() < _kRevealTolerance) {
      return false;
    }
    position.jumpTo(clamped);

    return true;
  }

  // listen to the visible item positions
  void _listenItemPositions() {
    // the value from itemPositions is the list of item positions, we need to filter
    //  the list to find the first and last visible items.
    final positions = _itemPositionsListener.itemPositions.value;

    if (positions.isEmpty) {
      visibleRangeNotifier.value = (-1, -1);

      return;
    }

    // Determine the first visible item by finding the item with the
    // smallest trailing edge that is greater than 0.  i.e. the first
    // item whose trailing edge in visible in the viewport.
    int min = positions
        .where((ItemPosition position) => position.itemTrailingEdge > 0)
        .reduce(
          (ItemPosition min, ItemPosition position) =>
              position.itemTrailingEdge < min.itemTrailingEdge ? position : min,
        )
        .index;
    // Determine the last visible item by finding the item with the
    // greatest leading edge that is less than 1.  i.e. the last
    // item whose leading edge in visible in the viewport.
    int max = positions
        .where((ItemPosition position) => position.itemLeadingEdge < 1)
        .reduce(
          (ItemPosition max, ItemPosition position) =>
              position.itemLeadingEdge > max.itemLeadingEdge ? position : max,
        )
        .index;

    // filter the header and footer
    if (editorState.showHeader) {
      max--;
    }

    if (editorState.showFooter &&
        max >= editorState.document.root.children.length) {
      max--;
    }

    // notify the listeners

    visibleRangeNotifier.value = (min, max);
  }
}

extension ValidIndexedValueNotifier on ValueNotifier<(int, int)> {
  /// Returns true if the value is valid.
  bool get isValid => value.$1 >= 0 && value.$2 >= 0 && value.$1 <= value.$2;
}
