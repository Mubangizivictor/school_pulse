import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/library_borrowing.dart';

class LibraryBorrowingModel extends LibraryBorrowing {
  const LibraryBorrowingModel({
    required super.id,
    required super.schoolId,
    required super.resourceId,
    required super.resourceTitle,
    required super.borrowerId,
    required super.borrowerName,
    required super.borrowerType,
    required super.borrowDate,
    required super.dueDate,
    super.returnDate,
    super.status,
    super.fineAmount,
    super.finePaid,
    required super.issuedBy,
    super.receivedBy,
  });

  factory LibraryBorrowingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LibraryBorrowingModel(
      id: doc.id,
      schoolId: data['schoolId'] ?? '',
      resourceId: data['resourceId'] ?? '',
      resourceTitle: data['resourceTitle'] ?? '',
      borrowerId: data['borrowerId'] ?? '',
      borrowerName: data['borrowerName'] ?? '',
      borrowerType: data['borrowerType'] ?? '',
      borrowDate: (data['borrowDate'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      returnDate: data['returnDate'] != null
          ? (data['returnDate'] as Timestamp).toDate()
          : null,
      status: BorrowingStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => BorrowingStatus.active,
      ),
      fineAmount: (data['fineAmount'] as num?)?.toDouble() ?? 0.0,
      finePaid: data['finePaid'] ?? false,
      issuedBy: data['issuedBy'] ?? '',
      receivedBy: data['receivedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'schoolId': schoolId,
      'resourceId': resourceId,
      'resourceTitle': resourceTitle,
      'borrowerId': borrowerId,
      'borrowerName': borrowerName,
      'borrowerType': borrowerType,
      'borrowDate': Timestamp.fromDate(borrowDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'returnDate': returnDate != null ? Timestamp.fromDate(returnDate!) : null,
      'status': status.name,
      'fineAmount': fineAmount,
      'finePaid': finePaid,
      'issuedBy': issuedBy,
      'receivedBy': receivedBy,
    };
  }
}
