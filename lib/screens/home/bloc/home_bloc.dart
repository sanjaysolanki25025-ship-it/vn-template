import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isWrapped = false;
  List<TemplateModel> _categoryPool = [];
  final List<CategoryModel> categoryListData = [
    CategoryModel(categoryName: 'All'),
    CategoryModel(categoryName: 'Trending'),
    CategoryModel(categoryName: 'Premium 👑'),
  ];
  StreamSubscription? _favouriteSub;

  HomeBloc() : super(HomeState.initial()) {
    on<FetchTemplateDataEvent>(_fetchTemplateDataEvent);
    on<LoadMoreEvent>(_loadMoreEvent);
    on<SelectCategoryEvent>(_selectCategoryEvent);
    on<ChangeIndexEvent>(_changeIndexEvent);
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

    _lastTemplateDoc = null;
    _isWrapped = false;
    _randomStart = Random().nextDouble();
    _categoryPool = [];

    final result = await homeRepositoryTest.fetchCategoryTemplates(
      category: 'All',
      limit: 300,
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

        // 2. Map the templates efficiently (and ensure only valid videos)
        final List<TemplateModel> updatedTemplates = templates
            .where((t) => t.hasValidVideo)
            .map((template) {
              final isLiked = favIds.contains(template.id);
              return template.copyWith(isFavourite: isLiked);
            }).toList();

        // 🔥 Randomize initial templates
        updatedTemplates.shuffle();
        _categoryPool = List.from(updatedTemplates);

        // ---------- EMIT STATE ----------
        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            templateList: _categoryPool,
            allCategories: categoryListData,
            selectedCategoryName: 'All',
            hasMore: true,
            reelsPaused: false,
            scrollLocked: false,
            isAdFlowRunning: false,
            currentIndex: 0,
          ),
        );
      },
    );
  }

  /// load more event
  Future<void> _loadMoreEvent(
    LoadMoreEvent event,
    Emitter<HomeState> emit,
  ) async {
    // 🔒 Concurrency lock & check if more data available
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    try {
      final currentCategory = state.selectedCategoryName;
      final isAll = currentCategory == null || currentCategory == 'All';

      // 🔥 If category was tapped and we have a shuffled category pool:
      if (_categoryPool.isNotEmpty) {
        // Continuous infinite reels: append another freshly shuffled cycle of the pool
        final moreShuffled = List<TemplateModel>.from(_categoryPool)..shuffle();

        emit(
          state.copyWith(
            status: HomeStatus.initial,
            templateList: [...state.templateList!, ...moreShuffled],
            hasMore: true,
          ),
        );
        return;
      }

      final result = await homeRepositoryTest.fetchTemplateWithPagination(
        limit: 6,
        lastDoc: _lastTemplateDoc,
        category: isAll ? null : currentCategory,
        randomStart: _randomStart,
        isWrapped: _isWrapped,
      );

      await result.match(
        (failure) {
          AppLogger.log("Load more templates error: ${failure.message}", error: failure.message);
          emit(state.copyWith(status: HomeStatus.loaded));
        },
        (paged) async {
          _lastTemplateDoc = paged.lastDoc;
          _isWrapped = paged.isWrapped;
          _hasMore = paged.hasMore;

          final favoriteIdsResult = await appRepository.fetchFavouriteTemplate();
          List<String> favIds = [];

          favoriteIdsResult.match((failure) => null, (favModels) {
            favIds = favModels.map((fav) => fav.templateId.toString()).toList();
          });

          // 🔥 Strict Deduplication: never re-add an already present template
          final existingIds = (state.templateList ?? []).map((e) => e.id).toSet();

          final List<TemplateModel> newTemplates = paged.templates
              .where((t) => t.hasValidVideo && !existingIds.contains(t.id))
              .map((template) {
                final isLiked = favIds.contains(template.id);
                return template.copyWith(isFavourite: isLiked, isMute: false);
              }).toList();

          // Shuffle new batch
          newTemplates.shuffle();

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
        },
      );
    } finally {
      _isLoadingMore = false;
    }
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
        currentIndex: 0,
        reelsPaused: false,
      ),
    );

    _lastTemplateDoc = null;
    _isWrapped = false;
    _randomStart = Random().nextDouble();
    _hasMore = true;
    _categoryPool = [];

    // 🔥 USER DIRECTIVE: Category onTap must fetch and shuffle();
    final result = await homeRepositoryTest.fetchCategoryTemplates(
      category: event.categoryName,
      limit: 300,
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
        final favoriteIdsResult = await appRepository.fetchFavouriteTemplate();
        List<String> favIds = [];
        favoriteIdsResult.match((failure) => null, (favModels) {
          favIds = favModels.map((fav) => fav.templateId.toString()).toList();
        });

        final List<TemplateModel> updatedTemplates = templates
            .where((t) => t.hasValidVideo)
            .map((template) {
              final isLiked = favIds.contains(template.id);
              return template.copyWith(isFavourite: isLiked);
            }).toList();

        // 🔥 SHUFFLE THE LIST ON CATEGORY ONTAP
        updatedTemplates.shuffle();
        _categoryPool = updatedTemplates;

        emit(
          state.copyWith(
            status: HomeStatus.loaded,
            templateList: _categoryPool,
            selectedCategoryName: event.categoryName,
            currentIndex: 0,
            reelsPaused: false,
            scrollLocked: false,
            isAdFlowRunning: false,
            hasMore: true,
          ),
        );
      },
    );
  }

  Future<void> _changeIndexEvent(
    ChangeIndexEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(currentIndex: event.index, reelsPaused: false));
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
