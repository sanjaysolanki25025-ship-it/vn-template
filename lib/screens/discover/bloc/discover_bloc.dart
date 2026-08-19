import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_template/data/models/category_model.dart';
import 'package:vn_template/data/models/favourite_model.dart';
import 'package:vn_template/data/models/template_model.dart';
import 'package:vn_template/data/repository/app_repository.dart';
import 'package:vn_template/screens/discover/repository/discover_repository.dart';

import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/data/services/api_service.dart';
import 'package:vn_template/core/utils/app_logger.dart';

part 'discover_event.dart';
part 'discover_state.dart';

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final DiscoverRepository _discoverRepository = DiscoverRepository();
  final AppRepository _appRepository = AppRepository();
  final ApiService _apiService = ApiService();

  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  double? _randomStart;

  StreamSubscription? _favouriteSub;

  DiscoverBloc() : super(const DiscoverState()) {
    on<FetchDiscoverDataEvent>(_onFetchDiscoverData);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<LoadMoreTemplatesEvent>(_onLoadMoreTemplates);
    on<ToggleFavouriteEvent>(_onToggleFavourite);
    on<EnrichDiscoverTemplateAtIndexEvent>(_onEnrichDiscoverTemplateAtIndex);
    on<UpdateFavouriteStatusEvent>(_onUpdateFavouriteStatus);
    on<LoadDiscoverRewardADEvent>(_onLoadDiscoverRewardAD);
    on<LoadedDiscoverRewardADEvent>(_onLoadedDiscoverRewardAD);
    on<ResetDiscoverStatusEvent>(_onResetDiscoverStatus);
    on<StoreDiscoverCoinEvent>(_onStoreDiscoverCoin);
    on<PlayDiscoverDinoGameEvent>(_onPlayDiscoverDinoGame);

    _favouriteSub = AppRepository.favouriteUpdates.listen((update) {
      add(UpdateFavouriteStatusEvent(
        templateId: update['templateId'] as String,
        isFavourite: update['isFavourite'] as bool,
      ));
    });
  }

  Future<void> _onFetchDiscoverData(
    FetchDiscoverDataEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(state.copyWith(status: DiscoverStatus.loading));
    _lastDoc = null;
    _hasMore = true;

    try {
      // 1. Fetch categories via AppRepository
      final catResult = await _appRepository.fetchCategory();
      List<CategoryModel> categoriesList = [
        CategoryModel(categoryName: 'All'),
        CategoryModel(categoryName: 'Trending'),
        CategoryModel(categoryName: 'Premium 👑'),
      ];

      catResult.match(
        (failure) {
          AppLogger.log("Fetch categories failed: ${failure.message}", error: failure.message);
        },
        (cats) {
          final existingNames = categoriesList.map((c) => c.categoryName).toSet();
          for (final cat in cats) {
            if (!existingNames.contains(cat.categoryName)) {
              categoriesList.add(cat);
              existingNames.add(cat.categoryName);
            }
          }
        },
      );

      // 2. Fetch initial 10 templates for selected category
      final selectedCategory = categoriesList.isNotEmpty &&
              state.selectedCategoryIndex < categoriesList.length
          ? categoriesList[state.selectedCategoryIndex].categoryName
          : 'All';

      _randomStart = Random().nextDouble();

      final templateResult = await _discoverRepository.fetchTemplatesWithPagination(
        category: selectedCategory == 'All' ? null : selectedCategory,
        limit: 6,
        lastDoc: null,
        randomStart: _randomStart,
      );

      await templateResult.match(
        (failure) async {
          AppLogger.log("Fetch discover templates failed: ${failure.message}", error: failure.message);
          emit(state.copyWith(
            status: DiscoverStatus.error,
            errorMessage: failure.message,
          ));
        },
        (pagedData) async {
          AppLogger.log("Successfully fetched ${pagedData.templates.length} templates from Firebase");
          _lastDoc = pagedData.lastDoc;
          _hasMore = pagedData.hasMore;

          // ---------- FAVOURITES ----------
          final favoriteIdsResult = await _appRepository.fetchFavouriteTemplate();
          List<String> favIds = [];

          favoriteIdsResult.match((failure) => null, (favModels) {
            favIds = favModels.map((fav) => fav.templateId.toString()).toList();
          });

          final List<TemplateModel> updatedList = pagedData.templates.map((
            template,
          ) {
            final isLiked = favIds.contains(template.id);
            return template.copyWith(isFavourite: isLiked);
          }).toList();

          emit(state.copyWith(
            status: DiscoverStatus.loaded,
            categories: categoriesList,
            templates: updatedList,
            hasMore: _hasMore,
          ));

          add(EnrichDiscoverTemplateAtIndexEvent(index: 0));
        },
      );
    } catch (e) {
      AppLogger.log("Fetch discover data exception: $e", error: e);
      emit(state.copyWith(
        status: DiscoverStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSelectCategory(
    SelectCategoryEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    if (event.categoryIndex == state.selectedCategoryIndex &&
        state.status == DiscoverStatus.loaded) {
      return;
    }

    emit(state.copyWith(
      selectedCategoryIndex: event.categoryIndex,
      status: DiscoverStatus.loading,
      templates: [],
    ));

    _lastDoc = null;
    _hasMore = true;
    _randomStart = Random().nextDouble();

    final selectedCategory = state.categories.isNotEmpty &&
            event.categoryIndex < state.categories.length
        ? state.categories[event.categoryIndex].categoryName
        : 'All';

    final templateResult = await _discoverRepository.fetchTemplatesWithPagination(
      category: selectedCategory == 'All' ? null : selectedCategory,
      limit: 6,
      lastDoc: null,
      randomStart: _randomStart,
    );

    await templateResult.match(
      (failure) async {
        AppLogger.log("Select category '$selectedCategory' templates failed: ${failure.message}", error: failure.message);
        emit(state.copyWith(
          status: DiscoverStatus.error,
          errorMessage: failure.message,
        ));
      },
      (pagedData) async {
        AppLogger.log("Successfully fetched ${pagedData.templates.length} templates for category '$selectedCategory'");
        _lastDoc = pagedData.lastDoc;
        _hasMore = pagedData.hasMore;

        // ---------- FAVOURITES ----------
        final favoriteIdsResult = await _appRepository.fetchFavouriteTemplate();
        List<String> favIds = [];

        favoriteIdsResult.match((failure) => null, (favModels) {
          favIds = favModels.map((fav) => fav.templateId.toString()).toList();
        });

        final List<TemplateModel> updatedList = pagedData.templates.map((
          template,
        ) {
          final isLiked = favIds.contains(template.id);
          return template.copyWith(isFavourite: isLiked);
        }).toList();

        emit(state.copyWith(
          status: DiscoverStatus.loaded,
          templates: updatedList,
          hasMore: _hasMore,
        ));

        add(EnrichDiscoverTemplateAtIndexEvent(index: 0));
      },
    );
  }

  Future<void> _onLoadMoreTemplates(
    LoadMoreTemplatesEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    if (state.isLoadingMore || !_hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final selectedCategory = state.categories.isNotEmpty &&
            state.selectedCategoryIndex < state.categories.length
        ? state.categories[state.selectedCategoryIndex].categoryName
        : 'All';

    final templateResult = await _discoverRepository.fetchTemplatesWithPagination(
      category: selectedCategory == 'All' ? null : selectedCategory,
      limit: 6,
      lastDoc: _lastDoc,
      randomStart: _randomStart,
    );

    await templateResult.match(
      (failure) async {
        AppLogger.log("Load more templates failed: ${failure.message}", error: failure.message);
        emit(state.copyWith(isLoadingMore: false));
      },
      (pagedData) async {
        AppLogger.log("Successfully loaded more templates (${pagedData.templates.length} items)");
        _lastDoc = pagedData.lastDoc;
        _hasMore = pagedData.hasMore;

        // ---------- FAVOURITES ----------
        final favoriteIdsResult = await _appRepository.fetchFavouriteTemplate();
        List<String> favIds = [];

        favoriteIdsResult.match((failure) => null, (favModels) {
          favIds = favModels.map((fav) => fav.templateId.toString()).toList();
        });

        final List<TemplateModel> newTemplates = pagedData.templates.map((
          template,
        ) {
          final isLiked = favIds.contains(template.id);
          return template.copyWith(isFavourite: isLiked);
        }).toList();

        final startIndex = state.templates.length;
        final currentList = List<TemplateModel>.from(state.templates)
          ..addAll(newTemplates);

        emit(state.copyWith(
          isLoadingMore: false,
          templates: currentList,
          hasMore: _hasMore,
        ));

        add(EnrichDiscoverTemplateAtIndexEvent(index: startIndex));
      },
    );
  }

  Future<void> _onToggleFavourite(
    ToggleFavouriteEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    final template = event.template;
    final templateId = template.id ?? '';
    final newFavState = !template.isFavourite;

    if (newFavState) {
      final favModel = FavouriteModel(
        templateId: templateId,
        description: template.description ?? '',
        qrCode: template.qrCode ?? '',
        category: (template.category ?? []).join(','),
        language: template.language ?? '',
        code: template.code ?? '',
        clip: template.clip ?? '',
        duration: template.duration ?? '',
        createdAt: template.createdAt.toIso8601String(),
        rand: template.rand,
        coin: template.coin ?? 0,
      );
      await _appRepository.addFavourite(fav: favModel);
    } else {
      await _appRepository.removeFavourite(templateId: templateId);
    }

    final updatedTemplates = state.templates.map((t) {
      if (t.id == templateId) {
        return t.copyWith(isFavourite: newFavState);
      }
      return t;
    }).toList();

    emit(state.copyWith(templates: updatedTemplates));
  }

  Future<void> _onEnrichDiscoverTemplateAtIndex(
    EnrichDiscoverTemplateAtIndexEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    final templates = state.templates;
    if (event.index < 0 || event.index >= templates.length) {
      return;
    }

    final template = templates[event.index];
    if (template.previewImage != null &&
        template.previewImage!.isNotEmpty) {
      add(EnrichDiscoverTemplateAtIndexEvent(index: event.index + 1));
      return;
    }

    final enriched = await _apiService.enrichTemplate(template);

    if (state.templates.isEmpty || event.index >= state.templates.length) {
      return;
    }

    if (state.templates[event.index].id != template.id) {
      return;
    }

    final updatedList = List<TemplateModel>.from(state.templates);

    if (enriched.previewImage != null && enriched.previewImage!.isNotEmpty) {
      AppLogger.log("Successfully enriched discover template at index ${event.index} with code ${template.code}");
      updatedList[event.index] = enriched;
      emit(state.copyWith(templates: updatedList));
      add(EnrichDiscoverTemplateAtIndexEvent(index: event.index + 1));
    } else {
      AppLogger.log("Discover API Enrichment empty or invalid format for code ${template.code} at index ${event.index}. Removing template.");
      updatedList.removeAt(event.index);
      emit(state.copyWith(templates: updatedList));

      if (updatedList.isNotEmpty && event.index < updatedList.length) {
        add(EnrichDiscoverTemplateAtIndexEvent(index: event.index));
      }
    }
  }

  void _onUpdateFavouriteStatus(
    UpdateFavouriteStatusEvent event,
    Emitter<DiscoverState> emit,
  ) {
    final updatedList = state.templates.map((template) {
      if (template.id == event.templateId) {
        return template.copyWith(isFavourite: event.isFavourite);
      }
      return template;
    }).toList();
    emit(state.copyWith(templates: updatedList));
  }

  @override
  Future<void> close() {
    _favouriteSub?.cancel();
    return super.close();
  }

  void _onLoadDiscoverRewardAD(LoadDiscoverRewardADEvent event, Emitter<DiscoverState> emit) {
    emit(state.copyWith(status: DiscoverStatus.rewardAdLoading));
  }

  void _onLoadedDiscoverRewardAD(LoadedDiscoverRewardADEvent event, Emitter<DiscoverState> emit) {
    emit(state.copyWith(status: DiscoverStatus.rewardAdLoaded));
  }

  void _onResetDiscoverStatus(ResetDiscoverStatusEvent event, Emitter<DiscoverState> emit) {
    emit(state.copyWith(status: DiscoverStatus.loaded));
  }

  Future<void> _onStoreDiscoverCoin(StoreDiscoverCoinEvent event, Emitter<DiscoverState> emit) async {
    final int currentCoins = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    await AppPreferences().setInt(AppPreferences.coin, currentCoins + event.coins);
    emit(state.copyWith(status: DiscoverStatus.loaded));
  }

  Future<void> _onPlayDiscoverDinoGame(PlayDiscoverDinoGameEvent event, Emitter<DiscoverState> emit) async {
    final int currentCoins = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    if (currentCoins >= 5) {
      await AppPreferences().setInt(AppPreferences.coin, currentCoins - 5);
    }
    emit(state.copyWith(status: DiscoverStatus.loaded));
  }
}
