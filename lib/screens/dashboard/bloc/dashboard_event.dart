part of 'dashboard_bloc.dart';

abstract class DashboardEvent {}

class OnTapDashboardEvent extends DashboardEvent {
  final int index;

  OnTapDashboardEvent({required this.index});
}
