import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'package:school_pulse/features/structure/domain/entities/timetable.dart';
import 'package:school_pulse/features/structure/domain/entities/timetable_config.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/domain/repositories/timetable_repository.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/shared/teacher_timetable_entry.dart';

/// See [TeacherTimetableEntry] - identical row shape to the teacher-facing
/// timetable blocs, only the query target (a student's class/stream rather
/// than a teacher's responsibility) differs.
typedef ParentTimetableEntry = TeacherTimetableEntry;

abstract class ParentTimetableEvent extends Equatable {
  const ParentTimetableEvent();

  @override
  List<Object?> get props => [];
}

/// Requests the published timetable for a child's class/stream. Re-fires
/// automatically whenever the selected child (and therefore class) changes.
class ParentTimetableRequested extends ParentTimetableEvent {
  final String schoolId;
  final String academicYearId;
  final String classId;
  final String? streamId;

  const ParentTimetableRequested({
    required this.schoolId,
    required this.academicYearId,
    required this.classId,
    this.streamId,
  });

  @override
  List<Object?> get props => [schoolId, academicYearId, classId, streamId];
}

class ParentTimetableState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final String? classId;
  final Timetable? timetable;
  final List<ParentTimetableEntry> entries;

  const ParentTimetableState({
    this.isLoading = false,
    this.errorMessage,
    this.classId,
    this.timetable,
    this.entries = const [],
  });

  const ParentTimetableState.initial() : this(isLoading: true);

  /// True once a real timetable has been published for this class - a draft
  /// or an absent one both mean "nothing to show yet", not an error.
  bool get hasPublishedTimetable => timetable != null;

  List<String> get days => distinctTimetableDays(entries);

  List<ParentTimetableEntry> entriesFor(String day) =>
      timetableEntriesForDay(entries, day);

  ParentTimetableState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? classId,
    Timetable? timetable,
    List<ParentTimetableEntry>? entries,
    bool clearError = false,
    bool clearTimetable = false,
  }) {
    return ParentTimetableState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      classId: classId ?? this.classId,
      timetable: clearTimetable ? null : (timetable ?? this.timetable),
      entries: entries ?? this.entries,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    classId,
    timetable,
    entries,
  ];
}

/// Parent-facing counterpart of `ClassTimetableBloc`: resolves the single
/// published timetable for a child's class/stream and exposes it as
/// day-keyed [ParentTimetableEntry] rows, reused by both the Home tab's
/// "next lesson" tile and the Learn tab's full Timetable sub-tab.
///
/// Deliberately not a modification of `ClassTimetableBloc` - that bloc is
/// scoped to a teacher's `ActiveResponsibilityContext`, a concept that does
/// not apply to a parent/child. The watch-timetables -> pick-published ->
/// watch-lessons -> map-to-entries pipeline is duplicated here rather than
/// generalized across both, since the two blocs are keyed by unrelated
/// context types.
class ParentTimetableBloc
    extends Bloc<ParentTimetableEvent, ParentTimetableState> {
  final TimetableRepository timetableRepository;
  final StructureRepository structureRepository;

  StreamSubscription<List<Timetable>>? _timetableSub;
  StreamSubscription<List<TimetableLesson>>? _lessonsSub;
  StreamSubscription<TimetableConfig>? _configSub;

  TimetableConfig? _config;
  List<TimetableLesson> _lessons = const [];

  ParentTimetableBloc({
    required this.timetableRepository,
    required this.structureRepository,
  }) : super(const ParentTimetableState.initial()) {
    on<ParentTimetableRequested>(
      _onRequested,
      transformer: (events, mapper) => events.switchMap(mapper),
    );
  }

  // Everything the three source streams (config/timetables/lessons) produce
  // is funneled through this controller and consumed via `emit.onEach`
  // below, so the handler's returned Future legitimately stays open for as
  // long as those subscriptions are alive. Calling `emit()` from a raw
  // `.listen()` callback after the async handler body returns throws
  // "emit called after handler completed" (see package:bloc/src/emitter.dart)
  // - `emit.onEach` is bloc's sanctioned way to keep a handler alive across
  // nested subscriptions instead.
  Future<void> _onRequested(
    ParentTimetableRequested event,
    Emitter<ParentTimetableState> emit,
  ) async {
    if (event.classId.isEmpty) {
      emit(
        const ParentTimetableState(
          isLoading: false,
          errorMessage: 'This child is not assigned to a class yet.',
        ),
      );
      return;
    }

    await _timetableSub?.cancel();
    await _lessonsSub?.cancel();
    await _configSub?.cancel();
    _config = null;
    _lessons = const [];

    // Start clean rather than copyWith: switching children must not show
    // the previous child's timetable while the new one loads.
    emit(ParentTimetableState(isLoading: true, classId: event.classId));

    final updates = StreamController<ParentTimetableState>();

    _configSub = structureRepository
        .watchTimetableConfig(event.schoolId)
        .listen(
          (config) {
            _config = config;
            final entries = _entriesState(event.classId);
            if (entries != null) updates.add(entries);
          },
          onError: (_) {
            // A missing config leaves lessons without times to show against -
            // the timetable stream below still drives isLoading/errorMessage.
          },
        );

    _timetableSub = timetableRepository
        .watchTimetables(
          schoolId: event.schoolId,
          academicYearId: event.academicYearId,
          classId: event.classId,
        )
        .listen(
          (timetables) {
            final published = _activeFor(timetables, streamId: event.streamId);

            _lessonsSub?.cancel();
            if (published == null) {
              _lessons = const [];
              updates.add(
                ParentTimetableState(isLoading: false, classId: event.classId),
              );
              return;
            }

            updates.add(
              ParentTimetableState(
                isLoading: true,
                classId: event.classId,
                timetable: published,
              ),
            );
            _lessonsSub = timetableRepository
                .watchLessons(
                  schoolId: event.schoolId,
                  timetableId: published.id,
                )
                .listen(
                  (lessons) {
                    _lessons = lessons;
                    final entries = _entriesState(
                      event.classId,
                      timetable: published,
                    );
                    if (entries != null) updates.add(entries);
                  },
                  onError: (_) => updates.add(
                    ParentTimetableState(
                      isLoading: false,
                      classId: event.classId,
                      timetable: published,
                      errorMessage:
                          'Could not load this timetable. Pull down to retry.',
                    ),
                  ),
                );
          },
          onError: (_) => updates.add(
            ParentTimetableState(
              isLoading: false,
              classId: event.classId,
              errorMessage: 'Could not load the timetable. Pull down to retry.',
            ),
          ),
        );

    try {
      await emit.onEach<ParentTimetableState>(
        updates.stream,
        onData: (next) => emit(next),
      );
    } finally {
      await _timetableSub?.cancel();
      await _lessonsSub?.cancel();
      await _configSub?.cancel();
      await updates.close();
    }
  }

  /// Builds the "config + lessons are both in" state, or null if the config
  /// hasn't arrived yet (nothing useful to show beyond the loading state
  /// already emitted).
  ParentTimetableState? _entriesState(String classId, {Timetable? timetable}) {
    final config = _config;
    if (config == null) return null;

    final entries = mapLessonsToTimetableEntries(
      lessons: _lessons,
      config: config,
    );

    return ParentTimetableState(
      isLoading: false,
      classId: classId,
      timetable: timetable,
      entries: entries,
    );
  }

  /// The single active timetable for this class/stream target - see
  /// `ClassTimetableBloc._activeFor` (identical rule, duplicated because
  /// that method is private to its own bloc).
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

  @override
  Future<void> close() async {
    await _timetableSub?.cancel();
    await _lessonsSub?.cancel();
    await _configSub?.cancel();
    return super.close();
  }
}

const List<String> parentTimetableWeekdayOrder = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// Finds the next lesson still ahead of [now] on today's weekday, or `null`
/// if the day has no more lessons (or no published timetable exists at
/// all). Never fabricates a lesson - callers should show a neutral empty
/// state when this returns `null`.
///
/// Pulled out as a free function (rather than inlined in a widget) because
/// the "still in the future, or in progress" comparison against a "HH:mm"
/// slot string is exactly the kind of logic worth a focused unit test.
ParentTimetableEntry? nextLessonForNow(
  List<ParentTimetableEntry> entries,
  DateTime now,
) {
  final today = parentTimetableWeekdayOrder[now.weekday - 1];
  final todaysEntries = timetableEntriesForDay(entries, today);
  if (todaysEntries.isEmpty) return null;

  final nowMinutes = now.hour * 60 + now.minute;
  for (final entry in todaysEntries) {
    final endMinutes = _minutesFromHHmm(entry.slot.endTime);
    if (endMinutes == null || endMinutes > nowMinutes) {
      return entry;
    }
  }
  return null;
}

int? _minutesFromHHmm(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return h * 60 + m;
}
