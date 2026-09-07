import 'package:equatable/equatable.dart';

import '../../domain/entities/parent_access_invite.dart';

enum ParentsAccessTab { parents, accessCodes }

enum ParentsAccessFilter { all, linked, pending, expiring }

/// One shared state for both tabs. status/loading is deliberately coarse
/// (no offline/permission-denied sub-states split out) because
/// [errorMessage]/[isOffline]/[isPermissionDenied] compose independently of
/// which page of data is showing - a screen only needs to know "are we
/// showing data, and if not, why".
class ParentsAccessState extends Equatable {
  final ParentsAccessTab activeTab;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool isOffline;
  final bool isPermissionDenied;

  final List<ParentAccessInvite> invites;
  final String? nextCursor;
  final int pendingCount;
  final int expiringSoonCount;

  /// Count of parents who have completed portal sign-up, from the server
  /// aggregate (not just this page).
  final int linkedParentCount;

  /// The tenant's configured maximum guardians per learner (people_policies,
  /// default 2). Surfaced in the info banner and enforced client-side in the
  /// Link Parent flow.
  final int maxGuardians;

  final String searchQuery;
  final ParentsAccessFilter filter;

  final bool actionInFlight;
  final String? actionError;
  final String? actionSuccessMessage;

  const ParentsAccessState({
    this.activeTab = ParentsAccessTab.parents,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.isOffline = false,
    this.isPermissionDenied = false,
    this.invites = const [],
    this.nextCursor,
    this.pendingCount = 0,
    this.expiringSoonCount = 0,
    this.linkedParentCount = 0,
    this.maxGuardians = 2,
    this.searchQuery = '',
    this.filter = ParentsAccessFilter.all,
    this.actionInFlight = false,
    this.actionError,
    this.actionSuccessMessage,
  });

  /// Server aggregate - the count of parents who have completed sign-up
  /// across the whole school, never a per-page count and never hard-coded.
  int get linkedParentsCount => linkedParentCount;

  List<ParentAccessInvite> get filteredRows {
    final query = searchQuery.trim().toLowerCase();
    return invites.where((invite) {
      final matchesQuery =
          query.isEmpty ||
          invite.parentName.toLowerCase().contains(query) ||
          invite.maskedPhone.toLowerCase().contains(query) ||
          invite.maskedEmail.toLowerCase().contains(query);
      if (!matchesQuery) return false;
      switch (filter) {
        case ParentsAccessFilter.all:
          return true;
        case ParentsAccessFilter.linked:
          return invite.isAccepted &&
              invite.status == ParentInviteStatus.active;
        case ParentsAccessFilter.pending:
          return invite.isPendingAcceptance;
        case ParentsAccessFilter.expiring:
          return invite.expiringSoon;
      }
    }).toList();
  }

  ParentsAccessState copyWith({
    ParentsAccessTab? activeTab,
    bool? isLoading,
    bool? isLoadingMore,
    String? Function()? errorMessage,
    bool? isOffline,
    bool? isPermissionDenied,
    List<ParentAccessInvite>? invites,
    String? Function()? nextCursor,
    int? pendingCount,
    int? expiringSoonCount,
    int? linkedParentCount,
    int? maxGuardians,
    String? searchQuery,
    ParentsAccessFilter? filter,
    bool? actionInFlight,
    String? Function()? actionError,
    String? Function()? actionSuccessMessage,
  }) {
    return ParentsAccessState(
      activeTab: activeTab ?? this.activeTab,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isOffline: isOffline ?? this.isOffline,
      isPermissionDenied: isPermissionDenied ?? this.isPermissionDenied,
      invites: invites ?? this.invites,
      nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
      pendingCount: pendingCount ?? this.pendingCount,
      expiringSoonCount: expiringSoonCount ?? this.expiringSoonCount,
      linkedParentCount: linkedParentCount ?? this.linkedParentCount,
      maxGuardians: maxGuardians ?? this.maxGuardians,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      actionInFlight: actionInFlight ?? this.actionInFlight,
      actionError: actionError != null ? actionError() : this.actionError,
      actionSuccessMessage: actionSuccessMessage != null
          ? actionSuccessMessage()
          : this.actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
    activeTab,
    isLoading,
    isLoadingMore,
    errorMessage,
    isOffline,
    isPermissionDenied,
    invites,
    nextCursor,
    pendingCount,
    expiringSoonCount,
    linkedParentCount,
    maxGuardians,
    searchQuery,
    filter,
    actionInFlight,
    actionError,
    actionSuccessMessage,
  ];
}
