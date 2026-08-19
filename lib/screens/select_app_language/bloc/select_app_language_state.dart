part of 'select_app_language_bloc.dart';

enum SelectAppLanguageStatus { initial, updated }

class SelectAppLanguageState {
  final SelectAppLanguageStatus status;
  final String selectedLanguageCode;

  SelectAppLanguageState({
    required this.status,
    required this.selectedLanguageCode,
  });

  SelectAppLanguageState copyWith({
    SelectAppLanguageStatus? status,
    String? selectedLanguageCode,
  }) {
    return SelectAppLanguageState(
      status: status ?? this.status,
      selectedLanguageCode: selectedLanguageCode ?? this.selectedLanguageCode,
    );
  }

  factory SelectAppLanguageState.initial(String languageCode) {
    return SelectAppLanguageState(
      status: SelectAppLanguageStatus.initial,
      selectedLanguageCode: languageCode,
    );
  }
}
