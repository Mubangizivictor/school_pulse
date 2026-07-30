import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../student/domain/entities/student.dart';
import '../bloc/attendance_qr_bloc.dart';
import '../bloc/attendance_qr_event.dart';
import '../bloc/attendance_qr_state.dart';
import '../../domain/entities/qr_attendance_record.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AttendanceConfirmationScreen extends StatelessWidget {
  final Student student;
  final String module; // 'class', 'dorm', 'event', etc.

  const AttendanceConfirmationScreen({
    super.key,
    required this.student,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Attendance'),
      ),
      body: BlocListener<AttendanceQrBloc, AttendanceQrState>(
        listener: (context, state) {
          if (state is AttendanceMarkedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop();
          } else if (state is AttendanceQrError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StudentProfileHeader(student: student),
              const SizedBox(height: 32),
              Text(
                'Mark attendance for ${module.toUpperCase()}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatusButton(
                      label: 'Present',
                      color: Colors.green,
                      icon: Icons.check_circle,
                      onPressed: () => _markAttendance(context, QrAttendanceStatus.present),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatusButton(
                      label: 'Late',
                      color: Colors.orange,
                      icon: Icons.access_time,
                      onPressed: () => _markAttendance(context, QrAttendanceStatus.late),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _StatusButton(
                label: 'Excused',
                color: Colors.blue,
                icon: Icons.info,
                onPressed: () => _markAttendance(context, QrAttendanceStatus.excused),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markAttendance(BuildContext context, QrAttendanceStatus status) {
    final authState = context.read<AuthBloc>().state;
    String scannedBy = 'Unknown';
    String schoolId = 'Unknown';

    if (authState is AuthAuthenticated) {
      scannedBy = authState.user.name;
      schoolId = authState.user.schoolId;
    }

    context.read<AttendanceQrBloc>().add(
          MarkAttendanceEvent(
            studentUniqueId: student.id,
            studentName: student.name,
            className: student.className,
            status: status,
            scannedBy: scannedBy,
            schoolId: schoolId,
            module: module,
          ),
        );
  }
}

class _StudentProfileHeader extends StatelessWidget {
  final Student student;

  const _StudentProfileHeader({required this.student});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: student.photoUrl != null ? NetworkImage(student.photoUrl!) : null,
          child: student.photoUrl == null ? const Icon(Icons.person, size: 60) : null,
        ),
        const SizedBox(height: 16),
        Text(
          student.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          'Class: ${student.className}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
        ),
        Text(
          'ID: ${student.studentId}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const _StatusButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
