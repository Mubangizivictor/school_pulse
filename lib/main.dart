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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Auto-seed admin on first run. 
  // You can comment this out after the first successful run.
  // await AdminSeeder.seedAdmin();

  await di.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
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
          create: (_) => di.sl<TeacherBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<GatekeeperBloc>(),
        ),
        BlocProvider(
          create: (_) => di.sl<ReceptionistBloc>(),
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'School Pulse',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
