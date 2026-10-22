import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/student/domain/entities/admission_application.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/presentation/enrollment_setup/screens/enrollment_setup_wizard_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/admin_student_directory_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/admin_student_documents_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/admin_student_profile_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/admission_review_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/admissions_list_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/direct_student_registration_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/new_application_screen.dart';
import 'package:school_pulse/features/student_identity/presentation/bloc/student_identity_bloc.dart';
import 'package:school_pulse/features/student_identity/presentation/screens/identity_and_cards_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_portal_codes_screen.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';

/// Resolves the body [AdminShell]/[AdminWebShell] show for the **Students**
/// section from the live URL, so every nested route under `students` and
/// `admissions` renders inside the canonical shell (persistent sidebar /
/// bottom nav) instead of the standalone `Scaffold` each screen used to be
/// reached with directly.
///
/// Each branch below mirrors the route `builder` previously registered
/// directly on the matching `GoRoute` in `router.dart` — same widget, same
/// `state.extra`/query-param reads — just re-hosted as shell content instead
/// of a bare top-level page. Screens still navigate between each other with
/// ordinary `context.push`/`context.go`/`Navigator.pop`; only *where* they
/// render (inside the shell vs. as a standalone page) changes.
class AdminStudentsSectionBody extends StatelessWidget {
  const AdminStudentsSectionBody({super.key});

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final path = state.uri.path;

    if (path == '/staff/admin/admissions' ||
        path == '/staff/admin/admissions/') {
      return const AdmissionsListScreen();
    }
    if (path == '/staff/admin/admissions/new') {
      return NewApplicationScreen(schoolId: state.extra as String);
    }
    if (path == '/staff/admin/admissions/register') {
      return DirectStudentRegistrationScreen(schoolId: state.extra as String);
    }
    if (path == '/staff/admin/admissions/review') {
      return AdmissionReviewScreen(
        application: state.extra as AdmissionApplication,
      );
    }
    if (path == '/staff/admin/admissions/review/enroll') {
      final extra = state.extra as EnrollmentSetupWizardRouteExtra;
      return EnrollmentSetupWizardScreen(
        application: extra.application,
        studentId: extra.studentId,
        schoolCode: extra.schoolCode,
        uniqueSystemId: extra.uniqueSystemId,
        studentCode: extra.studentCode,
      );
    }

    final studentIdMatch = RegExp(
      r'^/staff/admin/students/([^/]+)',
    ).firstMatch(path);
    if (studentIdMatch != null) {
      final studentId = studentIdMatch.group(1)!;
      if (path.endsWith('/documents')) {
        return AdminStudentDocumentsScreen(
          student: state.extra as Student,
          canMutate: true,
        );
      }
      if (path.endsWith('/identity')) {
        return BlocProvider(
          create: (_) => di.sl<StudentIdentityBloc>(),
          child: IdentityAndCardsScreen(
            student: state.extra as Student,
            canMutate: true,
          ),
        );
      }
      if (path.endsWith('/portal')) {
        return StudentPortalCodesScreen(student: state.extra as Student);
      }
      return AdminStudentProfileScreen(
        studentId: studentId,
        initialTab:
            int.tryParse(state.uri.queryParameters['tab'] ?? '') ??
            StudentProfileTab.overview,
      );
    }

    return const AdminStudentDirectoryScreen();
  }
}
