import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MobileScrollService extends StatefulWidget {
  const MobileScrollService({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<MobileScrollService> createState() => _MobileScrollServiceState();
}

class _MobileScrollServiceState extends State<MobileScrollService>
    implements AppFlowyScrollService {
  late final editorState = context.read<EditorState>();
  late final autoScroller = editorState.autoScroller;
  late final editorScrollController = context.read<EditorScrollController>();

  @override
  double get dy => context.read<EditorScrollController>().offsetNotifier.value;

  @override
  double? get onePageHeight {
    final renderBox = context.findRenderObject() as RenderBox?;

    return renderBox?.size.height;
  }

  @override
  double get maxScrollExtent =>
      editorState.scrollableState!.position.maxScrollExtent;

  @override
  double get minScrollExtent =>
      editorState.scrollableState!.position.minScrollExtent;

  @override
  int? get page {
    if (onePageHeight != null) {
      final scrollExtent = maxScrollExtent - minScrollExtent;

      return (scrollExtent / onePageHeight!).ceil();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void scrollTo(
    double dy, {
    Duration duration = const Duration(
      milliseconds: 150,
    ),
  }) {
    dy = dy.clamp(
      minScrollExtent,
      maxScrollExtent,
    );
    editorScrollController.scrollOffsetController.animateScroll(
      offset: dy,
      duration: duration,
    );
  }

  /// 把第 [index] 个顶层块（文档下标，不含 header）滚入可见区
  ///
  /// 不走 itemScrollController.jumpTo：那会把列表重新锚定到该块，
  /// 详见 [EditorScrollController.revealNodes]。
  @override
  void jumpTo(int index) {
    final children = editorState.document.root.children;
    if (index < 0 || index >= children.length) {
      return;
    }
    editorScrollController.revealNode(
      children.elementAt(index),
      duration: Duration.zero,
    );
  }

  @override
  Future<bool> revealNodes(
    List<Node> nodes, {
    double? alignment,
    bool preferEnd = false,
    Duration? duration,
  }) {
    return editorScrollController.revealNodes(
      nodes,
      alignment: alignment,
      preferEnd: preferEnd,
      duration: duration,
    );
  }

  @override
  void jumpToTop() {}

  @override
  void jumpToBottom() {}

  @override
  void disable() {
    AppFlowyEditorLog.scroll.debug('disable scroll service');
  }

  @override
  void enable() {
    AppFlowyEditorLog.scroll.debug('enable scroll service');
  }

  @override
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 200,
    AxisDirection? direction,
    Duration? duration,
  }) {
    autoScroller?.startAutoScroll(
      offset,
      edgeOffset: edgeOffset,
      direction: direction,
      duration: duration,
    );
  }

  @override
  void stopAutoScroll() {
    autoScroller?.stopAutoScroll();
  }

  @override
  void goBallistic(double velocity) {
    throw UnimplementedError();
  }

  @override
  ScrollController get scrollController => throw UnimplementedError();
}
