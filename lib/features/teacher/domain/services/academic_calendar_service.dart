import 'package:equatable/equatable.dart';

/// The academic period the panel is operating in.
class AcademicPeriod extends Equatable {
  final String academicYearId;
  final String academicYearName;
  final String termId;
  final String termName;

  const AcademicPeriod({
    required this.academicYearId,
    this.academicYearName = '',
    this.termId = '',
    this.termName = '',
  });

  bool get hasYear => academicYearId.isNotEmpty;
  bool get hasTerm => termId.isNotEmpty;

  @override
  List<Object?> get props => [academicYearId, academicYearName, termId, termName];
}

/// Reads the school's calendar without the Subject Teacher feature knowing
/// anything about how the Structure module stores it.
///
/// The panel needs "which year and term are we in" constantly - for scoping
/// queries, for the dashboard subtitle, for deciding whether an assignment is
/// current. Going through this interface keeps that a single dependency
/// instead of scattering Structure lookups through fifteen BLoCs.
abstract class AcademicCalendarService {
  /// The year and term flagged current by the school admin. Both parts can be
  /// missing - a school that has not configured its calendar yet is a real
  /// state the dashboard has to render, not an error.
  Future<AcademicPeriod> getCurrentPeriod();

  /// The term containing [date] within the current year, used when working on
  /// a lesson or assessment that belongs to a term other than today's.
  Future<AcademicPeriod> getPeriodForDate(DateTime date);
}
