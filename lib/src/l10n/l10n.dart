// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppFlowyEditorLocalizations {
  AppFlowyEditorLocalizations();

  static AppFlowyEditorLocalizations? _current;

  static AppFlowyEditorLocalizations get current {
    assert(
      _current != null,
      'No instance of AppFlowyEditorLocalizations was loaded. Try to initialize the AppFlowyEditorLocalizations delegate before accessing AppFlowyEditorLocalizations.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppFlowyEditorLocalizations> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppFlowyEditorLocalizations();
      AppFlowyEditorLocalizations._current = instance;

      return instance;
    });
  }

  static AppFlowyEditorLocalizations of(BuildContext context) {
    final instance = AppFlowyEditorLocalizations.maybeOf(context);
    assert(
      instance != null,
      'No instance of AppFlowyEditorLocalizations present in the widget tree. Did you add AppFlowyEditorLocalizations.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static AppFlowyEditorLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppFlowyEditorLocalizations>(
      context,
      AppFlowyEditorLocalizations,
    );
  }

  /// `粗体`
  String get bold {
    return Intl.message('粗体', name: 'bold', desc: '', args: []);
  }

  /// `无序列表`
  String get bulletedList {
    return Intl.message('无序列表', name: 'bulletedList', desc: '', args: []);
  }

  /// `复选框`
  String get checkbox {
    return Intl.message('复选框', name: 'checkbox', desc: '', args: []);
  }

  /// `代码块`
  String get embedCode {
    return Intl.message('代码块', name: 'embedCode', desc: '', args: []);
  }

  /// `一级标题`
  String get heading1 {
    return Intl.message('一级标题', name: 'heading1', desc: '', args: []);
  }

  /// `二级标题`
  String get heading2 {
    return Intl.message('二级标题', name: 'heading2', desc: '', args: []);
  }

  /// `三级标题`
  String get heading3 {
    return Intl.message('三级标题', name: 'heading3', desc: '', args: []);
  }

  /// `高亮`
  String get highlight {
    return Intl.message('高亮', name: 'highlight', desc: '', args: []);
  }

  /// `颜色`
  String get color {
    return Intl.message('颜色', name: 'color', desc: '', args: []);
  }

  /// `图片`
  String get image {
    return Intl.message('图片', name: 'image', desc: '', args: []);
  }

  /// `斜体`
  String get italic {
    return Intl.message('斜体', name: 'italic', desc: '', args: []);
  }

  /// `链接`
  String get link {
    return Intl.message('链接', name: 'link', desc: '', args: []);
  }

  /// `有序列表`
  String get numberedList {
    return Intl.message('有序列表', name: 'numberedList', desc: '', args: []);
  }

  /// `引文`
  String get quote {
    return Intl.message('引文', name: 'quote', desc: '', args: []);
  }

  /// `删除线`
  String get strikethrough {
    return Intl.message('删除线', name: 'strikethrough', desc: '', args: []);
  }

  /// `文本`
  String get text {
    return Intl.message('文本', name: 'text', desc: '', args: []);
  }

  /// `下划线`
  String get underline {
    return Intl.message('下划线', name: 'underline', desc: '', args: []);
  }

  /// `默认`
  String get fontColorDefault {
    return Intl.message('默认', name: 'fontColorDefault', desc: '', args: []);
  }

  /// `灰色`
  String get fontColorGray {
    return Intl.message('灰色', name: 'fontColorGray', desc: '', args: []);
  }

  /// `棕色`
  String get fontColorBrown {
    return Intl.message('棕色', name: 'fontColorBrown', desc: '', args: []);
  }

  /// `橙色`
  String get fontColorOrange {
    return Intl.message('橙色', name: 'fontColorOrange', desc: '', args: []);
  }

  /// `黄色`
  String get fontColorYellow {
    return Intl.message('黄色', name: 'fontColorYellow', desc: '', args: []);
  }

  /// `绿色`
  String get fontColorGreen {
    return Intl.message('绿色', name: 'fontColorGreen', desc: '', args: []);
  }

  /// `蓝色`
  String get fontColorBlue {
    return Intl.message('蓝色', name: 'fontColorBlue', desc: '', args: []);
  }

  /// `紫色`
  String get fontColorPurple {
    return Intl.message('紫色', name: 'fontColorPurple', desc: '', args: []);
  }

  /// `粉红色`
  String get fontColorPink {
    return Intl.message('粉红色', name: 'fontColorPink', desc: '', args: []);
  }

  /// `红色`
  String get fontColorRed {
    return Intl.message('红色', name: 'fontColorRed', desc: '', args: []);
  }

  /// `默认背景色`
  String get backgroundColorDefault {
    return Intl.message(
      '默认背景色',
      name: 'backgroundColorDefault',
      desc: '',
      args: [],
    );
  }

  /// `灰色背景`
  String get backgroundColorGray {
    return Intl.message(
      '灰色背景',
      name: 'backgroundColorGray',
      desc: '',
      args: [],
    );
  }

  /// `棕色背景`
  String get backgroundColorBrown {
    return Intl.message(
      '棕色背景',
      name: 'backgroundColorBrown',
      desc: '',
      args: [],
    );
  }

  /// `橙色背景`
  String get backgroundColorOrange {
    return Intl.message(
      '橙色背景',
      name: 'backgroundColorOrange',
      desc: '',
      args: [],
    );
  }

  /// `黄色背景`
  String get backgroundColorYellow {
    return Intl.message(
      '黄色背景',
      name: 'backgroundColorYellow',
      desc: '',
      args: [],
    );
  }

  /// `绿色背景`
  String get backgroundColorGreen {
    return Intl.message(
      '绿色背景',
      name: 'backgroundColorGreen',
      desc: '',
      args: [],
    );
  }

  /// `蓝色背景`
  String get backgroundColorBlue {
    return Intl.message(
      '蓝色背景',
      name: 'backgroundColorBlue',
      desc: '',
      args: [],
    );
  }

  /// `紫色背景`
  String get backgroundColorPurple {
    return Intl.message(
      '紫色背景',
      name: 'backgroundColorPurple',
      desc: '',
      args: [],
    );
  }

  /// `粉色背景`
  String get backgroundColorPink {
    return Intl.message(
      '粉色背景',
      name: 'backgroundColorPink',
      desc: '',
      args: [],
    );
  }

  /// `红色背景`
  String get backgroundColorRed {
    return Intl.message('红色背景', name: 'backgroundColorRed', desc: '', args: []);
  }

  /// `完成`
  String get done {
    return Intl.message('完成', name: 'done', desc: '', args: []);
  }

  /// `取消`
  String get cancel {
    return Intl.message('取消', name: 'cancel', desc: '', args: []);
  }

  /// `色调1`
  String get tint1 {
    return Intl.message('色调1', name: 'tint1', desc: '', args: []);
  }

  /// `色调2`
  String get tint2 {
    return Intl.message('色调2', name: 'tint2', desc: '', args: []);
  }

  /// `色调3`
  String get tint3 {
    return Intl.message('色调3', name: 'tint3', desc: '', args: []);
  }

  /// `色调4`
  String get tint4 {
    return Intl.message('色调4', name: 'tint4', desc: '', args: []);
  }

  /// `色调5`
  String get tint5 {
    return Intl.message('色调5', name: 'tint5', desc: '', args: []);
  }

  /// `色调6`
  String get tint6 {
    return Intl.message('色调6', name: 'tint6', desc: '', args: []);
  }

  /// `色调7`
  String get tint7 {
    return Intl.message('色调7', name: 'tint7', desc: '', args: []);
  }

  /// `色调8`
  String get tint8 {
    return Intl.message('色调8', name: 'tint8', desc: '', args: []);
  }

  /// `色调9`
  String get tint9 {
    return Intl.message('色调9', name: 'tint9', desc: '', args: []);
  }

  /// `紫色`
  String get lightLightTint1 {
    return Intl.message('紫色', name: 'lightLightTint1', desc: '', args: []);
  }

  /// `粉红色`
  String get lightLightTint2 {
    return Intl.message('粉红色', name: 'lightLightTint2', desc: '', args: []);
  }

  /// `浅粉红色`
  String get lightLightTint3 {
    return Intl.message('浅粉红色', name: 'lightLightTint3', desc: '', args: []);
  }

  /// `橙色`
  String get lightLightTint4 {
    return Intl.message('橙色', name: 'lightLightTint4', desc: '', args: []);
  }

  /// `黄色`
  String get lightLightTint5 {
    return Intl.message('黄色', name: 'lightLightTint5', desc: '', args: []);
  }

  /// `草绿色`
  String get lightLightTint6 {
    return Intl.message('草绿色', name: 'lightLightTint6', desc: '', args: []);
  }

  /// `绿色`
  String get lightLightTint7 {
    return Intl.message('绿色', name: 'lightLightTint7', desc: '', args: []);
  }

  /// `水蓝色`
  String get lightLightTint8 {
    return Intl.message('水蓝色', name: 'lightLightTint8', desc: '', args: []);
  }

  /// `蓝色`
  String get lightLightTint9 {
    return Intl.message('蓝色', name: 'lightLightTint9', desc: '', args: []);
  }

  /// `URL`
  String get urlHint {
    return Intl.message('URL', name: 'urlHint', desc: '', args: []);
  }

  /// `一级标题`
  String get mobileHeading1 {
    return Intl.message('一级标题', name: 'mobileHeading1', desc: '', args: []);
  }

  /// `二级标题`
  String get mobileHeading2 {
    return Intl.message('二级标题', name: 'mobileHeading2', desc: '', args: []);
  }

  /// `三级标题`
  String get mobileHeading3 {
    return Intl.message('三级标题', name: 'mobileHeading3', desc: '', args: []);
  }

  /// `文字颜色`
  String get textColor {
    return Intl.message('文字颜色', name: 'textColor', desc: '', args: []);
  }

  /// `背景颜色`
  String get backgroundColor {
    return Intl.message('背景颜色', name: 'backgroundColor', desc: '', args: []);
  }

  /// `添加链接`
  String get addYourLink {
    return Intl.message('添加链接', name: 'addYourLink', desc: '', args: []);
  }

  /// `打开链接`
  String get openLink {
    return Intl.message('打开链接', name: 'openLink', desc: '', args: []);
  }

  /// `复制链接`
  String get copyLink {
    return Intl.message('复制链接', name: 'copyLink', desc: '', args: []);
  }

  /// `移除链接`
  String get removeLink {
    return Intl.message('移除链接', name: 'removeLink', desc: '', args: []);
  }

  /// `修改链接`
  String get editLink {
    return Intl.message('修改链接', name: 'editLink', desc: '', args: []);
  }

  /// `文字`
  String get linkText {
    return Intl.message('文字', name: 'linkText', desc: '', args: []);
  }

  /// `请输入文字`
  String get linkTextHint {
    return Intl.message('请输入文字', name: 'linkTextHint', desc: '', args: []);
  }

  /// `请输入URL`
  String get linkAddressHint {
    return Intl.message('请输入URL', name: 'linkAddressHint', desc: '', args: []);
  }

  /// `高亮颜色`
  String get highlightColor {
    return Intl.message('高亮颜色', name: 'highlightColor', desc: '', args: []);
  }

  /// `清除高亮颜色`
  String get clearHighlightColor {
    return Intl.message(
      '清除高亮颜色',
      name: 'clearHighlightColor',
      desc: '',
      args: [],
    );
  }

  /// `自定义颜色`
  String get customColor {
    return Intl.message('自定义颜色', name: 'customColor', desc: '', args: []);
  }

  /// `十六进制值`
  String get hexValue {
    return Intl.message('十六进制值', name: 'hexValue', desc: '', args: []);
  }

  /// `透明度`
  String get opacity {
    return Intl.message('透明度', name: 'opacity', desc: '', args: []);
  }

  /// `重设为默认颜色`
  String get resetToDefaultColor {
    return Intl.message(
      '重设为默认颜色',
      name: 'resetToDefaultColor',
      desc: '',
      args: [],
    );
  }

  /// `自左至右`
  String get ltr {
    return Intl.message('自左至右', name: 'ltr', desc: '', args: []);
  }

  /// `自右至左`
  String get rtl {
    return Intl.message('自右至左', name: 'rtl', desc: '', args: []);
  }

  /// `自动`
  String get auto {
    return Intl.message('自动', name: 'auto', desc: '', args: []);
  }

  /// `剪切`
  String get cut {
    return Intl.message('剪切', name: 'cut', desc: '', args: []);
  }

  /// `复制`
  String get copy {
    return Intl.message('复制', name: 'copy', desc: '', args: []);
  }

  /// `粘贴`
  String get paste {
    return Intl.message('粘贴', name: 'paste', desc: '', args: []);
  }

  /// `查找`
  String get find {
    return Intl.message('查找', name: 'find', desc: '', args: []);
  }

  /// `上一匹配项`
  String get previousMatch {
    return Intl.message('上一匹配项', name: 'previousMatch', desc: '', args: []);
  }

  /// `下一匹配项`
  String get nextMatch {
    return Intl.message('下一匹配项', name: 'nextMatch', desc: '', args: []);
  }

  /// `关闭`
  String get closeFind {
    return Intl.message('关闭', name: 'closeFind', desc: '', args: []);
  }

  /// `替换`
  String get replace {
    return Intl.message('替换', name: 'replace', desc: '', args: []);
  }

  /// `替换全部`
  String get replaceAll {
    return Intl.message('替换全部', name: 'replaceAll', desc: '', args: []);
  }

  /// `正则表达式`
  String get regex {
    return Intl.message('正则表达式', name: 'regex', desc: '', args: []);
  }

  /// `区分大小写`
  String get caseSensitive {
    return Intl.message('区分大小写', name: 'caseSensitive', desc: '', args: []);
  }

  /// `正则错误`
  String get regexError {
    return Intl.message('正则错误', name: 'regexError', desc: '', args: []);
  }

  /// `无匹配项`
  String get noFindResult {
    return Intl.message('无匹配项', name: 'noFindResult', desc: '', args: []);
  }

  /// `输入查找内容`
  String get emptySearchBoxHint {
    return Intl.message(
      '输入查找内容',
      name: 'emptySearchBoxHint',
      desc: '',
      args: [],
    );
  }

  /// `上传图片`
  String get uploadImage {
    return Intl.message('上传图片', name: 'uploadImage', desc: '', args: []);
  }

  /// `网络图片`
  String get urlImage {
    return Intl.message('网络图片', name: 'urlImage', desc: '', args: []);
  }

  /// `链接错误`
  String get incorrectLink {
    return Intl.message('链接错误', name: 'incorrectLink', desc: '', args: []);
  }

  /// `上传`
  String get upload {
    return Intl.message('上传', name: 'upload', desc: '', args: []);
  }

  /// `选择图片文件`
  String get chooseImage {
    return Intl.message('选择图片文件', name: 'chooseImage', desc: '', args: []);
  }

  /// `正在加载`
  String get loading {
    return Intl.message('正在加载', name: 'loading', desc: '', args: []);
  }

  /// `无法加载图片`
  String get imageLoadFailed {
    return Intl.message('无法加载图片', name: 'imageLoadFailed', desc: '', args: []);
  }

  /// `分割线`
  String get divider {
    return Intl.message('分割线', name: 'divider', desc: '', args: []);
  }

  /// `表格`
  String get table {
    return Intl.message('表格', name: 'table', desc: '', args: []);
  }

  /// `左侧插入列`
  String get colAddBefore {
    return Intl.message('左侧插入列', name: 'colAddBefore', desc: '', args: []);
  }

  /// `上方插入行`
  String get rowAddBefore {
    return Intl.message('上方插入行', name: 'rowAddBefore', desc: '', args: []);
  }

  /// `右侧插入列`
  String get colAddAfter {
    return Intl.message('右侧插入列', name: 'colAddAfter', desc: '', args: []);
  }

  /// `下方插入行`
  String get rowAddAfter {
    return Intl.message('下方插入行', name: 'rowAddAfter', desc: '', args: []);
  }

  /// `删除整列`
  String get colRemove {
    return Intl.message('删除整列', name: 'colRemove', desc: '', args: []);
  }

  /// `删除整行`
  String get rowRemove {
    return Intl.message('删除整行', name: 'rowRemove', desc: '', args: []);
  }

  /// `复制整列`
  String get colDuplicate {
    return Intl.message('复制整列', name: 'colDuplicate', desc: '', args: []);
  }

  /// `复制整行`
  String get rowDuplicate {
    return Intl.message('复制整行', name: 'rowDuplicate', desc: '', args: []);
  }

  /// `清空整列`
  String get colClear {
    return Intl.message('清空整列', name: 'colClear', desc: '', args: []);
  }

  /// `清空整行`
  String get rowClear {
    return Intl.message('清空整行', name: 'rowClear', desc: '', args: []);
  }

  /// `列表项`
  String get listItemPlaceholder {
    return Intl.message('列表项', name: 'listItemPlaceholder', desc: '', args: []);
  }

  /// `待办事项`
  String get toDoPlaceholder {
    return Intl.message('待办事项', name: 'toDoPlaceholder', desc: '', args: []);
  }

  /// `单击 / 以插入内容，或开始输入`
  String get slashPlaceHolder {
    return Intl.message(
      '单击 / 以插入内容，或开始输入',
      name: 'slashPlaceHolder',
      desc: '',
      args: [],
    );
  }

  /// `靠左对齐`
  String get textAlignLeft {
    return Intl.message('靠左对齐', name: 'textAlignLeft', desc: '', args: []);
  }

  /// `居中对齐`
  String get textAlignCenter {
    return Intl.message('居中对齐', name: 'textAlignCenter', desc: '', args: []);
  }

  /// `靠右对齐`
  String get textAlignRight {
    return Intl.message('靠右对齐', name: 'textAlignRight', desc: '', args: []);
  }

  /// `转换为链接`
  String get cmdConvertToLink {
    return Intl.message('转换为链接', name: 'cmdConvertToLink', desc: '', args: []);
  }

  /// `转换为段落`
  String get cmdConvertToParagraph {
    return Intl.message(
      '转换为段落',
      name: 'cmdConvertToParagraph',
      desc: '',
      args: [],
    );
  }

  /// `复制选中内容`
  String get cmdCopySelection {
    return Intl.message('复制选中内容', name: 'cmdCopySelection', desc: '', args: []);
  }

  /// `剪切选中内容`
  String get cmdCutSelection {
    return Intl.message('剪切选中内容', name: 'cmdCutSelection', desc: '', args: []);
  }

  /// `向左删除字符`
  String get cmdDeleteLeft {
    return Intl.message('向左删除字符', name: 'cmdDeleteLeft', desc: '', args: []);
  }

  /// `删除至行首`
  String get cmdDeleteLineLeft {
    return Intl.message('删除至行首', name: 'cmdDeleteLineLeft', desc: '', args: []);
  }

  /// `向右删除字符`
  String get cmdDeleteRight {
    return Intl.message('向右删除字符', name: 'cmdDeleteRight', desc: '', args: []);
  }

  /// `向左删除词语`
  String get cmdDeleteWordLeft {
    return Intl.message(
      '向左删除词语',
      name: 'cmdDeleteWordLeft',
      desc: '',
      args: [],
    );
  }

  /// `向右删除词语`
  String get cmdDeleteWordRight {
    return Intl.message(
      '向右删除词语',
      name: 'cmdDeleteWordRight',
      desc: '',
      args: [],
    );
  }

  /// `退出编辑模式`
  String get cmdExitEditing {
    return Intl.message('退出编辑模式', name: 'cmdExitEditing', desc: '', args: []);
  }

  /// `缩进`
  String get cmdIndent {
    return Intl.message('缩进', name: 'cmdIndent', desc: '', args: []);
  }

  /// `移动光标到底部`
  String get cmdMoveCursorBottom {
    return Intl.message(
      '移动光标到底部',
      name: 'cmdMoveCursorBottom',
      desc: '',
      args: [],
    );
  }

  /// `选中到文档末尾`
  String get cmdMoveCursorBottomSelect {
    return Intl.message(
      '选中到文档末尾',
      name: 'cmdMoveCursorBottomSelect',
      desc: '',
      args: [],
    );
  }

  /// `向下移动光标`
  String get cmdMoveCursorDown {
    return Intl.message(
      '向下移动光标',
      name: 'cmdMoveCursorDown',
      desc: '',
      args: [],
    );
  }

  /// `向下选中`
  String get cmdMoveCursorDownSelect {
    return Intl.message(
      '向下选中',
      name: 'cmdMoveCursorDownSelect',
      desc: '',
      args: [],
    );
  }

  /// `向左移动光标`
  String get cmdMoveCursorLeft {
    return Intl.message(
      '向左移动光标',
      name: 'cmdMoveCursorLeft',
      desc: '',
      args: [],
    );
  }

  /// `向左选中`
  String get cmdMoveCursorLeftSelect {
    return Intl.message(
      '向左选中',
      name: 'cmdMoveCursorLeftSelect',
      desc: '',
      args: [],
    );
  }

  /// `移动光标到行尾`
  String get cmdMoveCursorLineEnd {
    return Intl.message(
      '移动光标到行尾',
      name: 'cmdMoveCursorLineEnd',
      desc: '',
      args: [],
    );
  }

  /// `选中到行尾`
  String get cmdMoveCursorLineEndSelect {
    return Intl.message(
      '选中到行尾',
      name: 'cmdMoveCursorLineEndSelect',
      desc: '',
      args: [],
    );
  }

  /// `移动光标到行首`
  String get cmdMoveCursorLineStart {
    return Intl.message(
      '移动光标到行首',
      name: 'cmdMoveCursorLineStart',
      desc: '',
      args: [],
    );
  }

  /// `选中到行首`
  String get cmdMoveCursorLineStartSelect {
    return Intl.message(
      '选中到行首',
      name: 'cmdMoveCursorLineStartSelect',
      desc: '',
      args: [],
    );
  }

  /// `向右移动光标`
  String get cmdMoveCursorRight {
    return Intl.message(
      '向右移动光标',
      name: 'cmdMoveCursorRight',
      desc: '',
      args: [],
    );
  }

  /// `向右选中`
  String get cmdMoveCursorRightSelect {
    return Intl.message(
      '向右选中',
      name: 'cmdMoveCursorRightSelect',
      desc: '',
      args: [],
    );
  }

  /// `移动光标到顶部`
  String get cmdMoveCursorTop {
    return Intl.message(
      '移动光标到顶部',
      name: 'cmdMoveCursorTop',
      desc: '',
      args: [],
    );
  }

  /// `选中到文档开头`
  String get cmdMoveCursorTopSelect {
    return Intl.message(
      '选中到文档开头',
      name: 'cmdMoveCursorTopSelect',
      desc: '',
      args: [],
    );
  }

  /// `向上移动光标`
  String get cmdMoveCursorUp {
    return Intl.message('向上移动光标', name: 'cmdMoveCursorUp', desc: '', args: []);
  }

  /// `向上选中`
  String get cmdMoveCursorUpSelect {
    return Intl.message(
      '向上选中',
      name: 'cmdMoveCursorUpSelect',
      desc: '',
      args: [],
    );
  }

  /// `移动光标到左侧词语`
  String get cmdMoveCursorWordLeft {
    return Intl.message(
      '移动光标到左侧词语',
      name: 'cmdMoveCursorWordLeft',
      desc: '',
      args: [],
    );
  }

  /// `选中左侧词语`
  String get cmdMoveCursorWordLeftSelect {
    return Intl.message(
      '选中左侧词语',
      name: 'cmdMoveCursorWordLeftSelect',
      desc: '',
      args: [],
    );
  }

  /// `移动光标到右侧词语`
  String get cmdMoveCursorWordRight {
    return Intl.message(
      '移动光标到右侧词语',
      name: 'cmdMoveCursorWordRight',
      desc: '',
      args: [],
    );
  }

  /// `选中右侧词语`
  String get cmdMoveCursorWordRightSelect {
    return Intl.message(
      '选中右侧词语',
      name: 'cmdMoveCursorWordRightSelect',
      desc: '',
      args: [],
    );
  }

  /// `打开查找`
  String get cmdOpenFind {
    return Intl.message('打开查找', name: 'cmdOpenFind', desc: '', args: []);
  }

  /// `打开查找替换`
  String get cmdOpenFindAndReplace {
    return Intl.message(
      '打开查找替换',
      name: 'cmdOpenFindAndReplace',
      desc: '',
      args: [],
    );
  }

  /// `打开链接`
  String get cmdOpenLink {
    return Intl.message('打开链接', name: 'cmdOpenLink', desc: '', args: []);
  }

  /// `打开所有链接`
  String get cmdOpenLinks {
    return Intl.message('打开所有链接', name: 'cmdOpenLinks', desc: '', args: []);
  }

  /// `取消缩进`
  String get cmdOutdent {
    return Intl.message('取消缩进', name: 'cmdOutdent', desc: '', args: []);
  }

  /// `粘贴内容`
  String get cmdPasteContent {
    return Intl.message('粘贴内容', name: 'cmdPasteContent', desc: '', args: []);
  }

  /// `以纯文本粘贴`
  String get cmdPasteContentAsPlainText {
    return Intl.message(
      '以纯文本粘贴',
      name: 'cmdPasteContentAsPlainText',
      desc: '',
      args: [],
    );
  }

  /// `重做`
  String get cmdRedo {
    return Intl.message('重做', name: 'cmdRedo', desc: '', args: []);
  }

  /// `向下翻页`
  String get cmdScrollPageDown {
    return Intl.message('向下翻页', name: 'cmdScrollPageDown', desc: '', args: []);
  }

  /// `向上翻页`
  String get cmdScrollPageUp {
    return Intl.message('向上翻页', name: 'cmdScrollPageUp', desc: '', args: []);
  }

  /// `滚动到底部`
  String get cmdScrollToBottom {
    return Intl.message('滚动到底部', name: 'cmdScrollToBottom', desc: '', args: []);
  }

  /// `滚动到顶部`
  String get cmdScrollToTop {
    return Intl.message('滚动到顶部', name: 'cmdScrollToTop', desc: '', args: []);
  }

  /// `全选`
  String get cmdSelectAll {
    return Intl.message('全选', name: 'cmdSelectAll', desc: '', args: []);
  }

  /// `表格：插入换行`
  String get cmdTableLineBreak {
    return Intl.message(
      '表格：插入换行',
      name: 'cmdTableLineBreak',
      desc: '',
      args: [],
    );
  }

  /// `移动到下方单元格`
  String get cmdTableMoveToDownCellAtSameOffset {
    return Intl.message(
      '移动到下方单元格',
      name: 'cmdTableMoveToDownCellAtSameOffset',
      desc: '',
      args: [],
    );
  }

  /// `移动到左侧单元格`
  String get cmdTableMoveToLeftCellIfItsAtStartOfCurrentCell {
    return Intl.message(
      '移动到左侧单元格',
      name: 'cmdTableMoveToLeftCellIfItsAtStartOfCurrentCell',
      desc: '',
      args: [],
    );
  }

  /// `移动到右侧单元格`
  String get cmdTableMoveToRightCellIfItsAtTheEndOfCurrentCell {
    return Intl.message(
      '移动到右侧单元格',
      name: 'cmdTableMoveToRightCellIfItsAtTheEndOfCurrentCell',
      desc: '',
      args: [],
    );
  }

  /// `移动到上方单元格`
  String get cmdTableMoveToUpCellAtSameOffset {
    return Intl.message(
      '移动到上方单元格',
      name: 'cmdTableMoveToUpCellAtSameOffset',
      desc: '',
      args: [],
    );
  }

  /// `在单元格间导航`
  String get cmdTableNavigateCells {
    return Intl.message(
      '在单元格间导航',
      name: 'cmdTableNavigateCells',
      desc: '',
      args: [],
    );
  }

  /// `在单元格间反向导航`
  String get cmdTableNavigateCellsReverse {
    return Intl.message(
      '在单元格间反向导航',
      name: 'cmdTableNavigateCellsReverse',
      desc: '',
      args: [],
    );
  }

  /// `停在单元格开头`
  String get cmdTableStopAtTheBeginningOfTheCell {
    return Intl.message(
      '停在单元格开头',
      name: 'cmdTableStopAtTheBeginningOfTheCell',
      desc: '',
      args: [],
    );
  }

  /// `切换粗体`
  String get cmdToggleBold {
    return Intl.message('切换粗体', name: 'cmdToggleBold', desc: '', args: []);
  }

  /// `切换代码`
  String get cmdToggleCode {
    return Intl.message('切换代码', name: 'cmdToggleCode', desc: '', args: []);
  }

  /// `切换高亮`
  String get cmdToggleHighlight {
    return Intl.message('切换高亮', name: 'cmdToggleHighlight', desc: '', args: []);
  }

  /// `切换斜体`
  String get cmdToggleItalic {
    return Intl.message('切换斜体', name: 'cmdToggleItalic', desc: '', args: []);
  }

  /// `切换删除线`
  String get cmdToggleStrikethrough {
    return Intl.message(
      '切换删除线',
      name: 'cmdToggleStrikethrough',
      desc: '',
      args: [],
    );
  }

  /// `切换待办列表`
  String get cmdToggleTodoList {
    return Intl.message(
      '切换待办列表',
      name: 'cmdToggleTodoList',
      desc: '',
      args: [],
    );
  }

  /// `切换下划线`
  String get cmdToggleUnderline {
    return Intl.message(
      '切换下划线',
      name: 'cmdToggleUnderline',
      desc: '',
      args: [],
    );
  }

  /// `撤销`
  String get cmdUndo {
    return Intl.message('撤销', name: 'cmdUndo', desc: '', args: []);
  }

  /// `切换一级标题`
  String get cmdToggleH1 {
    return Intl.message('切换一级标题', name: 'cmdToggleH1', desc: '', args: []);
  }

  /// `切换二级标题`
  String get cmdToggleH2 {
    return Intl.message('切换二级标题', name: 'cmdToggleH2', desc: '', args: []);
  }

  /// `切换三级标题`
  String get cmdToggleH3 {
    return Intl.message('切换三级标题', name: 'cmdToggleH3', desc: '', args: []);
  }

  /// `切换正文`
  String get cmdToggleBody {
    return Intl.message('切换正文', name: 'cmdToggleBody', desc: '', args: []);
  }
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<AppFlowyEditorLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'zh'),
      Locale.fromSubtags(languageCode: 'bn', countryCode: 'BN'),
      Locale.fromSubtags(languageCode: 'ca'),
      Locale.fromSubtags(languageCode: 'cs', countryCode: 'CZ'),
      Locale.fromSubtags(languageCode: 'da'),
      Locale.fromSubtags(languageCode: 'de', countryCode: 'DE'),
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es', countryCode: 'VE'),
      Locale.fromSubtags(languageCode: 'fr', countryCode: 'CA'),
      Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
      Locale.fromSubtags(languageCode: 'hi', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'hu', countryCode: 'HU'),
      Locale.fromSubtags(languageCode: 'id', countryCode: 'ID'),
      Locale.fromSubtags(languageCode: 'it', countryCode: 'IT'),
      Locale.fromSubtags(languageCode: 'ja', countryCode: 'JP'),
      Locale.fromSubtags(languageCode: 'ml', countryCode: 'IN'),
      Locale.fromSubtags(languageCode: 'nl', countryCode: 'NL'),
      Locale.fromSubtags(languageCode: 'pl', countryCode: 'PL'),
      Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
      Locale.fromSubtags(languageCode: 'pt', countryCode: 'PT'),
      Locale.fromSubtags(languageCode: 'ru', countryCode: 'RU'),
      Locale.fromSubtags(languageCode: 'tr', countryCode: 'TR'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppFlowyEditorLocalizations> load(Locale locale) =>
      AppFlowyEditorLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
