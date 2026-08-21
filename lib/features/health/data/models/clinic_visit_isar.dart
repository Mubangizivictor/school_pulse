import 'package:isar/isar.dart';
import '../../domain/entities/clinic_visit.dart';

part 'clinic_visit_isar.g.dart';

/// Local-first cache for nurse clinic visits, mirroring the
/// `AttendanceRecordIsar`/`GateIsar` Isar-first-write pattern: every visit
/// lands here immediately, then a push is attempted, so a recorded visit is
/// never lost to a dropped connection. `visitId` is a client-generated id
/// (see [ClinicVisit.id]) reused as the literal Firestore document id on
/// every push attempt, retried or not - a `.set()` on that same id is safe
/// to repeat.
@collection
class ClinicVisitIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String visitId;

  @Index()
  late String schoolId;
  @Index()
  late String studentId;
  String? staffId;
  @Index()
  late DateTime dateTime;
  late String reason;
  late String symptoms;
  double? temperature;
  String? bloodPressure;
  int? pulseRate;
  int? oxygenSaturation;
  double? weight;
  String? diagnosis;
  String? treatmentProvided;
  List<AdministeredMedicationIsar> medicationsGiven = const [];
  String? observationNotes;
  bool followUpRequired = false;
  late String outcome;
  late String recordedBy;
  @Index()
  late String syncStatus;

  ClinicVisitIsar();

  factory ClinicVisitIsar.fromEntity(ClinicVisit entity) {
    return ClinicVisitIsar()
      ..visitId = entity.id
      ..schoolId = entity.schoolId ?? ''
      ..studentId = entity.studentId
      ..staffId = entity.staffId
      ..dateTime = entity.dateTime
      ..reason = entity.reason
      ..symptoms = entity.symptoms
      ..temperature = entity.temperature
      ..bloodPressure = entity.bloodPressure
      ..pulseRate = entity.pulseRate
      ..oxygenSaturation = entity.oxygenSaturation
      ..weight = entity.weight
      ..diagnosis = entity.diagnosis
      ..treatmentProvided = entity.treatmentProvided
      ..medicationsGiven = entity.medicationsGiven
          .map(AdministeredMedicationIsar.fromEntity)
          .toList()
      ..observationNotes = entity.observationNotes
      ..followUpRequired = entity.followUpRequired
      ..outcome = entity.outcome.name
      ..recordedBy = entity.recordedBy
      ..syncStatus = HealthSyncStatus.pending.name;
  }

  ClinicVisit toEntity() {
    return ClinicVisit(
      id: visitId,
      studentId: studentId,
      staffId: staffId,
      dateTime: dateTime,
      reason: reason,
      symptoms: symptoms,
      temperature: temperature,
      bloodPressure: bloodPressure,
      pulseRate: pulseRate,
      oxygenSaturation: oxygenSaturation,
      weight: weight,
      diagnosis: diagnosis,
      treatmentProvided: treatmentProvided,
      medicationsGiven: medicationsGiven.map((m) => m.toEntity()).toList(),
      observationNotes: observationNotes,
      followUpRequired: followUpRequired,
      outcome: VisitOutcome.values.firstWhere(
        (o) => o.name == outcome,
        orElse: () => VisitOutcome.sentBackToClass,
      ),
      recordedBy: recordedBy,
      schoolId: schoolId,
    );
  }
}

@embedded
class AdministeredMedicationIsar {
  String medicationId = '';
  String medicationName = '';
  String dosage = '';
  int quantity = 1;
  DateTime? timeAdministered;
  String administeredBy = '';
  String? notes;

  AdministeredMedicationIsar();

  factory AdministeredMedicationIsar.fromEntity(AdministeredMedication m) {
    return AdministeredMedicationIsar()
      ..medicationId = m.medicationId
      ..medicationName = m.medicationName
      ..dosage = m.dosage
      ..quantity = m.quantity
      ..timeAdministered = m.timeAdministered
      ..administeredBy = m.administeredBy
      ..notes = m.notes;
  }

  AdministeredMedication toEntity() {
    return AdministeredMedication(
      medicationId: medicationId,
      medicationName: medicationName,
      dosage: dosage,
      quantity: quantity,
      timeAdministered: timeAdministered ?? DateTime.fromMillisecondsSinceEpoch(0),
      administeredBy: administeredBy,
      notes: notes,
    );
  }
}

enum HealthSyncStatus { pending, synced }
