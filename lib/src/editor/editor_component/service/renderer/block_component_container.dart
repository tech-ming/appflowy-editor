import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// BlockComponentContainer is a wrapper of block component
///
/// 1. used to update the child widget when node is changed
/// ~~2. used to show block component actions~~
/// 3. used to add the layer link to the child widget
///
/// 注意：非文本块（delta == null）的选区能力由块组件自身实现，模式如下：
/// - State 同时 with SelectableMixin 和 NonEditableBlockSelectionMixin
/// - Builder 在创建 Component widget 时传入 key: node.key
/// - State 内自带一个 _contentKey，用 BlockSelectionContainer + KeyedSubtree(_contentKey)
///   包裹真实内容
/// 这样 node.key 只挂在组件自身一处，不会和上层 wrapper 重复使用导致
/// "Multiple widgets used the same GlobalKey" 冲突（典型表现：光标闪烁后持续抛错）。
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

          return CompositedTransformTarget(
            link: node.layerLink,
            child: builder(context),
          );
        },
      ),
    );
  }
}
