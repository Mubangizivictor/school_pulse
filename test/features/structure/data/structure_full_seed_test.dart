import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/data/datasources/structure_remote_data_source.dart';
import 'package:school_pulse/features/structure/data/repositories/structure_setup_repository_impl.dart';
import 'package:school_pulse/features/structure/domain/entities/assessment_grading_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/attendance_config_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/campus_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/communication_config_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/feature_toggles.dart';
import 'package:school_pulse/features/structure/domain/entities/fee_category_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/hostel_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/institution_profile.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_setup_preferences.dart';
import 'package:school_pulse/features/structure/domain/entities/timetable_config.dart';
import 'package:school_pulse/features/structure/domain/entities/transport_structure_entities.dart';

void main() {
  test('complete combined-school dummy Structure persists through production serialization', () async {
    final firestore = FakeFirebaseFirestore();
    final remote = StructureRemoteDataSourceImpl(firestore: firestore);
    final setup = StructureSetupRepositoryImpl(firestore: firestore);

    const profile = InstitutionProfile(
      name: 'School Pulse Structure E2E Test School',
      shortName: 'SPTEST',
      schoolType: 'Combined Primary & Secondary',
      schoolCategory: 'Day & Boarding',
      country: 'Uganda',
      district: 'Wakiso',
      city: 'Wakiso',
      phone: '0700000000',
      email: 'structure-e2e@example.invalid',
      timeZone: 'Africa/Kampala',
      currency: 'UGX',
      language: 'English',
      dateFormat: 'dd/MM/yyyy',
      timeFormat: '24h',
    );
    await remote.updateInstitutionProfile(profile);
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
        transport: true,
        hostel: true,
        boarding: true,
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
    await remote.saveAcademicTerm(
      AcademicTerm(
        id: 'term1',
        academicYearId: '2026',
        name: 'Term 1',
        order: 1,
        startDate: DateTime(2026, 2, 2),
        endDate: DateTime(2026, 5, 1),
        isCurrent: true,
      ),
    );
    await remote.saveAcademicTerm(
      AcademicTerm(
        id: 'term2',
        academicYearId: '2026',
        name: 'Term 2',
        order: 2,
        startDate: DateTime(2026, 5, 25),
        endDate: DateTime(2026, 8, 7),
      ),
    );
    await remote.saveAcademicTerm(
      AcademicTerm(
        id: 'term3',
        academicYearId: '2026',
        name: 'Term 3',
        order: 3,
        startDate: DateTime(2026, 9, 7),
        endDate: DateTime(2026, 12, 4),
      ),
    );

    await remote.saveLevel(
      const EducationalLevel(id: 'primary', name: 'Primary', code: 'PRI', order: 1),
    );
    await remote.saveLevel(
      const EducationalLevel(id: 'secondary', name: 'Secondary', code: 'SEC', order: 2),
    );

    await remote.saveDepartment(
      const Department(id: 'sciences', name: 'Sciences', code: 'SCI'),
    );
    await remote.saveDepartment(
      const Department(id: 'languages', name: 'Languages', code: 'LAN'),
    );
    await remote.saveDepartment(
      const Department(id: 'humanities', name: 'Humanities', code: 'HUM'),
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
        id: 'p6',
        name: 'Primary 6',
        code: 'P6',
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
    await remote.saveClass(
      const SchoolClass(
        id: 's2',
        name: 'Senior 2',
        code: 'S2',
        levelId: 'secondary',
        capacity: 100,
      ),
    );

    for (final stream in const [
      ClassStream(id: 'p5-blue', name: 'Blue', code: 'BLU', classId: 'p5', capacity: 40),
      ClassStream(id: 'p5-red', name: 'Red', code: 'RED', classId: 'p5', capacity: 40),
      ClassStream(id: 's1-blue', name: 'Blue', code: 'BLU', classId: 's1', capacity: 50),
      ClassStream(id: 's1-red', name: 'Red', code: 'RED', classId: 's1', capacity: 50),
    ]) {
      await remote.saveStream(stream);
    }

    for (final subject in const [
      Subject(id: 'math', name: 'Mathematics', code: 'MATH', departmentId: 'sciences', assignedLevelIds: ['primary', 'secondary'], assignedClassIds: ['p5', 'p6', 's1', 's2']),
      Subject(id: 'english', name: 'English Language', code: 'ENG', departmentId: 'languages', assignedLevelIds: ['primary', 'secondary'], assignedClassIds: ['p5', 'p6', 's1', 's2']),
      Subject(id: 'science', name: 'Integrated Science', code: 'ISCI', departmentId: 'sciences', assignedLevelIds: ['primary'], assignedClassIds: ['p5', 'p6'], isPractical: true),
      Subject(id: 'physics', name: 'Physics', code: 'PHY', departmentId: 'sciences', assignedLevelIds: ['secondary'], assignedClassIds: ['s1', 's2'], isPractical: true),
      Subject(id: 'chemistry', name: 'Chemistry', code: 'CHEM', departmentId: 'sciences', assignedLevelIds: ['secondary'], assignedClassIds: ['s1', 's2'], isPractical: true),
      Subject(id: 'history', name: 'History', code: 'HIST', departmentId: 'humanities', assignedLevelIds: ['secondary'], assignedClassIds: ['s1', 's2']),
      Subject(id: 'geography', name: 'Geography', code: 'GEO', departmentId: 'humanities', assignedLevelIds: ['secondary'], assignedClassIds: ['s1', 's2']),
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
        id: 'primary-percent',
        name: 'Primary Internal Percentage Scale',
        type: 'percentage',
        isDefault: true,
      ),
    );
    for (final band in const [
      GradeBand(id: 'grade-a', gradingSystemId: 'primary-percent', grade: 'A', minScore: 80, maxScore: 100, order: 1),
      GradeBand(id: 'grade-b', gradingSystemId: 'primary-percent', grade: 'B', minScore: 60, maxScore: 79.99, order: 2),
      GradeBand(id: 'grade-c', gradingSystemId: 'primary-percent', grade: 'C', minScore: 0, maxScore: 59.99, order: 3),
    ]) {
      await remote.saveGradeBand(band);
    }

    for (final facility in const [
      Facility(id: 'p5-blue-room', name: 'P5 Blue Classroom', facilityType: 'classroom', location: 'Main Block', capacity: 40),
      Facility(id: 'p5-red-room', name: 'P5 Red Classroom', facilityType: 'classroom', location: 'Main Block', capacity: 40),
      Facility(id: 's1-blue-room', name: 'S1 Blue Classroom', facilityType: 'classroom', location: 'Secondary Block', capacity: 50),
      Facility(id: 'science-lab', name: 'Science Laboratory', facilityType: 'laboratory', location: 'Science Block', capacity: 40),
      Facility(id: 'computer-lab', name: 'Computer Lab', facilityType: 'computer_lab', location: 'ICT Block', capacity: 40),
      Facility(id: 'library', name: 'Library', facilityType: 'library', location: 'Main Block', capacity: 80),
      Facility(id: 'assembly-hall', name: 'Assembly Hall', facilityType: 'hall', location: 'Central', capacity: 600),
    ]) {
      await remote.saveFacility(facility);
    }

    await remote.updateTimetableConfig(
      const TimetableConfig(
        teachingDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        periodsPerDay: 7,
        schoolStartTime: '08:00',
        schoolEndTime: '16:00',
        slots: [
          TimetableSlot(name: 'Period 1', startTime: '08:00', endTime: '08:45'),
          TimetableSlot(name: 'Period 2', startTime: '08:45', endTime: '09:30'),
          TimetableSlot(name: 'Short Break', startTime: '09:30', endTime: '09:50', type: 'break'),
          TimetableSlot(name: 'Period 3', startTime: '09:50', endTime: '10:35'),
          TimetableSlot(name: 'Period 4', startTime: '10:35', endTime: '11:20'),
          TimetableSlot(name: 'Period 5', startTime: '11:20', endTime: '12:05'),
          TimetableSlot(name: 'Lunch', startTime: '12:05', endTime: '13:00', type: 'lunch'),
          TimetableSlot(name: 'Period 6', startTime: '13:00', endTime: '13:45'),
          TimetableSlot(name: 'Period 7', startTime: '13:45', endTime: '14:30'),
          TimetableSlot(name: 'Games / Prep', startTime: '14:30', endTime: '16:00', type: 'custom'),
        ],
      ),
    );

    await remote.saveDesignation(const StaffDesignation(id: 'teacher', name: 'Teacher'));
    for (final role in const [
      StaffRole(id: 'teacher-role', name: 'Teacher', designationId: 'teacher'),
      StaffRole(id: 'class-teacher', name: 'Class Teacher', designationId: 'teacher'),
      StaffRole(id: 'subject-teacher', name: 'Subject Teacher', designationId: 'teacher'),
      StaffRole(id: 'hod', name: 'Head of Department', designationId: 'teacher'),
      StaffRole(id: 'patron', name: 'Patron', designationId: 'teacher'),
      StaffRole(id: 'matron', name: 'Matron'),
      StaffRole(id: 'bursar', name: 'Bursar'),
    ]) {
      await remote.saveStaffRole(role);
    }

    await remote.saveHouse(const House(id: 'blue-house', name: 'Blue House', colorHex: '#2563EB'));
    await remote.saveHouse(const House(id: 'red-house', name: 'Red House', colorHex: '#DC2626'));
    await remote.saveClub(const Club(id: 'debate', name: 'Debate Club', category: 'Academic'));
    await remote.saveClub(const Club(id: 'robotics', name: 'Robotics Club', category: 'STEM'));

    await remote.saveHostel(const Hostel(id: 'boys', name: 'Boys Boarding', gender: 'male', capacity: 120));
    await remote.saveHostel(const Hostel(id: 'girls', name: 'Girls Boarding', gender: 'female', capacity: 120));
    await remote.saveHostelRoom(const HostelRoom(id: 'boys-a', hostelId: 'boys', blockName: 'A', roomNumber: 'A1', bedCapacity: 40));
    await remote.saveHostelRoom(const HostelRoom(id: 'girls-a', hostelId: 'girls', blockName: 'A', roomNumber: 'A1', bedCapacity: 40));

    await remote.saveTransportRoute(const TransportRoute(id: 'route-a', name: 'Test Route A', code: 'RTA'));
    await remote.saveTransportStop(const TransportStop(id: 'stop-1', routeId: 'route-a', name: 'Town Stop', order: 1, pickupTime: '06:30'));
    await remote.saveTransportStop(const TransportStop(id: 'stop-2', routeId: 'route-a', name: 'Trading Centre', order: 2, pickupTime: '06:45'));
    await remote.saveTransportVehicle(const TransportVehicle(id: 'bus-1', busNumber: 'BUS-01', plateNumber: 'TEST-001', capacity: 60, routeId: 'route-a'));

    await remote.saveAttendanceType(const AttendanceTypeDef(id: 'present', name: 'Present', colorHex: '#16A34A'));
    await remote.saveAttendanceType(const AttendanceTypeDef(id: 'absent', name: 'Absent', colorHex: '#DC2626'));
    await remote.saveAttendanceSession(const AttendanceSessionDef(id: 'morning', name: 'Morning'));
    await remote.saveFeeCategory(const FeeCategory(id: 'tuition', name: 'Tuition', code: 'TUI'));
    await remote.saveAnnouncementCategory(const AnnouncementCategoryDef(id: 'academic', name: 'Academic'));
    await remote.saveNotificationCategory(const NotificationCategoryDef(id: 'attendance', name: 'Attendance'));
    await remote.saveMessageTemplate(const MessageTemplateDef(id: 'absence', name: 'Absence Notice', channel: 'push', body: 'Student attendance update.'));

    expect((await remote.watchInstitutionProfile().first).name, profile.name);
    expect((await setup.watchPreferences().first).streams, StructureUseChoice.enabled);
    expect((await remote.watchAcademicYears().first).single.isCurrent, isTrue);
    expect((await remote.watchAcademicTerms().first), hasLength(3));
    expect((await remote.watchLevels().first), hasLength(2));
    expect((await remote.watchDepartments().first), hasLength(3));
    expect((await remote.watchClasses().first), hasLength(4));
    expect((await remote.watchStreams().first), hasLength(4));
    expect((await remote.watchSubjects().first), hasLength(7));
    expect((await remote.watchAssessmentTypes().first), hasLength(1));
    expect((await remote.watchGradingSystems().first), hasLength(1));
    expect((await remote.watchGradeBands().first), hasLength(3));
    expect((await remote.watchFacilities().first), hasLength(7));
    expect((await remote.watchTimetableConfig().first).slots, hasLength(10));
    expect((await remote.watchStaffRoles().first), hasLength(7));
    expect((await remote.watchHouses().first), hasLength(2));
    expect((await remote.watchClubs().first), hasLength(2));
    expect((await remote.watchHostels().first), hasLength(2));
    expect((await remote.watchHostelRooms().first), hasLength(2));
    expect((await remote.watchTransportRoutes().first), hasLength(1));
    expect((await remote.watchTransportStops().first), hasLength(2));
    expect((await remote.watchTransportVehicles().first), hasLength(1));
    expect((await remote.watchAttendanceTypes().first), hasLength(2));
    expect((await remote.watchAttendanceSessions().first), hasLength(1));
    expect((await remote.watchFeeCategories().first), hasLength(1));
    expect((await remote.watchAnnouncementCategories().first), hasLength(1));
    expect((await remote.watchNotificationCategories().first), hasLength(1));
    expect((await remote.watchMessageTemplates().first), hasLength(1));
  });
}
