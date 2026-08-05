import 'package:equatable/equatable.dart';

enum VisitOutcome {
  sentBackToClass,
  sentHome,
  admittedToSickBay,
  referredToHospital,
}

class ClinicVisit extends Equatable {
  final String id;
  final String studentId;
  final String? staffId; // If it's a staff visit
  final DateTime dateTime;
  final String reason;
  final String symptoms;
  final double? temperature;
  final String? bloodPressure;
  final int? pulseRate;
  final int? oxygenSaturation;
  final double? weight;
  final String? diagnosis;
  final String? treatmentProvided;
  final List<AdministeredMedication> medicationsGiven;
  final String? observationNotes;
  final bool followUpRequired;
  final VisitOutcome outcome;
  final String recordedBy;
  final String? schoolId;

  const ClinicVisit({
    required this.id,
    required this.studentId,
    this.staffId,
    required this.dateTime,
    required this.reason,
    required this.symptoms,
    this.temperature,
    this.bloodPressure,
    this.pulseRate,
    this.oxygenSaturation,
    this.weight,
    this.diagnosis,
    this.treatmentProvided,
    this.medicationsGiven = const [],
    this.observationNotes,
    this.followUpRequired = false,
    required this.outcome,
    required this.recordedBy,
    this.schoolId,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    staffId,
    dateTime,
    reason,
    symptoms,
    temperature,
    bloodPressure,
    pulseRate,
    oxygenSaturation,
    weight,
    diagnosis,
    treatmentProvided,
    medicationsGiven,
    observationNotes,
    followUpRequired,
    outcome,
    recordedBy,
    schoolId,
  ];
}

class AdministeredMedication extends Equatable {
  final String medicationId;
  final String medicationName;
  final String dosage;
  final int quantity;
  final DateTime timeAdministered;
  final String administeredBy;
  final String? notes;

  const AdministeredMedication({
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    this.quantity = 1,
    required this.timeAdministered,
    required this.administeredBy,
    this.notes,
  });

  @override
  List<Object?> get props => [
    medicationId,
    medicationName,
    dosage,
    quantity,
    timeAdministered,
    administeredBy,
    notes,
  ];
}
