import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_access_context.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_category.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_record.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_scope.dart';
import 'package:school_pulse/features/attendance_hub/domain/repositories/attendance_repository.dart';
import 'package:school_pulse/features/attendance_hub/domain/repositories/sheets_integration_repository.dart';
import 'package:school_pulse/features/attendance_hub/domain/services/attendance_participant_resolver.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;

class AttendanceMethodScreen extends StatefulWidget {
  const AttendanceMethodScreen({super.key});

  @override
  State<AttendanceMethodScreen> createState() => _AttendanceMethodScreenState();
}

// category.label ('Meals/Food', etc.) already matches the bottom-sheet copy
// this screen used before the dropdown became resolver-driven, so labels
// are read straight from AttendanceCategory rather than re-declared here.
const Map<AttendanceCategory, String> _kCategoryLabels = {
  AttendanceCategory.students: 'Students',
  AttendanceCategory.staff: 'Staff',
  AttendanceCategory.gate: 'Gate',
  AttendanceCategory.meals: 'Meals/Food',
  AttendanceCategory.library: 'Library',
  AttendanceCategory.transport: 'Transport',
  AttendanceCategory.visitors: 'Visitors',
  AttendanceCategory.hostel: 'Hostel',
  AttendanceCategory.custom: 'Custom',
};

class _AttendanceMethodScreenState extends State<AttendanceMethodScreen> {
  AttendanceCategory? _selectedCategory;
  bool _sheetsLinked = false;
  bool _loadingAccess = true;
  AttendanceAccessContext? _access;

  bool _loadingSummary = false;
  int? _totalCount;
  int _presentCount = 0;
  int _absentCount = 0;
  int _lateCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAccess();
    _loadSheetsStatus();
  }

  // Resolves what this operator may actually do before the dropdown shows
  // anything, per the spec's "Attendance For must not always contain every
  // domain - dynamically show only domains the current user is authorized
  // to manage." An empty result is a real state (no responsibility
  // assigned), not an error - handled in _buildBody, never a silent
  // fallback to every category.
  Future<void> _loadAccess() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      setState(() => _loadingAccess = false);
      return;
    }
    final result = await di.sl<AttendanceParticipantResolver>().resolve(
      authState.user,
    );
    if (!mounted) return;
    setState(() {
      _access = result.fold((_) => null, (access) => access);
      _loadingAccess = false;
      final domains = _access?.allowedDomains ?? const {};
      // Auto-select when exactly one domain is authorised, per spec step 6
      // ("Auto-select if only one option exists").
      if (domains.length == 1) {
        _selectedCategory = domains.first;
      } else if (domains.contains(AttendanceCategory.students)) {
        _selectedCategory = AttendanceCategory.students;
      } else if (domains.isNotEmpty) {
        _selectedCategory = domains.first;
      }
    });
    _loadSummary();
  }

  // Total = roster size across every scope this operator can see for the
  // selected category; Present/Absent/Late are tallied from today's marks,
  // per AttendanceRecord.status. Both draw on the same access-scoped repo
  // calls the rest of this screen already uses, so a Class Teacher only
  // ever sees their own class's numbers, never the whole school's.
  Future<void> _loadSummary() async {
    final category = _selectedCategory;
    final access = _access;
    final authState = context.read<AuthBloc>().state;
    if (category == null || access == null || authState is! AuthAuthenticated) {
      return;
    }
    setState(() => _loadingSummary = true);

    final repo = di.sl<AttendanceRepository>();
    final schoolId = authState.user.schoolId;

    final scopesResult = await repo.getScopes(schoolId, category, access);
    final scopes = scopesResult.fold((_) => <AttendanceScope>[], (s) => s);

    var total = 0;
    for (final scope in scopes) {
      final rosterResult = await repo.getRoster(
        schoolId,
        category,
        scope.id,
        access,
      );
      total += rosterResult.fold((_) => 0, (roster) => roster.length);
    }

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));
    final recordsResult = await repo.getRecords(
      schoolId: schoolId,
      access: access,
      category: category,
      from: startOfToday,
      to: endOfToday,
    );
    final records = recordsResult.fold((_) => <AttendanceRecord>[], (r) => r);

    if (!mounted) return;
    setState(() {
      _totalCount = total;
      _presentCount = records
          .where((r) => r.status == AttendanceStatus.present)
          .length;
      _absentCount = records
          .where((r) => r.status == AttendanceStatus.absent)
          .length;
      _lateCount = records
          .where((r) => r.status == AttendanceStatus.late)
          .length;
      _loadingSummary = false;
    });
  }

  Future<void> _loadSheetsStatus() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final result = await di.sl<SheetsIntegrationRepository>().getIntegration(
      authState.user.schoolId,
    );
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _sheetsLinked = false),
      (integration) => setState(() => _sheetsLinked = integration.linked),
    );
  }

  void _showTypeSelector() {
    final domains = _access?.allowedDomains.toList() ?? const [];
    if (domains.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: domains.length,
            itemBuilder: (context, index) {
              final category = domains[index];
              return ListTile(
                title: Text(
                  _kCategoryLabels[category] ?? category.label,
                  style: TextStyle(color: AppColors.textPrimary(context)),
                ),
                trailing: _selectedCategory == category
                    ? Icon(Icons.check, color: AppColors.primary(context))
                    : null,
                onTap: () {
                  setState(() => _selectedCategory = category);
                  Navigator.pop(context);
                  _loadSummary();
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary(context),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Attendance',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w900,
                fontSize: 26,
                letterSpacing: -0.6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => context.push('/staff/attendance/history'),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final total = _totalCount;
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Overview",
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.primary(context),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('d MMM yyyy').format(DateTime.now()),
                    style: TextStyle(
                      color: AppColors.primary(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loadingSummary && total == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SchoolPulseLoader(size: 24),
              ),
            )
          else
            Row(
              children: [
                _StatColumn(
                  icon: Icons.groups_rounded,
                  color: Colors.black,
                  value: total ?? 0,
                  label: 'Total Students',
                ),
                _StatColumn(
                  icon: Icons.check_circle_rounded,
                  color: Colors.black,
                  value: _presentCount,
                  label: 'Present',
                ),
                _StatColumn(
                  icon: Icons.cancel_rounded,
                  color: Colors.black,
                  value: _absentCount,
                  label: 'Absent',
                ),
                _StatColumn(
                  icon: Icons.access_time_filled_rounded,
                  color: Colors.black,
                  value: _lateCount,
                  label: 'Late',
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loadingAccess) {
      return Column(
        children: [
          _buildHeader(context),
          const Expanded(child: Center(child: SchoolPulseLoader())),
        ],
      );
    }

    final domains = _access?.allowedDomains ?? const {};
    if (domains.isEmpty) {
      // Per spec: an operator with no active attendance responsibility must
      // never fall back to seeing every category - show the empty state and
      // stop, rather than rendering method cards with nothing to scope them.
      return Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      color: AppColors.textMuted(context),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No attendance group has been assigned to your account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contact your Institution Administrator.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final selectedLabel = _selectedCategory != null
        ? (_kCategoryLabels[_selectedCategory!] ?? _selectedCategory!.label)
        : '';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown Section Card - only shown when there's an actual
                // choice to make (multiple authorised domains); a single-domain
                // operator was already auto-selected in _loadAccess.
                if (domains.length > 1)
                  InkWell(
                    onTap: _showTypeSelector,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border(context)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary(context),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.people_alt_rounded,
                              color: AppColors.primary(context),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Attendance for',
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // The Dropdown Button UI
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.border(context),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedLabel,
                                  style: TextStyle(
                                    color: AppColors.textPrimary(context),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textMuted(context),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                // NFC Card
                _MethodCard(
                  title: 'NFC Scan',
                  subtitle: 'Mark attendance using NFC card',
                  accentColor: Colors.black,
                  icon: Icons.sensors_rounded,
                  badgeIcon: Icons.shield_rounded,
                  badgeLabel: 'Fast & Secure',
                  onTap: () => context.push('/staff/attendance/nfc'),
                ),

                // QR Code Card
                _MethodCard(
                  title: 'QR Code Scanner',
                  subtitle: 'Scan student QR code',
                  accentColor: Colors.black,
                  icon: Icons.qr_code_2_rounded,
                  badgeIcon: Icons.shield_rounded,
                  badgeLabel: 'Quick & Easy',
                  onTap: () => context.push('/staff/attendance/qr'),
                ),

                // Manual Card
                _MethodCard(
                  title: 'Manual Attendance',
                  subtitle: 'Mark attendance manually',
                  accentColor: Colors.black,
                  icon: Icons.assignment_turned_in_rounded,
                  badgeIcon: Icons.shield_rounded,
                  badgeLabel: 'Full Control',
                  // A Class Teacher's manual attendance is their own daily class
                  // register (TeacherAttendanceScreen/ClassAttendanceBloc), not the
                  // generic multi-category manual screen this hub otherwise opens -
                  // matrons, patrons and admins have no such register, so the
                  // detour is scoped to only when that responsibility is active.
                  onTap: () {
                    final classActive = context
                        .read<ClassTeacherContextBloc>()
                        .state
                        .active;
                    if (classActive != null) {
                      context.push('/staff/roll-call');
                      return;
                    }
                    context.push(
                      '/staff/attendance/manual',
                      extra: _selectedCategory,
                    );
                  },
                ),

                // History Card
                _MethodCard(
                  title: 'Previous Attendances',
                  subtitle: 'View and manage past records',
                  accentColor: Colors.black,
                  icon: Icons.history_rounded,
                  badgeIcon: Icons.bar_chart_rounded,
                  badgeLabel: 'History & Reports',
                  // Mirrors the Manual Attendance card above: a Class Teacher's
                  // history is their own class register's
                  // (TeacherAttendanceHistoryScreen/ClassAttendanceHistoryBloc),
                  // not the generic multi-category history this hub otherwise opens.
                  onTap: () {
                    final classActive = context
                        .read<ClassTeacherContextBloc>()
                        .state
                        .active;
                    if (classActive != null) {
                      context.push('/staff/roll-call/history');
                      return;
                    }
                    context.push('/staff/attendance/history');
                  },
                ),

                // Google Sheets Card
                _IntegrationCard(
                  title: 'Google Sheets',
                  subtitle: 'Sync attendance to Google Sheets',
                  linked: _sheetsLinked,
                  badgeIcon: Icons.cloud_rounded,
                  badgeLabel: 'Sync & Export',
                  onTap: () async {
                    await context.push('/staff/attendance/sheets');
                    _loadSheetsStatus();
                  },
                ),

                const SizedBox(height: 8),
                _buildSummaryCard(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.5),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final IconData badgeIcon;
  final String badgeLabel;
  final VoidCallback onTap;

  const _MethodCard({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.badgeIcon,
    required this.badgeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor,
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontWeight: FontWeight.w400,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _Badge(
                    icon: badgeIcon,
                    label: badgeLabel,
                    color: accentColor,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted(context),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _IntegrationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool linked;
  final IconData badgeIcon;
  final String badgeLabel;
  final VoidCallback onTap;

  const _IntegrationCard({
    required this.title,
    required this.subtitle,
    required this.linked,
    required this.badgeIcon,
    required this.badgeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = AppColors.textMuted(context);
    final Color statusColor = linked
        ? Colors.black
        : AppColors.textMuted(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor,
              ),
              child: Icon(
                Icons.description_rounded,
                color: iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontWeight: FontWeight.w400,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _Badge(
                    icon: badgeIcon,
                    label: badgeLabel,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            Icon(
              linked ? Icons.link_rounded : Icons.link_off_rounded,
              color: statusColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted(context),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
