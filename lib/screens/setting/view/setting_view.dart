import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/view/banner_ad_widget.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:vn_template/common_widgets/common_app_bar.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/core/utils/common_functions.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:vn_template/routes/app_route_string.dart';
import 'package:vn_template/screens/setting/widgets/setting_option_tile.dart';
import 'package:vn_template/screens/setting/widgets/rate_us_bottom_sheet.dart';
import 'package:vn_template/common_widgets/common_bottomsheet.dart';
import 'package:vn_template/common_widgets/common_dialog.dart';
import 'package:vn_template/core/utils/native_ad_manager.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/core/localization/localization_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = "v${packageInfo.version} (${packageInfo.buildNumber})";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int coins = AppPreferences().getInt(AppPreferences.coin) ?? 0;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CommonAppBar(
          title: AppStrings.txtSetting.getString(context),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: AppColors.accentColor,
                    size: 24,
                  ),
                  const SBW10(),
                  CommonTextWidget(
                    text: coins.toString(),
                    textStyle: size16TextStyle(
                      textColor: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Highlighted Subscription Option
                  /*
                  InkWell(
                    onTap: () {
                      context.push(AppRoutesString.subscriptionView);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.amberColor, AppColors.orangeColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.amberColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.workspace_premium, color: AppColors.blackColor, size: 28),
                          const SBW15(),
                          Expanded(
                            child: CommonTextWidget(
                              text: AppStrings.txtPremiumSubscription,
                              textStyle: size16TextStyle(
                                textColor: AppColors.blackColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: AppColors.blackColor, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SBH10(),
                  */
                  SettingOptionTile(
                    icon: Icons.language,
                    title: AppStrings.txtSettingSelectionLanguage.getString(
                      context,
                    ),
                    trailingWidget: DropdownButton<String>(
                      value: LocalizationService().currentLocale,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.whiteColor,
                      ),
                      dropdownColor: AppColors.primaryColor,
                      underline: const SizedBox(),
                      items: LocalizationService().supportedLocales.map((
                        String locale,
                      ) {
                        return DropdownMenuItem<String>(
                          value: locale,
                          child: CommonTextWidget(
                            text: locale.toUpperCase(),
                            textStyle: size16TextStyle(
                              textColor: AppColors.whiteColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          LocalizationService().changeLanguage(newValue);
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  const SBH10(),
                  SettingOptionTile(
                    icon: Icons.star,
                    title: AppStrings.txtRateUs.getString(context),
                    onTap: () async {
                      CommonDialog.loaderDialog(context: context);
                      NativeAdManager().preCacheAd(AppAdIdString.rateUsNativeAd);
                      await Future.delayed(const Duration(seconds: 2));
                      if (!context.mounted) return;
                      CommonDialog.closeDialog(context: context);

                      CommonBottomSheet.showBottomSheet(
                        context: context,
                        widget: const RateUsBottomSheet(),
                      );
                    },
                  ),
                  const SBH10(),
                  SettingOptionTile(
                    icon: Icons.share,
                    title: AppStrings.txtShareApp.getString(context),
                    onTap: () {
                      CommonFunction.shareApp();
                    },
                  ),
                  const SBH10(),
                  SettingOptionTile(
                    icon: Icons.apps,
                    title: AppStrings.txtExploreOurOtherApps.getString(context),
                    onTap: () {
                      context.push(AppRoutesString.otherAppsView);
                    },
                  ),
                  const SBH10(),
                  BlocProvider(
                    create: (context) => NativeAdBloc(),
                    child: NativeAdView(adId: AppAdIdString.settingNativeAd),
                  ),
                  const SBH10(),
                  SettingOptionTile(
                    icon: Icons.privacy_tip,
                    title: AppStrings.txtPrivacyPolicy.getString(context),
                    onTap: () {
                      CommonFunction.launchUrlLink(AppStrings.privacyPolicyUrl);
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_appVersion.isNotEmpty) ...[
            CommonTextWidget(
              text: _appVersion,
              textStyle: size14TextStyle(
                textColor: AppColors.greyColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SBH20(),
          ],
        ],
      ),

      bottomNavigationBar: BlocProvider(
        create: (context) => BannerAdBloc(),
        child: BannerAdWidget(adId: AppAdIdString.settingBannerAd),
      ),
    );
  }
}
