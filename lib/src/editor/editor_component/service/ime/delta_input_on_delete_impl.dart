import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> onDelete(
  TextEditingDeltaDeletion deletion,
  EditorState editorState,
) async {
  AppFlowyEditorLog.input.debug('onDelete: $deletion');

  final selection = editorState.selection;
  if (selection == null) {
    return;
  }

  // IME
  // 只看删除范围：删掉的是输入法缓冲区开头的占位符时范围为空，应交给退格命令。
  // 不能以组合区是否有效来判断——部分安卓 / 鸿蒙输入法删除后会重新上报组合区
  // （如 (0,0)），误走这里就成了零长度删除，退格被吞掉。
  if (selection.isSingle) {
    final node = editorState.getNodeAtPath(selection.start.path);
    if (node?.delta != null && !deletion.deletedRange.isCollapsed) {
      final node = editorState.getNodesInSelection(selection).first;
      final start = deletion.deletedRange.start;
      final length = deletion.deletedRange.end - start;
      final transaction = editorState.transaction;
      final afterSelection = Selection(
        start: Position(
          path: node.path,
          offset: deletion.selection.baseOffset,
        ),
        end: Position(
          path: node.path,
          offset: deletion.selection.extentOffset,
        ),
      );
      transaction
        ..deleteText(node, start, length)
        ..afterSelection = afterSelection;
      await editorState.apply(transaction);

      return;
    }
  }

  // use backspace command instead.
  if (KeyEventResult.ignored ==
      convertToParagraphCommand.execute(editorState)) {
    backspaceCommand.execute(editorState);
  }
}
