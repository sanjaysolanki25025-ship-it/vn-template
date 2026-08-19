part of 'dashboard_bloc.dart';

class DashboardState {
  final int currentIndex;

  const DashboardState({this.currentIndex = 0});

  factory DashboardState.initial() {
    return const DashboardState();
  }

  DashboardState copyWith({
    int? currentIndex,
  }) {
    return DashboardState(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}
