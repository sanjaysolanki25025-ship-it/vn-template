import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';

class TrialButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onCancelTap;

  const TrialButtonWidget({Key? key, this.onTap, this.onCancelTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Text above button
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: size12TextStyle(
              textColor: AppColors.greyColor,
            ),
            children: [
              const TextSpan(text: AppStrings.txtTryFor1DaysAnd),
              TextSpan(
                text: AppStrings.txtSubscriptionCancel,
                style: size12TextStyle(
                  textColor: AppColors.trialButtonBlue,
                  fontWeight: FontWeight.w600,
                ),
                recognizer: TapGestureRecognizer()..onTap = onCancelTap,
              ),
              const TextSpan(text: AppStrings.txtAnytime),
            ],
          ),
        ),
        const SBH10(),
        // Subscribe Button
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.trialButtonBlue,
                  AppColors.trialButtonPurple,
                  AppColors.trialButtonPink,
                  AppColors.trialButtonOrange,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonTextWidget(
                  text: AppStrings.txtRupee1,
                  textStyle: size24TextStyle(
                    textColor: AppColors.whiteColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    CommonTextWidget(
                      text: AppStrings.txtStartTrial,
                      textStyle: size16TextStyle(
                        textColor: AppColors.whiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SBW10(),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppColors.whiteColor,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
