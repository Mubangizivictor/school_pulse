import 'package:equatable/equatable.dart';

enum BorrowingStatus { active, returned, overdue, lost, damaged }

class LibraryBorrowing extends Equatable {
  final String id;
  final String schoolId;
  final String resourceId;
  final String resourceTitle;
  final String borrowerId; // Student, Teacher, or Parent ID
  final String borrowerName;
  final String borrowerType; // 'student', 'teacher', 'parent'
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final BorrowingStatus status;
  final double fineAmount;
  final bool finePaid;
  final String issuedBy; // Librarian ID
  final String? receivedBy; // Librarian ID

  const LibraryBorrowing({
    required this.id,
    required this.schoolId,
    required this.resourceId,
    required this.resourceTitle,
    required this.borrowerId,
    required this.borrowerName,
    required this.borrowerType,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    this.status = BorrowingStatus.active,
    this.fineAmount = 0.0,
    this.finePaid = false,
    required this.issuedBy,
    this.receivedBy,
  });

  @override
  List<Object?> get props => [
        id,
        schoolId,
        resourceId,
        resourceTitle,
        borrowerId,
        borrowerName,
        borrowerType,
        borrowDate,
        dueDate,
        returnDate,
        status,
        fineAmount,
        finePaid,
        issuedBy,
        receivedBy,
      ];
}
