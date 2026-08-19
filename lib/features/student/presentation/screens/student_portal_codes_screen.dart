import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';

import '../../domain/entities/student.dart';
import '../../domain/entities/student_access_code.dart';
import '../bloc/student_portal_access_cubit.dart';
import '../bloc/student_portal_access_state.dart';

class StudentPortalCodesScreen extends StatefulWidget {
  final Student student;

  const StudentPortalCodesScreen({super.key, required this.student});

  @override
  State<StudentPortalCodesScreen> createState() =>
      _StudentPortalCodesScreenState();
}

class _StudentPortalCodesScreenState extends State<StudentPortalCodesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentPortalAccessCubit>().load(widget.student.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Portal Codes')),
      body: BlocConsumer<StudentPortalAccessCubit, StudentPortalAccessState>(
        listener: (context, state) {
          if (state is StudentPortalAccessActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is StudentPortalAccessError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is StudentPortalAccessLoading ||
              state is StudentPortalAccessInitial) {
            return const Center(child: SchoolPulseLoader());
          }

          if (state is StudentPortalAccessError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48),
                    const SizedBox(height: 12),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context
                          .read<StudentPortalAccessCubit>()
                          .load(widget.student.id),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is StudentPortalAccessLoaded) {
            return ResponsiveBuilder(
              builder: (context, layout) {
                final isDesktop = layout == ResponsiveLayout.desktop;
                final header = _StudentHeader(student: widget.student);
                final body = state.accessCode == null
                    ? _EmptyState(studentId: widget.student.id)
                    : _AccessCodeDetails(
                        student: widget.student,
                        accessCode: state.accessCode!,
                      );

                if (isDesktop) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: header),
                            const SizedBox(width: 24),
                            Expanded(flex: 6, child: body),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [header, const SizedBox(height: 24), body],
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StudentHeader extends StatelessWidget {
  final Student student;

  const _StudentHeader({required this.student});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: student.photoUrl?.isNotEmpty == true
                  ? NetworkImage(student.photoUrl!)
                  : null,
              child: student.photoUrl?.isNotEmpty == true
                  ? null
                  : const Icon(Icons.person, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${student.studentId} · ${student.className}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String studentId;

  const _EmptyState({required this.studentId});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.vpn_key_off_outlined, size: 40, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            const Text(
              'Portal access not yet provisioned',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Generate an access code to let this student log into the Student Portal.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context
                  .read<StudentPortalAccessCubit>()
                  .generateAccessCode(studentId),
              icon: const Icon(Icons.add_moderator_outlined),
              label: const Text('Generate Access Code'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessCodeDetails extends StatelessWidget {
  final Student student;
  final StudentAccessCode accessCode;

  const _AccessCodeDetails({required this.student, required this.accessCode});

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: accessCode.code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Access code copied')));
  }

  Future<void> _confirmResetPin(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset PIN'),
        content: const Text(
          'This clears the current login PIN. The student will be asked to set a new PIN next time they log in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset PIN'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<StudentPortalAccessCubit>().resetPin(
      student.id,
      accessCode.code,
    );
  }

  Future<void> _toggleStatus(BuildContext context, bool nextActive) async {
    String? reason;
    if (!nextActive) {
      reason = await showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Reason for disabling access',
                    style: Theme.of(
                      sheetContext,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              for (final reason in const ['Lost device', 'Left school', 'Suspicious activity', 'Other'])
                ListTile(
                  title: Text(reason),
                  onTap: () => Navigator.pop(sheetContext, reason),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
      if (reason == null || !context.mounted) return;
    }
    if (!context.mounted) return;
    context.read<StudentPortalAccessCubit>().setStatus(
      student.id,
      accessCode.code,
      nextActive,
      reason: reason,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CodeCard(
          title: 'Portal Access Code',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      accessCode.code,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy',
                    icon: const Icon(Icons.copy_outlined),
                    onPressed: () => _copyCode(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context
                    .read<StudentPortalAccessCubit>()
                    .generateAccessCode(student.id),
                icon: const Icon(Icons.refresh),
                label: const Text('Generate New Code'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _CodeCard(
          title: 'Login PIN',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (var i = 0; i < 4; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.circle, size: 12, color: scheme.onSurfaceVariant),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'PINs are hashed server-side and never sent to the app - the value cannot be displayed.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _confirmResetPin(context),
                icon: const Icon(Icons.lock_reset),
                label: const Text('Reset PIN'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _CodeCard(
          title: 'Access Status',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(accessCode.isActive ? 'ACTIVE' : 'DISABLED'),
                    backgroundColor: (accessCode.isActive ? Colors.green : Colors.red)
                        .withValues(alpha: 0.12),
                    labelStyle: TextStyle(
                      color: accessCode.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: accessCode.isActive,
                    onChanged: (next) => _toggleStatus(context, next),
                  ),
                ],
              ),
              if (!accessCode.isActive && accessCode.deactivationReason != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Reason: ${accessCode.deactivationReason}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                accessCode.lastLoginAt != null
                    ? 'Last login: ${accessCode.lastLoginAt}'
                    : 'Last login: never',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CodeCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _CodeCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
