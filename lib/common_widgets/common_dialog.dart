import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:vn_template/common_widgets/common_button.dart';
import 'package:vn_template/common_widgets/common_loader.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/common_widgets/common_image.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_image_string.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/routes/app_route_string.dart';

class CommonDialog {
  static Future<void> showDialogWidget({
    required BuildContext context,
    required String title,
    required Widget childWidget,
    bool barrierDismissible = true,
    required String adId,
  }) {
    return showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.whiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accentColor.withValues(alpha: 0.3), width: 1),
              gradient: LinearGradient(colors: [AppColors.primaryColor, AppColors.blackColor]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SBH10(),
                  Center(
                    child: CommonTextWidget(
                      text: title,
                      textAlign: TextAlign.center,
                      textStyle: size20TextStyle(
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.whiteColor,
                      ),
                    ),
                  ),
                  const SBH2(),
                  childWidget,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: BlocProvider(
                      create: (context) => NativeAdBloc(),
                      child: NativeAdView(isSmallAd: true, adId: adId),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// loader dialog
  static Future<void> loaderDialog({required BuildContext context, bool isSmall = false}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: isSmall
              ? Center(
                  child: Material(
                    color: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    type: MaterialType.card,
                    child: SizedBox(
                      width: 250,
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CommonLoader(
                              size: 18,
                              strokeWidth: 2,
                            ),
                            const SizedBox(width: 12),
                            CommonTextWidget(
                              text: AppStrings.txtPleaseWait,
                              textStyle: size12TextStyle(textColor: AppColors.whiteColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Dialog(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SBW5(),
                        const CommonLoader(
                          size: 30,
                          strokeWidth: 3,
                        ),
                        const SBW20(),
                        CommonTextWidget(
                          text: AppStrings.txtPleaseWait,
                          textStyle: size12TextStyle(textColor: AppColors.whiteColor),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  /// close dialog
  static void closeDialog({required BuildContext context}) {
    final navigator = Navigator.of(context, rootNavigator: true);

    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  /// Check if the Dino dialog should be shown today (once per day)
  static bool shouldShowDinoDialog() {
    final prefs = AppPreferences();
    final lastShown = prefs.getString("last_dino_dialog_show_date");
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastShown != today;
  }

  /// Mark that the Dino dialog was shown today
  static void markDinoDialogShown() {
    final prefs = AppPreferences();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    prefs.setString("last_dino_dialog_show_date", today);
  }

  /// Cartoon type Dino dialog
  static Future<void> showDinoDialog({required BuildContext context}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(
              color: AppColors.accentColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cartoon header icon - Dino
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: CommonImage(
                    assetName: AppImagesString.imgDino,
                    height: 80.h,
                    width: 80.w,
                    fit: BoxFit.contain,
                  ),
                ),
                const SBH15(),
                // Title
                CommonTextWidget(
                  text: AppStrings.txtDinoRunChallenge.getString(context),
                  textAlign: TextAlign.center,
                  textStyle: size18TextStyle(
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.whiteColor,
                  ),
                ),
                const SBH10(),
                // Description
                CommonTextWidget(
                  text: AppStrings.txtRunWithTheDinoDodgeCactiAndEarnFreeCoinsToUnlockYourFavoritePremiumLightroomPresets.getString(context),
                  textAlign: TextAlign.center,
                  textStyle: size12TextStyle(
                    textColor: AppColors.whiteColor.withValues(alpha: 0.7),
                  ).copyWith(height: 1.4),
                ),
                const SBH20(),
                // Play Button
                SizedBox(
                  width: double.infinity,
                  child: CommonButton(
                    onTap: () {
                      Navigator.of(context).pop(); // close dialog
                      context.push(AppRoutesString.dinoView); // navigate to dino game
                    },
                    text: AppStrings.txtPlayGame.getString(context),
                  ),
                ),
                const SBH10(),
                // Cancel
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: CommonTextWidget(
                      text: AppStrings.txtMaybeLater.getString(context),
                      textStyle: size12TextStyle(
                        textColor: AppColors.greyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
