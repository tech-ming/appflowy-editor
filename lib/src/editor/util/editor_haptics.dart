import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:flutter/services.dart';

/// 编辑器触感反馈
///
/// Android / OHOS 上 `selectionClick` 映射到系统 CLICK、`mediumImpact` 更重，
/// 无线性马达的设备退化为转子马达的整体震动，明显偏重，统一以 `lightImpact` 打底；
/// iOS 保持系统原生强度。部分 OHOS 设备调用会抛异常，这里统一吞掉。
class EditorHaptics {
  const EditorHaptics._();

  /// 选择位置跨过一档（拖动光标 / 选区手柄）
  static void selection() => _fire(
        PlatformExtension.isIOS
            ? HapticFeedback.selectionClick
            : HapticFeedback.lightImpact,
      );

  /// 操作生效的确认（长按选词）
  static void impact() => _fire(HapticFeedback.lightImpact);

  static Future<void> _fire(Future<void> Function() effect) async {
    try {
      await effect();
    } catch (_) {
      // 平台不支持触感反馈，忽略
    }
  }
}
