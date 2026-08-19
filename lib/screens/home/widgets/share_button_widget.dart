import 'package:flutter/material.dart';
import 'package:vn_template/core/constant/app_colors.dart';

class ShareButtonWidget extends StatelessWidget {
  const ShareButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.share,
          color: AppColors.whiteColor,
          size: 24,
        ),
      ),
    );
  }
}
