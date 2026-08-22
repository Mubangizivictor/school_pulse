import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/student/data/enrollment_setup/repositories/enrollment_setup_repository_impl.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/dormitory_assignment.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/entities/student_club_membership.dart';
import 'package:school_pulse/features/student/domain/enrollment_setup/repositories/enrollment_setup_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late EnrollmentSetupRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = EnrollmentSetupRepositoryImpl(firestore: firestore);
  });

  group('assignDormitory - duplicate bed prevention', () {
    test('assigns a fresh bed successfully', () async {
      final result = await repository.assignDormitory(
        DormitoryAssignment(
          id: '',
          studentId: 'student-1',
          schoolId: 'school-1',
          hostelId: 'hostel-1',
          roomId: 'room-1',
          bed: 'A1',
          assignedAt: DateTime.now(),
          assignedBy: 'staff-1',
        ),
      );

      expect(result.isRight(), true);
      result.fold((_) => fail('expected success'), (assignment) {
        expect(assignment.bed, 'A1');
        expect(assignment.studentId, 'student-1');
      });
    });

    test(
      'refuses to assign the same hostel+room+bed to a different student',
      () async {
        await repository.assignDormitory(
          DormitoryAssignment(
            id: '',
            studentId: 'student-1',
            schoolId: 'school-1',
            hostelId: 'hostel-1',
            roomId: 'room-1',
            bed: 'A1',
            assignedAt: DateTime.now(),
            assignedBy: 'staff-1',
          ),
        );

        final secondResult = await repository.assignDormitory(
          DormitoryAssignment(
            id: '',
            studentId: 'student-2',
            schoolId: 'school-1',
            hostelId: 'hostel-1',
            roomId: 'room-1',
            bed: 'A1',
            assignedAt: DateTime.now(),
            assignedBy: 'staff-1',
          ),
        );

        expect(secondResult.isLeft(), true);
        secondResult.fold(
          (failure) => expect(failure, isA<BedAlreadyAssignedFailure>()),
          (_) => fail('expected BedAlreadyAssignedFailure'),
        );

        // Never overwritten - only the original assignment doc exists.
        final snap = await firestore
            .collection('dormitory_assignments')
            .where('hostelId', isEqualTo: 'hostel-1')
            .where('roomId', isEqualTo: 'room-1')
            .where('bed', isEqualTo: 'A1')
            .get();
        expect(snap.docs.length, 1);
        expect(snap.docs.first.data()['studentId'], 'student-1');
      },
    );

    test(
      'retrying the same assignment for the same student is idempotent',
      () async {
        final assignment = DormitoryAssignment(
          id: '',
          studentId: 'student-1',
          schoolId: 'school-1',
          hostelId: 'hostel-1',
          roomId: 'room-1',
          bed: 'A1',
          assignedAt: DateTime.now(),
          assignedBy: 'staff-1',
        );

        await repository.assignDormitory(assignment);
        final retryResult = await repository.assignDormitory(assignment);

        expect(retryResult.isRight(), true);

        final snap = await firestore
            .collection('dormitory_assignments')
            .where('hostelId', isEqualTo: 'hostel-1')
            .where('roomId', isEqualTo: 'room-1')
            .where('bed', isEqualTo: 'A1')
            .get();
        expect(snap.docs.length, 1);
      },
    );

    test('a different bed in the same room can be assigned', () async {
      await repository.assignDormitory(
        DormitoryAssignment(
          id: '',
          studentId: 'student-1',
          schoolId: 'school-1',
          hostelId: 'hostel-1',
          roomId: 'room-1',
          bed: 'A1',
          assignedAt: DateTime.now(),
          assignedBy: 'staff-1',
        ),
      );

      final result = await repository.assignDormitory(
        DormitoryAssignment(
          id: '',
          studentId: 'student-2',
          schoolId: 'school-1',
          hostelId: 'hostel-1',
          roomId: 'room-1',
          bed: 'A2',
          assignedAt: DateTime.now(),
          assignedBy: 'staff-1',
        ),
      );

      expect(result.isRight(), true);
    });
  });

  group('joinClub - idempotency', () {
    test('joining the same club twice does not duplicate membership', () async {
      final membership = StudentClubMembership(
        id: '',
        studentId: 'student-1',
        schoolId: 'school-1',
        clubId: 'club-1',
        joinedAt: DateTime.now(),
      );
      await repository.joinClub(membership);
      await repository.joinClub(membership);

      final memberships = await repository.getClubMemberships(
        'school-1',
        'student-1',
      );
      memberships.fold(
        (_) => fail('expected success'),
        (list) => expect(list.length, 1),
      );
    });
  });
}
