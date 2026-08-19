import 'package:flutter/material.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/utils/app_text_style.dart';

class SettingOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailingWidget;

  const SettingOptionTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.whiteColor, size: 24),
            const SBW15(),
            Expanded(
              child: CommonTextWidget(
                text: title,
                textStyle: size16TextStyle(
                  textColor: AppColors.whiteColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailingWidget ?? const Icon(Icons.arrow_forward_ios, color: AppColors.whiteColor, size: 16),
          ],
        ),
      ),
    );
  }
}
