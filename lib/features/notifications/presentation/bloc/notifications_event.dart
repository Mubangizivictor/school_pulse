import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class FetchAlerts extends NotificationsEvent {
  final List<String> studentIds;
  final List<String> groups;
  const FetchAlerts(this.studentIds, {this.groups = const []});

  @override
  List<Object> get props => [studentIds, groups];
}

class DismissAlert extends NotificationsEvent {
  final String alertId;
  final String uid;
  const DismissAlert(this.alertId, this.uid);

  @override
  List<Object> get props => [alertId, uid];
}
