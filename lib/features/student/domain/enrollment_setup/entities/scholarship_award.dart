import 'package:equatable/equatable.dart';

/// Type of fee relief granted to a student during enrollment setup.
/// `none` is the default/no-op state - never persisted as its own award,
/// callers should simply not create a record when this is selected.
enum ScholarshipAwardType {
  none,
  full,
  partial,
  scholarship,
  staffChildDiscount,
  siblingDiscount,
  custom,
}

/// A fee-relief grant recorded against one student for one effective
/// period. Firestore collection: `scholarship_awards/{id}`. Creating any
/// award with a type other than [ScholarshipAwardType.none] is gated
/// behind `Permission.enrollmentBursaryAssign` - see
/// [EnrollmentSetupRepository.createScholarshipAward].
class ScholarshipAward extends Equatable {
  final String id;
  final String schoolId;
  final String studentId;
  final ScholarshipAwardType type;

  /// The relief value - either an absolute amount or a percentage,
  /// disambiguated by [isPercentage].
  final double amountOrPercentage;
  final bool isPercentage;

  final DateTime effectiveStart;
  final DateTime? effectiveEnd;

  final String approvedBy;
  final String reason;
  final String? supportingDocumentUrl;
  final DateTime createdAt;

  const ScholarshipAward({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.type,
    required this.amountOrPercentage,
    required this.isPercentage,
    required this.effectiveStart,
    this.effectiveEnd,
    required this.approvedBy,
    required this.reason,
    this.supportingDocumentUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    studentId,
    type,
    amountOrPercentage,
    isPercentage,
    effectiveStart,
    effectiveEnd,
    approvedBy,
    reason,
    supportingDocumentUrl,
    createdAt,
  ];
}
