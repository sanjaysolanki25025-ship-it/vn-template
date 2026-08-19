part of 'favourite_bloc.dart';

abstract class FavouriteEvent {}

class LoadFavouritesEvent extends FavouriteEvent {}

class EnrichFavouriteAtIndexEvent extends FavouriteEvent {
  final int index;
  EnrichFavouriteAtIndexEvent({required this.index});
}

class SelectFavouriteCategoryEvent extends FavouriteEvent {
  final int categoryIndex;
  SelectFavouriteCategoryEvent({required this.categoryIndex});
}

class ToggleFavouriteOnScreenEvent extends FavouriteEvent {
  final String templateId;
  ToggleFavouriteOnScreenEvent({required this.templateId});
}

class LoadFavouriteRewardADEvent extends FavouriteEvent {}

class LoadedFavouriteRewardADEvent extends FavouriteEvent {}

class ResetFavouriteStatusEvent extends FavouriteEvent {}

class StoreFavouriteCoinEvent extends FavouriteEvent {
  final int coins;
  StoreFavouriteCoinEvent({required this.coins});
}

class PlayFavouriteDinoGameEvent extends FavouriteEvent {}

