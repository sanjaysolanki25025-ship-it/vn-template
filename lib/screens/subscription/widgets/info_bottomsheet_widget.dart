import 'package:flutter/material.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';

class InfoBottomSheetWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const InfoBottomSheetWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: AppColors.whiteColor.withOpacity(0.1), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SBH10(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.blackColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.whiteColor, size: 30),
          ),
          const SBH20(),
          CommonTextWidget(
            text: title,
            textStyle: size18TextStyle(textColor: AppColors.whiteColor, fontWeight: FontWeight.bold),
          ),
          const SBH15(),
          CommonTextWidget(
            text: description,
            textAlign: TextAlign.center,
            textStyle: size14TextStyle(textColor: AppColors.whiteColor),
          ),
          const SBH30(),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CommonTextWidget(
                  text: AppStrings.txtOkay,
                  textStyle: size16TextStyle(textColor: AppColors.blackColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SBH15(),
        ],
      ),
    );
  }
}
