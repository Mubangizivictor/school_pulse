import '../entities/library_resource.dart';
import '../entities/library_borrowing.dart';
import '../entities/library_reservation.dart';
import '../entities/library_policy.dart';

abstract class LibraryRepository {
  // Resources
  Stream<List<LibraryResource>> watchResources(String schoolId);
  Future<void> addResource(LibraryResource resource);
  Future<void> updateResource(LibraryResource resource);
  Future<void> deleteResource(String schoolId, String resourceId);
  Future<LibraryResource?> getResourceByBarcode(
    String schoolId,
    String barcode,
  );

  // Borrowing
  Stream<List<LibraryBorrowing>> watchBorrowingHistory(
    String schoolId, {
    String? borrowerId,
  });
  Future<void> issueResource(LibraryBorrowing borrowing);
  Future<void> returnResource(
    String schoolId,
    String borrowingId, {
    ResourceCondition? condition,
    double? fineAmount,
  });
  Future<void> renewResource(
    String schoolId,
    String borrowingId,
    DateTime newDueDate,
  );

  // Reservations
  Stream<List<LibraryReservation>> watchReservations(
    String schoolId, {
    String? borrowerId,
  });
  Future<void> reserveResource(LibraryReservation reservation);
  Future<void> cancelReservation(String schoolId, String reservationId);
  Future<void> fulfilReservation(String schoolId, String reservationId);

  // Policies
  Stream<List<LibraryPolicy>> watchPolicies(String schoolId);
  Future<void> updatePolicy(LibraryPolicy policy);

  // Analytics
  Future<Map<String, dynamic>> getLibraryStats(String schoolId);
  Future<Map<String, dynamic>> getBorrowerAnalytics(
    String schoolId,
    String borrowerId,
  );
}
