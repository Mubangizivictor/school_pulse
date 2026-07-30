import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/login_flow/welcome_screen.dart';
import 'package:school_pulse/features/auth/login_flow/parent_login_screens.dart';
import 'package:school_pulse/features/auth/login_flow/staff_login_screens.dart';
import 'package:school_pulse/features/auth/login_flow/force_set_password_screen.dart';
import 'package:school_pulse/features/auth/login_flow/school_splash_screen.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/admin_dashboard_screen.dart';
import 'package:school_pulse/features/admin/admin_messages_screen.dart';
import 'package:school_pulse/features/admin/user_management_screen.dart';
import 'package:school_pulse/features/admin/broadcast_sms_screen.dart';
import 'package:school_pulse/features/admin/system_config_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/structure_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/institution_profile_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/academic_structure_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/people_structure_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/assessment_grading_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/campus_facilities_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/operations_config_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/feature_toggles_screen.dart';
import 'package:school_pulse/features/admin/visitor_log_screen.dart';
import 'package:school_pulse/features/admin/admin_staff_attendance_screen.dart';
import 'package:school_pulse/features/admin/appointments_screen.dart';
import 'package:school_pulse/features/admin/audit_log_screen.dart';
import 'package:school_pulse/features/admin/broadcast_history_screen.dart';
import 'package:school_pulse/features/admin/subscription_screen.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/parent/home_screen.dart';
import 'package:school_pulse/features/parent/academics_screen.dart';
import 'package:school_pulse/features/parent/report_card_screen.dart';
import 'package:school_pulse/features/parent/attendance_detail_screen.dart';
import 'package:school_pulse/features/parent/fees_screen.dart';
import 'package:school_pulse/features/parent/pay_now_screen.dart';
import 'package:school_pulse/features/parent/payment_history_screen.dart';
import 'package:school_pulse/features/parent/health_screen.dart';
import 'package:school_pulse/features/parent/library_screen.dart';
import 'package:school_pulse/features/parent/discipline_screen.dart';
import 'package:school_pulse/features/parent/transport_screen.dart';
import 'package:school_pulse/features/parent/messages_screen.dart';
import 'package:school_pulse/features/parent/profile_screen.dart';
import 'package:school_pulse/features/parent/more_menu_screen.dart';
import 'package:school_pulse/features/parent/notifications_screen.dart';
import 'package:school_pulse/features/parent/boarding_screen.dart';
import 'package:school_pulse/features/parent/security_activity_screen.dart';
import 'package:school_pulse/features/shared/shell_screen.dart';
import 'package:school_pulse/features/shared/presentation/staff_hub_screen.dart';
import 'package:school_pulse/features/teacher/dashboard_screen.dart';
import 'package:school_pulse/features/teacher/attendance_screen.dart';
import 'package:school_pulse/features/teacher/marks_entry_screen.dart';
import 'package:school_pulse/features/teacher/staff_more_screen.dart';
import 'package:school_pulse/features/teacher/staff_profile_screen.dart';
import 'package:school_pulse/features/teacher/security_settings_screen.dart';
import 'package:school_pulse/features/teacher/class_analytics_screen.dart';
import 'package:school_pulse/features/teacher/homework_screen.dart';
import 'package:school_pulse/features/teacher/report_comments_screen.dart';
import 'package:school_pulse/features/calendar/presentation/school_calendar_screen.dart';
import 'package:school_pulse/features/lesson_plans/presentation/lesson_plans_screen.dart';
import 'package:school_pulse/features/bursar/bursar_dashboard.dart';
import 'package:school_pulse/features/nurse/nurse_dashboard.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/librarian/librarian_dashboard.dart';
import 'package:school_pulse/features/matron/matron_dashboard.dart';
import 'package:school_pulse/features/inventory/inventory_dashboard.dart';
import 'package:school_pulse/features/patron/presentation/screens/patron_dashboard.dart';
import 'package:school_pulse/features/patron/presentation/screens/dormitory_management_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/boarding_attendance_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/welfare_management_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/discipline_management_screen.dart';
import 'package:school_pulse/features/teacher/attendance_history_screen.dart';
import 'package:school_pulse/features/catering/presentation/catering_dashboard_screen.dart';
import 'package:school_pulse/features/security/presentation/security_dashboard_screen.dart';
import 'package:school_pulse/features/security/presentation/screens/gate_management_screen.dart';
import 'package:school_pulse/features/security/presentation/screens/lost_and_found_screen.dart';
import 'package:school_pulse/features/security/presentation/screens/patrol_log_screen.dart';
import 'package:school_pulse/features/security/presentation/screens/admin_security_settings_screen.dart';
import 'package:school_pulse/features/security/presentation/screens/security_reports_screen.dart';
import 'package:school_pulse/features/transport/presentation/transport_coordinator_dashboard_screen.dart';
import 'package:school_pulse/features/discipline/presentation/discipline_dashboard_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/workload/teacher_workload_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/approvals/dean_approvals_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/interventions/academic_interventions_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/analytics/performance_analytics_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/curriculum/curriculum_management_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/monitoring/lesson_monitoring_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/qa/marks_qa_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/observations/class_observations_screen.dart';
import 'package:school_pulse/features/religion/presentation/religious_leader_dashboard_screen.dart';
import 'package:school_pulse/features/exams/presentation/exams_dashboard_screen.dart';
import 'package:school_pulse/features/hr/presentation/screens/hr_dashboard_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/director_approval_center_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/director_dashboard_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/director_reports_screen.dart';
import 'package:school_pulse/features/student_identity/presentation/screens/student_id_card_screen.dart';
import 'package:school_pulse/features/attendance_qr_integration/presentation/screens/qr_attendance_dashboard_screen.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/super_admin_dashboard.dart';
import 'package:school_pulse/features/visitors/domain/entities/visitor.dart';
import 'package:school_pulse/features/visitors/domain/entities/pre_approved_visitor.dart';
import 'package:school_pulse/features/visitors/presentation/pages/visitor_dashboard_screen.dart';
import 'package:school_pulse/features/visitors/presentation/pages/visitor_check_in_screen.dart';
import 'package:school_pulse/features/visitors/presentation/pages/visitor_scanner_screen.dart';
import 'package:school_pulse/features/visitors/presentation/pages/visitor_details_screen.dart';
import 'package:school_pulse/features/visitors/presentation/pages/student_pickup_page.dart';
import 'package:school_pulse/features/security/presentation/screens/pickup_authorizations_screen.dart';
import 'package:school_pulse/features/games/presentation/screens/games_dashboard_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/dean_dashboard_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/approvals/report_approval_screen.dart';
import 'package:school_pulse/features/notifications/presentation/staff_notification_center_screen.dart';

import 'package:school_pulse/features/branding/presentation/screens/splash_screen.dart'
    as pulse_splash;
import 'package:school_pulse/features/branding/presentation/screens/branded_splash_screen.dart';

import 'package:school_pulse/features/student/presentation/student_shell.dart';
import 'package:school_pulse/features/student/presentation/screens/student_dashboard_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_academics_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_homework_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_library_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_more_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_profile_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_fees_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_timetable_screen.dart';

import 'package:school_pulse/features/health/presentation/screens/student_health_profile_screen.dart';
import 'package:school_pulse/features/health/presentation/screens/health_history_screen.dart';
import 'package:school_pulse/features/health/presentation/screens/incident_details_screen.dart';
import 'package:school_pulse/features/nurse/presentation/screens/medicine_inventory_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isLoggingIn =
        state.uri.path.contains('/login') ||
        state.uri.path.contains('/welcome') ||
        state.uri.path == '/';

    if (authState is AuthInitial && !isLoggingIn) return '/welcome';

    // Protect Super Admin routes
    if (state.uri.path.startsWith('/super-admin')) {
      if (authState is AuthAuthenticated) {
        if (authState.user.role != UserRole.superAdmin) {
          return UserRoleRouting.dashboardPath(authState.user.role);
        }
      } else {
        return '/welcome';
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const pulse_splash.SplashScreen(),
    ),
    GoRoute(
      path: '/branded-splash',
      builder: (context, state) => const BrandedSplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/school-splash',
      builder: (context, state) =>
          SchoolSplashScreen(user: state.extra as UserEntity),
    ),
    ShellRoute(
      builder: (context, state, child) => StudentShell(child: child),
      routes: [
        GoRoute(
          path: '/student/dashboard',
          builder: (context, state) => const StudentDashboardScreen(),
        ),
        GoRoute(
          path: '/student/academics',
          builder: (context, state) => const StudentAcademicsScreen(),
        ),
        GoRoute(
          path: '/student/homework',
          builder: (context, state) => const StudentHomeworkScreen(),
        ),
        GoRoute(
          path: '/student/timetable',
          builder: (context, state) => const StudentTimetableScreen(),
        ),
        GoRoute(
          path: '/student/library',
          builder: (context, state) => const StudentLibraryScreen(),
        ),
        GoRoute(
          path: '/student/more',
          builder: (context, state) => const StudentMoreScreen(),
        ),
        GoRoute(
          path: '/student/profile',
          builder: (context, state) => const StudentProfileScreen(),
        ),
        GoRoute(
          path: '/student/fees',
          builder: (context, state) => const StudentFeesScreen(),
        ),
        GoRoute(
          path: '/student/health',
          builder: (context, state) => const HealthScreen(),
        ),
        GoRoute(
          path: '/student/discipline',
          builder: (context, state) => const DisciplineScreen(),
        ),
        GoRoute(
          path: '/student/transport',
          builder: (context, state) => const TransportScreen(),
        ),
        GoRoute(
          path: '/student/id-card',
          builder: (context, state) =>
              StudentIdCardScreen(student: state.extra as Student),
        ),
      ],
    ),
    GoRoute(
      path: '/parent/login/child-id',
      builder: (context, state) => const ChildIdScreen(),
    ),
    GoRoute(
      path: '/parent/login/verify',
      builder: (context, state) =>
          ParentPhoneScreen(accessCode: state.extra as ParentAccessCode?),
    ),
    GoRoute(
      path: '/parent/login/pin',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ParentPinScreen(
          accessCode: extra['accessCode'] as ParentAccessCode,
          phoneNumber: extra['phoneNumber'] as String,
        );
      },
    ),
    GoRoute(
      path: '/staff/login',
      builder: (context, state) => const StaffCredentialsScreen(),
    ),
    GoRoute(
      path: '/auth/force-setup',
      builder: (context, state) =>
          ForceSetPasswordScreen(user: state.extra as UserEntity?),
    ),
    GoRoute(path: '/login', redirect: (context, state) => '/welcome'),
    ShellRoute(
      builder: (context, state, child) {
        return ParentShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/parent/home',
          builder: (context, state) => const ParentHomeScreen(),
        ),
        GoRoute(
          path: '/parent/academics',
          builder: (context, state) => const AcademicsScreen(),
          routes: [
            GoRoute(
              path: 'report-card',
              builder: (context, state) => const ReportCardScreen(),
            ),
            GoRoute(
              path: 'attendance',
              builder: (context, state) => const AttendanceDetailScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/parent/fees',
          builder: (context, state) => const FeesScreen(),
          routes: [
            GoRoute(
              path: 'pay',
              builder: (context, state) => const PayNowScreen(),
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) => const PaymentHistoryScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/parent/messages',
          builder: (context, state) {
            final recipientId = state.uri.queryParameters['recipientId'];
            final recipientName = state.uri.queryParameters['recipientName'];
            final recipientRole = state.uri.queryParameters['recipientRole'];
            return MessagesScreen(
              initialRecipientId: recipientId,
              initialRecipientName: recipientName,
              initialRecipientRole: recipientRole,
            );
          },
        ),
        GoRoute(
          path: '/parent/more',
          builder: (context, state) => const MoreMenuScreen(),
        ),
        GoRoute(
          path: '/parent/health',
          builder: (context, state) => const HealthScreen(),
        ),
        GoRoute(
          path: '/parent/library',
          builder: (context, state) => const LibraryScreen(),
        ),
        GoRoute(
          path: '/parent/discipline',
          builder: (context, state) => const DisciplineScreen(),
        ),
        GoRoute(
          path: '/parent/transport',
          builder: (context, state) => const TransportScreen(),
        ),
        GoRoute(
          path: '/parent/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/parent/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/parent/calendar',
          builder: (context, state) => const SchoolCalendarScreen(),
        ),
        GoRoute(
          path: '/parent/boarding',
          builder: (context, state) => const ParentBoardingScreen(),
        ),
        GoRoute(
          path: '/parent/security',
          builder: (context, state) => const SecurityActivityScreen(),
        ),
      ],
    ),
    GoRoute(path: '/staff', redirect: (context, state) => '/staff/dashboard'),
    ShellRoute(
      builder: (context, state, child) {
        return StaffShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/staff/dashboard',
          builder: (context, state) => const TeacherDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/hub',
          builder: (context, state) => const StaffHubScreen(),
        ),
        GoRoute(
          path: '/staff/bursar',
          builder: (context, state) => const BursarDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/nurse',
          redirect: (context, state) {
            final auth = context.read<AuthBloc>().state;
            if (auth is! AuthAuthenticated) return '/welcome';
            const permitted = {
              UserRole.nurse,
              UserRole.schoolAdmin,
              UserRole.headTeacher,
              UserRole.deputyHead,
              UserRole.director,
            };
            if (!auth.user.roles.any(permitted.contains)) {
              return UserRoleRouting.dashboardPath(auth.user.role);
            }
            return null;
          },
          builder: (context, state) => const NurseDashboardScreen(),
          routes: [
            GoRoute(
              path: 'inventory',
              builder: (context, state) => BlocProvider(
                create: (_) => di.sl<HealthBloc>(),
                child: const MedicineInventoryScreen(),
              ),
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) => BlocProvider(
                create: (_) => di.sl<HealthBloc>(),
                child: const HealthHistoryScreen(),
              ),
            ),
            GoRoute(
              path: 'profile/:id',
              builder: (context, state) => BlocProvider(
                create: (_) => di.sl<HealthBloc>(),
                child: StudentHealthProfileScreen(
                  studentId: state.pathParameters['id']!,
                ),
              ),
            ),
            GoRoute(
              path: 'incident/:id',
              builder: (context, state) => BlocProvider(
                create: (_) => di.sl<HealthBloc>(),
                child: IncidentDetailsScreen(
                  incidentId: state.pathParameters['id']!,
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/librarian',
          builder: (context, state) => const LibrarianDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/security',
          builder: (context, state) => const SecurityDashboardScreen(),
          routes: [
            GoRoute(
              path: 'gates',
              builder: (context, state) => const GateManagementScreen(),
            ),
            GoRoute(
              path: 'pickup',
              builder: (context, state) => const StudentPickupPage(),
            ),
            GoRoute(
              path: 'pickup-authorizations',
              builder: (context, state) => const PickupAuthorizationsScreen(),
            ),
            GoRoute(
              path: 'lost-and-found',
              builder: (context, state) => const LostAndFoundScreen(),
            ),
            GoRoute(
              path: 'patrols',
              builder: (context, state) => const PatrolLogScreen(),
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const AdminSecuritySettingsScreen(),
            ),
            GoRoute(
              path: 'reports',
              builder: (context, state) => const SecurityReportsScreen(),
            ),
            GoRoute(
              path: 'visitors',
              builder: (context, state) => const VisitorDashboardScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => VisitorCheckInScreen(
                    preApprovedVisitor: state.extra as PreApprovedVisitor?,
                  ),
                ),
                GoRoute(
                  path: 'scan',
                  builder: (context, state) => const VisitorScannerScreen(),
                ),
                GoRoute(
                  path: 'details/:id',
                  builder: (context, state) {
                    final visitor = state.extra as Visitor;
                    return VisitorDetailsScreen(visitor: visitor);
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/staff/inventory',
          builder: (context, state) => const InventoryDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/matron',
          builder: (context, state) => const MatronDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/patron',
          builder: (context, state) => const PatronDashboard(),
          routes: [
            GoRoute(
              path: 'dorms',
              builder: (context, state) => const DormitoryManagementScreen(),
            ),
            GoRoute(
              path: 'attendance',
              builder: (context, state) => const BoardingAttendanceScreen(),
            ),
            GoRoute(
              path: 'welfare',
              builder: (context, state) => const WelfareManagementScreen(),
            ),
            GoRoute(
              path: 'discipline',
              builder: (context, state) => const DisciplineManagementScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/catering',
          builder: (context, state) => const CateringDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/games',
          builder: (context, state) => const GamesDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/transport',
          builder: (context, state) =>
              const TransportCoordinatorDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/discipline',
          builder: (context, state) => const DisciplineDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/dean',
          builder: (context, state) => const DeanDashboardScreen(),
          routes: [
            GoRoute(
              path: 'curriculum',
              builder: (context, state) => const CurriculumManagementScreen(),
            ),
            GoRoute(
              path: 'workload',
              builder: (context, state) => const TeacherWorkloadScreen(),
            ),
            GoRoute(
              path: 'lessons',
              builder: (context, state) => const LessonMonitoringScreen(),
            ),
            GoRoute(
              path: 'marks-qa',
              builder: (context, state) => const MarksQAScreen(),
            ),
            GoRoute(
              path: 'approvals',
              builder: (context, state) => const DeanApprovalsScreen(),
              routes: [
                GoRoute(
                  path: 'reports',
                  builder: (context, state) => const ReportApprovalScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'interventions',
              builder: (context, state) => const AcademicInterventionsScreen(),
            ),
            GoRoute(
              path: 'observations',
              builder: (context, state) => const ClassObservationsScreen(),
            ),
            GoRoute(
              path: 'analytics',
              builder: (context, state) => const PerformanceAnalyticsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/religious-leader',
          builder: (context, state) => const ReligiousLeaderDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/exams',
          builder: (context, state) => const ExamsDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/hr',
          builder: (context, state) => const HRDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/director',
          builder: (context, state) => const DirectorDashboardScreen(),
          routes: [
            GoRoute(
              path: 'approvals',
              builder: (context, state) => const DirectorApprovalCenterScreen(),
            ),
            GoRoute(
              path: 'reports',
              builder: (context, state) => const DirectorReportsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/admin',
          builder: (context, state) => const AdminDashboardScreen(),
          routes: [
            GoRoute(
              path: 'users',
              builder: (context, state) => const UserManagementScreen(),
            ),
            GoRoute(
              path: 'broadcast-sms',
              builder: (context, state) => const BroadcastSmsScreen(),
            ),
            GoRoute(
              path: 'config',
              builder: (context, state) => const SystemConfigScreen(),
            ),
            GoRoute(
              path: 'structure',
              builder: (context, state) => const StructureScreen(),
              routes: [
                GoRoute(
                  path: 'institution',
                  builder: (context, state) => const InstitutionProfileScreen(),
                ),
                GoRoute(
                  path: 'academic',
                  builder: (context, state) => const AcademicStructureScreen(),
                ),
                GoRoute(
                  path: 'people',
                  builder: (context, state) => const PeopleStructureScreen(),
                ),
                GoRoute(
                  path: 'assessment',
                  builder: (context, state) => const AssessmentGradingScreen(),
                ),
                GoRoute(
                  path: 'campus',
                  builder: (context, state) => const CampusFacilitiesScreen(),
                ),
                GoRoute(
                  path: 'operations',
                  builder: (context, state) => const OperationsConfigScreen(),
                ),
                GoRoute(
                  path: 'feature-toggles',
                  builder: (context, state) => const FeatureTogglesScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'visitors',
              builder: (context, state) => const VisitorLogScreen(),
            ),
            GoRoute(
              path: 'staff-attendance',
              builder: (context, state) => const AdminStaffAttendanceScreen(),
            ),
            GoRoute(
              path: 'appointments',
              builder: (context, state) => const AppointmentsScreen(),
            ),
            GoRoute(
              path: 'audit-log',
              builder: (context, state) => const AuditLogScreen(),
            ),
            GoRoute(
              path: 'broadcast-history',
              builder: (context, state) => const BroadcastHistoryScreen(),
            ),
            GoRoute(
              path: 'subscription',
              builder: (context, state) => const SubscriptionScreen(),
            ),
            GoRoute(
              path: 'student-id-card',
              builder: (context, state) {
                final student = state.extra as Student;
                return StudentIdCardScreen(student: student);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/staff/notifications',
          builder: (context, state) => const StaffNotificationCenterScreen(),
        ),
        GoRoute(
          path: '/staff/attendance',
          builder: (context, state) => const TeacherAttendanceScreen(),
          routes: [
            GoRoute(
              path: 'history',
              builder: (context, state) =>
                  const TeacherAttendanceHistoryScreen(),
            ),
            GoRoute(
              path: 'qr-dashboard',
              builder: (context, state) => const QrAttendanceDashboardScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/marks',
          builder: (context, state) => const MarksEntryScreen(),
        ),
        GoRoute(
          path: '/staff/messages',
          builder: (context, state) {
            final authState = context.read<AuthBloc>().state;
            final isAdmin =
                authState is AuthAuthenticated &&
                UserRoleDisplay.adminConsoleRoles.contains(authState.user.role);

            final recipientId = state.uri.queryParameters['recipientId'];
            final recipientName = state.uri.queryParameters['recipientName'];
            final recipientRole = state.uri.queryParameters['recipientRole'];

            if (isAdmin && recipientId == null) {
              return const AdminMessagesScreen();
            }

            return MessagesScreen(
              initialRecipientId: recipientId,
              initialRecipientName: recipientName,
              initialRecipientRole: recipientRole,
            );
          },
        ),
        GoRoute(
          path: '/staff/more',
          builder: (context, state) => const StaffMoreScreen(),
        ),
        GoRoute(
          path: '/staff/homework',
          builder: (context, state) => const HomeworkScreen(),
        ),
        GoRoute(
          path: '/staff/report-comments',
          builder: (context, state) => const ReportCommentsScreen(),
        ),
        GoRoute(
          path: '/staff/profile',
          builder: (context, state) => const StaffProfileScreen(),
        ),
        GoRoute(
          path: '/staff/security-settings',
          builder: (context, state) => const SecuritySettingsScreen(),
        ),
        GoRoute(
          path: '/staff/class-analytics',
          builder: (context, state) => const ClassAnalyticsScreen(),
        ),
        GoRoute(
          path: '/staff/calendar',
          builder: (context, state) => const SchoolCalendarScreen(),
        ),
        GoRoute(
          path: '/staff/lesson-plans',
          builder: (context, state) => const LessonPlansScreen(),
        ),
      ],
    ),
    // Deliberately outside every ShellRoute above - the owner console has
    // its own complete navigation (sidebar on wide, bottom nav on mobile)
    // and must never be wrapped in StaffShell's staff-facing bottom nav.
    GoRoute(
      path: '/super-admin',
      builder: (context, state) => const SuperAdminDashboard(),
    ),
  ],
);

class ParentShell extends StatelessWidget {
  final Widget child;
  const ParentShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/parent/home')) return 0;
    if (location.startsWith('/parent/academics')) return 1;
    if (location.startsWith('/parent/fees')) return 2;
    if (location.startsWith('/parent/messages')) return 3;
    if (location.startsWith('/parent/more')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/parent/home');
        break;
      case 1:
        context.go('/parent/academics');
        break;
      case 2:
        context.go('/parent/fees');
        break;
      case 3:
        context.go('/parent/messages');
        break;
      case 4:
        context.go('/parent/more');
        break;
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutPressed());
              Navigator.pop(context);
              context.go('/welcome');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final config = context.watch<ThemeProvider>().config;
    final logoUrl = config?.schoolLogoUrl;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              selectedIndex: _calculateSelectedIndex(context),
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: logoUrl != null && logoUrl.isNotEmpty
                    ? Image.network(
                        logoUrl,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.school,
                              color: Colors.blue,
                              size: 32,
                            ),
                      )
                    : const Icon(Icons.school, color: Colors.blue, size: 32),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school),
                  label: Text('Academics'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(Icons.account_balance_wallet),
                  label: Text('Fees'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.message_outlined),
                  selectedIcon: Icon(Icons.message),
                  label: Text('Messages'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.more_horiz),
                  label: Text('More'),
                ),
              ],
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _handleLogout(context),
                      tooltip: 'Logout',
                    ),
                  ),
                ),
              ),
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _calculateSelectedIndex(context),
              onTap: (idx) => _onItemTapped(idx, context),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.school_outlined),
                  activeIcon: Icon(Icons.school),
                  label: 'Academics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet),
                  label: 'Fees',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message_outlined),
                  activeIcon: Icon(Icons.message),
                  label: 'Messages',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz),
                  label: 'More',
                ),
              ],
            )
          : null,
    );
  }
}
