import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/error/failures.dart';

import '../../data/models/parent_access_invite_model.dart';
import '../../domain/repositories/parent_access_repository.dart';
import 'parents_access_state.dart';

/// Single Cubit backing both the Parents and Access codes tabs. Both tabs
/// are driven by the same `listParentAccessInvites` data - the only source
/// that already denormalizes parent name/masked phone/learner count/status
/// server-side. The Parents tab filters that list to linked parents; the
/// Access codes tab shows the full code-state detail. This avoids a second,
/// possibly-inconsistent data source joined against `parent_student_relationships`
/// (which carries no name/phone fields of its own).
class ParentsAccessCubit extends Cubit<ParentsAccessState> {
  final ParentAccessRepository repository;
  static const int pageSize = 25;

  ParentsAccessCubit({required this.repository})
    : super(const ParentsAccessState());

  Future<void> loadFirstPage() async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: () => null,
        isOffline: false,
        isPermissionDenied: false,
      ),
    );
    final result = await repository.listParentAccessInvites(
      pageSize: pageSize,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: () => failure.message,
          isOffline: failure is NetworkFailure,
          isPermissionDenied: failure is PermissionDeniedFailure,
        ),
      ),
      (page) => emit(_applyPage(page, replace: true)),
    );
  }

  Future<void> loadNextPage() async {
    if (state.nextCursor == null || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    final result = await repository.listParentAccessInvites(
      pageSize: pageSize,
      cursor: state.nextCursor,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingMore: false,
          actionError: () => failure.message,
        ),
      ),
      (page) => emit(_applyPage(page, replace: false)),
    );
  }

  ParentsAccessState _applyPage(
    ParentAccessInvitesPage page, {
    required bool replace,
  }) {
    return state.copyWith(
      isLoading: false,
      isLoadingMore: false,
      invites: replace ? page.rows : [...state.invites, ...page.rows],
      nextCursor: () => page.nextCursor,
      pendingCount: page.pendingCount,
      expiringSoonCount: page.expiringSoonCount,
    );
  }

  void setTab(ParentsAccessTab tab) {
    emit(state.copyWith(activeTab: tab));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setFilter(ParentsAccessFilter filter) {
    emit(state.copyWith(filter: filter));
  }

  Future<bool> revokeAccessCode(String inviteId) async {
    emit(
      state.copyWith(
        actionInFlight: true,
        actionError: () => null,
        actionSuccessMessage: () => null,
      ),
    );
    final result = await repository.revokeParentAccessCode(
      inviteId: inviteId,
    );
    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            actionInFlight: false,
            actionError: () => failure.message,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            actionInFlight: false,
            actionSuccessMessage: () => 'Access code revoked.',
          ),
        );
        loadFirstPage();
        return true;
      },
    );
  }

  Future<bool> reallocateLink({
    required String linkId,
    String? parentName,
    String? phoneNumber,
    required String reason,
  }) async {
    emit(
      state.copyWith(
        actionInFlight: true,
        actionError: () => null,
        actionSuccessMessage: () => null,
      ),
    );
    final result = await repository.reallocateParentLink(
      linkId: linkId,
      parentName: parentName,
      phoneNumber: phoneNumber,
      reason: reason,
    );
    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            actionInFlight: false,
            actionError: () => failure.message,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            actionInFlight: false,
            actionSuccessMessage: () => 'Parent link reallocated.',
          ),
        );
        loadFirstPage();
        return true;
      },
    );
  }

  void clearActionFeedback() {
    emit(
      state.copyWith(
        actionError: () => null,
        actionSuccessMessage: () => null,
      ),
    );
  }
}
