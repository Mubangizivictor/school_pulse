import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import '../../domain/entities/school.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../responsive.dart';

class SchoolDetailScreen extends StatefulWidget {
  final School school;

  const SchoolDetailScreen({super.key, required this.school});

  @override
  State<SchoolDetailScreen> createState() => _SchoolDetailScreenState();
}

class _SchoolDetailScreenState extends State<SchoolDetailScreen> {
  School get school => widget.school;

  final ManualPaymentService _paymentsService = ManualPaymentService();
  final NumberFormat _money = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );
  final DateFormat _paymentDate = DateFormat('MMM d, yyyy');

  bool _loadingPayments = true;
  String? _paymentsError;
  List<ManualSubscriptionPayment> _payments = const [];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _loadingPayments = true;
      _paymentsError = null;
    });
    try {
      final all = await _paymentsService.getPayments();
      final mine = all.where((p) => p.schoolId == school.id).toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      if (!mounted) return;
      setState(() {
        _payments = mine;
        _loadingPayments = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingPayments = false;
        _paymentsError = error.toString().replaceFirst(
          RegExp(r'^Exception:\s*'),
          '',
        );
      });
    }
  }

  int get _totalPaid => _payments
      .where((p) => p.status == ManualPaymentStatus.approved)
      .fold(0, (sum, p) => sum + p.submittedAmount);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final daysRemaining = school.subscriptionExpiry
        .difference(DateTime.now())
        .inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(school.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Edit school info',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editSchoolInfo(context, school),
          ),
          if (school.status == SchoolStatus.active)
            IconButton(
              tooltip: 'Suspend school',
              icon: Icon(Icons.block_rounded, color: theme.colorScheme.error),
              onPressed: () => _confirmStatusChange(
                context,
                action: 'Suspend',
                message:
                    'Are you sure you want to suspend ${school.name}? '
                    'Staff and admins will immediately lose access to the '
                    'dashboard. You can reactivate at any time. This action '
                    'will be logged.',
                color: theme.colorScheme.error,
                onConfirm: () => context.read<SuperAdminBloc>().add(
                  UpdateSchoolStatusEvent(
                    schoolId: school.id,
                    status: SchoolStatus.suspended,
                    reason: 'Suspended by Owner',
                  ),
                ),
              ),
            )
          else if (school.status == SchoolStatus.suspended ||
              school.status == SchoolStatus.archived)
            IconButton(
              tooltip: 'Reactivate school',
              icon: Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.success(context),
              ),
              onPressed: () => _confirmStatusChange(
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, theme),
            const SizedBox(height: AppSpacing.x4l),
            if (isSuperAdminWide(context))
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildOverview(theme, context)),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    child: _buildSubscription(
                      theme,
                      context,
                      dateFormat,
                      daysRemaining,
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverview(theme, context),
                  const SizedBox(height: AppSpacing.x4l),
                  _buildSubscription(theme, context, dateFormat, daysRemaining),
                ],
              ),
            const SizedBox(height: AppSpacing.x4l),
            _buildPayments(theme, context),
            const SizedBox(height: AppSpacing.x4l),
            _buildFeatureControl(theme, context),
            const SizedBox(height: AppSpacing.x4l),
            _buildSupportModeAction(theme, context),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary(context).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary(context)),
        ),
        const SizedBox(width: AppSpacing.m),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _iconChip(BuildContext context, IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _iconChip(context, icon, color),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return AppCard(
      color: AppColors.primary(context).withValues(alpha: 0.08),
      borderColor: AppColors.primary(context).withValues(alpha: 0.35),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary(context),
            child: Text(
              school.name.isEmpty
                  ? '?'
                  : school.name.substring(0, 1).toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  school.name,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tenant ID: ${school.tenantId} • Created ${DateFormat('MMM dd, yyyy').format(school.createdAt)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          _statusBadge(school.status, context),
        ],
      ),
    );
  }

  Widget _buildOverview(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, Icons.grid_view_rounded, 'Overview'),
        const SizedBox(height: AppSpacing.m),
        AppCard(
          child: Column(
            children: [
              _infoRow(
                context,
                icon: Icons.category_outlined,
                color: AppColors.primary(context),
                title: 'Category',
                subtitle: school.classificationOther?.isNotEmpty == true
                    ? school.classificationOther!
                    : school.classification.name,
              ),
              const Divider(height: 1),
              _infoRow(
                context,
                icon: Icons.email_outlined,
                color: AppColors.primary(context),
                title: 'Contact email',
                subtitle: school.contactEmail.isEmpty
                    ? '—'
                    : school.contactEmail,
              ),
              const Divider(height: 1),
              _infoRow(
                context,
                icon: Icons.phone_outlined,
                color: AppColors.primary(context),
                title: 'Contact phone',
                subtitle: school.contactPhone.isEmpty
                    ? '—'
                    : school.contactPhone,
              ),
              const Divider(height: 1),
              _infoRow(
                context,
                icon: Icons.location_on_outlined,
                color: AppColors.primary(context),
                title: 'Address',
                subtitle: school.address.isEmpty ? '—' : school.address,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscription(
    ThemeData theme,
    BuildContext context,
    DateFormat dateFormat,
    int daysRemaining,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          Icons.workspace_premium_rounded,
          'Subscription',
        ),
        const SizedBox(height: AppSpacing.m),
        AppCard(
          color: Colors.purple.withValues(alpha: 0.08),
          borderColor: Colors.purple.withValues(alpha: 0.25),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconChip(
                context,
                Icons.workspace_premium_rounded,
                Colors.purple,
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      school.subscriptionPlanId.isEmpty
                          ? 'No plan assigned'
                          : school.subscriptionPlanId.toUpperCase(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expires on ${dateFormat.format(school.subscriptionExpiry)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      daysRemaining >= 0
                          ? '$daysRemaining days remaining'
                          : 'Expired ${-daysRemaining} days ago',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: daysRemaining < 0
                            ? theme.colorScheme.error
                            : AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPayments(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, Icons.credit_card_rounded, 'Payments'),
        const SizedBox(height: AppSpacing.m),
        AppCard(
          child: Row(
            children: [
              _iconChip(
                context,
                Icons.camera_alt_rounded,
                AppColors.primary(context),
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total paid',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _loadingPayments ? '—' : _money.format(_totalPaid),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        if (_loadingPayments)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(child: SchoolPulseLoader()),
          )
        else if (_paymentsError != null)
          AppCard(
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.danger(context),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(child: Text(_paymentsError!)),
                TextButton(
                  onPressed: _loadPayments,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        else if (_payments.isEmpty)
          const EmptyState(
            icon: Icons.payments_outlined,
            title: 'No payments yet',
            message: 'No manual subscription payments from this school.',
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _payments.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final payment = _payments[index];
                return ListTile(
                  leading: _iconChip(
                    context,
                    payment.method == ManualPaymentMethod.mtn
                        ? Icons.phone_android_rounded
                        : Icons.account_balance_rounded,
                    AppColors.primary(context),
                  ),
                  title: Text(
                    '${_money.format(payment.submittedAmount)} • ${payment.planName}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  subtitle: Text(_paymentDate.format(payment.submittedAt)),
                  trailing: StatusBadge(
                    label: _paymentStatusLabel(payment.status),
                    color: _paymentStatusColor(context, payment.status),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  String _paymentStatusLabel(ManualPaymentStatus status) => switch (status) {
    ManualPaymentStatus.pendingVerification => 'Pending',
    ManualPaymentStatus.approved => 'Approved',
    ManualPaymentStatus.rejected => 'Rejected',
  };

  Color _paymentStatusColor(BuildContext context, ManualPaymentStatus status) =>
      switch (status) {
        ManualPaymentStatus.pendingVerification => AppColors.warning(context),
        ManualPaymentStatus.approved => AppColors.success(context),
        ManualPaymentStatus.rejected => AppColors.danger(context),
      };

  Widget _buildFeatureControl(ThemeData theme, BuildContext context) {
    final allFeatures = [
      {
        'id': 'attendance',
        'name': 'Attendance Management',
        'icon': Icons.calendar_today,
        'color': AppColors.electricBlue,
      },
      {
        'id': 'finance',
        'name': 'Financial Records',
        'icon': Icons.payments,
        'color': AppColors.successGreen,
      },
      {
        'id': 'exams',
        'name': 'Examination System',
        'icon': Icons.assignment,
        'color': Colors.purple,
      },
      {
        'id': 'transport',
        'name': 'Transport/Bus Tracking',
        'icon': Icons.directions_bus,
        'color': AppColors.brightOrange,
      },
      {
        'id': 'library',
        'name': 'Library Management',
        'icon': Icons.book,
        'color': AppColors.electricBlue,
      },
      {
        'id': 'qr_scanner',
        'name': 'QR Attendance Integration',
        'icon': Icons.qr_code,
        'color': Colors.purple,
      },
      {
        'id': 'parent_portal',
        'name': 'Parent Engagement',
        'icon': Icons.family_restroom,
        'color': AppColors.emeraldGreen,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(context, Icons.grid_view_rounded, 'Features & Modules'),
        const SizedBox(height: AppSpacing.m),
        AppCard(
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allFeatures.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final feature = allFeatures[index];
              final isEnabled = school.enabledFeatures.contains(feature['id']);
              return SwitchListTile(
                secondary: _iconChip(
                  context,
                  feature['icon'] as IconData,
                  feature['color'] as Color,
                ),
                title: Text(
                  feature['name'] as String,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                value: isEnabled,
                onChanged: (value) {
                  context.read<SuperAdminBloc>().add(
                    ToggleFeatureEvent(
                      schoolId: school.id,
                      feature: feature['id'] as String,
                      enabled: value,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSupportModeAction(ThemeData theme, BuildContext context) {
    return AppCard(
      color: AppColors.primary(context).withValues(alpha: 0.06),
      borderColor: AppColors.primary(context).withValues(alpha: 0.25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconChip(context, Icons.support_agent, AppColors.primary(context)),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Owner Support Mode',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sign in as this school\'s admin to help with a support '
                  'request. Every entry and exit is logged, and the session '
                  'expires automatically after 30 minutes. You will be '
                  'signed out of your owner session while active.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                OutlinedButton.icon(
                  onPressed: () => _enterSupportMode(context, school),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: const Text('Enter Support Mode'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _enterSupportMode(BuildContext context, School school) {
    final authBloc = context.read<AuthBloc>();
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.support_agent),
        title: const Text('Enter Support Mode?'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You will be signed in as ${school.name}\'s admin and '
                'signed out of your owner session. This action is logged '
                'and the session auto-expires after 30 minutes.',
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
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              authBloc.add(
                EnterSupportModeRequested(
                  schoolId: school.id,
                  reason: reasonController.text.trim(),
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Enter Support Mode'),
          ),
        ],
      ),
    );
  }

  void _editSchoolInfo(BuildContext context, School school) {
    final bloc = context.read<SuperAdminBloc>();
    final nameController = TextEditingController(text: school.name);
    final emailController = TextEditingController(text: school.contactEmail);
    final phoneController = TextEditingController(text: school.contactPhone);
    final addressController = TextEditingController(text: school.address);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit School Info'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'School name'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'School name is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Contact email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Contact phone',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              bloc.add(
                UpdateSchoolInfoEvent(
                  school.copyWith(
                    name: nameController.text.trim(),
                    contactEmail: emailController.text.trim(),
                    contactPhone: phoneController.text.trim(),
                    address: addressController.text.trim(),
                  ),
                ),
              );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('School info updated.')),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _confirmStatusChange(
    BuildContext context, {
    required String action,
    required Color color,
    required VoidCallback onConfirm,
    required String message,
  }) {
    confirmSchoolStatusChange(
      context,
      action: action,
      message: message,
      color: color,
      onConfirm: onConfirm,
    );
  }

  Widget _statusBadge(SchoolStatus status, BuildContext context) {
    final (label, color) = switch (status) {
      SchoolStatus.active => ('Active', AppColors.success(context)),
      SchoolStatus.suspended => ('Suspended', AppColors.danger(context)),
      SchoolStatus.trial => ('Trial', AppColors.warning(context)),
      SchoolStatus.archived => ('Archived', AppColors.textSecondary(context)),
    };
    return StatusBadge(label: label, color: color);
  }
}

/// Shared suspend/reactivate confirmation dialog. Reused by both
/// [SchoolDetailScreen]'s app bar actions and the Schools list's quick
/// actions so the wording and behavior stay in one place.
void confirmSchoolStatusChange(
  BuildContext context, {
  required String action,
  required String message,
  required Color color,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('$action School?'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: color),
          onPressed: () {
            onConfirm();
            Navigator.pop(dialogContext);
          },
          child: Text(action),
        ),
      ],
    ),
  );
}

/// Shared archive confirmation dialog — reused by [SchoolDetailScreen] and
/// the Schools list quick actions. Archiving reuses the same Firestore
/// write and access-lockout logic as suspending; it never deletes data.
/// Marks a school as deleted (Firestore-backed, via [SchoolStatus.archived]
/// under the hood). This intentionally stays reversible rather than being a
/// true destructive delete: a school's data likely spans many Firestore
/// collections that haven't been audited, so a naive hard-delete risks
/// orphaned data. Reactivating an archived school (from School Details)
/// undoes this.
void deleteSchoolDialog(BuildContext context, School school) {
  final bloc = context.read<SuperAdminBloc>();
  final reasonController = TextEditingController();
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(
        Icons.delete_outline_rounded,
        color: Theme.of(dialogContext).colorScheme.error,
      ),
      title: const Text('Delete School?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deleting ${school.name} immediately blocks all staff and '
            'admin access. This does NOT permanently erase any school '
            'data — it stays recoverable by reactivating the school from '
            'School Details. Use this for schools that are permanently '
            'leaving the platform.',
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
            bloc.add(
              UpdateSchoolStatusEvent(
                schoolId: school.id,
                status: SchoolStatus.archived,
                reason: reason,
              ),
            );
            Navigator.pop(dialogContext);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${school.name} has been deleted.')),
            );
          },
          child: const Text('Delete School'),
        ),
      ],
    ),
  );
}
