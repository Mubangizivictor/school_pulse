import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/features/relationships/domain/entities/parent_student_relationship.dart';
import 'package:school_pulse/features/relationships/domain/entities/relationship_enums.dart';
import 'package:school_pulse/features/relationships/domain/repositories/relationship_repository.dart';
import 'package:school_pulse/features/relationships/domain/usecases/reallocate_relationship.dart';

class MockRelationshipRepository extends Mock
    implements RelationshipRepository {}

void main() {
  late ReallocateRelationship usecase;
  late MockRelationshipRepository repository;

  const schoolId = 'school-1';
  const relationshipId = 'rel-1';
  const reallocatedBy = 'admin-1';

  final replacement = ParentStudentRelationship(
    id: 'rel-2',
    schoolId: schoolId,
    studentId: 'student-1',
    type: RelationshipType.guardian,
    status: RelationshipStatus.active,
    createdBy: reallocatedBy,
    createdAt: DateTime(2026, 1, 1),
    previousRelationshipId: relationshipId,
  );

  setUp(() {
    repository = MockRelationshipRepository();
    usecase = ReallocateRelationship(repository);
  });

  test('rejects an empty reason without touching the repository', () async {
    final result = await usecase(
      const ReallocateRelationshipParams(
        schoolId: schoolId,
        relationshipId: relationshipId,
        reason: '   ',
        reallocatedBy: reallocatedBy,
      ),
    );

    expect(result.isLeft(), isTrue);
    verifyNever(
      () => repository.reallocateRelationship(
        schoolId: any(named: 'schoolId'),
        relationshipId: any(named: 'relationshipId'),
        reason: any(named: 'reason'),
        reallocatedBy: any(named: 'reallocatedBy'),
      ),
    );
  });

  test('trims the reason and delegates to the repository', () async {
    when(
      () => repository.reallocateRelationship(
        schoolId: schoolId,
        relationshipId: relationshipId,
        reason: 'custody change',
        reallocatedBy: reallocatedBy,
        newUserId: any(named: 'newUserId'),
        newType: any(named: 'newType'),
      ),
    ).thenAnswer((_) async => Right(replacement));

    final result = await usecase(
      const ReallocateRelationshipParams(
        schoolId: schoolId,
        relationshipId: relationshipId,
        reason: '  custody change  ',
        reallocatedBy: reallocatedBy,
      ),
    );

    expect(result, Right(replacement));
  });

  test('propagates a repository failure', () async {
    when(
      () => repository.reallocateRelationship(
        schoolId: schoolId,
        relationshipId: relationshipId,
        reason: 'custody change',
        reallocatedBy: reallocatedBy,
        newUserId: any(named: 'newUserId'),
        newType: any(named: 'newType'),
      ),
    ).thenAnswer((_) async => Left(ServerFailure('not found')));

    final result = await usecase(
      const ReallocateRelationshipParams(
        schoolId: schoolId,
        relationshipId: relationshipId,
        reason: 'custody change',
        reallocatedBy: reallocatedBy,
      ),
    );

    expect(result, Left(ServerFailure('not found')));
  });
}
