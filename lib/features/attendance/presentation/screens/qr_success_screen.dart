import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/attendance_qr_integration/domain/entities/qr_attendance_record.dart';
import 'package:school_pulse/features/attendance_qr_integration/presentation/bloc/attendance_qr_bloc.dart';
import 'package:school_pulse/features/attendance_qr_integration/presentation/bloc/attendance_qr_event.dart';
import 'package:school_pulse/features/attendance_qr_integration/presentation/bloc/attendance_qr_state.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';

/// Maps the signed-in operator's role onto the module tag the QR-attendance
/// pipeline (and its Firestore write target) already understands -
/// boarding roll call, staff clock-in, or the default class/daily register.
String _moduleForRole(UserRole role) {
  switch (role) {
    case UserRole.boardingMatron:
    case UserRole.boardingPatron:
      return 'boarding';
    case UserRole.classTeacher:
    case UserRole.subjectTeacher:
      return 'class';
    default:
      return 'staff';
  }
}

class QRSuccessScreen extends StatefulWidget {
  final Student student;

  const QRSuccessScreen({super.key, required this.student});

  @override
  State<QRSuccessScreen> createState() => _QRSuccessScreenState();
}

class _QRSuccessScreenState extends State<QRSuccessScreen> {
  DateTime? _markedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markPresent());
  }

  void _markPresent() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final operator = authState.user;

    context.read<AttendanceQrBloc>().add(MarkAttendanceEvent(
          studentUniqueId: widget.student.id,
          studentName: widget.student.name,
          className: widget.student.classId,
          status: QrAttendanceStatus.present,
          scannedBy: operator.id,
          schoolId: widget.student.schoolId,
          module: _moduleForRole(operator.role),
        ));
    setState(() => _markedAt = DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final student = widget.student;

    return BlocListener<AttendanceQrBloc, AttendanceQrState>(
      listener: (context, state) {
        if (state is AttendanceQrError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save attendance: ${state.message}'), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => context.pop(),
        ),
        title: const Text('Scan Success'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  FadeInSlide(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: semantic.success, width: 3),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: student.photoUrl != null ? NetworkImage(student.photoUrl!) : null,
                                child: student.photoUrl == null
                                    ? Text(
                                        student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: semantic.success,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          student.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student.studentCode,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        StatusBadge(label: student.classId, color: AppColors.royalBlue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 200),
                    child: AppCard(
                      color: semantic.success.withValues(alpha: 0.05),
                      borderColor: semantic.success.withValues(alpha: 0.2),
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time, color: semantic.success, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _markedAt == null
                                ? 'Recording attendance...'
                                : 'Marked Present at ${DateFormat('h:mm a').format(_markedAt!)}',
                            style: TextStyle(
                              color: semantic.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated(context),
              border: Border(top: BorderSide(color: AppColors.border(context))),
            ),
            child: SafeArea(
              top: false,
              child: FadeInSlide(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PrimaryButton(
                      label: 'Next Student',
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: 'View Summary',
                      onPressed: () => context.push('/staff/attendance/summary'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
