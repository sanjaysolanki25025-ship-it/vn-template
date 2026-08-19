part of 'setting_bloc.dart';

abstract class SettingEvent {}

class ChangeRateUsEvent extends SettingEvent {
  final int selectedRateIndex;
  
  ChangeRateUsEvent({required this.selectedRateIndex});
}

class RateUsEvent extends SettingEvent {}
