import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Select all key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent selectAllCommand = CommandShortcutEvent(
  key: 'select all the selectable content',
  getDescription: () => AppFlowyEditorL10n.current.cmdSelectAll,
  command: 'ctrl+a',
  macOSCommand: 'cmd+a',
  handler: _selectAllCommandHandler,
);

/// 全选只覆盖文字：从首个文本块开头到最后一个文本块末尾，
/// 非文本块（图片、视频等自定义块）不属于文字选区，没有文字时不选
CommandShortcutEventHandler _selectAllCommandHandler = (editorState) {
  final root = editorState.document.root;
  if (root.children.isEmpty || editorState.selection == null) {
    return KeyEventResult.ignored;
  }
  final first = _firstTextNode(root);
  final last = _lastTextNode(root);
  if (first == null || last == null) {
    return KeyEventResult.handled;
  }
  editorState.updateSelectionWithReason(
    Selection(
      start: Position(path: first.path),
      end: Position(path: last.path, offset: last.delta!.length),
    ),
    reason: SelectionUpdateReason.selectAll,
  );

  return KeyEventResult.handled;
};

/// 文档顺序下的第一个文本块（父块先于子块）
Node? _firstTextNode(Node parent) {
  for (final child in parent.children) {
    if (child.delta != null) {
      return child;
    }
    final nested = _firstTextNode(child);
    if (nested != null) {
      return nested;
    }
  }

  return null;
}

/// 文档顺序下的最后一个文本块（子块后于父块）
Node? _lastTextNode(Node parent) {
  for (final child in parent.children.toList().reversed) {
    final nested = _lastTextNode(child);
    if (nested != null) {
      return nested;
    }
    if (child.delta != null) {
      return child;
    }
  }

  return null;
}
