import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/ime/character_shortcut_event_helper.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/paste/editor_paste_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:universal_platform/universal_platform.dart';

Future<void> onInsert(
  TextEditingDeltaInsertion insertion,
  EditorState editorState,
  List<CharacterShortcutEvent> characterShortcutEvents,
) async {
  AppFlowyEditorLog.input.debug('onInsert: $insertion');

  // 光标停在非文本块（图片、视频等）左右：先于字符快捷键处理，它们只认文本块
  if (await _insertBesideNonTextBlock(insertion, editorState)) {
    return;
  }

  final textInserted = insertion.textInserted;

  /// On mobile devices, the "/" is context-sensitive,which means it can't be
  /// recognized as a standalone character. This requires special handling.
  final isMobileSlash =
      UniversalPlatform.isMobile && insertion.textInserted == '/';

  // In France, the backtick key is used to toggle a character style.
  // We should prevent the execution of character shortcut events when the
  // composing range is not collapsed.
  if (insertion.composing.isCollapsed || isMobileSlash) {
    // execute character shortcut events
    final execution = await executeCharacterShortcutEvent(
      editorState,
      textInserted,
      characterShortcutEvents,
    );

    if (execution) {
      editorState.sliceUpcomingAttributes = false;

      return;
    }
  }

  var selection = editorState.selection;
  if (selection == null) {
    return;
  }

  if (!selection.isCollapsed) {
    await editorState.deleteSelection(selection);
  }

  selection = editorState.selection?.normalized;
  if (selection == null || !selection.isCollapsed) {
    return;
  }

  // IME
  // single line
  final node = editorState.getNodeAtPath(selection.start.path);
  if (node == null) {
    return;
  }
  assert(node.delta != null);

  if (kDebugMode) {
    // verify the toggled keys are supported.
    assert(
      editorState.toggledStyle.keys.every(
        (element) => AppFlowyRichTextKeys.supportToggled.contains(element),
      ),
    );
  }

  final afterSelection = Selection(
    start: Position(
      path: node.path,
      offset: insertion.selection.baseOffset,
    ),
    end: Position(
      path: node.path,
      offset: insertion.selection.extentOffset,
    ),
  );

  // 粘贴场景：委托给统一粘贴服务处理 URL 自动识别
  final handled = await EditorPasteService.processInsertedText(
    editorState: editorState,
    node: node,
    startOffset: selection.startIndex,
    text: textInserted,
    afterSelection: afterSelection,
  );

  if (handled) {
    return;
  }

  // 普通文本插入
  final transaction = editorState.transaction
    ..insertText(
      node,
      selection.startIndex,
      textInserted,
      toggledAttributes: editorState.toggledStyle,
      sliceAttributes: editorState.sliceUpcomingAttributes,
    )
    ..afterSelection = afterSelection;
  await editorState.apply(transaction);
}

/// 光标在非文本块左右时，把输入写进紧挨着的新段落，返回是否已处理
///
/// 同 ProseMirror gapcursor / Notion：原子块旁不能直接落字，输入即新建一行——
/// 光标在块左侧插在块前，右侧插在块后。
Future<bool> _insertBesideNonTextBlock(
  TextEditingDeltaInsertion insertion,
  EditorState editorState,
) async {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return false;
  }
  final node = editorState.getNodeAtPath(selection.start.path);
  final text = insertion.textInserted;
  if (node == null || node.delta != null || text.isEmpty) {
    return false;
  }

  final atEnd = selection.start.offset > 0;
  final path = atEnd ? node.path.next : node.path;
  final transaction = editorState.transaction;

  // 回车：只补一个空行；块后的空行接住光标，块前的空行光标仍留在块左侧
  if (text == '\n') {
    transaction
      ..insertNode(path, paragraphNode())
      ..afterSelection = Selection.collapsed(
        atEnd ? Position(path: path) : Position(path: path.next),
      );
    await editorState.apply(transaction);

    return true;
  }

  final attributes =
      editorState.toggledStyle.isEmpty ? null : {...editorState.toggledStyle};
  final lines = text.split('\n');
  transaction.insertNodes(path, [
    for (final line in lines)
      paragraphNode(delta: Delta()..insert(line, attributes: attributes)),
  ]);
  // 非文本块的输入法缓冲区为空，单行时 insertion 的选区偏移即新段落内的偏移
  // （保住输入法组合区）；多行落到最后一行末尾
  final lastPath = path.sublist(0, path.length - 1)..add(path.last + lines.length - 1);
  transaction.afterSelection = lines.length == 1
      ? Selection(
          start: Position(path: path, offset: insertion.selection.baseOffset),
          end: Position(path: path, offset: insertion.selection.extentOffset),
        )
      : Selection.collapsed(
          Position(path: lastPath, offset: lines.last.length),
        );
  await editorState.apply(transaction);

  return true;
}
