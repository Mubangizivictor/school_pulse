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
import '../repositories/appointment_repository.dart';

class WatchAppointmentTypes {
  final AppointmentRepository repository;
  WatchAppointmentTypes(this.repository);
  Stream<List<AppointmentType>> call(String schoolId) => repository.watchAppointmentTypes(schoolId);
}

class SaveAppointmentType {
  final AppointmentRepository repository;
  SaveAppointmentType(this.repository);
  Future<Either<Failure, void>> call(AppointmentType type) => repository.saveAppointmentType(type);
}

class DeleteAppointmentType {
  final AppointmentRepository repository;
  DeleteAppointmentType(this.repository);
  Future<Either<Failure, void>> call(String id) => repository.deleteAppointmentType(id);
}

class GetStaffAvailability {
  final AppointmentRepository repository;
  GetStaffAvailability(this.repository);
  Future<Either<Failure, StaffAvailability>> call(String staffId, String schoolId) =>
      repository.getStaffAvailability(staffId, schoolId);
}

class SaveStaffAvailability {
  final AppointmentRepository repository;
  SaveStaffAvailability(this.repository);
  Future<Either<Failure, void>> call(StaffAvailability availability) =>
      repository.saveStaffAvailability(availability);
}

class GetStaffByRoles {
  final AppointmentRepository repository;
  GetStaffByRoles(this.repository);
  Future<Either<Failure, List<StaffSummary>>> call(String schoolId, List<UserRole> roles) =>
      repository.getStaffByRoles(schoolId, roles);
}

class GetStudentsByIds {
  final AppointmentRepository repository;
  GetStudentsByIds(this.repository);
  Future<Either<Failure, List<StudentSummary>>> call(List<String> ids) =>
      repository.getStudentsByIds(ids);
}

class GetAvailableSlots {
  final AppointmentRepository repository;
  GetAvailableSlots(this.repository);
  Future<Either<Failure, List<DateTime>>> call({
    required String staffId,
    required String schoolId,
    required DateTime date,
    required int durationMinutes,
  }) =>
      repository.getAvailableSlots(
        staffId: staffId,
        schoolId: schoolId,
        date: date,
        durationMinutes: durationMinutes,
      );
}

class RequestAppointment {
  final AppointmentRepository repository;
  RequestAppointment(this.repository);
  Future<Either<Failure, Appointment>> call(Appointment appointment) =>
      repository.requestAppointment(appointment);
}

class RespondToAppointment {
  final AppointmentRepository repository;
  RespondToAppointment(this.repository);
  Future<Either<Failure, void>> call({
    required String id,
    required AppointmentStatus status,
    required String respondedBy,
    String? responseNote,
    DateTime? proposedStart,
    DateTime? proposedEnd,
  }) =>
      repository.respondToAppointment(
        id: id,
        status: status,
        respondedBy: respondedBy,
        responseNote: responseNote,
        proposedStart: proposedStart,
        proposedEnd: proposedEnd,
      );
}

class CancelAppointment {
  final AppointmentRepository repository;
  CancelAppointment(this.repository);
  Future<Either<Failure, void>> call({
    required String id,
    required String cancelledBy,
    String? reason,
  }) =>
      repository.cancelAppointment(id: id, cancelledBy: cancelledBy, reason: reason);
}

class CheckInAppointment {
  final AppointmentRepository repository;
  CheckInAppointment(this.repository);
  Future<Either<Failure, void>> call({
    required String id,
    required String checkedInBy,
    String? photoUrl,
  }) =>
      repository.checkIn(id: id, checkedInBy: checkedInBy, photoUrl: photoUrl);
}

class CheckOutAppointment {
  final AppointmentRepository repository;
  CheckOutAppointment(this.repository);
  Future<Either<Failure, void>> call(String id) => repository.checkOut(id);
}

class MarkAppointmentCompleted {
  final AppointmentRepository repository;
  MarkAppointmentCompleted(this.repository);
  Future<Either<Failure, void>> call(String id) => repository.markCompleted(id);
}

class WatchAppointmentsForParent {
  final AppointmentRepository repository;
  WatchAppointmentsForParent(this.repository);
  Stream<List<Appointment>> call(String parentId, String schoolId) =>
      repository.watchForParent(parentId, schoolId);
}

class WatchAppointmentsForStaff {
  final AppointmentRepository repository;
  WatchAppointmentsForStaff(this.repository);
  Stream<List<Appointment>> call(String staffId, String schoolId) =>
      repository.watchForStaff(staffId, schoolId);
}

class WatchAppointmentsForSchool {
  final AppointmentRepository repository;
  WatchAppointmentsForSchool(this.repository);
  Stream<List<Appointment>> call(String schoolId) => repository.watchForSchool(schoolId);
}

class AddAppointmentNote {
  final AppointmentRepository repository;
  AddAppointmentNote(this.repository);
  Future<Either<Failure, void>> call(AppointmentNote note) => repository.addNote(note);
}

class WatchAppointmentNotes {
  final AppointmentRepository repository;
  WatchAppointmentNotes(this.repository);
  Stream<List<AppointmentNote>> call(String appointmentId) => repository.watchNotes(appointmentId);
}
