import 'package:equatable/equatable.dart';

enum ReservationStatus { pending, fulfilled, cancelled, expired }

class LibraryReservation extends Equatable {
  final String id;
  final String schoolId;
  final String resourceId;
  final String resourceTitle;
  final String borrowerId;
  final String borrowerName;
  final String borrowerType;
  final DateTime reservationDate;
  final DateTime? expiryDate;
  final ReservationStatus status;
  final int queuePosition;

  const LibraryReservation({
    required this.id,
    required this.schoolId,
    required this.resourceId,
    required this.resourceTitle,
    required this.borrowerId,
    required this.borrowerName,
    required this.borrowerType,
    required this.reservationDate,
    this.expiryDate,
    this.status = ReservationStatus.pending,
    this.queuePosition = 0,
  });

  @override
  List<Object?> get props => [
    id,
    schoolId,
    resourceId,
    resourceTitle,
    borrowerId,
    borrowerName,
    borrowerType,
    reservationDate,
    expiryDate,
    status,
    queuePosition,
  ];
}
