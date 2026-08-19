part of 'discover_bloc.dart';

abstract class DiscoverEvent {}

class FetchDiscoverDataEvent extends DiscoverEvent {}

class SelectCategoryEvent extends DiscoverEvent {
  final int categoryIndex;

  SelectCategoryEvent({required this.categoryIndex});
}

class LoadMoreTemplatesEvent extends DiscoverEvent {}

class ToggleFavouriteEvent extends DiscoverEvent {
  final TemplateModel template;

  ToggleFavouriteEvent({required this.template});
}

class EnrichDiscoverTemplateAtIndexEvent extends DiscoverEvent {
  final int index;

  EnrichDiscoverTemplateAtIndexEvent({required this.index});
}

class UpdateFavouriteStatusEvent extends DiscoverEvent {
  final String templateId;
  final bool isFavourite;
  UpdateFavouriteStatusEvent({required this.templateId, required this.isFavourite});
}

class LoadDiscoverRewardADEvent extends DiscoverEvent {}

class LoadedDiscoverRewardADEvent extends DiscoverEvent {}

class ResetDiscoverStatusEvent extends DiscoverEvent {}

class StoreDiscoverCoinEvent extends DiscoverEvent {
  final int coins;
  StoreDiscoverCoinEvent({required this.coins});
}

class PlayDiscoverDinoGameEvent extends DiscoverEvent {}
