import 'package:flutter/material.dart';

/// 行内代码的视觉主题配置
///
/// 将行内代码的「文字样式」和「装饰样式」分离：
/// - [textStyle]：控制文字本身（字体、大小、颜色等），由 TextSpan 渲染
/// - 其余字段：控制圆角背景装饰，由 CustomPainter 绘制
///
/// 设计优势：
/// 1. 职责清晰——文字样式与装饰样式各司其职，互不干扰
/// 2. 扩展方便——可轻松添加边框样式、阴影等装饰属性
/// 3. 可选文字样式——[textStyle] 为 null 时保留原有文字样式，仅添加装饰
class InlineCodeTheme {
  const InlineCodeTheme({
    this.textStyle,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0.5,
    this.borderRadius = 3.0,
    this.horizontalPadding = 1.0,
    this.verticalPadding = 0.5,
  });

  /// 行内代码的文字样式（字体、大小、颜色等），为 null 时不改变原有文字样式
  final TextStyle? textStyle;

  /// 圆角背景颜色，为 null 时不绘制背景
  final Color? backgroundColor;

  /// 边框颜色，为 null 时不绘制边框
  final Color? borderColor;

  /// 边框宽度
  final double borderWidth;

  /// 圆角半径
  final double borderRadius;

  /// 水平内边距（背景向左右各扩展的距离）
  final double horizontalPadding;

  /// 垂直内边距（背景向上下各扩展的距离）
  final double verticalPadding;

  InlineCodeTheme copyWith({
    TextStyle? textStyle,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
    double? horizontalPadding,
    double? verticalPadding,
  }) {
    return InlineCodeTheme(
      textStyle: textStyle ?? this.textStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      verticalPadding: verticalPadding ?? this.verticalPadding,
    );
  }
}

/// only for the common config of text style
class TextStyleConfiguration {
  const TextStyleConfiguration({
    this.text = const TextStyle(fontSize: 16.0),
    this.bold = const TextStyle(fontWeight: FontWeight.bold),
    this.italic = const TextStyle(fontStyle: FontStyle.italic),
    this.underline = const TextStyle(
      decoration: TextDecoration.underline,
    ),
    this.strikethrough = const TextStyle(
      decoration: TextDecoration.lineThrough,
    ),
    this.href = const TextStyle(
      color: Colors.lightBlue,
      decoration: TextDecoration.underline,
    ),
    this.inlineCodeTheme,
    this.autoComplete = const TextStyle(
      color: Colors.grey,
    ),
    this.applyHeightToFirstAscent = false,
    this.applyHeightToLastDescent = false,
    this.lineHeight = 1.5,
    this.leadingDistribution = TextLeadingDistribution.even,
  });

  /// 默认文字样式
  final TextStyle text;

  /// 粗体样式
  final TextStyle bold;

  /// 斜体样式
  final TextStyle italic;

  /// 下划线样式
  final TextStyle underline;

  /// 删除线样式
  final TextStyle strikethrough;

  /// 链接样式
  final TextStyle href;

  /// 行内代码主题配置
  ///
  /// - [InlineCodeTheme.textStyle] 控制文字样式
  /// - [InlineCodeTheme.backgroundColor] 等控制圆角背景装饰
  final InlineCodeTheme? inlineCodeTheme;

  /// 自动补全样式
  final TextStyle autoComplete;

  final bool applyHeightToFirstAscent;
  final bool applyHeightToLastDescent;

  final double lineHeight;
  final TextLeadingDistribution leadingDistribution;

  TextStyleConfiguration copyWith({
    TextStyle? text,
    TextStyle? bold,
    TextStyle? italic,
    TextStyle? underline,
    TextStyle? strikethrough,
    TextStyle? href,
    InlineCodeTheme? inlineCodeTheme,
    TextStyle? autoComplete,
    bool? applyHeightToFirstAscent,
    bool? applyHeightToLastDescent,
    double? lineHeight,
    TextLeadingDistribution? leadingDistribution,
  }) {
    return TextStyleConfiguration(
      text: text ?? this.text,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      href: href ?? this.href,
      inlineCodeTheme: inlineCodeTheme ?? this.inlineCodeTheme,
      autoComplete: autoComplete ?? this.autoComplete,
      applyHeightToFirstAscent:
          applyHeightToFirstAscent ?? this.applyHeightToFirstAscent,
      applyHeightToLastDescent:
          applyHeightToLastDescent ?? this.applyHeightToLastDescent,
      lineHeight: lineHeight ?? this.lineHeight,
      leadingDistribution: leadingDistribution ?? this.leadingDistribution,
    );
  }
}
