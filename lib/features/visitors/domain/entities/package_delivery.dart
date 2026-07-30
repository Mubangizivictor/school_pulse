import 'package:equatable/equatable.dart';

class PackageDelivery extends Equatable {
  final String id;
  final String schoolId;
  final String recipientName;
  final String? recipientId;
  final String courierName;
  final String? courierPhone;
  final String? trackingNumber;
  final DateTime arrivalTime;
  final DateTime? collectedTime;
  final String? collectedBy;
  final bool isCollected;

  const PackageDelivery({
    required this.id,
    required this.schoolId,
    required this.recipientName,
    this.recipientId,
    required this.courierName,
    this.courierPhone,
    this.trackingNumber,
    required this.arrivalTime,
    this.collectedTime,
    this.collectedBy,
    this.isCollected = false,
  });

  @override
  List<Object?> get props => [id, schoolId, recipientName, recipientId, courierName, courierPhone, trackingNumber, arrivalTime, collectedTime, collectedBy, isCollected];
}
