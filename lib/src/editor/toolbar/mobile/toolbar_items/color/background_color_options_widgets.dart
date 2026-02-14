import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class BackgroundColorOptionsWidgets extends StatefulWidget {
  const BackgroundColorOptionsWidgets(
    this.editorState,
    this.selection, {
    this.backgroundColorOptions,
    super.key,
  });

  final Selection selection;
  final EditorState editorState;
  final List<ColorOption>? backgroundColorOptions;

  @override
  State<BackgroundColorOptionsWidgets> createState() =>
      _BackgroundColorOptionsWidgetsState();
}

class _BackgroundColorOptionsWidgetsState
    extends State<BackgroundColorOptionsWidgets> {
  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarTheme.of(context);
    final colorOptions =
        widget.backgroundColorOptions ?? generateHighlightColorOptions();
    final selection = widget.selection;
    final nodes = widget.editorState.getNodesInSelection(selection);

    // 获取当前背景颜色值
    // 折叠选区时优先使用 toggledStyle，其次从 sliceAttributes 推导
    final String? currentBgColor;
    final bool hasBgColor;

    if (selection.isCollapsed) {
      final toggledStyle = widget.editorState.toggledStyle;
      if (toggledStyle.containsKey(AppFlowyRichTextKeys.backgroundColor)) {
        // toggledStyle 中有值（可能是颜色字符串或 null），以此为准
        currentBgColor =
            toggledStyle[AppFlowyRichTextKeys.backgroundColor] as String?;
        hasBgColor = currentBgColor != null;
      } else {
        // 没有操作过 toggledStyle，从 delta 属性推导
        final node = nodes.firstOrNull;
        final delta = node?.delta;
        final sliced = delta?.sliceAttributes(selection.startIndex);
        currentBgColor =
            sliced?[AppFlowyRichTextKeys.backgroundColor] as String?;
        hasBgColor = currentBgColor != null;
      }
    } else {
      hasBgColor = nodes.allSatisfyInSelection(selection, (delta) {
        return delta.everyAttributes(
          (attributes) =>
              attributes[AppFlowyRichTextKeys.backgroundColor] != null,
        );
      });
      currentBgColor = null;
    }

    return Scrollbar(
      child: GridView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        gridDelegate: buildMobileToolbarMenuGridDelegate(
          mobileToolbarStyle: style,
          crossAxisCount: 3,
        ),
        children: [
          ClearColorButton(
            onPressed: () {
              if (hasBgColor) {
                setState(() {
                  if (selection.isCollapsed) {
                    widget.editorState.updateToggledStyle(
                      AppFlowyRichTextKeys.backgroundColor,
                      null,
                    );
                  } else {
                    widget.editorState.formatDelta(
                      selection,
                      {AppFlowyRichTextKeys.backgroundColor: null},
                    );
                  }
                });
              }
            },
            isSelected: !hasBgColor,
          ),
          // 颜色选项按钮
          ...colorOptions.map((e) {
            final bool isSelected;
            if (selection.isCollapsed) {
              isSelected = currentBgColor == e.colorHex;
            } else {
              isSelected = nodes.allSatisfyInSelection(selection, (delta) {
                return delta.everyAttributes(
                  (attributes) =>
                      attributes[AppFlowyRichTextKeys.backgroundColor] ==
                      e.colorHex,
                );
              });
            }

            return ColorButton(
              isBackgroundColor: true,
              colorOption: e,
              onPressed: () {
                setState(() {
                  if (selection.isCollapsed) {
                    widget.editorState.updateToggledStyle(
                      AppFlowyRichTextKeys.backgroundColor,
                      isSelected ? null : e.colorHex,
                    );
                  } else {
                    // 非折叠选区：使用固定的 selection 而非 editorState.selection
                    // 避免键盘关闭后 editorState.selection 可能变化的问题
                    formatHighlightColor(
                      widget.editorState,
                      selection,
                      isSelected ? null : e.colorHex,
                    );
                  }
                });
              },
              isSelected: isSelected,
            );
          }),
        ],
      ),
    );
  }
}
