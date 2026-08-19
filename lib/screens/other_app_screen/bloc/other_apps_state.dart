part of 'other_apps_bloc.dart';

enum OtherAppsStatus { initial, loading, loaded, error }

class OtherAppsState {
  final OtherAppsStatus status;
  final List<OtherAppModel> apps;
  final String? errorMessage;

  OtherAppsState({required this.status, required this.apps, this.errorMessage});

  OtherAppsState copyWith({
    OtherAppsStatus? status,
    List<OtherAppModel>? apps,
    String? errorMessage,
  }) {
    return OtherAppsState(
      status: status ?? this.status,
      apps: apps ?? this.apps,
      errorMessage: errorMessage,
    );
  }

  factory OtherAppsState.initial() {
    return OtherAppsState(status: OtherAppsStatus.initial, apps: []);
  }
}
