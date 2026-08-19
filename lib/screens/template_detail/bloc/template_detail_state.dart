part of 'template_detail_bloc.dart';

enum TemplateDetailStatus { 
  initial, 
  loading, 
  loaded, 
  error,
  createLoading,
  createLoaded,
  downloadVNApp,
  rewardAdLoading,
  rewardAdLoaded,
  rewardAdError,
}

class TemplateDetailState {
  final TemplateDetailStatus status;
  final VideoPlayerController? videoPlayerController;
  final TemplateModel? model;

  TemplateDetailState({
    required this.status,
    this.videoPlayerController,
    this.model,
  });

  TemplateDetailState copyWith({
    TemplateDetailStatus? status,
    VideoPlayerController? videoPlayerController,
    TemplateModel? model,
  }) {
    return TemplateDetailState(
      status: status ?? this.status,
      videoPlayerController: videoPlayerController ?? this.videoPlayerController,
      model: model ?? this.model,
    );
  }

  factory TemplateDetailState.initial() {
    return TemplateDetailState(status: TemplateDetailStatus.initial);
  }
}
