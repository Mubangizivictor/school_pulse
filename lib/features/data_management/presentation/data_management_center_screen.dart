import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/data_management/data/data_management_repository.dart';
import 'package:school_pulse/features/data_management/domain/data_operation_models.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_cubit.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_state.dart';

class DataManagementCenterScreen extends StatefulWidget {
  const DataManagementCenterScreen({super.key});
  @override
  State<DataManagementCenterScreen> createState() =>
      _DataManagementCenterScreenState();
}

class _DataManagementCenterScreenState
    extends State<DataManagementCenterScreen> {
  final _repository = DataManagementRepository();
  bool _working = false;

  Future<void> _request(String operation, {String module = 'data'}) async {
    final state = context.read<AuthBloc>().state;
    final institution = context.read<InstitutionContextCubit>().state;
    if (state is! AuthAuthenticated) {
      return;
    }
    if (institution is! InstitutionContextLoaded) {
      return;
    }
    setState(() => _working = true);
    try {
      await _repository.request(
        operation: operation,
        institutionId: institution.context.institutionId,
        moduleKey: module,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your request has been queued.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start operation: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _startImport() async {
    final chosen = await showModalBottomSheet<ImportTemplate>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        children: [
          const ListTile(
            title: Text('Choose an import type'),
            subtitle: Text(
              'Templates are versioned and validated before processing.',
            ),
          ),
          for (final template in supportedImportTemplates)
            ListTile(
              title: Text(template.label),
              subtitle: Text('Template ${template.templateVersion}'),
              onTap: () => Navigator.pop(context, template),
            ),
        ],
      ),
    );
    if (chosen == null || !mounted) {
      return;
    }
    final file = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
      withData: true,
    );
    if (!mounted || file == null || file.files.single.bytes == null) {
      return;
    }
    final picked = file.files.single;
    if (picked.size > 25 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Files must be 25 MB or smaller.')),
        );
      }
      return;
    }
    final state = context.read<AuthBloc>().state;
    final institution = context.read<InstitutionContextCubit>().state;
    if (state is! AuthAuthenticated) {
      return;
    }
    if (institution is! InstitutionContextLoaded) {
      return;
    }
    setState(() => _working = true);
    try {
      final bytes = picked.bytes!;
      final safeName = picked.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final path =
          'institutions/${institution.context.institutionId}/data_operations/imports/${DateTime.now().millisecondsSinceEpoch}_$safeName';
      await FirebaseStorage.instance
          .ref(path)
          .putData(
            bytes,
            SettableMetadata(
              contentType: picked.extension == 'csv'
                  ? 'text/csv'
                  : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            ),
          );
      await _repository.request(
        operation: 'import',
        institutionId: institution.context.institutionId,
        moduleKey: chosen.moduleKey,
        payload: {
          'fileReference': path,
          'templateVersion': chosen.templateVersion,
          'fileName': picked.name,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File uploaded. Validation will begin shortly.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import upload failed: $error')));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final institution = context.watch<InstitutionContextCubit>().state;
    final schoolId = institution is InstitutionContextLoaded
        ? institution.context.institutionId
        : null;
    return Scaffold(
      appBar: const AdminAppBar(title: 'Data Management'),
      body: schoolId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<DataOperation>>(
              stream: _repository.watch(schoolId, DataOperationKind.import),
              builder: (context, snapshot) {
                final imports = snapshot.data ?? const <DataOperation>[];
                final failedRows = imports.fold<int>(
                  0,
                  (sum, item) => sum + item.failed,
                );
                final duplicates = imports.fold<int>(
                  0,
                  (sum, item) => sum + item.duplicates,
                );
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Move school data safely',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Every operation is tenant-scoped, validated, reviewed, processed by a backend job, and audited.',
                    ),
                    const SizedBox(height: 20),
                    _SummaryGrid(
                      items: [
                        (
                          'Pending imports',
                          '${imports.where((x) => x.status != DataOperationStatus.completed).length}',
                          Icons.upload_file_outlined,
                        ),
                        ('Failed rows', '$failedRows', Icons.error_outline),
                        (
                          'Duplicate candidates',
                          '$duplicates',
                          Icons.copy_outlined,
                        ),
                        (
                          'Last backup',
                          'Platform-managed',
                          Icons.backup_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _ActionCard(
                          icon: Icons.upload_file,
                          title: 'Import data',
                          subtitle: 'CSV or XLSX with preview and review',
                          onTap: _working ? null : _startImport,
                        ),
                        _ActionCard(
                          icon: Icons.download_outlined,
                          title: 'Export data',
                          subtitle: 'Scoped, permission-checked jobs',
                          onTap: _working
                              ? null
                              : () => _request('export', module: 'students'),
                        ),
                        _ActionCard(
                          icon: Icons.fact_check_outlined,
                          title: 'Data quality',
                          subtitle: 'Find missing and orphaned references',
                          onTap: _working ? null : () => _request('quality'),
                        ),
                        _ActionCard(
                          icon: Icons.sync_alt_outlined,
                          title: 'Migration jobs',
                          subtitle: 'Dry runs and manual-review conflicts',
                          onTap: _working
                              ? null
                              : () => _request('migrationDryRun'),
                        ),
                        _ActionCard(
                          icon: Icons.archive_outlined,
                          title: 'Archived records',
                          subtitle: 'Restore only through source modules',
                          onTap: _working
                              ? null
                              : () => _request('archiveReview'),
                        ),
                        _ActionCard(
                          icon: Icons.settings_backup_restore,
                          title: 'Restore request',
                          subtitle: 'Platform approval; no client restore',
                          onTap: _working
                              ? null
                              : () => _request('restoreRequest'),
                        ),
                        _ActionCard(
                          icon: Icons.health_and_safety_outlined,
                          title: 'Institution health',
                          subtitle: 'Setup completeness and integrity checks',
                          onTap: () =>
                              context.push('/staff/admin/institution-health'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Recent import operations',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (snapshot.hasError)
                      const AppCard(
                        child: ListTile(
                          leading: Icon(Icons.cloud_off),
                          title: Text('Operations are unavailable'),
                          subtitle: Text(
                            'Check your connection or permissions and try again.',
                          ),
                        ),
                      )
                    else if (imports.isEmpty)
                      const AppCard(
                        child: ListTile(
                          leading: Icon(Icons.history),
                          title: Text('No import operations yet'),
                          subtitle: Text(
                            'Download a current template, upload a file, then confirm after validation.',
                          ),
                        ),
                      )
                    else
                      ...imports.map(_OperationTile.new),
                  ],
                );
              },
            ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.items});
  final List<(String, String, IconData)> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GridView.count(
        crossAxisCount: constraints.maxWidth > 700 ? 4 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.8,
        children: items.map((item) {
          return AppCard(
            child: ListTile(
              leading: Icon(item.$3),
              title: Text(
                item.$2,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(item.$1),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 260,
    child: AppCard(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    ),
  );
}

class _OperationTile extends StatelessWidget {
  const _OperationTile(this.operation);
  final DataOperation operation;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: AppCard(
      child: ListTile(
        leading: const Icon(Icons.upload_file_outlined),
        title: Text(operation.moduleKey),
        subtitle: Text(
          '${operation.status.name} · ${operation.processed}/${operation.total} rows · ${operation.failed} failed',
        ),
        trailing: Text(
          '${operation.createdAt.day}/${operation.createdAt.month}',
        ),
      ),
    ),
  );
}
