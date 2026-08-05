import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/repositories/notification_repository.dart';
import 'notification_center_event.dart';
import 'notification_center_state.dart';

/// Drives the notification centre.
///
/// Holds one live subscription to the repository stream and one to the counts
/// stream, both re-established whenever the filter changes. All mutations are
/// fire-and-forget against the repository: it applies them to the local cache
/// first, and the resulting cache write flows back through the stream, so the
/// UI updates without the bloc hand-patching its own list.
class NotificationCenterBloc
    extends Bloc<NotificationCenterEvent, NotificationCenterState> {
  final NotificationRepository repository;

  StreamSubscription<NotificationPage>? _itemsSub;
  StreamSubscription<NotificationCounts>? _countsSub;

  String? _schoolId;
  String? _userId;

  /// Cursor for the next page, held outside state because it is plumbing
  /// rather than something the UI renders.
  DateTime? _cursor;

  NotificationCenterBloc({required this.repository})
    : super(const NotificationCenterState()) {
    on<NotificationCenterStarted>(_onStarted);
    on<NotificationCenterRefreshed>(_onRefreshed);
    on<NotificationCenterLoadedMore>(_onLoadedMore);
    on<NotificationCenterFilterChanged>(_onFilterChanged);
    // Debounced so typing in the search box does not fire a query per
    // keystroke - each one would otherwise be a billed Firestore read.
    on<NotificationCenterSearched>(
      _onSearched,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 300))
          .switchMap(mapper),
    );
    on<NotificationCenterDataReceived>(_onDataReceived);
    on<NotificationCountsReceived>(_onCountsReceived);

    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationMarkedUnread>(_onMarkedUnread);
    on<NotificationOpened>(_onOpened);
    on<NotificationAcknowledged>(_onAcknowledged);
    on<NotificationPinToggled>(_onPinToggled);
    on<NotificationArchiveToggled>(_onArchiveToggled);
    on<NotificationDeleted>(_onDeleted);
    on<NotificationAllMarkedRead>(_onAllMarkedRead);
    on<NotificationAllArchived>(_onAllArchived);
    on<NotificationTransientCleared>(_onTransientCleared);
  }

  bool get _isReady => _schoolId != null && _userId != null;

  NotificationQuery _queryFrom(
    NotificationCenterState state, {
    DateTime? cursor,
  }) {
    return NotificationQuery(
      schoolId: _schoolId!,
      recipientUserId: _userId!,
      categories: state.categoryFilter,
      priorities: state.priorityFilter,
      isRead: state.readFilter,
      pinnedOnly: state.pinnedOnly,
      includeArchived: state.includeArchived,
      relatedStudentId: state.studentFilter,
      searchTerm: state.searchTerm.isEmpty ? null : state.searchTerm,
      startAfter: cursor,
    );
  }

  Future<void> _onStarted(
    NotificationCenterStarted event,
    Emitter<NotificationCenterState> emit,
  ) async {
    _schoolId = event.schoolId;
    _userId = event.userId;
    emit(state.copyWith(status: NotificationCenterStatus.loading));

    _subscribe();

    // Push anything the user did while offline, then drop rows past their
    // retention window so the cache does not grow without bound.
    unawaited(
      repository.syncPendingStateChanges(
        schoolId: event.schoolId,
        recipientUserId: event.userId,
      ),
    );
    unawaited(
      repository.purgeExpired(
        schoolId: event.schoolId,
        recipientUserId: event.userId,
      ),
    );
  }

  /// (Re)binds the item and count streams for the current filter.
  void _subscribe() {
    if (!_isReady) return;

    _itemsSub?.cancel();
    _countsSub?.cancel();
    _cursor = null;

    _itemsSub = repository.watchNotifications(_queryFrom(state)).listen((page) {
      _cursor = page.nextCursor;
      add(
        NotificationCenterDataReceived(
          items: page.items,
          fromCache: page.fromCache,
          hasMore: page.hasMore,
        ),
      );
    });

    _countsSub = repository
        .watchCounts(schoolId: _schoolId!, recipientUserId: _userId!)
        .listen((counts) {
          add(
            NotificationCountsReceived(
              unread: counts.unread,
              pinned: counts.pinned,
              total: counts.total,
              requiringAcknowledgement: counts.requiringAcknowledgement,
            ),
          );
        });
  }

  void _onDataReceived(
    NotificationCenterDataReceived event,
    Emitter<NotificationCenterState> emit,
  ) {
    emit(
      state.copyWith(
        status: NotificationCenterStatus.ready,
        items: event.items,
        hasMore: event.hasMore,
        isOffline: event.fromCache,
        isLoadingMore: false,
        clearFailure: true,
      ),
    );
  }

  void _onCountsReceived(
    NotificationCountsReceived event,
    Emitter<NotificationCenterState> emit,
  ) {
    emit(
      state.copyWith(
        unreadCount: event.unread,
        pinnedCount: event.pinned,
        totalCount: event.total,
        acknowledgementCount: event.requiringAcknowledgement,
      ),
    );
  }

  Future<void> _onRefreshed(
    NotificationCenterRefreshed event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (!_isReady) return;

    final synced = await repository.syncPendingStateChanges(
      schoolId: _schoolId!,
      recipientUserId: _userId!,
    );
    synced.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (_) => null,
    );

    final result = await repository.getNotifications(_queryFrom(state));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotificationCenterStatus.failure,
          failure: failure,
        ),
      ),
      (page) {
        _cursor = page.nextCursor;
        emit(
          state.copyWith(
            status: NotificationCenterStatus.ready,
            items: page.items,
            hasMore: page.hasMore,
            isOffline: page.fromCache,
            clearFailure: true,
          ),
        );
      },
    );
  }

  Future<void> _onLoadedMore(
    NotificationCenterLoadedMore event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (!_isReady || state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final result = await repository.getNotifications(
      _queryFrom(state, cursor: _cursor),
    );

    result.fold(
      (failure) => emit(state.copyWith(isLoadingMore: false, failure: failure)),
      (page) {
        _cursor = page.nextCursor;
        // Guard against a duplicate row if a notification arrived at the page
        // boundary between the two queries.
        final existingIds = state.items.map((n) => n.id).toSet();
        final appended = page.items.where((n) => !existingIds.contains(n.id));

        emit(
          state.copyWith(
            items: [...state.items, ...appended],
            hasMore: page.hasMore,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> _onFilterChanged(
    NotificationCenterFilterChanged event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (event.reset) {
      emit(
        state.copyWith(
          categoryFilter: const {},
          priorityFilter: const {},
          clearReadFilter: true,
          pinnedOnly: false,
          includeArchived: false,
          clearStudentFilter: true,
          searchTerm: '',
        ),
      );
    } else {
      emit(
        state.copyWith(
          categoryFilter: event.categories,
          priorityFilter: event.priorities,
          readFilter: event.isRead,
          pinnedOnly: event.pinnedOnly,
          includeArchived: event.includeArchived,
          studentFilter: event.relatedStudentId,
        ),
      );
    }

    _subscribe();
  }

  Future<void> _onSearched(
    NotificationCenterSearched event,
    Emitter<NotificationCenterState> emit,
  ) async {
    emit(state.copyWith(searchTerm: event.term));
    _subscribe();
  }

  // --- mutations -----------------------------------------------------------
  //
  // Each applies through the repository, which writes the local cache first.
  // The cache write is picked up by the watch stream, so the list refreshes
  // itself rather than the bloc patching its own copy - one source of truth.

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (!_isReady) return;
    await repository.markAsRead(
      schoolId: _schoolId!,
      notificationId: event.notificationId,
      recipientUserId: _userId!,
    );
  }

  Future<void> _onMarkedUnread(
    NotificationMarkedUnread event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (!_isReady) return;
    await repository.markAsUnread(
      schoolId: _schoolId!,
      notificationId: event.notificationId,
      recipientUserId: _userId!,
    );
  }

  Future<void> _onOpened(
    NotificationOpened event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (!_isReady) return;
    // Opening implies reading, and both timestamps are recorded, but they stay
    // distinct fields - the spec requires delivered/opened/read never collapse.
    await repository.markAsOpened(
      schoolId: _schoolId!,
      notificationId: event.notificationId,
      recipientUserId: _userId!,
    );
    await repository.markAsRead(
      schoolId: _schoolId!,
      notificationId: event.notificationId,
      recipientUserId: _userId!,
    );
  }

  Future<void> _onAcknowledged(
    NotificationAcknowledged event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (!_isReady) return;
    final result = await repository.acknowledge(
      schoolId: _schoolId!,
      notificationId: event.notificationId,
      recipientUserId: _userId!,
    );
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (_) => null,
    );
  }

  Future<void> _onPinToggled(
    NotificationPinToggled event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (!_isReady) return;
    await repository.setPinned(
      schoolId: _schoolId!,
      notificationId: event.notificationId,
      recipientUserId: _userId!,
      pinned: event.pinned,
    );
  }

  Future<void> _onArchiveToggled(
    NotificationArchiveToggled event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (!_isReady) return;
    await repository.setArchived(
      schoolId: _schoolId!,
      notificationId: event.notificationId,
      recipientUserId: _userId!,
      archived: event.archived,
    );
  }

  Future<void> _onDeleted(
    NotificationDeleted event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (!_isReady) return;
    final result = await repository.delete(
      schoolId: _schoolId!,
      notificationId: event.notificationId,
      recipientUserId: _userId!,
    );
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (_) => null,
    );
  }

  Future<void> _onAllMarkedRead(
    NotificationAllMarkedRead event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (!_isReady) return;
    await repository.markAllAsRead(
      schoolId: _schoolId!,
      recipientUserId: _userId!,
      categories: event.categories,
    );
  }

  Future<void> _onAllArchived(
    NotificationAllArchived event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (!_isReady) return;
    await repository.archiveAll(
      schoolId: _schoolId!,
      recipientUserId: _userId!,
      categories: event.categories,
    );
  }

  Future<void> _onTransientCleared(
    NotificationTransientCleared event,
    Emitter<NotificationCenterState> emit,
  ) async {
    if (!_isReady) return;
    await repository.clearTransientForSource(
      schoolId: _schoolId!,
      recipientUserId: _userId!,
      sourceModule: event.sourceModule,
      sourceEntityId: event.sourceEntityId,
    );
  }

  @override
  Future<void> close() {
    _itemsSub?.cancel();
    _countsSub?.cancel();
    return super.close();
  }
}
