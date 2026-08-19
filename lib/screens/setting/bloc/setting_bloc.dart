import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vn_template/core/constant/app_string.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(SettingState.initial()) {
    on<ChangeRateUsEvent>(_changeRateUsEvent);
    on<RateUsEvent>(_rateUsEvent);
  }

  Future<void> _changeRateUsEvent(ChangeRateUsEvent event, Emitter<SettingState> emit) async {
    emit(state.copyWith(selectedRateIndex: event.selectedRateIndex));
  }

  Future<void> _rateUsEvent(RateUsEvent event, Emitter<SettingState> emit) async {
    final uri = Uri.parse(AppStrings.appLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
