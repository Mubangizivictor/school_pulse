import 'package:equatable/equatable.dart';

/// What a Catering Manager is allowed to see for one student - meal
/// eligibility and dietary restrictions only. Deliberately has no balance
/// or percentagePaid field: CateringRepository.verifyStudentMealEligibility
/// returns a percentagePaid figure derived from finance, and this view
/// exists specifically to make sure that number never reaches a caller.
class CateringEligibilityView extends Equatable {
  final String studentId;
  final String name;
  final String classId;
  final String? photoUrl;
  final bool eligible;
  final String message;
  final List<String> dietaryRestrictions;

  const CateringEligibilityView({
    required this.studentId,
    required this.name,
    required this.classId,
    required this.photoUrl,
    required this.eligible,
    required this.message,
    required this.dietaryRestrictions,
  });

  @override
  List<Object?> get props => [
    studentId,
    name,
    classId,
    photoUrl,
    eligible,
    message,
    dietaryRestrictions,
  ];
}
