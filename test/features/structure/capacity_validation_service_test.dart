import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/services/capacity_validation_service.dart';

void main() {
  final service = const CapacityValidationService();

  const schoolId = 'school-1';
  final baseClass = SchoolClass(
    id: 'class-1',
    schoolId: schoolId,
    name: 'Primary 1',
    capacity: 50,
  );

  ClassStream stream({
    required String id,
    required int capacity,
    bool isActive = true,
    String name = '',
    String code = '',
    String classId = 'class-1',
    String schoolId = schoolId,
  }) => ClassStream(
    id: id,
    schoolId: schoolId,
    name: name.isEmpty ? id : name,
    code: code,
    classId: classId,
    capacity: capacity,
    isActive: isActive,
  );

  group('acceptance scenario: class capacity 50', () {
    test('Blue = 30 succeeds', () {
      final result = service.validateStreamSave(
        candidate: stream(id: 'blue', capacity: 30),
        existingStreams: const [],
        classes: [baseClass],
      );
      expect(result.isValid, isTrue);
    });

    test('Red = 25 fails because total would be 55', () {
      final blue = stream(id: 'blue', capacity: 30);
      final result = service.validateStreamSave(
        candidate: stream(id: 'red', capacity: 25),
        existingStreams: [blue],
        classes: [baseClass],
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Class capacity: 50'));
      expect(result.errorMessage, contains('already allocated: 30'));
      expect(result.errorMessage, contains('available: 20'));
    });

    test('Red = 20 succeeds', () {
      final blue = stream(id: 'blue', capacity: 30);
      final result = service.validateStreamSave(
        candidate: stream(id: 'red', capacity: 20),
        existingStreams: [blue],
        classes: [baseClass],
      );
      expect(result.isValid, isTrue);
    });

    test('reducing class capacity to 40 fails because streams total 50', () {
      final blue = stream(id: 'blue', capacity: 30);
      final red = stream(id: 'red', capacity: 20);
      final result = service.validateClassCapacityChange(
        candidate: baseClass,
        newCapacity: 40,
        streams: [blue, red],
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('cannot be reduced below 50'));
    });

    test(
      'after deactivating Blue, allocated capacity becomes 20 and class '
      'capacity 40 may save',
      () {
        final blueInactive = stream(id: 'blue', capacity: 30, isActive: false);
        final red = stream(id: 'red', capacity: 20);
        expect(
          service.activeStreamCapacity([blueInactive, red], 'class-1'),
          20,
        );
        final result = service.validateClassCapacityChange(
          candidate: baseClass,
          newCapacity: 40,
          streams: [blueInactive, red],
        );
        expect(result.isValid, isTrue);
      },
    );
  });

  group('capacity edge cases', () {
    test('class capacity 0 means unlimited - no enforcement', () {
      final unlimitedClass = baseClass.copyWith(capacity: 0);
      final result = service.validateStreamSave(
        candidate: stream(id: 'blue', capacity: 1000),
        existingStreams: const [],
        classes: [unlimitedClass],
      );
      expect(result.isValid, isTrue);
    });

    test('inactive stream candidate is excluded from capacity check', () {
      final blue = stream(id: 'blue', capacity: 30);
      final result = service.validateStreamSave(
        candidate: stream(id: 'red', capacity: 1000, isActive: false),
        existingStreams: [blue],
        classes: [baseClass],
      );
      expect(result.isValid, isTrue);
    });

    test('editing a stream excludes its own prior capacity from the sum', () {
      final blue = stream(id: 'blue', capacity: 30);
      // Editing blue itself up to 50 should succeed (no double count).
      final result = service.validateStreamSave(
        candidate: stream(id: 'blue', capacity: 50),
        existingStreams: [blue],
        classes: [baseClass],
      );
      expect(result.isValid, isTrue);
    });

    test('duplicate stream name within same class is rejected', () {
      final blue = stream(id: 'blue', capacity: 10, name: 'Blue', code: 'BL');
      final result = service.validateStreamSave(
        candidate: stream(id: 'blue-2', capacity: 5, name: 'Blue', code: 'B2'),
        existingStreams: [blue],
        classes: [baseClass],
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('already exists'));
    });

    test('duplicate stream code within same class is rejected', () {
      final blue = stream(id: 'blue', capacity: 10, name: 'Blue', code: 'BL');
      final result = service.validateStreamSave(
        candidate: stream(id: 'blue-2', capacity: 5, name: 'Azure', code: 'BL'),
        existingStreams: [blue],
        classes: [baseClass],
      );
      expect(result.isValid, isFalse);
    });

    test('same name allowed across different classes', () {
      final otherClass = baseClass.copyWith(id: 'class-2');
      final blueInOther = stream(
        id: 'blue-other',
        capacity: 10,
        name: 'Blue',
        classId: 'class-2',
      );
      final result = service.validateStreamSave(
        candidate: stream(id: 'blue', capacity: 10, name: 'Blue'),
        existingStreams: [blueInOther],
        classes: [baseClass, otherClass],
      );
      expect(result.isValid, isTrue);
    });

    test('stream referencing a class from another school is rejected', () {
      final otherSchoolClass = baseClass.copyWith(schoolId: 'school-2');
      final result = service.validateStreamSave(
        candidate: stream(
          id: 'blue',
          capacity: 10,
          classId: otherSchoolClass.id,
          schoolId: schoolId,
        ),
        existingStreams: const [],
        classes: [otherSchoolClass],
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('different school'));
    });

    test('stream referencing a nonexistent class is rejected', () {
      final result = service.validateStreamSave(
        candidate: stream(id: 'blue', capacity: 10, classId: 'missing'),
        existingStreams: const [],
        classes: [baseClass],
      );
      expect(result.isValid, isFalse);
    });

    test('reducing class capacity when no streams exist always succeeds', () {
      final result = service.validateClassCapacityChange(
        candidate: baseClass,
        newCapacity: 1,
        streams: const [],
      );
      expect(result.isValid, isTrue);
    });

    test('class capacity change to 0 (unlimited) always succeeds', () {
      final blue = stream(id: 'blue', capacity: 30);
      final result = service.validateClassCapacityChange(
        candidate: baseClass,
        newCapacity: 0,
        streams: [blue],
      );
      expect(result.isValid, isTrue);
    });
  });

  group('enrollment checks', () {
    test('enrollment within capacity succeeds', () {
      final result = service.validateEnrollment(
        capacity: 30,
        currentEnrollment: 20,
        additionalStudents: 5,
        label: 'Blue',
      );
      expect(result.isValid, isTrue);
    });

    test('enrollment exceeding capacity fails', () {
      final result = service.validateEnrollment(
        capacity: 30,
        currentEnrollment: 28,
        additionalStudents: 5,
        label: 'Blue',
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Capacity: 30'));
    });

    test('capacity 0 means unlimited enrollment', () {
      final result = service.validateEnrollment(
        capacity: 0,
        currentEnrollment: 1000,
        additionalStudents: 5,
        label: 'Blue',
      );
      expect(result.isValid, isTrue);
    });
  });

  group('class/stream enrollment reconciliation', () {
    test('matching totals succeed', () {
      final result = service.validateClassStreamReconciliation(
        classEnrolledTotal: 50,
        streamsEnrolledTotal: 50,
        classHasStreams: true,
      );
      expect(result.isValid, isTrue);
    });

    test('mismatched totals fail', () {
      final result = service.validateClassStreamReconciliation(
        classEnrolledTotal: 50,
        streamsEnrolledTotal: 45,
        classHasStreams: true,
      );
      expect(result.isValid, isFalse);
    });

    test('no streams skips reconciliation entirely', () {
      final result = service.validateClassStreamReconciliation(
        classEnrolledTotal: 50,
        streamsEnrolledTotal: 0,
        classHasStreams: false,
      );
      expect(result.isValid, isTrue);
    });
  });
}
