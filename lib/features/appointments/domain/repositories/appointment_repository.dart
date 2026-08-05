import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/user_roles.dart';
import '../entities/appointment.dart';
import '../entities/appointment_note.dart';
import '../entities/appointment_status.dart';
import '../entities/appointment_type.dart';
import '../entities/staff_availability.dart';
import '../entities/staff_summary.dart';
import '../entities/student_summary.dart';

abstract class AppointmentRepository {
  // Appointment types (school-configurable categories)
  Stream<List<AppointmentType>> watchAppointmentTypes(String schoolId);
  Future<Either<Failure, void>> saveAppointmentType(AppointmentType type);
  Future<Either<Failure, void>> deleteAppointmentType(String id);

  // Staff availability
  Future<Either<Failure, StaffAvailability>> getStaffAvailability(
    String staffId,
    String schoolId,
  );
  Future<Either<Failure, void>> saveStaffAvailability(
    StaffAvailability availability,
  );

  // Pickers
  Future<Either<Failure, List<StaffSummary>>> getStaffByRoles(
    String schoolId,
    List<UserRole> roles,
  );
  Future<Either<Failure, List<StudentSummary>>> getStudentsByIds(
    List<String> ids,
  );

  // Slot computation for a given staff member/day, respecting their
  // availability plus any appointments already booked that day.
  Future<Either<Failure, List<DateTime>>> getAvailableSlots({
    required String staffId,
    required String schoolId,
    required DateTime date,
    required int durationMinutes,
  });

  // Appointment lifecycle
  Future<Either<Failure, Appointment>> requestAppointment(
    Appointment appointment,
  );
  Future<Either<Failure, void>> respondToAppointment({
    required String id,
    required AppointmentStatus status,
    required String respondedBy,
    String? responseNote,
    DateTime? proposedStart,
    DateTime? proposedEnd,
  });
  Future<Either<Failure, void>> cancelAppointment({
    required String id,
    required String cancelledBy,
    String? reason,
  });
  Future<Either<Failure, void>> checkIn({
    required String id,
    required String checkedInBy,
    String? photoUrl,
  });
  Future<Either<Failure, void>> checkOut(String id);
  Future<Either<Failure, void>> markCompleted(String id);
  Future<Either<Failure, void>> deleteAppointment(String id);

  Stream<List<Appointment>> watchForParent(String parentId, String schoolId);
  Stream<List<Appointment>> watchForStaff(String staffId, String schoolId);
  Stream<List<Appointment>> watchForSchool(String schoolId);

  // Confidential meeting notes
  Future<Either<Failure, void>> addNote(AppointmentNote note);
  Stream<List<AppointmentNote>> watchNotes(String appointmentId);
}
