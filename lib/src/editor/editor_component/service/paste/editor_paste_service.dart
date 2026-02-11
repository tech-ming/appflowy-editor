import 'package:appflowy_editor/appflowy_editor.dart';

/// 统一粘贴服务
///
/// 所有粘贴入口（桌面键盘快捷键、右键菜单、移动端 IME）
/// 统一委托到此服务处理，确保行为一致。
///
/// 职责：
/// - URL / 电话号码正则检测（定义一次）
/// - 粘贴文本中的链接自动识别
/// - 选中文字 + 粘贴 URL → 转超链接
/// - 从剪贴板读取并粘贴（支持 HTML / 纯文本）
class EditorPasteService {
  EditorPasteService._();

  // ==========================================================================
  // 共享正则表达式（全局唯一定义）
  // ==========================================================================

  /// URL 正则：匹配 http / https 链接
  static final urlRegex = RegExp(
    r'https?://(?:www\.)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(?:/[^\s]*)?',
  );

  /// 电话号码正则：匹配国际电话号码格式
  static final phoneRegex = RegExp(
    r'^\+?'
    r'(?:[0-9][\s-.]?)+'
    r'[0-9]$',
  );

  // ==========================================================================
  // 工具方法
  // ==========================================================================

  /// 检测文本是否包含 URL
  static bool containsUrl(String text) => urlRegex.hasMatch(text);

  /// 检测文本是否包含电话号码
  static bool containsPhone(String text) => phoneRegex.hasMatch(text);

  /// 检测文本是否为纯 URL（整个文本就是一个 URL）
  static bool isPureUrl(String text) {
    final match = urlRegex.firstMatch(text.trim());
    return match != null &&
        match.start == 0 &&
        match.end == text.trim().length;
  }

  /// 检测文本是否为纯电话号码
  static bool isPurePhone(String text) => phoneRegex.hasMatch(text.trim());

  /// 检测文本是否为纯链接（URL 或电话）
  static bool isPureLinkOrPhone(String text) =>
      isPureUrl(text) || isPurePhone(text);

  // ==========================================================================
  // 入口1：从剪贴板粘贴
  // 调用方：paste_command.dart、copy_paste_handler.dart、浮动工具栏
  // ==========================================================================

  /// 从剪贴板读取数据并粘贴到编辑器
  ///
  /// 优先尝试 HTML 粘贴，失败后回退到纯文本粘贴。
  /// 纯文本粘贴时自动检测 URL 和电话号码。
  static Future<void> pasteFromClipboard(EditorState editorState) async {
    final data = await AppFlowyClipboard.getData();
    final html = data.html;
    final text = data.text;

    // 优先尝试 HTML 粘贴
    if (html != null && html.isNotEmpty) {
      final nodes = htmlToDocument(html).root.children.toList();
      // 清理首尾空行
      while (nodes.isNotEmpty &&
          nodes.first.delta?.isEmpty == true &&
          nodes.first.children.isEmpty) {
        nodes.removeAt(0);
      }
      while (nodes.isNotEmpty &&
          nodes.last.delta?.isEmpty == true &&
          nodes.last.children.isEmpty) {
        nodes.removeLast();
      }
      if (nodes.isNotEmpty) {
        if (nodes.length == 1) {
          await editorState.pasteSingleLineNode(nodes.first);
        } else {
          await editorState.pasteMultiLineNodes(nodes.toList());
        }
        return;
      }
    }

    // 回退到纯文本粘贴
    if (text != null && text.isNotEmpty) {
      await pasteText(editorState, text);
    }
  }

  /// 粘贴纯文本（带链接检测）
  ///
  /// 处理流程：
  /// 1. 选中文字 + 纯 URL → 将选中文字转为超链接
  /// 2. 删除当前选区
  /// 3. 构建带链接检测的节点
  /// 4. 插入节点
  static Future<void> pasteText(
    EditorState editorState,
    String text,
  ) async {
    // 1. 选中文字 + 粘贴 URL → 转超链接
    if (await maybeConvertSelectedTextToLink(editorState, text)) {
      return;
    }

    // 2. 删除当前选区
    final selection = await editorState.deleteSelectionIfNeeded();
    if (selection == null) {
      return;
    }

    // 3. 构建带链接检测的节点
    final nodes = buildNodesWithLinks(text);
    if (nodes.isEmpty) {
      return;
    }

    // 4. 插入节点
    if (nodes.length == 1) {
      await editorState.pasteSingleLineNode(nodes.first);
    } else {
      await editorState.pasteMultiLineNodes(nodes.toList());
    }
  }

  // ==========================================================================
  // 入口2：处理 IME 插入文本的链接检测
  // 调用方：delta_input_on_insert_impl.dart、delta_input_on_replace_impl.dart
  // ==========================================================================

  /// 处理 IME 插入的文本，检测并自动将 URL / 电话号码转为超链接
  ///
  /// 当插入的文本长度 > 1（粘贴场景）且包含链接时，
  /// 复用 [buildDeltaWithLinks] 统一检测，确保与其他粘贴路径行为一致。
  ///
  /// 返回 true 表示已处理（包含链接），false 表示未处理（普通文本）。
  static Future<bool> processInsertedText({
    required EditorState editorState,
    required Node node,
    required int startOffset,
    required String text,
    required Selection afterSelection,
  }) async {
    // 仅处理多字符插入（粘贴场景），单字符输入不处理
    if (text.length <= 1) {
      return false;
    }

    // 使用统一的 buildDeltaWithLinks 检测 URL 和电话号码
    final delta = buildDeltaWithLinks(text);

    // 如果 Delta 只有一个无属性的 insert，说明没有检测到链接
    final ops = delta.toList();
    final hasLink = ops.any(
      (op) => op is TextInsert && op.attributes?.isNotEmpty == true,
    );
    if (!hasLink) {
      return false;
    }

    // 使用 insertTextDelta 一次性插入整个带属性的 delta
    final transaction = editorState.transaction;
    transaction.insertTextDelta(node, startOffset, delta);
    transaction.afterSelection = afterSelection;
    await editorState.apply(transaction);
    return true;
  }

  /// 处理 IME 替换文本时的"选中文字 + 粘贴链接 → 转超链接"
  ///
  /// 当替换文本为纯 URL 或纯电话号码且有选中文字时，将选中文字格式化为超链接。
  ///
  /// 返回 true 表示已处理，false 表示未处理。
  static Future<bool> processReplacedTextAsLink({
    required EditorState editorState,
    required Node node,
    required String replacementText,
    required int replaceStart,
    required int replaceLength,
    required Selection afterSelection,
  }) async {
    if (replacementText.length <= 1 || !isPureLinkOrPhone(replacementText)) {
      return false;
    }

    final trimmed = replacementText.trim();
    final href = isPurePhone(trimmed) ? 'tel:$trimmed' : trimmed;

    final transaction = editorState.transaction;
    transaction.formatText(
      node,
      replaceStart,
      replaceLength,
      {AppFlowyRichTextKeys.href: href},
    );
    transaction.afterSelection = afterSelection;
    await editorState.apply(transaction);
    return true;
  }

  // ==========================================================================
  // 共享逻辑
  // ==========================================================================

  /// 选中文字 + 粘贴 URL/电话 → 将选中文字转为超链接
  ///
  /// 条件：
  /// - 有非折叠的单行选区（选中了文字）
  /// - 粘贴的文本是纯 URL 或纯电话号码
  ///
  /// 返回 true 表示已转换，false 表示不满足条件。
  static Future<bool> maybeConvertSelectedTextToLink(
    EditorState editorState,
    String pastedText,
  ) async {
    final selection = editorState.selection;
    if (selection == null ||
        !selection.isSingle ||
        selection.isCollapsed) {
      return false;
    }

    final trimmedText = pastedText.trim();
    final isUrl = isPureUrl(trimmedText);
    final isPhone = isPurePhone(trimmedText);

    if (!isUrl && !isPhone) {
      return false;
    }

    final node = editorState.getNodeAtPath(selection.start.path);
    if (node == null) {
      return false;
    }

    final href = isPhone ? 'tel:$trimmedText' : trimmedText;
    final transaction = editorState.transaction;
    transaction.formatText(
      node,
      selection.startIndex,
      selection.length,
      {AppFlowyRichTextKeys.href: href},
    );
    await editorState.apply(transaction);
    return true;
  }

  /// 将文本构建为带链接检测的节点列表
  ///
  /// 每行文本中的 URL 和电话号码自动识别为超链接。
  static List<Node> buildNodesWithLinks(String text) {
    return text
        .split('\n')
        .map((line) => line.replaceAll('\r', '').trimRight())
        .map((line) => paragraphNode(delta: buildDeltaWithLinks(line)))
        .toList();
  }

  /// 将单行文本构建为带链接检测的 Delta
  ///
  /// 文本中的 URL 和电话号码部分自动添加 href 属性，
  /// 其余部分作为纯文本。
  static Delta buildDeltaWithLinks(String line) {
    final delta = Delta();

    if (line.isEmpty) {
      return delta;
    }

    // 收集所有 URL 匹配
    final urlMatches = urlRegex.allMatches(line).toList();

    // 如果没有 URL，检查是否为电话号码
    if (urlMatches.isEmpty) {
      if (containsPhone(line)) {
        delta.insert(line, attributes: {
          AppFlowyRichTextKeys.href: 'tel:$line',
        },);
      } else {
        delta.insert(line);
      }
      return delta;
    }

    // 按 URL 匹配位置拆分文本
    int currentPos = 0;
    for (final match in urlMatches) {
      // 插入 URL 前的纯文本
      if (match.start > currentPos) {
        delta.insert(line.substring(currentPos, match.start));
      }

      // 插入 URL（带 href 属性）
      final url = match.group(0)!;
      delta.insert(url, attributes: {
        AppFlowyRichTextKeys.href: url,
      },);

      currentPos = match.end;
    }

    // 插入最后一个 URL 后的纯文本
    if (currentPos < line.length) {
      delta.insert(line.substring(currentPos));
    }

    return delta;
  }
}
