import 'package:equatable/equatable.dart';
import '../../domain/entities/announcement_entity.dart';

abstract class AnnouncementState extends Equatable {
  const AnnouncementState();

  @override
  List<Object?> get props => [];
}

class AnnouncementInitial extends AnnouncementState {}

class AnnouncementLoading extends AnnouncementState {}

class AnnouncementLoaded extends AnnouncementState {
  final List<AnnouncementEntity> announcements;
  final bool canManage;

  const AnnouncementLoaded({
    required this.announcements,
    required this.canManage,
  });

  @override
  List<Object?> get props => [announcements, canManage];
}

class AnnouncementError extends AnnouncementState {
  final String message;
  const AnnouncementError(this.message);

  @override
  List<Object?> get props => [message];
}

class AnnouncementActionDenied extends AnnouncementState {
  final String message;
  const AnnouncementActionDenied(this.message);

  @override
  List<Object?> get props => [message];
}

class AnnouncementActionSuccess extends AnnouncementState {
  final String message;
  const AnnouncementActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
