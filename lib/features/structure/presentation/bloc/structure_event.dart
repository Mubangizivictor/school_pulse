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

abstract class StructureEvent extends Equatable {
  const StructureEvent();

  @override
  List<Object?> get props => [];
}

class LoadStructureData extends StructureEvent {
  final String schoolId;
  const LoadStructureData(this.schoolId);
  @override
  List<Object?> get props => [schoolId];
}

/// Drops tenant-scoped Structure state when authentication ends, preventing a
/// subsequent account on a shared device from seeing the previous school's
/// cached configuration while its own streams are starting.
class ClearStructureData extends StructureEvent {
  const ClearStructureData();
}

// Internal events fed by the bloc's own stream subscriptions.
class LevelsUpdated extends StructureEvent {
  final List<EducationalLevel> levels;
  const LevelsUpdated(this.levels);
  @override
  List<Object?> get props => [levels];
}

class AcademicYearsUpdated extends StructureEvent {
  final List<AcademicYear> years;
  const AcademicYearsUpdated(this.years);
  @override
  List<Object?> get props => [years];
}

class AcademicTermsUpdated extends StructureEvent {
  final List<AcademicTerm> terms;
  const AcademicTermsUpdated(this.terms);
  @override
  List<Object?> get props => [terms];
}

class ClassesUpdated extends StructureEvent {
  final List<SchoolClass> classes;
  const ClassesUpdated(this.classes);
  @override
  List<Object?> get props => [classes];
}

class StreamsUpdated extends StructureEvent {
  final List<ClassStream> streams;
  const StreamsUpdated(this.streams);
  @override
  List<Object?> get props => [streams];
}

class SubjectsUpdated extends StructureEvent {
  final List<Subject> subjects;
  const SubjectsUpdated(this.subjects);
  @override
  List<Object?> get props => [subjects];
}

class DepartmentsUpdated extends StructureEvent {
  final List<Department> departments;
  const DepartmentsUpdated(this.departments);
  @override
  List<Object?> get props => [departments];
}

class DesignationsUpdated extends StructureEvent {
  final List<StaffDesignation> designations;
  const DesignationsUpdated(this.designations);
  @override
  List<Object?> get props => [designations];
}

class FeatureTogglesUpdated extends StructureEvent {
  final FeatureToggles toggles;
  const FeatureTogglesUpdated(this.toggles);
  @override
  List<Object?> get props => [toggles];
}

class InstitutionProfileUpdated extends StructureEvent {
  final InstitutionProfile profile;
  const InstitutionProfileUpdated(this.profile);
  @override
  List<Object?> get props => [profile];
}

class CampusesUpdated extends StructureEvent {
  final List<Campus> campuses;
  const CampusesUpdated(this.campuses);
  @override
  List<Object?> get props => [campuses];
}

class HousesUpdated extends StructureEvent {
  final List<House> houses;
  const HousesUpdated(this.houses);
  @override
  List<Object?> get props => [houses];
}

class ClubsUpdated extends StructureEvent {
  final List<Club> clubs;
  const ClubsUpdated(this.clubs);
  @override
  List<Object?> get props => [clubs];
}

class FacilitiesUpdated extends StructureEvent {
  final List<Facility> facilities;
  const FacilitiesUpdated(this.facilities);
  @override
  List<Object?> get props => [facilities];
}

class HostelsUpdated extends StructureEvent {
  final List<Hostel> hostels;
  const HostelsUpdated(this.hostels);
  @override
  List<Object?> get props => [hostels];
}

class HostelRoomsUpdated extends StructureEvent {
  final List<HostelRoom> rooms;
  const HostelRoomsUpdated(this.rooms);
  @override
  List<Object?> get props => [rooms];
}

class TransportRoutesUpdated extends StructureEvent {
  final List<TransportRoute> routes;
  const TransportRoutesUpdated(this.routes);
  @override
  List<Object?> get props => [routes];
}

class TransportStopsUpdated extends StructureEvent {
  final List<TransportStop> stops;
  const TransportStopsUpdated(this.stops);
  @override
  List<Object?> get props => [stops];
}

class TransportVehiclesUpdated extends StructureEvent {
  final List<TransportVehicle> vehicles;
  const TransportVehiclesUpdated(this.vehicles);
  @override
  List<Object?> get props => [vehicles];
}

class FeeCategoriesUpdated extends StructureEvent {
  final List<FeeCategory> categories;
  const FeeCategoriesUpdated(this.categories);
  @override
  List<Object?> get props => [categories];
}

class AssessmentTypesUpdated extends StructureEvent {
  final List<AssessmentTypeDef> types;
  const AssessmentTypesUpdated(this.types);
  @override
  List<Object?> get props => [types];
}

class GradingSystemsUpdated extends StructureEvent {
  final List<GradingSystemDef> systems;
  const GradingSystemsUpdated(this.systems);
  @override
  List<Object?> get props => [systems];
}

class GradeBandsUpdated extends StructureEvent {
  final List<GradeBand> bands;
  const GradeBandsUpdated(this.bands);
  @override
  List<Object?> get props => [bands];
}

class TimetableConfigUpdated extends StructureEvent {
  final TimetableConfig config;
  const TimetableConfigUpdated(this.config);
  @override
  List<Object?> get props => [config];
}

class AttendanceDefaultsConfigUpdated extends StructureEvent {
  final AttendanceDefaultsConfig config;
  const AttendanceDefaultsConfigUpdated(this.config);
  @override
  List<Object?> get props => [config];
}

class CommunicationDefaultsConfigUpdated extends StructureEvent {
  final CommunicationDefaultsConfig config;
  const CommunicationDefaultsConfigUpdated(this.config);
  @override
  List<Object?> get props => [config];
}

class AttendanceTypesUpdated extends StructureEvent {
  final List<AttendanceTypeDef> types;
  const AttendanceTypesUpdated(this.types);
  @override
  List<Object?> get props => [types];
}

class AttendanceSessionsUpdated extends StructureEvent {
  final List<AttendanceSessionDef> sessions;
  const AttendanceSessionsUpdated(this.sessions);
  @override
  List<Object?> get props => [sessions];
}

class AnnouncementCategoriesUpdated extends StructureEvent {
  final List<AnnouncementCategoryDef> categories;
  const AnnouncementCategoriesUpdated(this.categories);
  @override
  List<Object?> get props => [categories];
}

class NotificationCategoriesUpdated extends StructureEvent {
  final List<NotificationCategoryDef> categories;
  const NotificationCategoriesUpdated(this.categories);
  @override
  List<Object?> get props => [categories];
}

class MessageTemplatesUpdated extends StructureEvent {
  final List<MessageTemplateDef> templates;
  const MessageTemplatesUpdated(this.templates);
  @override
  List<Object?> get props => [templates];
}

class DocumentTemplatesUpdated extends StructureEvent {
  final List<DocumentTemplateDef> templates;
  const DocumentTemplatesUpdated(this.templates);
  @override
  List<Object?> get props => [templates];
}

class CustomFieldsUpdated extends StructureEvent {
  final List<CustomFieldDef> fields;
  const CustomFieldsUpdated(this.fields);
  @override
  List<Object?> get props => [fields];
}

class StructureLoadFailed extends StructureEvent {
  final String message;
  const StructureLoadFailed(this.message);
  @override
  List<Object?> get props => [message];
}

// User-triggered CRUD events.
class SaveLevelRequested extends StructureEvent {
  final EducationalLevel level;
  const SaveLevelRequested(this.level);
  @override
  List<Object?> get props => [level];
}

class DeleteLevelRequested extends StructureEvent {
  final String levelId;
  const DeleteLevelRequested(this.levelId);
  @override
  List<Object?> get props => [levelId];
}

class ArchiveLevelRequested extends StructureEvent {
  final String levelId;
  const ArchiveLevelRequested(this.levelId);
  @override
  List<Object?> get props => [levelId];
}

class SaveAcademicYearRequested extends StructureEvent {
  final AcademicYear year;
  const SaveAcademicYearRequested(this.year);
  @override
  List<Object?> get props => [year];
}

class DeleteAcademicYearRequested extends StructureEvent {
  final String yearId;
  const DeleteAcademicYearRequested(this.yearId);
  @override
  List<Object?> get props => [yearId];
}

class ArchiveAcademicYearRequested extends StructureEvent {
  final String yearId;
  const ArchiveAcademicYearRequested(this.yearId);
  @override
  List<Object?> get props => [yearId];
}

class SetCurrentAcademicYearRequested extends StructureEvent {
  final String yearId;
  final String schoolId;
  const SetCurrentAcademicYearRequested(this.yearId, this.schoolId);
  @override
  List<Object?> get props => [yearId, schoolId];
}

class SaveAcademicTermRequested extends StructureEvent {
  final AcademicTerm term;
  const SaveAcademicTermRequested(this.term);
  @override
  List<Object?> get props => [term];
}

class DeleteAcademicTermRequested extends StructureEvent {
  final String termId;
  const DeleteAcademicTermRequested(this.termId);
  @override
  List<Object?> get props => [termId];
}

class SetCurrentAcademicTermRequested extends StructureEvent {
  final String termId;
  final String schoolId;
  const SetCurrentAcademicTermRequested(this.termId, this.schoolId);
  @override
  List<Object?> get props => [termId, schoolId];
}

class SaveClassRequested extends StructureEvent {
  final SchoolClass schoolClass;
  const SaveClassRequested(this.schoolClass);
  @override
  List<Object?> get props => [schoolClass];
}

class DeleteClassRequested extends StructureEvent {
  final String classId;
  const DeleteClassRequested(this.classId);
  @override
  List<Object?> get props => [classId];
}

class ArchiveClassRequested extends StructureEvent {
  final String classId;
  const ArchiveClassRequested(this.classId);
  @override
  List<Object?> get props => [classId];
}

class SaveStreamRequested extends StructureEvent {
  final ClassStream stream;
  const SaveStreamRequested(this.stream);
  @override
  List<Object?> get props => [stream];
}

class DeleteStreamRequested extends StructureEvent {
  final String streamId;
  const DeleteStreamRequested(this.streamId);
  @override
  List<Object?> get props => [streamId];
}

class ArchiveStreamRequested extends StructureEvent {
  final String streamId;
  const ArchiveStreamRequested(this.streamId);
  @override
  List<Object?> get props => [streamId];
}

class SaveSubjectRequested extends StructureEvent {
  final Subject subject;
  const SaveSubjectRequested(this.subject);
  @override
  List<Object?> get props => [subject];
}

class DeleteSubjectRequested extends StructureEvent {
  final String subjectId;
  const DeleteSubjectRequested(this.subjectId);
  @override
  List<Object?> get props => [subjectId];
}

class ArchiveSubjectRequested extends StructureEvent {
  final String subjectId;
  const ArchiveSubjectRequested(this.subjectId);
  @override
  List<Object?> get props => [subjectId];
}

class SaveDepartmentRequested extends StructureEvent {
  final Department department;
  const SaveDepartmentRequested(this.department);
  @override
  List<Object?> get props => [department];
}

class DeleteDepartmentRequested extends StructureEvent {
  final String departmentId;
  const DeleteDepartmentRequested(this.departmentId);
  @override
  List<Object?> get props => [departmentId];
}

class ArchiveDepartmentRequested extends StructureEvent {
  final String departmentId;
  const ArchiveDepartmentRequested(this.departmentId);
  @override
  List<Object?> get props => [departmentId];
}

class SaveDesignationRequested extends StructureEvent {
  final StaffDesignation designation;
  const SaveDesignationRequested(this.designation);
  @override
  List<Object?> get props => [designation];
}

class DeleteDesignationRequested extends StructureEvent {
  final String designationId;
  const DeleteDesignationRequested(this.designationId);
  @override
  List<Object?> get props => [designationId];
}

class ArchiveDesignationRequested extends StructureEvent {
  final String designationId;
  const ArchiveDesignationRequested(this.designationId);
  @override
  List<Object?> get props => [designationId];
}

class RestoreDesignationRequested extends StructureEvent {
  final String designationId;
  const RestoreDesignationRequested(this.designationId);
  @override
  List<Object?> get props => [designationId];
}

class UpdateFeatureTogglesRequested extends StructureEvent {
  final FeatureToggles toggles;
  final String schoolId;
  const UpdateFeatureTogglesRequested(this.toggles, this.schoolId);
  @override
  List<Object?> get props => [toggles, schoolId];
}

class UpdateInstitutionProfileRequested extends StructureEvent {
  final InstitutionProfile profile;
  final String schoolId;
  const UpdateInstitutionProfileRequested(this.profile, this.schoolId);
  @override
  List<Object?> get props => [profile, schoolId];
}

class SaveCampusRequested extends StructureEvent {
  final Campus campus;
  const SaveCampusRequested(this.campus);
  @override
  List<Object?> get props => [campus];
}

class DeleteCampusRequested extends StructureEvent {
  final String campusId;
  const DeleteCampusRequested(this.campusId);
  @override
  List<Object?> get props => [campusId];
}

class ArchiveCampusRequested extends StructureEvent {
  final String campusId;
  const ArchiveCampusRequested(this.campusId);
  @override
  List<Object?> get props => [campusId];
}

class SaveHouseRequested extends StructureEvent {
  final House house;
  const SaveHouseRequested(this.house);
  @override
  List<Object?> get props => [house];
}

class DeleteHouseRequested extends StructureEvent {
  final String houseId;
  const DeleteHouseRequested(this.houseId);
  @override
  List<Object?> get props => [houseId];
}

class SaveClubRequested extends StructureEvent {
  final Club club;
  const SaveClubRequested(this.club);
  @override
  List<Object?> get props => [club];
}

class DeleteClubRequested extends StructureEvent {
  final String clubId;
  const DeleteClubRequested(this.clubId);
  @override
  List<Object?> get props => [clubId];
}

class SaveFacilityRequested extends StructureEvent {
  final Facility facility;
  const SaveFacilityRequested(this.facility);
  @override
  List<Object?> get props => [facility];
}

class DeleteFacilityRequested extends StructureEvent {
  final String facilityId;
  const DeleteFacilityRequested(this.facilityId);
  @override
  List<Object?> get props => [facilityId];
}

class SaveHostelRequested extends StructureEvent {
  final Hostel hostel;
  const SaveHostelRequested(this.hostel);
  @override
  List<Object?> get props => [hostel];
}

class DeleteHostelRequested extends StructureEvent {
  final String hostelId;
  const DeleteHostelRequested(this.hostelId);
  @override
  List<Object?> get props => [hostelId];
}

class SaveHostelRoomRequested extends StructureEvent {
  final HostelRoom room;
  const SaveHostelRoomRequested(this.room);
  @override
  List<Object?> get props => [room];
}

class DeleteHostelRoomRequested extends StructureEvent {
  final String roomId;
  const DeleteHostelRoomRequested(this.roomId);
  @override
  List<Object?> get props => [roomId];
}

class SaveTransportRouteRequested extends StructureEvent {
  final TransportRoute route;
  const SaveTransportRouteRequested(this.route);
  @override
  List<Object?> get props => [route];
}

class DeleteTransportRouteRequested extends StructureEvent {
  final String routeId;
  const DeleteTransportRouteRequested(this.routeId);
  @override
  List<Object?> get props => [routeId];
}

class SaveTransportStopRequested extends StructureEvent {
  final TransportStop stop;
  const SaveTransportStopRequested(this.stop);
  @override
  List<Object?> get props => [stop];
}

class DeleteTransportStopRequested extends StructureEvent {
  final String stopId;
  const DeleteTransportStopRequested(this.stopId);
  @override
  List<Object?> get props => [stopId];
}

class SaveTransportVehicleRequested extends StructureEvent {
  final TransportVehicle vehicle;
  const SaveTransportVehicleRequested(this.vehicle);
  @override
  List<Object?> get props => [vehicle];
}

class DeleteTransportVehicleRequested extends StructureEvent {
  final String vehicleId;
  const DeleteTransportVehicleRequested(this.vehicleId);
  @override
  List<Object?> get props => [vehicleId];
}

class SaveFeeCategoryRequested extends StructureEvent {
  final FeeCategory category;
  const SaveFeeCategoryRequested(this.category);
  @override
  List<Object?> get props => [category];
}

class DeleteFeeCategoryRequested extends StructureEvent {
  final String categoryId;
  const DeleteFeeCategoryRequested(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class SaveAssessmentTypeRequested extends StructureEvent {
  final AssessmentTypeDef type;
  const SaveAssessmentTypeRequested(this.type);
  @override
  List<Object?> get props => [type];
}

class DeleteAssessmentTypeRequested extends StructureEvent {
  final String typeId;
  const DeleteAssessmentTypeRequested(this.typeId);
  @override
  List<Object?> get props => [typeId];
}

class SaveGradingSystemRequested extends StructureEvent {
  final GradingSystemDef system;
  const SaveGradingSystemRequested(this.system);
  @override
  List<Object?> get props => [system];
}

class DeleteGradingSystemRequested extends StructureEvent {
  final String systemId;
  const DeleteGradingSystemRequested(this.systemId);
  @override
  List<Object?> get props => [systemId];
}

class SaveGradeBandRequested extends StructureEvent {
  final GradeBand band;
  const SaveGradeBandRequested(this.band);
  @override
  List<Object?> get props => [band];
}

class DeleteGradeBandRequested extends StructureEvent {
  final String bandId;
  const DeleteGradeBandRequested(this.bandId);
  @override
  List<Object?> get props => [bandId];
}

class UpdateTimetableConfigRequested extends StructureEvent {
  final TimetableConfig config;
  final String schoolId;
  const UpdateTimetableConfigRequested(this.config, this.schoolId);
  @override
  List<Object?> get props => [config, schoolId];
}

class UpdateAttendanceDefaultsConfigRequested extends StructureEvent {
  final AttendanceDefaultsConfig config;
  final String schoolId;
  const UpdateAttendanceDefaultsConfigRequested(this.config, this.schoolId);
  @override
  List<Object?> get props => [config, schoolId];
}

class UpdateCommunicationDefaultsConfigRequested extends StructureEvent {
  final CommunicationDefaultsConfig config;
  final String schoolId;
  const UpdateCommunicationDefaultsConfigRequested(this.config, this.schoolId);
  @override
  List<Object?> get props => [config, schoolId];
}

class SaveAttendanceTypeRequested extends StructureEvent {
  final AttendanceTypeDef type;
  const SaveAttendanceTypeRequested(this.type);
  @override
  List<Object?> get props => [type];
}

class DeleteAttendanceTypeRequested extends StructureEvent {
  final String typeId;
  const DeleteAttendanceTypeRequested(this.typeId);
  @override
  List<Object?> get props => [typeId];
}

class SaveAttendanceSessionRequested extends StructureEvent {
  final AttendanceSessionDef session;
  const SaveAttendanceSessionRequested(this.session);
  @override
  List<Object?> get props => [session];
}

class DeleteAttendanceSessionRequested extends StructureEvent {
  final String sessionId;
  const DeleteAttendanceSessionRequested(this.sessionId);
  @override
  List<Object?> get props => [sessionId];
}

class SaveAnnouncementCategoryRequested extends StructureEvent {
  final AnnouncementCategoryDef category;
  const SaveAnnouncementCategoryRequested(this.category);
  @override
  List<Object?> get props => [category];
}

class DeleteAnnouncementCategoryRequested extends StructureEvent {
  final String categoryId;
  const DeleteAnnouncementCategoryRequested(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class SaveNotificationCategoryRequested extends StructureEvent {
  final NotificationCategoryDef category;
  const SaveNotificationCategoryRequested(this.category);
  @override
  List<Object?> get props => [category];
}

class DeleteNotificationCategoryRequested extends StructureEvent {
  final String categoryId;
  const DeleteNotificationCategoryRequested(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class SaveMessageTemplateRequested extends StructureEvent {
  final MessageTemplateDef template;
  const SaveMessageTemplateRequested(this.template);
  @override
  List<Object?> get props => [template];
}

class DeleteMessageTemplateRequested extends StructureEvent {
  final String templateId;
  const DeleteMessageTemplateRequested(this.templateId);
  @override
  List<Object?> get props => [templateId];
}

class SaveDocumentTemplateRequested extends StructureEvent {
  final DocumentTemplateDef template;
  const SaveDocumentTemplateRequested(this.template);
  @override
  List<Object?> get props => [template];
}

class DeleteDocumentTemplateRequested extends StructureEvent {
  final String templateId;
  const DeleteDocumentTemplateRequested(this.templateId);
  @override
  List<Object?> get props => [templateId];
}

class SaveCustomFieldRequested extends StructureEvent {
  final CustomFieldDef field;
  const SaveCustomFieldRequested(this.field);
  @override
  List<Object?> get props => [field];
}

class DeleteCustomFieldRequested extends StructureEvent {
  final String fieldId;
  const DeleteCustomFieldRequested(this.fieldId);
  @override
  List<Object?> get props => [fieldId];
}
