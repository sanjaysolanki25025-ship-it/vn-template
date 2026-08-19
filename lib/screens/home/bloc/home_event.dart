part of 'home_bloc.dart';

abstract class HomeEvent {}

class FetchTemplateDataEvent extends HomeEvent {}

class LoadMoreEvent extends HomeEvent {}

class SelectCategoryEvent extends HomeEvent {
  final String categoryName;
  SelectCategoryEvent({required this.categoryName});
}

class ChangeIndexEvent extends HomeEvent {
  final int index;
  ChangeIndexEvent({required this.index});
}

class EnrichTemplateAtIndexEvent extends HomeEvent {
  final int index;
  EnrichTemplateAtIndexEvent({required this.index});
}

class SetReelsPausedEvent extends HomeEvent {
  final bool paused;
  SetReelsPausedEvent({required this.paused});
}

class SetAdFlowStatusEvent extends HomeEvent {
  final bool isAdFlowRunning;
  final bool scrollLocked;
  SetAdFlowStatusEvent({
    required this.isAdFlowRunning,
    required this.scrollLocked,
  });
}

class RemoveFavouriteTemplateEvent extends HomeEvent {
  final int index;
  final String templateId;
  RemoveFavouriteTemplateEvent({required this.index, required this.templateId});
}

class AddFavouriteTemplateEvent extends HomeEvent {
  final int index;
  final FavouriteModel favouriteModel;
  AddFavouriteTemplateEvent({
    required this.index,
    required this.favouriteModel,
  });
}

class LoadRewardAD extends HomeEvent {}

class LoadedRewardAD extends HomeEvent {}

class ResetHomeStatus extends HomeEvent {}

class StoreCoinEvent extends HomeEvent {
  final int coins;
  StoreCoinEvent({this.coins = 2});
}

class PlayDinoGame extends HomeEvent {}

class StartCreateFlowEvent extends HomeEvent {
  final TemplateModel model;
  StartCreateFlowEvent({required this.model});
}

class DownloadVnEvent extends HomeEvent {}

class UseVnAppEvent extends HomeEvent {
  final String qrCodeLink;
  UseVnAppEvent({required this.qrCodeLink});
}

class UpdateFavouriteStatusEvent extends HomeEvent {
  final String templateId;
  final bool isFavourite;
  UpdateFavouriteStatusEvent({required this.templateId, required this.isFavourite});
}

