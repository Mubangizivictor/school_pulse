import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/models/responsibility_catalog.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

import '../add_staff_wizard_controller.dart';
import '../models/role_assignment_draft.dart';
import '../role_config/role_assignment_config_registry.dart';
import '../role_config/role_config_form.dart';

/// Stage 3 - Roles & responsibilities: "What will this person do?" Internally
/// holds three screens - a searchable/filterable responsibility catalogue
/// picker (desktop: category rail + card grid + selected summary; mobile:
/// search + category chips + expandable category cards), a per-role scope
/// configuration screen for responsibilities that map to a system role
/// needing scope ("Role N of M"), and a final roles summary.
class Stage03Roles extends StatefulWidget {
  final VoidCallback onSaveDraft;

  const Stage03Roles({super.key, required this.onSaveDraft});

  @override
  State<Stage03Roles> createState() => _Stage03RolesState();
}

class _Stage03RolesState extends State<Stage03Roles> {
  final _structureRepository = di.sl<StructureRepository>();
  List<String> _classNames = [];
  List<String> _subjectNames = [];
  StreamSubscription? _classesSub;
  StreamSubscription? _subjectsSub;
  String _query = '';
  String _selectedCategory = 'All';
  final Set<String> _expandedMobileCategories = {};

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';
    _classesSub = _structureRepository.watchClasses(schoolId).listen((classes) {
      if (mounted) {
        setState(() => _classNames = classes.map((c) => c.name).toList());
      }
    });
    _subjectsSub = _structureRepository.watchSubjects(schoolId).listen((
      subjects,
    ) {
      if (mounted) {
        setState(() => _subjectNames = subjects.map((s) => s.name).toList());
      }
    });
  }

  @override
  void dispose() {
    _classesSub?.cancel();
    _subjectsSub?.cancel();
    super.dispose();
  }

  List<Responsibility> get _filtered {
    final q = _query.trim().toLowerCase();
    return kResponsibilityCatalog.where((r) {
      final matchesCategory =
          _selectedCategory == 'All' || r.category == _selectedCategory;
      final matchesQuery =
          q.isEmpty ||
          r.title.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    switch (controller.rolesSubStep) {
      case RolesSubStep.select:
        return ResponsiveBuilder(
          builder: (context, layout) => layout == ResponsiveLayout.desktop
              ? _buildSelectDesktop(controller)
              : _buildSelectMobile(controller),
        );
      case RolesSubStep.configure:
        return _buildConfigure(controller);
      case RolesSubStep.summary:
        return _buildSummary(controller);
    }
  }

  // ---------------------------------------------------------------------
  // Mobile: search field, horizontal category chips, selected-role chips,
  // expandable category cards of touch-friendly role cards.
  // ---------------------------------------------------------------------
  Widget _buildSelectMobile(AddStaffWizardController controller) {
    final draft = controller.draft;
    final categories = ['All', ...kResponsibilityCategories];

    return WizardStageScaffold(
      title: 'Add staff',
      stageLabels: kWizardStageLabels,
      currentStageIndex: stageIndexFor(WizardStage.roles),
      onBack: () => controller.back(),
      onSaveDraft: widget.onSaveDraft,
      footer: WizardFooterButtons(
        backLabel: 'Back',
        nextLabel: 'Continue to account access',
        onBack: () => controller.back(),
        onNext: draft.rolesSelected ? () => controller.next() : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WizardStageHeading(
            title: 'What will this person do?',
            subtitle:
                'Choose one or more responsibilities. Access is set next.',
          ),
          const SizedBox(height: 16),
          AppSearchField(
            hintText: 'Search roles or categories...',
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final category = categories[i];
                final selected = category == _selectedCategory;
                return _FilterChip(
                  label: category,
                  selected: selected,
                  onTap: () => setState(() => _selectedCategory = category),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _SelectedSummaryRow(
            draft: draft,
            onClearAll: controller.clearAllResponsibilities,
            onRemove: controller.toggleResponsibility,
          ),
          const SizedBox(height: 6),
          if (_filtered.isEmpty)
            _NoResultsState(query: _query)
          else if (_selectedCategory == 'All')
            ...kResponsibilityCategories.map((category) {
              final roles = responsibilitiesByCategory[category]!
                  .where(_filtered.contains)
                  .toList();
              if (roles.isEmpty) return const SizedBox.shrink();
              return _MobileCategoryCard(
                category: category,
                roles: roles,
                expanded: _expandedMobileCategories.contains(category),
                onToggle: () => setState(() {
                  if (_expandedMobileCategories.contains(category)) {
                    _expandedMobileCategories.remove(category);
                  } else {
                    _expandedMobileCategories.add(category);
                  }
                }),
                selectedIds: draft.selectedResponsibilityIds,
                onTapRole: (id) => controller.toggleResponsibility(id),
              );
            })
          else
            Column(
              children: _filtered
                  .map(
                    (r) => _MobileRoleCard(
                      responsibility: r,
                      selected: draft.selectedResponsibilityIds.contains(r.id),
                      onTap: () => controller.toggleResponsibility(r.id),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 12),
          _AddCustomRoleButton(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Desktop/tablet: left category rail with counts + search, main role-card
  // grid for the selected category, right selected-responsibilities summary.
  // ---------------------------------------------------------------------
  Widget _buildSelectDesktop(AddStaffWizardController controller) {
    final draft = controller.draft;
    final categoryForGrid = _selectedCategory == 'All'
        ? kResponsibilityCategories.first
        : _selectedCategory;
    final gridRoles = _query.trim().isNotEmpty
        ? _filtered
        : responsibilitiesByCategory[categoryForGrid] ?? const [];

    return WizardStageScaffold(
      title: 'Add staff',
      stageLabels: kWizardStageLabels,
      currentStageIndex: stageIndexFor(WizardStage.roles),
      onBack: () => controller.back(),
      onSaveDraft: widget.onSaveDraft,
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      footer: WizardFooterButtons(
        backLabel: 'Back',
        nextLabel: 'Continue to account access',
        onBack: () => controller.back(),
        onNext: draft.rolesSelected ? () => controller.next() : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WizardStageHeading(
            title: 'What will this person do?',
            subtitle:
                "Choose one or more responsibilities. You'll set their access scope next.",
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 640,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 260,
                  child: _CategoryRail(
                    selectedCategory: _query.trim().isEmpty
                        ? categoryForGrid
                        : null,
                    query: _query,
                    onQueryChanged: (v) => setState(() => _query = v),
                    onCategorySelected: (c) =>
                        setState(() => _selectedCategory = c),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RoleGrid(
                    category: _query.trim().isNotEmpty
                        ? 'Search results'
                        : categoryForGrid,
                    roles: gridRoles,
                    selectedIds: draft.selectedResponsibilityIds,
                    onTapRole: (id) => controller.toggleResponsibility(id),
                    query: _query,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 300,
                  child: _SelectedResponsibilitiesPanel(
                    draft: draft,
                    onRemove: controller.toggleResponsibility,
                    onClearAll: controller.clearAllResponsibilities,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigure(AddStaffWizardController controller) {
    final roles = controller.rolesNeedingConfig;

    if (roles.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => controller.next());
      return const Scaffold(body: Center(child: SchoolPulseLoader()));
    }

    final index = controller.configureRoleIndex.clamp(0, roles.length - 1);
    final role = roles[index];
    final spec = RoleAssignmentConfigRegistry.forRole(role);
    final draft = controller.draft.roleConfigs.putIfAbsent(
      role,
      () => RoleAssignmentDraft(role: role),
    );

    return WizardStageScaffold(
      title: 'Add staff',
      stageLabels: kWizardStageLabels,
      currentStageIndex: stageIndexFor(WizardStage.roles),
      onBack: () => controller.back(),
      onSaveDraft: widget.onSaveDraft,
      footer: WizardFooterButtons(
        backLabel: 'Back',
        nextLabel: index < roles.length - 1 ? 'Next role' : 'Continue',
        onBack: () => controller.back(),
        onNext: () => controller.next(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Role ${index + 1} of ${roles.length}',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          WizardStageHeading(
            title: UserRoleDisplay.name(role),
            subtitle:
                'Set the scope for this role. You can add or edit assignments as needed.',
          ),
          const SizedBox(height: 20),
          RoleConfigForm(
            draft: draft,
            spec: spec,
            classNames: _classNames,
            subjectNames: _subjectNames,
            academicYearId: null,
            onChanged: () => controller.notifyDraftChanged(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textMuted(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This staff member can access only the classes and subjects assigned above.',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(AddStaffWizardController controller) {
    final draft = controller.draft;
    return WizardStageScaffold(
      title: 'Add staff',
      stageLabels: kWizardStageLabels,
      currentStageIndex: stageIndexFor(WizardStage.roles),
      onBack: () => controller.back(),
      onSaveDraft: widget.onSaveDraft,
      footer: WizardFooterButtons(
        backLabel: 'Back',
        nextLabel: 'Continue',
        onBack: () => controller.back(),
        onNext: () => controller.next(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WizardStageHeading(
            title: 'Assigned responsibilities',
            subtitle:
                'Review the responsibilities and scope for this staff member.',
          ),
          const SizedBox(height: 16),
          ...draft.selectedResponsibilityIds.map((id) {
            final r = responsibilityById[id];
            if (r == null) return const SizedBox.shrink();
            final config = r.mappedRole != null
                ? draft.roleConfigs[r.mappedRole]
                : null;
            final spec = r.mappedRole != null
                ? RoleAssignmentConfigRegistry.forRole(r.mappedRole!)
                : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border(context)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                r.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              if (r.sensitive) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.shield_outlined,
                                  size: 14,
                                  color: AppColors.danger(context),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r.mappedRole != null
                                ? _summaryFor(r.mappedRole!, config)
                                : r.description,
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (spec != null && !spec.isEmpty)
                      TextButton(
                        onPressed: () => controller.editRole(r.mappedRole!),
                        child: const Text('Edit'),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Add another responsibility',
            icon: Icons.add,
            onPressed: () => controller.goToStage(WizardStage.roles),
          ),
        ],
      ),
    );
  }

  String _summaryFor(UserRole role, RoleAssignmentDraft? config) {
    if (config == null) return 'No additional configuration.';
    if (role == UserRole.classTeacher) {
      return config.className != null
          ? 'Class: ${config.className}'
          : 'Class not selected yet.';
    }
    if (role == UserRole.subjectTeacher) {
      if (config.subjectAssignments.isEmpty) return 'No subjects assigned yet.';
      return config.subjectAssignments
          .map((s) => '${s.subjectName} (${s.className})')
          .join(', ');
    }
    final parts = <String>[
      if (config.departmentId != null) 'Dept: ${config.departmentId}',
      if (config.dormitoryWing != null) 'Wing: ${config.dormitoryWing}',
      if (config.routeId != null) 'Route: ${config.routeId}',
      if (config.facilityId != null) 'Facility: ${config.facilityId}',
      if (config.approvalScope != null) 'Scope: ${config.approvalScope}',
    ];
    return parts.isEmpty ? 'No additional configuration.' : parts.join(' | ');
  }
}

// ===========================================================================
// Desktop widgets
// ===========================================================================

class _CategoryRail extends StatelessWidget {
  final String? selectedCategory;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onCategorySelected;

  const _CategoryRail({
    required this.selectedCategory,
    required this.query,
    required this.onQueryChanged,
    required this.onCategorySelected,
  });

  static const _icons = {
    'Leadership': Icons.workspace_premium_outlined,
    'Teaching & learning': Icons.school_outlined,
    'Learner wellbeing & safeguarding': Icons.shield_outlined,
    'Administration & finance': Icons.account_balance_outlined,
    'Operations & facilities': Icons.build_outlined,
    'Boarding, transport & gate': Icons.directions_bus_outlined,
    'Health, catering & welfare': Icons.favorite_outline,
    'Co-curricular, faith & community': Icons.groups_outlined,
    'Library, ICT & digital learning': Icons.laptop_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSearchField(
          hintText: 'Search roles or categories...',
          onChanged: onQueryChanged,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: kResponsibilityCategories.map((category) {
              final count = responsibilitiesByCategory[category]!.length;
              final selected = category == selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onCategorySelected(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.surfaceContainer(context)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: selected
                          ? Border.all(color: AppColors.primary(context))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _icons[category] ?? Icons.category_outlined,
                          size: 18,
                          color: selected
                              ? AppColors.textPrimary(context)
                              : AppColors.textMuted(context),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? AppColors.textPrimary(context)
                                  : AppColors.textMuted(context),
                            ),
                          ),
                        ),
                        Text(
                          '$count roles',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RoleGrid extends StatelessWidget {
  final String category;
  final List<Responsibility> roles;
  final Set<String> selectedIds;
  final ValueChanged<String> onTapRole;
  final String query;

  const _RoleGrid({
    required this.category,
    required this.roles,
    required this.selectedIds,
    required this.onTapRole,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              Text(
                '${roles.length} roles',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: roles.isEmpty
                ? _NoResultsState(query: query)
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.6,
                        ),
                    itemCount: roles.length,
                    itemBuilder: (context, i) {
                      final r = roles[i];
                      return _DesktopRoleCard(
                        responsibility: r,
                        selected: selectedIds.contains(r.id),
                        onTap: () => onTapRole(r.id),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          _AddCustomRoleButton(),
        ],
      ),
    );
  }
}

class _DesktopRoleCard extends StatelessWidget {
  final Responsibility responsibility;
  final bool selected;
  final VoidCallback onTap;

  const _DesktopRoleCard({
    required this.responsibility,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      showShadow: false,
      borderColor: selected ? AppColors.primary(context) : null,
      borderWidth: selected ? 1.6 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        responsibility.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    if (responsibility.sensitive)
                      Icon(
                        Icons.shield_outlined,
                        size: 13,
                        color: AppColors.danger(context),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  responsibility.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            selected ? Icons.check_box : Icons.check_box_outline_blank,
            size: 20,
            color: selected
                ? AppColors.primary(context)
                : AppColors.border(context),
          ),
        ],
      ),
    );
  }
}

class _SelectedResponsibilitiesPanel extends StatelessWidget {
  final dynamic draft;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  const _SelectedResponsibilitiesPanel({
    required this.draft,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final Set<String> selectedIds = draft.selectedResponsibilityIds;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Selected responsibilities',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${selectedIds.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              if (selectedIds.isNotEmpty)
                TextButton(
                  onPressed: onClearAll,
                  child: const Text('Clear all'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'These responsibilities will be linked to access permissions in the next step.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: selectedIds.isEmpty
                ? Center(
                    child: Text(
                      'No responsibilities selected yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  )
                : ListView(
                    children: selectedIds.map((id) {
                      final r = responsibilityById[id];
                      if (r == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  r.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => onRemove(id),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.textMuted(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.textMuted(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Access is configured in the next step. You'll choose what parts of School Pulse they can access based on these responsibilities.",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Mobile widgets
// ===========================================================================

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary(context)
              : AppColors.surfaceContainer(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary(context)
                : AppColors.border(context),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : AppColors.textPrimary(context),
          ),
        ),
      ),
    );
  }
}

class _SelectedSummaryRow extends StatelessWidget {
  final dynamic draft;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  const _SelectedSummaryRow({
    required this.draft,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final Set<String> selectedIds = draft.selectedResponsibilityIds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selectedIds.length} selected',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (selectedIds.isNotEmpty)
              TextButton(onPressed: onClearAll, child: const Text('Clear all')),
          ],
        ),
        if (selectedIds.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedIds.map((id) {
              final r = responsibilityById[id];
              if (r == null) return const SizedBox.shrink();
              return Chip(
                label: Text(r.title, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => onRemove(id),
                backgroundColor: AppColors.surfaceContainer(context),
                side: BorderSide(color: AppColors.border(context)),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _MobileCategoryCard extends StatelessWidget {
  final String category;
  final List<Responsibility> roles;
  final bool expanded;
  final VoidCallback onToggle;
  final Set<String> selectedIds;
  final ValueChanged<String> onTapRole;

  const _MobileCategoryCard({
    required this.category,
    required this.roles,
    required this.expanded,
    required this.onToggle,
    required this.selectedIds,
    required this.onTapRole,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCount = roles.where((r) => selectedIds.contains(r.id)).length;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                  if (selectedCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '$selectedCount selected',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  Text(
                    '${roles.length} roles',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: AppColors.textMuted(context),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: roles
                    .map(
                      (r) => _MobileRoleCard(
                        responsibility: r,
                        selected: selectedIds.contains(r.id),
                        onTap: () => onTapRole(r.id),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _MobileRoleCard extends StatelessWidget {
  final Responsibility responsibility;
  final bool selected;
  final VoidCallback onTap;

  const _MobileRoleCard({
    required this.responsibility,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.surfaceContainer(context)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? AppColors.primary(context)
                  : AppColors.border(context),
              width: selected ? 1.4 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            responsibility.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        if (responsibility.sensitive)
                          Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: AppColors.danger(context),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      responsibility.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                size: 22,
                color: selected
                    ? AppColors.primary(context)
                    : AppColors.border(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Shared
// ===========================================================================

class _NoResultsState extends StatelessWidget {
  final String query;

  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: EmptyState(
        icon: Icons.search_off,
        title: 'No roles found',
        message: query.trim().isEmpty
            ? 'No roles in this category yet.'
            : 'No roles match "$query". Try a different search term or add a custom role.',
      ),
    );
  }
}

class _AddCustomRoleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddCustomRoleComingSoon(context),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add custom role'),
      ),
    );
  }

  void _showAddCustomRoleComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Custom roles are coming soon. For now, pick the closest match from the catalogue.",
        ),
      ),
    );
  }
}
