import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readmore/readmore.dart';
import 'package:video_player/video_player.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/core/utils/common_functions.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/data/models/favourite_model.dart';
import 'package:vn_template/data/models/template_model.dart';
import 'package:vn_template/screens/home/bloc/home_bloc.dart';

import 'package:vn_template/screens/home/widgets/favourite_button_widget.dart';
import 'package:vn_template/screens/home/widgets/share_button_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:vn_template/common_widgets/common_action_button.dart';
import 'package:vn_template/common_widgets/common_bottomsheet.dart';
import 'package:vn_template/common_widgets/common_button.dart';
import 'package:vn_template/core/constant/app_image_string.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/common_widgets/common_dialog.dart';
import 'package:vn_template/core/utils/native_ad_manager.dart';
import 'package:vn_template/data/helper/ad_helper.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/routes/app_route_string.dart';

class ReelItemWidget extends StatelessWidget {
  final TemplateModel template;
  final VideoPlayerController? controller;
  final bool isActive;
  final int index;

  const ReelItemWidget({
    super.key,
    required this.template,
    required this.controller,
    required this.isActive,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      // Fallback layout when controller is not yet initialized or loaded
      return Stack(
        fit: StackFit.expand,
        children: [
          if (template.previewImage != null &&
              template.previewImage!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: template.previewImage!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: AppColors.whiteColor),
              ),
              errorWidget: (context, url, error) => const SizedBox(),
            ),
          const Center(
            child: CircularProgressIndicator(color: AppColors.whiteColor),
          ),
          _buildOverlay(),
          Positioned(
            bottom: 88,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (template.isFavourite) {
                      context.read<HomeBloc>().add(
                        RemoveFavouriteTemplateEvent(
                          index: index,
                          templateId: template.id ?? '',
                        ),
                      );
                    } else {
                      context.read<HomeBloc>().add(
                        AddFavouriteTemplateEvent(
                          index: index,
                          favouriteModel: FavouriteModel(
                            templateId: template.id ?? '',
                            description: template.description ?? '',
                            qrCode: template.qrCode ?? '',
                            category: template.category?.join(', ') ?? '',
                            language: template.language ?? '',
                            code: template.code ?? '',
                            clip: template.clip ?? '',
                            duration: template.duration ?? '',
                            createdAt: template.createdAt.toIso8601String(),
                            rand: template.rand,
                            coin: template.coin ?? 0,
                          ),
                        ),
                      );
                    }
                  },
                  child: FavouriteButtonWidget(
                    isFavourite: template.isFavourite,
                  ),
                ),
                const SBH10(),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    CommonFunction.shareApp();
                  },
                  child: const ShareButtonWidget(),
                ),
                const SBH10(),
                CommonActionButton(
                  assetPath: AppImagesString.imgDino,
                  onTap: () => _onOpenDinoGame(context),
                  imageSize: 45,
                  removeDecoration: true,
                  fit: BoxFit.fill,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: CommonButton(
              text: AppStrings.txtUseTemplate.getString(context),
              onTap: () {
                context.read<HomeBloc>().add(StartCreateFlowEvent(model: template));
              },
              suffixWidget: (template.coin ?? 0) > 0 && AppImagesString.imgPremium.isNotEmpty
                  ? Image.asset(
                      AppImagesString.imgPremium,
                      height: 20,
                      width: 20,
                    )
                  : null,
            ),
          ),
        ],
      );
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller!,
      builder: (context, value, child) {
        final isInitialized = value.isInitialized;
        final isBuffering = value.isBuffering || !isInitialized;
        final isPlaying = value.isPlaying;

        return Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: isInitialized ? value.aspectRatio : 9 / 16,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (template.previewImage != null &&
                        template.previewImage!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: template.previewImage!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.whiteColor,
                          ),
                        ),
                        errorWidget: (context, url, error) => const SizedBox(),
                      ),
                    if (isInitialized)
                      GestureDetector(
                        onTap: () {
                          final isPaused = context.read<HomeBloc>().state.reelsPaused;
                          context.read<HomeBloc>().add(SetReelsPausedEvent(paused: !isPaused));
                        },
                        child: VideoPlayer(controller!),
                      ),
                  ],
                ),
              ),
            ),

            // Centered Play Button when paused
            if (isInitialized && !isPlaying && !isBuffering)
              Center(
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      size: 45,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),

            // Show loading spinner on top of video when buffering
            if (isBuffering)
              const Center(
                child: CircularProgressIndicator(color: AppColors.whiteColor),
              ),

            _buildOverlay(),
            Positioned(
              bottom: 88,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (template.isFavourite) {
                        context.read<HomeBloc>().add(
                          RemoveFavouriteTemplateEvent(
                            index: index,
                            templateId: template.id ?? '',
                          ),
                        );
                      } else {
                        context.read<HomeBloc>().add(
                          AddFavouriteTemplateEvent(
                            index: index,
                            favouriteModel: FavouriteModel(
                              templateId: template.id ?? '',
                              description: template.description ?? '',
                              qrCode: template.qrCode ?? '',
                              category: template.category?.join(', ') ?? '',
                              language: template.language ?? '',
                              code: template.code ?? '',
                              clip: template.clip ?? '',
                              duration: template.duration ?? '',
                              createdAt: template.createdAt.toIso8601String(),
                              rand: template.rand,
                              coin: template.coin ?? 0,
                            ),
                          ),
                        );
                      }
                    },
                    child: FavouriteButtonWidget(
                      isFavourite: template.isFavourite,
                    ),
                  ),
                  const SBH10(),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      CommonFunction.shareApp();
                    },
                    child: const ShareButtonWidget(),
                  ),
                  const SBH10(),
                  CommonActionButton(
                    assetPath: AppImagesString.imgDino,
                    onTap: () => _onOpenDinoGame(context),
                    imageSize: 45,
                    removeDecoration: true,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: CommonButton(
                text: AppStrings.txtUseTemplate.getString(context),
                onTap: () {
                  context.read<HomeBloc>().add(StartCreateFlowEvent(model: template));
                },
                suffixWidget: (template.coin ?? 0) > 0 && AppImagesString.imgPremium.isNotEmpty
                    ? Image.asset(
                        AppImagesString.imgPremium,
                        height: 20,
                        width: 20,
                      )
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  void _onOpenDinoGame(BuildContext context) async {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    
    CommonDialog.loaderDialog(context: context);
    NativeAdManager().preCacheAd(AppAdIdString.homeBottomNativeAd);
    await Future.delayed(const Duration(seconds: 2));
    
    if (!context.mounted) return;
    CommonDialog.closeDialog(context: context);

    if (totalCoin < 5) {
      CommonBottomSheet.showCommonBottomSheet(
        adId: AppAdIdString.homeBottomNativeAd,
        context: context,
        firstButtonText: AppStrings.txtWatchAd.getString(context),
        title: AppStrings.txtNotEnoughCoinsWatchAnAdToPlay.getString(context),
        firstButtonOnTap: () {
          Navigator.of(context).pop();
          context.read<HomeBloc>().add(LoadRewardAD());
          AdHelper.showRewardedAd(
            adUnitId: AppAdIdString.dinoGameRestart,
            onRewardEarned: () {
              context.read<HomeBloc>().add(LoadedRewardAD());
              context.read<HomeBloc>().add(StoreCoinEvent());
            },
            onComplete: () {
              context.read<HomeBloc>().add(SetReelsPausedEvent(paused: true));
              context.push(AppRoutesString.dinoView).then((_) {
                if (context.mounted) {
                  context.read<HomeBloc>().add(ResetHomeStatus());
                  context.read<HomeBloc>().add(SetReelsPausedEvent(paused: false));
                }
              });
            },
            onAdFailed: () {
              context.read<HomeBloc>().add(LoadedRewardAD());
            },
          );
        },
      );
    } else {
      CommonBottomSheet.showCommonBottomSheet(
        adId: AppAdIdString.homeBottomNativeAd,
        context: context,
        firstButtonText: "🔓 ${AppStrings.txtFiveLetter.getString(context)} ${AppStrings.txtCoins.getString(context)}",
        secondButtonText: AppStrings.txtWatchAd.getString(context),
        title: AppStrings.txtPlayGameReward.getString(context),
        secondButtonOnTap: () {
          Navigator.of(context).pop();
          context.read<HomeBloc>().add(LoadRewardAD());
          AdHelper.showRewardedAd(
            adUnitId: AppAdIdString.dinoGameRestart,
            onRewardEarned: () {
              context.read<HomeBloc>().add(LoadedRewardAD());
              context.read<HomeBloc>().add(StoreCoinEvent());
            },
            onComplete: () {
              context.read<HomeBloc>().add(SetReelsPausedEvent(paused: true));
              context.push(AppRoutesString.dinoView).then((_) {
                if (context.mounted) {
                  context.read<HomeBloc>().add(ResetHomeStatus());
                  context.read<HomeBloc>().add(SetReelsPausedEvent(paused: false));
                }
              });
            },
            onAdFailed: () {
              context.read<HomeBloc>().add(LoadedRewardAD());
            },
          );
        },
        firstButtonOnTap: () {
          context.pop();
          context.read<HomeBloc>().add(PlayDinoGame());
          context.read<HomeBloc>().add(SetReelsPausedEvent(paused: true));
          context.push(AppRoutesString.dinoView).then((_) {
            if (context.mounted) {
              context.read<HomeBloc>().add(ResetHomeStatus());
              context.read<HomeBloc>().add(SetReelsPausedEvent(paused: false));
            }
          });
        },
      );
    }
  }

  Widget _buildOverlay() {
    final cleanedDescription = CommonFunction.cleanDescription(
      template.description,
    );

    return Positioned(
      left: 16,
      bottom: 88,
      right: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (template.title != null && template.title!.isNotEmpty) ...[
            CommonTextWidget(
              text: template.title!,
              textStyle: size18TextStyle(
                textColor: AppColors.whiteColor,
                fontWeight: FontWeight.bold,
              ),
              maxLine: 2,
            ),
            const SBH10(),
          ],

          // Highlighted Stats Row (Glassmorphic look)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.movie_outlined,
                      size: 14,
                      color: AppColors.whiteColor.withValues(alpha: 0.95),
                    ),
                    const SizedBox(width: 4),
                    CommonTextWidget(
                      text: template.clip ?? "0",
                      textStyle: size12TextStyle(
                        textColor: AppColors.whiteColor.withValues(alpha: 0.95),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CommonTextWidget(
                      text: '|',
                      textStyle: size12TextStyle(
                        textColor: AppColors.whiteColor.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.favorite_border,
                      size: 14,
                      color: AppColors.whiteColor.withValues(alpha: 0.95),
                    ),
                    const SizedBox(width: 4),
                    CommonTextWidget(
                      text: '${template.likes ?? 0}',
                      textStyle: size12TextStyle(
                        textColor: AppColors.whiteColor.withValues(alpha: 0.95),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CommonTextWidget(
                      text: '|',
                      textStyle: size12TextStyle(
                        textColor: AppColors.whiteColor.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.trending_up,
                      size: 14,
                      color: AppColors.whiteColor.withValues(alpha: 0.95),
                    ),
                    const SizedBox(width: 4),
                    CommonTextWidget(
                      text: '${template.usage ?? 0}',
                      textStyle: size12TextStyle(
                        textColor: AppColors.whiteColor.withValues(alpha: 0.95),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SBH10(),

          if (cleanedDescription.isNotEmpty)
            ReadMoreText(
              cleanedDescription,
              trimMode: TrimMode.Line,
              trimLines: 2,
              colorClickableText: AppColors.accentColor,
              trimCollapsedText: ' Show more',
              trimExpandedText: ' Show less',
              style: size14TextStyle(
                textColor: AppColors.whiteColor.withValues(alpha: 0.8),
              ),
              moreStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.accentColor,
              ),
              lessStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.accentColor,
              ),
            ),
        ],
      ),
    );
  }
}
