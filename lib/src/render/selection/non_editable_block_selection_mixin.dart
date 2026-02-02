import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// 非文本块（如图片、分割线、视频等）的选区处理 Mixin
///
/// 此 mixin 为非文本块提供统一的光标和选区处理能力，支持：
/// - 点击块的左半边时，光标定位到块的左侧（offset=0）
/// - 点击块的右半边时，光标定位到块的右侧（offset=1）
/// - 在块的左侧或右侧显示竖线光标
/// - 支持键盘导航（左右箭头可以在块的左右两侧之间移动）
///
/// 使用方式：
/// ```dart
/// class _MyBlockState extends State<MyBlock>
///     with SelectableMixin, NonEditableBlockSelectionMixin {
///
///   @override
///   GlobalKey get contentKey => _contentKey; // 内容区域的 GlobalKey
///
///   @override
///   Node get node => widget.node;
///
///   // ... 其他实现
/// }
/// ```
mixin NonEditableBlockSelectionMixin<T extends StatefulWidget>
    on State<T>, SelectableMixin<T> {
  /// 内容区域的 GlobalKey，用于获取内容区域的尺寸和位置
  GlobalKey get contentKey;

  /// 当前节点
  Node get node;

  /// 光标宽度（像素）
  double get cursorWidth => 2.0;

  /// 获取内容区域的 RenderBox
  RenderBox? get _contentRenderBox =>
      contentKey.currentContext?.findRenderObject() as RenderBox?;

  /// 获取组件的 RenderBox
  RenderBox? get _renderBox => context.findRenderObject() as RenderBox?;

  // ==================== SelectableMixin 实现 ====================

  /// 使用竖线光标样式
  @override
  CursorStyle get cursorStyle => CursorStyle.verticalLine;

  /// 光标闪烁
  @override
  bool get shouldCursorBlink => true;

  /// 块的起始位置（左侧，offset=0）
  @override
  Position start() => Position(path: node.path, offset: 0);

  /// 块的结束位置（右侧，offset=1）
  @override
  Position end() => Position(path: node.path, offset: 1);

  /// 根据点击位置判断光标应该在左侧还是右侧
  ///
  /// 点击左半边返回 start()，点击右半边返回 end()
  @override
  Position getPositionInOffset(Offset globalOffset) {
    final contentBox = _contentRenderBox;
    if (contentBox == null) {
      return end();
    }

    // 将全局坐标转换为内容区域的本地坐标
    final localOffset = contentBox.globalToLocal(globalOffset);
    final contentWidth = contentBox.size.width;

    // 点击位置在左半边则返回左侧位置，否则返回右侧位置
    if (localOffset.dx < contentWidth / 2) {
      return start();
    } else {
      return end();
    }
  }

  /// 获取光标在指定位置的矩形区域
  ///
  /// offset=0 时返回左侧竖线位置，offset=1 时返回右侧竖线位置
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

    // 计算内容区域相对于组件的偏移
    final contentOffset = shiftWithBaseOffset
        ? contentBox.localToGlobal(Offset.zero, ancestor: parentBox)
        : Offset.zero;

    // 根据 offset 决定光标位置
    // offset=0: 左侧光标
    // offset=1: 右侧光标
    final isLeftSide = position.offset == 0;
    final cursorX = isLeftSide
        ? contentOffset.dx
        : contentOffset.dx + contentSize.width - cursorWidth;

    return Rect.fromLTWH(
      cursorX,
      contentOffset.dy,
      cursorWidth,
      contentSize.height,
    );
  }

  /// 获取块的选区矩形（用于块选择模式）
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

  /// 获取选区范围内的矩形列表
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

  /// 获取指定范围的选区
  @override
  Selection getSelectionInRange(Offset start, Offset end) {
    return Selection.single(
      path: node.path,
      startOffset: 0,
      endOffset: 1,
    );
  }

  /// 将本地坐标转换为全局坐标
  @override
  Offset localToGlobal(Offset offset, {bool shiftWithBaseOffset = false}) {
    final renderBox = _renderBox;
    if (renderBox == null) {
      return offset;
    }
    return renderBox.localToGlobal(offset);
  }

  /// 文本方向（默认从左到右）
  @override
  TextDirection textDirection() => TextDirection.ltr;
}
