import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/parent_access/presentation/bloc/parent_access_cubit.dart';
import 'package:school_pulse/features/parent_access/presentation/bloc/parent_access_state.dart';
import 'package:school_pulse/features/relationships/domain/entities/parent_student_relationship.dart';
import 'package:school_pulse/features/relationships/domain/entities/people_policy.dart';
import 'package:school_pulse/features/relationships/domain/entities/relationship_enums.dart';
import 'package:school_pulse/features/relationships/domain/repositories/relationship_repository.dart';
import 'package:school_pulse/features/relationships/domain/usecases/get_people_policy.dart';
import 'package:school_pulse/features/relationships/domain/usecases/get_relationships_for_parent.dart';
import 'package:school_pulse/features/structure/domain/entities/feature_toggles.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_event.dart';

class MockRelationshipRepository extends Mock
    implements RelationshipRepository {}

class MockStructureRepository extends Mock implements StructureRepository {}

void main() {
  const schoolId = 'school-1';
  const parentUserId = 'parent-1';

  late MockRelationshipRepository relationshipRepository;
  late MockStructureRepository structureRepository;
  late GetRelationshipsForParent getRelationshipsForParent;
  late GetPeoplePolicy getPeoplePolicy;
  late SelectedStudentBloc selectedStudentBloc;

  Student buildStudent(String id) {
    return Student(
      id: id,
      schoolId: schoolId,
      name: 'Student $id',
      studentCode: 'SC-$id',
      admissionNumber: 'AD-$id',
      dateOfBirth: DateTime(2015, 1, 1),
      gender: Gender.male,
      classId: 'class-1',
      academicYearId: 'year-1',
      status: StudentStatus.active,
      level: EducationLevel.primary,
    );
  }

  ParentStudentRelationship buildRelationship({
    required String studentId,
    bool financialAccess = false,
    bool academicAccess = true,
  }) {
    return ParentStudentRelationship(
      id: 'rel-$studentId',
      schoolId: schoolId,
      studentId: studentId,
      userId: parentUserId,
      type: RelationshipType.parent,
      financialAccess: financialAccess,
      academicAccess: academicAccess,
      createdBy: 'staff-1',
      createdAt: DateTime(2026, 1, 1),
    );
  }

  setUp(() {
    relationshipRepository = MockRelationshipRepository();
    structureRepository = MockStructureRepository();
    getRelationshipsForParent = GetRelationshipsForParent(
      relationshipRepository,
    );
    getPeoplePolicy = GetPeoplePolicy(relationshipRepository);
    selectedStudentBloc = SelectedStudentBloc();

    when(
      () => relationshipRepository.getPeoplePolicy(schoolId),
    ).thenAnswer((_) async => Right(PeoplePolicy.defaultFor(schoolId)));
    when(
      () => structureRepository.watchFeatureToggles(schoolId),
    ).thenAnswer((_) => Stream.value(const FeatureToggles()));
  });

  tearDown(() {
    selectedStudentBloc.close();
  });

  test('resolves full access for a guardian relationship', () async {
    final student = buildStudent('student-1');
    when(
      () => relationshipRepository.getRelationshipsForParent(
        schoolId,
        parentUserId,
      ),
    ).thenAnswer(
      (_) async => Right([
        buildRelationship(studentId: student.id, financialAccess: true),
      ]),
    );

    final cubit = ParentAccessCubit(
      getRelationshipsForParent: getRelationshipsForParent,
      getPeoplePolicy: getPeoplePolicy,
      structureRepository: structureRepository,
      parentUserId: parentUserId,
      selectedStudentBloc: selectedStudentBloc,
    );

    selectedStudentBloc.add(SelectStudent(student));
    await pumpEventQueue();

    final state = cubit.state;
    expect(state, isA<ParentAccessResolved>());
    expect((state as ParentAccessResolved).visibility.academics, isTrue);
    expect(state.visibility.fees, isTrue);

    await cubit.close();
  });

  test(
    'denies access when no relationship exists for the selected child',
    () async {
      final student = buildStudent('student-2');
      when(
        () => relationshipRepository.getRelationshipsForParent(
          schoolId,
          parentUserId,
        ),
      ).thenAnswer((_) async => Right(<ParentStudentRelationship>[]));

      final cubit = ParentAccessCubit(
        getRelationshipsForParent: getRelationshipsForParent,
        getPeoplePolicy: getPeoplePolicy,
        structureRepository: structureRepository,
        parentUserId: parentUserId,
        selectedStudentBloc: selectedStudentBloc,
      );

      selectedStudentBloc.add(SelectStudent(student));
      await pumpEventQueue();

      expect(cubit.state, isA<ParentAccessDenied>());

      await cubit.close();
    },
  );

  test(
    're-resolves and does not leak previous child visibility on switch',
    () async {
      final studentA = buildStudent('student-a');
      final studentB = buildStudent('student-b');

      when(
        () => relationshipRepository.getRelationshipsForParent(
          schoolId,
          parentUserId,
        ),
      ).thenAnswer(
        (_) async => Right([
          buildRelationship(
            studentId: studentA.id,
            financialAccess: true,
            academicAccess: true,
          ),
          buildRelationship(
            studentId: studentB.id,
            financialAccess: false,
            academicAccess: false,
          ),
        ]),
      );

      final cubit = ParentAccessCubit(
        getRelationshipsForParent: getRelationshipsForParent,
        getPeoplePolicy: getPeoplePolicy,
        structureRepository: structureRepository,
        parentUserId: parentUserId,
        selectedStudentBloc: selectedStudentBloc,
      );

      selectedStudentBloc.add(SelectStudent(studentA));
      await pumpEventQueue();
      final stateA = cubit.state as ParentAccessResolved;
      expect(stateA.visibility.fees, isTrue);
      expect(stateA.visibility.academics, isTrue);

      selectedStudentBloc.add(SelectStudent(studentB));
      await pumpEventQueue();
      final stateB = cubit.state as ParentAccessResolved;
      expect(stateB.studentId, studentB.id);
      expect(stateB.visibility.fees, isFalse);
      expect(stateB.visibility.academics, isFalse);

      await cubit.close();
    },
  );
}
