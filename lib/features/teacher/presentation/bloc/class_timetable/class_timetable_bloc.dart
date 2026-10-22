import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/structure/domain/entities/timetable.dart';
import 'package:school_pulse/features/structure/domain/entities/timetable_config.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/domain/repositories/timetable_repository.dart';

import '../../../domain/entities/active_responsibility_context.dart';
import '../shared/teacher_timetable_entry.dart';

abstract class ClassTimetableEvent extends Equatable {
  const ClassTimetableEvent();

  @override
  List<Object?> get props => [];
}

class ClassTimetableRequested extends ClassTimetableEvent {
  final ActiveResponsibilityContext context;

  const ClassTimetableRequested(this.context);

  @override
  List<Object?> get props => [context];
}

/// See [TeacherTimetableEntry] - the shape is identical between the Class
/// Teacher and Subject Teacher timetables, only the query that produces the
/// lesson list differs.
typedef ClassTimetableEntry = TeacherTimetableEntry;

class ClassTimetableState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? roleAssignmentId;
  final Timetable? timetable;
  final List<ClassTimetableEntry> entries;

  const ClassTimetableState({
    this.isLoading = false,
    this.errorMessage,
    this.roleAssignmentId,
    this.timetable,
    this.entries = const [],
  });

  const ClassTimetableState.initial() : this(isLoading: true);

  /// True once a real timetable has been published for this class - a draft
  /// or an absent one both mean "nothing to show yet", not an error.
  bool get hasPublishedTimetable => timetable != null;

  List<String> get days => distinctTimetableDays(entries);

  List<ClassTimetableEntry> entriesFor(String day) =>
      timetableEntriesForDay(entries, day);

  ClassTimetableState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? roleAssignmentId,
    Timetable? timetable,
    List<ClassTimetableEntry>? entries,
    bool clearError = false,
    bool clearTimetable = false,
  }) {
    return ClassTimetableState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      roleAssignmentId: roleAssignmentId ?? this.roleAssignmentId,
      timetable: clearTimetable ? null : (timetable ?? this.timetable),
      entries: entries ?? this.entries,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    roleAssignmentId,
    timetable,
    entries,
  ];
}

class ClassTimetableBloc
    extends Bloc<ClassTimetableEvent, ClassTimetableState> {
  final TimetableRepository timetableRepository;
  final StructureRepository structureRepository;

  StreamSubscription<List<Timetable>>? _timetableSub;
  StreamSubscription<List<TimetableLesson>>? _lessonsSub;
  StreamSubscription<TimetableConfig>? _configSub;

  TimetableConfig? _config;
  List<TimetableLesson> _lessons = const [];

  // See TeacherTimetableBloc for why this exists: the subscriptions set up
  // below outlive a single dispatch of _onRequested, so the handler must
  // stay open on this Completer (resolved by close() or a superseding
  // ClassTimetableRequested) for as long as they can still call `emit` -
  // otherwise every listener callback below throws once the handler's
  // Future would otherwise have completed.
  Completer<void>? _requestLifetime;

  ClassTimetableBloc({
    required this.timetableRepository,
    required this.structureRepository,
  }) : super(const ClassTimetableState.initial()) {
    on<ClassTimetableRequested>(_onRequested);
  }

  Future<void> _onRequested(
    ClassTimetableRequested event,
    Emitter<ClassTimetableState> emit,
  ) async {
    final classId = event.context.classId;
    if (classId == null || classId.isEmpty) {
      emit(
        const ClassTimetableState(
          isLoading: false,
          errorMessage: 'This responsibility is not tied to a class.',
        ),
      );
      return;
    }

    await _timetableSub?.cancel();
    await _lessonsSub?.cancel();
    await _configSub?.cancel();
    _requestLifetime?.complete();
    final lifetime = Completer<void>();
    _requestLifetime = lifetime;

    // Start clean rather than copyWith: switching classes must not show the
    // previous class's grid while the new one loads.
    emit(
      ClassTimetableState(
        isLoading: true,
        roleAssignmentId: event.context.roleAssignmentId,
      ),
    );

    _configSub = structureRepository
        .watchTimetableConfig(event.context.schoolId)
        .listen(
          (config) {
            _config = config;
            _emitEntries(emit, event.context.roleAssignmentId);
          },
          onError: (_) {
            // A missing config leaves lessons without times to show against -
            // the timetable stream below still drives isLoading/errorMessage.
          },
        );

    _timetableSub = timetableRepository
        .watchTimetables(
          schoolId: event.context.schoolId,
          academicYearId: event.context.academicYearId,
          classId: classId,
        )
        .listen(
          (timetables) {
            if (emit.isDone ||
                state.roleAssignmentId != event.context.roleAssignmentId) {
              return;
            }

            final published = _activeFor(
              timetables,
              streamId: event.context.streamId,
            );

            _lessonsSub?.cancel();
            if (published == null) {
              _lessons = const [];
              emit(
                state.copyWith(
                  isLoading: false,
                  clearTimetable: true,
                  entries: const [],
                  clearError: true,
                ),
              );
              return;
            }

            emit(state.copyWith(timetable: published, clearError: true));
            _lessonsSub = timetableRepository
                .watchLessons(
                  schoolId: event.context.schoolId,
                  timetableId: published.id,
                )
                .listen(
                  (lessons) {
                    _lessons = lessons;
                    _emitEntries(emit, event.context.roleAssignmentId);
                  },
                  onError: (_) {
                    if (!emit.isDone) {
                      emit(
                        state.copyWith(
                          isLoading: false,
                          errorMessage:
                              'Could not load this timetable. Pull down to retry.',
                        ),
                      );
                    }
                  },
                );
          },
          onError: (_) {
            if (!emit.isDone) {
              emit(
                state.copyWith(
                  isLoading: false,
                  errorMessage:
                      'Could not load the timetable. Pull down to retry.',
                ),
              );
            }
          },
        );

    // Held open for the lifetime of this request so `emit` above stays
    // valid for the stream listeners; released by close() or a superseding
    // ClassTimetableRequested.
    await lifetime.future;
  }

  /// The single active timetable for this class/stream target. Draft and
  /// archived versions of the same target are expected to coexist per
  /// [Timetable]'s own contract, so only [TimetableStatus.published] is ever
  /// shown to a teacher - a draft is not yet real.
  Timetable? _activeFor(List<Timetable> timetables, {String? streamId}) {
    final active = timetables.where(
      (t) => t.status == TimetableStatus.published,
    );
    if (streamId != null && streamId.isNotEmpty) {
      for (final t in active) {
        if (t.streamId == streamId) return t;
      }
    }
    for (final t in active) {
      if (t.streamId.isEmpty) return t;
    }
    return active.isEmpty ? null : active.first;
  }

  void _emitEntries(
    Emitter<ClassTimetableState> emit,
    String roleAssignmentId,
  ) {
    if (emit.isDone || state.roleAssignmentId != roleAssignmentId) return;

    final config = _config;
    if (config == null) return;

    final entries = mapLessonsToTimetableEntries(
      lessons: _lessons,
      config: config,
    );

    emit(state.copyWith(isLoading: false, entries: entries, clearError: true));
  }

  @override
  Future<void> close() async {
    await _timetableSub?.cancel();
    await _lessonsSub?.cancel();
    await _configSub?.cancel();
    _requestLifetime?.complete();
    return super.close();
  }
}
