import 'package:school_pulse/core/notification/notification_service.dart';
import '../../domain/entities/library_resource.dart';
import '../../domain/entities/library_borrowing.dart';
import '../../domain/entities/library_reservation.dart';
import '../../domain/entities/library_policy.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_data_source.dart';
import '../datasources/local/library_local_data_source.dart';
import '../models/library_policy_model.dart';
import '../models/library_resource_model.dart';
import '../models/library_borrowing_model.dart';
import '../models/library_reservation_model.dart';
import 'package:rxdart/rxdart.dart';
import '../../../admin/data/repositories/audit_repository.dart';
import '../../../finance/domain/repositories/finance_repository.dart';
import '../../../finance/domain/entities/payment_record.dart';
import '../../../inventory/domain/repositories/stores_assets_repository.dart';
import '../../../inventory/domain/entities/repair.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remoteDataSource;
  final LibraryLocalDataSource localDataSource;
  final AuditRepository auditRepository;
  final FinanceRepository financeRepository;
  final StoresAssetsRepository storesAssetsRepository;

  LibraryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.auditRepository,
    required this.financeRepository,
    required this.storesAssetsRepository,
  });

  @override
  Stream<List<LibraryResource>> watchResources(String schoolId) {
    return Rx.merge([
      localDataSource.getCachedResources(schoolId).asStream(),
      remoteDataSource.watchResources(schoolId).doOnData((resources) {
        localDataSource.cacheResources(resources);
      }),
    ]).distinct();
  }

  @override
  Future<void> addResource(LibraryResource resource) {
    return remoteDataSource.addResource(
      LibraryResourceModel(
        id: resource.id,
        schoolId: resource.schoolId,
        libraryId: resource.libraryId,
        barcode: resource.barcode,
        qrCode: resource.qrCode,
        isbn: resource.isbn,
        title: resource.title,
        author: resource.author,
        publisher: resource.publisher,
        edition: resource.edition,
        category: resource.category,
        subject: resource.subject,
        shelf: resource.shelf,
        rack: resource.rack,
        totalQuantity: resource.totalQuantity,
        availableCopies: resource.availableCopies,
        purchaseDate: resource.purchaseDate,
        purchaseCost: resource.purchaseCost,
        supplier: resource.supplier,
        condition: resource.condition,
        type: resource.type,
        status: resource.status,
        coverImageUrl: resource.coverImageUrl,
        digitalAttachmentUrl: resource.digitalAttachmentUrl,
        metadata: resource.metadata,
      ),
    );
  }

  @override
  Future<void> updateResource(LibraryResource resource) {
    return remoteDataSource.updateResource(
      LibraryResourceModel(
        id: resource.id,
        schoolId: resource.schoolId,
        libraryId: resource.libraryId,
        barcode: resource.barcode,
        qrCode: resource.qrCode,
        isbn: resource.isbn,
        title: resource.title,
        author: resource.author,
        publisher: resource.publisher,
        edition: resource.edition,
        category: resource.category,
        subject: resource.subject,
        shelf: resource.shelf,
        rack: resource.rack,
        totalQuantity: resource.totalQuantity,
        availableCopies: resource.availableCopies,
        purchaseDate: resource.purchaseDate,
        purchaseCost: resource.purchaseCost,
        supplier: resource.supplier,
        condition: resource.condition,
        type: resource.type,
        status: resource.status,
        coverImageUrl: resource.coverImageUrl,
        digitalAttachmentUrl: resource.digitalAttachmentUrl,
        metadata: resource.metadata,
      ),
    );
  }

  @override
  Future<void> deleteResource(String schoolId, String resourceId) {
    return remoteDataSource.deleteResource(schoolId, resourceId);
  }

  @override
  Future<LibraryResource?> getResourceByBarcode(
    String schoolId,
    String barcode,
  ) {
    return remoteDataSource.getResourceByBarcode(schoolId, barcode);
  }

  @override
  Stream<List<LibraryBorrowing>> watchBorrowingHistory(
    String schoolId, {
    String? borrowerId,
  }) {
    return Rx.merge([
      localDataSource
          .getCachedBorrowings(schoolId, borrowerId: borrowerId)
          .asStream(),
      remoteDataSource
          .watchBorrowingHistory(schoolId, borrowerId: borrowerId)
          .doOnData((borrowings) {
            localDataSource.cacheBorrowings(borrowings);
          }),
    ]).distinct();
  }

  @override
  Future<void> issueResource(LibraryBorrowing borrowing) async {
    await remoteDataSource.issueResource(
      LibraryBorrowingModel(
        id: borrowing.id,
        schoolId: borrowing.schoolId,
        resourceId: borrowing.resourceId,
        resourceTitle: borrowing.resourceTitle,
        borrowerId: borrowing.borrowerId,
        borrowerName: borrowing.borrowerName,
        borrowerType: borrowing.borrowerType,
        borrowDate: borrowing.borrowDate,
        dueDate: borrowing.dueDate,
        status: borrowing.status,
        fineAmount: borrowing.fineAmount,
        finePaid: borrowing.finePaid,
        issuedBy: borrowing.issuedBy,
      ),
    );

    await auditRepository.logAction(
      schoolId: borrowing.schoolId,
      title: 'Resource Issued',
      description:
          'Librarian ${borrowing.issuedBy} issued "${borrowing.resourceTitle}" to ${borrowing.borrowerName}',
      iconName: 'book',
      colorHex: '#4CAF50',
      userId: borrowing.issuedBy,
    );

    // Schedule automated push notification for overdue reminder
    // Note: In a real enterprise app, this is often handled by a server-side cron job.
    // Here we leverage our existing Direct Notification infrastructure.
    await NotificationService().sendDirectNotification(
      userId: borrowing.borrowerId,
      title: 'Library Reminder',
      body:
          'You have borrowed "${borrowing.resourceTitle}". It is due on ${borrowing.dueDate.toString().split(' ')[0]}.',
      data: {'type': 'library', 'borrowingId': borrowing.id},
    );
  }

  @override
  Future<void> returnResource(
    String schoolId,
    String borrowingId, {
    ResourceCondition? condition,
    double? fineAmount,
  }) async {
    // 1. Fetch borrowing details to get borrower and resource info for integrations
    final borrowingModel = await remoteDataSource.getBorrowingById(
      schoolId,
      borrowingId,
    );
    if (borrowingModel == null) return;

    await remoteDataSource.updateBorrowingStatus(schoolId, borrowingId, {
      'status': BorrowingStatus.returned.name,
      'returnDate': DateTime.now(),
      'fineAmount': ?fineAmount,
    });

    // 2. Integration: Finance (Fines)
    if (fineAmount != null && fineAmount > 0) {
      final now = DateTime.now();
      await financeRepository.recordPayment(
        PaymentRecord(
          id: 'FINE_$borrowingId',
          schoolId: schoolId,
          studentId: borrowingModel.borrowerId,
          academicYear: now.year.toString(),
          term: 'N/A',
          amount: fineAmount,
          date: now,
          method: 'Account Debit',
          reference: 'LIB_FINE_$borrowingId',
          receiptNumber: 'LIB_FINE_$borrowingId',
          feeBreakdown: const {'Library Fine': 0},
          recordedBy: 'System (Library)',
          notes:
              'Fine for late/damaged return of "${borrowingModel.resourceTitle}"',
        ),
      );
    }

    // 3. Integration: Stores & Assets (Repairs)
    if (condition == ResourceCondition.damaged ||
        condition == ResourceCondition.poor) {
      await storesAssetsRepository.requestRepair(
        RepairRecord(
          id: 'REP_LIB_${borrowingModel.resourceId}_${DateTime.now().millisecondsSinceEpoch}',
          assetId: borrowingModel.resourceId,
          assetName: borrowingModel.resourceTitle,
          description:
              'Damaged during library borrowing (ID: $borrowingId). Condition: ${condition!.name}',
          requestDate: DateTime.now(),
          status: RepairStatus.pending,
          notes: 'Priority: medium. Requested by: Librarian',
        ),
      );

      // Update resource status to underRepair
      await remoteDataSource.updateResourceStatus(
        schoolId,
        borrowingModel.resourceId,
        ResourceStatus.underRepair.name,
      );
    }

    await auditRepository.logAction(
      schoolId: schoolId,
      title: 'Resource Returned',
      description:
          'Resource "${borrowingModel.resourceTitle}" returned by ${borrowingModel.borrowerName}. Fine: ${fineAmount ?? 0}',
      iconName: 'keyboard_return',
      colorHex: '#2196F3',
      userId: 'system', // Ideally we pass the librarian ID
    );
  }

  @override
  Future<void> renewResource(
    String schoolId,
    String borrowingId,
    DateTime newDueDate,
  ) {
    return remoteDataSource.updateBorrowingStatus(schoolId, borrowingId, {
      'dueDate': newDueDate,
    });
  }

  @override
  Stream<List<LibraryReservation>> watchReservations(
    String schoolId, {
    String? borrowerId,
  }) {
    return remoteDataSource.watchReservations(schoolId, borrowerId: borrowerId);
  }

  @override
  Future<void> reserveResource(LibraryReservation reservation) {
    return remoteDataSource.addReservation(
      LibraryReservationModel(
        id: reservation.id,
        schoolId: reservation.schoolId,
        resourceId: reservation.resourceId,
        resourceTitle: reservation.resourceTitle,
        borrowerId: reservation.borrowerId,
        borrowerName: reservation.borrowerName,
        borrowerType: reservation.borrowerType,
        reservationDate: reservation.reservationDate,
        expiryDate: reservation.expiryDate,
        status: reservation.status,
        queuePosition: reservation.queuePosition,
      ),
    );
  }

  @override
  Future<void> cancelReservation(String schoolId, String reservationId) {
    return remoteDataSource.updateReservationStatus(
      schoolId,
      reservationId,
      ReservationStatus.cancelled.name,
    );
  }

  @override
  Stream<List<LibraryPolicy>> watchPolicies(String schoolId) {
    return remoteDataSource
        .watchPolicies(schoolId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<void> updatePolicy(LibraryPolicy policy) {
    return remoteDataSource.updatePolicy(LibraryPolicyModel.fromEntity(policy));
  }

  @override
  Future<Map<String, dynamic>> getLibraryStats(String schoolId) {
    return remoteDataSource.getLibraryStats(schoolId);
  }

  @override
  Future<Map<String, dynamic>> getBorrowerAnalytics(
    String schoolId,
    String borrowerId,
  ) async {
    final borrowings = await remoteDataSource
        .watchBorrowingHistory(schoolId, borrowerId: borrowerId)
        .first;

    final totalBorrowed = borrowings.length;
    final currentlyBorrowed = borrowings
        .where((b) => b.status != BorrowingStatus.returned)
        .length;
    final overdueCount = borrowings
        .where((b) => b.status == BorrowingStatus.overdue)
        .length;

    // Calculate favorite category (requires fetching resource details)
    // For simplicity, we aggregate by title/resourceId for now
    Map<String, int> bookCounts = {};
    for (var b in borrowings) {
      bookCounts[b.resourceTitle] = (bookCounts[b.resourceTitle] ?? 0) + 1;
    }

    return {
      'totalBorrowed': totalBorrowed,
      'currentlyBorrowed': currentlyBorrowed,
      'overdueCount': overdueCount,
      'history': borrowings.map((b) => b.toFirestore()).toList(), // Simplified
    };
  }
}
