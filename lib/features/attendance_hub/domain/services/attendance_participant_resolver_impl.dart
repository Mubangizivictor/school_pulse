import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/domain/repositories/staff_assignment_repository.dart';
import 'package:school_pulse/features/teacher/domain/services/academic_calendar_service.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import '../entities/attendance_access_context.dart';
import '../entities/attendance_category.dart';
import '../entities/attendance_category_permission.dart';
import 'attendance_participant_resolver.dart';

/// Central attendance authorization resolver.
///
/// School leadership is institution-wide by role and must never depend on a
/// teacher/class assignment merely to open or test Attendance. Scoped staff
/// (class teachers, subject teachers, patrons/matrons, etc.) continue to be
/// resolved from their real active StaffRoleAssignments.
class AttendanceParticipantResolverImpl
    implements AttendanceParticipantResolver {
  final StaffAssignmentRepository assignmentRepository;
  final AcademicCalendarService calendarService;
  final PermissionEvaluator permissionEvaluator;

  static const _institutionWideRoles = {
    UserRole.schoolAdmin,
    UserRole.director,
    UserRole.headTeacher,
    UserRole.deputyHead,
  };

  AttendanceParticipantResolverImpl({
    required this.assignmentRepository,
    required this.calendarService,
    required this.permissionEvaluator,
  });

  @override
  Future<Either<Failure, AttendanceAccessContext>> resolve(
    UserEntity operatorUser,
  ) async {
    final isInstitutionWide = operatorUser.roles.any(
      _institutionWideRoles.contains,
    );

    // Leadership/admin accounts are the tenant authority. They can inspect
    // and operate attendance school-wide without first creating a fake class
    // teacher assignment. Firestore rules already have the same leadership
    // bypass, so this keeps client authorization aligned with the server.
    if (isInstitutionWide) {
      final allDomains = AttendanceCategory.values.toSet();
      return Right(
        AttendanceAccessContext(
          userId: operatorUser.id,
          schoolId: operatorUser.schoolId,
          allowedDomains: allDomains,
          institutionWideDomains: allDomains,
          allowedClassIds: const {},
          allowedSubjectClassIds: const {},
          allowedDormitoryIds: const {},
          assignmentIdByClassId: const {},
          assignmentIdByDormitoryId: const {},
          canCreateSession: true,
          canCorrectAttendance: true,
          canExportToGoogleSheets: true,
          reasonForRestriction: AttendanceRestrictionReason.none,
        ),
      );
    }

    final period = await calendarService.getCurrentPeriod(
      operatorUser.schoolId,
    );

    final assignmentsResult = await assignmentRepository.getValidAssignments(
      schoolId: operatorUser.schoolId,
      userId: operatorUser.id,
      academicYearId: period.hasYear ? period.academicYearId : null,
    );

    return assignmentsResult.fold((failure) async => Left(failure), (
      assignments,
    ) async {
      final hasOverrideResult = await permissionEvaluator.can(
        Permission.attendanceOverride,
        operatorUser,
      );
      final hasOverride = hasOverrideResult.fold((f) => false, (v) => v);

      final allowedDomains = <AttendanceCategory>{};
      final institutionWideDomains = <AttendanceCategory>{};
      final allowedClassIds = <String>{};
      final allowedSubjectClassIds = <String, Set<String>>{};
      final allowedDormitoryIds = <String>{};
      final assignmentIdByClassId = <String, String>{};
      final assignmentIdByDormitoryId = <String, String>{};

      for (final category in AttendanceCategory.values) {
        final permissionId = permissionForCategory(category);
        final grantedResult = await permissionEvaluator.can(
          permissionId,
          operatorUser,
        );
        final granted = grantedResult.fold((f) => false, (v) => v);
        if (!granted && !hasOverride) continue;

        allowedDomains.add(category);
        if (hasOverride) {
          institutionWideDomains.add(category);
        }
      }

      for (final assignment in assignments) {
        switch (assignment.roleType) {
          case StaffResponsibilityType.classTeacher:
            if (assignment.classId != null) {
              allowedClassIds.add(assignment.classId!);
              assignmentIdByClassId[assignment.classId!] = assignment.id;
              allowedDomains.add(AttendanceCategory.students);
            }
            break;
          case StaffResponsibilityType.subjectTeacher:
            if (assignment.subjectId != null && assignment.classId != null) {
              allowedSubjectClassIds
                  .putIfAbsent(assignment.subjectId!, () => {})
                  .add(assignment.classId!);
              assignmentIdByClassId.putIfAbsent(
                assignment.classId!,
                () => assignment.id,
              );
              allowedDomains.add(AttendanceCategory.students);
            }
            break;
          case StaffResponsibilityType.matron:
          case StaffResponsibilityType.patron:
            if (assignment.houseId != null) {
              allowedDormitoryIds.add(assignment.houseId!);
              assignmentIdByDormitoryId[assignment.houseId!] = assignment.id;
              allowedDomains.add(AttendanceCategory.hostel);
            }
            break;
          default:
            break;
        }
      }

      return Right(
        AttendanceAccessContext(
          userId: operatorUser.id,
          schoolId: operatorUser.schoolId,
          allowedDomains: allowedDomains,
          institutionWideDomains: institutionWideDomains,
          allowedClassIds: allowedClassIds,
          allowedSubjectClassIds: allowedSubjectClassIds,
          allowedDormitoryIds: allowedDormitoryIds,
          assignmentIdByClassId: assignmentIdByClassId,
          assignmentIdByDormitoryId: assignmentIdByDormitoryId,
          canCreateSession: allowedDomains.isNotEmpty,
          canCorrectAttendance: institutionWideDomains.isNotEmpty,
          canExportToGoogleSheets: allowedDomains.isNotEmpty,
          reasonForRestriction: allowedDomains.isEmpty
              ? AttendanceRestrictionReason.noResponsibility
              : AttendanceRestrictionReason.none,
        ),
      );
    });
  }
}
