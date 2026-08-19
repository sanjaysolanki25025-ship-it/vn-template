import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/view/banner_ad_widget.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:vn_template/common_widgets/common_app_bar.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/data/models/template_model.dart';
import 'package:vn_template/screens/template_detail/bloc/template_detail_bloc.dart';
import 'package:vn_template/screens/template_detail/widgets/template_stats_widget.dart';
import 'package:vn_template/screens/template_detail/widgets/template_video_player.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:go_router/go_router.dart';
import 'package:vn_template/data/helper/ad_helper.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/routes/app_route_string.dart';
import 'package:vn_template/common_widgets/common_dialog.dart';
import 'package:vn_template/common_widgets/common_bottomsheet.dart';
import 'package:vn_template/common_widgets/common_button.dart';
import 'package:vn_template/core/constant/app_image_string.dart';

class TemplateDetailView extends StatefulWidget {
  final TemplateModel template;

  const TemplateDetailView({super.key, required this.template});

  @override
  State<TemplateDetailView> createState() => _TemplateDetailViewState();
}

class _TemplateDetailViewState extends State<TemplateDetailView> {
  late TemplateDetailBloc _templateDetailBloc;

  @override
  void initState() {
    super.initState();
    _templateDetailBloc = context.read<TemplateDetailBloc>();
    if (widget.template.previewVideo != null &&
        widget.template.previewVideo!.isNotEmpty) {
      final String videoUrl = widget.template.previewVideo!;
      final lowerUrl = videoUrl.toLowerCase();
      final isImage =
          lowerUrl.contains('.jpg') ||
          lowerUrl.contains('.jpeg') ||
          lowerUrl.contains('.png') ||
          lowerUrl.contains('.gif') ||
          lowerUrl.contains('.webp');

      if (!isImage) {
        _templateDetailBloc.add(InitVideoPlayerEvent(videoUrl: videoUrl));
      }
    }
  }

  @override
  void dispose() {
    _templateDetailBloc.add(DisposeVideoPlayerEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.pop(true);
      },
      child: BlocListener<TemplateDetailBloc, TemplateDetailState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          final int userCoins =
              AppPreferences().getInt(AppPreferences.coin) ?? 0;
          if (state.status == TemplateDetailStatus.rewardAdLoading) {
            _templateDetailBloc.state.videoPlayerController?.pause();
            CommonDialog.loaderDialog(context: context);
          } else if (state.status == TemplateDetailStatus.createLoading) {
            CommonDialog.loaderDialog(context: context);
          } else if (state.status == TemplateDetailStatus.rewardAdLoaded ||
              state.status == TemplateDetailStatus.rewardAdError) {
            CommonDialog.closeDialog(context: context);
          } else if (state.status == TemplateDetailStatus.createLoaded) {
            CommonDialog.closeDialog(context: context);
            _templateDetailBloc.state.videoPlayerController?.pause();

            if (AppPreferences().getBool(AppPreferences.subscriptionPlan) ==
                true) {
              if (state.model != null &&
                  state.model!.qrCode != null &&
                  state.model!.qrCode!.isNotEmpty) {
                context
                    .push(
                      AppRoutesString.qrCodeView,
                      extra: {
                        'qrLink': state.model?.qrCode ?? '',
                        'title': state.model?.title ?? '',
                      },
                    )
                    .then((_) {
                      if (context.mounted) {
                        _templateDetailBloc.add(ResetDetailStatus());
                        _templateDetailBloc.state.videoPlayerController?.play();
                      }
                    });
              } else {
                _templateDetailBloc.add(
                  UseVnAppEvent(qrCodeLink: state.model?.qrCode ?? ''),
                );
                _templateDetailBloc.add(ResetDetailStatus());
                _templateDetailBloc.state.videoPlayerController?.play();
              }
              return;
            }

            final template = state.model ?? widget.template;
            final isPremiumTemplate = (template.coin ?? 0) > 0;
            final int requiredCoins = template.coin ?? 0;

            String sheetTitle = AppStrings.txtUseTemplateInVnTitle.getString(
              context,
            );
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
            String secondBtnText = AppStrings.txtDownloadQrCode.getString(
              context,
            );

            if (isPremiumTemplate) {
              if (userCoins < requiredCoins) {
                firstBtnText = AppStrings.txtPlayGame.getString(context);
                secondBtnText = AppStrings.txtCancel.getString(context);
              }
            }

            CommonBottomSheet.showCommonBottomSheet(
              adId: AppAdIdString.templateDetailNativeAd,
              context: context,
              firstButtonText: firstBtnText,
              secondButtonText: secondBtnText,
              title: sheetTitle,
              firstButtonOnTap: () {
                if (AppPreferences().getBool(AppPreferences.subscriptionPlan) ==
                    true) {
                  context.pop(true);
                  _templateDetailBloc.add(
                    UseVnAppEvent(qrCodeLink: template.qrCode ?? ''),
                  );
                  _templateDetailBloc.state.videoPlayerController?.play();
                } else {
                  if (isPremiumTemplate) {
                    if (userCoins < requiredCoins) {
                      context.pop(true);
                      _templateDetailBloc.add(LoadRewardAD());
                      AdHelper.showRewardedAd(
                        adUnitId: AppAdIdString.dinoGameRestart,
                        onRewardEarned: () {
                          _templateDetailBloc.add(StoreCoinEvent());
                        },
                        onComplete: () {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (context.mounted) {
                              context.push(AppRoutesString.dinoView).then((_) {
                                if (context.mounted) {
                                  _templateDetailBloc.add(ResetDetailStatus());
                                  _templateDetailBloc
                                      .state
                                      .videoPlayerController
                                      ?.play();
                                }
                              });
                            }
                          });
                        },
                        onAdFailed: () {
                          _templateDetailBloc.add(LoadedRewardAD());
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (context.mounted) {
                              context.push(AppRoutesString.dinoView).then((_) {
                                if (context.mounted) {
                                  _templateDetailBloc.add(ResetDetailStatus());
                                  _templateDetailBloc
                                      .state
                                      .videoPlayerController
                                      ?.play();
                                }
                              });
                            }
                          });
                        },
                      );
                    } else {
                      final remainingCoins = userCoins - requiredCoins;
                      AppPreferences().setInt(
                        AppPreferences.coin,
                        remainingCoins < 0 ? 0 : remainingCoins,
                      );
                      context.pop(true);
                      CommonDialog.loaderDialog(context: context);
                      _templateDetailBloc.add(
                        UseVnAppEvent(qrCodeLink: template.qrCode ?? ''),
                      );
                      Future.delayed(const Duration(milliseconds: 1500), () {
                        if (context.mounted) {
                          CommonDialog.closeDialog(context: context);
                        }
                      });
                    }
                  } else {
                    context.pop(true);
                    _templateDetailBloc.add(LoadRewardAD());
                    AdHelper.showRewardedAd(
                      adUnitId: AppAdIdString.startCreatingRewardedAd,
                      onRewardEarned: () {
                        _templateDetailBloc.add(StoreCoinEvent(coins: 2));
                      },
                      onComplete: () {
                        _templateDetailBloc.add(LoadedRewardAD());
                        CommonDialog.loaderDialog(context: context);
                        _templateDetailBloc.add(
                          UseVnAppEvent(qrCodeLink: template.qrCode ?? ''),
                        );
                        Future.delayed(const Duration(milliseconds: 1500), () {
                          if (context.mounted) {
                            CommonDialog.closeDialog(context: context);
                          }
                        });
                      },
                      onAdFailed: () {
                        _templateDetailBloc.add(LoadedRewardAD());
                        CommonDialog.loaderDialog(context: context);
                        _templateDetailBloc.add(
                          UseVnAppEvent(qrCodeLink: template.qrCode ?? ''),
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
                context.pop(true);
                if (template.qrCode != null && template.qrCode!.isNotEmpty) {
                  if (AppPreferences().getBool(
                        AppPreferences.subscriptionPlan,
                      ) ==
                      true) {
                    context
                        .push(
                          AppRoutesString.qrCodeView,
                          extra: {
                            'qrLink': template.qrCode ?? '',
                            'title': template.title ?? '',
                          },
                        )
                        .then((_) {
                          if (context.mounted) {
                            _templateDetailBloc.add(ResetDetailStatus());
                            _templateDetailBloc.state.videoPlayerController
                                ?.play();
                          }
                        });
                  } else if (isPremiumTemplate) {
                    if (userCoins < requiredCoins) {
                      _templateDetailBloc.state.videoPlayerController?.play();
                      return;
                    } else {
                      final remainingCoins = userCoins - requiredCoins;
                      AppPreferences().setInt(
                        AppPreferences.coin,
                        remainingCoins < 0 ? 0 : remainingCoins,
                      );
                      context
                          .push(
                            AppRoutesString.qrCodeView,
                            extra: {
                              'qrLink': template.qrCode ?? '',
                              'title': template.title ?? '',
                            },
                          )
                          .then((_) {
                            if (context.mounted) {
                              _templateDetailBloc.add(ResetDetailStatus());
                              _templateDetailBloc.state.videoPlayerController
                                  ?.play();
                            }
                          });
                    }
                  } else {
                    _templateDetailBloc.add(LoadRewardAD());
                    AdHelper.showRewardedAd(
                      adUnitId: AppAdIdString.startCreatingRewardedAd,
                      onRewardEarned: () {
                        _templateDetailBloc.add(StoreCoinEvent(coins: 2));
                      },
                      onComplete: () {
                        _templateDetailBloc.add(LoadedRewardAD());
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (context.mounted) {
                            context
                                .push(
                                  AppRoutesString.qrCodeView,
                                  extra: {
                                    'qrLink': template.qrCode ?? '',
                                    'title': template.title ?? '',
                                  },
                                )
                                .then((_) {
                                  if (context.mounted) {
                                    _templateDetailBloc.add(
                                      ResetDetailStatus(),
                                    );
                                    _templateDetailBloc
                                        .state
                                        .videoPlayerController
                                        ?.play();
                                  }
                                });
                          }
                        });
                      },
                      onAdFailed: () {
                        _templateDetailBloc.add(LoadedRewardAD());
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (context.mounted) {
                            context
                                .push(
                                  AppRoutesString.qrCodeView,
                                  extra: {
                                    'qrLink': template.qrCode ?? '',
                                    'title': template.title ?? '',
                                  },
                                )
                                .then((_) {
                                  if (context.mounted) {
                                    _templateDetailBloc.add(
                                      ResetDetailStatus(),
                                    );
                                    _templateDetailBloc
                                        .state
                                        .videoPlayerController
                                        ?.play();
                                  }
                                });
                          }
                        });
                      },
                    );
                  }
                }
              },
            ).then((value) {
              if (context.mounted) {
                _templateDetailBloc.add(ResetDetailStatus());
                if (value != true) {
                  _templateDetailBloc.state.videoPlayerController?.play();
                }
              }
            });
          } else if (state.status == TemplateDetailStatus.downloadVNApp) {
            CommonDialog.closeDialog(context: context);
            _templateDetailBloc.state.videoPlayerController?.pause();
            CommonBottomSheet.showCommonBottomSheet(
              adId: AppAdIdString.templateDetailNativeAd,
              context: context,
              firstButtonText: AppStrings.txtDownload.getString(context),
              secondButtonText: AppStrings.txtCancel.getString(context),
              title: AppStrings.txtDownloadVNApp.getString(context),
              firstButtonOnTap: () {
                context.pop(true);
                _templateDetailBloc.add(DownloadVnEvent());
              },
              secondButtonOnTap: () {
                context.pop();
              },
            ).then((value) {
              if (context.mounted) {
                _templateDetailBloc.add(ResetDetailStatus());
                if (value != true) {
                  _templateDetailBloc.state.videoPlayerController?.play();
                }
              }
            });
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.primaryColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: CommonAppBar(
              title:
                  widget.template.title ??
                  AppStrings.txtTemplateDetail.getString(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TemplateVideoPlayerWidget(template: widget.template),
                const SBH10(),
                TemplateStatsWidget(
                  clip: widget.template.clip ?? '',
                  likes: widget.template.likes ?? 0,
                  usage: widget.template.usage ?? 0,
                ),
                const SBH5(),
                BlocProvider(
                  create: (context) => NativeAdBloc(),
                  child: NativeAdView(
                    adId: AppAdIdString.templateDetailNativeAd,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(
              16.0,
            ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonButton(
                  text: AppStrings.txtUseTemplate.getString(context),
                  onTap: () {
                    _templateDetailBloc.add(
                      StartCreateFlowEvent(model: widget.template),
                    );
                  },
                  suffixWidget:
                      (widget.template.coin ?? 0) > 0 &&
                          AppImagesString.imgPremium.isNotEmpty
                      ? Image.asset(
                          AppImagesString.imgPremium,
                          height: 20,
                          width: 20,
                        )
                      : null,
                ),

                BlocProvider(
                  create: (context) => BannerAdBloc(),
                  child: BannerAdWidget(
                    adId: AppAdIdString.templateDetailBanner,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
