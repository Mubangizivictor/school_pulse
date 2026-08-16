import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/structure_entities.dart';
import '../../domain/entities/feature_toggles.dart';
import '../../domain/entities/institution_profile.dart';
import '../../domain/entities/campus_entities.dart';
import '../../domain/entities/hostel_entities.dart';
import '../../domain/entities/transport_structure_entities.dart';
import '../../domain/entities/fee_category_entities.dart';
import '../../domain/entities/assessment_grading_entities.dart';
import '../../domain/entities/timetable_config.dart';
import '../../domain/entities/attendance_config_entities.dart';
import '../../domain/entities/attendance_defaults_config.dart';
import '../../domain/entities/communication_config_entities.dart';
import '../../domain/entities/communication_defaults_config.dart';
import '../../domain/entities/document_template_entities.dart';
import '../../domain/entities/custom_field_entities.dart';

abstract class StructureRemoteDataSource {
  Stream<List<EducationalLevel>> watchLevels(String schoolId);
  Future<void> saveLevel(EducationalLevel level);
  Future<void> deleteLevel(String levelId);
  Future<void> archiveLevel(String levelId);
  Future<void> restoreLevel(String levelId);

  Stream<List<AcademicYear>> watchAcademicYears(String schoolId);
  Future<void> saveAcademicYear(AcademicYear year);
  Future<void> deleteAcademicYear(String yearId);
  Future<void> setCurrentAcademicYear(String yearId, String schoolId);
  Future<void> archiveAcademicYear(String yearId);
  Future<void> restoreAcademicYear(String yearId);

  Stream<List<AcademicTerm>> watchAcademicTerms(String schoolId);
  Future<void> saveAcademicTerm(AcademicTerm term);
  Future<void> deleteAcademicTerm(String termId);
  Future<void> setCurrentAcademicTerm(String termId, String schoolId);
  Future<void> archiveAcademicTerm(String termId);
  Future<void> restoreAcademicTerm(String termId);

  Stream<List<SchoolClass>> watchClasses(String schoolId);
  Future<void> saveClass(SchoolClass schoolClass);
  Future<void> deleteClass(String classId);
  Future<void> archiveClass(String classId);
  Future<void> restoreClass(String classId);

  Stream<List<ClassStream>> watchStreams(String schoolId);
  Future<void> saveStream(ClassStream stream);
  Future<void> deleteStream(String streamId);
  Future<void> archiveStream(String streamId);
  Future<void> restoreStream(String streamId);

  Stream<List<Subject>> watchSubjects(String schoolId);
  Future<void> saveSubject(Subject subject);
  Future<void> deleteSubject(String subjectId);
  Future<void> archiveSubject(String subjectId);

  Stream<List<Department>> watchDepartments(String schoolId);
  Future<void> saveDepartment(Department department);
  Future<void> deleteDepartment(String departmentId);
  Future<void> archiveDepartment(String departmentId);

  Stream<List<StaffDesignation>> watchDesignations(String schoolId);
  Future<void> saveDesignation(StaffDesignation designation);
  Future<void> deleteDesignation(String designationId);
  Future<void> archiveDesignation(String designationId);
  Future<void> restoreDesignation(String designationId);

  Stream<FeatureToggles> watchFeatureToggles(String schoolId);
  Future<void> updateFeatureToggles(FeatureToggles toggles, String schoolId);

  Stream<InstitutionProfile> watchInstitutionProfile(String schoolId);
  Future<void> updateInstitutionProfile(
    InstitutionProfile profile,
    String schoolId,
  );

  Stream<List<Campus>> watchCampuses(String schoolId);
  Future<void> saveCampus(Campus campus);
  Future<void> deleteCampus(String campusId);
  Future<void> archiveCampus(String campusId);

  Stream<List<House>> watchHouses(String schoolId);
  Future<void> saveHouse(House house);
  Future<void> deleteHouse(String houseId);

  Stream<List<Club>> watchClubs(String schoolId);
  Future<void> saveClub(Club club);
  Future<void> deleteClub(String clubId);

  Stream<List<Facility>> watchFacilities(String schoolId);
  Future<void> saveFacility(Facility facility);
  Future<void> deleteFacility(String facilityId);

  Stream<List<Hostel>> watchHostels(String schoolId);
  Future<void> saveHostel(Hostel hostel);
  Future<void> deleteHostel(String hostelId);

  Stream<List<HostelRoom>> watchHostelRooms(String schoolId);
  Future<void> saveHostelRoom(HostelRoom room);
  Future<void> deleteHostelRoom(String roomId);

  Stream<List<TransportRoute>> watchTransportRoutes(String schoolId);
  Future<void> saveTransportRoute(TransportRoute route);
  Future<void> deleteTransportRoute(String routeId);

  Stream<List<TransportStop>> watchTransportStops(String schoolId);
  Future<void> saveTransportStop(TransportStop stop);
  Future<void> deleteTransportStop(String stopId);

  Stream<List<TransportVehicle>> watchTransportVehicles(String schoolId);
  Future<void> saveTransportVehicle(TransportVehicle vehicle);
  Future<void> deleteTransportVehicle(String vehicleId);

  Stream<List<FeeCategory>> watchFeeCategories(String schoolId);
  Future<void> saveFeeCategory(FeeCategory category);
  Future<void> deleteFeeCategory(String categoryId);

  Stream<List<AssessmentTypeDef>> watchAssessmentTypes(String schoolId);
  Future<void> saveAssessmentType(AssessmentTypeDef type);
  Future<void> deleteAssessmentType(String typeId);

  Stream<List<GradingSystemDef>> watchGradingSystems(String schoolId);
  Future<void> saveGradingSystem(GradingSystemDef system);
  Future<void> deleteGradingSystem(String systemId);

  Stream<List<GradeBand>> watchGradeBands(String schoolId);
  Future<void> saveGradeBand(GradeBand band);
  Future<void> deleteGradeBand(String bandId);

  Stream<TimetableConfig> watchTimetableConfig(String schoolId);
  Future<void> updateTimetableConfig(TimetableConfig config, String schoolId);

  Stream<AttendanceDefaultsConfig> watchAttendanceDefaultsConfig(
    String schoolId,
  );
  Future<void> updateAttendanceDefaultsConfig(
    AttendanceDefaultsConfig config,
    String schoolId,
  );

  Stream<CommunicationDefaultsConfig> watchCommunicationDefaultsConfig(
    String schoolId,
  );
  Future<void> updateCommunicationDefaultsConfig(
    CommunicationDefaultsConfig config,
    String schoolId,
  );

  Stream<List<AttendanceTypeDef>> watchAttendanceTypes(String schoolId);
  Future<void> saveAttendanceType(AttendanceTypeDef type);
  Future<void> deleteAttendanceType(String typeId);

  Stream<List<AttendanceSessionDef>> watchAttendanceSessions(String schoolId);
  Future<void> saveAttendanceSession(AttendanceSessionDef session);
  Future<void> deleteAttendanceSession(String sessionId);

  Stream<List<AnnouncementCategoryDef>> watchAnnouncementCategories(
    String schoolId,
  );
  Future<void> saveAnnouncementCategory(AnnouncementCategoryDef category);
  Future<void> deleteAnnouncementCategory(String categoryId);

  Stream<List<NotificationCategoryDef>> watchNotificationCategories(
    String schoolId,
  );
  Future<void> saveNotificationCategory(NotificationCategoryDef category);
  Future<void> deleteNotificationCategory(String categoryId);

  Stream<List<MessageTemplateDef>> watchMessageTemplates(String schoolId);
  Future<void> saveMessageTemplate(MessageTemplateDef template);
  Future<void> deleteMessageTemplate(String templateId);

  Stream<List<DocumentTemplateDef>> watchDocumentTemplates(String schoolId);
  Future<void> saveDocumentTemplate(DocumentTemplateDef template);
  Future<void> deleteDocumentTemplate(String templateId);

  Stream<List<CustomFieldDef>> watchCustomFields(String schoolId);
  Future<void> saveCustomField(CustomFieldDef field);
  Future<void> deleteCustomField(String fieldId);
}

class StructureRemoteDataSourceImpl implements StructureRemoteDataSource {
  final FirebaseFirestore firestore;

  StructureRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _levels =>
      firestore.collection('educational_levels');
  CollectionReference<Map<String, dynamic>> get _years =>
      firestore.collection('academic_years');
  CollectionReference<Map<String, dynamic>> get _terms =>
      firestore.collection('academic_terms');
  CollectionReference<Map<String, dynamic>> get _classes =>
      firestore.collection('classes');
  CollectionReference<Map<String, dynamic>> get _streams =>
      firestore.collection('class_streams');
  CollectionReference<Map<String, dynamic>> get _subjects =>
      firestore.collection('subjects');
  CollectionReference<Map<String, dynamic>> get _departments =>
      firestore.collection('departments');
  CollectionReference<Map<String, dynamic>> get _designations =>
      firestore.collection('staff_designations');

  CollectionReference<Map<String, dynamic>> get _campuses =>
      firestore.collection('campuses');
  CollectionReference<Map<String, dynamic>> get _houses =>
      firestore.collection('houses');
  CollectionReference<Map<String, dynamic>> get _clubs =>
      firestore.collection('clubs');
  CollectionReference<Map<String, dynamic>> get _facilities =>
      firestore.collection('facilities');
  CollectionReference<Map<String, dynamic>> get _hostels =>
      firestore.collection('hostels');
  CollectionReference<Map<String, dynamic>> get _hostelRooms =>
      firestore.collection('hostel_rooms');
  CollectionReference<Map<String, dynamic>> get _transportRoutes =>
      firestore.collection('transport_routes');
  CollectionReference<Map<String, dynamic>> get _transportStops =>
      firestore.collection('transport_stops');
  CollectionReference<Map<String, dynamic>> get _transportVehicles =>
      firestore.collection('transport_vehicles');
  CollectionReference<Map<String, dynamic>> get _feeCategories =>
      firestore.collection('structure_fee_categories');
  CollectionReference<Map<String, dynamic>> get _assessmentTypes =>
      firestore.collection('structure_assessment_types');
  CollectionReference<Map<String, dynamic>> get _gradingSystems =>
      firestore.collection('structure_grading_systems');
  CollectionReference<Map<String, dynamic>> get _gradeBands =>
      firestore.collection('grade_bands');
  CollectionReference<Map<String, dynamic>> get _attendanceTypes =>
      firestore.collection('attendance_types');
  CollectionReference<Map<String, dynamic>> get _attendanceSessions =>
      firestore.collection('attendance_sessions');
  CollectionReference<Map<String, dynamic>> get _announcementCategories =>
      firestore.collection('announcement_categories');
  CollectionReference<Map<String, dynamic>> get _notificationCategories =>
      firestore.collection('notification_categories');
  CollectionReference<Map<String, dynamic>> get _messageTemplates =>
      firestore.collection('message_templates');
  CollectionReference<Map<String, dynamic>> get _documentTemplates =>
      firestore.collection('document_templates');
  CollectionReference<Map<String, dynamic>> get _customFields =>
      firestore.collection('custom_fields');

  DocumentReference<Map<String, dynamic>> _featureTogglesDoc(String schoolId) =>
      firestore
          .collection('schools')
          .doc(schoolId)
          .collection('config')
          .doc('feature_toggles');
  DocumentReference<Map<String, dynamic>> _institutionProfileDoc(
    String schoolId,
  ) => firestore
      .collection('schools')
      .doc(schoolId)
      .collection('config')
      .doc('institution_profile');
  DocumentReference<Map<String, dynamic>> _timetableConfigDoc(
    String schoolId,
  ) => firestore
      .collection('schools')
      .doc(schoolId)
      .collection('config')
      .doc('timetable_config');
  DocumentReference<Map<String, dynamic>> _attendanceDefaultsConfigDoc(
    String schoolId,
  ) => firestore
      .collection('schools')
      .doc(schoolId)
      .collection('config')
      .doc('attendance_defaults');
  DocumentReference<Map<String, dynamic>> _communicationDefaultsConfigDoc(
    String schoolId,
  ) => firestore
      .collection('schools')
      .doc(schoolId)
      .collection('config')
      .doc('communication_defaults');

  // Educational Levels
  @override
  Stream<List<EducationalLevel>> watchLevels(String schoolId) {
    return _levels
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('order')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => _levelFromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Future<void> saveLevel(EducationalLevel level) =>
      _levels.doc(level.id).set(_levelToMap(level), SetOptions(merge: true));

  @override
  Future<void> deleteLevel(String levelId) => _levels.doc(levelId).delete();

  @override
  Future<void> archiveLevel(String levelId) => _levels.doc(levelId).update({
    'isActive': false,
    'archivedAt': Timestamp.now().millisecondsSinceEpoch,
  });

  @override
  Future<void> restoreLevel(String levelId) =>
      _levels.doc(levelId).update({'isActive': true, 'archivedAt': null});

  EducationalLevel _levelFromMap(String id, Map<String, dynamic> map) {
    return EducationalLevel(
      id: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      order: map['order'] ?? 0,
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> _levelToMap(EducationalLevel e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'code': e.code,
    'order': e.order,
    'description': e.description,
    'isActive': e.isActive,
  };

  // Academic Years
  @override
  Stream<List<AcademicYear>> watchAcademicYears(String schoolId) {
    return _years
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => _yearFromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Future<void> saveAcademicYear(AcademicYear year) async {
    // A current year is a school-wide singleton. Keep the writes in one
    // batch so listeners never observe a partially-updated current state.
    // years selected at once.
    if (!year.isCurrent) {
      await _years.doc(year.id).set(_yearToMap(year), SetOptions(merge: true));
      return;
    }
    final current = await _years
        .where('schoolId', isEqualTo: year.schoolId)
        .where('isCurrent', isEqualTo: true)
        .get();
    final batch = firestore.batch();
    for (final doc in current.docs) {
      if (doc.id != year.id) batch.update(doc.reference, {'isCurrent': false});
    }
    batch.set(_years.doc(year.id), _yearToMap(year));
    await batch.commit();
  }

  @override
  Future<void> deleteAcademicYear(String yearId) => _years.doc(yearId).delete();

  @override
  Future<void> setCurrentAcademicYear(String yearId, String schoolId) async {
    final target = await _years.doc(yearId).get();
    if (!target.exists || target.data()?['schoolId'] != schoolId) {
      throw StateError('Academic year is not available for this school.');
    }
    final existingCurrent = await _years
        .where('schoolId', isEqualTo: schoolId)
        .where('isCurrent', isEqualTo: true)
        .get();
    final batch = firestore.batch();
    for (final doc in existingCurrent.docs) {
      batch.update(doc.reference, {'isCurrent': false});
    }
    batch.update(target.reference, {'isCurrent': true, 'isArchived': false});
    await batch.commit();
  }

  @override
  Future<void> archiveAcademicYear(String yearId) =>
      _years.doc(yearId).update({'isArchived': true, 'isCurrent': false});

  @override
  Future<void> restoreAcademicYear(String yearId) =>
      _years.doc(yearId).update({'isArchived': false});

  AcademicYear _yearFromMap(String id, Map<String, dynamic> map) {
    return AcademicYear(
      id: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: map['description'] ?? '',
      isCurrent: map['isCurrent'] ?? false,
      isArchived: map['isArchived'] ?? false,
    );
  }

  Map<String, dynamic> _yearToMap(AcademicYear e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'startDate': Timestamp.fromDate(e.startDate),
    'endDate': Timestamp.fromDate(e.endDate),
    'description': e.description,
    'isCurrent': e.isCurrent,
    'isArchived': e.isArchived,
  };

  // Academic Terms
  @override
  Stream<List<AcademicTerm>> watchAcademicTerms(String schoolId) {
    return _terms
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('order')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => _termFromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Future<void> saveAcademicTerm(AcademicTerm term) async {
    if (!term.isCurrent) {
      await _terms.doc(term.id).set(_termToMap(term), SetOptions(merge: true));
      return;
    }
    await _setCurrentTermTransaction(term.id, term.schoolId, term: term);
  }

  @override
  Future<void> deleteAcademicTerm(String termId) => _terms.doc(termId).delete();

  @override
  Future<void> setCurrentAcademicTerm(String termId, String schoolId) async {
    await _setCurrentTermTransaction(termId, schoolId);
  }

  Future<void> _setCurrentTermTransaction(
    String termId,
    String schoolId, {
    AcademicTerm? term,
  }) async {
    final target = _terms.doc(termId);
    final targetSnapshot = await target.get();
    final targetData = targetSnapshot.data();
    if (term == null &&
        (!targetSnapshot.exists || targetData?['schoolId'] != schoolId)) {
      throw StateError('Term is not available for this school.');
    }
    final yearId =
        term?.academicYearId ?? targetData!['academicYearId'] as String;
    final year = _years.doc(yearId);
    final yearSnapshot = await year.get();
    if (!yearSnapshot.exists || yearSnapshot.data()?['schoolId'] != schoolId) {
      throw StateError(
        'The selected academic year is not available for this school.',
      );
    }
    final currentTerms = await _terms
        .where('schoolId', isEqualTo: schoolId)
        .where('isCurrent', isEqualTo: true)
        .get();
    final currentYears = await _years
        .where('schoolId', isEqualTo: schoolId)
        .where('isCurrent', isEqualTo: true)
        .get();
    final batch = firestore.batch();
    for (final doc in currentTerms.docs) {
      if (doc.id != termId) batch.update(doc.reference, {'isCurrent': false});
    }
    for (final doc in currentYears.docs) {
      if (doc.id != yearId) batch.update(doc.reference, {'isCurrent': false});
    }
    batch.update(year, {'isCurrent': true, 'isArchived': false});
    if (term == null) {
      batch.update(target, {'isCurrent': true, 'isArchived': false});
    } else {
      batch.set(target, _termToMap(term));
    }
    await batch.commit();
  }

  @override
  Future<void> archiveAcademicTerm(String termId) =>
      _terms.doc(termId).update({'isArchived': true, 'isCurrent': false});

  @override
  Future<void> restoreAcademicTerm(String termId) =>
      _terms.doc(termId).update({'isArchived': false});

  AcademicTerm _termFromMap(String id, Map<String, dynamic> map) {
    return AcademicTerm(
      id: id,
      schoolId: map['schoolId'] ?? '',
      academicYearId: map['academicYearId'] ?? '',
      name: map['name'] ?? '',
      order: map['order'] ?? 0,
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCurrent: map['isCurrent'] ?? false,
      periodType: AcademicPeriodType.values.firstWhere(
        (t) => t.name == map['periodType'],
        orElse: () => AcademicPeriodType.term,
      ),
      isArchived: map['isArchived'] ?? false,
    );
  }

  Map<String, dynamic> _termToMap(AcademicTerm e) => {
    'schoolId': e.schoolId,
    'academicYearId': e.academicYearId,
    'name': e.name,
    'order': e.order,
    'startDate': Timestamp.fromDate(e.startDate),
    'endDate': Timestamp.fromDate(e.endDate),
    'isCurrent': e.isCurrent,
    'periodType': e.periodType.name,
    'isArchived': e.isArchived,
  };

  // Classes
  @override
  Stream<List<SchoolClass>> watchClasses(String schoolId) {
    return _classes
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('name')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => _classFromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Future<void> saveClass(SchoolClass schoolClass) =>
      _classes.doc(schoolClass.id).set(_classToMap(schoolClass));

  @override
  Future<void> deleteClass(String classId) => _classes.doc(classId).delete();

  @override
  Future<void> archiveClass(String classId) =>
      _classes.doc(classId).update({'isActive': false});

  @override
  Future<void> restoreClass(String classId) =>
      _classes.doc(classId).update({'isActive': true});

  SchoolClass _classFromMap(String id, Map<String, dynamic> map) {
    return SchoolClass(
      id: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      levelId: map['levelId'] ?? '',
      capacity: map['capacity'] ?? 0,
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> _classToMap(SchoolClass e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'code': e.code,
    'levelId': e.levelId,
    'capacity': e.capacity,
    'description': e.description,
    'isActive': e.isActive,
  };

  // Streams
  @override
  Stream<List<ClassStream>> watchStreams(String schoolId) {
    return _streams
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('name')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => _streamFromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Future<void> saveStream(ClassStream stream) =>
      _streams.doc(stream.id).set(_streamToMap(stream));

  @override
  Future<void> deleteStream(String streamId) => _streams.doc(streamId).delete();

  @override
  Future<void> archiveStream(String streamId) =>
      _streams.doc(streamId).update({'isActive': false});

  @override
  Future<void> restoreStream(String streamId) =>
      _streams.doc(streamId).update({'isActive': true});

  ClassStream _streamFromMap(String id, Map<String, dynamic> map) {
    return ClassStream(
      id: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      classId: map['classId'] ?? '',
      capacity: map['capacity'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> _streamToMap(ClassStream e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'code': e.code,
    'classId': e.classId,
    'capacity': e.capacity,
    'isActive': e.isActive,
  };

  // Subjects
  @override
  Stream<List<Subject>> watchSubjects(String schoolId) {
    return _subjects
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('name')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => _subjectFromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Future<void> saveSubject(Subject subject) async {
    final ref = _subjects.doc(subject.id);
    final existing = await ref.get();
    await ref.set({
      ..._subjectToMap(subject),
      'codeLower': subject.code.trim().toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (!existing.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteSubject(String subjectId) =>
      _subjects.doc(subjectId).delete();

  @override
  Future<void> archiveSubject(String subjectId) =>
      _subjects.doc(subjectId).update({'isActive': false});

  Subject _subjectFromMap(String id, Map<String, dynamic> map) {
    return Subject(
      id: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      departmentId: map['departmentId'] ?? '',
      color: map['color'] ?? '',
      description: map['description'] ?? '',
      subjectType:
          map['subjectType'] ??
          ((map['isElective'] ?? false) ? 'Elective' : 'Core'),
      isElective: map['isElective'] ?? false,
      isPractical: map['isPractical'] ?? false,
      creditUnits: map['creditUnits'] ?? 0,
      isActive: map['isActive'] ?? true,
      assignedLevelIds: List<String>.from(map['assignedLevelIds'] ?? const []),
      assignedClassIds: List<String>.from(map['assignedClassIds'] ?? const []),
    );
  }

  Map<String, dynamic> _subjectToMap(Subject e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'code': e.code,
    'departmentId': e.departmentId,
    'color': e.color,
    'description': e.description,
    'subjectType': e.subjectType,
    'isElective': e.isElective,
    'isPractical': e.isPractical,
    'creditUnits': e.creditUnits,
    'isActive': e.isActive,
    'assignedLevelIds': e.assignedLevelIds,
    'assignedClassIds': e.assignedClassIds,
  };

  // Departments
  @override
  Stream<List<Department>> watchDepartments(String schoolId) {
    return _departments
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('name')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => _departmentFromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Future<void> saveDepartment(Department department) =>
      _departments.doc(department.id).set(_departmentToMap(department));

  @override
  Future<void> deleteDepartment(String departmentId) =>
      _departments.doc(departmentId).delete();

  @override
  Future<void> archiveDepartment(String departmentId) =>
      _departments.doc(departmentId).update({'isActive': false});

  Department _departmentFromMap(String id, Map<String, dynamic> map) {
    return Department(
      id: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      description: map['description'] ?? '',
      headOfDepartmentStaffId: map['headOfDepartmentStaffId'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> _departmentToMap(Department e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'code': e.code,
    'description': e.description,
    'headOfDepartmentStaffId': e.headOfDepartmentStaffId,
    'isActive': e.isActive,
  };

  // Staff Designations
  @override
  Stream<List<StaffDesignation>> watchDesignations(String schoolId) {
    return _designations
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('name')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _designationFromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveDesignation(StaffDesignation designation) =>
      _designations.doc(designation.id).set(_designationToMap(designation));

  @override
  Future<void> deleteDesignation(String designationId) =>
      _designations.doc(designationId).delete();

  @override
  Future<void> archiveDesignation(String designationId) =>
      _designations.doc(designationId).update({'isArchived': true});

  @override
  Future<void> restoreDesignation(String designationId) =>
      _designations.doc(designationId).update({'isArchived': false});

  StaffDesignation _designationFromMap(String id, Map<String, dynamic> map) {
    return StaffDesignation(
      id: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      displayOrder: (map['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] ?? true,
      scopeType: map['scopeType'] ?? 'wholeSchool',
      roleNature: map['roleNature'] ?? 'Standard',
      requiresScope: map['requiresScope'] ?? false,
      allowMultipleStaff: map['allowMultipleStaff'] ?? true,
      allowConcurrentAssignments: map['allowConcurrentAssignments'] ?? true,
      allowTemporaryAssignments: map['allowTemporaryAssignments'] ?? true,
      isSystemPreset: map['isSystemPreset'] ?? false,
      isArchived: map['isArchived'] ?? false,
      iconName: map['iconName'] ?? 'badge_outlined',
      colorHex: map['colorHex'] ?? '#6366F1',
      permissions:
          (map['permissions'] as List?)?.cast<String>().toSet() ?? const {},
    );
  }

  Map<String, dynamic> _designationToMap(StaffDesignation e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'code': e.code,
    'category': e.category,
    'description': e.description,
    'displayOrder': e.displayOrder,
    'isActive': e.isActive,
    'scopeType': e.scopeType,
    'roleNature': e.roleNature,
    'requiresScope': e.requiresScope,
    'allowMultipleStaff': e.allowMultipleStaff,
    'allowConcurrentAssignments': e.allowConcurrentAssignments,
    'allowTemporaryAssignments': e.allowTemporaryAssignments,
    'isSystemPreset': e.isSystemPreset,
    'isArchived': e.isArchived,
    'iconName': e.iconName,
    'colorHex': e.colorHex,
    'permissions': e.permissions.toList(),
  };

  // Feature Toggles
  @override
  Stream<FeatureToggles> watchFeatureToggles(String schoolId) {
    return _featureTogglesDoc(schoolId).snapshots().map((doc) {
      final map = doc.data();
      if (map == null) return const FeatureToggles();
      return _togglesFromMap(map);
    });
  }

  @override
  Future<void> updateFeatureToggles(FeatureToggles toggles, String schoolId) =>
      _featureTogglesDoc(schoolId).set(_togglesToMap(toggles));

  FeatureToggles _togglesFromMap(Map<String, dynamic> map) {
    return FeatureToggles(
      transport: map['transport'] ?? true,
      hostel: map['hostel'] ?? true,
      library: map['library'] ?? true,
      medical: map['medical'] ?? true,
      visitors: map['visitors'] ?? true,
      inventory: map['inventory'] ?? true,
      payroll: map['payroll'] ?? true,
      procurement: map['procurement'] ?? true,
      alumni: map['alumni'] ?? false,
      communication: map['communication'] ?? true,
      boarding: map['boarding'] ?? true,
      qrAttendance: map['qrAttendance'] ?? true,
      digitalIds: map['digitalIds'] ?? true,
      parentPortal: map['parentPortal'] ?? true,
      studentPortal: map['studentPortal'] ?? true,
    );
  }

  Map<String, dynamic> _togglesToMap(FeatureToggles e) => {
    'transport': e.transport,
    'hostel': e.hostel,
    'library': e.library,
    'medical': e.medical,
    'visitors': e.visitors,
    'inventory': e.inventory,
    'payroll': e.payroll,
    'procurement': e.procurement,
    'alumni': e.alumni,
    'communication': e.communication,
    'boarding': e.boarding,
    'qrAttendance': e.qrAttendance,
    'digitalIds': e.digitalIds,
    'parentPortal': e.parentPortal,
    'studentPortal': e.studentPortal,
  };

  // Institution Profile
  @override
  Stream<InstitutionProfile> watchInstitutionProfile(String schoolId) {
    return _institutionProfileDoc(schoolId).snapshots().map((doc) {
      final map = doc.data();
      if (map == null) return const InstitutionProfile();
      return _institutionProfileFromMap(map);
    });
  }

  @override
  Future<void> updateInstitutionProfile(
    InstitutionProfile profile,
    String schoolId,
  ) => _institutionProfileDoc(schoolId).set(_institutionProfileToMap(profile));

  InstitutionProfile _institutionProfileFromMap(Map<String, dynamic> map) {
    return InstitutionProfile(
      name: map['name'] ?? '',
      shortName: map['shortName'] ?? '',
      motto: map['motto'] ?? '',
      vision: map['vision'] ?? '',
      mission: map['mission'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      badgeUrl: map['badgeUrl'] ?? '',
      colors: List<String>.from(map['colors'] ?? const []),
      schoolType: map['schoolType'] ?? '',
      schoolCategory: map['schoolCategory'] ?? '',
      registrationNumber: map['registrationNumber'] ?? '',
      ministryRegistrationNumber: map['ministryRegistrationNumber'] ?? '',
      taxNumber: map['taxNumber'] ?? '',
      country: map['country'] ?? '',
      district: map['district'] ?? '',
      city: map['city'] ?? '',
      address: map['address'] ?? '',
      gpsLat: (map['gpsLat'] as num?)?.toDouble(),
      gpsLng: (map['gpsLng'] as num?)?.toDouble(),
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      website: map['website'] ?? '',
      socialMedia: Map<String, String>.from(map['socialMedia'] ?? const {}),
      timeZone: map['timeZone'] ?? '',
      currency: map['currency'] ?? '',
      language: map['language'] ?? '',
      dateFormat: map['dateFormat'] ?? '',
      timeFormat: map['timeFormat'] ?? '',
    );
  }

  Map<String, dynamic> _institutionProfileToMap(InstitutionProfile e) => {
    'name': e.name,
    'shortName': e.shortName,
    'motto': e.motto,
    'vision': e.vision,
    'mission': e.mission,
    'logoUrl': e.logoUrl,
    'badgeUrl': e.badgeUrl,
    'colors': e.colors,
    'schoolType': e.schoolType,
    'schoolCategory': e.schoolCategory,
    'registrationNumber': e.registrationNumber,
    'ministryRegistrationNumber': e.ministryRegistrationNumber,
    'taxNumber': e.taxNumber,
    'country': e.country,
    'district': e.district,
    'city': e.city,
    'address': e.address,
    'gpsLat': e.gpsLat,
    'gpsLng': e.gpsLng,
    'phone': e.phone,
    'email': e.email,
    'website': e.website,
    'socialMedia': e.socialMedia,
    'timeZone': e.timeZone,
    'currency': e.currency,
    'language': e.language,
    'dateFormat': e.dateFormat,
    'timeFormat': e.timeFormat,
  };

  // Campuses
  @override
  Stream<List<Campus>> watchCampuses(String schoolId) {
    return _campuses
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('order')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => _campusFromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Future<void> saveCampus(Campus campus) =>
      _campuses.doc(campus.id).set(_campusToMap(campus));

  @override
  Future<void> deleteCampus(String campusId) =>
      _campuses.doc(campusId).delete();

  @override
  Future<void> archiveCampus(String campusId) => _campuses.doc(campusId).update(
    {'isActive': false, 'archivedAt': Timestamp.now()},
  );

  Campus _campusFromMap(String id, Map<String, dynamic> map) {
    return Campus(
      id: id,
      schoolId: map['schoolId'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      address: map['address'] ?? '',
      district: map['district'] ?? '',
      contactPhone: map['contactPhone'] as String?,
      contactEmail: map['contactEmail'] as String?,
      headStaffId: map['headStaffId'] as String?,
      isPrimary: map['isPrimary'] ?? false,
      isActive: map['isActive'] ?? true,
      order: map['order'] ?? 0,
      archivedAt: (map['archivedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> _campusToMap(Campus e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'code': e.code,
    'address': e.address,
    'district': e.district,
    'contactPhone': e.contactPhone,
    'contactEmail': e.contactEmail,
    'headStaffId': e.headStaffId,
    'isPrimary': e.isPrimary,
    'isActive': e.isActive,
    'order': e.order,
    'archivedAt': e.archivedAt != null
        ? Timestamp.fromDate(e.archivedAt!)
        : null,
  };

  // Houses
  @override
  Stream<List<House>> watchHouses(String schoolId) {
    return _houses
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => _houseFromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Future<void> saveHouse(House house) =>
      _houses.doc(house.id).set(_houseToMap(house));

  @override
  Future<void> deleteHouse(String houseId) => _houses.doc(houseId).delete();

  House _houseFromMap(String id, Map<String, dynamic> map) => House(
    id: id,
    schoolId: map['schoolId'] ?? '',
    name: map['name'] ?? '',
    colorHex: map['colorHex'] ?? '',
    description: map['description'] ?? '',
    isActive: map['isActive'] ?? true,
  );

  Map<String, dynamic> _houseToMap(House e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'colorHex': e.colorHex,
    'description': e.description,
    'isActive': e.isActive,
  };

  // Clubs & Societies
  @override
  Stream<List<Club>> watchClubs(String schoolId) {
    return _clubs
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => _clubFromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Future<void> saveClub(Club club) => _clubs.doc(club.id).set(_clubToMap(club));

  @override
  Future<void> deleteClub(String clubId) => _clubs.doc(clubId).delete();

  Club _clubFromMap(String id, Map<String, dynamic> map) => Club(
    id: id,
    schoolId: map['schoolId'] ?? '',
    name: map['name'] ?? '',
    category: map['category'] ?? '',
    description: map['description'] ?? '',
    patronName: map['patronName'] ?? '',
    isActive: map['isActive'] ?? true,
  );

  Map<String, dynamic> _clubToMap(Club e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'category': e.category,
    'description': e.description,
    'patronName': e.patronName,
    'isActive': e.isActive,
  };

  // Facilities
  @override
  Stream<List<Facility>> watchFacilities(String schoolId) {
    return _facilities
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => _facilityFromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Future<void> saveFacility(Facility facility) =>
      _facilities.doc(facility.id).set(_facilityToMap(facility));

  @override
  Future<void> deleteFacility(String facilityId) =>
      _facilities.doc(facilityId).delete();

  Facility _facilityFromMap(String id, Map<String, dynamic> map) => Facility(
    id: id,
    schoolId: map['schoolId'] ?? '',
    name: map['name'] ?? '',
    facilityType: map['facilityType'] ?? '',
    location: map['location'] ?? '',
    capacity: map['capacity'] ?? 0,
    description: map['description'] ?? '',
    isActive: map['isActive'] ?? true,
  );

  Map<String, dynamic> _facilityToMap(Facility e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'facilityType': e.facilityType,
    'location': e.location,
    'capacity': e.capacity,
    'description': e.description,
    'isActive': e.isActive,
  };

  // Hostels
  @override
  Stream<List<Hostel>> watchHostels(String schoolId) {
    return _hostels
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => _hostelFromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Future<void> saveHostel(Hostel hostel) =>
      _hostels.doc(hostel.id).set(_hostelToMap(hostel));

  @override
  Future<void> deleteHostel(String hostelId) => _hostels.doc(hostelId).delete();

  Hostel _hostelFromMap(String id, Map<String, dynamic> map) => Hostel(
    id: id,
    schoolId: map['schoolId'] ?? '',
    name: map['name'] ?? '',
    gender: map['gender'] ?? '',
    wardenName: map['wardenName'] ?? '',
    wardenContact: map['wardenContact'] ?? '',
    capacity: map['capacity'] ?? 0,
    description: map['description'] ?? '',
    isActive: map['isActive'] ?? true,
  );

  Map<String, dynamic> _hostelToMap(Hostel e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'gender': e.gender,
    'wardenName': e.wardenName,
    'wardenContact': e.wardenContact,
    'capacity': e.capacity,
    'description': e.description,
    'isActive': e.isActive,
  };

  // Hostel Rooms
  @override
  Stream<List<HostelRoom>> watchHostelRooms(String schoolId) {
    return _hostelRooms
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => _hostelRoomFromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Future<void> saveHostelRoom(HostelRoom room) =>
      _hostelRooms.doc(room.id).set(_hostelRoomToMap(room));

  @override
  Future<void> deleteHostelRoom(String roomId) =>
      _hostelRooms.doc(roomId).delete();

  HostelRoom _hostelRoomFromMap(String id, Map<String, dynamic> map) =>
      HostelRoom(
        id: id,
        schoolId: map['schoolId'] ?? '',
        hostelId: map['hostelId'] ?? '',
        blockName: map['blockName'] ?? '',
        roomNumber: map['roomNumber'] ?? '',
        bedCapacity: map['bedCapacity'] ?? 0,
        isActive: map['isActive'] ?? true,
      );

  Map<String, dynamic> _hostelRoomToMap(HostelRoom e) => {
    'schoolId': e.schoolId,
    'hostelId': e.hostelId,
    'blockName': e.blockName,
    'roomNumber': e.roomNumber,
    'bedCapacity': e.bedCapacity,
    'isActive': e.isActive,
  };

  // Transport Routes
  @override
  Stream<List<TransportRoute>> watchTransportRoutes(String schoolId) {
    return _transportRoutes
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _transportRouteFromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveTransportRoute(TransportRoute route) =>
      _transportRoutes.doc(route.id).set(_transportRouteToMap(route));

  @override
  Future<void> deleteTransportRoute(String routeId) =>
      _transportRoutes.doc(routeId).delete();

  TransportRoute _transportRouteFromMap(String id, Map<String, dynamic> map) =>
      TransportRoute(
        id: id,
        schoolId: map['schoolId'] ?? '',
        name: map['name'] ?? '',
        code: map['code'] ?? '',
        description: map['description'] ?? '',
        isActive: map['isActive'] ?? true,
      );

  Map<String, dynamic> _transportRouteToMap(TransportRoute e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'code': e.code,
    'description': e.description,
    'isActive': e.isActive,
  };

  // Transport Stops
  @override
  Stream<List<TransportStop>> watchTransportStops(String schoolId) {
    return _transportStops
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('order')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _transportStopFromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveTransportStop(TransportStop stop) =>
      _transportStops.doc(stop.id).set(_transportStopToMap(stop));

  @override
  Future<void> deleteTransportStop(String stopId) =>
      _transportStops.doc(stopId).delete();

  TransportStop _transportStopFromMap(String id, Map<String, dynamic> map) =>
      TransportStop(
        id: id,
        schoolId: map['schoolId'] ?? '',
        routeId: map['routeId'] ?? '',
        name: map['name'] ?? '',
        order: map['order'] ?? 0,
        pickupTime: map['pickupTime'] ?? '',
        zone: map['zone'] ?? '',
        isActive: map['isActive'] ?? true,
      );

  Map<String, dynamic> _transportStopToMap(TransportStop e) => {
    'schoolId': e.schoolId,
    'routeId': e.routeId,
    'name': e.name,
    'order': e.order,
    'pickupTime': e.pickupTime,
    'zone': e.zone,
    'isActive': e.isActive,
  };

  // Transport Vehicles
  @override
  Stream<List<TransportVehicle>> watchTransportVehicles(String schoolId) {
    return _transportVehicles
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _transportVehicleFromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveTransportVehicle(TransportVehicle vehicle) =>
      _transportVehicles.doc(vehicle.id).set(_transportVehicleToMap(vehicle));

  @override
  Future<void> deleteTransportVehicle(String vehicleId) =>
      _transportVehicles.doc(vehicleId).delete();

  TransportVehicle _transportVehicleFromMap(
    String id,
    Map<String, dynamic> map,
  ) => TransportVehicle(
    id: id,
    schoolId: map['schoolId'] ?? '',
    busNumber: map['busNumber'] ?? '',
    plateNumber: map['plateNumber'] ?? '',
    capacity: map['capacity'] ?? 0,
    driverName: map['driverName'] ?? '',
    routeId: map['routeId'] ?? '',
    isActive: map['isActive'] ?? true,
  );

  Map<String, dynamic> _transportVehicleToMap(TransportVehicle e) => {
    'schoolId': e.schoolId,
    'busNumber': e.busNumber,
    'plateNumber': e.plateNumber,
    'capacity': e.capacity,
    'driverName': e.driverName,
    'routeId': e.routeId,
    'isActive': e.isActive,
  };

  // Fee Categories
  @override
  Stream<List<FeeCategory>> watchFeeCategories(String schoolId) {
    return _feeCategories
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _feeCategoryFromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveFeeCategory(FeeCategory category) =>
      _feeCategories.doc(category.id).set(_feeCategoryToMap(category));

  @override
  Future<void> deleteFeeCategory(String categoryId) =>
      _feeCategories.doc(categoryId).delete();

  FeeCategory _feeCategoryFromMap(String id, Map<String, dynamic> map) =>
      FeeCategory(
        id: id,
        schoolId: map['schoolId'] ?? '',
        name: map['name'] ?? '',
        code: map['code'] ?? '',
        description: map['description'] ?? '',
        isMandatory: map['isMandatory'] ?? true,
        isActive: map['isActive'] ?? true,
      );

  Map<String, dynamic> _feeCategoryToMap(FeeCategory e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'code': e.code,
    'description': e.description,
    'isMandatory': e.isMandatory,
    'isActive': e.isActive,
  };

  // Assessment Types
  @override
  Stream<List<AssessmentTypeDef>> watchAssessmentTypes(String schoolId) {
    return _assessmentTypes
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _assessmentTypeFromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveAssessmentType(AssessmentTypeDef type) =>
      _assessmentTypes.doc(type.id).set(_assessmentTypeToMap(type));

  @override
  Future<void> deleteAssessmentType(String typeId) =>
      _assessmentTypes.doc(typeId).delete();

  AssessmentTypeDef _assessmentTypeFromMap(
    String id,
    Map<String, dynamic> map,
  ) => AssessmentTypeDef(
    id: id,
    schoolId: map['schoolId'] ?? '',
    name: map['name'] ?? '',
    weightPercentage: (map['weightPercentage'] as num?)?.toDouble() ?? 0,
    description: map['description'] ?? '',
    isActive: map['isActive'] ?? true,
  );

  Map<String, dynamic> _assessmentTypeToMap(AssessmentTypeDef e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'weightPercentage': e.weightPercentage,
    'description': e.description,
    'isActive': e.isActive,
  };

  // Grading Systems
  @override
  Stream<List<GradingSystemDef>> watchGradingSystems(String schoolId) {
    return _gradingSystems
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _gradingSystemFromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveGradingSystem(GradingSystemDef system) async {
    // Defaults are scoped by the exact applicability definition.  Updating
    // them in one transaction avoids two simultaneous school-wide defaults.
    if (!system.isDefault) {
      await _gradingSystems.doc(system.id).set(_gradingSystemToMap(system));
      return;
    }
    final current = await _gradingSystems
        .where('schoolId', isEqualTo: system.schoolId)
        .get();
    final batch = firestore.batch();
    for (final doc in current.docs) {
      final data = doc.data();
      if (doc.id != system.id &&
          data['isDefault'] == true &&
          _sameApplicability(data, system)) {
        batch.update(doc.reference, {'isDefault': false});
      }
    }
    batch.set(_gradingSystems.doc(system.id), _gradingSystemToMap(system));
    await batch.commit();
  }

  bool _sameApplicability(Map<String, dynamic> data, GradingSystemDef system) {
    List<String> values(String key) => List<String>.from(data[key] ?? const []);
    bool sameList(List<String> a, List<String> b) =>
        a.length == b.length && a.toSet().containsAll(b);
    return (data['appliesTo'] ?? 'school') == system.appliesTo &&
        sameList(values('levelIds'), system.levelIds) &&
        sameList(values('classIds'), system.classIds) &&
        sameList(values('academicYearIds'), system.academicYearIds);
  }

  @override
  Future<void> deleteGradingSystem(String systemId) =>
      _gradingSystems.doc(systemId).delete();

  GradingSystemDef _gradingSystemFromMap(String id, Map<String, dynamic> map) =>
      GradingSystemDef(
        id: id,
        schoolId: map['schoolId'] ?? '',
        name: map['name'] ?? '',
        type: map['type'] ?? '',
        isDefault: map['isDefault'] ?? false,
        isActive: map['isActive'] ?? true,
        description: map['description'] ?? '',
        scaleType: map['scaleType'] ?? 'Range Based',
        gradeFormat: map['gradeFormat'] ?? 'Letter',
        decimalPlaces: map['decimalPlaces'] ?? 2,
        passingScore: (map['passingScore'] as num?)?.toDouble(),
        passingGradeCode: map['passingGradeCode'],
        allowIncomplete: map['allowIncomplete'] ?? false,
        appliesTo: map['appliesTo'] ?? 'school',
        levelIds: List<String>.from(map['levelIds'] ?? const []),
        classIds: List<String>.from(map['classIds'] ?? const []),
        academicYearIds: List<String>.from(map['academicYearIds'] ?? const []),
        version: map['version'] ?? 1,
      );

  Map<String, dynamic> _gradingSystemToMap(GradingSystemDef e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'type': e.type,
    'isDefault': e.isDefault,
    'isActive': e.isActive,
    'description': e.description,
    'scaleType': e.scaleType,
    'gradeFormat': e.gradeFormat,
    'decimalPlaces': e.decimalPlaces,
    'passingScore': e.passingScore,
    'passingGradeCode': e.passingGradeCode,
    'allowIncomplete': e.allowIncomplete,
    'appliesTo': e.appliesTo,
    'levelIds': e.levelIds,
    'classIds': e.classIds,
    'academicYearIds': e.academicYearIds,
    'version': e.version,
  };

  // Grade Bands
  @override
  Stream<List<GradeBand>> watchGradeBands(String schoolId) {
    return _gradeBands
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('order')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => _gradeBandFromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Future<void> saveGradeBand(GradeBand band) =>
      _gradeBands.doc(band.id).set(_gradeBandToMap(band));

  @override
  Future<void> deleteGradeBand(String bandId) =>
      _gradeBands.doc(bandId).delete();

  GradeBand _gradeBandFromMap(String id, Map<String, dynamic> map) => GradeBand(
    id: id,
    schoolId: map['schoolId'] ?? '',
    gradingSystemId: map['gradingSystemId'] ?? '',
    grade: map['grade'] ?? '',
    minScore: (map['minScore'] as num?)?.toDouble() ?? 0,
    maxScore: (map['maxScore'] as num?)?.toDouble() ?? 0,
    remarks: map['remarks'] ?? '',
    order: map['order'] ?? 0,
    label: map['label'] ?? '',
    gradePoint: (map['gradePoint'] as num?)?.toDouble(),
    isPassing: map['isPassing'] ?? true,
    colorHex: map['colorHex'] ?? '',
    hasNumericBoundary: map['hasNumericBoundary'] ?? true,
  );

  Map<String, dynamic> _gradeBandToMap(GradeBand e) => {
    'schoolId': e.schoolId,
    'gradingSystemId': e.gradingSystemId,
    'grade': e.grade,
    'minScore': e.minScore,
    'maxScore': e.maxScore,
    'remarks': e.remarks,
    'order': e.order,
    'label': e.label,
    'gradePoint': e.gradePoint,
    'isPassing': e.isPassing,
    'colorHex': e.colorHex,
    'hasNumericBoundary': e.hasNumericBoundary,
  };

  // Timetable Config
  @override
  Stream<TimetableConfig> watchTimetableConfig(String schoolId) {
    return _timetableConfigDoc(schoolId).snapshots().map((doc) {
      final map = doc.data();
      if (map == null) return const TimetableConfig();
      return _timetableConfigFromMap(map);
    });
  }

  @override
  Future<void> updateTimetableConfig(TimetableConfig config, String schoolId) =>
      _timetableConfigDoc(schoolId).set(_timetableConfigToMap(config));

  TimetableConfig _timetableConfigFromMap(Map<String, dynamic> map) {
    return TimetableConfig(
      teachingDays: List<String>.from(map['teachingDays'] ?? const []),
      weekendDays: List<String>.from(map['weekendDays'] ?? const []),
      defaultPeriodDurationMinutes:
          (map['defaultPeriodDurationMinutes'] as num?)?.toInt() ?? 0,
      periodsPerDay: map['periodsPerDay'] ?? 0,
      schoolStartTime: map['schoolStartTime'] ?? '',
      schoolEndTime: map['schoolEndTime'] ?? '',
      slots: ((map['slots'] as List?) ?? const [])
          .map(
            (s) => TimetableSlot(
              id: s['id'] ?? '',
              name: s['name'] ?? '',
              startTime: s['startTime'] ?? '',
              endTime: s['endTime'] ?? '',
              type: s['type'] ?? 'period',
              displayOrder: s['displayOrder'] ?? 0,
              isActive: s['isActive'] ?? true,
              days: List<String>.from(s['days'] ?? const []),
              colorHex: s['colorHex'] ?? '',
              notes: s['notes'] ?? '',
            ),
          )
          .toList(),
      specialSchedules: ((map['specialSchedules'] as List?) ?? const []).map((
        schedule,
      ) {
        final start = schedule['effectiveStartDate'];
        final end = schedule['effectiveEndDate'];
        return TimetableSpecialSchedule(
          id: schedule['id'] ?? '',
          name: schedule['name'] ?? '',
          effectiveStartDate: start is Timestamp
              ? start.toDate()
              : DateTime.tryParse(start?.toString() ?? '') ?? DateTime(2000),
          effectiveEndDate: end is Timestamp
              ? end.toDate()
              : DateTime.tryParse(end?.toString() ?? '') ?? DateTime(2000),
          defaultPeriodDurationMinutes:
              (schedule['defaultPeriodDurationMinutes'] as num?)?.toInt(),
          slots: ((schedule['slots'] as List?) ?? const [])
              .map(
                (s) => TimetableSlot(
                  id: s['id'] ?? '',
                  name: s['name'] ?? '',
                  startTime: s['startTime'] ?? '',
                  endTime: s['endTime'] ?? '',
                  type: s['type'] ?? 'period',
                  displayOrder: s['displayOrder'] ?? 0,
                  isActive: s['isActive'] ?? true,
                  days: List<String>.from(s['days'] ?? const []),
                  colorHex: s['colorHex'] ?? '',
                  notes: s['notes'] ?? '',
                ),
              )
              .toList(),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _timetableConfigToMap(TimetableConfig e) => {
    'teachingDays': e.teachingDays,
    'weekendDays': e.weekendDays,
    'defaultPeriodDurationMinutes': e.defaultPeriodDurationMinutes,
    'periodsPerDay': e.periodsPerDay,
    'schoolStartTime': e.schoolStartTime,
    'schoolEndTime': e.schoolEndTime,
    'slots': e.slots
        .map(
          (s) => {
            'id': s.id,
            'name': s.name,
            'startTime': s.startTime,
            'endTime': s.endTime,
            'type': s.type,
            'displayOrder': s.displayOrder,
            'isActive': s.isActive,
            'days': s.days,
            'colorHex': s.colorHex,
            'notes': s.notes,
          },
        )
        .toList(),
    'specialSchedules': e.specialSchedules
        .map(
          (schedule) => {
            'id': schedule.id,
            'name': schedule.name,
            'effectiveStartDate': Timestamp.fromDate(
              schedule.effectiveStartDate,
            ),
            'effectiveEndDate': Timestamp.fromDate(schedule.effectiveEndDate),
            'defaultPeriodDurationMinutes':
                schedule.defaultPeriodDurationMinutes,
            'slots': schedule.slots
                .map(
                  (s) => {
                    'id': s.id,
                    'name': s.name,
                    'startTime': s.startTime,
                    'endTime': s.endTime,
                    'type': s.type,
                    'displayOrder': s.displayOrder,
                    'isActive': s.isActive,
                    'days': s.days,
                    'colorHex': s.colorHex,
                    'notes': s.notes,
                  },
                )
                .toList(),
          },
        )
        .toList(),
  };

  // Attendance Defaults Config
  @override
  Stream<AttendanceDefaultsConfig> watchAttendanceDefaultsConfig(
    String schoolId,
  ) {
    return _attendanceDefaultsConfigDoc(schoolId).snapshots().map((doc) {
      final map = doc.data();
      if (map == null) return const AttendanceDefaultsConfig();
      return AttendanceDefaultsConfig(
        attendanceMode: map['attendanceMode'] ?? 'Daily',
        markingWindow: map['markingWindow'] ?? 'Until End of School Day',
        allowBackdatedAttendance: map['allowBackdatedAttendance'] ?? false,
        autoPresentOnAdmission: map['autoPresentOnAdmission'] ?? false,
      );
    });
  }

  @override
  Future<void> updateAttendanceDefaultsConfig(
    AttendanceDefaultsConfig config,
    String schoolId,
  ) => _attendanceDefaultsConfigDoc(schoolId).set({
    'attendanceMode': config.attendanceMode,
    'markingWindow': config.markingWindow,
    'allowBackdatedAttendance': config.allowBackdatedAttendance,
    'autoPresentOnAdmission': config.autoPresentOnAdmission,
  });

  // Communication Defaults Config
  @override
  Stream<CommunicationDefaultsConfig> watchCommunicationDefaultsConfig(
    String schoolId,
  ) {
    return _communicationDefaultsConfigDoc(schoolId).snapshots().map((doc) {
      final map = doc.data();
      if (map == null) return const CommunicationDefaultsConfig();
      return CommunicationDefaultsConfig(
        defaultChannels: List<String>.from(
          map['defaultChannels'] ?? const ['app'],
        ),
        defaultLanguage: map['defaultLanguage'] ?? 'English',
      );
    });
  }

  @override
  Future<void> updateCommunicationDefaultsConfig(
    CommunicationDefaultsConfig config,
    String schoolId,
  ) => _communicationDefaultsConfigDoc(schoolId).set({
    'defaultChannels': config.defaultChannels,
    'defaultLanguage': config.defaultLanguage,
  });

  // Attendance Types
  @override
  Stream<List<AttendanceTypeDef>> watchAttendanceTypes(String schoolId) {
    return _attendanceTypes
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _attendanceTypeFromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveAttendanceType(AttendanceTypeDef type) =>
      _attendanceTypes.doc(type.id).set(_attendanceTypeToMap(type));

  @override
  Future<void> deleteAttendanceType(String typeId) =>
      _attendanceTypes.doc(typeId).delete();

  AttendanceTypeDef _attendanceTypeFromMap(
    String id,
    Map<String, dynamic> map,
  ) => AttendanceTypeDef(
    id: id,
    schoolId: map['schoolId'] ?? '',
    name: map['name'] ?? '',
    colorHex: map['colorHex'] ?? '',
    isActive: map['isActive'] ?? true,
  );

  Map<String, dynamic> _attendanceTypeToMap(AttendanceTypeDef e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'colorHex': e.colorHex,
    'isActive': e.isActive,
  };

  // Attendance Sessions
  @override
  Stream<List<AttendanceSessionDef>> watchAttendanceSessions(String schoolId) {
    return _attendanceSessions
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _attendanceSessionFromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveAttendanceSession(AttendanceSessionDef session) =>
      _attendanceSessions.doc(session.id).set(_attendanceSessionToMap(session));

  @override
  Future<void> deleteAttendanceSession(String sessionId) =>
      _attendanceSessions.doc(sessionId).delete();

  AttendanceSessionDef _attendanceSessionFromMap(
    String id,
    Map<String, dynamic> map,
  ) => AttendanceSessionDef(
    id: id,
    schoolId: map['schoolId'] ?? '',
    name: map['name'] ?? '',
    isActive: map['isActive'] ?? true,
  );

  Map<String, dynamic> _attendanceSessionToMap(AttendanceSessionDef e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'isActive': e.isActive,
  };

  // Announcement Categories
  @override
  Stream<List<AnnouncementCategoryDef>> watchAnnouncementCategories(
    String schoolId,
  ) {
    return _announcementCategories
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _announcementCategoryFromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveAnnouncementCategory(AnnouncementCategoryDef category) =>
      _announcementCategories
          .doc(category.id)
          .set(_announcementCategoryToMap(category));

  @override
  Future<void> deleteAnnouncementCategory(String categoryId) =>
      _announcementCategories.doc(categoryId).delete();

  AnnouncementCategoryDef _announcementCategoryFromMap(
    String id,
    Map<String, dynamic> map,
  ) => AnnouncementCategoryDef(
    id: id,
    schoolId: map['schoolId'] ?? '',
    name: map['name'] ?? '',
    isActive: map['isActive'] ?? true,
  );

  Map<String, dynamic> _announcementCategoryToMap(AnnouncementCategoryDef e) =>
      {'schoolId': e.schoolId, 'name': e.name, 'isActive': e.isActive};

  // Notification Categories
  @override
  Stream<List<NotificationCategoryDef>> watchNotificationCategories(
    String schoolId,
  ) {
    return _notificationCategories
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _notificationCategoryFromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveNotificationCategory(NotificationCategoryDef category) =>
      _notificationCategories
          .doc(category.id)
          .set(_notificationCategoryToMap(category));

  @override
  Future<void> deleteNotificationCategory(String categoryId) =>
      _notificationCategories.doc(categoryId).delete();

  NotificationCategoryDef _notificationCategoryFromMap(
    String id,
    Map<String, dynamic> map,
  ) => NotificationCategoryDef(
    id: id,
    schoolId: map['schoolId'] ?? '',
    name: map['name'] ?? '',
    isActive: map['isActive'] ?? true,
  );

  Map<String, dynamic> _notificationCategoryToMap(NotificationCategoryDef e) =>
      {'schoolId': e.schoolId, 'name': e.name, 'isActive': e.isActive};

  // Message Templates
  @override
  Stream<List<MessageTemplateDef>> watchMessageTemplates(String schoolId) {
    return _messageTemplates
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _messageTemplateFromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveMessageTemplate(MessageTemplateDef template) =>
      _messageTemplates.doc(template.id).set(_messageTemplateToMap(template));

  @override
  Future<void> deleteMessageTemplate(String templateId) =>
      _messageTemplates.doc(templateId).delete();

  MessageTemplateDef _messageTemplateFromMap(
    String id,
    Map<String, dynamic> map,
  ) => MessageTemplateDef(
    id: id,
    schoolId: map['schoolId'] ?? '',
    name: map['name'] ?? '',
    channel: map['channel'] ?? 'sms',
    subject: map['subject'] ?? '',
    body: map['body'] ?? '',
    isActive: map['isActive'] ?? true,
  );

  Map<String, dynamic> _messageTemplateToMap(MessageTemplateDef e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'channel': e.channel,
    'subject': e.subject,
    'body': e.body,
    'isActive': e.isActive,
  };

  // Document Templates
  @override
  Stream<List<DocumentTemplateDef>> watchDocumentTemplates(String schoolId) {
    return _documentTemplates
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _documentTemplateFromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveDocumentTemplate(DocumentTemplateDef template) =>
      _documentTemplates.doc(template.id).set(_documentTemplateToMap(template));

  @override
  Future<void> deleteDocumentTemplate(String templateId) =>
      _documentTemplates.doc(templateId).delete();

  DocumentTemplateDef _documentTemplateFromMap(
    String id,
    Map<String, dynamic> map,
  ) => DocumentTemplateDef(
    id: id,
    schoolId: map['schoolId'] ?? '',
    name: map['name'] ?? '',
    templateType: map['templateType'] ?? '',
    description: map['description'] ?? '',
    isActive: map['isActive'] ?? true,
  );

  Map<String, dynamic> _documentTemplateToMap(DocumentTemplateDef e) => {
    'schoolId': e.schoolId,
    'name': e.name,
    'templateType': e.templateType,
    'description': e.description,
    'isActive': e.isActive,
  };

  // Custom Fields
  @override
  Stream<List<CustomFieldDef>> watchCustomFields(String schoolId) {
    return _customFields
        .where('schoolId', isEqualTo: schoolId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _customFieldFromMap(d.id, d.data()))
              .toList(),
        );
  }

  @override
  Future<void> saveCustomField(CustomFieldDef field) =>
      _customFields.doc(field.id).set(_customFieldToMap(field));

  @override
  Future<void> deleteCustomField(String fieldId) =>
      _customFields.doc(fieldId).delete();

  CustomFieldDef _customFieldFromMap(String id, Map<String, dynamic> map) =>
      CustomFieldDef(
        id: id,
        schoolId: map['schoolId'] ?? '',
        appliesTo: map['appliesTo'] ?? '',
        fieldName: map['fieldName'] ?? '',
        fieldType: map['fieldType'] ?? 'text',
        options: List<String>.from(map['options'] ?? const []),
        isRequired: map['isRequired'] ?? false,
        isActive: map['isActive'] ?? true,
      );

  Map<String, dynamic> _customFieldToMap(CustomFieldDef e) => {
    'schoolId': e.schoolId,
    'appliesTo': e.appliesTo,
    'fieldName': e.fieldName,
    'fieldType': e.fieldType,
    'options': e.options,
    'isRequired': e.isRequired,
    'isActive': e.isActive,
  };
}
