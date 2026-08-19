part of 'discover_bloc.dart';

enum DiscoverStatus { initial, loading, loaded, error, rewardAdLoading, rewardAdLoaded }

class DiscoverState {
  final DiscoverStatus status;
  final List<TemplateModel> templates;
  final List<CategoryModel> categories;
  final int selectedCategoryIndex;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;

  const DiscoverState({
    this.status = DiscoverStatus.initial,
    this.templates = const [],
    this.categories = const [],
    this.selectedCategoryIndex = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  DiscoverState copyWith({
    DiscoverStatus? status,
    List<TemplateModel>? templates,
    List<CategoryModel>? categories,
    int? selectedCategoryIndex,
    bool? hasMore,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return DiscoverState(
      status: status ?? this.status,
      templates: templates ?? this.templates,
      categories: categories ?? this.categories,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
