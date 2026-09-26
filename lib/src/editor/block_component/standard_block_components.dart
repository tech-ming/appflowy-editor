import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/heading_block_component/heading_command_shortcut.dart';
import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const standardBlockComponentConfiguration = BlockComponentConfiguration();

/// 构建标准块构建器，每次调用返回新实例
///
/// [configuration] 为文本块（段落、待办、列表、引用、标题）的基础配置：
/// 宿主统一块间距时传入，各块在其上叠加自己的占位文本。
Map<String, BlockComponentBuilder> buildStandardBlockComponentBuilderMap({
  BlockComponentConfiguration configuration =
      standardBlockComponentConfiguration,
}) {
  return {
    PageBlockKeys.type: PageBlockComponentBuilder(),
    ParagraphBlockKeys.type: ParagraphBlockComponentBuilder(
      configuration: configuration.copyWith(
        placeholderText: (_) => PlatformExtension.isDesktopOrWeb
            ? AppFlowyEditorL10n.current.slashPlaceHolder
            : ' ',
      ),
    ),
    TodoListBlockKeys.type: TodoListBlockComponentBuilder(
      configuration: configuration.copyWith(
        placeholderText: (_) => AppFlowyEditorL10n.current.toDoPlaceholder,
      ),
      toggleChildrenTriggers: [
        LogicalKeyboardKey.shift,
        LogicalKeyboardKey.shiftLeft,
        LogicalKeyboardKey.shiftRight,
      ],
    ),
    BulletedListBlockKeys.type: BulletedListBlockComponentBuilder(
      configuration: configuration.copyWith(
        placeholderText: (_) => AppFlowyEditorL10n.current.listItemPlaceholder,
      ),
    ),
    NumberedListBlockKeys.type: NumberedListBlockComponentBuilder(
      configuration: configuration.copyWith(
        placeholderText: (_) => AppFlowyEditorL10n.current.listItemPlaceholder,
      ),
    ),
    QuoteBlockKeys.type: QuoteBlockComponentBuilder(
      configuration: configuration.copyWith(
        placeholderText: (_) => AppFlowyEditorL10n.current.quote,
      ),
    ),
    HeadingBlockKeys.type: HeadingBlockComponentBuilder(
      configuration: configuration.copyWith(
        // 根据标题级别获取对应的本地化占位文本
        placeholderText: (node) {
          final level = node.attributes[HeadingBlockKeys.level] as int? ?? 1;
          switch (level) {
            case 1:
              return AppFlowyEditorL10n.current.heading1;
            case 2:
              return AppFlowyEditorL10n.current.heading2;
            case 3:
              return AppFlowyEditorL10n.current.heading3;
            default:
              return AppFlowyEditorL10n.current.heading1;
          }
        },
      ),
    ),
    ImageBlockKeys.type: ImageBlockComponentBuilder(),
    DividerBlockKeys.type: DividerBlockComponentBuilder(
      configuration: configuration.copyWith(
        padding: (node) => const EdgeInsets.symmetric(vertical: 8.0),
      ),
    ),
    TableBlockKeys.type: TableBlockComponentBuilder(),
    TableCellBlockKeys.type: TableCellBlockComponentBuilder(),
  };
}

final Map<String, BlockComponentBuilder> standardBlockComponentBuilderMap =
    buildStandardBlockComponentBuilderMap();

final List<CharacterShortcutEvent> standardCharacterShortcutEvents = [
  // '\n'
  insertNewLineAfterBulletedList,
  insertNewLineAfterTodoList,
  insertNewLineAfterNumberedList,
  insertNewLineAfterHeading,
  insertNewLine,

  // bulleted list
  formatAsteriskToBulletedList,
  formatMinusToBulletedList,

  // numbered list
  formatNumberToNumberedList,

  // quote
  formatDoubleQuoteToQuote,

  // heading
  formatSignToHeading,

  // checkbox
  // format unchecked box, [] or -[]
  formatEmptyBracketsToUncheckedBox,
  formatHyphenEmptyBracketsToUncheckedBox,

  // format checked box, [x] or -[x]
  formatFilledBracketsToCheckedBox,
  formatHyphenFilledBracketsToCheckedBox,

  // slash
  slashCommand,

  // divider
  convertMinusesToDivider,
  convertStarsToDivider,
  convertUnderscoreToDivider,

  // markdown syntax
  ...markdownSyntaxShortcutEvents,

  // 输入空格时自动将 URL / 电话号码文本转为超链接
  formatAutoLink,

  // convert => to arrow
  formatGreaterEqual,
];

final List<CommandShortcutEvent> standardCommandShortcutEvents = [
  // undo, redo
  undoCommand,
  redoCommand,

  // backspace
  convertToParagraphCommand,
  ...tableCommands,
  backspaceCommand,
  deleteLeftWordCommand,
  deleteLeftSentenceCommand,

  //delete
  deleteCommand,
  deleteRightWordCommand,

  // arrow keys
  ...arrowLeftKeys,
  ...arrowRightKeys,
  ...arrowUpKeys,
  ...arrowDownKeys,

  //
  homeCommand,
  endCommand,

  //
  toggleTodoListCommand,
  ...toggleMarkdownCommands,
  ...toggleHeadingCommands,
  toggleHighlightCommand,
  showLinkMenuCommand,
  openInlineLinkCommand,
  openLinksCommand,

  //
  indentCommand,
  outdentCommand,

  //
  exitEditingCommand,

  //
  pageUpCommand,
  pageDownCommand,

  //
  selectAllCommand,

  // copy paste and cut
  copyCommand,
  ...pasteCommands,
  cutCommand,
];
