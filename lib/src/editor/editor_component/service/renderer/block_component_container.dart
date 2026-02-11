import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/non_editable_block_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// BlockComponentContainer is a wrapper of block component
///
/// 1. used to update the child widget when node is changed
/// ~~2. used to show block component actions~~
/// 3. used to add the layer link to the child widget
/// 4. automatically wraps non-editable blocks (delta == null) with selection support
class BlockComponentContainer extends StatelessWidget {
  const BlockComponentContainer({
    super.key,
    required this.configuration,
    required this.node,
    required this.builder,
  });

  final Node node;
  final BlockComponentConfiguration configuration;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Node>.value(
      value: node,
      child: Consumer<Node>(
        builder: (_, __, ___) {
          AppFlowyEditorLog.editor.debug(
            'node is rebuilding...: type: ${node.type} ',
          );

          // 构建原始子 widget
          Widget child = builder(context);

          // 非文本块（delta == null）自动包装选区能力
          // 不传入 key，让 Flutter 自动管理 widget 生命周期
          // node.key 是 GlobalKey，不能用作子 widget 的 key，否则会导致冲突
          if (node.delta == null) {
            child = NonEditableBlockWrapper(
              node: node,
              child: child,
            );
          }

          return CompositedTransformTarget(
            link: node.layerLink,
            child: child,
          );
        },
      ),
    );
  }
}
