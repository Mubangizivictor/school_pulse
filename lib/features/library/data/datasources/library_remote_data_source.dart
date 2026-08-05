import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/library_policy_model.dart';
import '../models/library_resource_model.dart';
import '../models/library_borrowing_model.dart';
import '../models/library_reservation_model.dart';
import '../../domain/entities/library_borrowing.dart';

abstract class LibraryRemoteDataSource {
  // Resources
  Stream<List<LibraryResourceModel>> watchResources(String schoolId);
  Future<void> addResource(LibraryResourceModel resource);
  Future<void> updateResource(LibraryResourceModel resource);
  Future<void> deleteResource(String schoolId, String resourceId);
  Future<LibraryResourceModel?> getResourceByBarcode(
    String schoolId,
    String barcode,
  );
  Future<void> updateResourceStatus(
    String schoolId,
    String resourceId,
    String status,
  );

  // Borrowing
  Stream<List<LibraryBorrowingModel>> watchBorrowingHistory(
    String schoolId, {
    String? borrowerId,
  });
  Future<LibraryBorrowingModel?> getBorrowingById(
    String schoolId,
    String borrowingId,
  );
  Future<void> issueResource(LibraryBorrowingModel borrowing);
  Future<void> updateBorrowingStatus(
    String schoolId,
    String borrowingId,
    Map<String, dynamic> data,
  );

  // Reservations
  Stream<List<LibraryReservationModel>> watchReservations(
    String schoolId, {
    String? borrowerId,
  });
  Future<void> addReservation(LibraryReservationModel reservation);
  Future<void> updateReservationStatus(
    String schoolId,
    String reservationId,
    String status,
  );

  // Stats
  Future<Map<String, dynamic>> getLibraryStats(String schoolId);

  // Policies
  Stream<List<LibraryPolicyModel>> watchPolicies(String schoolId);
  Future<void> updatePolicy(LibraryPolicyModel policy);
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final FirebaseFirestore firestore;

  LibraryRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<LibraryResourceModel>> watchResources(String schoolId) {
    return firestore
        .collection('schools')
        .doc(schoolId)
        .collection('library_resources')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LibraryResourceModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> addResource(LibraryResourceModel resource) async {
    await firestore
        .collection('schools')
        .doc(resource.schoolId)
        .collection('library_resources')
        .doc(resource.id.isEmpty ? null : resource.id)
        .set(resource.toFirestore());
  }

  @override
  Future<void> updateResource(LibraryResourceModel resource) async {
    await firestore
        .collection('schools')
        .doc(resource.schoolId)
        .collection('library_resources')
        .doc(resource.id)
        .update(resource.toFirestore());
  }

  @override
  Future<void> deleteResource(String schoolId, String resourceId) async {
    await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('library_resources')
        .doc(resourceId)
        .delete();
  }

  @override
  Future<LibraryResourceModel?> getResourceByBarcode(
    String schoolId,
    String barcode,
  ) async {
    final snapshot = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('library_resources')
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return LibraryResourceModel.fromFirestore(snapshot.docs.first);
  }

  @override
  Future<void> updateResourceStatus(
    String schoolId,
    String resourceId,
    String status,
  ) async {
    await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('library_resources')
        .doc(resourceId)
        .update({'status': status});
  }

  @override
  Stream<List<LibraryBorrowingModel>> watchBorrowingHistory(
    String schoolId, {
    String? borrowerId,
  }) {
    Query query = firestore
        .collection('schools')
        .doc(schoolId)
        .collection('library_borrowings');

    if (borrowerId != null) {
      query = query.where('borrowerId', isEqualTo: borrowerId);
    }

    return query
        .orderBy('borrowDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LibraryBorrowingModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<LibraryBorrowingModel?> getBorrowingById(
    String schoolId,
    String borrowingId,
  ) async {
    final doc = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('library_borrowings')
        .doc(borrowingId)
        .get();

    if (!doc.exists) return null;
    return LibraryBorrowingModel.fromFirestore(doc);
  }

  @override
  Future<void> issueResource(LibraryBorrowingModel borrowing) async {
    final batch = firestore.batch();

    final borrowingRef = firestore
        .collection('schools')
        .doc(borrowing.schoolId)
        .collection('library_borrowings')
        .doc(borrowing.id.isEmpty ? null : borrowing.id);

    batch.set(borrowingRef, borrowing.toFirestore());

    final resourceRef = firestore
        .collection('schools')
        .doc(borrowing.schoolId)
        .collection('library_resources')
        .doc(borrowing.resourceId);

    batch.update(resourceRef, {'availableCopies': FieldValue.increment(-1)});

    await batch.commit();
  }

  @override
  Future<void> updateBorrowingStatus(
    String schoolId,
    String borrowingId,
    Map<String, dynamic> data,
  ) async {
    await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('library_borrowings')
        .doc(borrowingId)
        .update(data);

    // If status is returned, we should increment availableCopies
    if (data['status'] == BorrowingStatus.returned.name) {
      final borrowingDoc = await firestore
          .collection('schools')
          .doc(schoolId)
          .collection('library_borrowings')
          .doc(borrowingId)
          .get();

      if (borrowingDoc.exists) {
        final resourceId = borrowingDoc.data()?['resourceId'];
        if (resourceId != null) {
          await firestore
              .collection('schools')
              .doc(schoolId)
              .collection('library_resources')
              .doc(resourceId)
              .update({'availableCopies': FieldValue.increment(1)});
        }
      }
    }
  }

  @override
  Stream<List<LibraryReservationModel>> watchReservations(
    String schoolId, {
    String? borrowerId,
  }) {
    Query query = firestore
        .collection('schools')
        .doc(schoolId)
        .collection('library_reservations');

    if (borrowerId != null) {
      query = query.where('borrowerId', isEqualTo: borrowerId);
    }

    return query
        .orderBy('reservationDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LibraryReservationModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> addReservation(LibraryReservationModel reservation) async {
    await firestore
        .collection('schools')
        .doc(reservation.schoolId)
        .collection('library_reservations')
        .add(reservation.toFirestore());
  }

  @override
  Future<void> updateReservationStatus(
    String schoolId,
    String reservationId,
    String status,
  ) async {
    await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('library_reservations')
        .doc(reservationId)
        .update({'status': status});
  }

  @override
  Future<Map<String, dynamic>> getLibraryStats(String schoolId) async {
    final resources = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('library_resources')
        .get();

    final activeBorrowings = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('library_borrowings')
        .where('status', isEqualTo: BorrowingStatus.active.name)
        .get();

    final overdue = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('library_borrowings')
        .where('status', isEqualTo: BorrowingStatus.active.name)
        .where('dueDate', isLessThan: Timestamp.now())
        .get();

    // Calculate trends for the last 6 months
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);

    final allBorrowings = await firestore
        .collection('schools')
        .doc(schoolId)
        .collection('library_borrowings')
        .where(
          'borrowDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(sixMonthsAgo),
        )
        .get();

    Map<String, int> monthlyTrends = {};
    for (var doc in allBorrowings.docs) {
      final date = (doc.data()['borrowDate'] as Timestamp).toDate();
      final key = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      monthlyTrends[key] = (monthlyTrends[key] ?? 0) + 1;
    }

    // Ensure all 6 months are present
    for (int i = 0; i < 6; i++) {
      final d = DateTime(now.year, now.month - i, 1);
      final key = "${d.year}-${d.month.toString().padLeft(2, '0')}";
      monthlyTrends.putIfAbsent(key, () => 0);
    }

    return {
      'totalBooks': resources.docs.length,
      'borrowedBooks': activeBorrowings.docs.length,
      'overdueBooks': overdue.docs.length,
      'monthlyTrends': monthlyTrends,
    };
  }

  @override
  Stream<List<LibraryPolicyModel>> watchPolicies(String schoolId) {
    return firestore
        .collection('schools')
        .doc(schoolId)
        .collection('library_policies')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => LibraryPolicyModel.fromFirestore(doc.data(), doc.id),
              )
              .toList(),
        );
  }

  @override
  Future<void> updatePolicy(LibraryPolicyModel policy) async {
    await firestore
        .collection('schools')
        .doc(policy.schoolId)
        .collection('library_policies')
        .doc(policy.borrowerType) // Use borrowerType as ID for easy lookup
        .set(policy.toFirestore());
  }
}
