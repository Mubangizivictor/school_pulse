import 'package:equatable/equatable.dart';
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

class StructureState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<EducationalLevel> levels;
  final List<AcademicYear> academicYears;
  final List<AcademicTerm> academicTerms;
  final List<SchoolClass> classes;
  final List<ClassStream> streams;
  final List<Subject> subjects;
  final List<Department> departments;
  final List<StaffDesignation> designations;
  final List<StaffRole> staffRoles;
  final FeatureToggles featureToggles;
  final InstitutionProfile institutionProfile;
  final List<Campus> campuses;
  final List<House> houses;
  final List<Club> clubs;
  final List<Facility> facilities;
  final List<Hostel> hostels;
  final List<HostelRoom> hostelRooms;
  final List<TransportRoute> transportRoutes;
  final List<TransportStop> transportStops;
  final List<TransportVehicle> transportVehicles;
  final List<FeeCategory> feeCategories;
  final List<AssessmentTypeDef> assessmentTypes;
  final List<GradingSystemDef> gradingSystems;
  final List<GradeBand> gradeBands;
  final TimetableConfig timetableConfig;
  final AttendanceDefaultsConfig attendanceDefaultsConfig;
  final CommunicationDefaultsConfig communicationDefaultsConfig;
  final List<AttendanceTypeDef> attendanceTypes;
  final List<AttendanceSessionDef> attendanceSessions;
  final List<AnnouncementCategoryDef> announcementCategories;
  final List<NotificationCategoryDef> notificationCategories;
  final List<MessageTemplateDef> messageTemplates;
  final List<DocumentTemplateDef> documentTemplates;
  final List<CustomFieldDef> customFields;

  const StructureState({
    this.isLoading = true,
    this.errorMessage,
    this.levels = const [],
    this.academicYears = const [],
    this.academicTerms = const [],
    this.classes = const [],
    this.streams = const [],
    this.subjects = const [],
    this.departments = const [],
    this.designations = const [],
    this.staffRoles = const [],
    this.featureToggles = const FeatureToggles(),
    this.institutionProfile = const InstitutionProfile(),
    this.campuses = const [],
    this.houses = const [],
    this.clubs = const [],
    this.facilities = const [],
    this.hostels = const [],
    this.hostelRooms = const [],
    this.transportRoutes = const [],
    this.transportStops = const [],
    this.transportVehicles = const [],
    this.feeCategories = const [],
    this.assessmentTypes = const [],
    this.gradingSystems = const [],
    this.gradeBands = const [],
    this.timetableConfig = const TimetableConfig(),
    this.attendanceDefaultsConfig = const AttendanceDefaultsConfig(),
    this.communicationDefaultsConfig = const CommunicationDefaultsConfig(),
    this.attendanceTypes = const [],
    this.attendanceSessions = const [],
    this.announcementCategories = const [],
    this.notificationCategories = const [],
    this.messageTemplates = const [],
    this.documentTemplates = const [],
    this.customFields = const [],
  });

  StructureState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<EducationalLevel>? levels,
    List<AcademicYear>? academicYears,
    List<AcademicTerm>? academicTerms,
    List<SchoolClass>? classes,
    List<ClassStream>? streams,
    List<Subject>? subjects,
    List<Department>? departments,
    List<StaffDesignation>? designations,
    List<StaffRole>? staffRoles,
    FeatureToggles? featureToggles,
    InstitutionProfile? institutionProfile,
    List<Campus>? campuses,
    List<House>? houses,
    List<Club>? clubs,
    List<Facility>? facilities,
    List<Hostel>? hostels,
    List<HostelRoom>? hostelRooms,
    List<TransportRoute>? transportRoutes,
    List<TransportStop>? transportStops,
    List<TransportVehicle>? transportVehicles,
    List<FeeCategory>? feeCategories,
    List<AssessmentTypeDef>? assessmentTypes,
    List<GradingSystemDef>? gradingSystems,
    List<GradeBand>? gradeBands,
    TimetableConfig? timetableConfig,
    AttendanceDefaultsConfig? attendanceDefaultsConfig,
    CommunicationDefaultsConfig? communicationDefaultsConfig,
    List<AttendanceTypeDef>? attendanceTypes,
    List<AttendanceSessionDef>? attendanceSessions,
    List<AnnouncementCategoryDef>? announcementCategories,
    List<NotificationCategoryDef>? notificationCategories,
    List<MessageTemplateDef>? messageTemplates,
    List<DocumentTemplateDef>? documentTemplates,
    List<CustomFieldDef>? customFields,
  }) {
    return StructureState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      levels: levels ?? this.levels,
      academicYears: academicYears ?? this.academicYears,
      academicTerms: academicTerms ?? this.academicTerms,
      classes: classes ?? this.classes,
      streams: streams ?? this.streams,
      subjects: subjects ?? this.subjects,
      departments: departments ?? this.departments,
      designations: designations ?? this.designations,
      staffRoles: staffRoles ?? this.staffRoles,
      featureToggles: featureToggles ?? this.featureToggles,
      institutionProfile: institutionProfile ?? this.institutionProfile,
      campuses: campuses ?? this.campuses,
      houses: houses ?? this.houses,
      clubs: clubs ?? this.clubs,
      facilities: facilities ?? this.facilities,
      hostels: hostels ?? this.hostels,
      hostelRooms: hostelRooms ?? this.hostelRooms,
      transportRoutes: transportRoutes ?? this.transportRoutes,
      transportStops: transportStops ?? this.transportStops,
      transportVehicles: transportVehicles ?? this.transportVehicles,
      feeCategories: feeCategories ?? this.feeCategories,
      assessmentTypes: assessmentTypes ?? this.assessmentTypes,
      gradingSystems: gradingSystems ?? this.gradingSystems,
      gradeBands: gradeBands ?? this.gradeBands,
      timetableConfig: timetableConfig ?? this.timetableConfig,
      attendanceDefaultsConfig:
          attendanceDefaultsConfig ?? this.attendanceDefaultsConfig,
      communicationDefaultsConfig:
          communicationDefaultsConfig ?? this.communicationDefaultsConfig,
      attendanceTypes: attendanceTypes ?? this.attendanceTypes,
      attendanceSessions: attendanceSessions ?? this.attendanceSessions,
      announcementCategories:
          announcementCategories ?? this.announcementCategories,
      notificationCategories:
          notificationCategories ?? this.notificationCategories,
      messageTemplates: messageTemplates ?? this.messageTemplates,
      documentTemplates: documentTemplates ?? this.documentTemplates,
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    levels,
    academicYears,
    academicTerms,
    classes,
    streams,
    subjects,
    departments,
    designations,
    staffRoles,
    featureToggles,
    institutionProfile,
    campuses,
    houses,
    clubs,
    facilities,
    hostels,
    hostelRooms,
    transportRoutes,
    transportStops,
    transportVehicles,
    feeCategories,
    assessmentTypes,
    gradingSystems,
    gradeBands,
    timetableConfig,
    attendanceDefaultsConfig,
    communicationDefaultsConfig,
    attendanceTypes,
    attendanceSessions,
    announcementCategories,
    notificationCategories,
    messageTemplates,
    documentTemplates,
    customFields,
  ];
}
