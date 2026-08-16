import 'package:equatable/equatable.dart';
import '../../domain/entities/timetable.dart';
import '../../domain/services/timetable_conflict_resolver.dart';

class TimetableState extends Equatable {
  final bool isLoadingList;
  final List<Timetable> timetables;

  final bool isLoadingDetail;
  final Timetable? current;
  final List<TimetableLesson> lessons;

  /// Every other lesson at the school for the current timetable's academic
  /// year/term, excluding [lessons] - the pool a new/edited lesson is
  /// checked against.
  final List<TimetableLesson> otherLessons;

  /// Set only after a rejected save, so the assign-subject dialog can show
  /// exactly why. Cleared on the next successful action.
  final List<TimetableConflict> lastSaveConflicts;

  /// Set after a rejected publish - a full scan across every lesson in the
  /// current timetable, keyed by lesson id.
  final Map<String, List<TimetableConflict>> publishConflicts;

  final bool isSaving;
  final String? errorMessage;

  const TimetableState({
    this.isLoadingList = false,
    this.timetables = const [],
    this.isLoadingDetail = false,
    this.current,
    this.lessons = const [],
    this.otherLessons = const [],
    this.lastSaveConflicts = const [],
    this.publishConflicts = const {},
    this.isSaving = false,
    this.errorMessage,
  });

  TimetableState copyWith({
    bool? isLoadingList,
    List<Timetable>? timetables,
    bool? isLoadingDetail,
    Timetable? current,
    List<TimetableLesson>? lessons,
    List<TimetableLesson>? otherLessons,
    List<TimetableConflict>? lastSaveConflicts,
    Map<String, List<TimetableConflict>>? publishConflicts,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    bool clearCurrent = false,
  }) {
    return TimetableState(
      isLoadingList: isLoadingList ?? this.isLoadingList,
      timetables: timetables ?? this.timetables,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      current: clearCurrent ? null : (current ?? this.current),
      lessons: clearCurrent ? const [] : (lessons ?? this.lessons),
      otherLessons: clearCurrent
          ? const []
          : (otherLessons ?? this.otherLessons),
      lastSaveConflicts: lastSaveConflicts ?? const [],
      publishConflicts: publishConflicts ?? this.publishConflicts,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoadingList,
    timetables,
    isLoadingDetail,
    current,
    lessons,
    otherLessons,
    lastSaveConflicts,
    publishConflicts,
    isSaving,
    errorMessage,
  ];
}
