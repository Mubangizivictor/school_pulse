import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:school_pulse/features/student_identity/data/models/student_cache_isar.dart';
import 'package:school_pulse/features/student/data/models/student_isar_models.dart';
import 'package:school_pulse/features/attendance_qr_integration/data/models/attendance_log_isar.dart';
import 'package:school_pulse/features/inventory/data/models/asset_isar.dart';
import 'package:school_pulse/features/inventory/data/models/inventory_item_isar.dart';
import 'package:school_pulse/features/inventory/data/models/stock_movement_isar.dart';
import 'package:school_pulse/features/inventory/data/models/supplier_isar.dart';
import 'package:school_pulse/features/inventory/data/models/purchase_order_isar.dart';
import 'package:school_pulse/features/inventory/data/models/repair_isar.dart';
import 'package:school_pulse/features/inventory/data/models/maintenance_isar.dart';
import 'package:school_pulse/features/inventory/data/models/procurement_request_isar.dart';
import 'package:school_pulse/features/branding/data/models/school_branding_isar.dart';
import 'package:school_pulse/features/biometrics/data/models/biometric_template_isar.dart';
import 'package:school_pulse/features/gate_ops/data/models/gate_ops_isar_models.dart';
import 'package:school_pulse/features/structure/data/models/structure_isar_models.dart';
import 'package:school_pulse/features/exams/data/models/isar_assessment_mark.dart';
import 'package:school_pulse/features/library/data/models/library_isar_models.dart';
import 'package:school_pulse/features/catering/data/models/meal_record_isar.dart';
import 'package:school_pulse/features/verification/data/models/verification_isar_models.dart';
import 'package:school_pulse/features/notifications/data/models/notification_isar.dart';
import 'package:school_pulse/features/notifications/data/models/notification_token_isar.dart';
import 'package:school_pulse/features/teacher/data/models/class_teacher_isar_models.dart';
import 'package:school_pulse/features/teacher/data/models/subject_teacher_isar_models.dart';

/// Isar's web engine persists to IndexedDB and ignores the directory path;
/// `getApplicationDocumentsDirectory()` has no web implementation and
/// throws - but this whole file is only ever reached on mobile/desktop (see
/// isar_bootstrap.dart's conditional import), so that's moot here.
Future<Isar> open() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open([
    StudentCacheIsarSchema,
    StudentProfileIsarSchema,
    AttendanceLogIsarSchema,
    AssetIsarSchema,
    InventoryItemIsarSchema,
    StockMovementIsarSchema,
    SupplierIsarSchema,
    PurchaseOrderIsarSchema,
    RepairIsarSchema,
    MaintenanceIsarSchema,
    ProcurementRequestIsarSchema,
    SchoolBrandingIsarSchema,
    BiometricTemplateIsarSchema,
    GateIsarSchema,
    MovementEventIsarSchema,
    VisitorIsarSchema,
    SecurityIncidentIsarSchema,
    EmergencyEventIsarSchema,
    EducationalLevelIsarSchema,
    AcademicYearIsarSchema,
    AcademicTermIsarSchema,
    SchoolClassIsarSchema,
    ClassStreamIsarSchema,
    SubjectIsarSchema,
    DepartmentIsarSchema,
    StaffDesignationIsarSchema,
    IsarAssessmentMarkSchema,
    LibraryResourceIsarSchema,
    LibraryBorrowingIsarSchema,
    LibraryReservationIsarSchema,
    MealRecordIsarSchema,
    CachedCredentialIsarSchema,
    RevokedCredentialIsarSchema,
    VerificationEventIsarSchema,
    AuthorizedDeviceIsarSchema,
    OperatorPermissionSnapshotIsarSchema,
    NotificationIsarSchema,
    NotificationTokenIsarSchema,
    StaffRoleAssignmentIsarSchema,
    SubjectEnrollmentIsarSchema,
    SubjectTeacherOfflineOperationIsarSchema,
    LessonIsarSchema,
    LessonAttendanceIsarSchema,
    ClassStudentIsarSchema,
    ClassDashboardCacheIsarSchema,
    ClassAttendanceDraftIsarSchema,
    AttendanceTypeDefIsarSchema,
    CampusIsarSchema,
    HouseIsarSchema,
    ClubIsarSchema,
    FacilityIsarSchema,
    HostelIsarSchema,
    HostelRoomIsarSchema,
    TransportRouteIsarSchema,
    TransportStopIsarSchema,
    TransportVehicleIsarSchema,
    StructureFeeCategoryIsarSchema,
    AssessmentTypeDefIsarSchema,
    GradingSystemDefIsarSchema,
    GradeBandIsarSchema,
    AttendanceSessionDefIsarSchema,
    AnnouncementCategoryDefIsarSchema,
    NotificationCategoryDefIsarSchema,
    MessageTemplateDefIsarSchema,
    DocumentTemplateDefIsarSchema,
    CustomFieldDefIsarSchema,
  ], directory: dir.path);
}
