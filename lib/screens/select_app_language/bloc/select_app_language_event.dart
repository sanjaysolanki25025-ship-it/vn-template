part of 'select_app_language_bloc.dart';

abstract class SelectAppLanguageEvent {}

class ChangeLanguageEvent extends SelectAppLanguageEvent {
  final String languageCode;
  ChangeLanguageEvent(this.languageCode);
}
