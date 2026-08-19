import 'package:flutter_localization/flutter_localization.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../common_widgets/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import '../../../common_widgets/ad_widgets/banner_ad/view/banner_ad_widget.dart';
import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_image.dart';
import '../../../common_widgets/common_text_widget.dart';
import '../../../common_widgets/common_toast.dart';
import '../../../core/constant/app_ad_id_string.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_string.dart';
import '../../../core/utils/app_text_style.dart';
import '../../../core/utils/common_functions.dart';
import '../bloc/other_apps_bloc.dart';

class OtherAppsView extends StatefulWidget {
  const OtherAppsView({super.key});

  @override
  State<OtherAppsView> createState() => _OtherAppsViewState();
}

class _OtherAppsViewState extends State<OtherAppsView> {
  @override
  void initState() {
    super.initState();
    context.read<OtherAppsBloc>().add(FetchOtherAppsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CommonAppBar(
          title: AppStrings.txtExploreOurOtherApps.getString(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: BlocListener<OtherAppsBloc, OtherAppsState>(
          listener: (context, state) {
            if (state.status == OtherAppsStatus.error) {
              CommonToast.showToast(
                context: context,
                message:
                    state.errorMessage ??
                    AppStrings.txtSomethingWentWrong.getString(context),
                isError: true,
              );
            }
          },
          child: BlocBuilder<OtherAppsBloc, OtherAppsState>(
            builder: (context, state) {
              if (state.status == OtherAppsStatus.loading ||
                  state.status == OtherAppsStatus.initial) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              if (state.status == OtherAppsStatus.error) {
                return Center(
                  child: CommonTextWidget(
                    text:
                        state.errorMessage ??
                        AppStrings.txtSomethingWentWrong.getString(context),
                    textStyle: size14TextStyle(
                      textColor: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              if (state.apps.isEmpty) {
                return Center(
                  child: CommonTextWidget(
                    text: AppStrings.txtNoDataFound.getString(context),
                    textStyle: size14TextStyle(
                      textColor: AppColors.greyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              final filteredApps = state.apps
                  .where((app) => app.isAndroid == true)
                  .toList();
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: filteredApps.length,
                itemBuilder: (context, index) {
                  final app = filteredApps[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        CommonFunction.launchUrlLink(app.appLink);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightPrimaryColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            CommonImage(
                              assetName: app.appLogo,
                              width: 56,
                              height: 56,
                              borderRadius: 12,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CommonTextWidget(
                                    text: app.appName,
                                    textStyle: size16TextStyle(
                                      textColor: AppColors.whiteColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    height: 1.2,
                                  ),
                                  CommonTextWidget(
                                    text: AppStrings.txtOpenInPlayStore.getString(
                                      context,
                                    ),
                                    textStyle: size12TextStyle(
                                      textColor: AppColors.greyColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    height: 1.2,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.open_in_new_rounded,
                              color: AppColors.whiteColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BlocProvider(
        create: (context) => BannerAdBloc(),
        child: BannerAdWidget(adId: AppAdIdString.otherAppBannerAd),
      ),
    );
  }
}
