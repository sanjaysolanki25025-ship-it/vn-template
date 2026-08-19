class DurationModel {
  final String duration;
  final bool isSelected;
  final bool isApplied;

  DurationModel({
    required this.duration,
    this.isSelected = false,
    this.isApplied = false,
  });

  DurationModel copyWith({
    String? duration,
    bool? isSelected,
    bool? isApplied,
  }) {
    return DurationModel(
      duration: duration ?? this.duration,
      isSelected: isSelected ?? this.isSelected,
      isApplied: isApplied ?? this.isApplied,
    );
  }
}
