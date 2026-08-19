part of 'favourite_bloc.dart';

enum FavouriteStatus { initial, loading, loaded, error, noInternet, rewardAdLoading, rewardAdLoaded }

class FavouriteState {
  final FavouriteStatus status;
  final List<FavouriteModel> favourites;
  final List<String> categories;
  final int selectedCategoryIndex;
  final String? errorMessage;

  const FavouriteState({
    this.status = FavouriteStatus.initial,
    this.favourites = const [],
    this.categories = const [],
    this.selectedCategoryIndex = 0,
    this.errorMessage,
  });

  List<FavouriteModel> get filteredFavourites {
    if (selectedCategoryIndex == 0 || categories.isEmpty) {
      return favourites;
    }
    final category = categories[selectedCategoryIndex];
    return favourites.where((item) {
      final List<String> splitCats = item.category.split(',').map((e) => e.trim()).toList();
      return splitCats.contains(category);
    }).toList();
  }

  FavouriteState copyWith({
    FavouriteStatus? status,
    List<FavouriteModel>? favourites,
    List<String>? categories,
    int? selectedCategoryIndex,
    String? errorMessage,
  }) {
    return FavouriteState(
      status: status ?? this.status,
      favourites: favourites ?? this.favourites,
      categories: categories ?? this.categories,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
