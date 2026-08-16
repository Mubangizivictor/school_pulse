import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/timetable.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../../domain/services/timetable_conflict_resolver.dart';
import 'timetable_event.dart';
import 'timetable_state.dart';

class TimetableBloc extends Bloc<TimetableEvent, TimetableState> {
  final TimetableRepository repository;
  final TimetableConflictResolver conflictResolver;

  StreamSubscription? _listSub;
  StreamSubscription? _lessonsSub;

  TimetableBloc({
    required this.repository,
    TimetableConflictResolver? conflictResolver,
  }) : conflictResolver = conflictResolver ?? const TimetableConflictResolver(),
       super(const TimetableState()) {
    on<TimetableListRequested>(_onListRequested);
    on<TimetableListUpdated>(
      (event, emit) => emit(
        state.copyWith(isLoadingList: false, timetables: event.timetables),
      ),
    );
    on<TimetableOpened>(_onOpened);
    on<TimetableDetailLoaded>(
      (event, emit) => emit(state.copyWith(current: event.timetable)),
    );
    on<TimetableLessonsUpdated>(
      (event, emit) => emit(state.copyWith(lessons: event.lessons)),
    );
    on<TimetableOtherLessonsLoaded>(
      (event, emit) => emit(state.copyWith(otherLessons: event.lessons)),
    );
    on<TimetableClosed>(_onClosed);
    on<TimetableCreateRequested>(_onCreateRequested);
    on<TimetableLessonSaveRequested>(_onLessonSaveRequested);
    on<TimetableLessonRemoveRequested>(_onLessonRemoveRequested);
    on<TimetablePublishRequested>(_onPublishRequested);
    on<TimetableArchiveRequested>(_onArchiveRequested);
  }

  Future<void> _onListRequested(
    TimetableListRequested event,
    Emitter<TimetableState> emit,
  ) async {
    emit(state.copyWith(isLoadingList: true, clearError: true));
    await _listSub?.cancel();
    _listSub = repository
        .watchTimetables(
          schoolId: event.schoolId,
          academicYearId: event.academicYearId,
          classId: event.classId,
        )
        .listen((timetables) => add(TimetableListUpdated(timetables)));
  }

  Future<void> _onOpened(
    TimetableOpened event,
    Emitter<TimetableState> emit,
  ) async {
    emit(state.copyWith(isLoadingDetail: true, clearError: true));
    try {
      final timetable = await repository.getTimetable(
        schoolId: event.schoolId,
        timetableId: event.timetableId,
      );
      if (timetable == null) {
        emit(
          state.copyWith(
            isLoadingDetail: false,
            errorMessage: 'This timetable could not be found.',
          ),
        );
        return;
      }
      add(TimetableDetailLoaded(timetable));

      await _lessonsSub?.cancel();
      _lessonsSub = repository
          .watchLessons(schoolId: event.schoolId, timetableId: timetable.id)
          .listen((lessons) => add(TimetableLessonsUpdated(lessons)));

      final others = await repository.getAllLessonsForYear(
        schoolId: event.schoolId,
        academicYearId: timetable.academicYearId,
        termId: timetable.termId,
      );
      add(
        TimetableOtherLessonsLoaded(
          others.where((l) => l.timetableId != timetable.id).toList(),
        ),
      );

      emit(state.copyWith(isLoadingDetail: false));
    } catch (e) {
      emit(state.copyWith(isLoadingDetail: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onClosed(
    TimetableClosed event,
    Emitter<TimetableState> emit,
  ) async {
    await _lessonsSub?.cancel();
    _lessonsSub = null;
    emit(state.copyWith(clearCurrent: true));
  }

  Future<void> _onCreateRequested(
    TimetableCreateRequested event,
    Emitter<TimetableState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final id = await repository.createTimetable(event.draft);
      emit(state.copyWith(isSaving: false));
      add(TimetableOpened(schoolId: event.draft.schoolId, timetableId: id));
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLessonSaveRequested(
    TimetableLessonSaveRequested event,
    Emitter<TimetableState> emit,
  ) async {
    final pool = [...state.lessons, ...state.otherLessons];
    final conflicts = conflictResolver.findConflicts(
      candidate: event.lesson,
      otherLessons: pool,
    );
    if (conflicts.isNotEmpty) {
      emit(state.copyWith(lastSaveConflicts: conflicts));
      return;
    }

    emit(
      state.copyWith(
        isSaving: true,
        clearError: true,
        lastSaveConflicts: const [],
      ),
    );
    try {
      await repository.upsertLesson(event.lesson);
      emit(state.copyWith(isSaving: false));
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLessonRemoveRequested(
    TimetableLessonRemoveRequested event,
    Emitter<TimetableState> emit,
  ) async {
    final schoolId = state.current?.schoolId;
    if (schoolId == null) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await repository.deleteLesson(
        schoolId: schoolId,
        lessonId: event.lessonId,
      );
      emit(state.copyWith(isSaving: false));
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onPublishRequested(
    TimetablePublishRequested event,
    Emitter<TimetableState> emit,
  ) async {
    final current = state.current;
    if (current == null) return;

    final scan = conflictResolver.scanAll(
      lessons: [...state.lessons, ...state.otherLessons],
    );
    // Only conflicts touching a lesson that belongs to this timetable block
    // publishing - a pre-existing conflict purely between two other
    // timetables is not this timetable's problem to fix.
    final ownLessonIds = state.lessons.map((l) => l.id).toSet();
    final blocking = Map.fromEntries(
      scan.entries.where((e) => ownLessonIds.contains(e.key)),
    );
    if (blocking.isNotEmpty) {
      emit(state.copyWith(publishConflicts: blocking));
      return;
    }

    emit(
      state.copyWith(
        isSaving: true,
        clearError: true,
        publishConflicts: const {},
      ),
    );
    try {
      await repository.updateTimetable(
        current.copyWith(
          status: TimetableStatus.active,
          publishedAt: DateTime.now(),
          publishedBy: event.publishedBy,
          updatedAt: DateTime.now(),
          updatedBy: event.publishedBy,
        ),
      );
      emit(state.copyWith(isSaving: false));
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onArchiveRequested(
    TimetableArchiveRequested event,
    Emitter<TimetableState> emit,
  ) async {
    final current = state.current;
    if (current == null) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await repository.updateTimetable(
        current.copyWith(
          status: TimetableStatus.archived,
          archivedAt: DateTime.now(),
          archivedBy: event.archivedBy,
          updatedAt: DateTime.now(),
          updatedBy: event.archivedBy,
        ),
      );
      emit(state.copyWith(isSaving: false));
    } catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _listSub?.cancel();
    _lessonsSub?.cancel();
    return super.close();
  }
}
