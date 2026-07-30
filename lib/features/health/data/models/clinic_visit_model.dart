import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/clinic_visit.dart';

DateTime _readDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

class ClinicVisitModel extends ClinicVisit {
  const ClinicVisitModel({
    required super.id,
    required super.studentId,
    super.staffId,
    required super.dateTime,
    required super.reason,
    required super.symptoms,
    super.temperature,
    super.bloodPressure,
    super.pulseRate,
    super.oxygenSaturation,
    super.weight,
    super.diagnosis,
    super.treatmentProvided,
    super.medicationsGiven,
    super.observationNotes,
    super.followUpRequired,
    required super.outcome,
    required super.recordedBy,
    super.schoolId,
  });

  factory ClinicVisitModel.fromJson(Map<String, dynamic> json) {
    return ClinicVisitModel(
      id: json['id'] as String? ?? '',
      studentId: json['studentId'] as String,
      staffId: json['staffId'] as String?,
      dateTime: _readDateTime(json['dateTime']),
      reason: json['reason'] as String,
      symptoms: json['symptoms'] as String,
      temperature: (json['temperature'] as num?)?.toDouble(),
      bloodPressure: json['bloodPressure'] as String?,
      pulseRate: json['pulseRate'] as int?,
      oxygenSaturation: json['oxygenSaturation'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      diagnosis: json['diagnosis'] as String?,
      treatmentProvided: json['treatmentProvided'] as String?,
      medicationsGiven:
          (json['medicationsGiven'] as List?)
              ?.map(
                (e) => AdministeredMedicationModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
      observationNotes: json['observationNotes'] as String?,
      followUpRequired: json['followUpRequired'] as bool? ?? false,
      outcome: VisitOutcome.values.firstWhere(
        (e) => e.toString() == json['outcome'],
        orElse: () => VisitOutcome.sentBackToClass,
      ),
      recordedBy: json['recordedBy'] as String? ?? '',
      schoolId: json['schoolId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'staffId': staffId,
      'dateTime': Timestamp.fromDate(dateTime),
      'reason': reason,
      'symptoms': symptoms,
      'temperature': temperature,
      'bloodPressure': bloodPressure,
      'pulseRate': pulseRate,
      'oxygenSaturation': oxygenSaturation,
      'weight': weight,
      'diagnosis': diagnosis,
      'treatmentProvided': treatmentProvided,
      'medicationsGiven': medicationsGiven
          .map(
            (medication) => medication is AdministeredMedicationModel
                ? medication.toJson()
                : {
                    'medicationId': medication.medicationId,
                    'medicationName': medication.medicationName,
                    'dosage': medication.dosage,
                    'timeAdministered': Timestamp.fromDate(
                      medication.timeAdministered,
                    ),
                    'administeredBy': medication.administeredBy,
                    'notes': medication.notes,
                  },
          )
          .toList(),
      'observationNotes': observationNotes,
      'followUpRequired': followUpRequired,
      'outcome': outcome.toString(),
      'recordedBy': recordedBy,
      'schoolId': schoolId,
    };
  }
}

class AdministeredMedicationModel extends AdministeredMedication {
  const AdministeredMedicationModel({
    required super.medicationId,
    required super.medicationName,
    required super.dosage,
    required super.timeAdministered,
    required super.administeredBy,
    super.notes,
  });

  factory AdministeredMedicationModel.fromJson(Map<String, dynamic> json) {
    return AdministeredMedicationModel(
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String,
      timeAdministered: _readDateTime(json['timeAdministered']),
      administeredBy: json['administeredBy'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
      'timeAdministered': Timestamp.fromDate(timeAdministered),
      'administeredBy': administeredBy,
      'notes': notes,
    };
  }
}
