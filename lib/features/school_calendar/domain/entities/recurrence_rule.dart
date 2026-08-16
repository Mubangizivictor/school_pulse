import 'package:equatable/equatable.dart';

enum RecurrenceFrequency { daily, weekly, monthly, yearly }

enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

/// How a recurring event's occurrences end - never (indefinite), on a fixed
/// date, or after a fixed number of occurrences.
enum RecurrenceEndType { never, onDate, afterOccurrences }

/// Which occurrences of a recurring event a delete/edit applies to.
enum RecurrenceEditScope { thisOccurrence, thisAndFuture, allOccurrences }

class RecurrenceRule extends Equatable {
  final RecurrenceFrequency frequency;
  final List<Weekday> repeatsOn;
  final RecurrenceEndType endType;
  final DateTime? endDate;
  final int? occurrences;

  const RecurrenceRule({
    required this.frequency,
    this.repeatsOn = const [],
    this.endType = RecurrenceEndType.never,
    this.endDate,
    this.occurrences,
  });

  @override
  List<Object?> get props => [
    frequency,
    repeatsOn,
    endType,
    endDate,
    occurrences,
  ];
}
