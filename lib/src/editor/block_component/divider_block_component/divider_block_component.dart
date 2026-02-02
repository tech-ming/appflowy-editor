import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class DividerBlockKeys {
  const DividerBlockKeys._();

  static const String type = 'divider';
}

// creating a new callout node
Node dividerNode() {
  return Node(
    type: DividerBlockKeys.type,
  );
}

typedef DividerBlockWrapper = Widget Function(
  BuildContext context,
  Node node,
  Widget child,
);

class DividerBlockComponentBuilder extends BlockComponentBuilder {
  DividerBlockComponentBuilder({
    super.configuration,
    this.lineColor = Colors.grey,
    this.height = 10,
    this.wrapper,
  });

  final Color lineColor;
  final double height;
  final DividerBlockWrapper? wrapper;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;

    return DividerBlockComponentWidget(
      // 不使用 node.key，让 BlockComponentContainer 自动包装
      node: node,
      configuration: configuration,
      lineColor: lineColor,
      height: height,
      wrapper: wrapper,
      showActions: showActions(node),
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
      actionTrailingBuilder: (context, state) => actionTrailingBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  @override
  BlockComponentValidate get validate => (node) => node.children.isEmpty;
}

class DividerBlockComponentWidget extends BlockComponentStatefulWidget {
  const DividerBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.actionTrailingBuilder,
    super.configuration = const BlockComponentConfiguration(),
    this.lineColor = Colors.grey,
    this.height = 10,
    this.wrapper,
  });

  final Color lineColor;
  final double height;
  final DividerBlockWrapper? wrapper;

  @override
  State<DividerBlockComponentWidget> createState() =>
      _DividerBlockComponentWidgetState();
}

class _DividerBlockComponentWidgetState
    extends State<DividerBlockComponentWidget>
    with BlockComponentConfigurable {
  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      height: widget.height,
      alignment: Alignment.center,
      child: Divider(
        color: widget.lineColor,
        thickness: 1,
      ),
    );

    child = Padding(
      padding: padding,
      child: child,
    );

    if (widget.showActions && widget.actionBuilder != null) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        actionTrailingBuilder: widget.actionTrailingBuilder,
        child: child,
      );
    }

    if (widget.wrapper != null) {
      child = widget.wrapper!(context, node, child);
    }

    return child;
  }
}
