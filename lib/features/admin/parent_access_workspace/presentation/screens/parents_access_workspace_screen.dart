import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/parent_offline/presentation/widgets/parent_offline_banner.dart';
import 'package:school_pulse/injection_container.dart' as di;

import '../../domain/entities/parent_access_invite.dart';
import '../cubit/parents_access_cubit.dart';
import '../cubit/parents_access_state.dart';
import '../responsive.dart';
import '../widgets/access_code_row_tile.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/info_banner.dart';
import '../widgets/parent_row_tile.dart';
import '../widgets/summary_count_cards.dart';
import '../widgets/web/codes_needing_attention_panel.dart';
import '../widgets/web/parent_access_data_table.dart';
import '../widgets/web/parent_access_pagination_footer.dart';
import '../widgets/web/parent_access_toolbar.dart';

/// Two-tab "Parents & access" workspace, replacing the legacy
/// AccessCodesScreen at both of its former route registrations. One shared
/// ParentsAccessCubit, three responsive presentation trees chosen by width.
class ParentsAccessWorkspaceScreen extends StatelessWidget {
  const ParentsAccessWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ParentsAccessCubit>()..loadFirstPage(),
      child: const _WorkspaceView(),
    );
  }
}

class _WorkspaceView extends StatefulWidget {
  const _WorkspaceView();

  @override
  State<_WorkspaceView> createState() => _WorkspaceViewState();
}

class _WorkspaceViewState extends State<_WorkspaceView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  ParentAccessSortColumn _sortColumn = ParentAccessSortColumn.name;
  bool _sortAscending = true;
  bool _bannerDismissed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      context.read<ParentsAccessCubit>().setTab(
        _tabController.index == 0
            ? ParentsAccessTab.parents
            : ParentsAccessTab.accessCodes,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _isSchoolAdmin {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return false;
    return auth.user.roles.contains(UserRole.schoolAdmin);
  }

  List<ParentAccessInvite> _sortedRows(List<ParentAccessInvite> rows) {
    final sorted = [...rows];
    int compare(ParentAccessInvite a, ParentAccessInvite b) {
      switch (_sortColumn) {
        case ParentAccessSortColumn.name:
          return a.parentName.compareTo(b.parentName);
        case ParentAccessSortColumn.phone:
          return a.maskedPhone.compareTo(b.maskedPhone);
        case ParentAccessSortColumn.learners:
          return a.learnerCount.compareTo(b.learnerCount);
        case ParentAccessSortColumn.status:
          return a.status.index.compareTo(b.status.index);
      }
    }

    sorted.sort(_sortAscending ? compare : (a, b) => compare(b, a));
    return sorted;
  }

  void _openAddParentWizard(BuildContext context, String schoolId) {
    // Push the router route (not a bare MaterialPageRoute) so the Link Parent
    // flow renders inside AdminShell's content pane - the canonical sidebar
    // (desktop/tablet) and the Parents bottom-nav tab (mobile) stay mounted
    // and selected across every step, Back, and the review page.
    context.push('/staff/admin/parents/link');
  }

  @override
  Widget build(BuildContext context) {
    final schoolId = _currentSchoolId(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          if (isParentAccessWeb(width)) {
            return _WebLayout(
              tabController: _tabController,
              sortColumn: _sortColumn,
              sortAscending: _sortAscending,
              onSort: (column) {
                setState(() {
                  if (_sortColumn == column) {
                    _sortAscending = !_sortAscending;
                  } else {
                    _sortColumn = column;
                    _sortAscending = true;
                  }
                });
              },
              sortRows: _sortedRows,
              canReallocate: _isSchoolAdmin,
              onAddParent: () => _openAddParentWizard(context, schoolId),
              bannerDismissed: _bannerDismissed,
              onDismissBanner: () => setState(() => _bannerDismissed = true),
            );
          }
          if (isParentAccessTablet(width)) {
            return _TabletLayout(
              tabController: _tabController,
              canReallocate: _isSchoolAdmin,
              onAddParent: () => _openAddParentWizard(context, schoolId),
              bannerDismissed: _bannerDismissed,
              onDismissBanner: () => setState(() => _bannerDismissed = true),
            );
          }
          return _PhoneLayout(
            tabController: _tabController,
            canReallocate: _isSchoolAdmin,
            onAddParent: () => _openAddParentWizard(context, schoolId),
            bannerDismissed: _bannerDismissed,
            onDismissBanner: () => setState(() => _bannerDismissed = true),
          );
        },
      ),
    );
  }

  String _currentSchoolId(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) return auth.user.schoolId;
    return '';
  }
}

// ---------------------------------------------------------------------------
// Shared state widgets (loading / empty / error / offline / permission
// denied) - used by all three layouts.
// ---------------------------------------------------------------------------

class _StateBody extends StatelessWidget {
  final ParentsAccessState state;
  final Widget child;

  const _StateBody({required this.state, required this.child});

  @override
  Widget build(BuildContext context) {
    if (state.isPermissionDenied) {
      return const _CenteredMessage(
        icon: Icons.lock_outline,
        title: 'You do not have permission',
        message: 'Ask a school admin to grant you parent access management.',
      );
    }
    if (state.isLoading && state.invites.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.invites.isEmpty) {
      return _CenteredMessage(
        icon: state.isOffline ? Icons.wifi_off_outlined : Icons.error_outline,
        title: state.isOffline
            ? 'You are offline'
            : 'Could not load parents',
        message: state.errorMessage!,
        onRetry: () => context.read<ParentsAccessCubit>().retry(),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.isOffline) const ParentOfflineBanner(),
        Expanded(child: child),
      ],
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const _CenteredMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.textMuted(context)),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted(context), fontSize: 13),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyRows extends StatelessWidget {
  final String message;

  const _EmptyRows({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: AppColors.textMuted(context), fontSize: 13),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Phone layout
// ---------------------------------------------------------------------------

class _PhoneLayout extends StatelessWidget {
  final TabController tabController;
  final bool canReallocate;
  final VoidCallback onAddParent;
  final bool bannerDismissed;
  final VoidCallback onDismissBanner;

  const _PhoneLayout({
    required this.tabController,
    required this.canReallocate,
    required this.onAddParent,
    required this.bannerDismissed,
    required this.onDismissBanner,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ParentsAccessCubit, ParentsAccessState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Parents & access',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          Text(
                            'Parent links and sign-in access',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => showSearch(
                        context: context,
                        delegate: _ParentAccessSearchDelegate(),
                      ),
                      icon: const Icon(Icons.search),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () async {
                        final selected = await showParentAccessFilterSheet(
                          context,
                          current: state.filter,
                        );
                        if (selected != null && context.mounted) {
                          context.read<ParentsAccessCubit>().setFilter(selected);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: onAddParent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: AppColors.background(context),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add / link parent'),
                ),
              ),
              const SizedBox(height: 12),
              TabBar(
                controller: tabController,
                labelColor: AppColors.textPrimary(context),
                tabs: const [Tab(text: 'Parents'), Tab(text: 'Access codes')],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: SummaryCountCards(
                  data: SummaryCountData(
                    linkedParents: state.linkedParentsCount,
                    codesPending: state.pendingCount,
                    expiringSoon: state.expiringSoonCount,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TextField(
                  onChanged: (q) => context.read<ParentsAccessCubit>().setSearchQuery(q),
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone, or learner...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surfaceContainer(context),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border(context)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ParentAccessFilterChips(
                    selected: state.filter,
                    onChanged: (f) => context.read<ParentsAccessCubit>().setFilter(f),
                  ),
                ),
              ),
              if (!bannerDismissed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: ParentAccessInfoBanner(
                    onDismiss: onDismissBanner,
                    maxGuardians: state.maxGuardians,
                  ),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: _StateBody(
                  state: state,
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      _RowListView(rows: state.filteredRows, tab: ParentsAccessTab.parents, canReallocate: canReallocate),
                      _RowListView(rows: state.filteredRows, tab: ParentsAccessTab.accessCodes, canReallocate: canReallocate),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RowListView extends StatelessWidget {
  final List<ParentAccessInvite> rows;
  final ParentsAccessTab tab;
  final bool canReallocate;

  const _RowListView({
    required this.rows,
    required this.tab,
    required this.canReallocate,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const _EmptyRows(message: 'No parents match your search or filter.');
    }
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border(context)),
      itemBuilder: (context, index) {
        final invite = rows[index];
        if (tab == ParentsAccessTab.parents) {
          return ParentRowTile(
            invite: invite,
            onTap: () => context.push(
              '/staff/admin/parents/${invite.inviteId}',
            ),
          );
        }
        return AccessCodeRowTile(
          invite: invite,
          canRevoke: true,
          canReallocate: canReallocate,
          onRevoke: () => _confirmRevoke(context, invite),
          onReallocate: canReallocate ? () => _confirmReallocate(context, invite) : null,
        );
      },
    );
  }
}

Future<void> _confirmRevoke(BuildContext context, ParentAccessInvite invite) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Revoke access code?'),
      content: Text('This immediately invalidates the code issued to ${invite.parentName}.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text('Revoke', style: TextStyle(color: AppColors.danger(dialogContext))),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final cubit = context.read<ParentsAccessCubit>();
  final success = await cubit.revokeAccessCode(invite.inviteId);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(success ? 'Access code revoked.' : (cubit.state.actionError ?? 'Could not revoke the code.'))),
  );
}

Future<void> _confirmReallocate(BuildContext context, ParentAccessInvite invite) async {
  final reasonController = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Reallocate parent link?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This revokes ${invite.parentName}\'s current link. Only a school admin may do this.'),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            decoration: const InputDecoration(labelText: 'Reason', hintText: 'Required'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Continue')),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  if (reasonController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A reason is required to reallocate.')));
    return;
  }
  final cubit = context.read<ParentsAccessCubit>();
  final success = await cubit.reallocateLink(linkId: invite.inviteId, reason: reasonController.text.trim());
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(success ? 'Parent link reallocated.' : (cubit.state.actionError ?? 'Could not reallocate.'))),
  );
}

class _ParentAccessSearchDelegate extends SearchDelegate<void> {
  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
  ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(onPressed: () => close(context, null), icon: const Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) => const SizedBox.shrink();

  @override
  Widget buildSuggestions(BuildContext context) {
    context.read<ParentsAccessCubit>().setSearchQuery(query);
    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Tablet layout - same rows, adaptive two-column.
// ---------------------------------------------------------------------------

class _TabletLayout extends StatelessWidget {
  final TabController tabController;
  final bool canReallocate;
  final VoidCallback onAddParent;
  final bool bannerDismissed;
  final VoidCallback onDismissBanner;

  const _TabletLayout({
    required this.tabController,
    required this.canReallocate,
    required this.onAddParent,
    required this.bannerDismissed,
    required this.onDismissBanner,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ParentsAccessCubit, ParentsAccessState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Parents & access',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: onAddParent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
                        foregroundColor: AppColors.background(context),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add / link parent'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TabBar(
                  controller: tabController,
                  isScrollable: true,
                  labelColor: AppColors.textPrimary(context),
                  tabs: const [Tab(text: 'Parents'), Tab(text: 'Access codes')],
                ),
                const SizedBox(height: 12),
                SummaryCountCards(
                  data: SummaryCountData(
                    linkedParents: state.linkedParentsCount,
                    codesPending: state.pendingCount,
                    expiringSoon: state.expiringSoonCount,
                  ),
                ),
                if (!bannerDismissed) ...[
                  const SizedBox(height: 12),
                  ParentAccessInfoBanner(
                    onDismiss: onDismissBanner,
                    maxGuardians: state.maxGuardians,
                  ),
                ],
                const SizedBox(height: 12),
                Expanded(
                  child: _StateBody(
                    state: state,
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3.0,
                          ),
                          itemCount: state.filteredRows.length,
                          itemBuilder: (context, index) => ParentRowTile(
                            invite: state.filteredRows[index],
                            onTap: () => context.push(
                              '/staff/admin/parents/'
                              '${state.filteredRows[index].inviteId}',
                            ),
                          ),
                        ),
                        GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3.4,
                          ),
                          itemCount: state.filteredRows.length,
                          itemBuilder: (context, index) => AccessCodeRowTile(
                            invite: state.filteredRows[index],
                            canRevoke: true,
                            canReallocate: canReallocate,
                            onRevoke: () => _confirmRevoke(context, state.filteredRows[index]),
                            onReallocate: canReallocate
                                ? () => _confirmReallocate(context, state.filteredRows[index])
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Web layout
// ---------------------------------------------------------------------------

class _WebLayout extends StatelessWidget {
  final TabController tabController;
  final ParentAccessSortColumn sortColumn;
  final bool sortAscending;
  final ValueChanged<ParentAccessSortColumn> onSort;
  final List<ParentAccessInvite> Function(List<ParentAccessInvite>) sortRows;
  final bool canReallocate;
  final VoidCallback onAddParent;
  final bool bannerDismissed;
  final VoidCallback onDismissBanner;

  const _WebLayout({
    required this.tabController,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
    required this.sortRows,
    required this.canReallocate,
    required this.onAddParent,
    required this.bannerDismissed,
    required this.onDismissBanner,
  });

  @override
  Widget build(BuildContext context) {
    // No inner side rail: this body renders inside AdminWebShell's content
    // pane, which already provides the one canonical admin sidebar. A second
    // rail here was duplicate navigation.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: BlocBuilder<ParentsAccessCubit, ParentsAccessState>(
            builder: (context, state) {
              final rows = sortRows(state.filteredRows);
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Parents & access',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Parent links and sign-in access',
                      style: TextStyle(color: AppColors.textMuted(context)),
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                      controller: tabController,
                      isScrollable: true,
                      labelColor: AppColors.textPrimary(context),
                      tabs: const [Tab(text: 'Parents'), Tab(text: 'Access codes')],
                    ),
                    const SizedBox(height: 16),
                    SummaryCountCards(
                      data: SummaryCountData(
                        linkedParents: state.linkedParentsCount,
                        codesPending: state.pendingCount,
                        expiringSoon: state.expiringSoonCount,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ParentAccessToolbar(
                      selectedFilter: state.filter,
                      onFilterChanged: (f) => context.read<ParentsAccessCubit>().setFilter(f),
                      onSearchChanged: (q) => context.read<ParentsAccessCubit>().setSearchQuery(q),
                      onAddParent: onAddParent,
                    ),
                    if (!bannerDismissed) ...[
                      const SizedBox(height: 12),
                      ParentAccessInfoBanner(
                    onDismiss: onDismissBanner,
                    maxGuardians: state.maxGuardians,
                  ),
                    ],
                    const SizedBox(height: 16),
                    Expanded(
                      child: _StateBody(
                        state: state,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: rows.isEmpty
                                        ? const _EmptyRows(message: 'No parents match your search or filter.')
                                        : SingleChildScrollView(
                                            child: ParentAccessDataTable(
                                              rows: rows,
                                              sortColumn: sortColumn,
                                              sortAscending: sortAscending,
                                              onSort: onSort,
                                              onRowTap: (invite) => context.push(
                                                '/staff/admin/parents/'
                                                '${invite.inviteId}',
                                              ),
                                            ),
                                          ),
                                  ),
                                  if (rows.isNotEmpty)
                                    ParentAccessPaginationFooter(
                                      shownCount: rows.length,
                                      totalCount: state.invites.length,
                                      pageSize: ParentsAccessCubit.pageSize,
                                      hasNextPage: state.nextCursor != null,
                                      isLoadingMore: state.isLoadingMore,
                                      onLoadMore: () => context.read<ParentsAccessCubit>().loadNextPage(),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            CodesNeedingAttentionPanel(
                              expiringSoonCount: state.expiringSoonCount,
                              revokedCount: state.invites
                                  .where((i) => i.status == ParentInviteStatus.revoked)
                                  .length,
                              onViewAccessCodes: () => tabController.animateTo(1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
