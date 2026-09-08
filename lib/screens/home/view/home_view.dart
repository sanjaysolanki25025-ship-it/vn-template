import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:video_player/video_player.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/core/utils/in_app_update_manager.dart';
import 'package:vn_template/data/helper/ad_helper.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/data/models/template_model.dart';
import 'package:vn_template/routes/app_route_string.dart';
import 'package:vn_template/screens/home/bloc/home_bloc.dart';
import 'package:vn_template/screens/home/widgets/reel_item_widget.dart';
import 'package:vn_template/common_widgets/common_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:vn_template/core/utils/common_functions.dart';
import 'package:vn_template/common_widgets/common_bottomsheet.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final Map<String, VideoPlayerController> _videoCache = {};
  late final PageController _pageController;
  int _lastReelIndex = 0;
  int _reelScrollCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    AdHelper.precacheInterstitialAd(adId: AppAdIdString.homeReelsInterstitial);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(FetchTemplateDataEvent());
    });
    InAppUpdateManager.checkForUpdate(context);
  }

  @override
  void dispose() {
    for (final controller in _videoCache.values) {
      controller.dispose();
    }
    _videoCache.clear();
    _pageController.dispose();
    super.dispose();
  }

  void _manageVideoCache(
    List<TemplateModel> templates,
    int currentIndex,
    bool reelsPaused,
  ) {
    // 1. Determine target URLs to cache (current, previous, and next two)
    final Set<String> targetUrls = {};
    for (int i = currentIndex - 1; i <= currentIndex + 2; i++) {
      if (i >= 0 && i < templates.length) {
        final videoUrl = templates[i].previewVideo;
        if (videoUrl != null && videoUrl.isNotEmpty) {
          targetUrls.add(videoUrl);
        }
      }
    }

    // 2. Dispose of controllers not in target set
    final urlsToRemove = _videoCache.keys
        .where((url) => !targetUrls.contains(url))
        .toList();
    for (final url in urlsToRemove) {
      _videoCache[url]?.dispose();
      _videoCache.remove(url);
    }

    // 3. Initialize new controllers
    for (final url in targetUrls) {
      if (!_videoCache.containsKey(url)) {
        final controller = VideoPlayerController.networkUrl(Uri.parse(url));
        _videoCache[url] = controller;
        controller
            .initialize()
            .then((_) {
              controller.setLooping(true);
              // Play immediately if it's the active one and reels not paused
              if (mounted) {
                final activeIndex = context.read<HomeBloc>().state.currentIndex;
                final activeTemplates =
                    context.read<HomeBloc>().state.templateList ?? [];
                final activeReelsPaused = context
                    .read<HomeBloc>()
                    .state
                    .reelsPaused;
                if (activeIndex >= 0 && activeIndex < activeTemplates.length) {
                  if (activeTemplates[activeIndex].previewVideo == url &&
                      !activeReelsPaused) {
                    controller.play();
                  }
                }
              }
            })
            .catchError((e) {
              debugPrint("Pre-cache error: $e");
            });
      }
    }

    // 4. Play active video, pause others
    if (currentIndex >= 0 && currentIndex < templates.length) {
      final activeUrl = templates[currentIndex].previewVideo;
      _videoCache.forEach((url, controller) {
        if (controller.value.isInitialized) {
          if (url == activeUrl && !reelsPaused) {
            if (!controller.value.isPlaying) {
              controller.play();
            }
          } else {
            if (controller.value.isPlaying) {
              controller.pause();
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: BlocListener<HomeBloc, HomeState>(
              listenWhen: (previous, current) =>
                  previous.status != current.status,
              listener: (context, state) {
                final int userCoins =
                    AppPreferences().getInt(AppPreferences.coin) ?? 0;
                if (state.status == HomeStatus.rewardAdLoading) {
                  context.read<HomeBloc>().add(
                    SetReelsPausedEvent(paused: true),
                  );
                  CommonDialog.loaderDialog(context: context);
                } else if (state.status == HomeStatus.createLoading) {
                  CommonDialog.loaderDialog(context: context);
                } else if (state.status == HomeStatus.rewardAdLoaded ||
                    state.status == HomeStatus.rewardAdError) {
                  CommonDialog.closeDialog(context: context);
                } else if (state.status == HomeStatus.createLoaded) {
                  CommonDialog.closeDialog(context: context);
                  context.read<HomeBloc>().add(
                    SetReelsPausedEvent(paused: true),
                  );

                  // If subscribed, direct navigate to QR screen without showing bottom sheet or ads
                  if (AppPreferences().getBool(AppPreferences.subscriptionPlan) == true) {
                    if (state.model != null &&
                        state.model!.qrCode != null &&
                        state.model!.qrCode!.isNotEmpty) {
                      context.push(
                        AppRoutesString.qrCodeView,
                        extra: {
                          'qrLink': state.model?.qrCode ?? '',
                          'title': state.model?.title ?? '',
                        },
                      ).then((_) {
                        if (context.mounted) {
                          context.read<HomeBloc>().add(ResetHomeStatus());
                          context.read<HomeBloc>().add(
                            SetReelsPausedEvent(paused: false),
                          );
                        }
                      });
                    } else {
                      context.read<HomeBloc>().add(
                        UseVnAppEvent(qrCodeLink: state.model?.qrCode ?? ''),
                      );
                      context.read<HomeBloc>().add(ResetHomeStatus());
                      context.read<HomeBloc>().add(
                        SetReelsPausedEvent(paused: false),
                      );
                    }
                    return;
                  }

                  final template = state.model;
                  final isPremiumTemplate = (template?.coin ?? 0) > 0;
                  final int userCoins =
                      AppPreferences().getInt(AppPreferences.coin) ?? 0;
                  final int requiredCoins = template?.coin ?? 0;

                  String sheetTitle = AppStrings.txtUseTemplateInVnTitle
                      .getString(context);
                  if (isPremiumTemplate) {
                    if (userCoins < requiredCoins) {
                      sheetTitle = AppStrings.txtPremiumTemplateNeedCoins
                          .getString(context)
                          .replaceAll('{coins}', requiredCoins.toString());
                    } else {
                      sheetTitle = AppStrings.txtPremiumTemplateCoinsRequired
                          .getString(context)
                          .replaceAll('{coins}', requiredCoins.toString());
                    }
                  }

                  String firstBtnText = AppStrings.txtUseVnApp.getString(context);
                  String secondBtnText = AppStrings.txtDownloadQrCode.getString(context);

                  if (isPremiumTemplate) {
                    if (userCoins < requiredCoins) {
                      firstBtnText = AppStrings.txtPlayGame.getString(context);
                      secondBtnText = AppStrings.txtCancel.getString(context);
                    }
                  }

                  CommonBottomSheet.showCommonBottomSheet(
                    adId: AppAdIdString.homeBottomNativeAd,
                    context: context,
                    firstButtonText: firstBtnText,
                    secondButtonText: secondBtnText,
                    title: sheetTitle,
                    firstButtonOnTap: () {
                      if (AppPreferences().getBool(
                            AppPreferences.subscriptionPlan,
                          ) ==
                          true) {
                        context.pop();
                        context.read<HomeBloc>().add(
                          UseVnAppEvent(qrCodeLink: state.model?.qrCode ?? ''),
                        );
                        context.read<HomeBloc>().add(
                          SetReelsPausedEvent(paused: false),
                        );
                      } else {
                        if (isPremiumTemplate) {
                          if (userCoins < requiredCoins) {
                            context.pop();
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
                                context.read<HomeBloc>().add(SetReelsPausedEvent(paused: true));
                                context.push(AppRoutesString.dinoView).then((_) {
                                  if (context.mounted) {
                                    context.read<HomeBloc>().add(ResetHomeStatus());
                                    context.read<HomeBloc>().add(SetReelsPausedEvent(paused: false));
                                  }
                                });
                              },
                            );
                          } else {
                            final remainingCoins = userCoins - requiredCoins;
                            AppPreferences().setInt(AppPreferences.coin, remainingCoins < 0 ? 0 : remainingCoins);
                            context.pop();
                            CommonDialog.loaderDialog(context: context);
                            context.read<HomeBloc>().add(
                              UseVnAppEvent(qrCodeLink: state.model?.qrCode ?? ''),
                            );
                            Future.delayed(const Duration(milliseconds: 1500), () {
                              if (context.mounted) {
                                CommonDialog.closeDialog(context: context);
                              }
                            });
                          }
                        } else {
                          // Free template flow
                          context.pop();
                          context.read<HomeBloc>().add(LoadRewardAD());
                          AdHelper.showRewardedAd(
                            adUnitId: AppAdIdString.startCreatingRewardedAd,
                            onRewardEarned: () {
                              context.read<HomeBloc>().add(LoadedRewardAD());
                              context.read<HomeBloc>().add(StoreCoinEvent(coins: 2));
                            },
                            onComplete: () {
                              context.read<HomeBloc>().add(LoadedRewardAD());
                              CommonDialog.loaderDialog(context: context);
                              context.read<HomeBloc>().add(
                                UseVnAppEvent(qrCodeLink: state.model?.qrCode ?? ''),
                              );
                              Future.delayed(const Duration(milliseconds: 1500), () {
                                if (context.mounted) {
                                  CommonDialog.closeDialog(context: context);
                                }
                              });
                            },
                            onAdFailed: () {
                              context.read<HomeBloc>().add(LoadedRewardAD());
                              CommonDialog.loaderDialog(context: context);
                              context.read<HomeBloc>().add(
                                UseVnAppEvent(qrCodeLink: state.model?.qrCode ?? ''),
                              );
                              Future.delayed(const Duration(milliseconds: 1500), () {
                                if (context.mounted) {
                                  CommonDialog.closeDialog(context: context);
                                }
                              });
                            },
                          );
                        }
                      }
                    },
                    secondButtonOnTap: () {
                      context.read<HomeBloc>().add(
                        SetReelsPausedEvent(paused: true),
                      );
                      context.pop();
                      if (state.model != null &&
                          state.model!.qrCode != null &&
                          state.model!.qrCode!.isNotEmpty) {
                        if (AppPreferences().getBool(
                              AppPreferences.subscriptionPlan,
                            ) ==
                            true) {
                          // Subscribed user flow: direct navigation, no ads, no coin deduction
                          context.push(
                            AppRoutesString.qrCodeView,
                            extra: {
                              'qrLink': state.model?.qrCode ?? '',
                              'title': state.model?.title ?? '',
                            },
                          ).then((_) {
                            if (context.mounted) {
                              context.read<HomeBloc>().add(ResetHomeStatus());
                              context.read<HomeBloc>().add(
                                SetReelsPausedEvent(paused: false),
                              );
                            }
                          });
                        } else if (isPremiumTemplate) {
                          if (userCoins < requiredCoins) {
                            // Insufficient coins for premium template, unpause reels
                            context.read<HomeBloc>().add(
                              SetReelsPausedEvent(paused: false),
                            );
                            return;
                          } else {
                            // Premium template flow: deduct coins, no ad
                            final remainingCoins = userCoins - requiredCoins;
                            AppPreferences().setInt(
                              AppPreferences.coin,
                              remainingCoins < 0 ? 0 : remainingCoins,
                            );
                            context.push(
                              AppRoutesString.qrCodeView,
                              extra: {
                                'qrLink': state.model?.qrCode ?? '',
                                'title': state.model?.title ?? '',
                              },
                            ).then((_) {
                              if (context.mounted) {
                                context.read<HomeBloc>().add(ResetHomeStatus());
                                context.read<HomeBloc>().add(
                                  SetReelsPausedEvent(paused: false),
                                );
                              }
                            });
                          }
                        } else {
                          // Free template flow: show rewarded ad, store 2 coins
                          context.read<HomeBloc>().add(LoadRewardAD());
                          AdHelper.showRewardedAd(
                            adUnitId: AppAdIdString.startCreatingRewardedAd,
                            onRewardEarned: () {
                              context.read<HomeBloc>().add(LoadedRewardAD());
                              context.read<HomeBloc>().add(StoreCoinEvent(coins: 2));
                            },
                            onComplete: () {
                              context.read<HomeBloc>().add(LoadedRewardAD());
                              context.push(
                                AppRoutesString.qrCodeView,
                                extra: {
                                  'qrLink': state.model?.qrCode ?? '',
                                  'title': state.model?.title ?? '',
                                },
                              ).then((_) {
                                if (context.mounted) {
                                  context.read<HomeBloc>().add(ResetHomeStatus());
                                  context.read<HomeBloc>().add(
                                    SetReelsPausedEvent(paused: false),
                                  );
                                }
                              });
                            },
                            onAdFailed: () {
                              context.read<HomeBloc>().add(LoadedRewardAD());
                              context.push(
                                AppRoutesString.qrCodeView,
                                extra: {
                                  'qrLink': state.model?.qrCode ?? '',
                                  'title': state.model?.title ?? '',
                                },
                              ).then((_) {
                                if (context.mounted) {
                                  context.read<HomeBloc>().add(ResetHomeStatus());
                                  context.read<HomeBloc>().add(
                                    SetReelsPausedEvent(paused: false),
                                  );
                                }
                              });
                            },
                          );
                        }
                      }
                    },
                  ).then((_) {
                    if (context.mounted) {
                      context.read<HomeBloc>().add(ResetHomeStatus());
                      context.read<HomeBloc>().add(
                        SetReelsPausedEvent(paused: false),
                      );
                    }
                  });
                } else if (state.status == HomeStatus.downloadVNApp) {
                  CommonDialog.closeDialog(context: context);
                  context.read<HomeBloc>().add(
                    SetReelsPausedEvent(paused: true),
                  );
                  CommonBottomSheet.showCommonBottomSheet(
                    adId: AppAdIdString.homeBottomNativeAd,
                    context: context,
                    firstButtonText: AppStrings.txtDownload.getString(context),
                    secondButtonText: AppStrings.txtCancel.getString(context),
                    title: AppStrings.txtDownloadVNApp.getString(context),
                    firstButtonOnTap: () {
                      context.pop();
                      context.read<HomeBloc>().add(DownloadVnEvent());
                    },
                    secondButtonOnTap: () {
                      context.pop();
                    },
                  ).then((_) {
                    if (context.mounted) {
                      context.read<HomeBloc>().add(ResetHomeStatus());
                      context.read<HomeBloc>().add(
                        SetReelsPausedEvent(paused: false),
                      );
                    }
                  });
                }
              },
              child: BlocBuilder<HomeBloc, HomeState>(
                buildWhen: (previous, current) =>
                    previous.templateList != current.templateList ||
                    previous.status != current.status ||
                    previous.currentIndex != current.currentIndex ||
                    previous.reelsPaused != current.reelsPaused,
                builder: (context, state) {
                  final templates = state.templateList ?? [];

                  // Manage pre-caching for current viewport
                  _manageVideoCache(
                    templates,
                    state.currentIndex,
                    state.reelsPaused,
                  );

                  if (state.status == HomeStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.whiteColor,
                      ),
                    );
                  }

                  if (templates.isEmpty) {
                    return Center(
                      child: CommonTextWidget(
                        text: AppStrings.txtNoTemplatesFound.getString(context),
                        textStyle: size14TextStyle(
                          textColor: AppColors.whiteColor,
                        ),
                      ),
                    );
                  }

                  return PageView.builder(
                    controller: _pageController,
                    physics: (state.scrollLocked ?? false)
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: templates.length,
                    onPageChanged: (index) {
                      final homeBloc = context.read<HomeBloc>();
                      homeBloc.add(ChangeIndexEvent(index: index));

                      // Show interstitial ad every 3 reels scrolled down
                      if (index > _lastReelIndex) {
                        _reelScrollCount++;

                        if (_reelScrollCount % 3 == 0 &&
                            AdHelper.isInterstitialReady &&
                            state.isAdFlowRunning == false) {
                          homeBloc.add(
                            SetAdFlowStatusEvent(
                              isAdFlowRunning: true,
                              scrollLocked: true,
                            ),
                          );

                          /// ⏱ wait while reel plays
                          Future.delayed(
                            const Duration(milliseconds: 1800),
                            () {
                              if (!mounted) return;

                              try {
                                homeBloc.add(SetReelsPausedEvent(paused: true));

                                AdHelper.showInterstitialAd(
                                  adId: AppAdIdString.homeReelsInterstitial,
                                  onAdClosed: () {
                                    if (!mounted) return;
                                    homeBloc.add(
                                      SetAdFlowStatusEvent(
                                        isAdFlowRunning: false,
                                        scrollLocked: false,
                                      ),
                                    );
                                    homeBloc.add(
                                      SetReelsPausedEvent(paused: false),
                                    );
                                  },
                                );
                              } catch (_) {
                                homeBloc.add(
                                  SetAdFlowStatusEvent(
                                    isAdFlowRunning: false,
                                    scrollLocked: false,
                                  ),
                                );
                                AdHelper.precacheInterstitialAd(
                                  adId: AppAdIdString.homeReelsInterstitial,
                                );
                              }
                            },
                          );
                        }
                      }
                      _lastReelIndex = index;

                      if (index >= templates.length - 2) {
                        homeBloc.add(LoadMoreEvent());
                      }
                    },
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      final controller = _videoCache[template.previewVideo];
                      return ReelItemWidget(
                        template: template,
                        controller: controller,
                        isActive: index == state.currentIndex,
                        index: index,
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // 2. Top Layer: Floating Category List
          BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (previous, current) =>
                previous.allCategories != current.allCategories ||
                previous.selectedCategoryName != current.selectedCategoryName,
            builder: (context, state) {
              final categories = state.allCategories ?? [];
              final selectedCategory = state.selectedCategoryName ?? 'All';

              if (categories.isEmpty) return const SizedBox.shrink();

              return Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 0,
                right: 0,
                height: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected =
                          category.categoryName == selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            if (category.categoryName == selectedCategory) return;
                            
                            int taps = AppPreferences().getInt(AppPreferences.categoryOnTap) ?? 0;
                            taps++;
                            AppPreferences().setInt(AppPreferences.categoryOnTap, taps);

                            final homeBloc = context.read<HomeBloc>();
                            homeBloc.add(
                              SelectCategoryEvent(
                                categoryName: category.categoryName,
                              ),
                            );
                            if (_pageController.hasClients) {
                              _pageController.jumpToPage(0);
                            }
                            homeBloc.add(
                              SetAdFlowStatusEvent(
                                isAdFlowRunning: false,
                                scrollLocked: false,
                              ),
                            );
                            _lastReelIndex = 0;
                            _reelScrollCount = 0;

                            final showAd = taps % 3 == 0;
                            if (showAd) {
                              AdHelper.instantShowInterstitialAdt(
                                adUnitId: AppAdIdString.categoryOnTapInterstitialAd,
                                onAdShowed: () {
                                  homeBloc.add(SetReelsPausedEvent(paused: true));
                                },
                                onAdClosed: () {
                                  homeBloc.add(SetReelsPausedEvent(paused: false));
                                },
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentColor
                                  : AppColors.whiteColor.withValues(
                                      alpha: 0.15,
                                    ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            alignment: Alignment.center,
                            child: CommonTextWidget(
                              text: category.categoryName,
                              textStyle: size14TextStyle(
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
