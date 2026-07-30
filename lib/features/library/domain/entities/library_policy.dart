import 'package:equatable/equatable.dart';

class LibraryPolicy extends Equatable {
  final String id;
  final String schoolId;
  final String borrowerType; // 'student', 'teacher', 'parent', 'staff'
  final int maxBooks;
  final int borrowDurationDays;
  final int renewalLimit;
  final int gracePeriodDays;
  final double finePerDay;
  final double lostBookChargeMultiplier; // e.g., 1.5 times the cost
  final bool canReserve;

  const LibraryPolicy({
    required this.id,
    required this.schoolId,
    required this.borrowerType,
    required this.maxBooks,
    required this.borrowDurationDays,
    required this.renewalLimit,
    required this.gracePeriodDays,
    required this.finePerDay,
    required this.lostBookChargeMultiplier,
    this.canReserve = true,
  });

  @override
  List<Object?> get props => [
        id,
        schoolId,
        borrowerType,
        maxBooks,
        borrowDurationDays,
        renewalLimit,
        gracePeriodDays,
        finePerDay,
        lostBookChargeMultiplier,
        canReserve,
      ];
}
