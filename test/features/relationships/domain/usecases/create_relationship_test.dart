import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/relationships/domain/entities/parent_student_relationship.dart';
import 'package:school_pulse/features/relationships/domain/entities/people_policy.dart';
import 'package:school_pulse/features/relationships/domain/entities/relationship_enums.dart';
import 'package:school_pulse/features/relationships/domain/repositories/relationship_repository.dart';
import 'package:school_pulse/features/relationships/domain/usecases/create_relationship.dart';

class MockRelationshipRepository extends Mock implements RelationshipRepository {}

void main() {
  late CreateRelationship usecase;
  late MockRelationshipRepository repository;

  const schoolId = 'school-1';
  const studentId = 'student-1';
  const createdBy = 'staff-1';

  ParentStudentRelationship buildRelationship({
    RelationshipType type = RelationshipType.parent,
    RelationshipStatus status = RelationshipStatus.active,
  }) {
    return ParentStudentRelationship(
      id: 'rel-1',
      schoolId: schoolId,
      studentId: studentId,
      type: type,
      status: status,
      createdBy: createdBy,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  setUpAll(() {
    registerFallbackValue(RelationshipType.parent);
  });

  setUp(() {
    repository = MockRelationshipRepository();
    usecase = CreateRelationship(repository);
  });

  test('creates a relationship when the student is under the guardian limit', () async {
    when(() => repository.getPeoplePolicy(schoolId))
        .thenAnswer((_) async => Right(const PeoplePolicy(schoolId: schoolId, maxStandardGuardians: 2)));
    when(() => repository.getRelationshipsForStudent(schoolId, studentId))
        .thenAnswer((_) async => const Right([]));
    when(() => repository.createRelationship(
          schoolId: schoolId,
          studentId: studentId,
          userId: any(named: 'userId'),
          parentCode: any(named: 'parentCode'),
          type: RelationshipType.parent,
          isLegalGuardian: any(named: 'isLegalGuardian'),
          isPrimaryGuardian: any(named: 'isPrimaryGuardian'),
          createdBy: createdBy,
        )).thenAnswer((_) async => Right(buildRelationship()));

    final result = await usecase(const CreateRelationshipParams(
      schoolId: schoolId,
      studentId: studentId,
      type: RelationshipType.parent,
      createdBy: createdBy,
    ));

    expect(result.isRight(), isTrue);
  });

  test('rejects a new standard guardian once the policy limit is reached', () async {
    when(() => repository.getPeoplePolicy(schoolId))
        .thenAnswer((_) async => Right(const PeoplePolicy(schoolId: schoolId, maxStandardGuardians: 2)));
    when(() => repository.getRelationshipsForStudent(schoolId, studentId)).thenAnswer(
      (_) async => Right([
        buildRelationship(type: RelationshipType.parent),
        buildRelationship(type: RelationshipType.guardian),
      ]),
    );

    final result = await usecase(const CreateRelationshipParams(
      schoolId: schoolId,
      studentId: studentId,
      type: RelationshipType.parent,
      createdBy: createdBy,
    ));

    expect(result.isLeft(), isTrue);
    expect(result.fold((f) => f, (_) => null), isA<GuardianLimitExceededFailure>());
    verifyNever(() => repository.createRelationship(
          schoolId: any(named: 'schoolId'),
          studentId: any(named: 'studentId'),
          userId: any(named: 'userId'),
          parentCode: any(named: 'parentCode'),
          type: any(named: 'type'),
          isLegalGuardian: any(named: 'isLegalGuardian'),
          isPrimaryGuardian: any(named: 'isPrimaryGuardian'),
          createdBy: any(named: 'createdBy'),
        ));
  });

  test('superseded relationships do not count against the guardian limit', () async {
    when(() => repository.getPeoplePolicy(schoolId))
        .thenAnswer((_) async => Right(const PeoplePolicy(schoolId: schoolId, maxStandardGuardians: 2)));
    when(() => repository.getRelationshipsForStudent(schoolId, studentId)).thenAnswer(
      (_) async => Right([
        buildRelationship(type: RelationshipType.parent, status: RelationshipStatus.superseded),
        buildRelationship(type: RelationshipType.guardian),
      ]),
    );
    when(() => repository.createRelationship(
          schoolId: schoolId,
          studentId: studentId,
          userId: any(named: 'userId'),
          parentCode: any(named: 'parentCode'),
          type: RelationshipType.parent,
          isLegalGuardian: any(named: 'isLegalGuardian'),
          isPrimaryGuardian: any(named: 'isPrimaryGuardian'),
          createdBy: createdBy,
        )).thenAnswer((_) async => Right(buildRelationship()));

    final result = await usecase(const CreateRelationshipParams(
      schoolId: schoolId,
      studentId: studentId,
      type: RelationshipType.parent,
      createdBy: createdBy,
    ));

    expect(result.isRight(), isTrue);
  });

  test('non-standard relationship types (sponsor) bypass the guardian limit entirely', () async {
    when(() => repository.createRelationship(
          schoolId: schoolId,
          studentId: studentId,
          userId: any(named: 'userId'),
          parentCode: any(named: 'parentCode'),
          type: RelationshipType.sponsor,
          isLegalGuardian: any(named: 'isLegalGuardian'),
          isPrimaryGuardian: any(named: 'isPrimaryGuardian'),
          createdBy: createdBy,
        )).thenAnswer((_) async => Right(buildRelationship(type: RelationshipType.sponsor)));

    final result = await usecase(const CreateRelationshipParams(
      schoolId: schoolId,
      studentId: studentId,
      type: RelationshipType.sponsor,
      createdBy: createdBy,
    ));

    expect(result.isRight(), isTrue);
    verifyNever(() => repository.getPeoplePolicy(any()));
  });
}
