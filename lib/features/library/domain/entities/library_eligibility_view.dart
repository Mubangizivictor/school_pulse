import 'package:equatable/equatable.dart';

/// What a Librarian is allowed to see for one student - borrowing
/// eligibility only, never marks or finance.
class LibraryEligibilityView extends Equatable {
  final String studentId;
  final String name;
  final bool eligible;
  final int currentlyBorrowed;
  final int overdueCount;
  final String message;

  const LibraryEligibilityView({
    required this.studentId,
    required this.name,
    required this.eligible,
    required this.currentlyBorrowed,
    required this.overdueCount,
    required this.message,
  });

  @override
  List<Object?> get props => [
    studentId,
    name,
    eligible,
    currentlyBorrowed,
    overdueCount,
    message,
  ];
}
