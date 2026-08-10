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
/// Answers "what active attendance responsibilities and scopes does this
/// authenticated person currently have" instead of "what role is this
/// person" - it is built entirely from real data (role-level permissions +
/// every currently-valid [StaffRoleAssignment] the operator holds, unioned
/// across responsibility types), never from a role-name switch statement.
///
/// One user may hold several assignments at once (Class Teacher of P5 Blue
/// AND Subject Teacher of Math in P6/P7, for example) - every valid one is
/// folded into the same [AttendanceAccessContext], so nothing here narrows
/// to a single "currently selected" responsibility the way the teacher
/// module's `ActiveResponsibilityService` does for its own dashboard.
///
/// Roles resolved with real scope data this pass: Class Teacher (classId),
/// Subject Teacher (subjectId -> classIds), Matron/Patron (houseId as
/// dormitory scope), Security/Gate (category-level only - Gate-resource
/// scoping already lives in PermissionEvaluatorImpl), and any role granted
/// `attendance.override` or the schoolAdmin/director/headTeacher/deputyHead
/// Firestore-rules bypass, which resolve to institution-wide access.
/// Transport, Lecturer/course-unit, Dean/faculty drill-down and event/club
/// staff have no enrollment/assignment data model to resolve against yet -
/// deliberately not wired here rather than guessed at.
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
      final isInstitutionWide = operatorUser.roles.any(
        _institutionWideRoles.contains,
      );
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

      // Category-level permission is the first gate for every category -
      // scope data (below) only narrows it further, never widens it beyond
      // what the operator's role/override permissions already allow.
      for (final category in AttendanceCategory.values) {
        final permissionId = permissionForCategory(category);
        final grantedResult = await permissionEvaluator.can(
          permissionId,
          operatorUser,
        );
        final granted = grantedResult.fold((f) => false, (v) => v);
        if (!granted && !hasOverride) continue;

        allowedDomains.add(category);
        if (isInstitutionWide || hasOverride) {
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
              // A class already granted via a Class Teacher assignment keeps
              // that assignment id - either one legitimately authorises the
              // write, and the map only needs to name one that does.
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
            // securityOfficer, transportCoordinator, and every other
            // responsibility type contribute only the category-level
            // permission already resolved above - no scoped assignment
            // data exists for them yet.
            break;
        }
      }

      final context = AttendanceAccessContext(
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
      );

      return Right(context);
    });
  }
}
