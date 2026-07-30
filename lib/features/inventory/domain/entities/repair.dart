import 'package:equatable/equatable.dart';

enum RepairStatus { pending, approved, inProgress, completed, cancelled }

class RepairRecord extends Equatable {
  final String id;
  final String assetId;
  final String assetName;
  final String description;
  final String? technicianName;
  final double estimatedCost;
  final double actualCost;
  final RepairStatus status;
  final List<String> partsUsed;
  final DateTime requestDate;
  final DateTime? completionDate;
  final String? notes;
  final String? beforePhotoUrl;
  final String? afterPhotoUrl;

  const RepairRecord({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.description,
    this.technicianName,
    this.estimatedCost = 0.0,
    this.actualCost = 0.0,
    required this.status,
    this.partsUsed = const [],
    required this.requestDate,
    this.completionDate,
    this.notes,
    this.beforePhotoUrl,
    this.afterPhotoUrl,
  });

  @override
  List<Object?> get props => [
        id,
        assetId,
        assetName,
        description,
        technicianName,
        estimatedCost,
        actualCost,
        status,
        partsUsed,
        requestDate,
        completionDate,
        notes,
        beforePhotoUrl,
        afterPhotoUrl,
      ];
}
