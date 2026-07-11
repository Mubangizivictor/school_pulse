import 'package:equatable/equatable.dart';
import '../../domain/entities/alert.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<Alert> alerts;
  const NotificationsLoaded(this.alerts);

  @override
  List<Object> get props => [alerts];
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);

  @override
  List<Object> get props => [message];
}
