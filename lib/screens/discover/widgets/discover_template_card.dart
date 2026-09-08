import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_template/common_widgets/common_image.dart';
import 'package:vn_template/common_widgets/shimmer/common_container_shimmer.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_image_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/data/models/template_model.dart';
import 'package:vn_template/screens/discover/bloc/discover_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vn_template/routes/app_route_string.dart';
import 'package:vn_template/data/helper/ad_helper.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/common_widgets/common_dialog.dart';
import 'package:vn_template/core/utils/native_ad_manager.dart';

class DiscoverTemplateCard extends StatelessWidget {
  final TemplateModel item;

  const DiscoverTemplateCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isPremium = (item.coin ?? 0) > 0;
    final hasImage = item.previewImage != null && item.previewImage!.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        if (item.previewVideo == null || item.previewVideo!.isEmpty) return;
        
        CommonDialog.loaderDialog(context: context);
        NativeAdManager().preCacheAd(AppAdIdString.templateDetailNativeAd);
        await Future.delayed(const Duration(seconds: 2));
        if (!context.mounted) return;
        CommonDialog.closeDialog(context: context);

        final bool? result = await context.push<bool>(AppRoutesString.templateDetailView, extra: item);

        if (result == true) {
          final int backPressCount = (AppPreferences().getInt(AppPreferences.onBackPress) ?? 0) + 1;
          AppPreferences().setInt(AppPreferences.onBackPress, backPressCount);

          if (backPressCount >= 2) {
            AppPreferences().setInt(AppPreferences.onBackPress, 0);

            if (!AdHelper.isBackButtonAdLoadingOrShowing) {
              AdHelper.isBackButtonAdLoadingOrShowing = true;
              AdHelper.showInterstitialAd(
                adId: AppAdIdString.backButtonInterstitialAd,
                onAdClosed: () {
                  AdHelper.isBackButtonAdLoadingOrShowing = false;
                },
              );
            }
          }
        }
      },
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Preview Image
            Positioned.fill(
              child: hasImage
                  ? CommonImage(
                      fit: BoxFit.cover,
                      assetName: item.previewImage!,
                    )
                  : const CommonContainerShimmer(
                      height: double.infinity,
                      width: double.infinity,
                    ),
            ),

            // Bottom Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.blackColor.withValues(alpha: 0.0),
                      AppColors.blackColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Premium Badge Top Left
            if (isPremium)
              Positioned(
                top: 10,
                left: 10,
                child: CommonImage(
                  assetName: AppImagesString.imgPremium,
                  height: 28,
                  width: 28,
                ),
              ),

            // Favourite Icon Top Right
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  context
                      .read<DiscoverBloc>()
                      .add(ToggleFavouriteEvent(template: item));
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.blackColor.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.isFavourite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: item.isFavourite
                        ? AppColors.redColor
                        : AppColors.whiteColor,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Title at Bottom
            if (item.title != null && item.title!.isNotEmpty)
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: CommonTextWidget(
                  text: item.title!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textStyle: size14TextStyle(
                    textColor: AppColors.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
