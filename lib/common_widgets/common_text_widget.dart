import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:vn_template/core/constant/app_colors.dart';

class CommonTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final int? maxLines;
  final int? maxLine;
  final double? height;
  final double? minFontSize;
  final bool? isUnderline;
  final bool? isStrikeThrough;
  final Color? underlineColor;

  const CommonTextWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.overflow,
    this.textAlign,
    this.maxLines,
    this.maxLine,
    this.height,
    this.minFontSize,
    this.isUnderline,
    this.isStrikeThrough,
    this.underlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: (textStyle ?? const TextStyle()).copyWith(
        height: height,
        decoration: isStrikeThrough == true
            ? TextDecoration.lineThrough
            : isUnderline == true
            ? TextDecoration.underline
            : null,
        decorationColor: underlineColor ?? AppColors.primaryColor,
        decorationThickness: 2,
      ),
      overflow: overflow,
      textAlign: textAlign,
      maxLines: maxLines ?? maxLine,
      minFontSize: (minFontSize ?? 8).floorToDouble(),
    );
  }
}
