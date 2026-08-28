import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/core/network/network_info.dart';
import 'package:school_pulse/features/finance/data/datasources/finance_operations_remote_data_source.dart';

/// Offline-first support for finance (audit area 6).
///
/// Deliberately narrow. Only ONE finance action may be queued offline: a
/// **petty-cash disbursement** — a low-risk, additive capture whose
/// callable (`recordPettyCashDisbursement`) is already idempotent on a
/// client-minted `clientRequestId` (proven by the Area 3 emulator tests).
/// Everything else — approvals, reconciliation match/unmatch, payroll
/// finalisation, supplier payment — is a security-sensitive or
/// conflict-prone decision and stays strictly online-only; there is no
/// enqueue path for them here at all.
///
/// Storage is a small JSON list in SharedPreferences (app-sandboxed,
/// survives restart). The queue is a handful of tiny records, so this
/// reuses the *shape* of `parent_offline` (durable, idempotency-keyed,
/// pending/syncing/failed, replay in order, stop on first failure) without
/// standing up a second Isar schema — which the web build explicitly can't
/// take.
enum FinanceQueueStatus { pending, syncing, failed }

class FinanceQueuedDisbursement {
  final String clientRequestId;
  final String schoolId;
  final String floatId;
  final String payee;
  final String category;
  final String purpose;
  final int amountUgx;
  final DateTime capturedAt;
  final String? requestedBy;
  final String? approvedBy;
  final FinanceQueueStatus status;
  final String? lastError;

  const FinanceQueuedDisbursement({
    required this.clientRequestId,
    required this.schoolId,
    required this.floatId,
    required this.payee,
    required this.category,
    required this.purpose,
    required this.amountUgx,
    required this.capturedAt,
    this.requestedBy,
    this.approvedBy,
    this.status = FinanceQueueStatus.pending,
    this.lastError,
  });

  FinanceQueuedDisbursement copyWith({
    FinanceQueueStatus? status,
    String? lastError,
  }) => FinanceQueuedDisbursement(
    clientRequestId: clientRequestId,
    schoolId: schoolId,
    floatId: floatId,
    payee: payee,
    category: category,
    purpose: purpose,
    amountUgx: amountUgx,
    capturedAt: capturedAt,
    requestedBy: requestedBy,
    approvedBy: approvedBy,
    status: status ?? this.status,
    lastError: lastError,
  );

  Map<String, dynamic> toJson() => {
    'clientRequestId': clientRequestId,
    'schoolId': schoolId,
    'floatId': floatId,
    'payee': payee,
    'category': category,
    'purpose': purpose,
    'amountUgx': amountUgx,
    'capturedAt': capturedAt.toIso8601String(),
    'requestedBy': requestedBy,
    'approvedBy': approvedBy,
    'status': status.name,
    'lastError': lastError,
  };

  factory FinanceQueuedDisbursement.fromJson(Map<String, dynamic> j) =>
      FinanceQueuedDisbursement(
        clientRequestId: j['clientRequestId'] as String,
        schoolId: j['schoolId'] as String,
        floatId: j['floatId'] as String? ?? 'main',
        payee: j['payee'] as String? ?? '',
        category: j['category'] as String? ?? '',
        purpose: j['purpose'] as String? ?? '',
        amountUgx: (j['amountUgx'] as num?)?.toInt() ?? 0,
        capturedAt:
            DateTime.tryParse(j['capturedAt'] as String? ?? '') ??
            DateTime.now(),
        requestedBy: j['requestedBy'] as String?,
        approvedBy: j['approvedBy'] as String?,
        status: FinanceQueueStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => FinanceQueueStatus.pending,
        ),
        lastError: j['lastError'] as String?,
      );
}

class FinanceOfflineQueue {
  static const _prefsKey = 'finance_petty_cash_queue_v1';

  final SharedPreferences _prefs;
  final NetworkInfo _network;
  final FinanceOperationsRemoteDataSource _ops;
  static const _uuid = Uuid();

  FinanceOfflineQueue({
    required SharedPreferences prefs,
    required NetworkInfo network,
    required FinanceOperationsRemoteDataSource ops,
  }) : this._(prefs, network, ops);

  FinanceOfflineQueue._(this._prefs, this._network, this._ops);

  Future<bool> get isOnline => _network.isConnected;

  List<FinanceQueuedDisbursement> _load() {
    final raw = _prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map(
            (e) => FinanceQueuedDisbursement.fromJson(
              (e as Map).cast<String, dynamic>(),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _save(List<FinanceQueuedDisbursement> items) => _prefs.setString(
    _prefsKey,
    jsonEncode(items.map((e) => e.toJson()).toList()),
  );

  List<FinanceQueuedDisbursement> pendingFor(String schoolId) =>
      _load().where((e) => e.schoolId == schoolId).toList()
        ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));

  /// Capture a disbursement for later send. Returns the `clientRequestId`
  /// the server will dedupe on.
  Future<String> enqueueDisbursement({
    required String schoolId,
    String floatId = 'main',
    required String payee,
    required String category,
    required String purpose,
    required int amountUgx,
    String? requestedBy,
    String? approvedBy,
  }) async {
    final id = _uuid.v4();
    final items = _load()
      ..add(
        FinanceQueuedDisbursement(
          clientRequestId: id,
          schoolId: schoolId,
          floatId: floatId,
          payee: payee,
          category: category,
          purpose: purpose,
          amountUgx: amountUgx,
          capturedAt: DateTime.now(),
          requestedBy: requestedBy,
          approvedBy: approvedBy,
        ),
      );
    await _save(items);
    return id;
  }

  Future<void> discard(String clientRequestId) async {
    final items = _load()
      ..removeWhere((e) => e.clientRequestId == clientRequestId);
    await _save(items);
  }

  /// Replay every pending item for [schoolId] in capture order, stopping at
  /// the first failure so a later capture can't overtake an unresolved one.
  /// A successful send is removed from the queue; the callable's own
  /// idempotency means a retry of a partially-acked send never
  /// double-spends the float. Returns the number successfully synced.
  Future<int> sync(String schoolId) async {
    if (!await isOnline) return 0;
    var synced = 0;
    var items = _load();
    final mine = items.where((e) => e.schoolId == schoolId).toList()
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));

    for (final item in mine) {
      // mark syncing
      items = items
          .map(
            (e) => e.clientRequestId == item.clientRequestId
                ? e.copyWith(status: FinanceQueueStatus.syncing)
                : e,
          )
          .toList();
      await _save(items);
      try {
        await _ops.recordPettyCashDisbursement(
          schoolId: item.schoolId,
          floatId: item.floatId,
          payee: item.payee,
          category: item.category,
          purpose: item.purpose,
          amountUgx: item.amountUgx,
          requestedBy: item.requestedBy,
          approvedBy: item.approvedBy,
          clientRequestId: item.clientRequestId,
        );
        items = items
            .where((e) => e.clientRequestId != item.clientRequestId)
            .toList();
        await _save(items);
        synced++;
      } catch (e) {
        items = items
            .map(
              (x) => x.clientRequestId == item.clientRequestId
                  ? x.copyWith(
                      status: FinanceQueueStatus.failed,
                      lastError: e.toString(),
                    )
                  : x,
            )
            .toList();
        await _save(items);
        break;
      }
    }
    return synced;
  }
}
