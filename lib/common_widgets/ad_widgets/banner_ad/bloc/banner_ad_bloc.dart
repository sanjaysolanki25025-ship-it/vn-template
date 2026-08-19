import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'banner_ad_event.dart';

part 'banner_ad_state.dart';

class BannerAdBloc extends Bloc<BannerAdEvent, BannerAdState> {
  BannerAdBloc() : super(BannerAdState()) {
    on<ShowBannerAdEvent>(_showBannerAdEvent);
  }

  /// show banner ad
  FutureOr<void> _showBannerAdEvent(
    ShowBannerAdEvent event,
    Emitter<BannerAdState> emit,
  ) {
    emit(
      state.copyWith(
        isShowBanner: event.isShowBanner,
        bannerAd: event.bannerAd,
      ),
    );
  }
}
