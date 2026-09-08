import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vn_template/data/services/api_service.dart';
import 'package:vn_template/core/utils/app_logger.dart';
import 'package:vn_template/data/models/category_model.dart';
import 'package:vn_template/data/models/favourite_model.dart';
import 'package:vn_template/data/models/template_model.dart';
import 'package:vn_template/data/repository/app_repository.dart';
import 'package:vn_template/screens/home/repository/home_repository.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:vn_template/core/utils/native_ad_manager.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepositoryTest = HomeRepository();
  final AppRepository appRepository = AppRepository();

  DocumentSnapshot? _lastTemplateDoc;
  double? _randomStart;
  bool _templateHasMore = true;
  bool _hasMore = true;
  final List<CategoryModel> categoryListData = [
    CategoryModel(categoryName: 'All'),
    CategoryModel(categoryName: 'Trending'),
    CategoryModel(categoryName: 'Premium 👑'),
  ];
  final ApiService apiService = ApiService();
  StreamSubscription? _favouriteSub;

  HomeBloc() : super(HomeState.initial()) {
    on<FetchTemplateDataEvent>(_fetchTemplateDataEvent);
    on<LoadMoreEvent>(_loadMoreEvent);
    on<SelectCategoryEvent>(_selectCategoryEvent);
    on<ChangeIndexEvent>(_changeIndexEvent);
    on<EnrichTemplateAtIndexEvent>(_enrichTemplateAtIndexEvent);
    on<SetReelsPausedEvent>(_setReelsPausedEvent);
    on<SetAdFlowStatusEvent>(_setAdFlowStatusEvent);
    on<AddFavouriteTemplateEvent>(_addFavouriteTemplateEvent);
    on<RemoveFavouriteTemplateEvent>(_removeFavouriteTemplateEvent);
    on<LoadRewardAD>(_loadRewardAD);
    on<LoadedRewardAD>(_loadedRewardAD);
    on<ResetHomeStatus>(_resetHomeStatus);
    on<StoreCoinEvent>(_storeCoinEvent);
    on<PlayDinoGame>(_playDinoGame);
    on<StartCreateFlowEvent>(_startCreateFlowEvent);
    on<DownloadVnEvent>(_downloadVnEvent);
    on<UseVnAppEvent>(_useVnAppEvent);
    on<UpdateFavouriteStatusEvent>(_updateFavouriteStatus);

    _favouriteSub = AppRepository.favouriteUpdates.listen((update) {
      add(UpdateFavouriteStatusEvent(
        templateId: update['templateId'] as String,
        isFavourite: update['isFavourite'] as bool,
      ));
    });
  }

  Future<void> _useVnAppEvent(
    UseVnAppEvent event,
    Emitter<HomeState> emit,
  ) async {
    await LaunchApp.openApp(
      androidPackageName: 'com.frontrow.vlog',
      openStore: false,
    );
    await Clipboard.setData(ClipboardData(text: event.qrCodeLink));
    emit(state.copyWith(status: HomeStatus.initial));
  }

  /// fetch template
  Future<void> _fetchTemplateDataEvent(
    FetchTemplateDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));

    if (_lastTemplateDoc == null) {
      _randomStart = Random().nextDouble();
    }

    final result = await homeRepositoryTest.fetchTemplateWithPagination(
      limit: 6,
      lastDoc: _lastTemplateDoc,
      randomStart: _randomStart,
    );

    await result.match(
      (failure) {
        AppLogger.log("Fetch templates error: ${failure.message}", error: failure.message);
        emit(
          state.copyWith(
            status: HomeStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (templates) async {
        // ---------- PAGINATION ----------
        _lastTemplateDoc = templates.lastDoc;
        _templateHasMore = templates.hasMore;
        _hasMore = (templates.templates.length >= 3) || _templateHasMore;

        // ---------- CATEGORIES ----------
        final categoryResult = await appRepository.fetchCategory();

        categoryResult.match((_) {}, (categories) {
          final existingNames = categoryListData
              .map((c) => c.categoryName)
              .toSet();

          for (final cat in categories) {
            if (!existingNames.contains(cat.categoryName)) {
              categoryListData.add(cat);
              existingNames.add(cat.categoryName);
            }
          }
        });

        // ---------- FAVOURITES ----------
        final favoriteIdsResult = await appRepository.fetchFavouriteTemplate();
        List<String> favIds = [];

        favoriteIdsResult.match((failure) => null, (favModels) {
          favIds = favModels.map((fav) => fav.templateId.toString()).toList();
        });

        // 2. Map the templates efficiently
        final List<TemplateModel> updatedTemplates = templates.templates.map((
          template,
        ) {
          final isLiked = favIds.contains(template.id);
          return template.copyWith(isFavourite: isLiked);
        }).toList();

        // ---------- EMIT STATE ----------
        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            templateList: updatedTemplates,
            allCategories: categoryListData,
            selectedCategoryName: 'All',
            hasMore: _hasMore,
          ),
        );

        // Background one-by-one enrichment
        add(EnrichTemplateAtIndexEvent(index: 0));
      },
    );
  }

  /// load more event
  Future<void> _loadMoreEvent(
    LoadMoreEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (!_hasMore) return;

    // Determine current selected category from state. If it's 'All' or null, don't pass a category filter.
    final currentCategory = state.selectedCategoryName;
    final isAll = currentCategory == null || currentCategory == 'All';

    final result = await homeRepositoryTest.fetchTemplateWithPagination(
      limit: 6,
      lastDoc: _lastTemplateDoc,
      category: isAll ? null : currentCategory,
    );

    await result.match(
      (failure) {
        AppLogger.log("Load more templates error: ${failure.message}", error: failure.message);
        emit(state.copyWith(status: HomeStatus.loaded));
      },
      (paged) async {
        _lastTemplateDoc = paged.lastDoc;
        _templateHasMore = paged.hasMore;
        _hasMore = paged.hasMore;

        final favoriteIdsResult = await appRepository.fetchFavouriteTemplate();
        List<String> favIds = [];

        favoriteIdsResult.match((failure) => null, (favModels) {
          favIds = favModels.map((fav) => fav.templateId.toString()).toList();
        });

        final List<TemplateModel> newTemplates = paged.templates.map((
          template,
        ) {
          final isLiked = favIds.contains(template.id);
          return template.copyWith(isFavourite: isLiked, isMute: false);
        }).toList();

        final startIndex = state.templateList!.length;
        final updatedList = [
          ...state.templateList!,
          ...newTemplates.map((e) => e.copyWith(isMute: false)),
        ];

        emit(
          state.copyWith(
            status: HomeStatus.initial,
            templateList: updatedList,
            hasMore: _hasMore,
          ),
        );

        // Background enrichment for new items
        add(EnrichTemplateAtIndexEvent(index: startIndex));
      },
    );
  }

  /// select category event
  Future<void> _selectCategoryEvent(
    SelectCategoryEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCategoryName: event.categoryName,
        status: HomeStatus.loading,
        templateList: [],
      ),
    );

    _lastTemplateDoc = null;
    _randomStart = Random().nextDouble();
    _templateHasMore = true;
    _hasMore = true;

    final isAll = event.categoryName == 'All';
    final result = await homeRepositoryTest.fetchTemplateWithPagination(
      limit: 6,
      category: isAll ? null : event.categoryName,
      randomStart: _randomStart,
    );

    await result.match(
      (failure) {
        AppLogger.log("Select category templates error: ${failure.message}", error: failure.message);
        emit(
          state.copyWith(
            status: HomeStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (templates) async {
        _lastTemplateDoc = templates.lastDoc;
        _templateHasMore = templates.hasMore;
        _hasMore = (templates.templates.length >= 3) || _templateHasMore;

        final favoriteIdsResult = await appRepository.fetchFavouriteTemplate();
        List<String> favIds = [];
        favoriteIdsResult.match((failure) => null, (favModels) {
          favIds = favModels.map((fav) => fav.templateId.toString()).toList();
        });

        final List<TemplateModel> updatedTemplates = templates.templates.map((
          template,
        ) {
          final isLiked = favIds.contains(template.id);
          return template.copyWith(isFavourite: isLiked);
        }).toList();

        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            templateList: updatedTemplates,
            hasMore: _hasMore,
          ),
        );

        // Background one-by-one enrichment
        add(EnrichTemplateAtIndexEvent(index: 0));
      },
    );
  }

  Future<void> _changeIndexEvent(
    ChangeIndexEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(currentIndex: event.index, reelsPaused: false));
    // Trigger enrichment for the active index (which will cascade forward)
    add(EnrichTemplateAtIndexEvent(index: event.index));
  }

  Future<void> _setReelsPausedEvent(
    SetReelsPausedEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(reelsPaused: event.paused));
  }

  Future<void> _setAdFlowStatusEvent(
    SetAdFlowStatusEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(
      isAdFlowRunning: event.isAdFlowRunning,
      scrollLocked: event.scrollLocked,
    ));
  }

  Future<void> _addFavouriteTemplateEvent(
    AddFavouriteTemplateEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.favouriteLoading));
    final result = await appRepository.addFavourite(fav: event.favouriteModel);
    result.match(
      (f) {
        emit(state.copyWith(status: HomeStatus.favouriteError, errorMessage: f.message));
      },
      (l) {
        final idx = event.index;
        if (idx >= 0 && state.templateList != null && idx < state.templateList!.length) {
          final updated = List<TemplateModel>.from(state.templateList!);
          updated[idx] = updated[idx].copyWith(isFavourite: true);
          emit(state.copyWith(templateList: updated, status: HomeStatus.favouriteLoaded));
        } else {
          emit(state.copyWith(status: HomeStatus.favouriteLoaded));
        }
      },
    );
  }

  Future<void> _removeFavouriteTemplateEvent(
    RemoveFavouriteTemplateEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.favouriteLoading));
    final removeResult = await appRepository.removeFavourite(templateId: event.templateId);
    removeResult.match(
      (f) {
        emit(state.copyWith(status: HomeStatus.favouriteError, errorMessage: f.message));
      },
      (l) {
        final idx = event.index;
        if (idx >= 0 && state.templateList != null && idx < state.templateList!.length) {
          final updated = List<TemplateModel>.from(state.templateList!);
          updated[idx] = updated[idx].copyWith(isFavourite: false);
          emit(state.copyWith(templateList: updated, status: HomeStatus.favouriteLoaded));
        } else {
          emit(state.copyWith(status: HomeStatus.favouriteLoaded));
        }
      },
    );
  }

  bool _isValidVideoUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    return !lowerUrl.endsWith('.jpg') &&
        !lowerUrl.endsWith('.jpeg') &&
        !lowerUrl.endsWith('.png') &&
        !lowerUrl.endsWith('.webp') &&
        !lowerUrl.endsWith('.gif');
  }

  Future<void> _enrichTemplateAtIndexEvent(
    EnrichTemplateAtIndexEvent event,
    Emitter<HomeState> emit,
  ) async {
    final templates = state.templateList;
    if (templates == null || event.index < 0 || event.index >= templates.length) {
      return;
    }

    final template = templates[event.index];
    if (template.previewVideo != null &&
        template.previewVideo!.isNotEmpty &&
        _isValidVideoUrl(template.previewVideo)) {
      // Already enriched: move to the next item in the list
      add(EnrichTemplateAtIndexEvent(index: event.index + 1));
      return;
    }

    final enriched = await apiService.enrichTemplate(template);

    if (state.templateList == null || event.index >= state.templateList!.length) {
      return;
    }

    final updatedList = List<TemplateModel>.from(state.templateList!);

    if (enriched.previewVideo != null &&
        enriched.previewVideo!.isNotEmpty &&
        _isValidVideoUrl(enriched.previewVideo)) {
      updatedList[event.index] = enriched;

      final jsonResponse = JsonEncoder.withIndent('  ', (dynamic object) {
        if (object is DateTime) return object.toIso8601String();
        return object.toString();
      }).convert(enriched.toMap());
      AppLogger.log("API Enrichment Success at index ${event.index}:\n$jsonResponse");

      emit(state.copyWith(templateList: updatedList));

      // Proceed to enrich the next item
      add(EnrichTemplateAtIndexEvent(index: event.index + 1));
    } else {
      AppLogger.log("API Enrichment empty or invalid video format for code ${template.code} at index ${event.index}. Removing template.");
      updatedList.removeAt(event.index);

      int newIndex = state.currentIndex;
      if (newIndex >= updatedList.length) {
        newIndex = updatedList.isEmpty ? 0 : updatedList.length - 1;
      }

      emit(state.copyWith(
        templateList: updatedList,
        currentIndex: newIndex,
      ));

      // Since we removed this item, the next item shifts to event.index.
      // We trigger enrichment at the same index (which is now the next item).
      if (updatedList.isNotEmpty && event.index < updatedList.length) {
        add(EnrichTemplateAtIndexEvent(index: event.index));
      }
    }
  }

  void _loadRewardAD(LoadRewardAD event, Emitter<HomeState> emit) {
    emit(state.copyWith(status: HomeStatus.rewardAdLoading));
  }

  void _loadedRewardAD(LoadedRewardAD event, Emitter<HomeState> emit) {
    emit(state.copyWith(status: HomeStatus.rewardAdLoaded));
  }

  void _resetHomeStatus(ResetHomeStatus event, Emitter<HomeState> emit) {
    emit(state.copyWith(status: HomeStatus.loaded));
  }

  Future<void> _storeCoinEvent(StoreCoinEvent event, Emitter<HomeState> emit) async {
    final int currentCoins = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    await AppPreferences().setInt(AppPreferences.coin, currentCoins + event.coins);
    emit(state.copyWith(status: HomeStatus.loaded));
  }

  Future<void> _playDinoGame(PlayDinoGame event, Emitter<HomeState> emit) async {
    final int currentCoins = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    if (currentCoins >= 5) {
      await AppPreferences().setInt(AppPreferences.coin, currentCoins - 5);
    }
    emit(state.copyWith(status: HomeStatus.loaded));
  }

  Future<void> _startCreateFlowEvent(StartCreateFlowEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.createLoading));
    
    NativeAdManager().preCacheAd(AppAdIdString.homeBottomNativeAd);
    await Future.delayed(const Duration(seconds: 2));

    final isInstalled = await LaunchApp.isAppInstalled(androidPackageName: 'com.frontrow.vlog');
    if (isInstalled) {
      emit(state.copyWith(status: HomeStatus.createLoaded, model: event.model));
    } else {
      emit(state.copyWith(status: HomeStatus.downloadVNApp, model: event.model));
    }
  }

  Future<void> _downloadVnEvent(DownloadVnEvent event, Emitter<HomeState> emit) async {
    await LaunchApp.openApp(
      androidPackageName: 'com.frontrow.vlog',
      iosUrlScheme: 'vn',
      appStoreLink: 'https://apps.apple.com/app/id1343581380',
      openStore: true,
    );
    emit(state.copyWith(status: HomeStatus.initial));
  }

  void _updateFavouriteStatus(
    UpdateFavouriteStatusEvent event,
    Emitter<HomeState> emit,
  ) {
    final updatedList = state.templateList?.map((template) {
      if (template.id == event.templateId) {
        return template.copyWith(isFavourite: event.isFavourite);
      }
      return template;
    }).toList();
    emit(state.copyWith(templateList: updatedList));
  }

  @override
  Future<void> close() {
    _favouriteSub?.cancel();
    return super.close();
  }
}
