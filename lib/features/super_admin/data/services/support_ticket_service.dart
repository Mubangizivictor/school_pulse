import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/support_ticket.dart';

/// Real Firestore-backed client for the SaaS owner "Report a Problem" /
/// "Submit a Request" support ticket flow.
///
/// Tickets live in `super_admin_support_tickets`, scoped to the
/// authenticated owner via an `ownerId` field (both client-side query
/// scoping here and a matching `firestore.rules` block). Messages live in
/// a `messages` subcollection per ticket - chosen over an embedded array so
/// replies stream in real time via `snapshots()` without re-fetching or
/// rewriting the whole ticket document on every message.
class SupportTicketService {
  SupportTicketService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _tickets =>
      _firestore.collection('super_admin_support_tickets');

  String get _requireUid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Cannot use support tickets while signed out.');
    }
    return uid;
  }

  /// Creates a new ticket owned by the signed-in SaaS owner and returns its
  /// Firestore document id. `origin` records whether this came from
  /// "Report a Problem" or "Submit a Request" (same underlying form/flow -
  /// see build report for the product-interpretation call).
  Future<String> createTicket({
    required String subject,
    required String description,
    required SupportTicketPriority priority,
    required String origin,
  }) async {
    final uid = _requireUid;
    final now = FieldValue.serverTimestamp();
    final docRef = _tickets.doc();
    final ticketNumber =
        'TKT-${DateTime.now().year}-${docRef.id.substring(0, 6).toUpperCase()}';

    await docRef.set({
      'ticketNumber': ticketNumber,
      'ownerId': uid,
      'subject': subject,
      'description': description,
      'priority': supportTicketPriorityToString(priority),
      'status': supportTicketStatusToString(SupportTicketStatus.open),
      'origin': origin,
      'createdAt': now,
      'updatedAt': now,
    });

    return docRef.id;
  }

  Stream<List<SupportTicket>> watchTickets() {
    final uid = _requireUid;
    return _tickets
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => SupportTicket.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(growable: false),
        );
  }

  Stream<SupportTicket?> watchTicket(String ticketId) {
    return _tickets.doc(ticketId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return SupportTicket.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  Stream<List<SupportTicketMessage>> watchMessages(String ticketId) {
    return _tickets
        .doc(ticketId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportTicketMessage.fromJson(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  Future<void> sendMessage({
    required String ticketId,
    required String text,
  }) async {
    final uid = _requireUid;
    final user = _auth.currentUser;
    final senderName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : (user?.email ?? 'Owner');

    final ticketRef = _tickets.doc(ticketId);
    final batch = _firestore.batch();
    batch.set(ticketRef.collection('messages').doc(), {
      'sender': 'owner',
      'senderId': uid,
      'senderName': senderName,
      'text': text,
      'createdAt': Timestamp.now(),
    });
    batch.update(ticketRef, {'updatedAt': FieldValue.serverTimestamp()});
    await batch.commit();
  }
}
