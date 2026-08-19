import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:vn_template/common_widgets/common_button.dart';
import 'package:vn_template/common_widgets/common_image.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_image_string.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/routes/app_route_string.dart';
import 'package:vn_template/screens/setting/bloc/setting_bloc.dart';

class RateUsBottomSheet extends StatelessWidget {
  const RateUsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingBloc(),
      child: BlocBuilder<SettingBloc, SettingState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: BlocProvider(
                    create: (context) => NativeAdBloc(),
                    child: NativeAdView(adId: AppAdIdString.rateUsNativeAd),
                  ),
                ),
                const SBH10(),

                // Rating Image
                CommonImage(
                  assetName: state.selectedRateIndex == 1
                      ? AppImagesString.imgRating1
                      : state.selectedRateIndex == 2
                      ? AppImagesString.imgRating2
                      : state.selectedRateIndex == 3
                      ? AppImagesString.imgRating3
                      : state.selectedRateIndex == 4
                      ? AppImagesString.imgRating4
                      : AppImagesString.imgRating5,
                  height: 70,
                  width: 70,
                  fit: BoxFit.contain,
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: CommonTextWidget(
                    text: state.selectedRateIndex == 1
                        ? AppStrings.txtWeSorryAboutThis.getString(context)
                        : state.selectedRateIndex == 2
                        ? AppStrings.txtItWasPoor.getString(context)
                        : state.selectedRateIndex == 3
                        ? AppStrings.txtItWasGood.getString(context)
                        : state.selectedRateIndex == 4
                        ? AppStrings.txtThanksForYourTrust.getString(context)
                        : AppStrings.txtPleaseRateUs.getString(context),
                    maxLine: 1,
                    minFontSize: 18,
                    overflow: TextOverflow.ellipsis,
                    textStyle: size20TextStyle(
                      textColor: AppColors.whiteColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: CommonTextWidget(
                    text: state.selectedRateIndex == 1
                        ? AppStrings.txtLetUsKnowTheIssueWeGotYouCovered
                              .getString(context)
                        : state.selectedRateIndex == 2
                        ? AppStrings.txtWhereCanWeImprove.getString(context)
                        : state.selectedRateIndex == 3
                        ? AppStrings.txtWhatAspectsOfTheAppCouldWeImprove
                              .getString(context)
                        : state.selectedRateIndex == 4
                        ? AppStrings.txtWillWorkHarderToMakeYouMoreSatisfied
                              .getString(context)
                        : AppStrings.txtEnjoyingTheAppLetUsKnow.getString(
                            context,
                          ),
                    textAlign: TextAlign.center,
                    maxLine: 2,
                    minFontSize: 12,
                    textStyle: size12TextStyle(textColor: AppColors.greyColor),
                  ),
                ),

                const SBH5(),

                // Rating Bar
                RatingBar.builder(
                  initialRating: state.selectedRateIndex.toDouble(),
                  minRating: 1,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 35,
                  unratedColor: AppColors.greyColor,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: AppColors.accentColor),
                  onRatingUpdate: (rating) {
                    context.read<SettingBloc>().add(
                      ChangeRateUsEvent(selectedRateIndex: rating.toInt()),
                    );
                  },
                ),

                const SBH5(),

                // Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CommonButton(
                    borderRadius: 30,
                    text: state.selectedRateIndex == 5
                        ? AppStrings.txtRateUsOnGoogle.getString(context)
                        : AppStrings.txtRateUs.getString(context),
                    onTap: () {
                      if (state.selectedRateIndex != 5) {
                        context.pop();
                        context.push(AppRoutesString.feedbackCenterView);
                      } else {
                        context.read<SettingBloc>().add(RateUsEvent());
                      }
                    },
                  ),
                ),

                const SBH5(),
              ],
            ),
          );
        },
      ),
    );
  }
}
