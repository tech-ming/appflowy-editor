import 'package:flutter/material.dart';

import 'package:appflowy_editor/appflowy_editor.dart';

/// Delete key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent deleteCommand = CommandShortcutEvent(
  key: 'Delete Key',
  getDescription: () => AppFlowyEditorL10n.current.cmdDeleteRight,
  command: 'delete, shift+delete',
  handler: _deleteCommandHandler,
);

CommandShortcutEventHandler _deleteCommandHandler = (editorState) {
  final selection = editorState.selection;
  final selectionType = editorState.selectionType;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  if (selectionType == SelectionType.block) {
    return _deleteInBlockSelection(editorState);
  } else if (selection.isCollapsed) {
    return _deleteInCollapsedSelection(editorState);
  } else {
    return _deleteInNotCollapsedSelection(editorState);
  }
};

/// Handle delete key event when selection is collapsed.
CommandShortcutEventHandler _deleteInCollapsedSelection = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  final position = selection.start;
  final node = editorState.getNodeAtPath(position.path);
  if (node == null) {
    return KeyEventResult.ignored;
  }

  final transaction = editorState.transaction;

  // 处理无文本内容的块（图片、分割线等）
  // 删除整个块，并将光标移动到下一个块
  if (node.delta == null) {
    final next = node.next;
    transaction.deleteNode(node);

    if (next != null) {
      // 移动光标到下一个节点的开始位置
      transaction.afterSelection = Selection.collapsed(
        Position(path: next.path, offset: 0),
      );
    } else {
      // 如果没有下一个节点，保持在当前路径
      transaction.afterSelection = Selection.collapsed(
        Position(path: position.path, offset: 0),
      );
    }

    editorState.apply(transaction);
    return KeyEventResult.handled;
  }

  final delta = node.delta!;

  if (position.offset == delta.length) {
    Node? tableParent =
        node.findParent((element) => element.type == TableBlockKeys.type);
    Node? nextTableParent;
    final next = node.findDownward((element) {
      nextTableParent =
          element.findParent((element) => element.type == TableBlockKeys.type);
      // break if only one is in a table or they're in different tables
      return tableParent != nextTableParent ||
          // merge the next node with delta OR delete the next non-delta node
          true; // 改为始终找到下一个节点
    });

    // 如果下一个节点没有 delta（图片、分割线等），直接删除它
    if (next != null && next.delta == null && tableParent == nextTableParent) {
      transaction.deleteNode(next);
      // 光标保持在当前位置
      transaction.afterSelection = selection;
      editorState.apply(transaction);
      return KeyEventResult.handled;
    }

    // 表格节点应该使用表格菜单删除
    // 表格内的段落只能在表格内删除
    if (next != null && next.delta != null && tableParent == nextTableParent) {
      if (next.children.isNotEmpty) {
        final path = node.path + [node.children.length];
        transaction.insertNodes(path, next.children);
      }
      transaction
        ..deleteNode(next)
        ..mergeText(
          node,
          next,
        );
      editorState.apply(transaction);

      return KeyEventResult.handled;
    }
  } else {
    final nextIndex = delta.nextRunePosition(position.offset);
    if (nextIndex <= delta.length) {
      transaction.deleteText(
        node,
        position.offset,
        nextIndex - position.offset,
      );
      editorState.apply(transaction);

      return KeyEventResult.handled;
    }
  }

  return KeyEventResult.ignored;
};

/// Handle delete key event when selection is not collapsed.
CommandShortcutEventHandler _deleteInNotCollapsedSelection = (editorState) {
  final selection = editorState.selection;
  if (selection == null || selection.isCollapsed) {
    return KeyEventResult.ignored;
  }
  editorState.deleteSelection(selection);

  return KeyEventResult.handled;
};

CommandShortcutEventHandler _deleteInBlockSelection = (editorState) {
  final selection = editorState.selection;
  if (selection == null || editorState.selectionType != SelectionType.block) {
    return KeyEventResult.ignored;
  }
  final transaction = editorState.transaction;
  transaction.deleteNodesAtPath(selection.start.path);
  editorState
      .apply(transaction)
      .then((value) => editorState.selectionType = null);

  return KeyEventResult.handled;
};
