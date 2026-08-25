import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/teacher/domain/services/academic_calendar_service.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_state.dart';
import '../bloc/finance_event.dart';
import '../../domain/entities/fee_category.dart';
import '../../domain/entities/fee_structure.dart';

class FeeConfigurationScreen extends StatefulWidget {
  const FeeConfigurationScreen({super.key});

  @override
  State<FeeConfigurationScreen> createState() => _FeeConfigurationScreenState();
}

class _FeeConfigurationScreenState extends State<FeeConfigurationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FinanceBloc>().add(
        LoadFeeCategories(authState.user.schoolId),
      );
      context.read<FinanceBloc>().add(
        LoadFeeStructures(authState.user.schoolId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FinanceBloc, FinanceState>(
      listener: (context, state) {
        if (state is FinanceActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          _loadData();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Fee Configuration'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Categories'),
              Tab(text: 'Structures'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_FeeCategoriesList(), _FeeStructuresList()],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    if (_tabController.index == 0) {
      _showAddCategoryDialog(context);
    } else {
      _showAddStructureDialog(context);
    }
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    bool isMandatory = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Fee Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name (e.g. Tuition)',
                ),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              SwitchListTile(
                title: const Text('Mandatory'),
                value: isMandatory,
                onChanged: (val) => setState(() => isMandatory = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final authState =
                    context.read<AuthBloc>().state as AuthAuthenticated;
                context.read<FinanceBloc>().add(
                  SaveSchoolFeeCategory(
                    FeeCategory(
                      id: '',
                      schoolId: authState.user.schoolId,
                      name: nameController.text,
                      description: descController.text,
                      isMandatory: isMandatory,
                    ),
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStructureDialog(BuildContext context) {
    final nameController = TextEditingController();
    String term = 'Term 1';
    String category = 'Day';
    String? classId;
    List<FeeStructureItem> items = [];
    final authState = context.read<AuthBloc>().state as AuthAuthenticated;
    final structureRepo = sl<StructureRepository>();
    // FeeStructure.academicYear is matched against AcademicYear.id by the
    // enrollment wizard's Finance step, not the display name, so resolve
    // and store the id rather than letting the admin type a year string.
    final currentPeriodFuture = sl<AcademicCalendarService>().getCurrentPeriod(
      authState.user.schoolId,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => FutureBuilder<AcademicPeriod>(
        future: currentPeriodFuture,
        builder: (context, periodSnapshot) {
          final period = periodSnapshot.data;
          final academicYearId = period?.academicYearId ?? '';
          final academicYearName = period?.academicYearName ?? '';

          return StatefulBuilder(
            builder: (context, setState) {
              final financeState = context.watch<FinanceBloc>().state;
              List<FeeCategory> availableCategories = [];
              if (financeState is FeeConfigurationLoaded) {
                availableCategories = financeState.categories;
              }

              return AlertDialog(
                title: const Text('Create Fee Structure'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Structure Name',
                        ),
                      ),
                      if (academicYearName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Academic year: $academicYearName',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: term,
                              items: ['Term 1', 'Term 2', 'Term 3']
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => term = v!),
                              decoration: const InputDecoration(
                                labelText: 'Term',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: category,
                              items: ['Day', 'Boarding', 'International']
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => category = v!),
                              decoration: const InputDecoration(
                                labelText: 'Student Category',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<List<SchoolClass>>(
                        stream: structureRepo.watchClasses(
                          authState.user.schoolId,
                        ),
                        builder: (context, snap) {
                          final classes = snap.data ?? const <SchoolClass>[];
                          return DropdownButtonFormField<String?>(
                            initialValue: classId,
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('All classes'),
                              ),
                              ...classes.map(
                                (c) => DropdownMenuItem<String?>(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              ),
                            ],
                            onChanged: (v) => setState(() => classId = v),
                            decoration: const InputDecoration(
                              labelText: 'Applies to class (optional)',
                            ),
                          );
                        },
                      ),
                      const Divider(height: 32),
                      const Text(
                        'Fee Items',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...items.map(
                        (item) => ListTile(
                          title: Text(item.categoryName),
                          trailing: Text(CurrencyFormatter.ugx(item.amount)),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showAddItemDialog(
                          context,
                          availableCategories,
                          (newItem) {
                            setState(() => items.add(newItem));
                          },
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Item'),
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
                    onPressed: academicYearId.isEmpty
                        ? null
                        : () {
                            context.read<FinanceBloc>().add(
                              SaveSchoolFeeStructure(
                                FeeStructure(
                                  id: '',
                                  schoolId: authState.user.schoolId,
                                  name: nameController.text,
                                  academicYear: academicYearId,
                                  term: term,
                                  items: items,
                                  classId: classId,
                                  studentCategory: category,
                                ),
                              ),
                            );
                            Navigator.pop(dialogContext);
                          },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showAddItemDialog(
    BuildContext context,
    List<FeeCategory> categories,
    Function(FeeStructureItem) onAdd,
  ) {
    FeeCategory? selectedCategory;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Fee Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<FeeCategory>(
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (v) => selectedCategory = v,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (UGX)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedCategory != null &&
                  amountController.text.isNotEmpty) {
                onAdd(
                  FeeStructureItem(
                    categoryId: selectedCategory!.id,
                    categoryName: selectedCategory!.name,
                    amount: double.tryParse(amountController.text) ?? 0,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _FeeCategoriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        if (state is FinanceLoading) {
          return const Center(child: SchoolPulseLoader());
        }
        if (state is FeeConfigurationLoaded) {
          if (state.categories.isEmpty) {
            return const Center(child: Text('No categories defined.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final cat = state.categories[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    cat.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(cat.description ?? 'No description'),
                  trailing: cat.isMandatory
                      ? const Chip(
                          label: Text(
                            'Mandatory',
                            style: TextStyle(fontSize: 10),
                          ),
                          backgroundColor: Colors.black,
                        )
                      : null,
                ),
              );
            },
          );
        }
        return const Center(child: Text('Load data to see categories'));
      },
    );
  }
}

class _FeeStructuresList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        if (state is FinanceLoading) {
          return const Center(child: SchoolPulseLoader());
        }
        if (state is FeeConfigurationLoaded) {
          if (state.structures.isEmpty) {
            return const Center(child: Text('No structures defined.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.structures.length,
            itemBuilder: (context, index) {
              final struct = state.structures[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(
                    struct.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${struct.studentCategory} • ${struct.term} ${struct.academicYear}'
                    '${struct.classId == null ? ' • All classes' : ''}',
                  ),
                  trailing: Text(
                    CurrencyFormatter.ugx(struct.totalAmount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  children: struct.items
                      .map(
                        (item) => ListTile(
                          dense: true,
                          title: Text(item.categoryName),
                          trailing: Text(CurrencyFormatter.ugx(item.amount)),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          );
        }
        return const Center(child: Text('Load data to see structures'));
      },
    );
  }
}
