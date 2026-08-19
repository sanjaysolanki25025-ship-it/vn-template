import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:vn_template/common_widgets/common_button.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/core/utils/common_functions.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';

class CommonBottomSheet {
  static Future<dynamic> showBottomSheet({
    required BuildContext context,
    required Widget widget,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.primaryColor,
      builder: (context) {
        return widget;
      },
    );
  }

  /// Common Bottom Sheet
  static Future<dynamic> showCommonBottomSheet({
    required BuildContext context,
    required String title,
    required String firstButtonText,
    required VoidCallback firstButtonOnTap,
    required String adId,

    /// Optional Second Button
    String? secondButtonText,
    VoidCallback? secondButtonOnTap,
  }) {
    final remoteConfig = FirebaseRemoteConfig.instance;
    late final String howToUseLink;
    try {
      howToUseLink = remoteConfig.getString("howToUseLink");
    } catch (_) {
      howToUseLink = "";
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.primaryColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: AppColors.accentColor.withValues(alpha: 0.6), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocProvider(
                create: (context) => NativeAdBloc(),
                child: NativeAdView(isSmallAd: false, adId: adId),
              ),

              const SBH15(),

              CommonTextWidget(
                text: title,
                textStyle: size18TextStyle(textColor: AppColors.whiteColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),

              const SBH5(),

              CommonTextWidget(
                text:
                    "${AppStrings.txtYouHave.getString(context)} 🟡 ${AppPreferences().getInt(AppPreferences.coin) ?? 0} ${AppStrings.txtCoins.getString(context)}",
                textStyle: size14TextStyle(textColor: AppColors.whiteColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SBH5(),
              howToUseLink.isEmpty
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: () async {
                        await CommonFunction.launchUrlLink(howToUseLink);
                      },
                      child: CommonTextWidget(
                        text: AppStrings.txtHowToUse.getString(context),
                        textStyle: size12TextStyle(textColor: AppColors.accentColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
              const SBH5(),
              if (secondButtonText != null && secondButtonOnTap != null)
                Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                        text: firstButtonText,
                        onTap: firstButtonOnTap,
                        buttonColor: AppColors.accentColor,
                        textColor: AppColors.whiteColor,
                      ),
                    ),

                    const SBW15(),

                    Expanded(
                      child: CommonButton(
                        text: secondButtonText,
                        onTap: secondButtonOnTap,
                        buttonColor: AppColors.secondaryColor,
                        textColor: AppColors.whiteColor,
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: CommonButton(
                    text: firstButtonText,
                    onTap: firstButtonOnTap,
                    buttonColor: AppColors.accentColor,
                    textColor: AppColors.whiteColor,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
