import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/view/banner_ad_widget.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/data/helper/ad_helper.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/routes/app_route_string.dart';
import '../bloc/select_app_language_bloc.dart';
import '../widget/language_tile.dart';
import 'package:vn_template/common_widgets/common_app_bar.dart';
import 'package:vn_template/common_widgets/common_button.dart';
import 'package:vn_template/core/utils/localization_service.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';

class SelectAppLanguageView extends StatefulWidget {
  const SelectAppLanguageView({super.key});

  @override
  State<SelectAppLanguageView> createState() => _SelectAppLanguageViewState();
}

class _SelectAppLanguageViewState extends State<SelectAppLanguageView> {
  @override
  void initState() {
    AdHelper.precacheInterstitialAd(
      adId: AppAdIdString.selectLanguageInterstitial,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: CommonAppBar(
        title: AppStrings.txtSelectLanguage.getString(context),
      ),
      body: BlocBuilder<SelectAppLanguageBloc, SelectAppLanguageState>(
        builder: (context, state) {
          final bloc = context.read<SelectAppLanguageBloc>();
          return ListView.builder(
            padding: EdgeInsets.only(top: 16.h, bottom: 32.h),
            itemCount: bloc.supportedLanguages.length + 1,
            itemBuilder: (context, index) {
              if (index == 4) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 2.h,
                  ),
                  child: BlocProvider(
                    create: (context) => NativeAdBloc(),
                    child: NativeAdView(
                      adId: AppAdIdString.selectLanguageNativeAd,
                      isSplash: true,
                      isSmallAd: false,
                    ),
                  ),
                );
              }
              final langIndex = index > 4 ? index - 1 : index;
              final language = bloc.supportedLanguages[langIndex];
              final isSelected = language.code == state.selectedLanguageCode;
              return LanguageTile(
                language: language,
                isSelected: isSelected,
                onTap: () {
                  bloc.add(ChangeLanguageEvent(language.code));
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar:
          BlocBuilder<SelectAppLanguageBloc, SelectAppLanguageState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: CommonButton(
                      text: AppStrings.txtNext.getString(context),
                      onTap: () {
                        AdHelper.showInterstitialAd(
                          adId: AppAdIdString.selectLanguageInterstitial,
                          reloadAfterClose: false,
                          onAdClosed: () {
                            LocalizationService().changeLanguage(
                              state.selectedLanguageCode,
                            );
                            AppPreferences().setBool(
                              AppPreferences.isLanguageSelected,
                              true,
                            );
                            context.push(AppRoutesString.yourInterestView);
                          },
                        );
                      },
                    ),
                  ),
                  const SBH2(),
                  BlocProvider(
                    create: (context) => BannerAdBloc(),
                    child: BannerAdWidget(
                      adId: AppAdIdString.selectLanguageBanner,
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
