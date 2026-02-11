# AppFlowy Editor（HarmonyOS 适配版）

基于 [AppFlowy Editor](https://github.com/AppFlowy-IO/appflowy-editor) 的 HarmonyOS 适配分支，为日记应用提供富文本编辑能力。

## 概述

本包是 AppFlowy Editor v6.1.0 的 fork 版本，主要针对 HarmonyOS（鸿蒙）平台进行了适配和优化。

## 主要改动

### HarmonyOS 平台适配

- **Flutter 版本兼容**：降级至 Flutter 3.27.0 以支持 OpenHarmony Flutter SDK
- **键盘高度插件**：使用鸿蒙适配版 `keyboard_height_plugin`
- **平台检测**：使用鸿蒙适配版 `universal_platform`，支持 `UniversalPlatform.isOhos`
- **URL 启动器**：使用鸿蒙适配版 `url_launcher`，支持内置浏览器

### 编辑器优化

- **非文本块删除**：删除非文本块时，整个块被删除并替换为空文本行（改善用户体验）
- **手机工具栏**：移除工具栏高度中的安全区域部分（适配全面屏）

## 依赖说明

```yaml
dependencies:
  # HarmonyOS 适配依赖
  keyboard_height_plugin:
    git:
      url: https://gitcode.com/tech-ming/keyboard_height_plugin.git
      ref: br_v0.2.0_ohos
  universal_platform:
    git:
      url: https://gitcode.com/tech-ming/flutter-universal-platform.git
      ref: br_v1.1.0_ohos
  url_launcher:
    git:
      url: https://gitcode.com/openharmony-tpc/flutter_packages.git
      path: packages/url_launcher/url_launcher
      ref: br_url_launcher-v6.3.0_ohos
```

## 使用方法

### 基本用法

```dart
import 'package:appflowy_editor/appflowy_editor.dart';

// 创建空白编辑器
final editorState = EditorState.blank(withInitialText: true);
final editor = AppFlowyEditor(
  editorState: editorState,
);

// 从 JSON 创建编辑器
final json = jsonDecode('YOUR JSON STRING');
final editorState = EditorState(document: Document.fromJson(json));
final editor = AppFlowyEditor(
  editorState: editorState,
);
```

### 国际化配置

在 `MaterialApp` 中添加本地化代理：

```dart
MaterialApp(
  localizationsDelegates: const [
    AppFlowyEditorLocalizations.delegate,
  ],
);
```

### 生成国际化文件

修改 `lib/l10n/*.arb` 翻译文件后，在 `packages/appflowy-editor` 目录下执行：

```bash
dart run intl_utils:generate
```

基准语言为中文（`main_locale: zh`），配置详见 `pubspec.yaml` 中的 `flutter_intl` 部分。

## HarmonyOS 内置浏览器配置

在 HarmonyOS 平台上点击链接时，会使用应用内置浏览器打开。需要在 ohos 项目中配置：

### 1. 注册页面路由

编辑 `ohos/entry/src/main/resources/base/profile/main_pages.json`：

```json
{
  "src": [
    "pages/Index",
    "pages/LaunchInAppPage"
  ]
}
```

### 2. 创建浏览器页面

创建 `ohos/entry/src/main/ets/pages/LaunchInAppPage.ets`：

```typescript
 import { InAppBrowser } from 'url_launcher_ohos/src/main/ets/components/plugin/InAppBrowser';

 @Entry
 @Component
 struct LaunchInAppPage {

   build() {
     Row() {
       InAppBrowser()
     }
   }
 }
```

## 上游仓库

- **原始仓库**：[AppFlowy-IO/appflowy-editor](https://github.com/AppFlowy-IO/appflowy-editor)
- **基于版本**：v6.1.0

## 许可证

本项目遵循原始 AppFlowy Editor 的双重许可：

1. GNU Affero General Public License Version 3
2. Mozilla Public License, Version 2.0 (MPL)

详见 [LICENSE](https://github.com/AppFlowy-IO/appflowy-editor/blob/main/LICENSE)
