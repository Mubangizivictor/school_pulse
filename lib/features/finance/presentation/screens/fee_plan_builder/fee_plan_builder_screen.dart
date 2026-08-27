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
import 'package:school_pulse/features/finance/domain/entities/fee_catalogue_item.dart';
import 'package:school_pulse/features/finance/domain/entities/fee_plan.dart';
import 'package:school_pulse/features/finance/domain/repositories/fee_catalogue_repository.dart';
import 'package:school_pulse/features/finance/presentation/bloc/fee_plan_builder/fee_plan_builder_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/fee_plan_builder/fee_plan_builder_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/fee_plan_builder/fee_plan_builder_state.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'fee_plan_editor_dialog.dart';

/// Replaces the legacy Fee Configuration screen's Structures tab. Reachable
/// from Structure > Academics > Fee Plans (school admin never has to go
/// through a Bursar-prefixed screen) as well as from Bursar's own entry
/// points. Money is integer UGX everywhere - no `double` amounts anywhere
/// in this feature.
class FeePlanBuilderScreen extends StatelessWidget {
  const FeePlanBuilderScreen({super.key});

  static const _financeRoles = {
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
    final canManage = authState.user.roles.any(_financeRoles.contains);
    final schoolId = authState.user.schoolId;

    return BlocProvider(
      create: (_) => FeePlanBuilderBloc(repository: sl())
        ..add(FeePlansSubscriptionRequested(schoolId)),
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
    return BlocListener<FeePlanBuilderBloc, FeePlanBuilderState>(
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
          title: const Text('Fee Plans'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Fee Plans'),
              Tab(text: 'Fee Catalogue'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _FeePlansTab(schoolId: widget.schoolId, canManage: widget.canManage),
            _FeeCatalogueTab(
              schoolId: widget.schoolId,
              canManage: widget.canManage,
            ),
          ],
        ),
        floatingActionButton: widget.canManage && _tabController.index == 0
            ? null
            : null,
      ),
    );
  }
}

class _FeePlansTab extends StatelessWidget {
  final String schoolId;
  final bool canManage;
  const _FeePlansTab({required this.schoolId, required this.canManage});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeePlanBuilderBloc, FeePlanBuilderState>(
      builder: (context, state) {
        return Stack(
          children: [
            if (state.isLoading)
              const Center(child: SchoolPulseLoader())
            else if (state.plans.isEmpty)
              EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No fee plans yet',
                message: canManage
                    ? 'Publish a fee plan for a class, term and student '
                          'category to start billing new enrolments.'
                    : 'No fee plans have been published for this school yet.',
              )
            else
              StreamBuilder<List<SchoolClass>>(
                stream: sl<StructureRepository>().watchClasses(schoolId),
                builder: (context, classSnap) {
                  final classes = classSnap.data ?? const <SchoolClass>[];
                  return StreamBuilder<List<AcademicYear>>(
                    stream: sl<StructureRepository>().watchAcademicYears(
                      schoolId,
                    ),
                    builder: (context, yearSnap) {
                      final years = yearSnap.data ?? const <AcademicYear>[];
                      return StreamBuilder<List<AcademicTerm>>(
                        stream: sl<StructureRepository>().watchAcademicTerms(
                          schoolId,
                        ),
                        builder: (context, termSnap) {
                          final terms = termSnap.data ?? const <AcademicTerm>[];
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.plans.length,
                            itemBuilder: (context, index) {
                              final plan = state.plans[index];
                              final className = classes
                                      .where((c) => c.id == plan.selector.classId)
                                      .firstOrNull
                                      ?.name ??
                                  plan.selector.classId;
                              final yearName = years
                                      .where(
                                        (y) =>
                                            y.id == plan.selector.academicYearId,
                                      )
                                      .firstOrNull
                                      ?.name ??
                                  plan.selector.academicYearId;
                              final termName = terms
                                      .where((t) => t.id == plan.selector.termId)
                                      .firstOrNull
                                      ?.name ??
                                  plan.selector.termId;
                              return AppCard(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(
                                    plan.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$className • ${plan.selector.studentCategory} • '
                                    '$termName $yearName • v${plan.latestVersion}',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _StatusChip(status: plan.status),
                                      if (canManage) ...[
                                        const SizedBox(width: 4),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'new_version') {
                                              _openEditor(
                                                context,
                                                existingPlan: plan,
                                              );
                                            } else if (value == 'archive') {
                                              context
                                                  .read<FeePlanBuilderBloc>()
                                                  .add(
                                                    FeePlanArchiveRequested(
                                                      schoolId: schoolId,
                                                      planId: plan.id,
                                                    ),
                                                  );
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            if (plan.status == 'published')
                                              const PopupMenuItem(
                                                value: 'new_version',
                                                child: Text('New version'),
                                              ),
                                            if (plan.status != 'archived')
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
                  label: const Text('New plan'),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openEditor(BuildContext context, {FeePlan? existingPlan}) {
    final bloc = context.read<FeePlanBuilderBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: FeePlanEditorDialog(schoolId: schoolId, existingPlan: existingPlan),
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

class _FeeCatalogueTab extends StatelessWidget {
  final String schoolId;
  final bool canManage;
  const _FeeCatalogueTab({required this.schoolId, required this.canManage});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FeeCatalogueItem>>(
      stream: sl<FeeCatalogueRepository>().watchCatalogue(schoolId),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <FeeCatalogueItem>[];
        return Stack(
          children: [
            if (!snapshot.hasData)
              const Center(child: SchoolPulseLoader())
            else if (items.isEmpty)
              EmptyState(
                icon: Icons.local_offer_outlined,
                title: 'No charges yet',
                message: canManage
                    ? 'Add reusable named charges (e.g. Tuition, Transport) '
                          'to speed up building fee plans.'
                    : 'No fee charges have been set up for this school yet.',
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
                      subtitle: item.defaultServiceKey != null
                          ? Text('Service: ${item.defaultServiceKey}')
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
                  label: const Text('New charge'),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, FeeCatalogueItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove charge?'),
        content: Text('Remove "${item.name}" from the fee catalogue?'),
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
      await sl<FeeCatalogueRepository>().deleteItem(schoolId, item.id);
    }
  }

  void _openAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final serviceKeyController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Fee Charge'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name (e.g. Tuition)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: serviceKeyController,
              decoration: const InputDecoration(
                labelText: 'Service key (optional)',
              ),
            ),
          ],
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
              await sl<FeeCatalogueRepository>().saveItem(
                FeeCatalogueItem(
                  id: '',
                  schoolId: schoolId,
                  name: name,
                  defaultServiceKey: serviceKeyController.text.trim().isEmpty
                      ? null
                      : serviceKeyController.text.trim(),
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
