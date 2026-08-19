import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad_onboarding/view/native_ad_onboarding_widget.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_image_string.dart';
import 'package:vn_template/core/constant/app_lotties_string.dart';
import 'package:vn_template/common_widgets/common_lottie_asset.dart';
import 'package:vn_template/common_widgets/common_button.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:vn_template/data/helper/ad_helper.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/screens/onboarding/widget/onboarding_page_widget.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad_onboarding/bloc/native_ad_onboarding_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vn_template/routes/app_route_string.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  @override
  void initState() {
    super.initState();
    AdHelper.precacheInterstitialAd(adId: AppAdIdString.onboardingInterstitial);
    context.read<OnboardingBloc>().add(OnboardingInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: state.currentPage == 0
                    ? OnboardingPageWidget(
                        imagePath: AppImagesString.imgOnboarding1,
                        title: AppStrings.txtDiscoverBestTemplates.getString(
                          context,
                        ),
                      )
                    : OnboardingPageWidget(
                        imagePath: AppImagesString.imgOnboarding2,
                        title: AppStrings.txtCreateAmazingReels.getString(
                          context,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 40.0,
                ),
                child: SizedBox(
                  height: 60,
                  child: state.isLoading
                      ? const Center(
                          child: CommonLottieAsset(
                            assetName: AppLottiesString.lottieOnboardingLoading,
                            height: 60,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Dotted lines
                            Row(
                              children: List.generate(
                                2,
                                (index) => Container(
                                  margin: const EdgeInsets.only(right: 8.0),
                                  height: 8.0,
                                  width: state.currentPage == index
                                      ? 24.0
                                      : 8.0,
                                  decoration: BoxDecoration(
                                    color: state.currentPage == index
                                        ? AppColors.accentColor
                                        : Colors.grey,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                ),
                              ),
                            ),
                            // Next / Get Started button
                            CommonButton(
                              text: state.currentPage == 1
                                  ? AppStrings.txtGetStarted.getString(context)
                                  : AppStrings.txtNext.getString(context),
                              onTap: () {
                                if (state.currentPage == 1) {
                                  AdHelper.showInterstitialAd(
                                    adId: AppAdIdString
                                        .onboardingDoneInterstitial,
                                    onAdClosed: () {
                                      AppPreferences().setBool(
                                        AppPreferences.onboarding,
                                        true,
                                      );
                                      AppPreferences().setInt(
                                        AppPreferences.coin,
                                        50,
                                      );
                                      context.go(
                                        AppRoutesString.selectAppLanguageView,
                                      );
                                    },
                                    reloadAfterClose: false,
                                  );
                                } else {
                                  AdHelper.showInterstitialAd(
                                    reloadAfterClose: false,
                                    adId: AppAdIdString.onboardingInterstitial,
                                    onAdClosed: () {
                                      AdHelper.precacheInterstitialAd(
                                        adId: AppAdIdString
                                            .onboardingDoneInterstitial,
                                      );
                                      context.read<OnboardingBloc>().add(
                                        PageChangedEvent(1),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                ),
              ),
              BlocProvider(
                create: (context) => NativeAdOnboardingBloc(),
                child: NativeAdOnboardingWidget(index: state.currentPage),
              ),
            ],
          );
        },
      ),
    );
  }
}
