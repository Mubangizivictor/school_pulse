import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart';
import '../bloc/school_calendar_bloc.dart';
import '../bloc/school_calendar_event.dart';
import 'calendar_overview_screen.dart';

class CalendarHomeScreen extends StatelessWidget {
  const CalendarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }
    final user = authState.user;

    return BlocProvider(
      create: (_) => sl<SchoolCalendarBloc>()
        ..add(
          LoadCalendarRequested(schoolId: user.schoolId, operatorUser: user),
        ),
      // CalendarOverviewScreen is the canonical calendar experience. Keeping
      // the provider here means the route remains shell/navigation compatible.
      child: const CalendarOverviewScreen(),
    );
  }
}
