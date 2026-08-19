import 'package:flutter/material.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? buttonColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? suffixWidget;

  const CommonButton({
    super.key,
    required this.text,
    required this.onTap,
    this.buttonColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.padding,
    this.suffixWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: buttonColor ?? AppColors.accentColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonTextWidget(
                text: text,
                maxLines: 1,
                minFontSize: 8,
                textAlign: TextAlign.center,
                textStyle: size16TextStyle(
                  fontWeight: FontWeight.bold,
                  textColor: textColor ?? Colors.white,
                ),
              ),
              if (suffixWidget != null) ...[
                const SizedBox(width: 8),
                suffixWidget!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
