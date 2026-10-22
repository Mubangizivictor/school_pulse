import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/shared/boarding/boarding_list_widgets.dart';

/// Plain, role-agnostic roster row - deliberately not the Patron/Matron
/// `BoardingStudent` entity, so this file never imports either role's
/// domain layer. `attendanceStatus` is null when no attendance record
/// exists yet for today's chosen session, rendered as "Present" (Roll
/// Call defaults new records to Present) - see `_tabMatches` for detail.
class RosterStudent {
  final String id;
  final String name;
  final String? photoUrl;
  final String? bedLabel;
  final String? classLabel;
  final String? attendanceStatus; // 'present' | 'absent' | 'late' | 'leave'

  const RosterStudent({
    required this.id,
    required this.name,
    this.photoUrl,
    this.bedLabel,
    this.classLabel,
    this.attendanceStatus,
  });
}

const _kRosterTabs = ['All', 'Present', 'Absent', 'Late', 'On Leave'];

/// Shared dormitory student roster - lists every boarder allocated to one
/// dormitory with tabs to filter by today's attendance status. Identical
/// for Patron (boys) and Matron (girls); the per-role wrapper supplies live
/// data + a tap callback so no PatronBloc/MatronBloc reference belongs here.
class DormStudentRosterScreen extends StatelessWidget {
  final String dormitoryName;
  final List<RosterStudent> students;
  final bool isLoading;
  final ValueChanged<String> onStudentTap;

  const DormStudentRosterScreen({
    super.key,
    required this.dormitoryName,
    required this.students,
    required this.isLoading,
    required this.onStudentTap,
  });

  bool _tabMatches(int tabIndex, RosterStudent student) {
    if (tabIndex == 0) return true;
    // Default to 'present' when no record exists yet for today, matching
    // how Roll Call treats an unmarked boarder.
    final status = (student.attendanceStatus ?? 'present').toLowerCase();
    return switch (tabIndex) {
      1 => status == 'present',
      2 => status == 'absent',
      3 => status == 'late',
      4 => status == 'leave',
      _ => true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(dormitoryName)),
      body: isLoading
          ? const Center(child: Skeleton(height: 220, borderRadius: 16))
          : TabbedListScaffold<RosterStudent>(
              tabLabels: _kRosterTabs,
              items: students,
              filter: _tabMatches,
              emptyIcon: Icons.people_outline,
              emptyTitle: 'No Boarders',
              emptyMessage: 'No boarders match this filter.',
              itemBuilder: (context, student) => AppCard(
                margin: const EdgeInsets.only(bottom: AppSpacing.s),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: StudentListRow(
                  name: student.name,
                  photoUrl: student.photoUrl,
                  bedLabel: student.bedLabel,
                  classLabel: student.classLabel,
                  onTap: () => onStudentTap(student.id),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                ),
              ),
            ),
    );
  }
}
