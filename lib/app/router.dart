import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/login_flow/welcome_screen.dart';
import 'package:school_pulse/features/auth/login_flow/parent_login_screens.dart';
import 'package:school_pulse/features/auth/login_flow/staff_login_screens.dart';
import 'package:school_pulse/features/auth/login_flow/platform_blocked_screen.dart';
import 'package:school_pulse/features/auth/login_flow/force_set_password_screen.dart';
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
import 'package:school_pulse/features/shared/shell_screen.dart';
import 'package:school_pulse/features/teacher/dashboard_screen.dart';
import 'package:school_pulse/features/teacher/attendance_screen.dart';
import 'package:school_pulse/features/teacher/marks_entry_screen.dart';
import 'package:school_pulse/features/teacher/staff_more_screen.dart';
import 'package:school_pulse/features/bursar/bursar_dashboard.dart';
import 'package:school_pulse/features/nurse/nurse_dashboard.dart';
import 'package:school_pulse/features/librarian/librarian_dashboard.dart';
import 'package:school_pulse/features/gatekeeper/gatekeeper_dashboard.dart';
import 'package:school_pulse/features/receptionist/receptionist_dashboard.dart';
import 'package:school_pulse/features/matron/matron_dashboard.dart';
import 'package:school_pulse/features/catering/presentation/catering_dashboard_screen.dart';
import 'package:school_pulse/features/games/presentation/games_dashboard_screen.dart';
import 'package:school_pulse/features/security/presentation/security_dashboard_screen.dart';
import 'package:school_pulse/features/transport/presentation/transport_coordinator_dashboard_screen.dart';
import 'package:school_pulse/features/discipline/presentation/discipline_dashboard_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/dean_dashboard_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/curriculum/syllabus_coverage_screen.dart';
import 'package:school_pulse/features/religion/presentation/religious_leader_dashboard_screen.dart';

import 'package:school_pulse/features/auth/login_flow/splash_screen.dart';
import 'package:school_pulse/features/admin/user_management_screen.dart';
import 'package:school_pulse/features/admin/admin_dashboard_screen.dart';
import 'package:school_pulse/features/admin/system_config_screen.dart';
import 'package:school_pulse/features/admin/school_structure_screen.dart';
import 'package:school_pulse/features/admin/broadcast_sms_screen.dart';
import 'package:school_pulse/features/admin/visitor_log_screen.dart';
import 'package:school_pulse/features/admin/admin_staff_attendance_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final path = state.uri.path;
    
    // Global platform guards
    if (path.startsWith('/parent') && kIsWeb) {
      return '/platform-blocked?role=parent';
    }
    
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
      GoRoute(
        path: '/parent/login/child-id',
        builder: (context, state) => const ChildIdScreen(),
      ),
      GoRoute(
        path: '/parent/login/verify',
        builder: (context, state) => ParentVerifyScreen(accessCode: state.extra as ParentAccessCode?),
      ),
      GoRoute(
        path: '/parent/login/unlock',
        builder: (context, state) => const ParentUnlockScreen(),
      ),
      GoRoute(
        path: '/staff/login/role',
        builder: (context, state) => const StaffRolePickerScreen(),
      ),
      GoRoute(
        path: '/staff/login',
        builder: (context, state) {
          final roleName = state.uri.queryParameters['role'];
          final role = roleName != null 
              ? UserRole.values.firstWhere((r) => r.name == roleName, orElse: () => UserRole.classTeacher)
              : null;
          return StaffCredentialsScreen(initialRole: role);
        },
      ),
      GoRoute(
        path: '/staff/set-password',
        builder: (context, state) => ForceSetPasswordScreen(role: state.extra as UserRole?),
      ),
      GoRoute(
        path: '/platform-blocked',
        builder: (context, state) {
          final roleName = state.uri.queryParameters['role'];
          final role = UserRole.values.firstWhere((r) => r.name == roleName, orElse: () => UserRole.parent);
          return PlatformBlockedScreen(role: role);
        },
      ),
      GoRoute(
        path: '/login',
        redirect: (context, state) => kIsWeb ? '/staff/login/role' : '/welcome',
      ),
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
            builder: (context, state) => const MessagesScreen(),
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
        ],
      ),
      GoRoute(
        path: '/staff',
        redirect: (context, state) => '/staff/dashboard',
      ),
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
            path: '/staff/bursar',
            builder: (context, state) => const BursarDashboardScreen(),
          ),
          GoRoute(
            path: '/staff/nurse',
            builder: (context, state) => const NurseDashboardScreen(),
          ),
          GoRoute(
            path: '/staff/librarian',
            builder: (context, state) => const LibrarianDashboardScreen(),
          ),
          GoRoute(
            path: '/staff/gatekeeper',
            builder: (context, state) => const GatekeeperDashboardScreen(),
          ),
          GoRoute(
            path: '/staff/receptionist',
            builder: (context, state) => const ReceptionistDashboardScreen(),
          ),
          GoRoute(
            path: '/staff/matron',
            builder: (context, state) => const MatronDashboardScreen(),
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
            path: '/staff/security',
            builder: (context, state) => const SecurityDashboardScreen(),
          ),
          GoRoute(
            path: '/staff/transport',
            builder: (context, state) => const TransportCoordinatorDashboardScreen(),
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
                builder: (context, state) => const SyllabusCoverageScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/staff/religious-leader',
            builder: (context, state) => const ReligiousLeaderDashboardScreen(),
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
                builder: (context, state) => const SchoolStructureScreen(),
              ),
              GoRoute(
                path: 'visitors',
                builder: (context, state) => const VisitorLogScreen(),
              ),
              GoRoute(
                path: 'staff-attendance',
                builder: (context, state) => const AdminStaffAttendanceScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/staff/attendance',
            builder: (context, state) => const TeacherAttendanceScreen(),
          ),
          GoRoute(
            path: '/staff/marks',
            builder: (context, state) => const MarksEntryScreen(),
          ),
          GoRoute(
            path: '/staff/messages',
            builder: (context, state) => const MessagesScreen(), // Reusing Messages Screen
          ),
          GoRoute(
            path: '/staff/more',
            builder: (context, state) => const StaffMoreScreen(),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              selectedIndex: _calculateSelectedIndex(context),
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: Text('Academics')),
                NavigationRailDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: Text('Fees')),
                NavigationRailDestination(icon: Icon(Icons.message_outlined), selectedIcon: Icon(Icons.message), label: Text('Messages')),
                NavigationRailDestination(icon: Icon(Icons.more_horiz), label: Text('More')),
              ],
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
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.school_outlined), activeIcon: Icon(Icons.school), label: 'Academics'),
                BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Fees'),
                BottomNavigationBarItem(icon: Icon(Icons.message_outlined), activeIcon: Icon(Icons.message), label: 'Messages'),
                BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
              ],
            )
          : null,
    );
  }
}
