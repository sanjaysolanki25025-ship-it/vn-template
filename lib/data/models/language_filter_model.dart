class LanguageFilterModel {
  final String language;
  final bool isSelected;
  final bool isApplied;

  LanguageFilterModel({
    required this.language,
    this.isSelected = false,
    this.isApplied = false,
  });

  LanguageFilterModel copyWith({
    String? language,
    bool? isSelected,
    bool? isApplied,
  }) {
    return LanguageFilterModel(
      language: language ?? this.language,
      isSelected: isSelected ?? this.isSelected,
      isApplied: isApplied ?? this.isApplied,
    );
  }
}