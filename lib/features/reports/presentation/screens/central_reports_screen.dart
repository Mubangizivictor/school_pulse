import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/core/permissions/role_permission_defaults.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_cubit.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_state.dart';
import 'package:school_pulse/features/institution/domain/entities/institution_context.dart';
import 'package:school_pulse/features/reports/data/report_center_repository.dart';
import 'package:school_pulse/features/reports/domain/reporting.dart';

class CentralReportsScreen extends StatefulWidget {
  const CentralReportsScreen({super.key});
  @override
  State<CentralReportsScreen> createState() => _CentralReportsScreenState();
}

class _CentralReportsScreenState extends State<CentralReportsScreen> {
  final _search = TextEditingController();
  final _access = const ReportAccessResolver();
  late final ReportCenterRepository _repository;
  final _favorites = <String>{};
  String _tab = 'Browse';

  @override
  void initState() {
    super.initState();
    _repository = ReportCenterRepository(FirebaseFirestore.instance);
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final institutionState = context.watch<InstitutionContextCubit>().state;
    if (auth is! AuthAuthenticated ||
        institutionState is! InstitutionContextLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final institution = institutionState.context;
    final permissions = _permissionsFor(auth.user.roles);
    final reports = ReportRegistry.definitions
        .where(
          (report) => _access
              .resolve(
                report: report,
                enabledModules: institution.enabledFeatures.toSet(),
                permissions: permissions,
                mfaEnabled: auth.user.mfaEnabled,
              )
              .canView,
        )
        .where(_matchesSearch)
        .toList();
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Reports Center'),
        actions: [
          IconButton(
            tooltip: 'Export history',
            icon: const Icon(Icons.history),
            onPressed: () => _showHistory(context, institution.institutionId),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            _Heading(institution: institution.displayLabel),
            const SizedBox(height: AppSpacing.l),
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search reports, categories, or saved reports',
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Browse',
                  label: Text('Browse'),
                  icon: Icon(Icons.grid_view),
                ),
                ButtonSegment(
                  value: 'Saved',
                  label: Text('Saved'),
                  icon: Icon(Icons.bookmark_outline),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (value) => setState(() => _tab = value.first),
            ),
            const SizedBox(height: AppSpacing.l),
            if (_tab == 'Saved')
              _SavedReports(
                repository: _repository,
                institutionId: institution.institutionId,
                userId: auth.user.id,
                onOpen: (saved) => _open(
                  context,
                  ReportRegistry.byKey(saved.reportKey)!,
                  auth,
                  institution,
                  permissions,
                  initialFilters: saved.filters,
                ),
              )
            else ...[
              if (_favorites.isNotEmpty)
                _ReportSection(
                  title: 'Favorites',
                  reports: reports
                      .where((r) => _favorites.contains(r.reportKey))
                      .toList(),
                  onOpen: (r) =>
                      _open(context, r, auth, institution, permissions),
                ),
              ..._sections(reports, auth, institution, permissions),
            ],
          ],
        ),
      ),
    );
  }

  bool _matchesSearch(ReportDefinition report) {
    final q = _search.text.trim().toLowerCase();
    return q.isEmpty ||
        '${report.title} ${report.moduleKey} ${report.category} ${report.description}'
            .toLowerCase()
            .contains(q);
  }

  List<Widget> _sections(
    List<ReportDefinition> reports,
    AuthAuthenticated auth,
    InstitutionContext institution,
    Set<String> permissions,
  ) {
    final grouped = <String, List<ReportDefinition>>{};
    for (final report in reports) {
      (grouped[report.category] ??= []).add(report);
    }
    return grouped.entries
        .map(
          (entry) => _ReportSection(
            title: entry.key,
            reports: entry.value,
            onOpen: (r) => _open(context, r, auth, institution, permissions),
            favorites: _favorites,
            onFavorite: (key) => setState(
              () => _favorites.contains(key)
                  ? _favorites.remove(key)
                  : _favorites.add(key),
            ),
          ),
        )
        .toList();
  }

  void _open(
    BuildContext context,
    ReportDefinition report,
    AuthAuthenticated auth,
    dynamic institution,
    Set<String> permissions, {
    Map<String, dynamic> initialFilters = const {},
  }) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ReportDetailScreen(
        report: report,
        institutionId: institution.institutionId,
        institutionName: institution.displayLabel,
        userId: auth.user.id,
        userName: auth.user.name,
        can: _access.resolve(
          report: report,
          enabledModules: institution.enabledFeatures.toSet(),
          permissions: permissions,
          mfaEnabled: auth.user.mfaEnabled,
        ),
        initialFilters: initialFilters,
      ),
    ),
  );
  Set<String> _permissionsFor(List<UserRole> roles) {
    return RolePermissionDefaults.permissionsFor(roles);
  }

  void _showHistory(BuildContext context, String id) => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => SizedBox(
      height: 300,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('institutions')
            .doc(id)
            .collection('report_export_history')
            .orderBy('requestedAt', descending: true)
            .limit(30)
            .snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No exports have been requested.'));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final d = doc.data();
              return ListTile(
                leading: const Icon(Icons.file_download_outlined),
                title: Text(d['reportKey']?.toString() ?? 'Report export'),
                subtitle: Text('${d['format'] ?? ''} • ${d['status'] ?? ''}'),
              );
            }).toList(),
          );
        },
      ),
    ),
  );
}

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({
    super.key,
    required this.report,
    required this.institutionId,
    required this.institutionName,
    required this.userId,
    required this.userName,
    required this.can,
    this.initialFilters = const {},
  });
  final ReportDefinition report;
  final String institutionId, institutionName, userId, userName;
  final ReportAccessDecision can;
  final Map<String, dynamic> initialFilters;
  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late final Map<String, dynamic> _filters = {...widget.initialFilters};
  final _repository = ReportCenterRepository(FirebaseFirestore.instance);
  @override
  void initState() {
    super.initState();
    _repository.audit(
      widget.institutionId,
      action: widget.report.sensitivity == ReportSensitivity.normal
          ? 'report_opened'
          : 'sensitive_report_opened',
      actorId: widget.userId,
      reportKey: widget.report.reportKey,
      filters: _filters,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.report.title)),
    body: ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        Text(
          widget.report.description,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textMuted(context),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text(
                widget.report.supportsSnapshot
                    ? 'Live / snapshot'
                    : 'Live data',
              ),
            ),
            Chip(label: Text('v${widget.report.version}')),
            if (widget.report.sensitivity != ReportSensitivity.normal)
              const Chip(
                avatar: Icon(Icons.lock_outline, size: 18),
                label: Text('Sensitive'),
              ),
          ],
        ),
        if (widget.can.requiresMfa)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: _Notice(
              'MFA is required before viewing or exporting this sensitive report.',
            ),
          ),
        const SizedBox(height: AppSpacing.l),
        Text('Filters', style: AppTypography.titleMedium),
        ...widget.report.filters.map(
          (name) => DropdownButtonFormField<String>(
            initialValue: _filters[name] as String?,
            decoration: InputDecoration(labelText: name),
            items: const [DropdownMenuItem(value: 'All', child: Text('All'))],
            onChanged: (value) => setState(() => _filters[name] = value),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        _Notice(
          'This center requests report results from the ${widget.report.moduleKey} reporting provider. No local calculation or raw operational-data fallback is used.',
        ),
        const SizedBox(height: AppSpacing.l),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (widget.can.canExport)
              FilledButton.icon(
                onPressed: () => _queueExport(context, ReportFormat.pdf),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Export PDF'),
              ),
            if (widget.can.canExport)
              OutlinedButton.icon(
                onPressed: () => _queueExport(context, ReportFormat.excel),
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('Export Excel'),
              ),
            if (widget.can.canExport)
              OutlinedButton.icon(
                onPressed: () => _queueExport(context, ReportFormat.csv),
                icon: const Icon(Icons.download_outlined),
                label: const Text('Export CSV'),
              ),
            if (widget.can.canSchedule)
              OutlinedButton.icon(
                onPressed: _schedule,
                icon: const Icon(Icons.schedule),
                label: const Text('Schedule'),
              ),
            OutlinedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('Save preset'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Generated metadata', style: AppTypography.titleMedium),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(widget.institutionName),
          subtitle: Text(
            'Generated on request • Institution timezone • ${widget.report.reportKey}',
          ),
        ),
      ],
    ),
  );
  Future<void> _queueExport(BuildContext context, ReportFormat format) async {
    final job = ReportExportJob(
      id: const Uuid().v4(),
      reportKey: widget.report.reportKey,
      ownerUserId: widget.userId,
      format: format,
      status: ReportJobStatus.queued,
      filters: _filters,
      createdAt: DateTime.now(),
    );
    await _repository.queueExport(widget.institutionId, job);
    await _repository.audit(
      widget.institutionId,
      action: 'export_requested',
      actorId: widget.userId,
      reportKey: widget.report.reportKey,
      filters: _filters,
    );
    if (mounted) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(
            '${format.name.toUpperCase()} export queued. You will be notified when it is ready.',
          ),
        ),
      );
    }
  }

  Future<void> _save() async {
    final name = await _nameDialog('Save report preset');
    if (name == null) return;
    await _repository.savePreset(
      widget.institutionId,
      SavedReport(
        id: const Uuid().v4(),
        reportKey: widget.report.reportKey,
        name: name,
        ownerUserId: widget.userId,
        filters: _filters,
        createdAt: DateTime.now(),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved report preset.')));
    }
  }

  Future<void> _schedule() async {
    final name = await _nameDialog('Schedule report');
    if (name == null) return;
    final id = const Uuid().v4();
    await FirebaseFirestore.instance
        .collection('institutions')
        .doc(widget.institutionId)
        .collection('scheduled_reports')
        .doc(id)
        .set({
          'scheduleId': id,
          'institutionId': widget.institutionId,
          'reportKey': widget.report.reportKey,
          'ownerUserId': widget.userId,
          'filterPreset': _filters,
          'recurrence': 'weekly',
          'deliveryMethod': 'in_app',
          'outputFormat': 'pdf',
          'sensitivity': widget.report.sensitivity.name,
          'active': true,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weekly in-app schedule created.')),
      );
    }
  }

  Future<String?> _nameDialog(String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.institution});
  final String institution;
  @override
  Widget build(BuildContext context) => PulseCard(
    child: Row(
      children: [
        const CircleAvatar(child: Icon(Icons.insights)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(institution, style: AppTypography.titleMedium),
              Text(
                'Institution insights • live reports respect your access scope',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({
    required this.title,
    required this.reports,
    required this.onOpen,
    this.favorites = const {},
    this.onFavorite,
  });
  final String title;
  final List<ReportDefinition> reports;
  final ValueChanged<ReportDefinition> onOpen;
  final Set<String> favorites;
  final ValueChanged<String>? onFavorite;
  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.s),
          ...reports.map(
            (report) => PulseCard(
              onTap: () => onOpen(report),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(report.icon),
                title: Text(report.title),
                subtitle: Text(report.description),
                trailing: onFavorite == null
                    ? const Icon(Icons.chevron_right)
                    : IconButton(
                        icon: Icon(
                          favorites.contains(report.reportKey)
                              ? Icons.star
                              : Icons.star_border,
                        ),
                        onPressed: () => onFavorite!(report.reportKey),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedReports extends StatelessWidget {
  const _SavedReports({
    required this.repository,
    required this.institutionId,
    required this.userId,
    required this.onOpen,
  });
  final ReportCenterRepository repository;
  final String institutionId, userId;
  final ValueChanged<SavedReport> onOpen;
  @override
  Widget build(BuildContext context) => StreamBuilder<List<SavedReport>>(
    stream: repository.watchSavedReports(institutionId, userId),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.data!.isEmpty) {
        return const _Notice(
          'No saved reports yet. Save a report configuration from its detail screen.',
        );
      }
      return Column(
        children: snapshot.data!
            .map(
              (saved) => ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: Text(saved.name),
                subtitle: Text(
                  ReportRegistry.byKey(saved.reportKey)?.title ??
                      saved.reportKey,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () =>
                      repository.deletePreset(institutionId, saved.id),
                ),
                onTap: () => onOpen(saved),
              ),
            )
            .toList(),
      );
    },
  );
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text),
  );
}
