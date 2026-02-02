import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_event.dart';
import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:flutter/services.dart';

/// insert a new line block
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent insertNewLine = CharacterShortcutEvent(
  key: 'insert a new line',
  character: '\n',
  handler: _insertNewLineHandler,
);

CharacterShortcutEventHandler _insertNewLineHandler = (editorState) async {
  // on desktop or web, shift + enter to insert a '\n' character to the same line.
  // so, we should return the false to let the system handle it.
  if (PlatformExtension.isNotMobile &&
      HardwareKeyboard.instance.isShiftPressed) {
    return false;
  }

  final selection = editorState.selection?.normalized;
  if (selection == null) {
    return false;
  }

  // 检查是否是非文本块（delta == null）
  final node = editorState.getNodeAtPath(selection.start.path);
  if (node != null && node.delta == null) {
    // 非文本块：根据光标位置决定在上方还是下方插入新行
    final transaction = editorState.transaction;
    final position = selection.start;

    // offset=0 在上方插入，offset=1 在下方插入
    final insertPath = position.offset == 0 ? position.path : position.path.next;

    transaction.insertNode(
      insertPath,
      paragraphNode(),
    );

    // 光标移到新插入的段落
    transaction.afterSelection = Selection.collapsed(
      Position(path: insertPath, offset: 0),
    );

    await editorState.apply(transaction);
    return true;
  }

  // delete the selection
  await editorState.deleteSelection(selection);
  // insert a new line
  await editorState.insertNewLine(position: selection.start);

  return true;
};
