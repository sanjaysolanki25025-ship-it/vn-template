import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/view/banner_ad_widget.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/common_widgets/shimmer/discover_shimmer..dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/data/helper/ad_helper.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/routes/app_route_string.dart';
import 'package:vn_template/screens/favourite/bloc/favourite_bloc.dart';
import 'package:vn_template/screens/favourite/widgets/favourite_template_card.dart';
import 'package:vn_template/common_widgets/common_app_bar.dart';
import 'package:vn_template/common_widgets/common_action_button.dart';
import 'package:vn_template/common_widgets/common_bottomsheet.dart';
import 'package:vn_template/common_widgets/common_dialog.dart';
import 'package:vn_template/core/utils/native_ad_manager.dart';
import 'package:vn_template/core/constant/app_image_string.dart';

class FavouriteView extends StatefulWidget {
  const FavouriteView({super.key});

  @override
  State<FavouriteView> createState() => _FavouriteViewState();
}

class _FavouriteViewState extends State<FavouriteView> {
  @override
  void initState() {
    super.initState();
    context.read<FavouriteBloc>().add(LoadFavouritesEvent());
  }

  void _onOpenDinoGame(BuildContext context) async {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;

    CommonDialog.loaderDialog(context: context);
    NativeAdManager().preCacheAd(AppAdIdString.favouriteBottomNativeAd);
    await Future.delayed(const Duration(seconds: 2));
    
    if (!context.mounted) return;
    CommonDialog.closeDialog(context: context);

    if (totalCoin < 5) {
      CommonBottomSheet.showCommonBottomSheet(
        adId: AppAdIdString.favouriteBottomNativeAd,
        context: context,
        firstButtonText: AppStrings.txtWatchAd.getString(context),
        title: AppStrings.txtNotEnoughCoinsWatchAnAdToPlay.getString(context),
        firstButtonOnTap: () {
          Navigator.of(context).pop();
          context.read<FavouriteBloc>().add(LoadFavouriteRewardADEvent());
          AdHelper.showRewardedAd(
            adUnitId: AppAdIdString.dinoGameRestart,
            onRewardEarned: () {
              context.read<FavouriteBloc>().add(LoadedFavouriteRewardADEvent());
              context.read<FavouriteBloc>().add(
                StoreFavouriteCoinEvent(coins: 2),
              );
            },
            onComplete: () {
              context.push(AppRoutesString.dinoView).then((_) {
                if (context.mounted) {
                  context.read<FavouriteBloc>().add(
                    ResetFavouriteStatusEvent(),
                  );
                }
              });
            },
            onAdFailed: () {
              context.read<FavouriteBloc>().add(LoadedFavouriteRewardADEvent());
            },
          );
        },
      );
    } else {
      CommonBottomSheet.showCommonBottomSheet(
        adId: AppAdIdString.favouriteBottomNativeAd,
        context: context,
        firstButtonText:
            "🔓 ${AppStrings.txtFiveLetter.getString(context)} ${AppStrings.txtCoins.getString(context)}",
        secondButtonText: AppStrings.txtWatchAd.getString(context),
        title: AppStrings.txtPlayGameReward.getString(context),
        secondButtonOnTap: () {
          Navigator.of(context).pop();
          context.read<FavouriteBloc>().add(LoadFavouriteRewardADEvent());
          AdHelper.showRewardedAd(
            adUnitId: AppAdIdString.dinoGameRestart,
            onRewardEarned: () {
              context.read<FavouriteBloc>().add(LoadedFavouriteRewardADEvent());
              context.read<FavouriteBloc>().add(
                StoreFavouriteCoinEvent(coins: 2),
              );
            },
            onComplete: () {
              context.push(AppRoutesString.dinoView).then((_) {
                if (context.mounted) {
                  context.read<FavouriteBloc>().add(
                    ResetFavouriteStatusEvent(),
                  );
                }
              });
            },
            onAdFailed: () {
              context.read<FavouriteBloc>().add(LoadedFavouriteRewardADEvent());
            },
          );
        },
        firstButtonOnTap: () {
          context.pop();
          context.read<FavouriteBloc>().add(PlayFavouriteDinoGameEvent());
          context.push(AppRoutesString.dinoView).then((_) {
            if (context.mounted) {
              context.read<FavouriteBloc>().add(ResetFavouriteStatusEvent());
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
          title: AppStrings.txtFavourite.getString(context),
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
      body: BlocListener<FavouriteBloc, FavouriteState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == FavouriteStatus.rewardAdLoading) {
            CommonDialog.loaderDialog(context: context);
          } else if (state.status == FavouriteStatus.rewardAdLoaded) {
            CommonDialog.closeDialog(context: context);
          }
        },
        child: BlocBuilder<FavouriteBloc, FavouriteState>(
          builder: (context, state) {
            if (state.status == FavouriteStatus.noInternet) {
              return Center(
                child: Column(
                  children: [
                    CommonTextWidget(
                      text: AppStrings.txtNoInternetConnection.getString(
                        context,
                      ),
                      textStyle: size16TextStyle(
                        textColor: AppColors.whiteColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    BlocProvider(
                      create: (context) => NativeAdBloc(),
                      child: NativeAdView(
                        adId: AppAdIdString.noDataFoundNativeAd,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state.status == FavouriteStatus.loading ||
                state.status == FavouriteStatus.initial) {
              return const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: DiscoverShimmer(isGridView: true),
              );
            }

            if (state.status == FavouriteStatus.error) {
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

            final filteredList = state.filteredFavourites;

            return Column(
              children: [
                const SBH10(),
                _buildCategoryList(state),
                const SBH10(),
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CommonTextWidget(
                                text: AppStrings.txtNoTemplatesFound.getString(
                                  context,
                                ),
                                textStyle: size16TextStyle(
                                  textColor: AppColors.whiteColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              BlocProvider(
                                create: (context) => NativeAdBloc(),
                                child: NativeAdView(
                                  adId: AppAdIdString.noDataFoundNativeAd,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              children: [
                                for (
                                  int i = 0, row = 0;
                                  i < filteredList.length;
                                  i += 2, row++
                                ) ...[
                                  Row(
                                    children: [
                                      // First Item
                                      Expanded(
                                        child: FavouriteTemplateCard(
                                          item: filteredList[i],
                                        ),
                                      ),
                                      SBW10(),
                                      // Second Item
                                      if (i + 1 < filteredList.length)
                                        Expanded(
                                          child: FavouriteTemplateCard(
                                            item: filteredList[i + 1],
                                          ),
                                        )
                                      else
                                        const Spacer(),
                                    ],
                                  ),
                                  SBH2(),
                                  // Native Ad after each row
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    child: BlocProvider(
                                      create: (_) => NativeAdBloc(),
                                      child: NativeAdView(
                                        adId: AppAdIdString.favouriteNativeAd,
                                      ),
                                    ),
                                  ),
                                  (AppPreferences().getBool(
                                            AppPreferences.subscriptionPlan,
                                          ) ??
                                          false)
                                      ? SizedBox()
                                      : SBH5(),
                                ],
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BlocProvider(
        create: (context) => BannerAdBloc(),
        child: BannerAdWidget(adId: AppAdIdString.favouriteBannerAd),
      ),
    );
  }

  Widget _buildCategoryList(FavouriteState state) {
    if (state.categories.isEmpty || state.favourites.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 32,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length,
        separatorBuilder: (_, __) => const SBW10(),
        itemBuilder: (context, index) {
          final isSelected = state.selectedCategoryIndex == index;
          final categoryName = state.categories[index];

          return GestureDetector(
            onTap: () {
              if (state.selectedCategoryIndex == index) return;
              int taps =
                  AppPreferences().getInt(AppPreferences.categoryOnTap) ?? 0;
              taps++;
              AppPreferences().setInt(AppPreferences.categoryOnTap, taps);
              context.read<FavouriteBloc>().add(
                SelectFavouriteCategoryEvent(categoryIndex: index),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentColor
                    : AppColors.secondaryColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: CommonTextWidget(
                  text: categoryName,
                  textStyle: size12TextStyle(
                    textColor: isSelected
                        ? AppColors.primaryColor
                        : AppColors.whiteColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
