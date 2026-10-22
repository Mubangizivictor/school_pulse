import 'package:equatable/equatable.dart';

enum ClubMembershipStatus { active, inactive }

/// A student's membership in a club/society. Firestore collection:
/// `student_club_memberships/{id}`. Optional and non-blocking - the
/// Clubs/Activities wizard step never requires at least one selection.
class StudentClubMembership extends Equatable {
  final String id;
  final String studentId;
  final String schoolId;
  final String clubId;
  final DateTime joinedAt;
  final ClubMembershipStatus status;

  const StudentClubMembership({
    required this.id,
    required this.studentId,
    required this.schoolId,
    required this.clubId,
    required this.joinedAt,
    this.status = ClubMembershipStatus.active,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    schoolId,
    clubId,
    joinedAt,
    status,
  ];
}
