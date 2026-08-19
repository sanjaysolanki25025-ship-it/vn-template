import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:vn_template/core/utils/common_functions.dart';

class MaintenanceView extends StatefulWidget {
  const MaintenanceView({super.key});

  @override
  State<MaintenanceView> createState() => _MaintenanceViewState();
}

class _MaintenanceViewState extends State<MaintenanceView> {
  final remoteConfig = FirebaseRemoteConfig.instance;
  late final String isMaintenance = remoteConfig.getString("maintenanceLink");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SBH10(),
            CommonImage(assetName: AppImagesString.imgMaintenance, height: 200, width: 200),
            CommonTextWidget(
              text: AppStrings.txtAppUnderMaintenance,
              textStyle: size24TextStyle(fontWeight: FontWeight.w800, textColor: AppColors.whiteColor),
            ),
            SBH10(),
            CommonTextWidget(
              text: AppStrings.txtWeAreImprovingThingsForYou,
              textStyle: size18TextStyle(fontWeight: FontWeight.w600, textColor: AppColors.greyColor),
            ),
            SBH5(),
            CommonButton(
              text: isMaintenance.isEmpty ? AppStrings.txtTryAgainLater : AppStrings.txtExploreNow,
              onTap: () {
                if (isMaintenance.isEmpty) {
                  SystemNavigator.pop();
                } else {
                  CommonFunction.launchUrlLink(isMaintenance);
                }
              },
            ),
            BlocProvider(
              create: (context) => NativeAdBloc(),
              child: NativeAdView(isSmallAd: true, adId: AppAdIdString.maintenanceNativeAd, isSplash: true),
            ),
          ],
        ),
      ),
    );
  }
}
