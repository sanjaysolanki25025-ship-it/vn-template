part of 'splash_bloc.dart';

enum SplashStatus { initial, loaded }

class SplashState {
  final SplashStatus status;

  SplashState({required this.status});

  SplashState copyWith({SplashStatus? status}) {
    return SplashState(status: status ?? this.status);
  }

  factory SplashState.initial() {
    return SplashState(status: SplashStatus.initial);
  }
}
