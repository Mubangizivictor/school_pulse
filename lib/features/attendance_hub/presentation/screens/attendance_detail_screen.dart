import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import '../../domain/entities/attendance_record.dart';

class AttendanceDetailScreen extends StatelessWidget {
  final List<AttendanceRecord> records;
  final String title;

  const AttendanceDetailScreen({
    super.key,
    required this.records,
    required this.title,
  });

  String _statusLabel(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }

  Color _statusColor(BuildContext context, AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.success(context);
      case AttendanceStatus.absent:
        return AppColors.danger(context);
      case AttendanceStatus.late:
        return AppColors.warning(context);
      case AttendanceStatus.excused:
        return AppColors.information(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = records.length;
    final present = records
        .where((r) => r.status == AttendanceStatus.present)
        .length;
    final absent = records
        .where((r) => r.status == AttendanceStatus.absent)
        .length;
    final late = records.where((r) => r.status == AttendanceStatus.late).length;
    final first = records.isNotEmpty ? records.first : null;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  children: [
                    if (first != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.m),
                        child: Text(
                          '${first.date.day}/${first.date.month}/${first.date.year}',
                          style: TextStyle(color: AppColors.textMuted(context)),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatChip(label: 'Total', value: '$total'),
                        _StatChip(
                          label: 'Present',
                          value: '$present',
                          color: AppColors.success(context),
                        ),
                        _StatChip(
                          label: 'Absent',
                          value: '$absent',
                          color: AppColors.danger(context),
                        ),
                        _StatChip(
                          label: 'Late',
                          value: '$late',
                          color: AppColors.warning(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.s),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(r.personName),
                    trailing: Text(
                      _statusLabel(r.status),
                      style: TextStyle(
                        color: _statusColor(context, r.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.ios_share),
                    label: const Text('Export'),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatChip({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: color ?? AppColors.textPrimary(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
        ),
      ],
    );
  }
}
