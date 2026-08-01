import '../entities/offline_operation.dart';

/// What one drain pass did.
class SyncResult {
  final int synced;
  final int failed;
  final int conflicted;
  final int remaining;

  const SyncResult({
    this.synced = 0,
    this.failed = 0,
    this.conflicted = 0,
    this.remaining = 0,
  });

  bool get isClean => failed == 0 && conflicted == 0;
  bool get didWork => synced > 0 || failed > 0 || conflicted > 0;
}

/// Replays work the teacher did offline.
///
/// The queue is written by the repositories; this is the only thing that
/// drains it. Keeping the two apart means a repository never has to care
/// whether it is online, and the drain never has to know how a register or a
/// mark is shaped beyond the handler it dispatches to.
abstract class SubjectSyncService {
  /// Pushes every pending operation it can. Safe to call repeatedly - already
  /// synced operations are removed, and a failure leaves the work on the
  /// device rather than dropping it.
  Future<SyncResult> drain({String? schoolId});

  /// How much work is still waiting, for the sync indicator.
  Future<List<OfflineOperation>> pending({String? schoolId});

  /// Starts draining whenever connectivity returns.
  void startWatching({String? schoolId});

  void stopWatching();
}
