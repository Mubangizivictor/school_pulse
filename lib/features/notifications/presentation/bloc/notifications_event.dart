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

class SendNotification extends NotificationsEvent {
  final String title;
  final String body;
  final List<String> targetGroups;
  final String? imageUrl;
  final bool isAnnouncement;

  const SendNotification({
    required this.title,
    required this.body,
    required this.targetGroups,
    this.imageUrl,
    this.isAnnouncement = false,
  });

  @override
  List<Object> get props => [title, body, targetGroups, imageUrl ?? '', isAnnouncement];
}
