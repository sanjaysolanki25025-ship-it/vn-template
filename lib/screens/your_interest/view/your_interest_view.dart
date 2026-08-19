import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/view/banner_ad_widget.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:vn_template/common_widgets/common_app_bar.dart';
import 'package:vn_template/common_widgets/common_button.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/common_widgets/common_toast.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/data/helper/ad_helper.dart';
import 'package:vn_template/routes/app_route_string.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import '../bloc/your_interest_bloc.dart';
import '../widget/interest_chip_widget.dart';

class YourInterestView extends StatelessWidget {
  const YourInterestView({Key? key}) : super(key: key);

  static const List<String> categories = [
    AppStrings.txtCategoryPopular,
    AppStrings.txtCategoryTrending,
    AppStrings.txtCategoryFeatured,
    AppStrings.txtCategoryNew,
    AppStrings.txtCategoryClassic,
    AppStrings.txtCategoryMinimal,
    AppStrings.txtCategoryCreative,
    AppStrings.txtCategoryAesthetic,
    AppStrings.txtCategoryModern,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: CommonAppBar(
        title: AppStrings.txtYourInterests.getString(context),
      ),
      body: BlocListener<YourInterestBloc, YourInterestState>(
        listener: (context, state) {
          if (state.status == YourInterestStatus.error) {
            CommonToast.showToast(
              context: context,
              message: AppStrings.txtAtLeastOneInterest.getString(context),
              isError: true,
            );
          } else if (state.status == YourInterestStatus.success) {
            AppPreferences().setBool(AppPreferences.isInterestDone, true);
            AdHelper.showAppOpenAd(
              onComplete: () {
                context.go(AppRoutesString.dashboardView);
              },
            );
          }
        },
        child: BlocBuilder<YourInterestBloc, YourInterestState>(
          builder: (context, state) {
            final bloc = context.read<YourInterestBloc>();
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 16.h,
                    children: categories.map((category) {
                      final isSelected = state.selectedInterests.contains(
                        category,
                      );
                      return InterestChipWidget(
                        label: category,
                        isSelected: isSelected,
                        onTap: () {
                          bloc.add(ToggleInterestEvent(category));
                        },
                      );
                    }).toList(),
                  ),
                  SBH5(),
                  BlocProvider(
                    create: (context) => NativeAdBloc(),
                    child: NativeAdView(
                      adId: AppAdIdString.chooseYourInterestNativeAd,
                      isSmallAd: false,
                      isSplash: true,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<YourInterestBloc, YourInterestState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CommonButton(
                  text: AppStrings.txtDone.getString(context),
                  onTap: () {
                    context.read<YourInterestBloc>().add(
                      SubmitInterestsEvent(),
                    );
                  },
                ),
              ),
              const SBH2(),
              BlocProvider(
                create: (context) => BannerAdBloc(),
                child: BannerAdWidget(adId: AppAdIdString.chooseInterestBanner),
              ),
            ],
          );
        },
      ),
    );
  }
}
