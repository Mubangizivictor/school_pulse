import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:school_pulse/features/notifications/notification_coordinator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/app/router.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/firebase_options.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_cubit.dart';
import 'package:school_pulse/features/institution/presentation/widgets/subscription_access_gate.dart';
import 'package:school_pulse/features/super_admin/presentation/widgets/owner_app_lock_gate.dart';
import 'package:school_pulse/features/super_admin/data/datasources/owner_session_remote_data_source.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/core/utils/device_info_service.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/transport/presentation/bloc/transport_bloc.dart';
import 'package:school_pulse/features/library/presentation/bloc/library_bloc.dart';
import 'package:school_pulse/features/discipline/presentation/bloc/discipline_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_attendance/class_attendance_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_attendance/class_attendance_history_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_students/class_students_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_announcements/class_announcements_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_performance/class_performance_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_reports/class_reports_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_tasks/class_tasks_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_work/class_work_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_dashboard/class_teacher_dashboard_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_dashboard/subject_teacher_dashboard_bloc.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_bloc.dart';
import 'package:school_pulse/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:school_pulse/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:school_pulse/features/inventory/presentation/bloc/stores_assets_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_event.dart';
import 'package:school_pulse/features/hr/presentation/bloc/hr_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/religion/presentation/bloc/religion_bloc.dart';
import 'package:school_pulse/features/exams/presentation/bloc/exams_bloc.dart';
import 'package:school_pulse/features/catering/presentation/bloc/catering_bloc.dart';
import 'package:school_pulse/features/games/presentation/bloc/games_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_event.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_state.dart';
import 'package:school_pulse/core/notification/notification_service.dart';
import 'package:school_pulse/features/biometrics/presentation/bloc/biometrics_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/super_admin/presentation/bloc/super_admin_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_event.dart';
import 'package:school_pulse/features/branding/presentation/screens/branding_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('Firebase already initialized, skipping...');
    } else {
      rethrow;
    }
  }

  await NotificationService().initialize();

  await di.init();

  // Notification pipeline: register channels and bind the FCM listeners.
  // Deliberately after di.init() (it needs the container) and deliberately
  // not awaited beyond this - the cold-launch check below is the only part
  // that touches the network, and it is timeout-guarded inside.
  await di.sl<NotificationCoordinator>().initialize();
  unawaited(di.sl<NotificationCoordinator>().checkInitialMessage());

  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const SchoolPulseApp(),
    ),
  );
}

class SchoolPulseApp extends StatelessWidget {
  const SchoolPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider(create: (_) => di.sl<InstitutionContextCubit>()),
        BlocProvider(
          create: (_) => di.sl<BrandingBloc>()..add(InitializeBranding()),
        ),
        BlocProvider(create: (_) => di.sl<AcademicBloc>()),
        BlocProvider(create: (_) => di.sl<FinanceBloc>()),
        BlocProvider(create: (_) => di.sl<HealthBloc>()),
        BlocProvider(create: (_) => di.sl<TransportBloc>()),
        BlocProvider(create: (_) => di.sl<LibraryBloc>()),
        BlocProvider(create: (_) => di.sl<DisciplineBloc>()),
        BlocProvider(create: (_) => SelectedStudentBloc()),
        BlocProvider(create: (_) => di.sl<StudentsBloc>()),
        BlocProvider(create: (_) => di.sl<NotificationsBloc>()),
        BlocProvider(create: (_) => di.sl<TeacherBloc>()),
        // Provided app-wide, not per-screen: the Subject Teacher tabs are
        // separate routes, and each has to read the same active
        // responsibility as the others.
        BlocProvider(create: (_) => di.sl<SubjectTeacherContextBloc>()),
        BlocProvider(create: (_) => di.sl<SubjectTeacherDashboardBloc>()),
        // Same reasoning for the Class Teacher panel: Home, Students,
        // Reports, Tasks and More are separate routes that must all read the
        // same active class.
        BlocProvider(create: (_) => di.sl<ClassTeacherContextBloc>()),
        BlocProvider(create: (_) => di.sl<ClassTeacherDashboardBloc>()),
        BlocProvider(create: (_) => di.sl<ClassStudentsBloc>()),
        BlocProvider(create: (_) => di.sl<ClassAttendanceBloc>()),
        BlocProvider(create: (_) => di.sl<ClassAttendanceHistoryBloc>()),
        BlocProvider(create: (_) => di.sl<ClassWorkBloc>()),
        BlocProvider(create: (_) => di.sl<ClassAnnouncementsBloc>()),
        BlocProvider(create: (_) => di.sl<ClassPerformanceBloc>()),
        BlocProvider(create: (_) => di.sl<ClassReportsBloc>()),
        BlocProvider(create: (_) => di.sl<ClassTasksBloc>()),
        BlocProvider(create: (_) => di.sl<DirectorBloc>()),
        BlocProvider(
          create: (_) => di.sl<InventoryBloc>()..add(LoadInventory()),
        ),
        BlocProvider(create: (_) => di.sl<StoresAssetsBloc>()),
        BlocProvider(create: (_) => di.sl<StructureBloc>()),
        BlocProvider(create: (_) => di.sl<DeanBloc>()),
        BlocProvider(create: (_) => di.sl<ReligionBloc>()),
        BlocProvider(create: (_) => di.sl<ExamsBloc>()),
        BlocProvider(create: (_) => di.sl<CateringBloc>()),
        BlocProvider(create: (_) => di.sl<GamesBloc>()),
        BlocProvider(create: (_) => di.sl<MatronBloc>()),
        BlocProvider(create: (_) => di.sl<PatronBloc>()),
        BlocProvider(create: (_) => di.sl<HrBloc>()),
        BlocProvider(
          create: (_) => di.sl<SystemConfigBloc>()..add(WatchSystemConfig()),
        ),
        BlocProvider(create: (_) => di.sl<BiometricsBloc>()),
        BlocProvider(create: (_) => di.sl<SuperAdminBloc>()),
      ],
      child: const BrandingInitializer(child: SchoolPulseAppView()),
    );
  }
}

class SchoolPulseAppView extends StatelessWidget {
  const SchoolPulseAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SystemConfigBloc, SystemConfigState>(
          listener: (context, state) {
            if (state is SystemConfigLoaded) {
              context.read<ThemeProvider>().updateConfig(state.config);
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              NotificationService().syncToken(state.user.id);
              // Registers this device, starts the badge stream, drains any
              // offline read/acknowledge queue, and replays a deep link that
              // was stashed while signed out.
              di.sl<NotificationCoordinator>().onSignedIn(state.user);

              // Load structure data once authenticated.
              context.read<StructureBloc>().add(
                LoadStructureData(state.user.schoolId),
              );

              // Institution Context Engine: restore the last-active tenant
              // (for multi-institution users) or fall back to home schoolId.
              // superAdmin has no tenant to scope to - it operates platform-wide.
              if (state.user.role != UserRole.superAdmin) {
                context.read<InstitutionContextCubit>().restore(
                  state.user.schoolId,
                );
              } else {
                // Registers/refreshes this device in the owner's real
                // session registry on every successful sign-in, so
                // Trusted Devices / Active Sessions reflect reality even
                // if the owner never opens the Security screens.
                _registerOwnerSession(state.user.id);
              }
            } else if (state is AuthUnauthenticated) {
              // Revoking the token is what actually stops delivery; clearing
              // the tray stops the next user of a shared device seeing the
              // previous user's alerts.
              di.sl<NotificationCoordinator>().onSignedOut();
              context.read<InstitutionContextCubit>().clear();
            }
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: themeProvider.branding?.schoolName ?? 'School Pulse',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router,
            builder: (context, child) => OwnerAppLockGate(
              child: SubscriptionAccessGate(
                child: child ?? const SizedBox.shrink(),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  static Future<void> _registerOwnerSession(String ownerId) async {
    final deviceIdService = di.sl<DeviceIdService>();
    final deviceInfoService = di.sl<DeviceInfoService>();
    final sessions = di.sl<OwnerSessionRemoteDataSource>();
    final deviceId = await deviceIdService.getDeviceId();
    await sessions.upsertSession(
      ownerId: ownerId,
      deviceId: deviceId,
      platform: await deviceInfoService.platformLabel(),
      deviceName: await deviceInfoService.deviceName(),
      isNewSession: false,
    );
  }
}
