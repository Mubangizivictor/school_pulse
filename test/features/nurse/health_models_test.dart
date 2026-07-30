import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/health/data/models/clinic_visit_model.dart';
import 'package:school_pulse/features/health/data/models/student_health_profile_model.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/domain/entities/student_health_profile.dart';

void main() {
  group('Nurse health model serialization', () {
    test('serializes a vaccination added by the profile screen', () {
      final profile = StudentHealthProfileModel(
        studentId: 'student-1',
        schoolId: 'school-1',
        bloodGroup: 'O',
        emergencyContactName: 'Parent',
        emergencyContactPhone: '+256700000000',
        vaccinationHistory: [
          VaccinationRecord(
            id: 'vaccination-1',
            vaccineName: 'Tetanus',
            dateAdministered: DateTime(2026, 7, 30),
          ),
        ],
      );

      final json = profile.toJson();
      final vaccinations = json['vaccinationHistory'] as List<dynamic>;
      expect(vaccinations, hasLength(1));
      expect(
        (vaccinations.single as Map<String, dynamic>)['vaccineName'],
        'Tetanus',
      );
    });

    test('serializes medication entities without requiring a model cast', () {
      final visit = ClinicVisitModel(
        id: 'visit-1',
        studentId: 'student-1',
        dateTime: DateTime(2026, 7, 30),
        reason: 'Headache',
        symptoms: 'Pain',
        outcome: VisitOutcome.sentBackToClass,
        recordedBy: 'nurse-1',
        schoolId: 'school-1',
        medicationsGiven: [
          AdministeredMedication(
            medicationId: 'medication-1',
            medicationName: 'Paracetamol',
            dosage: '500 mg',
            timeAdministered: DateTime(2026, 7, 30, 9),
            administeredBy: 'nurse-1',
          ),
        ],
      );

      final json = visit.toJson();
      final medications = json['medicationsGiven'] as List<dynamic>;
      expect(medications, hasLength(1));
      expect(
        (medications.single as Map<String, dynamic>)['medicationName'],
        'Paracetamol',
      );
    });
  });
}
