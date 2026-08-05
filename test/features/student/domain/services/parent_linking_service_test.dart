import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/relationships/domain/entities/parent_student_relationship.dart';
import 'package:school_pulse/features/relationships/domain/entities/relationship_enums.dart';
import 'package:school_pulse/features/relationships/domain/usecases/create_relationship.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student/domain/services/parent_linking_service.dart';

class MockStudentRepository extends Mock implements StudentRepository {}

class MockCreateRelationship extends Mock implements CreateRelationship {}

void main() {
  late ParentLinkingService service;
  late MockStudentRepository repository;
  late MockCreateRelationship createRelationship;

  const schoolId = 'school-1';
  const phone = '0700000000';
  const createdBy = 'staff-1';

  setUpAll(() {
    registerFallbackValue(
      const ParentAccessCode(
        id: 'fallback',
        parentCode: 'fallback',
        schoolId: schoolId,
        studentIds: [],
        studentNames: [],
      ),
    );
    registerFallbackValue(
      const CreateRelationshipParams(
        schoolId: schoolId,
        studentId: 'fallback',
        type: RelationshipType.parent,
        createdBy: createdBy,
      ),
    );
  });

  setUp(() {
    repository = MockStudentRepository();
    createRelationship = MockCreateRelationship();
    service = ParentLinkingService(repository, createRelationship);
    when(() => createRelationship(any())).thenAnswer(
      (_) async => Right(
        ParentStudentRelationship(
          id: 'rel-1',
          schoolId: schoolId,
          studentId: 'student',
          type: RelationshipType.parent,
          createdBy: createdBy,
          createdAt: DateTime(2026, 1, 1),
        ),
      ),
    );
  });

  group('findExistingCodeForPhone', () {
    test('returns null when no code matches the phone number', () async {
      when(
        () => repository.getAllAccessCodes(schoolId: schoolId),
      ).thenAnswer((_) async => const Right([]));

      final result = await service.findExistingCodeForPhone(
        schoolId: schoolId,
        phoneNumber: phone,
      );

      expect(result, const Right<Failure, ParentAccessCode?>(null));
    });

    test('returns the matching code when one exists', () async {
      const code = ParentAccessCode(
        id: 'code-1',
        parentCode: 'SMAC000001',
        schoolId: schoolId,
        studentIds: ['student-1'],
        studentNames: ['Existing Sibling'],
        phoneNumber: phone,
      );
      when(
        () => repository.getAllAccessCodes(schoolId: schoolId),
      ).thenAnswer((_) async => const Right([code]));

      final result = await service.findExistingCodeForPhone(
        schoolId: schoolId,
        phoneNumber: phone,
      );

      expect(result.getOrElse(() => null)?.parentCode, 'SMAC000001');
    });
  });

  group('linkStudentToParent', () {
    test(
      'creates a new access code when the phone has no existing code',
      () async {
        when(
          () => repository.getAllAccessCodes(schoolId: schoolId),
        ).thenAnswer((_) async => const Right([]));
        when(
          () => repository.createAccessCode(
            studentIds: ['student-2'],
            schoolId: schoolId,
            phoneNumber: phone,
            parentName: 'New Parent',
          ),
        ).thenAnswer((_) async => const Right('SMAC000002'));

        final result = await service.linkStudentToParent(
          studentId: 'student-2',
          studentName: 'New Student',
          schoolId: schoolId,
          createdBy: createdBy,
          phoneNumber: phone,
          parentName: 'New Parent',
        );

        expect(result, const Right('SMAC000002'));
        verifyNever(() => repository.updateAccessCode(any()));
      },
    );

    test(
      'adds the student to an existing sibling code instead of creating a duplicate',
      () async {
        const existing = ParentAccessCode(
          id: 'code-1',
          parentCode: 'SMAC000001',
          schoolId: schoolId,
          studentIds: ['student-1'],
          studentNames: ['Existing Sibling'],
          phoneNumber: phone,
          parentName: 'Existing Parent',
        );
        when(
          () => repository.getAllAccessCodes(schoolId: schoolId),
        ).thenAnswer((_) async => const Right([existing]));
        when(
          () => repository.updateAccessCode(any()),
        ).thenAnswer((_) async => const Right(null));

        final result = await service.linkStudentToParent(
          studentId: 'student-2',
          studentName: 'New Sibling',
          schoolId: schoolId,
          createdBy: createdBy,
          phoneNumber: phone,
          parentName: 'New Parent',
        );

        expect(result, const Right('SMAC000001'));
        verifyNever(
          () => repository.createAccessCode(
            studentIds: any(named: 'studentIds'),
            schoolId: any(named: 'schoolId'),
            phoneNumber: any(named: 'phoneNumber'),
            parentName: any(named: 'parentName'),
          ),
        );
        final captured = verify(
          () => repository.updateAccessCode(captureAny()),
        ).captured;
        final updated = captured.single as ParentAccessCode;
        expect(updated.studentIds, ['student-1', 'student-2']);
        expect(updated.studentNames, ['Existing Sibling', 'New Sibling']);
      },
    );

    test(
      'is idempotent when the student is already linked to the code',
      () async {
        const existing = ParentAccessCode(
          id: 'code-1',
          parentCode: 'SMAC000001',
          schoolId: schoolId,
          studentIds: ['student-1', 'student-2'],
          studentNames: ['A', 'B'],
          phoneNumber: phone,
        );
        when(
          () => repository.getAllAccessCodes(schoolId: schoolId),
        ).thenAnswer((_) async => const Right([existing]));

        final result = await service.linkStudentToParent(
          studentId: 'student-2',
          studentName: 'B',
          schoolId: schoolId,
          createdBy: createdBy,
          phoneNumber: phone,
        );

        expect(result, const Right('SMAC000001'));
        verifyNever(() => repository.updateAccessCode(any()));
      },
    );
  });
}
