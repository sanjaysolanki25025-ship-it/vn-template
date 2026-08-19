import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/view/banner_ad_widget.dart';
import 'package:vn_template/data/helper/ad_helper.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/common_widgets/common_app_bar.dart';
import 'package:vn_template/common_widgets/common_button.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/common_widgets/common_bottomsheet.dart';
import 'package:vn_template/common_widgets/common_action_button.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/constant/app_image_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/routes/app_route_string.dart';
import 'package:vn_template/screens/discover/bloc/discover_bloc.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:vn_template/common_widgets/common_dialog.dart';
import 'package:vn_template/data/models/template_model.dart';

import '../../../common_widgets/shimmer/discover_shimmer..dart';
import 'package:vn_template/screens/discover/widgets/discover_template_card.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  @override
  void initState() {
    super.initState();
    context.read<DiscoverBloc>().add(FetchDiscoverDataEvent());
  }

  void _onOpenDinoGame(BuildContext context) {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    if (totalCoin < 5) {
      CommonBottomSheet.showCommonBottomSheet(
        adId: AppAdIdString.discoverBottomSheetNativeAd,
        context: context,
        firstButtonText: AppStrings.txtWatchAd.getString(context),
        title: AppStrings.txtNotEnoughCoinsWatchAnAdToPlay.getString(context),
        firstButtonOnTap: () {
          Navigator.of(context).pop();
          context.read<DiscoverBloc>().add(LoadDiscoverRewardADEvent());
          AdHelper.showRewardedAd(
            adUnitId: AppAdIdString.dinoGameRestart,
            onRewardEarned: () {
              context.read<DiscoverBloc>().add(LoadedDiscoverRewardADEvent());
              context.read<DiscoverBloc>().add(
                StoreDiscoverCoinEvent(coins: 2),
              );
            },
            onComplete: () {
              context.push(AppRoutesString.dinoView).then((_) {
                if (context.mounted) {
                  context.read<DiscoverBloc>().add(ResetDiscoverStatusEvent());
                }
              });
            },
            onAdFailed: () {
              context.read<DiscoverBloc>().add(LoadedDiscoverRewardADEvent());
            },
          );
        },
      );
    } else {
      CommonBottomSheet.showCommonBottomSheet(
        adId: AppAdIdString.discoverBottomSheetNativeAd,
        context: context,
        firstButtonText:
            "🔓 ${AppStrings.txtFiveLetter.getString(context)} ${AppStrings.txtCoins.getString(context)}",
        secondButtonText: AppStrings.txtWatchAd.getString(context),
        title: AppStrings.txtPlayGameReward.getString(context),
        secondButtonOnTap: () {
          Navigator.of(context).pop();
          context.read<DiscoverBloc>().add(LoadDiscoverRewardADEvent());
          AdHelper.showRewardedAd(
            adUnitId: AppAdIdString.dinoGameRestart,
            onRewardEarned: () {
              context.read<DiscoverBloc>().add(LoadedDiscoverRewardADEvent());
              context.read<DiscoverBloc>().add(
                StoreDiscoverCoinEvent(coins: 2),
              );
            },
            onComplete: () {
              context.push(AppRoutesString.dinoView).then((_) {
                if (context.mounted) {
                  context.read<DiscoverBloc>().add(ResetDiscoverStatusEvent());
                }
              });
            },
            onAdFailed: () {
              context.read<DiscoverBloc>().add(LoadedDiscoverRewardADEvent());
            },
          );
        },
        firstButtonOnTap: () {
          context.pop();
          context.read<DiscoverBloc>().add(PlayDiscoverDinoGameEvent());
          context.push(AppRoutesString.dinoView).then((_) {
            if (context.mounted) {
              context.read<DiscoverBloc>().add(ResetDiscoverStatusEvent());
            }
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CommonAppBar(
          title: AppStrings.txtDiscover.getString(context),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: CommonActionButton(
                assetPath: AppImagesString.imgDino,
                onTap: () => _onOpenDinoGame(context),
                imageSize: 45,
                removeDecoration: true,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
      body: BlocListener<DiscoverBloc, DiscoverState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == DiscoverStatus.rewardAdLoading) {
            CommonDialog.loaderDialog(context: context);
          } else if (state.status == DiscoverStatus.rewardAdLoaded) {
            CommonDialog.closeDialog(context: context);
          }
        },
        child: Column(
          children: [
            _buildCategoryList(),
            const SBH5(),
            Expanded(child: _buildTemplateContent()),
          ],
        ),
      ),
      bottomNavigationBar: BlocProvider(
        create: (context) => BannerAdBloc(),
        child: BannerAdWidget(adId: AppAdIdString.discoverBannerAd),
      ),
    );
  }

  Widget _buildCategoryList() {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      buildWhen: (previous, current) =>
          previous.selectedCategoryIndex != current.selectedCategoryIndex ||
          previous.categories != current.categories,
      builder: (context, state) {
        return SizedBox(
          height: 32,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: state.categories.length,
            separatorBuilder: (_, __) => const SBW10(),
            itemBuilder: (context, index) {
              final isSelected = state.selectedCategoryIndex == index;
              final categoryItem = state.categories[index];

              return GestureDetector(
                onTap: () {
                  if (state.selectedCategoryIndex == index) return;
                  int taps =
                      AppPreferences().getInt(AppPreferences.categoryOnTap) ??
                      0;
                  taps++;
                  AppPreferences().setInt(AppPreferences.categoryOnTap, taps);
                  context.read<DiscoverBloc>().add(
                    SelectCategoryEvent(categoryIndex: index),
                  );

                  final showAd = taps % 3 == 0;
                  if (showAd) {
                    AdHelper.instantShowInterstitialAdt(
                      adUnitId: AppAdIdString.categoryOnTapInterstitialAd,
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentColor
                        : AppColors.secondaryColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: CommonTextWidget(
                      text: categoryItem.categoryName,
                      textStyle: size12TextStyle(
                        textColor: isSelected
                            ? AppColors.primaryColor
                            : AppColors.whiteColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTemplateContent() {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      builder: (context, state) {
        if (state.status == DiscoverStatus.loading && state.templates.isEmpty) {
          return const DiscoverShimmer(isGridView: true);
        }

        if (state.status == DiscoverStatus.error && state.templates.isEmpty) {
          return Center(
            child: CommonTextWidget(
              text:
                  state.errorMessage ??
                  AppStrings.txtSomethingWentWrong.getString(context),
              textStyle: size16TextStyle(
                textColor: AppColors.whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        final templates = state.templates;
        if (templates.isEmpty) {
          return Center(
            child: CommonTextWidget(
              text: AppStrings.txtNoTemplatesFound.getString(context),
              textStyle: size16TextStyle(
                textColor: AppColors.whiteColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        final List<List<TemplateModel>> chunks = [];
        for (var i = 0; i < templates.length; i += 4) {
          chunks.add(
            templates.sublist(
              i,
              i + 4 > templates.length ? templates.length : i + 4,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              ...chunks.asMap().entries.map((entry) {
                final chunk = entry.value;

                return Column(
                  children: [
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: chunk.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemBuilder: (context, index) {
                        final item = chunk[index];
                        return DiscoverTemplateCard(item: item);
                      },
                    ),
                    if (chunk.length == 4) ...[
                      const SBH10(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: BlocProvider(
                          create: (context) => NativeAdBloc(),
                          child: NativeAdView(
                            adId: AppAdIdString.discoverNativeAd,
                          ),
                        ),
                      ),
                      const SBH10(),
                    ] else ...[
                      const SBH10(),
                    ],
                  ],
                );
              }),

              // Load More Button section
              if (state.hasMore) ...[
                const SBH20(),
                if (state.isLoadingMore)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.accentColor,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: CommonButton(
                      text: AppStrings.txtLoadMore.getString(context),
                      onTap: () {
                        context.read<DiscoverBloc>().add(
                          LoadMoreTemplatesEvent(),
                        );
                        int taps =
                            AppPreferences().getInt(
                              AppPreferences.loadMoreOnTap,
                            ) ??
                            0;
                        taps++;
                        AppPreferences().setInt(
                          AppPreferences.loadMoreOnTap,
                          taps,
                        );

                        if (taps % 2 == 0) {
                          if (!AdHelper.isLoadMoreAdLoadingOrShowing) {
                            AdHelper.instantShowInterstitialAdt(
                              adUnitId: AppAdIdString.loadMoreInterstitialAd,
                            );
                          }
                        }
                      },
                    ),
                  ),
                const SBH20(),
              ] else ...[
                const SBH20(),
              ],
            ],
          ),
        );
      },
    );
  }
}
