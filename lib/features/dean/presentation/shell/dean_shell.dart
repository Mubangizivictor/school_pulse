import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/dean/presentation/screens/alerts/academic_alerts_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/analytics/performance_analytics_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/assessments/assessments_overview_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/curriculum/curriculum_management_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/dean_dashboard_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/exams/exams_overview_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/interventions/academic_interventions_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/monitoring/lesson_monitoring_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/monitoring/missed_lessons_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/more/dean_more_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/operations/todays_operations_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/qa/marks_qa_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/students/student_academic_profile_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/workload/teacher_workload_screen.dart';

/// Bottom-navigation shell for the Dean of Studies (DOS) module.
///
/// 5 tabs: Overview / Teaching / Assessments / Reports / More.
/// Each tab owns a nested [Navigator] so that screens pushed on top of a
/// tab's root keep the [DeanShell]'s bottom nav visible (push-on-top-of-tab
/// pattern). Pushed screens are reached via named routes registered on each
/// tab's own `onGenerateRoute`.
class DeanShell extends StatefulWidget {
  const DeanShell({super.key});

  @override
  State<DeanShell> createState() => _DeanShellState();
}

class _DeanShellState extends State<DeanShell> {
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined, size: 24),
      selectedIcon: Icon(
        Icons.dashboard_rounded,
        size: 24,
        color: AppColors.royalBlue,
      ),
      label: 'Overview',
    ),
    NavigationDestination(
      icon: Icon(Icons.school_outlined, size: 24),
      selectedIcon: Icon(
        Icons.school_rounded,
        size: 24,
        color: AppColors.royalBlue,
      ),
      label: 'Teaching',
    ),
    NavigationDestination(
      icon: Icon(Icons.fact_check_outlined, size: 24),
      selectedIcon: Icon(
        Icons.fact_check_rounded,
        size: 24,
        color: AppColors.royalBlue,
      ),
      label: 'Assessments',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined, size: 24),
      selectedIcon: Icon(
        Icons.bar_chart_rounded,
        size: 24,
        color: AppColors.royalBlue,
      ),
      label: 'Reports',
    ),
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined, size: 24),
      selectedIcon: Icon(
        Icons.grid_view_rounded,
        size: 24,
        color: AppColors.royalBlue,
      ),
      label: 'More',
    ),
  ];

  /// Each tab's route table: `/` is the tab root, other entries are screens
  /// pushed on top of that tab per the plan's tab-mapping table.
  Widget Function(BuildContext) _routeBuilder(int tabIndex, String routeName) {
    switch (tabIndex) {
      case 0: // Overview
        switch (routeName) {
          case 'today':
            return (_) => const TodaysOperationsScreen();
          case 'alerts':
            return (_) => const AcademicAlertsScreen();
          case 'student':
            return (context) {
              final studentId =
                  ModalRoute.of(context)?.settings.arguments as String? ?? '';
              return StudentAcademicProfileScreen(studentId: studentId);
            };
          default:
            return (_) => const DeanDashboardScreen();
        }
      case 1: // Teaching
        switch (routeName) {
          case 'lessons':
            return (_) => const LessonMonitoringScreen();
          case 'missed-lessons':
            return (_) => const MissedLessonsScreen();
          case 'syllabus':
            return (_) => const CurriculumManagementScreen();
          default:
            return (_) => const TeacherWorkloadScreen();
        }
      case 2: // Assessments
        switch (routeName) {
          case 'marks-qa':
            return (_) => const MarksQAScreen();
          case 'interventions':
            return (_) => const AcademicInterventionsScreen();
          default:
            return (_) => const AssessmentsOverviewScreen();
        }
      case 3: // Reports
        switch (routeName) {
          case 'readiness':
            return (_) => const PerformanceAnalyticsScreen();
          default:
            return (_) => const ExamsOverviewScreen();
        }
      case 4: // More
      default:
        return (_) => const DeanMoreScreen();
    }
  }

  Widget _buildTabNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      initialRoute: '/',
      onGenerateRoute: (routeSettings) {
        final routeName = (routeSettings.name ?? '/').replaceFirst('/', '');
        return MaterialPageRoute(
          builder: _routeBuilder(index, routeName),
          settings: routeSettings,
        );
      },
    );
  }

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) {
      // Tapping the active tab again pops its nested Navigator to root.
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() => _selectedIndex = index);
  }

  Future<bool> _onWillPop() async {
    final isFirstRouteInCurrentTab =
        !(_navigatorKeys[_selectedIndex].currentState?.canPop() ?? false);
    if (isFirstRouteInCurrentTab) {
      return true;
    }
    _navigatorKeys[_selectedIndex].currentState?.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: List.generate(5, _buildTabNavigator),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: NavigationBar(
            height: 64,
            backgroundColor: isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            indicatorColor: AppColors.electricBlue.withValues(alpha: 0.1),
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: _destinations,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      ),
    );
  }
}
