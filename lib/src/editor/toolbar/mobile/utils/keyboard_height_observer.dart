import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:keyboard_height_plugin/keyboard_height_plugin.dart';

typedef KeyboardHeightCallback = void Function(double height);

// the KeyboardHeightPlugin only accepts one listener, so we need to create a
//  singleton class to manage the multiple listeners.
class KeyboardHeightObserver {
  KeyboardHeightObserver._() {
    // 注：原实现会通过 device_info_plus 读取 Android SDK 版本写入静态字段，
    // 但全工程无任何读取方，且 device_info_plus 在 Android 上会反射访问
    // Build.SERIAL 等设备标识符，引发应用商店 SN 合规审核驳回。
    // 此处移除该无用采集，并从 pubspec 中删除 device_info_plus 依赖。
    _keyboardHeightPlugin.onKeyboardHeightChanged((height) {
      notify(height);

      currentKeyboardHeight = height;
    });
  }

  static final KeyboardHeightObserver instance = KeyboardHeightObserver._();
  static double currentKeyboardHeight = 0;

  final List<KeyboardHeightCallback> _listeners = [];
  final KeyboardHeightPlugin _keyboardHeightPlugin = KeyboardHeightPlugin();

  void addListener(KeyboardHeightCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(KeyboardHeightCallback listener) {
    _listeners.remove(listener);
  }

  void dispose() {
    _listeners.clear();
    _keyboardHeightPlugin.dispose();
  }

  void notify(double height) {
    // the keyboard height will notify twice with the same value on Android/OHOS
    if ((PlatformExtension.isAndroid || PlatformExtension.isOhos) &&
        height == currentKeyboardHeight) {
      return;
    }

    for (final listener in _listeners) {
      listener(height);
    }
  }
}
