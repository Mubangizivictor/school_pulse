import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_model.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_repository.dart';
import '../mappers/notification_mapper.dart';
import '../mappers/notification_preferences_mapper.dart';

/// Firestore access for notifications.
///
/// Layout:
///   notifications/{notificationId}                  - one doc per recipient
///   schools/{schoolId}/notification_settings/{uid}  - user preferences
///   schools/{schoolId}/notification_policy/policy   - school-wide policy
///
/// One document per recipient (rather than one shared document with a
/// recipients array) is what makes per-user read state, archiving and security
/// rules expressible: a rule can compare `resource.data.recipientUserId` to the
/// caller directly, and a read receipt is a single-field write rather than an
/// array mutation contended by every recipient at once.
abstract class NotificationRemoteDataSource {
  Future<List<NotificationItem>> fetch(NotificationQuery query);
  Stream<List<NotificationItem>> watch(NotificationQuery query);
  Future<NotificationItem?> getById(String notificationId);

  Future<void> applyStateChange({
    required String notificationId,
    required String field,
    bool value = true,
  });

  Future<void> applyBulkStateChange({
    required String schoolId,
    required String recipientUserId,
    required String field,
    Set<NotificationCategory> categories = const {},
  });

  Future<void> delete(String notificationId);

  Future<int> clearTransientForSource({
    required String schoolId,
    required String recipientUserId,
    required String sourceModule,
    required String sourceEntityId,
  });

  Future<NotificationPreferences?> getPreferences({
    required String schoolId,
    required String userId,
  });

  Future<void> savePreferences(NotificationPreferences preferences);

  Future<SchoolNotificationPolicy?> getSchoolPolicy(String schoolId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;

  NotificationRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection(NotificationMapper.collection);

  /// Builds the tenant- and recipient-scoped query.
  ///
  /// The `schoolId` + `recipientUserId` equality pair is always applied first
  /// and is never optional - it is what the security rules also enforce, and
  /// what keeps one school's notifications unreachable from another.
  ///
  /// Only filters that Firestore can serve from a composite index are applied
  /// here. Free-text search and multi-category filtering are handled after the
  /// fetch, because Firestore has no OR-across-fields or substring support and
  /// pushing them server-side would need one index per filter combination.
  Query<Map<String, dynamic>> _buildQuery(NotificationQuery q) {
    Query<Map<String, dynamic>> query = _collection
        .where('schoolId', isEqualTo: q.schoolId)
        .where('recipientUserId', isEqualTo: q.recipientUserId);

    if (!q.includeArchived) {
      query = query.where('isArchived', isEqualTo: false);
    }
    if (q.isRead != null) {
      query = query.where('isRead', isEqualTo: q.isRead);
    }
    if (q.pinnedOnly) {
      query = query.where('isPinned', isEqualTo: true);
    }
    if (q.relatedStudentId != null) {
      query = query.where('relatedStudentId', isEqualTo: q.relatedStudentId);
    }
    // A single category filters server-side; several are applied in-memory to
    // avoid needing a separate composite index per category combination.
    if (q.categories.length == 1) {
      query = query.where('category', isEqualTo: q.categories.first.name);
    }
    if (q.from != null) {
      query = query.where('createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(q.from!));
    }
    if (q.to != null) {
      query =
          query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(q.to!));
    }

    query = query.orderBy('createdAt', descending: true);

    // Cursor is the createdAt of the last row of the previous page. Paging by
    // the ordered field (rather than a document snapshot) keeps the cursor
    // serialisable, so it survives being held in bloc state across a rebuild.
    if (q.startAfter != null) {
      query = query.startAfter([Timestamp.fromDate(q.startAfter!)]);
    }

    // Over-fetch when post-filtering will discard rows, so a page still fills
    // after in-memory filters run.
    final needsPostFilter =
        q.categories.length > 1 || q.priorities.isNotEmpty || _hasTerm(q);
    return query.limit(needsPostFilter ? q.limit * 3 : q.limit);
  }

  static bool _hasTerm(NotificationQuery q) =>
      q.searchTerm != null && q.searchTerm!.trim().isNotEmpty;

  /// Applies the filters Firestore could not express, then trims to the page
  /// size the caller asked for.
  List<NotificationItem> _postFilter(
    List<NotificationItem> items,
    NotificationQuery q,
  ) {
    var result = items;

    if (q.categories.length > 1) {
      result = result.where((n) => q.categories.contains(n.category)).toList();
    }
    if (q.priorities.isNotEmpty) {
      result = result.where((n) => q.priorities.contains(n.priority)).toList();
    }
    if (_hasTerm(q)) {
      final term = q.searchTerm!.trim().toLowerCase();
      result = result.where((n) {
        return n.title.toLowerCase().contains(term) ||
            n.description.toLowerCase().contains(term) ||
            n.senderName.toLowerCase().contains(term) ||
            (n.relatedStudentName?.toLowerCase().contains(term) ?? false);
      }).toList();
    }

    return result.length > q.limit ? result.sublist(0, q.limit) : result;
  }

  @override
  Future<List<NotificationItem>> fetch(NotificationQuery q) async {
    final snapshot = await _buildQuery(q).get();
    final items = snapshot.docs
        .map((d) => NotificationMapper.fromFirestore(d.id, d.data()))
        .toList();
    return _postFilter(items, q);
  }

  @override
  Stream<List<NotificationItem>> watch(NotificationQuery q) {
    return _buildQuery(q).snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((d) => NotificationMapper.fromFirestore(d.id, d.data()))
          .toList();
      return _postFilter(items, q);
    });
  }

  @override
  Future<NotificationItem?> getById(String notificationId) async {
    final doc = await _collection.doc(notificationId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return NotificationMapper.fromFirestore(doc.id, data);
  }

  @override
  Future<void> applyStateChange({
    required String notificationId,
    required String field,
    bool value = true,
  }) async {
    final update = NotificationMapper.stateUpdate(field, value: value);
    if (update.isEmpty) return;
    await _collection.doc(notificationId).update(update);
  }

  @override
  Future<void> applyBulkStateChange({
    required String schoolId,
    required String recipientUserId,
    required String field,
    Set<NotificationCategory> categories = const {},
  }) async {
    final update = NotificationMapper.stateUpdate(field);
    if (update.isEmpty) return;

    Query<Map<String, dynamic>> query = _collection
        .where('schoolId', isEqualTo: schoolId)
        .where('recipientUserId', isEqualTo: recipientUserId);

    // Only touch rows that actually need changing: marking everything read
    // when most rows are already read would otherwise bill a write per row.
    if (field == 'read') {
      query = query.where('isRead', isEqualTo: false);
    } else if (field == 'archived') {
      query = query.where('isArchived', isEqualTo: false);
    }
    if (categories.length == 1) {
      query = query.where('category', isEqualTo: categories.first.name);
    }

    await _commitInBatches(
      query: query,
      update: update,
      categories: categories.length > 1 ? categories : const {},
    );
  }

  /// Applies [update] to every matching document, 400 at a time.
  ///
  /// Firestore caps a batch at 500 writes; 400 leaves headroom and keeps each
  /// commit small enough to retry cheaply on a poor connection.
  Future<void> _commitInBatches({
    required Query<Map<String, dynamic>> query,
    required Map<String, dynamic> update,
    Set<NotificationCategory> categories = const {},
  }) async {
    const pageSize = 400;
    DocumentSnapshot<Map<String, dynamic>>? cursor;

    while (true) {
      var page = query.limit(pageSize);
      if (cursor != null) page = page.startAfterDocument(cursor);

      final snapshot = await page.get();
      if (snapshot.docs.isEmpty) break;

      final batch = firestore.batch();
      var writes = 0;
      for (final doc in snapshot.docs) {
        if (categories.isNotEmpty) {
          final name = doc.data()['category'] as String?;
          final matches = categories.any((c) => c.name == name);
          if (!matches) continue;
        }
        batch.update(doc.reference, update);
        writes++;
      }
      if (writes > 0) await batch.commit();

      if (snapshot.docs.length < pageSize) break;
      cursor = snapshot.docs.last;
    }
  }

  @override
  Future<void> delete(String notificationId) async {
    await _collection.doc(notificationId).delete();
  }

  @override
  Future<int> clearTransientForSource({
    required String schoolId,
    required String recipientUserId,
    required String sourceModule,
    required String sourceEntityId,
  }) async {
    // Transient notifications (chat pings) are deleted rather than marked
    // read: keeping one permanent row per message is exactly the duplication
    // the cost-optimisation requirement rules out.
    final snapshot = await _collection
        .where('schoolId', isEqualTo: schoolId)
        .where('recipientUserId', isEqualTo: recipientUserId)
        .where('sourceModule', isEqualTo: sourceModule)
        .where('sourceEntityId', isEqualTo: sourceEntityId)
        .where('persistence', isEqualTo: NotificationPersistence.transient.name)
        .limit(400)
        .get();

    if (snapshot.docs.isEmpty) return 0;

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    return snapshot.docs.length;
  }

  DocumentReference<Map<String, dynamic>> _preferencesDoc(
    String schoolId,
    String userId,
  ) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('notification_settings')
          .doc(userId);

  @override
  Future<NotificationPreferences?> getPreferences({
    required String schoolId,
    required String userId,
  }) async {
    final doc = await _preferencesDoc(schoolId, userId).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return NotificationPreferencesMapper.fromFirestore(
      data,
      userId: userId,
      schoolId: schoolId,
    );
  }

  @override
  Future<void> savePreferences(NotificationPreferences preferences) async {
    await _preferencesDoc(preferences.schoolId, preferences.userId).set(
      NotificationPreferencesMapper.toFirestore(preferences),
      SetOptions(merge: true),
    );
  }

  @override
  Future<SchoolNotificationPolicy?> getSchoolPolicy(String schoolId) async {
    final doc = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('notification_policy')
        .doc('policy')
        .get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return NotificationPreferencesMapper.policyFromFirestore(data, schoolId);
  }
}
