import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/paste/editor_paste_service.dart';

/// 输入空格时自动将前方的 URL 或电话号码文本转为超链接
///
/// 例如：输入 "https://example.com " 后，URL 部分自动变为可点击链接
/// 例如：输入 "13711112222 " 后，号码部分自动变为可点击电话链接
final CharacterShortcutEvent formatAutoLink = CharacterShortcutEvent(
  key: 'format url or phone to link when typing space',
  character: ' ',
  handler: (editorState) async => _handleAutoFormatLink(
    editorState: editorState,
  ),
);

bool _handleAutoFormatLink({
  required EditorState editorState,
}) {
  final selection = editorState.selection;

  // 仅在光标折叠（非选区）状态下触发
  if (selection == null || !selection.isCollapsed) {
    return false;
  }

  final node = editorState.getNodeAtPath(selection.end.path);
  final delta = node?.delta;
  if (node == null || delta == null) {
    return false;
  }

  // 获取光标前的全部文本
  final plainText = delta.toPlainText().substring(0, selection.end.offset);

  // 优先检测 URL
  final urlMatches =
      EditorPasteService.urlRegex.allMatches(plainText).toList();
  if (urlMatches.isNotEmpty) {
    final lastMatch = urlMatches.last;
    // URL 必须紧邻光标位置
    if (lastMatch.end == selection.end.offset) {
      return _applyLinkFormat(
        editorState: editorState,
        node: node,
        delta: delta,
        selection: selection,
        start: lastMatch.start,
        end: lastMatch.end,
        href: lastMatch.group(0)!,
      );
    }
  }

  // 检测电话号码：取光标前最后一个"词"（空格分隔）
  final lastWord = plainText.split(RegExp(r'\s')).last;
  if (lastWord.isNotEmpty && EditorPasteService.isPurePhone(lastWord)) {
    final start = plainText.length - lastWord.length;
    return _applyLinkFormat(
      editorState: editorState,
      node: node,
      delta: delta,
      selection: selection,
      start: start,
      end: plainText.length,
      href: 'tel:$lastWord',
    );
  }

  return false;
}

/// 将指定范围的文本格式化为超链接，并在末尾插入空格
bool _applyLinkFormat({
  required EditorState editorState,
  required Node node,
  required Delta delta,
  required Selection selection,
  required int start,
  required int end,
  required String href,
}) {
  // 检查该位置的文本是否已经是链接，避免重复处理
  final slicedDelta = delta.slice(start, end);
  final alreadyLinked = slicedDelta.everyAttributes(
    (attrs) => attrs[AppFlowyRichTextKeys.href] != null,
  );
  if (alreadyLinked) {
    return false;
  }

  final transaction = editorState.transaction
    ..formatText(
      node,
      start,
      end - start,
      {AppFlowyRichTextKeys.href: href},
    )
    ..insertText(
      node,
      selection.end.offset,
      ' ',
    )
    ..afterSelection = Selection.collapsed(
      Position(
        path: selection.end.path,
        offset: selection.end.offset + 1,
      ),
    );
  editorState.apply(transaction);

  return true;
}
