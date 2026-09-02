import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

import '../../data/services/support_access_service.dart';
import '../../domain/entities/school.dart';
import '../../domain/repositories/super_admin_repository.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import 'school_admin_management_screen.dart';
import 'school_detail_screen.dart' show confirmSchoolStatusChange;

/// Screen D - School admins, support session, and administrative actions.
/// Admin list is real (SuperAdminRepository.getSchoolAdmins - a users query,
/// see repository for details). Support session is real too, backed by the
/// new `requestSupportAccess` callable and `institutions/{id}/
/// support_access_requests` (see SupportAccessService) rather than the
/// retired owner-impersonation flow. This screen intentionally offers no
/// hard-delete lifecycle action - archiving is the platform's only
/// irreversible-feeling but actually-reversible option; permanent removal
/// is out of scope per product policy.
class SchoolAdminActionsScreen extends StatefulWidget {
  const SchoolAdminActionsScreen({super.key, required this.school});
  final School school;

  @override
  State<SchoolAdminActionsScreen> createState() =>
      _SchoolAdminActionsScreenState();
}

class _SchoolAdminActionsScreenState extends State<SchoolAdminActionsScreen> {
  final SupportAccessService _supportAccessService = SupportAccessService();

  bool _loadingAdmins = true;
  String? _adminsError;
  List<SchoolAdminSummary> _admins = const [];

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    setState(() {
      _loadingAdmins = true;
      _adminsError = null;
    });
    try {
      final repository = context.read<SuperAdminBloc>().repository;
      final admins = await repository.getSchoolAdmins(widget.school.id);
      if (!mounted) return;
      setState(() {
        _admins = admins;
        _loadingAdmins = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingAdmins = false;
        _adminsError = error
            .toString()
            .replaceFirst(RegExp(r'^\w+Error:\s*'), '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final school = widget.school;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: Text(school.name, overflow: TextOverflow.ellipsis)),
      body: RefreshIndicator(
        onRefresh: _loadAdmins,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdminsSection(context),
              const SizedBox(height: AppSpacing.l),
              _SupportSessionCard(
                school: school,
                service: _supportAccessService,
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Administrative actions',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'These actions affect all staff and user access.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              _buildLifecycleActions(context, school),
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 14,
                    color: AppColors.textMuted(context),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    'Every administrative action is logged.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted(context),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminsSection(BuildContext context) {
    if (_loadingAdmins) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(child: SchoolPulseLoader()),
      );
    }
    if (_adminsError != null) {
      return AppCard(
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.danger(context)),
            const SizedBox(width: AppSpacing.l),
            Expanded(child: Text(_adminsError!)),
            TextButton(onPressed: _loadAdmins, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_admins.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            Icon(
              Icons.person_off_outlined,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Text(
                'No school admin accounts found for this school.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final primary = _admins.firstWhere(
      (a) => a.isPrimary,
      orElse: () => _admins.first,
    );
    final others = _admins.where((a) => a.uid != primary.uid).toList();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'School admins',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                '${_admins.length} admin${_admins.length == 1 ? '' : 's'}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary(
                  context,
                ).withValues(alpha: .14),
                child: Text(
                  _initials(primary.name),
                  style: TextStyle(
                    color: AppColors.primary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            primary.name,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (primary.isPrimary)
                          StatusBadge(
                            label: 'Primary',
                            color: AppColors.primary(context),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'School Admin • ${primary.mfaEnabled ? '2FA active' : '2FA not set up'}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    if (primary.lastSignInAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Last sign in ${DateFormat('MMM d, yyyy, h:mm a').format(primary.lastSignInAt!)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (others.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            SizedBox(
              height: 32,
              child: Stack(
                children: [
                  for (var i = 0; i < others.length.clamp(0, 4); i++)
                    Positioned(
                      left: i * 24.0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.surfaceElevated(context),
                        child: Text(
                          _initials(others[i].name),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ),
                  if (others.length > 4)
                    Positioned(
                      left: 4 * 24.0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.surfaceElevated(context),
                        child: Text(
                          '+${others.length - 4}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<SuperAdminBloc>(),
                    child: SchoolAdminManagementScreen(school: widget.school),
                  ),
                ),
              ).then((_) => _loadAdmins()),
              icon: const Icon(Icons.group_outlined, size: 18),
              label: const Text('Manage admins'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifecycleActions(BuildContext context, School school) {
    return Column(
      children: [
        if (school.status == SchoolStatus.active)
          _ActionTile(
            icon: Icons.pause_circle_outline_rounded,
            title: 'Suspend school',
            subtitle: 'Temporarily restrict all access',
            color: AppColors.danger(context),
            onTap: () => confirmSchoolStatusChange(
              context,
              action: 'Suspend',
              message:
                  'Are you sure you want to suspend ${school.name}? Staff '
                  'and admins will immediately lose access. Data remains '
                  'retained and you can reactivate at any time. This '
                  'action will be logged.',
              color: AppColors.danger(context),
              onConfirm: () => context.read<SuperAdminBloc>().add(
                UpdateSchoolStatusEvent(
                  schoolId: school.id,
                  status: SchoolStatus.suspended,
                  reason: 'Suspended by Owner',
                ),
              ),
            ),
          )
        else if (school.status == SchoolStatus.suspended)
          _ActionTile(
            icon: Icons.play_circle_outline_rounded,
            title: 'Reactivate school',
            subtitle: 'Restore access for staff and admins',
            color: AppColors.success(context),
            onTap: () => confirmSchoolStatusChange(
              context,
              action: 'Reactivate',
              message:
                  'Are you sure you want to reactivate ${school.name}? '
                  'Staff and admins will regain access immediately. This '
                  'action will be logged.',
              color: AppColors.success(context),
              onConfirm: () => context.read<SuperAdminBloc>().add(
                UpdateSchoolStatusEvent(
                  schoolId: school.id,
                  status: SchoolStatus.active,
                ),
              ),
            ),
          ),
        if (school.status != SchoolStatus.archived) ...[
          const SizedBox(height: AppSpacing.s),
          _ActionTile(
            icon: Icons.inventory_2_outlined,
            title: 'Archive school',
            subtitle: 'Retain data, remove from active schools',
            color: AppColors.textSecondary(context),
            onTap: () => _confirmArchive(context, school),
          ),
        ],
      ],
    );
  }

  void _confirmArchive(BuildContext context, School school) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.inventory_2_outlined),
        title: const Text('Archive school?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Archiving ${school.name} removes it from the active schools '
              'list and blocks staff/admin access. Data stays retained and '
              'the school can be reactivated at any time. This action is '
              'logged.',
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: reasonController,
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'e.g. School closed, moved to another provider',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.length < 3) return;
              context.read<SuperAdminBloc>().add(
                UpdateSchoolStatusEvent(
                  schoolId: school.id,
                  status: SchoolStatus.archived,
                  reason: reason,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0]).join().toUpperCase();
  }
}

class _SupportSessionCard extends StatefulWidget {
  const _SupportSessionCard({required this.school, required this.service});
  final School school;
  final SupportAccessService service;

  @override
  State<_SupportSessionCard> createState() => _SupportSessionCardState();
}

class _SupportSessionCardState extends State<_SupportSessionCard> {
  bool _requesting = false;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_agent, color: AppColors.primary(context)),
              const SizedBox(width: AppSpacing.s),
              Text(
                'Support session',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Requesting access opens a 30-minute, fully audited support '
            'session for this school. Every request, approval and exit is '
            'logged.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          StreamBuilder<List<SupportAccessRequest>>(
            stream: widget.service.watchRequests(widget.school.id),
            builder: (context, snapshot) {
              final active = (snapshot.data ?? const [])
                  .where((r) => r.isActive || r.status == 'pending')
                  .toList();
              if (active.isNotEmpty) {
                final current = active.first;
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.s),
                  decoration: BoxDecoration(
                    color: AppColors.warningSurface(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.hourglass_top_rounded,
                        size: 16,
                        color: AppColors.warning(context),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: Text(
                          current.status == 'pending'
                              ? 'A support session is awaiting approval.'
                              : 'A support session is active until '
                                    '${current.expiresAt != null ? DateFormat('h:mm a').format(current.expiresAt!) : 'expiry'}.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _requesting
                      ? null
                      : () => _confirmOpenSession(context),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: Text(
                    _requesting ? 'Requesting…' : 'Open support session',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmOpenSession(BuildContext context) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.support_agent),
        title: const Text('Open support session?'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This requests time-boxed support access to '
                '${widget.school.name} for 30 minutes. Every entry and exit '
                'is audited.',
              ),
              const SizedBox(height: AppSpacing.m),
              TextFormField(
                controller: reasonController,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                maxLength: 300,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  hintText: 'e.g. Debugging a reported attendance issue',
                ),
                validator: (value) => (value == null || value.trim().length < 3)
                    ? 'Please enter a reason (min 3 characters)'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() != true) return;
              Navigator.pop(dialogContext);
              setState(() => _requesting = true);
              try {
                await widget.service.request(
                  schoolId: widget.school.id,
                  reason: reasonController.text.trim(),
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceFirst(RegExp(r'^\w+Error:\s*'), ''),
                      ),
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _requesting = false);
              }
            },
            child: const Text('Request access'),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: color.withValues(alpha: .35),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: color),
        ],
      ),
    );
  }
}
