import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/mobile/utils/keyboard_height_observer.dart';
import 'package:flutter/material.dart';

const String selectionExtraInfoDisableMobileToolbarKey = 'disableMobileToolbar';

class MobileToolbarV2 extends StatefulWidget {
  const MobileToolbarV2({
    super.key,
    this.backgroundColor = Colors.white,
    this.foregroundColor = const Color(0xff676666),
    this.iconColor = Colors.black,
    this.clearDiagonalLineColor = const Color(0xffB3261E),
    this.itemHighlightColor = const Color(0xff1F71AC),
    this.itemOutlineColor = const Color(0xFFE3E3E3),
    this.tabBarSelectedBackgroundColor = const Color(0x23808080),
    this.tabBarSelectedForegroundColor = Colors.black,
    this.primaryColor = const Color(0xff1F71AC),
    this.onPrimaryColor = Colors.white,
    this.outlineColor = const Color(0xFFE3E3E3),
    this.toolbarHeight = 50.0,
    this.borderRadius = 6.0,
    this.buttonHeight = 40.0,
    this.buttonSpacing = 8.0,
    this.buttonBorderWidth = 1.0,
    this.buttonSelectedBorderWidth = 2.0,
    required this.editorState,
    required this.toolbarItems,
    required this.child,
  });

  final EditorState editorState;
  final List<MobileToolbarItem> toolbarItems;
  final Widget child;

  // style
  final Color backgroundColor;
  final Color foregroundColor;
  final Color iconColor;
  final Color clearDiagonalLineColor;
  final Color itemHighlightColor;
  final Color itemOutlineColor;
  final Color tabBarSelectedBackgroundColor;
  final Color tabBarSelectedForegroundColor;
  final Color primaryColor;
  final Color onPrimaryColor;
  final Color outlineColor;
  final double toolbarHeight;
  final double borderRadius;
  final double buttonHeight;
  final double buttonSpacing;
  final double buttonBorderWidth;
  final double buttonSelectedBorderWidth;

  @override
  State<MobileToolbarV2> createState() => _MobileToolbarV2State();
}

class _MobileToolbarV2State extends State<MobileToolbarV2> {
  OverlayEntry? toolbarOverlay;

  final isKeyboardShow = ValueNotifier(false);

  /// 菜单显示时需要模拟的键盘高度
  /// 当菜单打开时，设为 cachedKeyboardHeight，
  /// 关闭菜单恢复键盘后，由 _onKeyboardHeightChanged 清除
  final simulatedKeyboardHeight = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();

    _insertKeyboardToolbar();
    KeyboardHeightObserver.instance.addListener(_onKeyboardHeightChanged);
  }

  @override
  void dispose() {
    isKeyboardShow.dispose();
    simulatedKeyboardHeight.dispose();
    toolbarOverlay?.remove();
    toolbarOverlay?.dispose();
    toolbarOverlay = null;
    KeyboardHeightObserver.instance.removeListener(_onKeyboardHeightChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 注意：必须保持 widget tree 结构稳定（始终返回相同的 Column）。
    // 如果根据 simHeight 切换返回 widget.child / Column 两种结构，
    // Flutter 的 Element diff 会因 runtimeType 不一致而销毁 child 子树并重建，
    // 导致 AppFlowyEditor 内部的 EditorScrollController/SelectionService 全部重置：
    // 表现为「点击菜单时，菜单被关闭、光标退回到文章开头」。
    return Column(
      children: [
        Expanded(child: widget.child),
        ValueListenableBuilder<double>(
          valueListenable: simulatedKeyboardHeight,
          builder: (context, simHeight, _) {
            // simHeight <= 0：键盘正常弹出 / 全部收起
            // - Scaffold 的 resizeToAvoidBottomInset 已处理键盘空间
            // - 工具栏在 Overlay 中，不占 widget tree 空间
            // 此时 spacer 高度为 0，等同于无占位
            if (simHeight <= 0) {
              return const SizedBox.shrink();
            }

            // simHeight > 0：菜单显示时的占位补偿公式：
            // spacer = toolbarHeight + (simHeight - viewInsets.bottom)
            // 键盘关闭动画中 viewInsets.bottom 逐渐减小 → Scaffold body 逐渐变大
            // → spacer 同步增大补偿 → 编辑器可见区域恒定，零闪烁
            final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
            final spacerHeight = widget.toolbarHeight +
                (simHeight - viewInsetsBottom).clamp(0.0, simHeight);
            return SizedBox(height: spacerHeight);
          },
        ),
      ],
    );
  }

  void _onKeyboardHeightChanged(double height) {
    isKeyboardShow.value = height > 0;

    // 键盘恢复后，清除模拟高度（键盘已经接管了空间占位）
    if (height > 0 && simulatedKeyboardHeight.value > 0) {
      simulatedKeyboardHeight.value = 0;
    }
  }

  void _removeKeyboardToolbar() {
    toolbarOverlay?.remove();
    toolbarOverlay?.dispose();
    toolbarOverlay = null;
  }

  void _insertKeyboardToolbar() {
    _removeKeyboardToolbar();

    Widget child = ValueListenableBuilder<Selection?>(
      valueListenable: widget.editorState.selectionNotifier,
      builder: (_, Selection? selection, __) {
        // if the selection is null, hide the toolbar
        if (selection == null ||
            widget.editorState.selectionExtraInfo?[
                    selectionExtraInfoDisableMobileToolbarKey] ==
                true) {
          return const SizedBox.shrink();
        }

        return RepaintBoundary(
          child: MobileToolbarTheme(
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            iconColor: widget.iconColor,
            clearDiagonalLineColor: widget.clearDiagonalLineColor,
            itemHighlightColor: widget.itemHighlightColor,
            itemOutlineColor: widget.itemOutlineColor,
            tabBarSelectedBackgroundColor: widget.tabBarSelectedBackgroundColor,
            tabBarSelectedForegroundColor: widget.tabBarSelectedForegroundColor,
            primaryColor: widget.primaryColor,
            onPrimaryColor: widget.onPrimaryColor,
            outlineColor: widget.outlineColor,
            toolbarHeight: widget.toolbarHeight,
            borderRadius: widget.borderRadius,
            buttonHeight: widget.buttonHeight,
            buttonSpacing: widget.buttonSpacing,
            buttonBorderWidth: widget.buttonBorderWidth,
            buttonSelectedBorderWidth: widget.buttonSelectedBorderWidth,
            child: _MobileToolbar(
              editorState: widget.editorState,
              toolbarItems: widget.toolbarItems,
              simulatedKeyboardHeight: simulatedKeyboardHeight,
            ),
          ),
        );
      },
    );

    child = Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Material(
            child: child,
          ),
        ),
      ],
    );

    toolbarOverlay = OverlayEntry(
      builder: (context) {
        return child;
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Overlay.of(context, rootOverlay: true).insert(toolbarOverlay!);
    });
  }
}

class _MobileToolbar extends StatefulWidget {
  const _MobileToolbar({
    required this.editorState,
    required this.toolbarItems,
    required this.simulatedKeyboardHeight,
  });

  final EditorState editorState;
  final List<MobileToolbarItem> toolbarItems;

  /// 父组件的模拟键盘高度通知器，
  /// 菜单打开时设为缓存的键盘高度，让父组件计算占位符补偿
  final ValueNotifier<double> simulatedKeyboardHeight;

  @override
  State<_MobileToolbar> createState() => _MobileToolbarState();
}

class _MobileToolbarState extends State<_MobileToolbar>
    implements MobileToolbarWidgetService {
  // used to control the toolbar menu items
  PropertyValueNotifier<bool> showMenuNotifier = PropertyValueNotifier(false);

  // when the users click the menu item, the keyboard will be hidden,
  //  but in this case, we don't want to update the cached keyboard height.
  // This is because we want to keep the same height when the menu is shown.
  bool canUpdateCachedKeyboardHeight = true;
  ValueNotifier<double> cachedKeyboardHeight = ValueNotifier(0.0);

  // used to check if click the same item again
  int? selectedMenuIndex;

  Selection? currentSelection;

  bool closeKeyboardInitiative = false;

  @override
  void initState() {
    super.initState();

    currentSelection = widget.editorState.selection;
    KeyboardHeightObserver.instance.addListener(_onKeyboardHeightChanged);
  }

  @override
  void didUpdateWidget(covariant _MobileToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (currentSelection != widget.editorState.selection) {
      currentSelection = widget.editorState.selection;
      // 仅在菜单未显示时才关闭菜单和清除模拟高度
      // 如果菜单正在显示，selection 变化（如长按选中新文本）不应改变布局，
      // 否则 spacer 突然清零会导致编辑器区域突变、内容滚动跳动
      if (!showMenuNotifier.value) {
        closeItemMenu();
        widget.simulatedKeyboardHeight.value = 0;
      }
    }
  }

  @override
  void dispose() {
    showMenuNotifier.dispose();
    cachedKeyboardHeight.dispose();
    KeyboardHeightObserver.instance.removeListener(_onKeyboardHeightChanged);

    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();

    canUpdateCachedKeyboardHeight = true;
    closeItemMenu();
    _closeKeyboard();
  }

  @override
  Widget build(BuildContext context) {
    // toolbar
    //  - if the menu is shown, the toolbar will be pushed up by the height of the menu
    //  - otherwise, add a spacer to push the toolbar up when the keyboard is shown
    return Column(
      children: [
        _buildToolbar(context),
        _buildMenuOrSpacer(context),
      ],
    );
  }

  @override
  void closeItemMenu() {
    showMenuNotifier.value = false;
    // 注意：不在此处清除 simulatedKeyboardHeight
    // 当键盘恢复显示后，父组件的 _onKeyboardHeightChanged 会自动清除
    // 这样在键盘关闭→菜单打开→菜单关闭→键盘恢复 的过渡期间，
    // 占位符高度公式能持续补偿，避免闪烁
  }

  void showItemMenu() {
    showMenuNotifier.value = true;
    // 延迟一帧再设置模拟高度：
    // 确保 _closeKeyboard() 先执行、键盘关闭动画已启动后，
    // 再通知父组件开始补偿占位，避免「键盘还在 + spacer 也在」导致的双重压缩闪烁
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (showMenuNotifier.value) {
        widget.simulatedKeyboardHeight.value = cachedKeyboardHeight.value;
      }
    });
  }

  void _onKeyboardHeightChanged(double height) {
    // if the keyboard is not closed initiative, we need to close the menu at same time
    if (!closeKeyboardInitiative &&
        cachedKeyboardHeight.value != 0 &&
        !showMenuNotifier.value &&
        height == 0) {
      widget.editorState.selection = null;
    }

    // 键盘重新弹出时（如用户点击了编辑器其他位置），关闭菜单
    if (height > 0 && showMenuNotifier.value) {
      closeItemMenu();
      canUpdateCachedKeyboardHeight = true;
    }

    if (canUpdateCachedKeyboardHeight) {
      cachedKeyboardHeight.value = height;
      // 移除强制添加 viewPadding.bottom 的逻辑
      // 键盘高度应该由系统直接提供，不需要额外添加安全区域
      // 如果调用方需要安全区域，应该在外层使用 SafeArea
    }

    if (height == 0) {
      closeKeyboardInitiative = false;
    }
  }

  // toolbar list view and close keyboard/menu button
  Widget _buildToolbar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final style = MobileToolbarTheme.of(context);

    return Container(
      width: width,
      height: style.toolbarHeight,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: style.itemOutlineColor,
          ),
          bottom: BorderSide(color: style.itemOutlineColor),
        ),
        color: style.backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // toolbar list view
          Expanded(
            child: _ToolbarItemListView(
              toolbarItems: widget.toolbarItems,
              editorState: widget.editorState,
              toolbarWidgetService: this,
              itemWithActionOnPressed: (_) {
                if (showMenuNotifier.value) {
                  closeItemMenu();
                  _showKeyboard();
                  // update the cached keyboard height after the keyboard is shown
                  Debounce.debounce('canUpdateCachedKeyboardHeight',
                      const Duration(milliseconds: 500), () {
                    canUpdateCachedKeyboardHeight = true;
                  });
                }
              },
              itemWithMenuOnPressed: (index) {
                // click the same one
                if (selectedMenuIndex == index && showMenuNotifier.value) {
                  // if the menu is shown, close it and show the keyboard
                  closeItemMenu();
                  _showKeyboard();
                  // update the cached keyboard height after the keyboard is shown
                  Debounce.debounce('canUpdateCachedKeyboardHeight',
                      const Duration(milliseconds: 500), () {
                    canUpdateCachedKeyboardHeight = true;
                  });
                } else {
                  canUpdateCachedKeyboardHeight = false;
                  selectedMenuIndex = index;
                  closeKeyboardInitiative = true;
                  // 先关闭键盘，再显示菜单
                  // 这样 showItemMenu 中延迟一帧设置 simulatedKeyboardHeight 时，
                  // 键盘关闭动画已经启动，公式补偿才正确
                  _closeKeyboard();
                  showItemMenu();
                }
              },
            ),
          ),
          // divider
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: VerticalDivider(
              width: 1,
            ),
          ),
          // close menu or close keyboard button
          ValueListenableBuilder(
            valueListenable: showMenuNotifier,
            builder: (_, showingMenu, __) {
              return _CloseKeyboardOrMenuButton(
                showingMenu: showingMenu,
                onPressed: () {
                  if (showingMenu) {
                    // close the menu and show the keyboard
                    closeItemMenu();
                    _showKeyboard();
                  } else {
                    closeKeyboardInitiative = true;
                    // close the keyboard and clear the selection
                    // if the selection is null, the keyboard and the toolbar will be hidden automatically
                    widget.editorState.selection = null;
                  }
                },
              );
            },
          ),
          const SizedBox(
            width: 4.0,
          ),
        ],
      ),
    );
  }

  // if there's no menu, we need to add a spacer to push the toolbar up when the keyboard is shown
  Widget _buildMenuOrSpacer(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: cachedKeyboardHeight,
      builder: (_, height, ___) {
        return ValueListenableBuilder(
          valueListenable: showMenuNotifier,
          builder: (_, showingMenu, __) {
            var keyboardHeight = height;
            // 当不显示菜单时，确保使用实时的键盘高度
            // viewInsets.bottom 只包含键盘高度，不包含安全区域
            if (!showingMenu) {
              keyboardHeight = max(
                keyboardHeight,
                MediaQuery.of(context).viewInsets.bottom,
              );
            }

            return SizedBox(
              height: keyboardHeight,
              child: (showingMenu && selectedMenuIndex != null)
                  ? MobileToolbarItemMenu(
                      editorState: widget.editorState,
                      itemMenuBuilder: () {
                        final menu = widget
                            .toolbarItems[selectedMenuIndex!].itemMenuBuilder!
                            .call(
                          context,
                          widget.editorState,
                          this,
                        );

                        return menu ?? const SizedBox.shrink();
                      },
                    )
                  : const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }

  void _showKeyboard() {
    final selection = widget.editorState.selection;
    if (selection != null) {
      widget.editorState.service.keyboardService?.enableKeyBoard(selection);
    }
  }

  void _closeKeyboard() {
    widget.editorState.service.keyboardService?.closeKeyboard();
  }
}

class _ToolbarItemListView extends StatelessWidget {
  const _ToolbarItemListView({
    required this.toolbarItems,
    required this.editorState,
    required this.toolbarWidgetService,
    required this.itemWithMenuOnPressed,
    required this.itemWithActionOnPressed,
  });

  final Function(int index) itemWithMenuOnPressed;
  final Function(int index) itemWithActionOnPressed;
  final List<MobileToolbarItem> toolbarItems;
  final EditorState editorState;
  final MobileToolbarWidgetService toolbarWidgetService;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final toolbarItem = toolbarItems[index];
        final icon = toolbarItem.itemIconBuilder?.call(
          context,
          editorState,
          toolbarWidgetService,
        );
        if (icon == null) {
          return const SizedBox.shrink();
        }

        return IconButton(
          icon: icon,
          onPressed: () {
            if (toolbarItem.hasMenu) {
              // open /close current item menu through its parent widget(MobileToolbarWidget)
              itemWithMenuOnPressed(index);
            } else {
              itemWithActionOnPressed(index);
              // close menu if other item's menu is still on the screen
              toolbarWidgetService.closeItemMenu();
              toolbarItems[index].actionHandler?.call(
                    context,
                    editorState,
                  );
            }
          },
        );
      },
      itemCount: toolbarItems.length,
      scrollDirection: Axis.horizontal,
    );
  }
}

class _CloseKeyboardOrMenuButton extends StatelessWidget {
  const _CloseKeyboardOrMenuButton({
    required this.showingMenu,
    required this.onPressed,
  });

  final bool showingMenu;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: showingMenu
          ? AFMobileIcon(
              afMobileIcons: AFMobileIcons.close,
              color: MobileToolbarTheme.of(context).iconColor,
            )
          : Icon(
              Icons.keyboard_hide,
              color: MobileToolbarTheme.of(context).iconColor,
            ),
    );
  }
}
