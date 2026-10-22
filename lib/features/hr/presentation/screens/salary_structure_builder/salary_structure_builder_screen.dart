import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/hr/domain/entities/pay_component_catalogue_item.dart';
import 'package:school_pulse/features/hr/domain/entities/salary_structure.dart';
import 'package:school_pulse/features/hr/domain/repositories/pay_component_catalogue_repository.dart';
import 'package:school_pulse/features/hr/presentation/bloc/salary_structure_builder/salary_structure_builder_bloc.dart';
import 'package:school_pulse/features/hr/presentation/bloc/salary_structure_builder/salary_structure_builder_event.dart';
import 'package:school_pulse/features/hr/presentation/bloc/salary_structure_builder/salary_structure_builder_state.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'salary_structure_editor_dialog.dart';

/// Structure > People > Salary Structures. Money is integer UGX everywhere -
/// mirrors FeePlanBuilderScreen's design exactly, but keyed on designation
/// instead of class/term/category.
class SalaryStructureBuilderScreen extends StatelessWidget {
  const SalaryStructureBuilderScreen({super.key});

  static const _payrollRoles = {
    UserRole.schoolAdmin,
    UserRole.director,
    UserRole.headTeacher,
    UserRole.bursar,
  };

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: SchoolPulseLoader()));
    }
    final canManage = authState.user.roles.any(_payrollRoles.contains);
    final schoolId = authState.user.schoolId;

    return BlocProvider(
      create: (_) => SalaryStructureBuilderBloc(repository: sl())
        ..add(SalaryStructuresSubscriptionRequested(schoolId)),
      child: _BuilderView(schoolId: schoolId, canManage: canManage),
    );
  }
}

class _BuilderView extends StatefulWidget {
  final String schoolId;
  final bool canManage;
  const _BuilderView({required this.schoolId, required this.canManage});

  @override
  State<_BuilderView> createState() => _BuilderViewState();
}

class _BuilderViewState extends State<_BuilderView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SalaryStructureBuilderBloc, SalaryStructureBuilderState>(
      listenWhen: (prev, curr) =>
          curr.error != prev.error || curr.successMessage != prev.successMessage,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.danger(context),
            ),
          );
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Salary Structures'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Salary Structures'),
              Tab(text: 'Pay Component Catalogue'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _StructuresTab(schoolId: widget.schoolId, canManage: widget.canManage),
            _CatalogueTab(schoolId: widget.schoolId, canManage: widget.canManage),
          ],
        ),
      ),
    );
  }
}

class _StructuresTab extends StatelessWidget {
  final String schoolId;
  final bool canManage;
  const _StructuresTab({required this.schoolId, required this.canManage});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalaryStructureBuilderBloc, SalaryStructureBuilderState>(
      builder: (context, state) {
        return Stack(
          children: [
            if (state.isLoading)
              const Center(child: SchoolPulseLoader())
            else if (state.structures.isEmpty)
              EmptyState(
                icon: Icons.payments_outlined,
                title: 'No salary structures yet',
                message: canManage
                    ? 'Publish a salary structure for a staff designation '
                          'to start setting up pay for new staff.'
                    : 'No salary structures have been published for this school yet.',
              )
            else
              StreamBuilder<List<StaffDesignation>>(
                stream: sl<StructureRepository>().watchDesignations(schoolId),
                builder: (context, designationSnap) {
                  final designations =
                      designationSnap.data ?? const <StaffDesignation>[];
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.structures.length,
                    itemBuilder: (context, index) {
                      final structure = state.structures[index];
                      final designationName = designations
                              .where(
                                (d) => d.id == structure.selector.designationId,
                              )
                              .firstOrNull
                              ?.name ??
                          structure.selector.designationId;
                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            structure.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '$designationName • v${structure.latestVersion}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _StatusChip(status: structure.status),
                              if (canManage) ...[
                                const SizedBox(width: 4),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'new_version') {
                                      _openEditor(
                                        context,
                                        existingStructure: structure,
                                      );
                                    } else if (value == 'archive') {
                                      context
                                          .read<SalaryStructureBuilderBloc>()
                                          .add(
                                            SalaryStructureArchiveRequested(
                                              schoolId: schoolId,
                                              structureId: structure.id,
                                            ),
                                          );
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    if (structure.status == 'published')
                                      const PopupMenuItem(
                                        value: 'new_version',
                                        child: Text('New version'),
                                      ),
                                    if (structure.status != 'archived')
                                      const PopupMenuItem(
                                        value: 'archive',
                                        child: Text('Archive'),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            if (canManage)
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  onPressed: () => _openEditor(context),
                  icon: const Icon(Icons.add),
                  label: const Text('New structure'),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openEditor(BuildContext context, {SalaryStructure? existingStructure}) {
    final bloc = context.read<SalaryStructureBuilderBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: SalaryStructureEditorDialog(
          schoolId: schoolId,
          existingStructure: existingStructure,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'published' => AppColors.success(context),
      'archived' => AppColors.textMuted(context),
      _ => AppColors.warning(context),
    };
    return Chip(
      label: Text(status, style: const TextStyle(fontSize: 11)),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _CatalogueTab extends StatelessWidget {
  final String schoolId;
  final bool canManage;
  const _CatalogueTab({required this.schoolId, required this.canManage});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PayComponentCatalogueItem>>(
      stream: sl<PayComponentCatalogueRepository>().watchCatalogue(schoolId),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <PayComponentCatalogueItem>[];
        return Stack(
          children: [
            if (!snapshot.hasData)
              const Center(child: SchoolPulseLoader())
            else if (items.isEmpty)
              EmptyState(
                icon: Icons.local_offer_outlined,
                title: 'No pay components yet',
                message: canManage
                    ? 'Add reusable named pay components (e.g. Base Salary, '
                          'Housing Allowance) to speed up building salary '
                          'structures.'
                    : 'No pay components have been set up for this school yet.',
              )
            else
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: item.defaultComponentKey != null
                          ? Text('Component: ${item.defaultComponentKey}')
                          : null,
                      trailing: item.suggestedAmountUgx != null
                          ? Text(
                              CurrencyFormatter.ugx(
                                item.suggestedAmountUgx!.toDouble(),
                              ),
                            )
                          : null,
                      onLongPress: canManage
                          ? () => _confirmDelete(context, item)
                          : null,
                    ),
                  );
                },
              ),
            if (canManage)
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.extended(
                  onPressed: () => _openAddDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('New component'),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PayComponentCatalogueItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove component?'),
        content: Text('Remove "${item.name}" from the pay component catalogue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await sl<PayComponentCatalogueRepository>().deleteItem(schoolId, item.id);
    }
  }

  // Common pay components on a typical Ugandan school payroll - presets to
  // speed up catalogue setup, not an exhaustive or mandatory list. Admins
  // can still type any custom name.
  static const _presetComponents = <(String name, String componentKey)>[
    ('Base Salary', 'base_salary'),
    ('Housing Allowance', 'housing'),
    ('Transport Allowance', 'transport'),
    ('Airtime / Communication Allowance', 'airtime'),
    ('Responsibility Allowance', 'responsibility'),
    ('Lunch Allowance', 'lunch'),
    ('Hardship Allowance', 'hardship'),
    ('Overtime Allowance', 'overtime'),
    ('Medical / Insurance', 'medical'),
    ('Leave Allowance', 'leave'),
  ];

  void _openAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final componentKeyController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Pay Component'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Common components',
                style: Theme.of(dialogContext).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final preset in _presetComponents)
                    ActionChip(
                      label: Text(preset.$1),
                      onPressed: () {
                        nameController.text = preset.$1;
                        componentKeyController.text = preset.$2;
                      },
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (e.g. Base Salary)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: componentKeyController,
                decoration: const InputDecoration(
                  labelText: 'Component key (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              await sl<PayComponentCatalogueRepository>().saveItem(
                PayComponentCatalogueItem(
                  id: '',
                  schoolId: schoolId,
                  name: name,
                  defaultComponentKey:
                      componentKeyController.text.trim().isEmpty
                          ? null
                          : componentKeyController.text.trim(),
                ),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
