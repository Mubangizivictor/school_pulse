import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/relationships/data/datasources/relationship_remote_data_source.dart';
import 'package:school_pulse/features/relationships/data/models/parent_student_relationship_model.dart';
import 'package:school_pulse/features/relationships/data/repositories/relationship_repository_impl.dart';
import 'package:school_pulse/features/relationships/domain/entities/relationship_enums.dart';

class MockRelationshipRemoteDataSource extends Mock
    implements RelationshipRemoteDataSource {}

void main() {
  late RelationshipRepositoryImpl repository;
  late MockRelationshipRemoteDataSource dataSource;

  const schoolId = 'school-1';
  const relationshipId = 'rel-1';
  const reallocatedBy = 'admin-1';

  final existing = ParentStudentRelationshipModel.fromMap(relationshipId, {
    'schoolId': schoolId,
    'studentId': 'student-1',
    'userId': 'parent-old',
    'type': 'parent',
    'status': 'active',
    'createdBy': 'staff-1',
  });

  final replacement = ParentStudentRelationshipModel.fromMap('rel-2', {
    'schoolId': schoolId,
    'studentId': 'student-1',
    'userId': 'parent-new',
    'type': 'guardian',
    'status': 'active',
    'createdBy': reallocatedBy,
    'previousRelationshipId': relationshipId,
  });

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    dataSource = MockRelationshipRemoteDataSource();
    repository = RelationshipRepositoryImpl(remoteDataSource: dataSource);
  });

  test(
    'reallocateRelationship supersedes the old doc before creating the replacement',
    () async {
      final callOrder = <String>[];
      when(
        () => dataSource.getRelationshipById(relationshipId),
      ).thenAnswer((_) async => existing);
      when(
        () => dataSource.supersedeRelationship(relationshipId, any()),
      ).thenAnswer((_) async {
        callOrder.add('supersede');
      });
      when(() => dataSource.createRelationship(any())).thenAnswer((_) async {
        callOrder.add('create');
        return replacement;
      });

      final result = await repository.reallocateRelationship(
        schoolId: schoolId,
        relationshipId: relationshipId,
        reason: 'custody change',
        reallocatedBy: reallocatedBy,
        newUserId: 'parent-new',
        newType: RelationshipType.guardian,
      );

      expect(result.isRight(), isTrue);

      final supersedeCall = verify(
        () => dataSource.supersedeRelationship(relationshipId, captureAny()),
      ).captured;
      final supersedeData = supersedeCall.single as Map<String, dynamic>;
      expect(supersedeData['status'], 'superseded');
      expect(supersedeData['supersededBy'], reallocatedBy);
      expect(supersedeData['supersessionReason'], 'custody change');

      final createCall = verify(
        () => dataSource.createRelationship(captureAny()),
      ).captured;
      final createData = createCall.single as Map<String, dynamic>;
      expect(createData['status'], 'active');
      expect(createData['previousRelationshipId'], relationshipId);
      expect(createData['userId'], 'parent-new');
      expect(createData['type'], 'guardian');
      expect(callOrder, ['supersede', 'create']);
    },
  );

  test(
    'reallocation preserves access flags from the superseded relationship by default',
    () async {
      final existingWithFlags =
          ParentStudentRelationshipModel.fromMap(relationshipId, {
            'schoolId': schoolId,
            'studentId': 'student-1',
            'userId': 'parent-old',
            'type': 'parent',
            'status': 'active',
            'createdBy': 'staff-1',
            'pickupAuthorized': true,
            'medicalAccess': true,
          });
      when(
        () => dataSource.getRelationshipById(relationshipId),
      ).thenAnswer((_) async => existingWithFlags);
      when(
        () => dataSource.supersedeRelationship(relationshipId, any()),
      ).thenAnswer((_) async {});
      when(
        () => dataSource.createRelationship(any()),
      ).thenAnswer((_) async => replacement);

      await repository.reallocateRelationship(
        schoolId: schoolId,
        relationshipId: relationshipId,
        reason: 'reallocated',
        reallocatedBy: reallocatedBy,
      );

      final createCall = verify(
        () => dataSource.createRelationship(captureAny()),
      ).captured;
      final createData = createCall.single as Map<String, dynamic>;
      expect(createData['pickupAuthorized'], true);
      expect(createData['medicalAccess'], true);
      // userId/type default to the existing relationship's when not overridden.
      expect(createData['userId'], 'parent-old');
      expect(createData['type'], 'parent');
    },
  );

  test(
    'recordEnrolmentChange ends the previously active enrolment before opening the new one',
    () async {
      final callOrder = <String>[];
      when(
        () => dataSource.endActiveEnrolment(schoolId, 'student-1'),
      ).thenAnswer((_) async {
        callOrder.add('end');
      });
      when(() => dataSource.createEnrolment(any())).thenAnswer((_) async {
        callOrder.add('create');
      });

      final result = await repository.recordEnrolmentChange(
        schoolId: schoolId,
        studentId: 'student-1',
        classId: 'class-2',
        streamId: 'stream-b',
        academicYearId: 'ay-2026',
        recordedBy: 'staff-1',
        reason: 'promotion',
      );

      expect(result.isRight(), isTrue);
      expect(callOrder, ['end', 'create']);

      final createCall = verify(
        () => dataSource.createEnrolment(captureAny()),
      ).captured;
      final createData = createCall.single as Map<String, dynamic>;
      expect(createData['classId'], 'class-2');
      expect(createData['streamId'], 'stream-b');
      expect(createData['academicYearId'], 'ay-2026');
      expect(createData['status'], 'active');
      expect(createData['reason'], 'promotion');
      expect(createData['recordedBy'], 'staff-1');
    },
  );
}
