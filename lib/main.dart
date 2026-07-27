import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:school_pulse/app/router.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/firebase_options.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
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
import 'package:school_pulse/features/gatekeeper/presentation/bloc/gatekeeper_bloc.dart';
import 'package:school_pulse/features/receptionist/presentation/bloc/receptionist_bloc.dart';
import 'package:school_pulse/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:school_pulse/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:school_pulse/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:school_pulse/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:school_pulse/features/hr/presentation/bloc/hr_bloc.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/religion/presentation/bloc/religion_bloc.dart';
import 'package:school_pulse/features/exams/presentation/bloc/exams_bloc.dart';
import 'package:school_pulse/features/catering/presentation/bloc/catering_bloc.dart';
import 'package:school_pulse/features/games/presentation/bloc/games_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_bloc.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_event.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_state.dart';
import 'package:school_pulse/core/notification/notification_service.dart';

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
        BlocProvider(
          create: (_) => di.sl<AcademicBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<FinanceBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<HealthBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<TransportBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<LibraryBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<DisciplineBloc>(),
        ),
        BlocProvider(
          create: (_) => SelectedStudentBloc(),
        ),
        BlocProvider(
          create: (_) => di.sl<StudentsBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<NotificationsBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<CalendarBloc>()..add(LoadCalendarEvents()),
        ),
        BlocProvider(
          create: (_) => di.sl<TeacherBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<GatekeeperBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<InventoryBloc>()..add(LoadInventory()),
        ),
        BlocProvider(
          create: (_) => di.sl<ReceptionistBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<SecurityBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<DeanBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<ReligionBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<ExamsBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<CateringBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<GamesBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<MatronBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<HrBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<SystemConfigBloc>()..add(WatchSystemConfig()),
        ),
      ],
      child: const SchoolPulseAppView(),
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
              // Sync FCM token whenever a user authenticates
              NotificationService().syncToken(state.user.id);
            }
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final config = themeProvider.config;
          final primary = config?.primaryColor != null ? Color(int.parse(config!.primaryColor!)) : null;
          final secondary = config?.secondaryColor != null ? Color(int.parse(config!.secondaryColor!)) : null;

          return MaterialApp.router(
            title: config?.schoolName ?? 'School Pulse',
            theme: AppTheme.light(primary: primary, secondary: secondary),
            darkTheme: AppTheme.dark(primary: primary, secondary: secondary),
            themeMode: themeProvider.themeMode,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
