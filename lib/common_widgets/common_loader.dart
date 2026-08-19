import 'package:flutter/material.dart';
import 'package:vn_template/core/constant/app_colors.dart';

class CommonLoader extends StatelessWidget {
  const CommonLoader({super.key, this.size = 30, this.strokeWidth = 3});

  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        color: AppColors.whiteColor,
        strokeWidth: strokeWidth,
      ),
    );
  }
}
