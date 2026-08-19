import 'package:flutter/material.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/utils/app_text_style.dart';

class CommonTextField extends StatelessWidget {
  final String hintText;
  final String? prefixIcon;
  final TextEditingController controller;
  final int maxLines;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool autoFocus;

  const CommonTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    required this.controller,
    this.maxLines = 1,
    this.validator,
    this.focusNode,
    this.keyboardType,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      autofocus: autoFocus,
      validator: validator,
      maxLines: maxLines,
      controller: controller,
      keyboardType: keyboardType,
      style: size16TextStyle(textColor: AppColors.blackColor, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: size16TextStyle(textColor: AppColors.greyColor, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: AppColors.whiteColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
