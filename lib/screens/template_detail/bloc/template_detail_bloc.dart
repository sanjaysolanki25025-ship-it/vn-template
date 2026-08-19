import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:vn_template/data/models/template_model.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/services.dart';

part 'template_detail_event.dart';
part 'template_detail_state.dart';

class TemplateDetailBloc extends Bloc<TemplateDetailEvent, TemplateDetailState> {
  bool _isDisposed = false;

  TemplateDetailBloc() : super(TemplateDetailState.initial()) {
    on<InitVideoPlayerEvent>(_onInitVideoPlayer);
    on<DisposeVideoPlayerEvent>(_onDisposeVideoPlayer);
    on<TogglePlayPauseEvent>(_onTogglePlayPause);
    on<LoadRewardAD>(_loadRewardAD);
    on<LoadedRewardAD>(_loadedRewardAD);
    on<ResetDetailStatus>(_resetDetailStatus);
    on<StoreCoinEvent>(_storeCoinEvent);
    on<StartCreateFlowEvent>(_startCreateFlowEvent);
    on<DownloadVnEvent>(_downloadVnEvent);
    on<UseVnAppEvent>(_useVnAppEvent);
  }

  Future<void> _onInitVideoPlayer(InitVideoPlayerEvent event, Emitter<TemplateDetailState> emit) async {
    emit(state.copyWith(status: TemplateDetailStatus.loading));
    final controller = VideoPlayerController.networkUrl(Uri.parse(event.videoUrl));
    await controller.initialize();

    if (_isDisposed || isClosed) {
      controller.dispose();
      return;
    }

    controller.play();
    controller.setLooping(true);
    emit(state.copyWith(status: TemplateDetailStatus.loaded, videoPlayerController: controller));
  }

  void _onDisposeVideoPlayer(DisposeVideoPlayerEvent event, Emitter<TemplateDetailState> emit) {
    _isDisposed = true;
    state.videoPlayerController?.pause();
    state.videoPlayerController?.dispose();
    emit(state.copyWith(videoPlayerController: null));
  }

  void _onTogglePlayPause(TogglePlayPauseEvent event, Emitter<TemplateDetailState> emit) {
    if (state.videoPlayerController != null) {
      if (state.videoPlayerController!.value.isPlaying) {
        state.videoPlayerController!.pause();
      } else {
        state.videoPlayerController!.play();
      }
      emit(state.copyWith());
    }
  }

  void _loadRewardAD(LoadRewardAD event, Emitter<TemplateDetailState> emit) {
    emit(state.copyWith(status: TemplateDetailStatus.rewardAdLoading));
  }

  void _loadedRewardAD(LoadedRewardAD event, Emitter<TemplateDetailState> emit) {
    emit(state.copyWith(status: TemplateDetailStatus.rewardAdLoaded));
  }

  void _resetDetailStatus(ResetDetailStatus event, Emitter<TemplateDetailState> emit) {
    emit(state.copyWith(status: TemplateDetailStatus.loaded));
  }

  Future<void> _storeCoinEvent(StoreCoinEvent event, Emitter<TemplateDetailState> emit) async {
    final int currentCoins = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    await AppPreferences().setInt(AppPreferences.coin, currentCoins + event.coins);
    emit(state.copyWith(status: TemplateDetailStatus.loaded));
  }

  Future<void> _startCreateFlowEvent(StartCreateFlowEvent event, Emitter<TemplateDetailState> emit) async {
    emit(state.copyWith(status: TemplateDetailStatus.createLoading));
    final isInstalled = await LaunchApp.isAppInstalled(androidPackageName: 'com.frontrow.vlog');
    if (isInstalled) {
      emit(state.copyWith(status: TemplateDetailStatus.createLoaded, model: event.model));
    } else {
      emit(state.copyWith(status: TemplateDetailStatus.downloadVNApp, model: event.model));
    }
  }

  Future<void> _downloadVnEvent(DownloadVnEvent event, Emitter<TemplateDetailState> emit) async {
    await LaunchApp.openApp(
      androidPackageName: 'com.frontrow.vlog',
      iosUrlScheme: 'vn',
      appStoreLink: 'https://apps.apple.com/app/id1343581380',
      openStore: true,
    );
    emit(state.copyWith(status: TemplateDetailStatus.initial));
  }

  Future<void> _useVnAppEvent(
    UseVnAppEvent event,
    Emitter<TemplateDetailState> emit,
  ) async {
    await LaunchApp.openApp(
      androidPackageName: 'com.frontrow.vlog',
      openStore: false,
    );
    await Clipboard.setData(ClipboardData(text: event.qrCodeLink));
    emit(state.copyWith(status: TemplateDetailStatus.initial));
  }
}
