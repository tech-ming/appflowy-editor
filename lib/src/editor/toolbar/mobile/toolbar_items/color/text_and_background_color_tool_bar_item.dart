import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

MobileToolbarItem buildTextAndBackgroundColorMobileToolbarItem({
  List<ColorOption>? textColorOptions,
  List<ColorOption>? backgroundColorOptions,
}) {
  return MobileToolbarItem.withMenu(
    itemIconBuilder: (context, __, ___) => AFMobileIcon(
      afMobileIcons: AFMobileIcons.color,
      color: MobileToolbarTheme.of(context).iconColor,
    ),
    itemMenuBuilder: (_, editorState, ___) {
      final selection = editorState.selection;
      if (selection == null) {
        return const SizedBox.shrink();
      }

      return _TextAndBackgroundColorMenu(
        editorState,
        selection,
        textColorOptions: textColorOptions,
        backgroundColorOptions: backgroundColorOptions,
      );
    },
  );
}

class _TextAndBackgroundColorMenu extends StatefulWidget {
  const _TextAndBackgroundColorMenu(
    this.editorState,
    this.selection, {
    this.textColorOptions,
    this.backgroundColorOptions,
  });

  final EditorState editorState;
  final Selection selection;
  final List<ColorOption>? textColorOptions;
  final List<ColorOption>? backgroundColorOptions;

  @override
  State<_TextAndBackgroundColorMenu> createState() =>
      _TextAndBackgroundColorMenuState();
}

class _TextAndBackgroundColorMenuState
    extends State<_TextAndBackgroundColorMenu> {
  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarTheme.of(context);
    final tabs = <Tab>[
      Tab(text: AppFlowyEditorL10n.current.textColor),
      Tab(text: AppFlowyEditorL10n.current.backgroundColor),
    ];

    // 计算内容区高度：3 行按钮 + 2 个行间距
    final contentHeight = 3 * style.buttonHeight + 2 * style.buttonSpacing;

    return DefaultTabController(
      length: tabs.length,
      child: SizedBox(
        // 总高度 = TabBar 高度 + 间距 + 内容高度
        height: style.buttonHeight + style.buttonSpacing + contentHeight,
        child: Column(
          children: [
            // TabBar
            SizedBox(
              height: style.buttonHeight,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: tabs,
                labelColor: style.tabBarSelectedForegroundColor,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(style.borderRadius),
                  color: style.tabBarSelectedBackgroundColor,
                ),
                dividerColor: Colors.transparent,
              ),
            ),

            // 间距
            SizedBox(height: style.buttonSpacing),

            // 内容区
            Expanded(
              child: TabBarView(
                children: [
                  TextColorOptionsWidgets(
                    widget.editorState,
                    widget.selection,
                    textColorOptions: widget.textColorOptions,
                  ),
                  BackgroundColorOptionsWidgets(
                    widget.editorState,
                    widget.selection,
                    backgroundColorOptions: widget.backgroundColorOptions,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
