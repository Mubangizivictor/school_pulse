import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/feature_toggles.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';

/// One optional module's definition: how to read/write its switch on
/// [FeatureToggles], which category it belongs to, and what a school should
/// set up before it's genuinely usable (informational only - enabling the
/// switch is always allowed so a school can finish setup later).
class _ModuleDef {
  final String key;
  final String title;
  final IconData icon;
  final String description;
  final _Category category;
  final bool Function(FeatureToggles) isEnabled;
  final FeatureToggles Function(FeatureToggles, bool) apply;
  final List<_ReadinessItem> Function(StructureState) readiness;

  const _ModuleDef({
    required this.key,
    required this.title,
    required this.icon,
    required this.description,
    required this.category,
    required this.isEnabled,
    required this.apply,
    this.readiness = _noReadiness,
  });

  static List<_ReadinessItem> _noReadiness(StructureState state) => const [];
}

class _ReadinessItem {
  final String label;
  final IconData icon;
  final bool done;
  const _ReadinessItem(this.label, this.icon, {this.done = false});
}

enum _Category {
  studentServices('Student services', Icons.directions_bus_outlined),
  accessPortals('Access & portals', Icons.laptop_outlined),
  operationsCommunity('Operations & community', Icons.settings_outlined);

  const _Category(this.label, this.icon);
  final String label;
  final IconData icon;
}

final List<_ModuleDef> _modules = [
  _ModuleDef(
    key: 'transport',
    title: 'Transport',
    icon: Icons.directions_bus_outlined,
    description: 'Manage routes, stops, vehicles and student riders.',
    category: _Category.studentServices,
    isEnabled: (t) => t.transport,
    apply: (t, v) => t.copyWith(transport: v),
    readiness: (s) => [
      _ReadinessItem(
        'Create routes and stops',
        Icons.map_outlined,
        done: s.transportRoutes.isNotEmpty,
      ),
      const _ReadinessItem(
        'Add vehicles and drivers',
        Icons.directions_bus_filled_outlined,
      ),
      const _ReadinessItem('Assign eligible students', Icons.groups_outlined),
    ],
  ),
  _ModuleDef(
    key: 'boarding',
    title: 'Boarding',
    icon: Icons.night_shelter_outlined,
    description: 'Manage houses, dormitories and boarding students.',
    category: _Category.studentServices,
    isEnabled: (t) => t.boarding,
    apply: (t, v) => t.copyWith(boarding: v, hostel: v),
    readiness: (s) => [
      _ReadinessItem(
        'Create houses or dormitories',
        Icons.holiday_village_outlined,
        done: s.hostels.isNotEmpty,
      ),
      const _ReadinessItem('Assign boarding students', Icons.groups_outlined),
    ],
  ),
  _ModuleDef(
    key: 'library',
    title: 'Library',
    icon: Icons.local_library_outlined,
    description: 'Track books, loans and library members.',
    category: _Category.studentServices,
    isEnabled: (t) => t.library,
    apply: (t, v) => t.copyWith(library: v),
    readiness: (s) => const [
      _ReadinessItem('Add your book catalogue', Icons.menu_book_outlined),
    ],
  ),
  _ModuleDef(
    key: 'health',
    title: 'Health',
    icon: Icons.medical_services_outlined,
    description: 'Record student health visits and medical notes.',
    category: _Category.studentServices,
    isEnabled: (t) => t.medical,
    apply: (t, v) => t.copyWith(medical: v),
    readiness: (s) => const [
      _ReadinessItem(
        'Set up the sick bay space',
        Icons.local_hospital_outlined,
      ),
    ],
  ),
  _ModuleDef(
    key: 'parentPortal',
    title: 'Parent portal',
    icon: Icons.family_restroom_outlined,
    description: 'Give parents access to their child\'s school information.',
    category: _Category.accessPortals,
    isEnabled: (t) => t.parentPortal,
    apply: (t, v) => t.copyWith(parentPortal: v),
    readiness: (s) => const [
      _ReadinessItem('Add guardian contacts', Icons.contacts_outlined),
      _ReadinessItem('Send parent invites', Icons.mail_outline),
    ],
  ),
  _ModuleDef(
    key: 'studentPortal',
    title: 'Student portal',
    icon: Icons.school_outlined,
    description: 'Give students access to their own school information.',
    category: _Category.accessPortals,
    isEnabled: (t) => t.studentPortal,
    apply: (t, v) => t.copyWith(studentPortal: v),
    readiness: (s) => const [
      _ReadinessItem('Activate student accounts', Icons.person_outline),
    ],
  ),
  _ModuleDef(
    key: 'digitalIds',
    title: 'Digital IDs',
    icon: Icons.badge_outlined,
    description: 'Issue QR-based digital ID cards for students and staff.',
    category: _Category.accessPortals,
    isEnabled: (t) => t.digitalIds,
    apply: (t, v) => t.copyWith(digitalIds: v),
  ),
  _ModuleDef(
    key: 'qrAttendance',
    title: 'QR attendance',
    icon: Icons.qr_code_scanner_outlined,
    description: 'Scan digital IDs to record attendance.',
    category: _Category.accessPortals,
    isEnabled: (t) => t.qrAttendance,
    apply: (t, v) => t.copyWith(qrAttendance: v),
    readiness: (s) => [
      _ReadinessItem(
        'Enable Digital IDs first',
        Icons.badge_outlined,
        done: s.featureToggles.digitalIds,
      ),
    ],
  ),
  _ModuleDef(
    key: 'inventory',
    title: 'Inventory',
    icon: Icons.inventory_2_outlined,
    description: 'Track school assets and stock levels.',
    category: _Category.operationsCommunity,
    isEnabled: (t) => t.inventory,
    apply: (t, v) => t.copyWith(inventory: v),
  ),
  _ModuleDef(
    key: 'procurement',
    title: 'Procurement',
    icon: Icons.shopping_cart_checkout_outlined,
    description: 'Manage purchase requests and suppliers.',
    category: _Category.operationsCommunity,
    isEnabled: (t) => t.procurement,
    apply: (t, v) => t.copyWith(procurement: v),
  ),
  _ModuleDef(
    key: 'payroll',
    title: 'Payroll',
    icon: Icons.payments_outlined,
    description: 'Run staff payroll and payslips.',
    category: _Category.operationsCommunity,
    isEnabled: (t) => t.payroll,
    apply: (t, v) => t.copyWith(payroll: v),
    readiness: (s) => const [
      _ReadinessItem('Set up staff employment details', Icons.badge_outlined),
      _ReadinessItem('Configure pay structure', Icons.payments_outlined),
    ],
  ),
  _ModuleDef(
    key: 'alumni',
    title: 'Alumni',
    icon: Icons.groups_outlined,
    description: 'Stay connected with former students.',
    category: _Category.operationsCommunity,
    isEnabled: (t) => t.alumni,
    apply: (t, v) => t.copyWith(alumni: v),
  ),
];

/// Step 14: which optional modules this school has switched on. Core tools
/// (student records, staff, academic structure, attendance, assessment,
/// basic fees, announcements) are always on and not shown here - only the
/// modules a school can genuinely choose to enable or leave off.
class FeatureTogglesScreen extends StatefulWidget {
  const FeatureTogglesScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<FeatureTogglesScreen> createState() => _FeatureTogglesScreenState();
}

class _FeatureTogglesScreenState extends State<FeatureTogglesScreen> {
  // FeatureToggles defaults every switch to `true` when read from an empty
  // document, for backward compatibility with schools that already relied
  // on that default elsewhere in the app. This setup screen must never show
  // that as a fake "N enabled" though, so it checks document existence once
  // and, while unconfigured, treats every module as off until the admin
  // makes an explicit choice (which then always writes real `false` values
  // for anything left off, so the next load reads the truth directly).
  late final Future<bool> _hasSavedChoices = () async {
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    final doc = await FirebaseFirestore.instance
        .collection('schools')
        .doc(schoolId)
        .collection('settings')
        .doc('features')
        .get();
    return doc.exists;
  }();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Feature choices'))
          : null,
      backgroundColor: widget.showAppBar ? null : Colors.transparent,
      body: FutureBuilder<bool>(
        future: _hasSavedChoices,
        builder: (context, saved) {
          if (saved.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load feature choices: ${saved.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!saved.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return BlocBuilder<StructureBloc, StructureState>(
            builder: (context, state) => _Overview(
              state: saved.data!
                  ? state
                  : state.copyWith(
                      featureToggles: const FeatureToggles.allOff(),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.state});
  final StructureState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start with the essentials. Enable more when your school is ready.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Text(
                    'ALWAYS ON',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .6,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const _CoreToolsCard(),
                  const SizedBox(height: 20),
                  Text(
                    'OPTIONAL MODULES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .6,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final category in _Category.values)
                    _CategoryCard(
                      category: category,
                      state: state,
                      onOpen: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _ModuleListScreen(
                            category: category,
                            state: state,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You can change these later from School settings.',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
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

class _CoreToolsCard extends StatelessWidget {
  const _CoreToolsCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.transparent,
              child: Icon(Icons.apartment_outlined, color: scheme.onSurface),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Core school tools',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Students, staff, academics, attendance, fees and messaging',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(Icons.check_circle, color: scheme.onSurface),
                const SizedBox(height: 2),
                const Text('Ready', style: TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.state,
    required this.onOpen,
  });
  final _Category category;
  final StructureState state;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final modules = _modules.where((m) => m.category == category).toList();
    final enabledCount = modules
        .where((m) => m.isEnabled(state.featureToggles))
        .length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.transparent,
                child: Icon(category.icon, color: scheme.onSurface),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      modules.map((m) => m.title).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outline),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  enabledCount == 0 ? 'Not enabled' : '$enabledCount enabled',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleListScreen extends StatelessWidget {
  const _ModuleListScreen({required this.category, required this.state});
  final _Category category;
  final StructureState state;

  @override
  Widget build(BuildContext context) {
    final modules = _modules.where((m) => m.category == category).toList();
    return Scaffold(
      appBar: AppBar(title: Text(category.label)),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: modules.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _ModuleRow(
            module: modules[index],
            enabled: modules[index].isEnabled(state.featureToggles),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    _ModuleDetailScreen(module: modules[index], state: state),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({
    required this.module,
    required this.enabled,
    required this.onTap,
  });
  final _ModuleDef module;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(module.icon, color: scheme.onSurface),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    module.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outline),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                enabled ? 'Enabled' : 'Off',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

/// Screen 2: one module's enable switch plus its "before you start"
/// readiness checklist. Disabling is always allowed - see [_DisableGuard]
/// for the data-loss warning shown only when the module actually has
/// dependent data or a dependent module still enabled.
class _ModuleDetailScreen extends StatefulWidget {
  const _ModuleDetailScreen({required this.module, required this.state});
  final _ModuleDef module;
  final StructureState state;

  @override
  State<_ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<_ModuleDetailScreen> {
  bool? _pendingValue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = widget.state;
    return Scaffold(
      appBar: AppBar(title: Text(widget.module.title)),
      body: Builder(
        builder: (context) {
          final currentValue = widget.module.isEnabled(state.featureToggles);
          final value = _pendingValue ?? currentValue;
          final readiness = widget.module.readiness(state);
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    children: [
                      Text(
                        'OPTIONAL MODULE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .6,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.module.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppCard(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.module.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      value
                                          ? 'Available to your school'
                                          : 'Not available to your school',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Switch(
                                    value: value,
                                    onChanged: (v) =>
                                        setState(() => _pendingValue = v),
                                  ),
                                  Text(
                                    value ? 'Enabled' : 'Disabled',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (readiness.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Before you start',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AppCard(
                          child: Column(
                            children: [
                              for (var i = 0; i < readiness.length; i++) ...[
                                if (i > 0) const Divider(height: 1),
                                _ReadinessRow(item: readiness[i]),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: scheme.outlineVariant),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'You can enable this now and finish setup later.',
                                style: TextStyle(fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Back to choices'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed:
                                _pendingValue == null ||
                                    _pendingValue == currentValue
                                ? null
                                : () => _save(context, state),
                            child: const Text('Save changes'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _save(BuildContext context, StructureState displayState) async {
    final target = _pendingValue!;
    if (!target) {
      final proceed = await _DisableGuard.confirm(
        context,
        module: widget.module,
        state: displayState,
      );
      if (proceed != true) return;
      if (!mounted) return;
    }
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    // Merge against the live bloc state, not `displayState` - while
    // unconfigured, `displayState.featureToggles` is the all-off display
    // substitute (see FeatureTogglesScreen), and writing that back verbatim
    // would silently turn off every other module a legacy default/consumer
    // still expected to read as true.
    final updated = widget.module.apply(bloc.state.featureToggles, target);
    bloc.add(UpdateFeatureTogglesRequested(updated, schoolId));
    setState(() => _pendingValue = null);
    if (context.mounted) Navigator.of(context).pop();
  }
}

/// Warns before disabling a module that either has data recorded against it
/// or is still required by another currently-enabled module - disabling
/// never deletes data, it only stops the module appearing for new use.
class _DisableGuard {
  static Future<bool?> confirm(
    BuildContext context, {
    required _ModuleDef module,
    required StructureState state,
  }) {
    final dependents = _modules
        .where(
          (m) =>
              m.key != module.key &&
              m.isEnabled(state.featureToggles) &&
              m
                  .readiness(state)
                  .any(
                    (r) => r.label.toLowerCase().contains(
                      module.title.toLowerCase(),
                    ),
                  ),
        )
        .toList();
    final hasData = switch (module.key) {
      'transport' => state.transportRoutes.isNotEmpty,
      'boarding' => state.hostels.isNotEmpty,
      _ => false,
    };
    if (dependents.isEmpty && !hasData) {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Turn off ${module.title}?'),
          content: const Text(
            'Your data is kept and nothing is deleted. You can turn it back on any time.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Turn off'),
            ),
          ],
        ),
      );
    }
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${module.title} is in use'),
        content: Text(
          [
            if (hasData) '${module.title} already has data recorded.',
            if (dependents.isNotEmpty)
              '${dependents.map((m) => m.title).join(', ')} depends on ${module.title}.',
            'Turning it off keeps existing data but hides it from new use.',
          ].join(' '),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Turn off anyway'),
          ),
        ],
      ),
    );
  }
}

class _ReadinessRow extends StatelessWidget {
  const _ReadinessRow({required this.item});
  final _ReadinessItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(item.icon, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(
            child: Text(item.label, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            item.done ? 'Done' : 'Set up later',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: item.done ? FontWeight.w700 : FontWeight.w500,
              color: item.done ? scheme.onSurface : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
