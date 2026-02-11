import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Support mobile platform
///   - customize the href text span
TextSpan mobileTextSpanDecoratorForAttribute(
  BuildContext context,
  Node node,
  int index,
  TextInsert text,
  TextSpan before,
  TextSpan after,
) {
  final attributes = text.attributes;
  if (attributes == null) {
    return before;
  }
  final editorState = context.read<EditorState>();

  final hrefAddress = attributes[AppFlowyRichTextKeys.href] as String?;
  if (hrefAddress != null) {
    // 使用 _LinkGestureRecognizer 同时支持单击和长按
    final recognizer = _LinkGestureRecognizer(
      onTap: () {
        editorState.service.keyboardService?.closeKeyboard();
        safeLaunchUrl(hrefAddress);
      },
      onLongPress: () {
        editorState.service.keyboardService?.closeKeyboard();

        // 构建 selection 用于编辑对话框内的格式化操作
        final selection = Selection.single(
          path: node.path,
          startOffset: index,
          endOffset: index + text.text.length,
        );

        if (!context.mounted) return;

        _showLinkEditDialog(
          context: context,
          node: node,
          index: index,
          hrefText: text.text,
          hrefAddress: hrefAddress,
          editorState: editorState,
          selection: selection,
        );
      },
    );

    return TextSpan(
      style: before.style,
      text: text.text,
      recognizer: recognizer,
    );
  }

  return before;
}

/// 显示链接编辑对话框
///
/// 采用底部弹出式 BottomSheet 样式，更符合移动端交互习惯
void _showLinkEditDialog({
  required BuildContext context,
  required Node node,
  required int index,
  required String hrefText,
  required String hrefAddress,
  required EditorState editorState,
  required Selection selection,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return _LinkEditSheet(
        node: node,
        index: index,
        hrefText: hrefText,
        hrefAddress: hrefAddress,
        editorState: editorState,
        selection: selection,
      );
    },
  );
}

/// 链接编辑底部弹窗内容
class _LinkEditSheet extends StatefulWidget {
  const _LinkEditSheet({
    required this.node,
    required this.index,
    required this.hrefText,
    required this.hrefAddress,
    required this.editorState,
    required this.selection,
  });

  final Node node;
  final int index;
  final String hrefText;
  final String hrefAddress;
  final EditorState editorState;
  final Selection selection;

  @override
  State<_LinkEditSheet> createState() => _LinkEditSheetState();
}

class _LinkEditSheetState extends State<_LinkEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _textController;
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.hrefText);
    _urlController = TextEditingController(text: widget.hrefAddress);
  }

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppFlowyEditorL10n.current;

    return Padding(
      // 响应键盘弹出时的底部间距
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 拖拽指示条
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // 标题
                Text(
                  l10n.editLink,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                // 链接文字输入框
                TextFormField(
                  key: const Key('LinkEditSheet_TextFormField'),
                  controller: _textController,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.linkTextHint;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: l10n.linkText,
                    hintText: l10n.linkTextHint,
                    prefixIcon: const Icon(Icons.text_fields_rounded),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: _textController.clear,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 链接地址输入框
                TextFormField(
                  key: const Key('LinkEditSheet_UrlFormField'),
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleDone(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.linkAddressHint;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: l10n.urlHint,
                    hintText: l10n.linkAddressHint,
                    prefixIcon: const Icon(Icons.link_rounded),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: _urlController.clear,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 操作按钮区域
                Row(
                  children: [
                    // 移除链接按钮（靠左）
                    TextButton.icon(
                      icon: Icon(
                        Icons.link_off_rounded,
                        size: 18,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        l10n.removeLink,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      onPressed: _handleRemoveLink,
                    ),

                    const Spacer(),

                    // 取消按钮
                    TextButton(
                      child: Text(l10n.cancel),
                      onPressed: () => Navigator.of(context).pop(),
                    ),

                    const SizedBox(width: 8),

                    // 完成按钮（填充样式，突出主操作）
                    FilledButton(
                      onPressed: _handleDone,
                      child: Text(l10n.done),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 处理移除链接
  Future<void> _handleRemoveLink() async {
    final transaction = widget.editorState.transaction
      ..formatText(
        widget.node,
        widget.index,
        widget.hrefText.length,
        {BuiltInAttributeKey.href: null},
      );
    await widget.editorState.apply(transaction).whenComplete(() {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  /// 处理完成编辑
  Future<void> _handleDone() async {
    if (!_formKey.currentState!.validate()) return;

    final bool textChanged = _textController.text != widget.hrefText;
    final bool addressChanged = _urlController.text != widget.hrefAddress;

    if (textChanged && addressChanged) {
      // 文字和地址都变了
      final transaction = widget.editorState.transaction
        ..replaceText(
          widget.node,
          widget.index,
          widget.hrefText.length,
          _textController.text,
          attributes: {
            AppFlowyRichTextKeys.href: _urlController.text,
          },
        );
      await widget.editorState.apply(transaction).whenComplete(() {
        if (mounted) Navigator.of(context).pop();
      });
    } else if (textChanged) {
      // 只有文字变了
      final transaction = widget.editorState.transaction
        ..replaceText(
          widget.node,
          widget.index,
          widget.hrefText.length,
          _textController.text,
        );
      await widget.editorState.apply(transaction).whenComplete(() {
        if (mounted) Navigator.of(context).pop();
      });
    } else if (addressChanged) {
      // 只有地址变了
      await widget.editorState.formatDelta(widget.selection, {
        AppFlowyRichTextKeys.href: _urlController.text,
      }).whenComplete(() {
        if (mounted) Navigator.of(context).pop();
      });
    } else {
      // 无变更，直接关闭
      Navigator.of(context).pop();
    }
  }
}

/// 链接手势识别器
///
/// 基于 [OneSequenceGestureRecognizer] 实现，同时支持单击和长按手势。
/// 使用 Timer 检测长按，避免与 Flutter 手势竞技场产生冲突。
///
/// 工作原理：
/// - 手指按下时启动 500ms 计时器
/// - 如果在 500ms 内手指抬起，触发 [onTap]
/// - 如果超过 500ms，触发 [onLongPress]
class _LinkGestureRecognizer extends OneSequenceGestureRecognizer {
  _LinkGestureRecognizer({
    this.onTap,
    this.onLongPress,
  });

  /// 单击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 长按阈值
  static const _longPressDuration = Duration(milliseconds: 500);

  /// 长按计时器
  Timer? _longPressTimer;

  /// 是否已触发长按
  bool _longPressTriggered = false;

  /// 当前追踪的指针 ID
  int? _primaryPointer;

  /// 初始位置（用于检测手指移动）
  Offset? _initialPosition;

  /// 允许的移动距离阈值
  static const _kTouchSlop = 18.0;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    // 只处理第一个触摸点
    if (_primaryPointer != null) {
      return;
    }

    _primaryPointer = event.pointer;
    _initialPosition = event.position;
    _longPressTriggered = false;

    // 启动长按计时器
    _longPressTimer?.cancel();
    _longPressTimer = Timer(_longPressDuration, _handleLongPressTimeout);

    // 开始追踪此指针
    startTrackingPointer(event.pointer, event.transform);

    // 立即声明赢得手势竞争，阻止其他手势识别器（如系统的长按）
    resolve(GestureDisposition.accepted);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event.pointer != _primaryPointer) return;

    if (event is PointerMoveEvent) {
      // 检测手指是否移动过远
      final distance = (event.position - _initialPosition!).distance;
      if (distance > _kTouchSlop) {
        // 手指移动过远，取消手势
        _cancelTimer();
        stopTrackingPointer(event.pointer);
        _reset();
      }
    } else if (event is PointerUpEvent) {
      // 手指抬起
      _cancelTimer();
      stopTrackingPointer(event.pointer);

      if (!_longPressTriggered) {
        // 长按未触发，执行单击
        onTap?.call();
      }
      _reset();
    } else if (event is PointerCancelEvent) {
      // 指针被取消
      _cancelTimer();
      stopTrackingPointer(event.pointer);
      _reset();
    }
  }

  /// 长按超时处理
  void _handleLongPressTimeout() {
    _longPressTriggered = true;
    onLongPress?.call();
  }

  /// 取消计时器
  void _cancelTimer() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  /// 重置状态
  void _reset() {
    _primaryPointer = null;
    _initialPosition = null;
    _longPressTriggered = false;
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    // 空实现，手势已在 addAllowedPointer 中解决
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  @override
  String get debugDescription => '_LinkGestureRecognizer';
}
