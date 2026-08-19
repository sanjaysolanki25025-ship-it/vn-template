import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/utils/app_text_style.dart';

class CommonToast {
  static bool _isShowing = false;
  static Timer? _resetTimer;

  static void showToast({
    required BuildContext context,
    required String message,
    required bool isError,
  }) {
    if (_isShowing) return;

    _isShowing = true;

    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: CommonTextWidget(
        text: message,
        textStyle: size16TextStyle(
          fontWeight: FontWeight.w500,
          textColor: AppColors.whiteColor,
        ),
      ),
      backgroundColor: isError ? AppColors.redColor : AppColors.greenColor,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(top: 20.h, left: 16.w, right: 16.w),
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 2), () {
      _isShowing = false;
    });
  }
}
