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
          // 必须使用 node.key 作为 NonEditableBlockWrapper 的 key，
          // 否则 node.selectable 会返回 null，导致点击非文本块两边
          // 时无法通过 selectable.getPositionInOffset 定位光标
          // (desktop_selection_service._onTapDown 会走清空分支)。
          // 文本块自己已经将 node.key 传给内部 widget，因此不会冲突。
          if (node.delta == null) {
            child = NonEditableBlockWrapper(
              key: node.key,
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
