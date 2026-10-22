import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/repositories/exam_factory_repository.dart';
import '../../domain/services/exam_factory_offline_queue_service.dart';
import '../bloc/exam_factory_cubit.dart';

/// Wraps an Exam Factory screen with a cubit scoped to the signed-in user's
/// institution. Built per navigation rather than as a DI singleton because
/// institutionId/uid are only known once authenticated. Shared by
/// app/router.dart's routes and DeanShell's Exams tab so both entry points
/// into the module provide the same cubit the same way.
Widget examFactoryScoped(BuildContext context, Widget child) {
  final authState = context.read<AuthBloc>().state;
  final institutionId = authState is AuthAuthenticated
      ? authState.user.schoolId
      : '';
  final userId = authState is AuthAuthenticated ? authState.user.id : '';
  return BlocProvider<ExamFactoryCubit>(
    create: (_) => ExamFactoryCubit(
      repository: di.sl<ExamFactoryRepository>(),
      institutionId: institutionId,
      currentUserId: userId,
      networkInfo: di.sl<NetworkInfo>(),
      offlineQueue: di.sl<ExamFactoryOfflineQueueService>(),
    ),
    child: child,
  );
}
