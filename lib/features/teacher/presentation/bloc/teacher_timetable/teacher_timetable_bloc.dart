import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/timetable.dart';
import 'package:school_pulse/features/structure/domain/entities/timetable_config.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/domain/repositories/timetable_repository.dart';

import '../shared/teacher_timetable_entry.dart';

export '../shared/teacher_timetable_entry.dart' show TeacherTimetableEntry;

abstract class TeacherTimetableEvent extends Equatable {
  const TeacherTimetableEvent();

  @override
  List<Object?> get props => [];
}

class TeacherTimetableRequested extends TeacherTimetableEvent {
  final String schoolId;
  final String teacherId;

  const TeacherTimetableRequested({
    required this.schoolId,
    required this.teacherId,
  });

  @override
  List<Object?> get props => [schoolId, teacherId];
}

class TeacherTimetableState extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  /// Every lesson at the school for the current year, resolved against real
  /// slot times. [myEntries] narrows this to the requesting teacher for the
  /// "My Timetable" tab; "Full School" reads [allEntries] directly.
  final List<TeacherTimetableEntry> allEntries;
  final String teacherId;

  const TeacherTimetableState({
    this.isLoading = false,
    this.errorMessage,
    this.allEntries = const [],
    this.teacherId = '',
  });

  const TeacherTimetableState.initial() : this(isLoading: true);

  List<TeacherTimetableEntry> get myEntries =>
      allEntries.where((e) => e.lesson.teacherId == teacherId).toList();

  List<String> daysOf(List<TeacherTimetableEntry> entries) =>
      distinctTimetableDays(entries);

  List<TeacherTimetableEntry> entriesFor(
    List<TeacherTimetableEntry> entries,
    String day,
  ) => timetableEntriesForDay(entries, day);

  TeacherTimetableState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TeacherTimetableEntry>? allEntries,
    String? teacherId,
    bool clearError = false,
  }) {
    return TeacherTimetableState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      allEntries: allEntries ?? this.allEntries,
      teacherId: teacherId ?? this.teacherId,
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, allEntries, teacherId];
}

class TeacherTimetableBloc
    extends Bloc<TeacherTimetableEvent, TeacherTimetableState> {
  final TimetableRepository timetableRepository;
  final StructureRepository structureRepository;

  StreamSubscription<List<AcademicYear>>? _yearsSub;
  StreamSubscription<TimetableConfig>? _configSub;

  TimetableConfig? _config;
  List<TimetableLesson> _lessons = const [];

  TeacherTimetableBloc({
    required this.timetableRepository,
    required this.structureRepository,
  }) : super(const TeacherTimetableState.initial()) {
    on<TeacherTimetableRequested>(_onRequested);
  }

  // The two subscriptions below outlive a single dispatch of this handler,
  // so the handler must not return while they can still fire - an Emitter
  // captured past the point its owning handler's Future completes throws
  // 'Bad state: Cannot emit after calling close' (previously seen live as
  // "Failed assertion: '!_isCompleted'"). Keeping the handler alive on a
  // Completer that only resolves in close() (or when a newer request
  // supersedes this one) keeps `emit` valid for as long as these listeners
  // can use it, and `emit.isDone` still guards against the bloc closing
  // mid-flight.
  Completer<void>? _requestLifetime;

  Future<void> _onRequested(
    TeacherTimetableRequested event,
    Emitter<TeacherTimetableState> emit,
  ) async {
    await _yearsSub?.cancel();
    await _configSub?.cancel();
    _requestLifetime?.complete();
    final lifetime = Completer<void>();
    _requestLifetime = lifetime;

    emit(TeacherTimetableState(isLoading: true, teacherId: event.teacherId));

    _configSub = structureRepository
        .watchTimetableConfig(event.schoolId)
        .listen((config) {
          _config = config;
          _emitEntries(emit);
        }, onError: (_) {});

    _yearsSub = structureRepository.watchAcademicYears(event.schoolId).listen(
      (years) async {
        final current = years.where((y) => y.isCurrent).firstOrNull;
        if (current == null) {
          if (!emit.isDone) {
            emit(
              state.copyWith(
                isLoading: false,
                errorMessage:
                    'No active academic year is set for this school.',
              ),
            );
          }
          return;
        }

        try {
          _lessons = await timetableRepository.getAllLessonsForYear(
            schoolId: event.schoolId,
            academicYearId: current.id,
          );
          _emitEntries(emit);
        } catch (_) {
          if (!emit.isDone) {
            emit(
              state.copyWith(
                isLoading: false,
                errorMessage:
                    'Could not load the timetable. Pull down to retry.',
              ),
            );
          }
        }
      },
      onError: (_) {
        if (!emit.isDone) {
          emit(
            state.copyWith(
              isLoading: false,
              errorMessage: 'Could not load the timetable. Pull down to retry.',
            ),
          );
        }
      },
    );

    // Held open for the lifetime of this request so `emit` above stays
    // valid for the stream listeners; released by close() or a superseding
    // TeacherTimetableRequested.
    await lifetime.future;
  }

  void _emitEntries(Emitter<TeacherTimetableState> emit) {
    if (emit.isDone) return;
    final config = _config;
    if (config == null) return;

    final entries = mapLessonsToTimetableEntries(
      lessons: _lessons,
      config: config,
    );

    emit(
      state.copyWith(isLoading: false, allEntries: entries, clearError: true),
    );
  }

  @override
  Future<void> close() async {
    await _yearsSub?.cancel();
    await _configSub?.cancel();
    _requestLifetime?.complete();
    return super.close();
  }
}
