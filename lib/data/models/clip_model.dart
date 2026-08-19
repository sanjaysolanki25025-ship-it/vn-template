class ClipModel {
  final String numberClip;
  final bool isSelected;
  final bool isApplied;

  ClipModel({
    required this.numberClip,
    this.isSelected = false,
    this.isApplied = false,
  });

  ClipModel copyWith({String? numberClip, bool? isSelected, bool? isApplied}) {
    return ClipModel(
      numberClip: numberClip ?? this.numberClip,
      isSelected: isSelected ?? this.isSelected,
      isApplied: isApplied ?? this.isApplied,
    );
  }
}
