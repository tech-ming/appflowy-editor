import 'package:flutter/material.dart';

import 'package:appflowy_editor/appflowy_editor.dart';

/// Backspace key event.
///
/// - support
///   - desktop
///   - web
///   - mobile
///
final CommandShortcutEvent backspaceCommand = CommandShortcutEvent(
  key: 'backspace',
  getDescription: () => AppFlowyEditorL10n.current.cmdDeleteLeft,
  command: 'backspace, shift+backspace',
  handler: _backspaceCommandHandler,
);

CommandShortcutEventHandler _backspaceCommandHandler = (editorState) {
  final selection = editorState.selection;
  final selectionType = editorState.selectionType;

  if (selection == null) {
    return KeyEventResult.ignored;
  }

  final reason = editorState.selectionUpdateReason;

  if (selectionType == SelectionType.block) {
    return _backspaceInBlockSelection(editorState);
  } else if (selection.isCollapsed) {
    return _backspaceInCollapsedSelection(editorState);
  } else if (reason == SelectionUpdateReason.selectAll) {
    return _backspaceInSelectAll(editorState);
  } else {
    return _backspaceInNotCollapsedSelection(editorState);
  }
};

/// Handle backspace key event when selection is collapsed.
CommandShortcutEventHandler _backspaceInCollapsedSelection = (editorState) {
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

  // 处理非文本块（delta == null 的节点，如图片、分割线等）
  if (node.delta == null) {
    if (position.offset == 0) {
      // 光标在非文本块左侧（offset=0）：
      // 尝试将光标移到上一个节点的末尾，而不是删除当前块
      Node? tableParent =
          node.findParent((element) => element.type == TableBlockKeys.type);
      Node? prevTableParent;
      final prev = node.previousNodeWhere((element) {
        prevTableParent = element
            .findParent((element) => element.type == TableBlockKeys.type);
        return tableParent != prevTableParent || element.delta != null;
      });

      if (prev != null && prev.delta != null && tableParent == prevTableParent) {
        // 移到上一个文本块的末尾
        transaction.afterSelection = Selection.collapsed(
          Position(path: prev.path, offset: prev.delta!.length),
        );
      } else {
        // 没有上一个文本块，尝试移到上一个非文本块的右侧
        final prevAny = node.previousNodeWhere((element) {
          prevTableParent = element
              .findParent((element) => element.type == TableBlockKeys.type);
          return tableParent != prevTableParent || true;
        });
        if (prevAny != null && tableParent == prevTableParent) {
          transaction.afterSelection = Selection.collapsed(
            Position(path: prevAny.path, offset: 1),
          );
        } else {
          // 没有上一个节点，不做任何操作
          return KeyEventResult.handled;
        }
      }
      editorState.apply(transaction);
      return KeyEventResult.handled;
    } else {
      // 光标在非文本块右侧（offset=1）：删除整个块，替换为空文本行
      final targetPath = position.path;

      // 先插入空段落到当前位置，再删除非文本块
      // 注意：insertNode 会把新节点插入到指定路径，原节点往后移
      // 所以删除时要用 targetPath.next
      transaction.insertNode(targetPath, paragraphNode());
      transaction.deleteNode(node);

      // 光标定位到新段落开头
      transaction.afterSelection = Selection.collapsed(
        Position(path: targetPath, offset: 0),
      );

      editorState.apply(transaction);
      return KeyEventResult.handled;
    }
  }

  // Why do we use prevRunPosition instead of the position start offset?
  // Because some character's length > 1, for example, emoji.
  final index = node.delta!.prevRunePosition(position.offset);

  if (index < 0) {
    // move this node to it's parent in below case.
    // the node's next is null
    // and the node's children is empty
    if (node.next == null &&
        node.children.isEmpty &&
        node.parent?.parent != null &&
        node.parent?.delta != null) {
      final path = node.parent!.path.next;
      transaction
        ..deleteNode(node)
        ..insertNode(path, node)
        ..afterSelection = Selection.collapsed(
          Position(
            path: path,
            offset: 0,
          ),
        );
    } else {
      // If the deletion crosses columns and starts from the beginning position
      // skip the node deletion process
      // otherwise it will cause an error in table rendering.
      if (node.parent?.type == TableCellBlockKeys.type &&
          position.offset == 0) {
        return KeyEventResult.handled;
      }

      Node? tableParent =
          node.findParent((element) => element.type == TableBlockKeys.type);
      Node? prevTableParent;

      // 首先检查前一个节点（无论是否有 delta）
      final prevAny = node.previousNodeWhere((element) {
        prevTableParent = element
            .findParent((element) => element.type == TableBlockKeys.type);
        return tableParent != prevTableParent || true; // 找到任何前一个节点
      });

      // 如果前一个节点是无文本块（图片、分割线等），将光标移到该块的右侧
      // 而不是直接删除它，这样用户需要再按一次删除键才能真正删除该块
      if (prevAny != null &&
          prevAny.delta == null &&
          tableParent == prevTableParent) {
        // 光标移动到前一个块的右侧（offset=1）
        transaction.afterSelection = Selection.collapsed(
          Position(path: prevAny.path, offset: 1),
        );
        // 如果当前行是空行，则删除它
        if (node.delta != null && node.delta!.isEmpty) {
          transaction.deleteNode(node);
        }
        editorState.apply(transaction);
        return KeyEventResult.handled;
      }

      // 查找前一个有文本的节点用于合并
      final prev = node.previousNodeWhere((element) {
        prevTableParent = element
            .findParent((element) => element.type == TableBlockKeys.type);
        // break if only one is in a table or they're in different tables
        return tableParent != prevTableParent ||
            // merge with the previous node contains delta.
            element.delta != null;
      });
      // table nodes should be deleted using the table menu
      // in-table paragraphs should only be deleted inside the table
      if (prev != null && tableParent == prevTableParent) {
        assert(prev.delta != null);
        transaction
          ..mergeText(prev, node)
          ..insertNodes(
            // insert children to previous node
            prev.path.next,
            node.children.toList(),
          )
          ..deleteNode(node)
          ..afterSelection = Selection.collapsed(
            Position(
              path: prev.path,
              offset: prev.delta!.length,
            ),
          );
      } else {
        // do nothing if there is no previous node contains delta.
        return KeyEventResult.ignored;
      }
    }
  } else {
    // Although the selection may be collapsed,
    //  its length may not always be equal to 1 because some characters have a length greater than 1.
    transaction.deleteText(
      node,
      index,
      position.offset - index,
    );
  }

  editorState.apply(transaction);

  return KeyEventResult.handled;
};

/// Handle backspace key event when selection is not collapsed.
CommandShortcutEventHandler _backspaceInNotCollapsedSelection = (editorState) {
  final selection = editorState.selection;
  if (selection == null || selection.isCollapsed) {
    return KeyEventResult.ignored;
  }
  editorState.deleteSelection(selection);

  return KeyEventResult.handled;
};

CommandShortcutEventHandler _backspaceInBlockSelection = (editorState) {
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

CommandShortcutEventHandler _backspaceInSelectAll = (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  final transaction = editorState.transaction;
  final nodes = editorState.getNodesInSelection(selection);
  transaction.deleteNodes(nodes);

  // Insert a new paragraph node to avoid locking the editor
  transaction.insertNode(
    editorState.document.root.children.first.path,
    paragraphNode(),
  );
  transaction.afterSelection = Selection.collapsed(Position(path: [0]));

  editorState.apply(transaction);

  return KeyEventResult.handled;
};
