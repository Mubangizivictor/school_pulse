import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import '../../domain/repositories/announcement_repository.dart';
import 'announcement_event.dart';
import 'announcement_state.dart';

class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final AnnouncementRepository repository;
  final PermissionEvaluator permissionEvaluator;

  AnnouncementBloc({
    required this.repository,
    required this.permissionEvaluator,
  }) : super(AnnouncementInitial()) {
    on<LoadAnnouncementsRequested>(_onLoad);
    on<CreateAnnouncementRequested>(_onCreate);
    on<UpdateAnnouncementRequested>(_onUpdate);
    on<DeleteAnnouncementRequested>(_onDelete);
    on<PublishAnnouncementRequested>(_onPublish);
  }

  Future<bool> _canManage(dynamic operatorUser) async {
    final result = await permissionEvaluator.can(
      Permission.announcementManage,
      operatorUser,
    );
    return result.fold((failure) => false, (allowed) => allowed);
  }

  Future<void> _onLoad(
    LoadAnnouncementsRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    emit(AnnouncementLoading());

    final canManage = await _canManage(event.operatorUser);

    final result = await repository.getAnnouncements(
      event.schoolId,
      publishedOnly: !canManage,
    );
    result.fold(
      (failure) => emit(AnnouncementError(failure.message)),
      (announcements) => emit(
        AnnouncementLoaded(announcements: announcements, canManage: canManage),
      ),
    );
  }

  Future<void> _onCreate(
    CreateAnnouncementRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    final allowed = await _canManage(event.operatorUser);
    if (!allowed) {
      emit(
        const AnnouncementActionDenied(
          'You do not have permission to manage announcements.',
        ),
      );
      return;
    }

    final result = await repository.upsertAnnouncement(event.announcement);
    result.fold(
      (failure) => emit(AnnouncementError(failure.message)),
      (_) => emit(const AnnouncementActionSuccess('Announcement saved')),
    );

    add(
      LoadAnnouncementsRequested(
        schoolId: event.announcement.schoolId,
        operatorUser: event.operatorUser,
      ),
    );
  }

  Future<void> _onUpdate(
    UpdateAnnouncementRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    final allowed = await _canManage(event.operatorUser);
    if (!allowed) {
      emit(
        const AnnouncementActionDenied(
          'You do not have permission to manage announcements.',
        ),
      );
      return;
    }

    final result = await repository.upsertAnnouncement(event.announcement);
    result.fold(
      (failure) => emit(AnnouncementError(failure.message)),
      (_) => emit(const AnnouncementActionSuccess('Announcement updated')),
    );

    add(
      LoadAnnouncementsRequested(
        schoolId: event.announcement.schoolId,
        operatorUser: event.operatorUser,
      ),
    );
  }

  Future<void> _onDelete(
    DeleteAnnouncementRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    final allowed = await _canManage(event.operatorUser);
    if (!allowed) {
      emit(
        const AnnouncementActionDenied(
          'You do not have permission to manage announcements.',
        ),
      );
      return;
    }

    final result = await repository.deleteAnnouncement(
      event.schoolId,
      event.announcementId,
    );
    result.fold(
      (failure) => emit(AnnouncementError(failure.message)),
      (_) => emit(const AnnouncementActionSuccess('Announcement removed')),
    );

    add(
      LoadAnnouncementsRequested(
        schoolId: event.schoolId,
        operatorUser: event.operatorUser,
      ),
    );
  }

  Future<void> _onPublish(
    PublishAnnouncementRequested event,
    Emitter<AnnouncementState> emit,
  ) async {
    final allowed = await _canManage(event.operatorUser);
    if (!allowed) {
      emit(
        const AnnouncementActionDenied(
          'You do not have permission to manage announcements.',
        ),
      );
      return;
    }

    final result = await repository.publishAnnouncement(
      event.schoolId,
      event.announcementId,
    );
    result.fold(
      (failure) => emit(AnnouncementError(failure.message)),
      (_) => emit(const AnnouncementActionSuccess('Announcement published')),
    );

    add(
      LoadAnnouncementsRequested(
        schoolId: event.schoolId,
        operatorUser: event.operatorUser,
      ),
    );
  }
}
