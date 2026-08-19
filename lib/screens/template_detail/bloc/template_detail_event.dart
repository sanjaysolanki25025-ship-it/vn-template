part of 'template_detail_bloc.dart';

abstract class TemplateDetailEvent {}

class InitVideoPlayerEvent extends TemplateDetailEvent {
  final String videoUrl;
  InitVideoPlayerEvent({required this.videoUrl});
}

class DisposeVideoPlayerEvent extends TemplateDetailEvent {}

class TogglePlayPauseEvent extends TemplateDetailEvent {}

class LoadRewardAD extends TemplateDetailEvent {}

class LoadedRewardAD extends TemplateDetailEvent {}

class ResetDetailStatus extends TemplateDetailEvent {}

class StoreCoinEvent extends TemplateDetailEvent {
  final int coins;
  StoreCoinEvent({this.coins = 5});
}

class StartCreateFlowEvent extends TemplateDetailEvent {
  final TemplateModel model;
  StartCreateFlowEvent({required this.model});
}

class DownloadVnEvent extends TemplateDetailEvent {}

class UseVnAppEvent extends TemplateDetailEvent {
  final String qrCodeLink;
  UseVnAppEvent({required this.qrCodeLink});
}
