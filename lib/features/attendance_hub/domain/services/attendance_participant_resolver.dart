import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import '../entities/attendance_access_context.dart';

/// Turns "who is this authenticated person, and what active attendance
/// responsibilities/scopes do they currently hold" into a single
/// [AttendanceAccessContext].
///
/// Every attendance surface - the "Attendance For" dropdown, scope
/// selectors, the manual roster, NFC/QR scan validation, Previous
/// Attendance, and the Google Sheets export - must resolve access through
/// this one entry point. None of them may independently decide "what role
/// is this person" and hardcode a participant list from that; see the
/// module-level doc comment in attendance_participant_resolver_impl.dart for
/// why.
abstract class AttendanceParticipantResolver {
  Future<Either<Failure, AttendanceAccessContext>> resolve(
    UserEntity operatorUser,
  );
}
