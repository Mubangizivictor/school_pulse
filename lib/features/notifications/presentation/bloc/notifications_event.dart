import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class FetchAlerts extends NotificationsEvent {
  final List<String> studentIds;
  const FetchAlerts(this.studentIds);

  @override
  List<Object> get props => [studentIds];
}
