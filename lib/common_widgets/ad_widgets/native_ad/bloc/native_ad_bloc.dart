import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

part 'native_ad_event.dart';

part 'native_ad_state.dart';

class NativeAdBloc extends Bloc<NativeAdEvent, NativeAdState> {
  NativeAdBloc() : super(NativeAdState.initial()) {
    on<ShowNativeAdEvent>(_showNativeAdEvent);
  }

  /// show native ad
  FutureOr<void> _showNativeAdEvent(ShowNativeAdEvent event, Emitter<NativeAdState> emit) {
    emit(state.copyWith(isShowNative: event.isShowNative));
  }
}