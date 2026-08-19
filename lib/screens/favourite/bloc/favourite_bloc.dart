import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:vn_template/core/utils/app_logger.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/data/models/favourite_model.dart';
import 'package:vn_template/data/models/template_model.dart';
import 'package:vn_template/data/repository/app_repository.dart';
import 'package:vn_template/data/services/api_service.dart';

part 'favourite_event.dart';
part 'favourite_state.dart';

class FavouriteBloc extends Bloc<FavouriteEvent, FavouriteState> {
  final AppRepository _appRepository = AppRepository();
  final ApiService _apiService = ApiService();
  StreamSubscription? _favouriteSub;

  FavouriteBloc() : super(const FavouriteState()) {
    on<LoadFavouritesEvent>(_onLoadFavourites);
    on<EnrichFavouriteAtIndexEvent>(_onEnrichFavouriteAtIndex);
    on<SelectFavouriteCategoryEvent>(_onSelectFavouriteCategory);
    on<ToggleFavouriteOnScreenEvent>(_onToggleFavouriteOnScreen);
    on<LoadFavouriteRewardADEvent>(_onLoadFavouriteRewardAD);
    on<LoadedFavouriteRewardADEvent>(_onLoadedFavouriteRewardAD);
    on<ResetFavouriteStatusEvent>(_onResetFavouriteStatus);
    on<StoreFavouriteCoinEvent>(_onStoreFavouriteCoin);
    on<PlayFavouriteDinoGameEvent>(_onPlayFavouriteDinoGame);

    _favouriteSub = AppRepository.favouriteUpdates.listen((update) {
      final templateId = update['templateId'] as String;
      final isFavourite = update['isFavourite'] as bool;
      if (!isFavourite) {
        add(ToggleFavouriteOnScreenEvent(templateId: templateId));
      } else {
        // If favorited from another screen, reload the list to show it here.
        add(LoadFavouritesEvent());
      }
    });
  }

  Future<void> _onLoadFavourites(
    LoadFavouritesEvent event,
    Emitter<FavouriteState> emit,
  ) async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      emit(state.copyWith(status: FavouriteStatus.noInternet));
      return;
    }

    emit(state.copyWith(status: FavouriteStatus.loading));

    final result = await _appRepository.fetchFavouriteTemplate();
    result.fold(
      (failure) {
        emit(state.copyWith(
          status: FavouriteStatus.error,
          errorMessage: failure.message,
        ));
      },
      (favouritesList) {
        List<String> categoriesList = [];
        if (favouritesList.isNotEmpty) {
          final Set<String> uniqueCategories = {};
          for (var item in favouritesList) {
            if (item.category.isNotEmpty) {
              final List<String> splitCats = item.category.split(',');
              for (var cat in splitCats) {
                final trimmedCat = cat.trim();
                if (trimmedCat.isNotEmpty) {
                  uniqueCategories.add(trimmedCat);
                }
              }
            }
          }
          categoriesList = ['All', ...uniqueCategories];
        }

        emit(state.copyWith(
          status: FavouriteStatus.loaded,
          favourites: favouritesList,
          categories: categoriesList,
          selectedCategoryIndex: 0,
        ));

        // Start enriching backgrounds
        if (favouritesList.isNotEmpty) {
          add(EnrichFavouriteAtIndexEvent(index: 0));
        }
      },
    );
  }

  Future<void> _onEnrichFavouriteAtIndex(
    EnrichFavouriteAtIndexEvent event,
    Emitter<FavouriteState> emit,
  ) async {
    final favourites = state.favourites;
    if (event.index < 0 || event.index >= favourites.length) {
      return;
    }

    final item = favourites[event.index];
    if (item.previewImage != null && item.previewImage!.isNotEmpty) {
      // Already enriched, proceed to next
      add(EnrichFavouriteAtIndexEvent(index: event.index + 1));
      return;
    }

    // Call enrichTemplate
    final tempTemplate = TemplateModel(
      id: item.templateId,
      code: item.code,
    );

    final enrichedTemp = await _apiService.enrichTemplate(tempTemplate);

    if (state.favourites.isEmpty || event.index >= state.favourites.length) {
      return;
    }

    if (state.favourites[event.index].templateId != item.templateId) {
      return;
    }

    final updatedList = List<FavouriteModel>.from(state.favourites);

    if (enrichedTemp.previewImage != null && enrichedTemp.previewImage!.isNotEmpty) {
      AppLogger.log("Successfully enriched favourite template at index ${event.index} with code ${item.code}");
      final enriched = item.copyWith(
        title: enrichedTemp.title,
        previewImage: enrichedTemp.previewImage,
        previewVideo: enrichedTemp.previewVideo,
      );
      updatedList[event.index] = enriched;
      emit(state.copyWith(favourites: updatedList));
    } else {
      AppLogger.log("Favourite API Enrichment empty or invalid format for code ${item.code} at index ${event.index}.");
    }

    // Always proceed to next favorite item
    add(EnrichFavouriteAtIndexEvent(index: event.index + 1));
  }

  void _onSelectFavouriteCategory(
    SelectFavouriteCategoryEvent event,
    Emitter<FavouriteState> emit,
  ) {
    emit(state.copyWith(selectedCategoryIndex: event.categoryIndex));
  }

  Future<void> _onToggleFavouriteOnScreen(
    ToggleFavouriteOnScreenEvent event,
    Emitter<FavouriteState> emit,
  ) async {
    // Check if it exists in current favourites
    final exists = state.favourites.any((item) => item.templateId == event.templateId);
    if (!exists) return;

    // Remove locally
    final updatedList = state.favourites.where((item) => item.templateId != event.templateId).toList();
    
    // Also request removal in repository if triggered on this screen
    // Note: Since AppRepository.favouriteUpdates is also listening,
    // we make sure we don't end up in an infinite loop by only removing from repo if it is currently in local db.
    await _appRepository.removeFavourite(templateId: event.templateId);

    // Update categories based on remaining favourites
    final Set<String> uniqueCategories = {};
    for (var item in updatedList) {
      if (item.category.isNotEmpty) {
        final List<String> splitCats = item.category.split(',');
        for (var cat in splitCats) {
          final trimmedCat = cat.trim();
          if (trimmedCat.isNotEmpty) {
            uniqueCategories.add(trimmedCat);
          }
        }
      }
    }
    final categoriesList = ['All', ...uniqueCategories];

    int newCategoryIndex = state.selectedCategoryIndex;
    if (newCategoryIndex >= categoriesList.length) {
      newCategoryIndex = 0;
    }

    emit(state.copyWith(
      favourites: updatedList,
      categories: categoriesList,
      selectedCategoryIndex: newCategoryIndex,
    ));
  }

  @override
  Future<void> close() {
    _favouriteSub?.cancel();
    return super.close();
  }

  void _onLoadFavouriteRewardAD(LoadFavouriteRewardADEvent event, Emitter<FavouriteState> emit) {
    emit(state.copyWith(status: FavouriteStatus.rewardAdLoading));
  }

  void _onLoadedFavouriteRewardAD(LoadedFavouriteRewardADEvent event, Emitter<FavouriteState> emit) {
    emit(state.copyWith(status: FavouriteStatus.rewardAdLoaded));
  }

  void _onResetFavouriteStatus(ResetFavouriteStatusEvent event, Emitter<FavouriteState> emit) {
    emit(state.copyWith(status: FavouriteStatus.loaded));
  }

  Future<void> _onStoreFavouriteCoin(StoreFavouriteCoinEvent event, Emitter<FavouriteState> emit) async {
    final int currentCoins = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    await AppPreferences().setInt(AppPreferences.coin, currentCoins + event.coins);
    emit(state.copyWith(status: FavouriteStatus.loaded));
  }

  Future<void> _onPlayFavouriteDinoGame(PlayFavouriteDinoGameEvent event, Emitter<FavouriteState> emit) async {
    final int currentCoins = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    if (currentCoins >= 5) {
      await AppPreferences().setInt(AppPreferences.coin, currentCoins - 5);
    }
    emit(state.copyWith(status: FavouriteStatus.loaded));
  }
}
