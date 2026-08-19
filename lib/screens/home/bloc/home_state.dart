part of 'home_bloc.dart';

enum HomeStatus {
  initial,
  loading,
  loaded,
  error,
  favouriteLoading,
  favouriteLoaded,
  favouriteError,
  rewardAdError,
  rewardAdLoading,
  rewardAdLoaded,
  createLoading,
  createLoaded,
  downloadVNApp,
}

class HomeState {
  final HomeStatus? status;
  final String? errorMessage;
  final List<TemplateModel>? templateList;
  final bool pageLoading;
  final bool hasMore;
  final int currentIndex;
  final List<CategoryModel>? allCategories;
  final String? selectedCategoryName;
  final bool? reelAdLocked;
  final bool? scrollLocked;
  final bool reelsPaused;
  final bool isFiltering;
  final bool isAnimatingToPage;
  final bool isAdFlowRunning;
  final int lastCategoryIndex;
  final bool isHowSlideUpLottie;
  final TemplateModel? model;

  HomeState({
    this.status,
    this.errorMessage,
    this.templateList,
    this.pageLoading = false,
    this.hasMore = true,
    this.currentIndex = 0,
    this.allCategories,
    this.selectedCategoryName,
    this.reelAdLocked,
    this.scrollLocked,
    this.reelsPaused = false,
    this.isFiltering = false,
    this.isAnimatingToPage = false,
    this.isAdFlowRunning = false,
    this.lastCategoryIndex = -1,
    this.isHowSlideUpLottie = true,
    this.model,
  });

  HomeState copyWith({
    HomeStatus? status,
    String? errorMessage,
    List<TemplateModel>? templateList,
    bool? pageLoading,
    bool? hasMore,
    int? currentPage,
    int? currentIndex,
    List<CategoryModel>? allCategories,
    String? selectedCategoryName,
    bool? reelAdLocked,
    bool? scrollLocked,
    bool? reelsPaused,
    bool? isFiltering,
    bool? isAnimatingToPage,
    bool? isAdFlowRunning,
    int? lastCategoryIndex,
    bool? isHowSlideUpLottie,
    TemplateModel? model,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      templateList: templateList ?? this.templateList,
      pageLoading: pageLoading ?? this.pageLoading,
      hasMore: hasMore ?? this.hasMore,
      currentIndex: currentIndex ?? this.currentIndex,
      allCategories: allCategories ?? this.allCategories,
      selectedCategoryName: selectedCategoryName ?? this.selectedCategoryName,
      reelAdLocked: reelAdLocked ?? this.reelAdLocked,
      scrollLocked: scrollLocked ?? this.scrollLocked,
      reelsPaused: reelsPaused ?? this.reelsPaused,
      isFiltering: isFiltering ?? this.isFiltering,
      isAnimatingToPage: isAnimatingToPage ?? this.isAnimatingToPage,
      isAdFlowRunning: isAdFlowRunning ?? this.isAdFlowRunning,
      lastCategoryIndex: lastCategoryIndex ?? this.lastCategoryIndex,
      isHowSlideUpLottie: isHowSlideUpLottie ?? this.isHowSlideUpLottie,
      model: model ?? this.model,
    );
  }

  factory HomeState.initial() {
    return HomeState(
      status: HomeStatus.initial,
      errorMessage: null,
      templateList: [],
      pageLoading: false,
      hasMore: true,
      currentIndex: 0,
      allCategories: [],
      selectedCategoryName: 'All',
      reelAdLocked: false,
      scrollLocked: false,
      reelsPaused: false,
      isFiltering: false,
      isAnimatingToPage: false,
      isAdFlowRunning: false,
      lastCategoryIndex: -1,
      isHowSlideUpLottie: true,
      model: null,
    );
  }
}
