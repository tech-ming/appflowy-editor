import 'package:flutter/foundation.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';

/// HarmonyOS 内置浏览器中转页面路径
const _ohosInAppBrowserPage = 'pages/LaunchInAppPage';

/// 安全启动 URL
///
/// 支持多平台：
/// - HarmonyOS：使用内置浏览器（InAppBrowser）
/// - 其他平台：使用系统默认方式
///
/// 参考：https://developer.huawei.com/consumer/cn/forum/topic/0201192388845896577
Future<bool> safeLaunchUrl(String? href) async {
  if (href == null) {
    debugPrint('[url_launcher] href is null');
    return false;
  }

  // 解析并补全 URL scheme
  final uri = Uri.parse(href);
  final launchUri = uri.scheme.isNotEmpty
      ? uri
      : Uri.parse('http://$href'.trim());

  debugPrint('[url_launcher] Trying to launch: $launchUri');

  try {
    // HarmonyOS 平台：使用内置浏览器
    if (UniversalPlatform.isOhos) {
      debugPrint('[url_launcher] OHOS platform, using InAppBrowser');
      final result = await launchUrl(
        launchUri,
        webViewConfiguration: const WebViewConfiguration(
          headers: <String, String>{
            'harmony_browser_page': _ohosInAppBrowserPage,
          },
        ),
      );
      debugPrint('[url_launcher] launchUrl result: $result');
      return result;
    }

    // 其他平台：使用默认逻辑
    final canLaunchResult = await canLaunchUrl(launchUri);
    debugPrint('[url_launcher] canLaunchUrl: $canLaunchResult');

    if (canLaunchResult) {
      final result = await launchUrl(launchUri);
      debugPrint('[url_launcher] launchUrl result: $result');
      return result;
    } else {
      debugPrint('[url_launcher] Cannot launch URL, trying to force launch...');
      // 尝试强制打开（某些平台 canLaunch 返回 false 但实际可以打开）
      final result = await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );
      debugPrint('[url_launcher] Force launch result: $result');
      return result;
    }
  } catch (e, stack) {
    debugPrint('[url_launcher] Error: $e');
    debugPrint('[url_launcher] Stack: $stack');
    return false;
  }
}

Future<bool> Function(String? href) editorLaunchUrl = safeLaunchUrl;
