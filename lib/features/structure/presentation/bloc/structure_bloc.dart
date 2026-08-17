import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/assessment_grading_entities.dart';
import '../../domain/entities/campus_entities.dart';
import '../../domain/entities/hostel_entities.dart';
import '../../domain/entities/timetable_config.dart';
import '../../domain/entities/transport_structure_entities.dart';
import '../../domain/repositories/structure_repository.dart';
import '../../domain/services/structure_integrity_validator.dart';
import 'structure_event.dart';
import 'structure_state.dart';

class StructureBloc extends Bloc<StructureEvent, StructureState> {
  final StructureRepository repository;
  final StructureIntegrityValidator _validator;

  final Set<String> _loadedParts = <String>{};
  static const Set<String> _requiredLoads = {
    'levels',
    'years',
    'terms',
    'classes',
    'streams',
    'subjects',
    'departments',
    'designations',
    'roles',
    'toggles',
    'institution',
    'houses',
    'clubs',
    'facilities',
    'hostels',
    'hostelRooms',
    'routes',
    'stops',
    'vehicles',
    'feeCategories',
    'assessmentTypes',
    'gradingSystems',
    'gradeBands',
    'timetable',
    'attendanceTypes',
    'attendanceSessions',
    'announcementCategories',
    'notificationCategories',
    'messageTemplates',
    'documentTemplates',
    'customFields',
  };

  StreamSubscription? _levelsSub;
  StreamSubscription? _yearsSub;
  StreamSubscription? _termsSub;
  StreamSubscription? _classesSub;
  StreamSubscription? _streamsSub;
  StreamSubscription? _subjectsSub;
  StreamSubscription? _departmentsSub;
  StreamSubscription? _designationsSub;
  StreamSubscription? _staffRolesSub;
  StreamSubscription? _togglesSub;
  StreamSubscription? _institutionProfileSub;
  StreamSubscription? _housesSub;
  StreamSubscription? _clubsSub;
  StreamSubscription? _facilitiesSub;
  StreamSubscription? _hostelsSub;
  StreamSubscription? _hostelRoomsSub;
  StreamSubscription? _transportRoutesSub;
  StreamSubscription? _transportStopsSub;
  StreamSubscription? _transportVehiclesSub;
  StreamSubscription? _feeCategoriesSub;
  StreamSubscription? _assessmentTypesSub;
  StreamSubscription? _gradingSystemsSub;
  StreamSubscription? _gradeBandsSub;
  StreamSubscription? _timetableConfigSub;
  StreamSubscription? _attendanceTypesSub;
  StreamSubscription? _attendanceSessionsSub;
  StreamSubscription? _announcementCategoriesSub;
  StreamSubscription? _notificationCategoriesSub;
  StreamSubscription? _messageTemplatesSub;
  StreamSubscription? _documentTemplatesSub;
  StreamSubscription? _customFieldsSub;

  StructureBloc({
    required this.repository,
    StructureIntegrityValidator validator = const StructureIntegrityValidator(),
  })  : _validator = validator,
        super(const StructureState()) {
    on<LoadStructureData>(_onLoad);

    on<LevelsUpdated>((event, emit) => _loaded(emit, 'levels', state.copyWith(levels: event.levels)));
    on<AcademicYearsUpdated>((event, emit) => _loaded(emit, 'years', state.copyWith(academicYears: event.years)));
    on<AcademicTermsUpdated>((event, emit) => _loaded(emit, 'terms', state.copyWith(academicTerms: event.terms)));
    on<ClassesUpdated>((event, emit) => _loaded(emit, 'classes', state.copyWith(classes: event.classes)));
    on<StreamsUpdated>((event, emit) => _loaded(emit, 'streams', state.copyWith(streams: event.streams)));
    on<SubjectsUpdated>((event, emit) => _loaded(emit, 'subjects', state.copyWith(subjects: event.subjects)));
    on<DepartmentsUpdated>((event, emit) => _loaded(emit, 'departments', state.copyWith(departments: event.departments)));
    on<DesignationsUpdated>((event, emit) => _loaded(emit, 'designations', state.copyWith(designations: event.designations)));
    on<StaffRolesUpdated>((event, emit) => _loaded(emit, 'roles', state.copyWith(staffRoles: event.roles)));
    on<FeatureTogglesUpdated>((event, emit) => _loaded(emit, 'toggles', state.copyWith(featureToggles: event.toggles)));
    on<InstitutionProfileUpdated>((event, emit) => _loaded(emit, 'institution', state.copyWith(institutionProfile: event.profile)));
    on<HousesUpdated>((event, emit) => _loaded(emit, 'houses', state.copyWith(houses: event.houses)));
    on<ClubsUpdated>((event, emit) => _loaded(emit, 'clubs', state.copyWith(clubs: event.clubs)));
    on<FacilitiesUpdated>((event, emit) => _loaded(emit, 'facilities', state.copyWith(facilities: event.facilities)));
    on<HostelsUpdated>((event, emit) => _loaded(emit, 'hostels', state.copyWith(hostels: event.hostels)));
    on<HostelRoomsUpdated>((event, emit) => _loaded(emit, 'hostelRooms', state.copyWith(hostelRooms: event.rooms)));
    on<TransportRoutesUpdated>((event, emit) => _loaded(emit, 'routes', state.copyWith(transportRoutes: event.routes)));
    on<TransportStopsUpdated>((event, emit) => _loaded(emit, 'stops', state.copyWith(transportStops: event.stops)));
    on<TransportVehiclesUpdated>((event, emit) => _loaded(emit, 'vehicles', state.copyWith(transportVehicles: event.vehicles)));
    on<FeeCategoriesUpdated>((event, emit) => _loaded(emit, 'feeCategories', state.copyWith(feeCategories: event.categories)));
    on<AssessmentTypesUpdated>((event, emit) => _loaded(emit, 'assessmentTypes', state.copyWith(assessmentTypes: event.types)));
    on<GradingSystemsUpdated>((event, emit) => _loaded(emit, 'gradingSystems', state.copyWith(gradingSystems: event.systems)));
    on<GradeBandsUpdated>((event, emit) => _loaded(emit, 'gradeBands', state.copyWith(gradeBands: event.bands)));
    on<TimetableConfigUpdated>((event, emit) => _loaded(emit, 'timetable', state.copyWith(timetableConfig: event.config)));
    on<AttendanceTypesUpdated>((event, emit) => _loaded(emit, 'attendanceTypes', state.copyWith(attendanceTypes: event.types)));
    on<AttendanceSessionsUpdated>((event, emit) => _loaded(emit, 'attendanceSessions', state.copyWith(attendanceSessions: event.sessions)));
    on<AnnouncementCategoriesUpdated>((event, emit) => _loaded(emit, 'announcementCategories', state.copyWith(announcementCategories: event.categories)));
    on<NotificationCategoriesUpdated>((event, emit) => _loaded(emit, 'notificationCategories', state.copyWith(notificationCategories: event.categories)));
    on<MessageTemplatesUpdated>((event, emit) => _loaded(emit, 'messageTemplates', state.copyWith(messageTemplates: event.templates)));
    on<DocumentTemplatesUpdated>((event, emit) => _loaded(emit, 'documentTemplates', state.copyWith(documentTemplates: event.templates)));
    on<CustomFieldsUpdated>((event, emit) => _loaded(emit, 'customFields', state.copyWith(customFields: event.fields)));
    on<StructureLoadFailed>((event, emit) => emit(state.copyWith(isLoading: false, errorMessage: event.message)));

    on<SaveLevelRequested>((event, emit) async {
      final error = _validator.validateLevel(event.level, state.levels);
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addLevel(event.level));
    });
    on<DeleteLevelRequested>((event, emit) async {
      if (state.classes.any((item) => item.levelId == event.levelId)) {
        return _validationFailed(emit, 'This level is used by classes. Deactivate it instead of deleting it.');
      }
      await _write(emit, () => repository.deleteLevel(event.levelId));
    });

    on<SaveAcademicYearRequested>((event, emit) async {
      final error = _validator.validateAcademicYear(event.year, state.academicYears);
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addAcademicYear(event.year));
    });
    on<DeleteAcademicYearRequested>((event, emit) async {
      if (state.academicTerms.any((item) => item.academicYearId == event.yearId)) {
        return _validationFailed(emit, 'This academic year contains terms/semesters. Archive it instead of deleting it.');
      }
      await _write(emit, () => repository.deleteAcademicYear(event.yearId));
    });
    on<SetCurrentAcademicYearRequested>((event, emit) async {
      final matches = state.academicYears.where((item) => item.id == event.yearId && !item.isArchived);
      if (matches.isEmpty) return _validationFailed(emit, 'Select a valid non-archived academic year.');
      await _write(emit, () => repository.setCurrentAcademicYear(event.yearId));
    });

    on<SaveAcademicTermRequested>((event, emit) async {
      final error = _validator.validateAcademicTerm(event.term, state.academicYears, state.academicTerms);
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addAcademicTerm(event.term));
    });
    on<DeleteAcademicTermRequested>((event, emit) async {
      await _write(emit, () => repository.deleteAcademicTerm(event.termId));
    });
    on<SetCurrentAcademicTermRequested>((event, emit) async {
      final matches = state.academicTerms.where((item) => item.id == event.termId);
      if (matches.isEmpty) return _validationFailed(emit, 'Select a valid term/semester.');
      final currentYearIds = state.academicYears.where((item) => item.isCurrent && !item.isArchived).map((item) => item.id).toSet();
      if (!currentYearIds.contains(matches.first.academicYearId)) {
        return _validationFailed(emit, 'Set the term’s academic year as current before making this term current.');
      }
      await _write(emit, () => repository.setCurrentAcademicTerm(event.termId));
    });

    on<SaveClassRequested>((event, emit) async {
      final error = _validator.validateClass(
        event.schoolClass,
        levels: state.levels,
        classes: state.classes,
        streams: state.streams,
      );
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addClass(event.schoolClass));
    });
    on<DeleteClassRequested>((event, emit) async {
      if (state.streams.any((item) => item.classId == event.classId)) {
        return _validationFailed(emit, 'This class has streams/sections. Deactivate it instead of deleting it.');
      }
      await _write(emit, () => repository.deleteClass(event.classId));
    });

    on<SaveStreamRequested>((event, emit) async {
      final error = _validator.validateStream(
        event.stream,
        classes: state.classes,
        streams: state.streams,
      );
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addStream(event.stream));
    });
    on<DeleteStreamRequested>((event, emit) async {
      await _write(emit, () => repository.deleteStream(event.streamId));
    });

    on<SaveSubjectRequested>((event, emit) async {
      final error = _validator.validateSubject(
        event.subject,
        subjects: state.subjects,
        departments: state.departments,
      );
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addSubject(event.subject));
    });
    on<DeleteSubjectRequested>((event, emit) async {
      return _validationFailed(emit, 'Hard-delete of subjects is disabled to protect academic history. Deactivate the subject instead.');
    });

    on<SaveDepartmentRequested>((event, emit) async {
      final error = _validator.validateDepartment(event.department, state.departments);
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addDepartment(event.department));
    });
    on<DeleteDepartmentRequested>((event, emit) async {
      if (state.subjects.any((item) => item.departmentId == event.departmentId)) {
        return _validationFailed(emit, 'This department is referenced by subjects. Deactivate it instead of deleting it.');
      }
      await _write(emit, () => repository.deleteDepartment(event.departmentId));
    });

    on<SaveDesignationRequested>((event, emit) async {
      final error = _validator.validateDesignation(event.designation, state.designations);
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addDesignation(event.designation));
    });
    on<DeleteDesignationRequested>((event, emit) async {
      if (state.staffRoles.any((item) => item.designationId == event.designationId)) {
        return _validationFailed(emit, 'This designation is referenced by staff roles. Deactivate it instead of deleting it.');
      }
      await _write(emit, () => repository.deleteDesignation(event.designationId));
    });

    on<SaveStaffRoleRequested>((event, emit) async {
      final error = _validator.validateRole(
        event.role,
        roles: state.staffRoles,
        designations: state.designations,
      );
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addStaffRole(event.role));
    });
    on<DeleteStaffRoleRequested>((event, emit) async {
      return _validationFailed(emit, 'Hard-delete of staff roles is disabled to protect responsibility history. Deactivate the role instead.');
    });

    on<UpdateFeatureTogglesRequested>((event, emit) async => _write(emit, () => repository.updateFeatureToggles(event.toggles)));
    on<UpdateInstitutionProfileRequested>((event, emit) async => _write(emit, () => repository.updateInstitutionProfile(event.profile)));

    on<SaveHouseRequested>((event, emit) async {
      if (event.house.name.trim().isEmpty) return _validationFailed(emit, 'Enter a house name.');
      if (_duplicateActiveName(event.house.id, event.house.name, state.houses.map((item) => (item.id, item.name, item.isActive)))) {
        return _validationFailed(emit, 'An active house with this name already exists.');
      }
      await _write(emit, () => repository.addHouse(event.house));
    });
    on<DeleteHouseRequested>((event, emit) async => _write(emit, () => repository.deleteHouse(event.houseId)));

    on<SaveClubRequested>((event, emit) async {
      if (event.club.name.trim().isEmpty) return _validationFailed(emit, 'Enter a club or society name.');
      if (_duplicateActiveName(event.club.id, event.club.name, state.clubs.map((item) => (item.id, item.name, item.isActive)))) {
        return _validationFailed(emit, 'An active club with this name already exists.');
      }
      await _write(emit, () => repository.addClub(event.club));
    });
    on<DeleteClubRequested>((event, emit) async => _write(emit, () => repository.deleteClub(event.clubId)));

    on<SaveFacilityRequested>((event, emit) async {
      final error = _validateFacility(event.facility, state.facilities);
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addFacility(event.facility));
    });
    on<DeleteFacilityRequested>((event, emit) async => _write(emit, () => repository.deleteFacility(event.facilityId)));

    on<SaveHostelRequested>((event, emit) async {
      final error = _validateHostel(event.hostel, state.hostels, state.hostelRooms);
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addHostel(event.hostel));
    });
    on<DeleteHostelRequested>((event, emit) async {
      if (state.hostelRooms.any((item) => item.hostelId == event.hostelId)) {
        return _validationFailed(emit, 'This hostel contains rooms. Deactivate it instead of deleting it.');
      }
      await _write(emit, () => repository.deleteHostel(event.hostelId));
    });

    on<SaveHostelRoomRequested>((event, emit) async {
      final error = _validateHostelRoom(event.room, state.hostels, state.hostelRooms);
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addHostelRoom(event.room));
    });
    on<DeleteHostelRoomRequested>((event, emit) async => _write(emit, () => repository.deleteHostelRoom(event.roomId)));

    on<SaveTransportRouteRequested>((event, emit) async {
      if (event.route.name.trim().isEmpty) return _validationFailed(emit, 'Enter a transport route name.');
      await _write(emit, () => repository.addTransportRoute(event.route));
    });
    on<DeleteTransportRouteRequested>((event, emit) async {
      if (state.transportStops.any((item) => item.routeId == event.routeId) ||
          state.transportVehicles.any((item) => item.routeId == event.routeId)) {
        return _validationFailed(emit, 'This route has stops or vehicles. Deactivate it instead of deleting it.');
      }
      await _write(emit, () => repository.deleteTransportRoute(event.routeId));
    });

    on<SaveTransportStopRequested>((event, emit) async {
      final error = _validateTransportStop(event.stop, state.transportRoutes);
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addTransportStop(event.stop));
    });
    on<DeleteTransportStopRequested>((event, emit) async => _write(emit, () => repository.deleteTransportStop(event.stopId)));

    on<SaveTransportVehicleRequested>((event, emit) async {
      final error = _validateTransportVehicle(event.vehicle, state.transportRoutes);
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addTransportVehicle(event.vehicle));
    });
    on<DeleteTransportVehicleRequested>((event, emit) async => _write(emit, () => repository.deleteTransportVehicle(event.vehicleId)));

    on<SaveFeeCategoryRequested>((event, emit) async => _write(emit, () => repository.addFeeCategory(event.category)));
    on<DeleteFeeCategoryRequested>((event, emit) async => _write(emit, () => repository.deleteFeeCategory(event.categoryId)));

    on<SaveAssessmentTypeRequested>((event, emit) async {
      if (event.type.name.trim().isEmpty) return _validationFailed(emit, 'Enter an assessment type name.');
      if (event.type.weightPercentage < 0 || event.type.weightPercentage > 100) {
        return _validationFailed(emit, 'Assessment weight must be between 0 and 100.');
      }
      await _write(emit, () => repository.addAssessmentType(event.type));
    });
    on<DeleteAssessmentTypeRequested>((event, emit) async => _write(emit, () => repository.deleteAssessmentType(event.typeId)));

    on<SaveGradingSystemRequested>((event, emit) async {
      if (event.system.name.trim().isEmpty) return _validationFailed(emit, 'Enter a grading system name.');
      await _write(emit, () async {
        if (event.system.isDefault) {
          for (final current in state.gradingSystems.where((item) => item.id != event.system.id && item.isDefault)) {
            await repository.updateGradingSystem(current.copyWith(isDefault: false));
          }
        }
        await repository.addGradingSystem(event.system);
      });
    });
    on<DeleteGradingSystemRequested>((event, emit) async {
      if (state.gradeBands.any((item) => item.gradingSystemId == event.systemId)) {
        return _validationFailed(emit, 'This grading system has grade bands. Deactivate it instead of deleting it.');
      }
      await _write(emit, () => repository.deleteGradingSystem(event.systemId));
    });

    on<SaveGradeBandRequested>((event, emit) async {
      final error = _validateGradeBand(event.band, state.gradingSystems, state.gradeBands);
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.addGradeBand(event.band));
    });
    on<DeleteGradeBandRequested>((event, emit) async => _write(emit, () => repository.deleteGradeBand(event.bandId)));

    on<UpdateTimetableConfigRequested>((event, emit) async {
      final error = _validateTimetableConfig(event.config);
      if (error != null) return _validationFailed(emit, error);
      await _write(emit, () => repository.updateTimetableConfig(event.config));
    });

    on<SaveAttendanceTypeRequested>((event, emit) async => _write(emit, () => repository.addAttendanceType(event.type)));
    on<DeleteAttendanceTypeRequested>((event, emit) async => _write(emit, () => repository.deleteAttendanceType(event.typeId)));
    on<SaveAttendanceSessionRequested>((event, emit) async => _write(emit, () => repository.addAttendanceSession(event.session)));
    on<DeleteAttendanceSessionRequested>((event, emit) async => _write(emit, () => repository.deleteAttendanceSession(event.sessionId)));

    on<SaveAnnouncementCategoryRequested>((event, emit) async => _write(emit, () => repository.addAnnouncementCategory(event.category)));
    on<DeleteAnnouncementCategoryRequested>((event, emit) async => _write(emit, () => repository.deleteAnnouncementCategory(event.categoryId)));
    on<SaveNotificationCategoryRequested>((event, emit) async => _write(emit, () => repository.addNotificationCategory(event.category)));
    on<DeleteNotificationCategoryRequested>((event, emit) async => _write(emit, () => repository.deleteNotificationCategory(event.categoryId)));
    on<SaveMessageTemplateRequested>((event, emit) async => _write(emit, () => repository.addMessageTemplate(event.template)));
    on<DeleteMessageTemplateRequested>((event, emit) async => _write(emit, () => repository.deleteMessageTemplate(event.templateId)));
    on<SaveDocumentTemplateRequested>((event, emit) async => _write(emit, () => repository.addDocumentTemplate(event.template)));
    on<DeleteDocumentTemplateRequested>((event, emit) async => _write(emit, () => repository.deleteDocumentTemplate(event.templateId)));
    on<SaveCustomFieldRequested>((event, emit) async => _write(emit, () => repository.addCustomField(event.field)));
    on<DeleteCustomFieldRequested>((event, emit) async => _write(emit, () => repository.deleteCustomField(event.fieldId)));
  }

  void _loaded(Emitter<StructureState> emit, String part, StructureState next) {
    _loadedParts.add(part);
    emit(next.copyWith(isLoading: !_loadedParts.containsAll(_requiredLoads)));
  }

  void _validationFailed(Emitter<StructureState> emit, String message) {
    emit(state.copyWith(isLoading: false, errorMessage: message));
  }

  Future<void> _write(
    Emitter<StructureState> emit,
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  bool _duplicateActiveName(
    String id,
    String name,
    Iterable<(String, String, bool)> records,
  ) {
    final normalized = name.trim().toLowerCase();
    return records.any((record) => record.$1 != id && record.$3 && record.$2.trim().toLowerCase() == normalized);
  }

  String? _validateFacility(Facility candidate, List<Facility> facilities) {
    if (candidate.name.trim().isEmpty) return 'Enter a room or learning-space name.';
    if (candidate.capacity < 0) return 'Room capacity cannot be negative.';
    if (_duplicateActiveName(candidate.id, candidate.name, facilities.map((item) => (item.id, item.name, item.isActive)))) {
      return 'An active room/learning space with this name already exists.';
    }
    return null;
  }

  String? _validateHostel(
    Hostel candidate,
    List<Hostel> hostels,
    List<HostelRoom> rooms,
  ) {
    if (candidate.name.trim().isEmpty) return 'Enter a hostel/dormitory name.';
    if (candidate.capacity < 0) return 'Hostel capacity cannot be negative.';
    if (_duplicateActiveName(candidate.id, candidate.name, hostels.map((item) => (item.id, item.name, item.isActive)))) {
      return 'An active hostel/dormitory with this name already exists.';
    }
    final allocated = rooms.where((item) => item.hostelId == candidate.id && item.isActive).fold<int>(0, (sum, item) => sum + item.bedCapacity);
    if (candidate.capacity > 0 && allocated > candidate.capacity) {
      return 'Hostel capacity cannot be reduced to ${candidate.capacity}; active rooms already allocate $allocated beds.';
    }
    return null;
  }

  String? _validateHostelRoom(
    HostelRoom candidate,
    List<Hostel> hostels,
    List<HostelRoom> rooms,
  ) {
    final parents = hostels.where((item) => item.id == candidate.hostelId && item.isActive);
    if (parents.isEmpty) return 'Select an active hostel/dormitory.';
    final parent = parents.first;
    if (candidate.roomNumber.trim().isEmpty) return 'Enter a room number/name.';
    if (candidate.bedCapacity < 0) return 'Bed capacity cannot be negative.';
    final duplicate = rooms.any((item) => item.id != candidate.id && item.hostelId == candidate.hostelId && item.isActive && candidate.isActive && item.roomNumber.trim().toLowerCase() == candidate.roomNumber.trim().toLowerCase());
    if (duplicate) return 'This hostel already contains a room with this number/name.';
    final allocated = rooms.where((item) => item.id != candidate.id && item.hostelId == candidate.hostelId && item.isActive).fold<int>(0, (sum, item) => sum + item.bedCapacity);
    if (candidate.isActive && parent.capacity > 0 && allocated + candidate.bedCapacity > parent.capacity) {
      return 'Room capacity exceeds ${parent.name} capacity. Available beds: ${(parent.capacity - allocated).clamp(0, parent.capacity)}.';
    }
    return null;
  }

  String? _validateTransportStop(
    TransportStop candidate,
    List<TransportRoute> routes,
  ) {
    if (candidate.name.trim().isEmpty) return 'Enter a transport stop name.';
    if (!routes.any((item) => item.id == candidate.routeId && item.isActive)) {
      return 'Select an active transport route.';
    }
    return null;
  }

  String? _validateTransportVehicle(
    TransportVehicle candidate,
    List<TransportRoute> routes,
  ) {
    if (candidate.busNumber.trim().isEmpty) return 'Enter a vehicle/bus number.';
    if (candidate.capacity < 0) return 'Vehicle capacity cannot be negative.';
    if (candidate.routeId.isNotEmpty && !routes.any((item) => item.id == candidate.routeId && item.isActive)) {
      return 'The selected route is missing or inactive.';
    }
    return null;
  }

  String? _validateGradeBand(
    GradeBand candidate,
    List<GradingSystemDef> systems,
    List<GradeBand> bands,
  ) {
    if (!systems.any((item) => item.id == candidate.gradingSystemId && item.isActive)) {
      return 'Select an active grading system.';
    }
    if (candidate.grade.trim().isEmpty) return 'Enter a grade/achievement label.';
    if (candidate.minScore > candidate.maxScore) return 'Minimum score cannot exceed maximum score.';
    final duplicate = bands.any((item) => item.id != candidate.id && item.gradingSystemId == candidate.gradingSystemId && item.grade.trim().toLowerCase() == candidate.grade.trim().toLowerCase());
    if (duplicate) return 'This grade label already exists in the grading system.';
    final overlap = bands.any((item) => item.id != candidate.id && item.gradingSystemId == candidate.gradingSystemId && candidate.minScore <= item.maxScore && candidate.maxScore >= item.minScore);
    if (overlap) return 'This grade range overlaps another grade band.';
    return null;
  }

  String? _validateTimetableConfig(TimetableConfig config) {
    if (config.teachingDays.isEmpty) return 'Select at least one teaching day.';
    final schoolStart = _minutes(config.schoolStartTime);
    final schoolEnd = _minutes(config.schoolEndTime);
    if (schoolStart == null || schoolEnd == null || schoolStart >= schoolEnd) {
      return 'Set valid school start and end times.';
    }
    if (config.slots.isEmpty) return 'Add at least one timetable slot.';
    final slots = <({String name, int start, int end})>[];
    for (final slot in config.slots) {
      final start = _minutes(slot.startTime);
      final end = _minutes(slot.endTime);
      if (start == null || end == null || start >= end) {
        return '${slot.name} has invalid start/end times.';
      }
      if (start < schoolStart || end > schoolEnd) {
        return '${slot.name} falls outside the configured school day.';
      }
      slots.add((name: slot.name, start: start, end: end));
    }
    slots.sort((a, b) => a.start.compareTo(b.start));
    for (var i = 1; i < slots.length; i++) {
      if (slots[i].start < slots[i - 1].end) {
        return '${slots[i].name} overlaps ${slots[i - 1].name}.';
      }
    }
    return null;
  }

  int? _minutes(String raw) {
    final parts = raw.trim().split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return hour * 60 + minute;
  }

  Future<void> _onLoad(
    LoadStructureData event,
    Emitter<StructureState> emit,
  ) async {
    _loadedParts.clear();
    emit(state.copyWith(isLoading: true));
    await _cancelSubscriptions();

    _levelsSub = _watch(repository.watchLevels(), (value) => LevelsUpdated(value));
    _yearsSub = _watch(repository.watchAcademicYears(), (value) => AcademicYearsUpdated(value));
    _termsSub = _watch(repository.watchAcademicTerms(), (value) => AcademicTermsUpdated(value));
    _classesSub = _watch(repository.watchClasses(), (value) => ClassesUpdated(value));
    _streamsSub = _watch(repository.watchStreams(), (value) => StreamsUpdated(value));
    _subjectsSub = _watch(repository.watchSubjects(), (value) => SubjectsUpdated(value));
    _departmentsSub = _watch(repository.watchDepartments(), (value) => DepartmentsUpdated(value));
    _designationsSub = _watch(repository.watchDesignations(), (value) => DesignationsUpdated(value));
    _staffRolesSub = _watch(repository.watchStaffRoles(), (value) => StaffRolesUpdated(value));
    _togglesSub = _watch(repository.watchFeatureToggles(), (value) => FeatureTogglesUpdated(value));
    _institutionProfileSub = _watch(repository.watchInstitutionProfile(), (value) => InstitutionProfileUpdated(value));
    _housesSub = _watch(repository.watchHouses(), (value) => HousesUpdated(value));
    _clubsSub = _watch(repository.watchClubs(), (value) => ClubsUpdated(value));
    _facilitiesSub = _watch(repository.watchFacilities(), (value) => FacilitiesUpdated(value));
    _hostelsSub = _watch(repository.watchHostels(), (value) => HostelsUpdated(value));
    _hostelRoomsSub = _watch(repository.watchHostelRooms(), (value) => HostelRoomsUpdated(value));
    _transportRoutesSub = _watch(repository.watchTransportRoutes(), (value) => TransportRoutesUpdated(value));
    _transportStopsSub = _watch(repository.watchTransportStops(), (value) => TransportStopsUpdated(value));
    _transportVehiclesSub = _watch(repository.watchTransportVehicles(), (value) => TransportVehiclesUpdated(value));
    _feeCategoriesSub = _watch(repository.watchFeeCategories(), (value) => FeeCategoriesUpdated(value));
    _assessmentTypesSub = _watch(repository.watchAssessmentTypes(), (value) => AssessmentTypesUpdated(value));
    _gradingSystemsSub = _watch(repository.watchGradingSystems(), (value) => GradingSystemsUpdated(value));
    _gradeBandsSub = _watch(repository.watchGradeBands(), (value) => GradeBandsUpdated(value));
    _timetableConfigSub = _watch(repository.watchTimetableConfig(), (value) => TimetableConfigUpdated(value));
    _attendanceTypesSub = _watch(repository.watchAttendanceTypes(), (value) => AttendanceTypesUpdated(value));
    _attendanceSessionsSub = _watch(repository.watchAttendanceSessions(), (value) => AttendanceSessionsUpdated(value));
    _announcementCategoriesSub = _watch(repository.watchAnnouncementCategories(), (value) => AnnouncementCategoriesUpdated(value));
    _notificationCategoriesSub = _watch(repository.watchNotificationCategories(), (value) => NotificationCategoriesUpdated(value));
    _messageTemplatesSub = _watch(repository.watchMessageTemplates(), (value) => MessageTemplatesUpdated(value));
    _documentTemplatesSub = _watch(repository.watchDocumentTemplates(), (value) => DocumentTemplatesUpdated(value));
    _customFieldsSub = _watch(repository.watchCustomFields(), (value) => CustomFieldsUpdated(value));
  }

  StreamSubscription<T> _watch<T>(
    Stream<T> stream,
    StructureEvent Function(T) eventBuilder,
  ) {
    return stream.listen(
      (value) => add(eventBuilder(value)),
      onError: (Object error) => add(StructureLoadFailed(error.toString())),
    );
  }

  Future<void> _cancelSubscriptions() async {
    final subscriptions = <StreamSubscription?>[
      _levelsSub,
      _yearsSub,
      _termsSub,
      _classesSub,
      _streamsSub,
      _subjectsSub,
      _departmentsSub,
      _designationsSub,
      _staffRolesSub,
      _togglesSub,
      _institutionProfileSub,
      _housesSub,
      _clubsSub,
      _facilitiesSub,
      _hostelsSub,
      _hostelRoomsSub,
      _transportRoutesSub,
      _transportStopsSub,
      _transportVehiclesSub,
      _feeCategoriesSub,
      _assessmentTypesSub,
      _gradingSystemsSub,
      _gradeBandsSub,
      _timetableConfigSub,
      _attendanceTypesSub,
      _attendanceSessionsSub,
      _announcementCategoriesSub,
      _notificationCategoriesSub,
      _messageTemplatesSub,
      _documentTemplatesSub,
      _customFieldsSub,
    ];
    await Future.wait(subscriptions.whereType<StreamSubscription>().map((sub) => sub.cancel()));
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    return super.close();
  }
}
