import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/core/error/friendly_error_message.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/super_admin/data/services/portal_subdomain_change_service.dart';

/// School Admin-facing screen: shows this school's current
/// `<slug>.schoolpulseapp.com` subdomain and lets the admin request a
/// change. A change is not applied immediately - it goes to the SaaS Owner's
/// Subdomain Change Requests console for review (see
/// `super_admin/presentation/pages/subdomain_change_requests_screen.dart`),
/// same as a custom-domain request needs owner activation.
class SchoolSubdomainScreen extends StatefulWidget {
  const SchoolSubdomainScreen({super.key, this.service});

  final PortalSubdomainChangeService? service;

  @override
  State<SchoolSubdomainScreen> createState() => _SchoolSubdomainScreenState();
}

class _SchoolSubdomainScreenState extends State<SchoolSubdomainScreen> {
  late final PortalSubdomainChangeService _service =
      widget.service ?? PortalSubdomainChangeService();
  final _controller = TextEditingController();
  bool _busy = false;
  bool? _available;
  String? _availabilityChecked;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _friendlyError(Object error) {
    final value = error.toString();
    if (value.contains('already-exists')) {
      return 'That subdomain is already in use.';
    }
    if (value.contains('invalid-argument')) {
      return 'Enter a valid subdomain (lowercase letters, numbers, hyphens).';
    }
    return friendlyErrorMessage(error);
  }

  Future<void> _checkAvailability(String slug) async {
    if (slug.trim().isEmpty) {
      setState(() {
        _available = null;
        _availabilityChecked = null;
      });
      return;
    }
    try {
      final available = await _service.checkAvailability(slug);
      if (!mounted) return;
      setState(() {
        _available = available;
        _availabilityChecked = slug.trim().toLowerCase();
      });
    } catch (_) {
      // Availability is a convenience preview only - a failed check doesn't
      // block submission, the callable re-validates server-side anyway.
    }
  }

  Future<void> _submit(String schoolId) async {
    final slug = _controller.text.trim().toLowerCase();
    if (slug.isEmpty) return;
    setState(() => _busy = true);
    try {
      await _service.requestChange(slug);
      if (mounted) {
        _controller.clear();
        setState(() {
          _available = null;
          _availabilityChecked = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Request sent. School Pulse will review it shortly.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(error)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Subdomain'),
        leading: const BackButton(),
      ),
      body: schoolId.isEmpty
          ? const Center(child: Text('No school context found.'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .doc('schools/$schoolId')
                  .snapshots(),
              builder: (context, schoolSnap) {
                if (!schoolSnap.hasData) {
                  return const Center(child: SchoolPulseLoader());
                }
                final currentSlug =
                    schoolSnap.data?.data()?['slug']?.toString();
                return StreamBuilder<PortalSubdomainChangeRequest?>(
                  stream: _service.watchForSchool(schoolId),
                  builder: (context, reqSnap) {
                    final pending = reqSnap.data;
                    return ListView(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      children: [
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current subdomain',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary(context),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                currentSlug == null
                                    ? '—'
                                    : '$currentSlug.schoolpulseapp.com',
                                style: AppTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.l),
                        if (pending != null && pending.isPending)
                          AppCard(
                            color: AppColors.warning(
                              context,
                            ).withValues(alpha: 0.12),
                            showBorder: true,
                            borderColor: AppColors.warning(context),
                            showShadow: false,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.hourglass_top_rounded,
                                  color: AppColors.warning(context),
                                ),
                                const SizedBox(width: AppSpacing.m),
                                Expanded(
                                  child: Text(
                                    'Request pending review: '
                                    '${pending.requestedSlug}.schoolpulseapp.com',
                                    style: TextStyle(
                                      color: AppColors.textPrimary(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          if (pending != null && pending.isRejected)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.m,
                              ),
                              child: AppCard(
                                color: AppColors.danger(
                                  context,
                                ).withValues(alpha: 0.12),
                                showBorder: true,
                                borderColor: AppColors.danger(context),
                                showShadow: false,
                                child: Text(
                                  'Your last request '
                                  '(${pending.requestedSlug}.schoolpulseapp.com) '
                                  'was rejected'
                                  '${pending.rejectionReason != null ? ': ${pending.rejectionReason}' : '.'}',
                                  style: TextStyle(
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                              ),
                            ),
                          Text(
                            'Request a new subdomain',
                            style: AppTypography.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            'Changing your subdomain requires School Pulse '
                            'review before it goes live.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          TextField(
                            controller: _controller,
                            enabled: !_busy,
                            decoration: InputDecoration(
                              labelText: 'Desired subdomain',
                              suffixText: '.schoolpulseapp.com',
                              border: const OutlineInputBorder(),
                              helperText: _available == null
                                  ? null
                                  : _available == true
                                  ? 'Available'
                                  : 'Not available',
                              helperStyle: TextStyle(
                                color: _available == true
                                    ? AppColors.success(context)
                                    : AppColors.danger(context),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _available = null;
                                _availabilityChecked = null;
                              });
                              _checkAvailability(value);
                            },
                          ),
                          const SizedBox(height: AppSpacing.l),
                          FilledButton(
                            onPressed:
                                _busy ||
                                    _controller.text.trim().isEmpty ||
                                    (_available == false &&
                                        _availabilityChecked ==
                                            _controller.text
                                                .trim()
                                                .toLowerCase())
                                ? null
                                : () => _submit(schoolId),
                            child: _busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Submit request'),
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}
