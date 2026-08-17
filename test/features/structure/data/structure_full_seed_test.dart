import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/data/datasources/structure_remote_data_source.dart';
import 'package:school_pulse/features/structure/data/repositories/structure_setup_repository_impl.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/attendance_config_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/campus_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/feature_toggles.dart';
import 'package:school_pulse/features/structure/domain/entities/hostel_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/institution_profile.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_setup_preferences.dart';
import 'package:school_pulse/features/structure/domain/entities/timetable_config.dart';
import 'package:school_pulse/features/structure/domain/entities/transport_structure_entities.dart';

void main() {
  test(
    'realistic combined-school Structure persists through production serializers',
    () async {
      final firestore = FakeFirebaseFirestore();
      final remote = StructureRemoteDataSourceImpl(firestore: firestore);
      final setup = StructureSetupRepositoryImpl(
        firestore: firestore,
        schoolIdOverride: 'sp-structure-e2e-school',
      );

      await remote.updateInstitutionProfile(
        const InstitutionProfile(
          name: 'School Pulse Structure E2E Test School',
          shortName: 'SPTEST',
          schoolType: 'Combined Primary & Secondary',
          schoolCategory: 'Day & Boarding',
          country: 'Uganda',
          district: 'Wakiso',
          city: 'Wakiso',
          timeZone: 'Africa/Kampala',
          currency: 'UGX',
          language: 'English',
          dateFormat: 'dd/MM/yyyy',
          timeFormat: '24h',
        ),
      );
      await setup.savePreferences(
        const StructureSetupPreferences(
          departments: StructureUseChoice.enabled,
          streams: StructureUseChoice.enabled,
          rooms: StructureUseChoice.enabled,
          houses: StructureUseChoice.enabled,
          clubs: StructureUseChoice.enabled,
          boarding: StructureUseChoice.enabled,
          transport: StructureUseChoice.enabled,
        ),
      );
      await remote.updateFeatureToggles(
        const FeatureToggles(
          boarding: true,
          hostel: true,
          transport: true,
          communication: true,
        ),
      );

      await remote.saveAcademicYear(
        AcademicYear(
          id: '2026',
          name: '2026',
          startDate: DateTime(2026, 1, 20),
          endDate: DateTime(2026, 12, 10),
          isCurrent: true,
        ),
      );
      for (final term in [
        AcademicTerm(
          id: 't1',
          academicYearId: '2026',
          name: 'Term 1',
          order: 1,
          startDate: DateTime(2026, 2, 2),
          endDate: DateTime(2026, 5, 1),
          isCurrent: true,
        ),
        AcademicTerm(
          id: 't2',
          academicYearId: '2026',
          name: 'Term 2',
          order: 2,
          startDate: DateTime(2026, 5, 25),
          endDate: DateTime(2026, 8, 7),
        ),
        AcademicTerm(
          id: 't3',
          academicYearId: '2026',
          name: 'Term 3',
          order: 3,
          startDate: DateTime(2026, 9, 7),
          endDate: DateTime(2026, 12, 4),
        ),
      ]) {
        await remote.saveAcademicTerm(term);
      }

      await remote.saveLevel(
        const EducationalLevel(id: 'primary', name: 'Primary', code: 'PRI'),
      );
      await remote.saveLevel(
        const EducationalLevel(id: 'secondary', name: 'Secondary', code: 'SEC'),
      );
      await remote.saveDepartment(
        const Department(id: 'science', name: 'Sciences', code: 'SCI'),
      );
      await remote.saveDepartment(
        const Department(id: 'languages', name: 'Languages', code: 'LAN'),
      );

      await remote.saveClass(
        const SchoolClass(
          id: 'p5',
          name: 'Primary 5',
          code: 'P5',
          levelId: 'primary',
          capacity: 80,
        ),
      );
      await remote.saveClass(
        const SchoolClass(
          id: 's1',
          name: 'Senior 1',
          code: 'S1',
          levelId: 'secondary',
          capacity: 100,
        ),
      );
      for (final stream in const [
        ClassStream(
          id: 'p5-blue',
          name: 'Blue',
          code: 'BLU',
          classId: 'p5',
          capacity: 40,
        ),
        ClassStream(
          id: 'p5-red',
          name: 'Red',
          code: 'RED',
          classId: 'p5',
          capacity: 40,
        ),
        ClassStream(
          id: 's1-blue',
          name: 'Blue',
          code: 'BLU',
          classId: 's1',
          capacity: 50,
        ),
        ClassStream(
          id: 's1-red',
          name: 'Red',
          code: 'RED',
          classId: 's1',
          capacity: 50,
        ),
      ]) {
        await remote.saveStream(stream);
      }

      for (final subject in const [
        Subject(
          id: 'math',
          name: 'Mathematics',
          code: 'MATH',
          departmentId: 'science',
          assignedLevelIds: ['primary', 'secondary'],
          assignedClassIds: ['p5', 's1'],
        ),
        Subject(
          id: 'english',
          name: 'English Language',
          code: 'ENG',
          departmentId: 'languages',
          assignedLevelIds: ['primary', 'secondary'],
          assignedClassIds: ['p5', 's1'],
        ),
        Subject(
          id: 'physics',
          name: 'Physics',
          code: 'PHY',
          departmentId: 'science',
          assignedLevelIds: ['secondary'],
          assignedClassIds: ['s1'],
          isPractical: true,
        ),
      ]) {
        await remote.saveSubject(subject);
      }

      await remote.saveAssessmentType(
        const AssessmentTypeDef(
          id: 'end-term',
          name: 'End of Term Assessment',
          weightPercentage: 100,
        ),
      );
      await remote.saveGradingSystem(
        const GradingSystemDef(
          id: 'percentage',
          name: 'Internal Percentage Scale',
          type: 'percentage',
          isDefault: true,
        ),
      );
      for (final band in const [
        GradeBand(
          id: 'a',
          gradingSystemId: 'percentage',
          grade: 'A',
          minScore: 80,
          maxScore: 100,
          order: 1,
        ),
        GradeBand(
          id: 'b',
          gradingSystemId: 'percentage',
          grade: 'B',
          minScore: 60,
          maxScore: 79.99,
          order: 2,
        ),
        GradeBand(
          id: 'c',
          gradingSystemId: 'percentage',
          grade: 'C',
          minScore: 0,
          maxScore: 59.99,
          order: 3,
        ),
      ]) {
        await remote.saveGradeBand(band);
      }

      await remote.saveFacility(
        const Facility(
          id: 'science-lab',
          name: 'Science Laboratory',
          facilityType: 'laboratory',
          location: 'Science Block',
          capacity: 40,
        ),
      );
      await remote.saveFacility(
        const Facility(
          id: 'library',
          name: 'Library',
          facilityType: 'library',
          location: 'Main Block',
          capacity: 80,
        ),
      );
      await remote.updateTimetableConfig(
        const TimetableConfig(
          teachingDays: [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
          ],
          periodsPerDay: 4,
          schoolStartTime: '08:00',
          schoolEndTime: '13:00',
          slots: [
            TimetableSlot(
              name: 'Period 1',
              startTime: '08:00',
              endTime: '08:45',
            ),
            TimetableSlot(
              name: 'Period 2',
              startTime: '08:45',
              endTime: '09:30',
            ),
            TimetableSlot(
              name: 'Break',
              startTime: '09:30',
              endTime: '09:50',
              type: 'break',
            ),
            TimetableSlot(
              name: 'Period 3',
              startTime: '09:50',
              endTime: '10:35',
            ),
            TimetableSlot(
              name: 'Lunch',
              startTime: '12:05',
              endTime: '13:00',
              type: 'lunch',
            ),
          ],
        ),
      );

      await remote.saveDesignation(
        const StaffDesignation(id: 'teacher', name: 'Teacher'),
      );
      for (final role in const [
        StaffRole(
          id: 'subject-teacher',
          name: 'Subject Teacher',
          designationId: 'teacher',
        ),
        StaffRole(
          id: 'class-teacher',
          name: 'Class Teacher',
          designationId: 'teacher',
        ),
        StaffRole(
          id: 'hod',
          name: 'Head of Department',
          designationId: 'teacher',
        ),
      ]) {
        await remote.saveStaffRole(role);
      }
      await remote.saveHouse(
        const House(id: 'blue', name: 'Blue House', colorHex: '#2563EB'),
      );
      await remote.saveClub(
        const Club(id: 'debate', name: 'Debate Club', category: 'Academic'),
      );
      await remote.saveHostel(
        const Hostel(
          id: 'boys',
          name: 'Boys Boarding',
          gender: 'male',
          capacity: 120,
        ),
      );
      await remote.saveHostelRoom(
        const HostelRoom(
          id: 'boys-a1',
          hostelId: 'boys',
          blockName: 'A',
          roomNumber: 'A1',
          bedCapacity: 40,
        ),
      );
      await remote.saveTransportRoute(
        const TransportRoute(id: 'route-a', name: 'Test Route A', code: 'RTA'),
      );
      await remote.saveTransportStop(
        const TransportStop(
          id: 'stop-a',
          routeId: 'route-a',
          name: 'Town Stop',
          order: 1,
          pickupTime: '06:30',
        ),
      );
      await remote.saveTransportVehicle(
        const TransportVehicle(
          id: 'bus-a',
          busNumber: 'BUS-01',
          plateNumber: 'TEST-001',
          capacity: 60,
          routeId: 'route-a',
        ),
      );
      await remote.saveAttendanceType(
        const AttendanceTypeDef(id: 'present', name: 'Present'),
      );

      expect(
        (await setup.watchPreferences().first).streams,
        StructureUseChoice.enabled,
      );
      expect((await remote.watchAcademicTerms().first), hasLength(3));
      expect((await remote.watchLevels().first), hasLength(2));
      expect((await remote.watchDepartments().first), hasLength(2));
      expect((await remote.watchClasses().first), hasLength(2));
      expect((await remote.watchStreams().first), hasLength(4));
      expect((await remote.watchSubjects().first), hasLength(3));
      expect((await remote.watchGradeBands().first), hasLength(3));
      expect((await remote.watchFacilities().first), hasLength(2));
      expect((await remote.watchStaffRoles().first), hasLength(3));
      expect((await remote.watchHouses().first), hasLength(1));
      expect((await remote.watchClubs().first), hasLength(1));
      expect((await remote.watchHostels().first), hasLength(1));
      expect((await remote.watchTransportVehicles().first), hasLength(1));
      expect((await remote.watchAttendanceTypes().first), hasLength(1));

      final prefsDoc = await firestore
          .collection('structure_setup_preferences')
          .doc('sp-structure-e2e-school')
          .get();
      expect(prefsDoc.data()?['schoolId'], 'sp-structure-e2e-school');
    },
  );
}
