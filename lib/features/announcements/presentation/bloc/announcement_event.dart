import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import '../../domain/entities/announcement_entity.dart';

abstract class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnnouncementsRequested extends AnnouncementEvent {
  final String schoolId;
  final UserEntity operatorUser;

  const LoadAnnouncementsRequested({
    required this.schoolId,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [schoolId, operatorUser];
}

class CreateAnnouncementRequested extends AnnouncementEvent {
  final AnnouncementEntity announcement;
  final UserEntity operatorUser;

  const CreateAnnouncementRequested({
    required this.announcement,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [announcement, operatorUser];
}

class UpdateAnnouncementRequested extends AnnouncementEvent {
  final AnnouncementEntity announcement;
  final UserEntity operatorUser;

  const UpdateAnnouncementRequested({
    required this.announcement,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [announcement, operatorUser];
}

class DeleteAnnouncementRequested extends AnnouncementEvent {
  final String schoolId;
  final String announcementId;
  final UserEntity operatorUser;

  const DeleteAnnouncementRequested({
    required this.schoolId,
    required this.announcementId,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [schoolId, announcementId, operatorUser];
}

class PublishAnnouncementRequested extends AnnouncementEvent {
  final String schoolId;
  final String announcementId;
  final UserEntity operatorUser;

  const PublishAnnouncementRequested({
    required this.schoolId,
    required this.announcementId,
    required this.operatorUser,
  });

  @override
  List<Object?> get props => [schoolId, announcementId, operatorUser];
}
