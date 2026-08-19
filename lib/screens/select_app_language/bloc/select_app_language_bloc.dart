import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_template/data/helper/preferences_helper.dart';
import 'package:vn_template/core/utils/localization_service.dart';
import 'package:vn_template/data/models/select_app_language_model.dart';

part 'select_app_language_event.dart';
part 'select_app_language_state.dart';


class SelectAppLanguageBloc extends Bloc<SelectAppLanguageEvent, SelectAppLanguageState> {
  final List<SelectAppLanguageModel> supportedLanguages = [
    SelectAppLanguageModel(code: 'en', name: 'English', flag: '🇺🇸'),
    SelectAppLanguageModel(code: 'hi', name: 'Hindi', flag: '🇮🇳'),
    SelectAppLanguageModel(code: 'es', name: 'Spanish', flag: '🇪🇸'),
    SelectAppLanguageModel(code: 'pt', name: 'Portuguese', flag: '🇵🇹'),
    SelectAppLanguageModel(code: 'de', name: 'German', flag: '🇩🇪'),
    SelectAppLanguageModel(code: 'fr', name: 'French', flag: '🇫🇷'),
    SelectAppLanguageModel(code: 'ar', name: 'Arabic', flag: '🇸🇦'),
    SelectAppLanguageModel(code: 'ko', name: 'Korean', flag: '🇰🇷'),
    SelectAppLanguageModel(code: 'tr', name: 'Turkish', flag: '🇹🇷'),
    SelectAppLanguageModel(code: 'id', name: 'Indonesian', flag: '🇮🇩'),
  ];

  SelectAppLanguageBloc() : super(SelectAppLanguageState.initial(AppPreferences().getString(AppPreferences.selectedLanguage) ?? 'en')) {
    on<ChangeLanguageEvent>(_onChangeLanguageEvent);
  }

  Future<void> _onChangeLanguageEvent(
      ChangeLanguageEvent event, Emitter<SelectAppLanguageState> emit) async {
    emit(state.copyWith(
        status: SelectAppLanguageStatus.updated,
        selectedLanguageCode: event.languageCode));
  }
}
