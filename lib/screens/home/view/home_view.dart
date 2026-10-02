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
import 'package:vn_template/common_widgets/common_bottomsheet.dart';

import '../utils/reel_video_cache_manager.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _initializingIndices = {};
  late final PageController _pageController;
  int _currentIndex = 0;
  int _lastReelIndex = 0;
  int _reelScrollCount = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    AdHelper.precacheInterstitialAd(adId: AppAdIdString.homeReelsInterstitial);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(SetReelsPausedEvent(paused: false));
      context.read<HomeBloc>().add(FetchTemplateDataEvent());
    });
    InAppUpdateManager.checkForUpdate(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused ||
        lifecycle == AppLifecycleState.inactive) {
      _controllers[_currentIndex]?.pause();
    } else if (lifecycle == AppLifecycleState.resumed) {
      final reelsPaused = context.read<HomeBloc>().state.reelsPaused;
      if (!reelsPaused) {
        _controllers[_currentIndex]?.play();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _disposeAllControllers();
    _pageController.dispose();
    super.dispose();
  }

  void _disposeAllControllers() {
    for (final controller in _controllers.values) {
      controller.pause();
      controller.dispose();
    }
    _controllers.clear();
    _initializingIndices.clear();
  }

  String? _getVideoUrl(List<TemplateModel> templates, int index) {
    if (index >= 0 && index < templates.length) {
      final t = templates[index];
      if (t.hasValidVideo) {
        return (t.videoUrl ?? t.previewVideo)?.trim();
      }
    }
    return null;
  }

  /// Prune any controllers outside the tight [targetIndex - 1, targetIndex + 1] window
  /// to strictly manage RAM and free hardware decoders immediately.
  void _pruneControllers(int targetIndex) {
    final keysToRemove = _controllers.keys
        .where((i) => i < targetIndex - 1 || i > targetIndex + 1)
        .toList();

    for (final key in keysToRemove) {
      final controller = _controllers.remove(key);
      controller?.pause();
      controller?.dispose();
    }
  }

  /// Initializes a video controller for a given reel index.
  /// Uses disk cache if available (or starts background disk caching).
  Future<void> _initController(
    int index,
    String url,
    bool shouldAutoPlay,
  ) async {
    if (_isDisposed ||
        _controllers.containsKey(index) ||
        _initializingIndices.contains(index)) {
      return;
    }

    _initializingIndices.add(index);

    try {
      final controller =
          await ReelVideoCacheManager.instance.createController(url);

      if (_isDisposed ||
          !mounted ||
          index < _currentIndex - 1 ||
          index > _currentIndex + 1) {
        controller.dispose();
        return;
      }

      await controller.initialize();

      if (_isDisposed ||
          !mounted ||
          index < _currentIndex - 1 ||
          index > _currentIndex + 1) {
        controller.dispose();
        return;
      }

      controller.setLooping(true);
      _controllers[index] = controller;

      final reelsPaused = context.read<HomeBloc>().state.reelsPaused;
      if (index == _currentIndex && shouldAutoPlay && !reelsPaused) {
        await controller.play();
      } else {
        await controller.pause();
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error initializing reel video at index $index: $e");
    } finally {
      _initializingIndices.remove(index);
    }
  }

  /// Manages video controllers with an ultra-low RAM sliding window:
  /// - Holds at most 3 controllers: [targetIndex - 1, targetIndex, targetIndex + 1]
  /// - Preloads targetIndex + 1 into memory (initialized and paused at 0)
  /// - Pre-caches targetIndex + 2 to disk ONLY (0 extra RAM!)
  /// - Disposes all controllers outside the window immediately
  void _syncControllers(
    List<TemplateModel> templates,
    int targetIndex,
    bool reelsPaused,
  ) {
    if (templates.isEmpty || _isDisposed) return;

    _currentIndex = targetIndex;

    // 1. Immediately prune controllers outside window to conserve RAM
    _pruneControllers(targetIndex);

    // 2. Play active video or initialize it
    final currentController = _controllers[targetIndex];
    if (currentController != null && currentController.value.isInitialized) {
      if (!reelsPaused) {
        if (!currentController.value.isPlaying) {
          currentController.play();
        }
      } else {
        if (currentController.value.isPlaying) {
          currentController.pause();
        }
      }
    } else {
      final currentUrl = _getVideoUrl(templates, targetIndex);
      if (currentUrl != null) {
        _initController(targetIndex, currentUrl, true);
      }
    }

    // 3. Pause previous video if present
    if (targetIndex > 0) {
      _controllers[targetIndex - 1]?.pause();
    }

    // 4. Preload next video controller (targetIndex + 1)
    final nextIndex = targetIndex + 1;
    if (nextIndex < templates.length) {
      final nextUrl = _getVideoUrl(templates, nextIndex);
      if (nextUrl != null) {
        ReelVideoCacheManager.instance.preCacheVideoToDisk(nextUrl);
        if (!_controllers.containsKey(nextIndex)) {
          _initController(nextIndex, nextUrl, false);
        }
      }
    }

    // 5. Pre-cache next-next video to disk ONLY (zero RAM cost!)
    final nextNextIndex = targetIndex + 2;
    if (nextNextIndex < templates.length) {
      final nextNextUrl = _getVideoUrl(templates, nextNextIndex);
      if (nextNextUrl != null) {
        ReelVideoCacheManager.instance.preCacheVideoToDisk(nextNextUrl);
      }
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
                  previous.status != current.status ||
                  previous.templateList != current.templateList ||
                  previous.reelsPaused != current.reelsPaused,
              listener: (context, state) {
                // Keep controllers in sync when template list arrives or updates
                if (state.templateList != null && state.templateList!.isNotEmpty) {
                  _syncControllers(
                    state.templateList!,
                    _currentIndex,
                    state.reelsPaused,
                  );
                }

                // If reelsPaused toggled
                if (state.reelsPaused) {
                  _controllers[_currentIndex]?.pause();
                } else {
                  final activeController = _controllers[_currentIndex];
                  if (activeController != null && activeController.value.isInitialized) {
                    if (!activeController.value.isPlaying) {
                      activeController.play();
                    }
                  }
                }

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
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: templates.length,
                    onPageChanged: (index) {
                      final homeBloc = context.read<HomeBloc>();
                      homeBloc.add(ChangeIndexEvent(index: index));

                      // Instant playback & tight sliding-window preloading
                      _syncControllers(templates, index, state.reelsPaused);

                      // Show interstitial ad every 4 reels scrolled down
                      if (index > _lastReelIndex) {
                        _reelScrollCount++;

                        if (_reelScrollCount % 4 == 0 &&
                            AdHelper.isInterstitialReady &&
                            state.isAdFlowRunning == false) {
                          homeBloc.add(
                            SetAdFlowStatusEvent(
                              isAdFlowRunning: true,
                              scrollLocked: false,
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
                      final controller = _controllers[index];
                      return ReelItemWidget(
                        template: template,
                        controller: controller,
                        isActive: index == _currentIndex,
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
                            int taps = AppPreferences().getInt(AppPreferences.categoryOnTap) ?? 0;
                            taps++;
                            AppPreferences().setInt(AppPreferences.categoryOnTap, taps);

                            _disposeAllControllers();
                            _currentIndex = 0;
                            _lastReelIndex = 0;
                            _reelScrollCount = 0;

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
