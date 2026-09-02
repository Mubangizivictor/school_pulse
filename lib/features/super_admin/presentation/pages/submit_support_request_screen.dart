import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

import '../../data/services/support_ticket_service.dart';
import '../../domain/entities/support_ticket.dart';
import '../widgets/super_admin_unsaved_changes_guard.dart';

/// Which entry point launched the form - "Report a Problem" and
/// "Submit a Request" share this exact same underlying form/flow. Product
/// call: both are honestly the same shape (subject, description, priority)
/// and both create the same kind of ticket record; only the origin tag and
/// the on-screen copy differ; see build report.
class SubmitSupportRequestArgs {
  final String origin;
  const SubmitSupportRequestArgs({required this.origin});
}

class SubmitSupportRequestScreen extends StatefulWidget {
  const SubmitSupportRequestScreen({super.key, required this.args});

  final SubmitSupportRequestArgs args;

  @override
  State<SubmitSupportRequestScreen> createState() =>
      _SubmitSupportRequestScreenState();
}

class _SubmitSupportRequestScreenState
    extends State<SubmitSupportRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  SupportTicketPriority _priority = SupportTicketPriority.medium;
  final _service = SupportTicketService();
  bool _submitting = false;
  bool _dirty = false;
  String? _error;

  bool get _isReportProblem => widget.args.origin == 'report_problem';

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _subjectController.addListener(_markDirty);
    _descriptionController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_dirty && mounted) setState(() => _dirty = true);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final ticketId = await _service.createTicket(
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        origin: widget.args.origin,
      );
      if (!mounted) return;
      setState(() => _dirty = false);
      context.pushReplacement('/super-admin/settings/support/ticket/$ticketId');
    } catch (e) {
      setState(() {
        _error = 'Could not submit this ticket. Please try again.\n$e';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SuperAdminUnsavedChangesGuard(
      hasUnsavedChanges: _dirty && !_submitting,
      message: 'Your support request has not been submitted.',
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: Text(
            _isReportProblem ? 'Report a Problem' : 'Submit a Request',
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                Text(
                  _isReportProblem
                      ? 'Describe what went wrong so support can investigate.'
                      : 'Describe the feature or change you\'d like to see.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Subject',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                TextFormField(
                  controller: _subjectController,
                  maxLength: 120,
                  decoration: const InputDecoration(
                    hintText: 'Short summary',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Subject is required'
                      : null,
                ),
                const SizedBox(height: AppSpacing.l),
                Text(
                  'Description',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 5,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText:
                        'Steps to reproduce, what you expected, or full request details',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Description is required'
                      : null,
                ),
                const SizedBox(height: AppSpacing.l),
                Text(
                  'Priority',
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                SegmentedButton<SupportTicketPriority>(
                  segments: const [
                    ButtonSegment(
                      value: SupportTicketPriority.low,
                      label: Text('Low'),
                    ),
                    ButtonSegment(
                      value: SupportTicketPriority.medium,
                      label: Text('Medium'),
                    ),
                    ButtonSegment(
                      value: SupportTicketPriority.high,
                      label: Text('High'),
                    ),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (selection) =>
                      setState(() => _priority = selection.first),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    _error!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.danger(context),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.x2l),
                PrimaryButton(
                  label: 'Submit',
                  isLoading: _submitting,
                  onPressed: _submitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
