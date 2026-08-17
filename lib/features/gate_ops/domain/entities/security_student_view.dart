import 'package:equatable/equatable.dart';

/// What a Security/Gatekeeper operator is allowed to see for one student
/// during identity verification - deliberately the narrowest projection in
/// the codebase. No academic, financial, medical or discipline data ever
/// flows into this view; it exists only to confirm "this is who the card
/// says it is" at a gate.
class SecurityStudentView extends Equatable {
  final String studentId;
  final String name;
  final String? photoUrl;
  final String classId;
  final String? cardStatus;

  const SecurityStudentView({
    required this.studentId,
    required this.name,
    required this.photoUrl,
    required this.classId,
    this.cardStatus,
  });

  @override
  List<Object?> get props => [studentId, name, photoUrl, classId, cardStatus];
}
