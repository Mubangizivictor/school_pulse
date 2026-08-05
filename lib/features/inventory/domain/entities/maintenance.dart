import 'package:equatable/equatable.dart';

enum MaintenanceType { routine, preventive, emergency }

enum MaintenanceStatus { scheduled, inProgress, completed, cancelled }

class MaintenanceRecord extends Equatable {
  final String id;
  final String assetId;
  final String assetName;
  final MaintenanceType type;
  final String description;
  final DateTime scheduledDate;
  final DateTime? completionDate;
  final MaintenanceStatus status;
  final String? performedBy;
  final double cost;
  final String? notes;

  const MaintenanceRecord({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.type,
    required this.description,
    required this.scheduledDate,
    this.completionDate,
    required this.status,
    this.performedBy,
    this.cost = 0.0,
    this.notes,
  });

  @override
  List<Object?> get props => [
    id,
    assetId,
    assetName,
    type,
    description,
    scheduledDate,
    completionDate,
    status,
    performedBy,
    cost,
    notes,
  ];
}
