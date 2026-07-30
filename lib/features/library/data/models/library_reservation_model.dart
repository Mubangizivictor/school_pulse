import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/library_reservation.dart';

class LibraryReservationModel extends LibraryReservation {
  const LibraryReservationModel({
    required super.id,
    required super.schoolId,
    required super.resourceId,
    required super.resourceTitle,
    required super.borrowerId,
    required super.borrowerName,
    required super.borrowerType,
    required super.reservationDate,
    super.expiryDate,
    super.status,
    super.queuePosition,
  });

  factory LibraryReservationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LibraryReservationModel(
      id: doc.id,
      schoolId: data['schoolId'] ?? '',
      resourceId: data['resourceId'] ?? '',
      resourceTitle: data['resourceTitle'] ?? '',
      borrowerId: data['borrowerId'] ?? '',
      borrowerName: data['borrowerName'] ?? '',
      borrowerType: data['borrowerType'] ?? '',
      reservationDate: (data['reservationDate'] as Timestamp).toDate(),
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
      status: ReservationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ReservationStatus.pending,
      ),
      queuePosition: data['queuePosition'] ?? 0,
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
      'reservationDate': Timestamp.fromDate(reservationDate),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'status': status.name,
      'queuePosition': queuePosition,
    };
  }
}
