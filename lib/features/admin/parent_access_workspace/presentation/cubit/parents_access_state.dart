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
    this.searchQuery = '',
    this.filter = ParentsAccessFilter.all,
    this.actionInFlight = false,
    this.actionError,
    this.actionSuccessMessage,
  });

  int get linkedParentsCount =>
      invites.where((i) => i.status == ParentInviteStatus.active).length;

  List<ParentAccessInvite> get filteredRows {
    final query = searchQuery.trim().toLowerCase();
    return invites.where((invite) {
      final matchesQuery =
          query.isEmpty ||
          invite.parentName.toLowerCase().contains(query) ||
          invite.maskedPhone.toLowerCase().contains(query);
      if (!matchesQuery) return false;
      switch (filter) {
        case ParentsAccessFilter.all:
          return true;
        case ParentsAccessFilter.linked:
          return invite.status == ParentInviteStatus.active &&
              !invite.expiringSoon;
        case ParentsAccessFilter.pending:
          return invite.status == ParentInviteStatus.active;
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
    searchQuery,
    filter,
    actionInFlight,
    actionError,
    actionSuccessMessage,
  ];
}
