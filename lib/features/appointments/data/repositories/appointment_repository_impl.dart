import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/user_roles.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_note.dart';
import '../../domain/entities/appointment_status.dart';
import '../../domain/entities/appointment_type.dart';
import '../../domain/entities/staff_availability.dart';
import '../../domain/entities/staff_summary.dart';
import '../../domain/entities/student_summary.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_data_source.dart';
import '../models/appointment_model.dart';
import '../models/appointment_note_model.dart';
import '../models/appointment_type_model.dart';
import '../models/staff_availability_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<AppointmentType>> watchAppointmentTypes(String schoolId) {
    return remoteDataSource
        .watchAppointmentTypes(schoolId)
        .map(
          (list) => list
              .map((m) => AppointmentTypeModel.fromMap(m, m['id']))
              .toList(),
        );
  }

  @override
  Future<Either<Failure, void>> saveAppointmentType(
    AppointmentType type,
  ) async {
    try {
      final model = AppointmentTypeModel.fromEntity(type);
      await remoteDataSource.saveAppointmentType(type.id, model.toMap());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAppointmentType(String id) async {
    try {
      await remoteDataSource.deleteAppointmentType(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StaffAvailability>> getStaffAvailability(
    String staffId,
    String schoolId,
  ) async {
    try {
      final data = await remoteDataSource.getStaffAvailability(staffId);
      if (data == null) {
        return Right(StaffAvailability(staffId: staffId, schoolId: schoolId));
      }
      return Right(StaffAvailabilityModel.fromMap(data, staffId));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveStaffAvailability(
    StaffAvailability availability,
  ) async {
    try {
      final model = StaffAvailabilityModel.fromEntity(availability);
      await remoteDataSource.saveStaffAvailability(
        availability.staffId,
        model.toMap(),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StaffSummary>>> getStaffByRoles(
    String schoolId,
    List<UserRole> roles,
  ) async {
    try {
      final data = await remoteDataSource.getStaffByRoles(
        schoolId,
        roles.map((r) => r.name).toList(),
      );
      final staff = data
          .map(
            (m) => StaffSummary(
              id: m['id'],
              name: m['name'] ?? '',
              role: UserRole.values.firstWhere(
                (r) => r.name == m['role'],
                orElse: () => UserRole.schoolAdmin,
              ),
            ),
          )
          .toList();
      return Right(staff);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudentSummary>>> getStudentsByIds(
    List<String> ids,
  ) async {
    try {
      final data = await remoteDataSource.getStudentsByIds(ids);
      final students = data
          .map(
            (m) => StudentSummary(
              id: m['id'],
              name: m['name'] ?? '',
              classId: m['classId'] ?? '',
            ),
          )
          .toList();
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> getAvailableSlots({
    required String staffId,
    required String schoolId,
    required DateTime date,
    required int durationMinutes,
  }) async {
    try {
      final availabilityData = await remoteDataSource.getStaffAvailability(
        staffId,
      );
      final availability = availabilityData == null
          ? StaffAvailability(staffId: staffId, schoolId: schoolId)
          : StaffAvailabilityModel.fromMap(availabilityData, staffId);

      final dayStart = DateTime(date.year, date.month, date.day);

      if (!availability.workingDays.contains(dayStart.weekday) ||
          availability.isUnavailableOn(dayStart)) {
        return const Right([]);
      }

      final bookedData = await remoteDataSource.getStaffAppointmentsOnDate(
        staffId,
        schoolId,
        dayStart,
      );
      if (bookedData.length >= availability.maxAppointmentsPerDay) {
        return const Right([]);
      }

      final booked = bookedData
          .map((m) => AppointmentModel.fromMap(m, m['id']))
          .map((a) => (start: a.scheduledStart, end: a.scheduledEnd))
          .toList();

      final step = durationMinutes + availability.bufferMinutes;
      final slots = <DateTime>[];
      final now = DateTime.now();

      for (
        var minute = availability.startMinuteOfDay;
        minute + durationMinutes <= availability.endMinuteOfDay;
        minute += step
      ) {
        final slotStart = dayStart.add(Duration(minutes: minute));
        final slotEnd = slotStart.add(Duration(minutes: durationMinutes));

        if (slotStart.isBefore(now)) continue;

        final overlaps = booked.any(
          (b) => slotStart.isBefore(b.end) && slotEnd.isAfter(b.start),
        );
        if (!overlaps) slots.add(slotStart);
      }

      return Right(slots);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Appointment>> requestAppointment(
    Appointment appointment,
  ) async {
    try {
      final model = AppointmentModel.fromEntity(appointment);
      final id = await remoteDataSource.createAppointment(model.toMap());
      return Right(appointment.copyWith(id: id));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> respondToAppointment({
    required String id,
    required AppointmentStatus status,
    required String respondedBy,
    String? responseNote,
    DateTime? proposedStart,
    DateTime? proposedEnd,
  }) async {
    try {
      final data = <String, dynamic>{
        'status': status.name,
        'respondedBy': respondedBy,
        'updatedAt': DateTime.now(),
      };
      if (responseNote != null) data['responseNote'] = responseNote;
      if (proposedStart != null) {
        data['proposedStart'] = proposedStart;
        if (proposedEnd != null) data['scheduledEnd'] = proposedEnd;
      }
      if (status == AppointmentStatus.approved && proposedStart != null) {
        data['scheduledStart'] = proposedStart;
      }
      await remoteDataSource.updateAppointment(id, _serializeTimestamps(data));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAppointment({
    required String id,
    required String cancelledBy,
    String? reason,
  }) async {
    try {
      await remoteDataSource.updateAppointment(
        id,
        _serializeTimestamps({
          'status': AppointmentStatus.cancelled.name,
          'respondedBy': cancelledBy,
          'responseNote': reason,
          'updatedAt': DateTime.now(),
        }),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> checkIn({
    required String id,
    required String checkedInBy,
    String? photoUrl,
  }) async {
    try {
      await remoteDataSource.updateAppointment(
        id,
        _serializeTimestamps({
          'checkInTime': DateTime.now(),
          'checkInBy': checkedInBy,
          'checkInPhotoUrl': photoUrl,
          'updatedAt': DateTime.now(),
        }),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> checkOut(String id) async {
    try {
      await remoteDataSource.updateAppointment(
        id,
        _serializeTimestamps({
          'checkOutTime': DateTime.now(),
          'status': AppointmentStatus.completed.name,
          'updatedAt': DateTime.now(),
        }),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markCompleted(String id) async {
    try {
      await remoteDataSource.updateAppointment(
        id,
        _serializeTimestamps({
          'status': AppointmentStatus.completed.name,
          'updatedAt': DateTime.now(),
        }),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAppointment(String id) async {
    try {
      await remoteDataSource.deleteAppointment(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<Appointment>> watchForParent(String parentId, String schoolId) {
    return remoteDataSource
        .watchForParent(parentId, schoolId)
        .map(
          (list) =>
              list.map((m) => AppointmentModel.fromMap(m, m['id'])).toList(),
        );
  }

  @override
  Stream<List<Appointment>> watchForStaff(String staffId, String schoolId) {
    return remoteDataSource
        .watchForStaff(staffId, schoolId)
        .map(
          (list) =>
              list.map((m) => AppointmentModel.fromMap(m, m['id'])).toList(),
        );
  }

  @override
  Stream<List<Appointment>> watchForSchool(String schoolId) {
    return remoteDataSource
        .watchForSchool(schoolId)
        .map(
          (list) =>
              list.map((m) => AppointmentModel.fromMap(m, m['id'])).toList(),
        );
  }

  @override
  Future<Either<Failure, void>> addNote(AppointmentNote note) async {
    try {
      final model = AppointmentNoteModel.fromEntity(note);
      await remoteDataSource.addNote(note.appointmentId, model.toMap());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<AppointmentNote>> watchNotes(String appointmentId) {
    return remoteDataSource
        .watchNotes(appointmentId)
        .map(
          (list) => list
              .map((m) => AppointmentNoteModel.fromMap(m, m['id']))
              .toList(),
        );
  }

  /// `update()` calls pass plain DateTimes above for readability - Firestore
  /// needs Timestamps, so convert just before hitting the datasource.
  Map<String, dynamic> _serializeTimestamps(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is DateTime) return MapEntry(key, Timestamp.fromDate(value));
      return MapEntry(key, value);
    });
  }
}
