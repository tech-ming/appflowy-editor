import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class TextColorOptionsWidgets extends StatefulWidget {
  const TextColorOptionsWidgets(
    this.editorState,
    this.selection, {
    this.textColorOptions,
    super.key,
  });

  final Selection selection;
  final EditorState editorState;
  final List<ColorOption>? textColorOptions;

  @override
  State<TextColorOptionsWidgets> createState() =>
      _TextColorOptionsWidgetsState();
}

class _TextColorOptionsWidgetsState extends State<TextColorOptionsWidgets> {
  @override
  Widget build(BuildContext context) {
    final style = MobileToolbarTheme.of(context);

    final selection = widget.selection;
    final nodes = widget.editorState.getNodesInSelection(selection);

    // 获取当前文字颜色值
    // 折叠选区时优先使用 toggledStyle，其次从 sliceAttributes 推导
    final String? currentTextColor;
    final bool hasTextColor;

    if (selection.isCollapsed) {
      final toggledStyle = widget.editorState.toggledStyle;
      if (toggledStyle.containsKey(AppFlowyRichTextKeys.textColor)) {
        // toggledStyle 中有值（可能是颜色字符串或 null），以此为准
        currentTextColor =
            toggledStyle[AppFlowyRichTextKeys.textColor] as String?;
        hasTextColor = currentTextColor != null;
      } else {
        // 没有操作过 toggledStyle，从 delta 属性推导
        final node = nodes.firstOrNull;
        final delta = node?.delta;
        final sliced = delta?.sliceAttributes(selection.startIndex);
        currentTextColor =
            sliced?[AppFlowyRichTextKeys.textColor] as String?;
        hasTextColor = currentTextColor != null;
      }
    } else {
      hasTextColor = nodes.allSatisfyInSelection(selection, (delta) {
        return delta.everyAttributes(
          (attributes) => attributes[AppFlowyRichTextKeys.textColor] != null,
        );
      });
      currentTextColor = null; // 非折叠选区逐个匹配
    }

    final colorOptions = widget.textColorOptions ?? generateTextColorOptions();

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
              if (hasTextColor) {
                setState(() {
                  if (selection.isCollapsed) {
                    // 折叠选区：通过 toggledStyle 清除颜色
                    widget.editorState.updateToggledStyle(
                      AppFlowyRichTextKeys.textColor,
                      null,
                    );
                  } else {
                    widget.editorState.formatDelta(
                      selection,
                      {AppFlowyRichTextKeys.textColor: null},
                    );
                  }
                });
              }
            },
            isSelected: !hasTextColor,
          ),
          // 颜色选项按钮
          ...colorOptions.map((e) {
            final bool isSelected;
            if (selection.isCollapsed) {
              isSelected = currentTextColor == e.colorHex;
            } else {
              isSelected = nodes.allSatisfyInSelection(selection, (delta) {
                return delta.everyAttributes(
                  (attributes) =>
                      attributes[AppFlowyRichTextKeys.textColor] == e.colorHex,
                );
              });
            }

            return ColorButton(
              colorOption: e,
              onPressed: () {
                setState(() {
                  if (selection.isCollapsed) {
                    // 折叠选区：设置 toggledStyle，下次输入时应用
                    widget.editorState.updateToggledStyle(
                      AppFlowyRichTextKeys.textColor,
                      isSelected ? null : e.colorHex,
                    );
                  } else {
                    // 非折叠选区：使用固定的 selection 而非 editorState.selection
                    // 避免键盘关闭后 editorState.selection 可能变化的问题
                    formatFontColor(
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
