part of 'setting_bloc.dart';

enum SettingStatus { initial, loaded, error }

class SettingState {
  final SettingStatus status;
  final int selectedRateIndex;

  SettingState({
    required this.status,
    required this.selectedRateIndex,
  });

  SettingState copyWith({
    SettingStatus? status,
    int? selectedRateIndex,
  }) {
    return SettingState(
      status: status ?? this.status,
      selectedRateIndex: selectedRateIndex ?? this.selectedRateIndex,
    );
  }

  factory SettingState.initial() {
    return SettingState(
      status: SettingStatus.initial,
      selectedRateIndex: 5,
    );
  }
}
