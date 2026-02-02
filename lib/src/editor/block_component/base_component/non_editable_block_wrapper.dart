import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 非文本块的自动选区包装器
///
/// 此组件自动为没有实现 [SelectableMixin] 的非文本块提供选区能力：
/// - 点击块的左半边时，光标定位到块的左侧（offset=0）
/// - 点击块的右半边时，光标定位到块的右侧（offset=1）
/// - 在块的左侧或右侧显示竖线光标
/// - 支持键盘导航和删除操作
///
/// 此组件由 [BlockComponentContainer] 自动使用，块开发者无需手动处理。
class NonEditableBlockWrapper extends StatefulWidget {
  const NonEditableBlockWrapper({
    super.key,
    required this.node,
    required this.child,
  });

  final Node node;
  final Widget child;

  @override
  State<NonEditableBlockWrapper> createState() =>
      _NonEditableBlockWrapperState();
}

class _NonEditableBlockWrapperState extends State<NonEditableBlockWrapper>
    with SelectableMixin {
  final _contentKey = GlobalKey();

  /// 光标宽度
  static const _cursorWidth = 2.0;

  RenderBox? get _contentRenderBox =>
      _contentKey.currentContext?.findRenderObject() as RenderBox?;

  RenderBox? get _renderBox => context.findRenderObject() as RenderBox?;

  @override
  Widget build(BuildContext context) {
    final editorState = context.read<EditorState>();

    Widget child = KeyedSubtree(
      key: _contentKey,
      child: widget.child,
    );

    // 包装选区容器
    child = BlockSelectionContainer(
      node: widget.node,
      delegate: this,
      listenable: editorState.selectionNotifier,
      blockColor: editorState.editorStyle.selectionColor,
      cursorColor: editorState.editorStyle.cursorColor,
      selectionColor: editorState.editorStyle.selectionColor,
      supportTypes: const [
        BlockSelectionType.block,
        BlockSelectionType.cursor,
        BlockSelectionType.selection,
      ],
      child: child,
    );

    return child;
  }

  // ==================== SelectableMixin 实现 ====================

  @override
  CursorStyle get cursorStyle => CursorStyle.verticalLine;

  @override
  bool get shouldCursorBlink => true;

  @override
  Position start() => Position(path: widget.node.path, offset: 0);

  @override
  Position end() => Position(path: widget.node.path, offset: 1);

  @override
  Position getPositionInOffset(Offset globalOffset) {
    final contentBox = _contentRenderBox;
    if (contentBox == null) {
      return end();
    }

    final localOffset = contentBox.globalToLocal(globalOffset);
    final contentWidth = contentBox.size.width;

    // 点击左半边返回左侧位置，否则返回右侧位置
    if (localOffset.dx < contentWidth / 2) {
      return start();
    } else {
      return end();
    }
  }

  @override
  Rect? getCursorRectInPosition(
    Position position, {
    bool shiftWithBaseOffset = false,
  }) {
    final contentBox = _contentRenderBox;
    final parentBox = _renderBox;
    if (contentBox == null || parentBox == null) {
      return null;
    }

    final contentSize = contentBox.size;
    final contentOffset = shiftWithBaseOffset
        ? contentBox.localToGlobal(Offset.zero, ancestor: parentBox)
        : Offset.zero;

    // offset=0: 左侧光标，offset=1: 右侧光标
    final isLeftSide = position.offset == 0;
    final cursorX = isLeftSide
        ? contentOffset.dx
        : contentOffset.dx + contentSize.width - _cursorWidth;

    return Rect.fromLTWH(
      cursorX,
      contentOffset.dy,
      _cursorWidth,
      contentSize.height,
    );
  }

  @override
  Rect getBlockRect({bool shiftWithBaseOffset = false}) {
    final contentBox = _contentRenderBox;
    if (contentBox == null) {
      return Rect.zero;
    }

    final parentBox = _renderBox;
    if (shiftWithBaseOffset && parentBox != null) {
      final offset =
          contentBox.localToGlobal(Offset.zero, ancestor: parentBox);
      return offset & contentBox.size;
    }

    return Offset.zero & contentBox.size;
  }

  @override
  List<Rect> getRectsInSelection(
    Selection selection, {
    bool shiftWithBaseOffset = false,
  }) {
    final contentBox = _contentRenderBox;
    final parentBox = _renderBox;
    if (contentBox == null) {
      return [];
    }

    if (shiftWithBaseOffset && parentBox != null) {
      final offset =
          contentBox.localToGlobal(Offset.zero, ancestor: parentBox);
      return [offset & contentBox.size];
    }

    return [Offset.zero & contentBox.size];
  }

  @override
  Selection getSelectionInRange(Offset start, Offset end) {
    return Selection.single(
      path: widget.node.path,
      startOffset: 0,
      endOffset: 1,
    );
  }

  @override
  Offset localToGlobal(Offset offset, {bool shiftWithBaseOffset = false}) {
    final renderBox = _renderBox;
    if (renderBox == null) {
      return offset;
    }
    return renderBox.localToGlobal(offset);
  }

  @override
  TextDirection textDirection() => TextDirection.ltr;
}
