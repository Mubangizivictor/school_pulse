import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/user_roles.dart';

/// Default role -> permission-set seed used when no cached
/// `OperatorPermissionSnapshotIsar` exists yet (first run on a fresh
/// device) or as the source of truth when a snapshot is refreshed.
///
/// Phase 1 only seeds the security/gate permissions, deliberately
/// mirroring the permitted-role set already used for the `/staff/security`
/// route guard in `lib/app/router.dart` - no role that has dashboard
/// access today loses it under the new permission layer.
class RolePermissionDefaults {
  const RolePermissionDefaults._();

  static const Set<String> _gatekeeperPermissions = {
    Permission.securityIdentityVerify,
    Permission.securityEntryRecord,
    Permission.securityExitRecord,
  };

  static const Set<String> _appointmentOfficePermissions = {
    Permission.appointmentsView,
    Permission.appointmentsManage,
    Permission.appointmentsApprove,
  };

  static const Set<String> _securityLeadPermissions = {
    ..._gatekeeperPermissions,
    Permission.securityOverride,
    Permission.verificationOverride,
    Permission.verificationAuditRead,
    Permission.verificationDeviceManage,
    Permission.identityCredentialManage,
  };

  static const Set<String> _securityCenterAdminPermissions = {
    Permission.securityView,
    Permission.securityViewSessions,
    Permission.securityRevokeSession,
    Permission.securityRevokeAllSessions,
    Permission.securityViewDevices,
    Permission.securityManageDeviceTrust,
    Permission.securityViewFailedLogins,
    Permission.securityLockAccount,
    Permission.securityUnlockAccount,
    Permission.securityForcePasswordReset,
    Permission.securityViewEvents,
    Permission.securityResolveAlerts,
    Permission.securityExport,
    Permission.securityManagePolicy,
  };

  static const Set<String> _centralReportsAdminPermissions = {
    Permission.reportsView,
    Permission.reportsExport,
    Permission.reportsPrint,
    Permission.reportsSchedule,
    Permission.reportsShare,
    Permission.reportsViewSensitive,
  };

  static const Set<String> _dataManagementAdminPermissions = {
    Permission.dataImport,
    Permission.dataImportStudents,
    Permission.dataImportStaff,
    Permission.dataImportParents,
    Permission.dataImportStructure,
    Permission.dataBulkUpdate,
    Permission.dataArchive,
    Permission.dataRestoreArchive,
    Permission.dataViewQuality,
    Permission.dataRunQuality,
    Permission.dataRunMigration,
    Permission.dataExport,
    Permission.dataExportSensitive,
    Permission.dataRequestRestore,
    Permission.dataViewBackupStatus,
  };

  static const Set<String> _subscriptionAdminPermissions = {
    Permission.subscriptionView,
    Permission.subscriptionViewUsage,
    Permission.subscriptionViewInvoices,
    Permission.subscriptionDownloadInvoice,
    Permission.subscriptionDownloadReceipt,
    Permission.subscriptionRequestUpgrade,
    Permission.subscriptionRequestAddon,
    Permission.subscriptionInitiateRenewal,
    Permission.subscriptionViewHistory,
  };

  static const Set<String> _institutionHealthAdminPermissions = {
    Permission.institutionHealthView,
    Permission.institutionHealthViewSecurity,
    Permission.institutionHealthViewDataQuality,
    Permission.institutionHealthViewSubscription,
    Permission.institutionHealthAcknowledge,
    Permission.institutionHealthIgnore,
    Permission.institutionHealthRecheck,
    Permission.institutionHealthExport,
  };

  static const Set<String> _moduleControlAdminPermissions = {
    Permission.modulesView,
    Permission.modulesEnable,
    Permission.modulesDisable,
    Permission.modulesConfigure,
    Permission.policiesView,
    Permission.policiesCreate,
    Permission.policiesEdit,
    Permission.policiesActivate,
    Permission.policiesArchive,
    Permission.policiesRollback,
    Permission.policiesSchedule,
  };

  static const Set<String> _supportAuditAdminPermissions = {
    Permission.supportView,
    Permission.supportCreate,
    Permission.supportReply,
    Permission.supportClose,
    Permission.supportReopen,
    Permission.supportEscalate,
    Permission.supportApproveAccess,
    Permission.supportRevokeAccess,
    Permission.auditView,
    Permission.auditViewSecurity,
    Permission.auditViewSensitive,
    Permission.auditSearch,
    Permission.auditExport,
    Permission.auditViewSupportAccess,
  };

  // Enrollment Permission (spec term) - never granted by job title alone,
  // only through this role-default seed (or a future custom-role grant).
  // Mirrors the doc's "Enrollment may only be performed by users with
  // Enrollment Permission" requirement: School Admin, Headteacher, Deputy
  // Head, Dean, Director, Receptionist, HR - the subset of that list that
  // exists as a UserRole today (no dedicated Registrar/Admissions Officer
  // role exists in this codebase yet).
  static const Set<String> _admissionsPermissions = {
    Permission.admissionApplicationCreate,
    Permission.admissionApplicationReview,
    Permission.admissionEnroll,
  };

  // Information-projection permissions for the roles whose whole job is
  // "look up one student's slice of data" - Nurse/Bursar/Librarian/
  // Transport Coordinator/Catering Manager. Each set is deliberately
  // narrow to its own domain; none of these roles gain any other role's
  // permissions by being added here.
  static const Set<String> _nursePermissions = {
    Permission.healthStudentVerify,
    Permission.healthStudentBasicRead,
    Permission.healthStudentClinicalRead,
    Permission.healthStudentVisitCreate,
    Permission.healthStudentEmergencyRead,
  };

  static const Set<String> _bursarPermissions = {
    Permission.financeStudentVerify,
    Permission.financeStudentBalanceRead,
  };

  static const Set<String> _librarianPermissions = {
    Permission.libraryMemberVerify,
    Permission.libraryBorrow,
    Permission.libraryReturn,
  };

  static const Set<String> _transportCoordinatorPermissions = {
    Permission.transportBoardingVerify,
    Permission.transportBoardingRecord,
    Permission.transportDropoffRecord,
  };

  static const Set<String> _cateringManagerPermissions = {
    Permission.mealsVerify,
    Permission.mealsServe,
  };

  // Notification send/manage permissions. `notification.view` and
  // `notification.acknowledge` are NOT listed here - every authenticated user
  // may read and acknowledge their own notifications, so gating them by role
  // would lock parents and students out of their own notification centre.
  // What follows is only the authority to *originate* and *administer*
  // notifications, which is genuinely role-scoped.

  /// Staff who may send targeted notifications within their own remit
  /// (a class teacher messaging their class's parents, for example).
  static const Set<String> _notificationSenderPermissions = {
    Permission.notificationSend,
    Permission.notificationSendToParent,
    Permission.notificationSendToStudent,
    Permission.notificationUseImages,
    Permission.notificationUseAttachments,
    Permission.notificationArchive,
  };

  /// Office roles that additionally broadcast school-wide, schedule ahead and
  /// read delivery reports for what they sent.
  static const Set<String> _notificationOfficePermissions = {
    ..._notificationSenderPermissions,
    Permission.notificationSendToStaff,
    Permission.notificationBroadcast,
    Permission.notificationSchedule,
    Permission.notificationCancel,
    Permission.notificationViewDeliveryReports,
  };

  /// School leadership: full notification administration including emergency
  /// alerts, templates and school-level notification settings.
  static const Set<String> _notificationAdminPermissions = {
    ..._notificationOfficePermissions,
    Permission.notificationSendEmergency,
    Permission.notificationManageTemplates,
    Permission.notificationManageSettings,
    Permission.notificationDelete,
    Permission.notificationRunDeliveryTest,
  };

  // Full attendance authority across every category - school leadership's
  // baseline so the unified Attendance feature is usable out of the box.
  // Any other role only gains a specific category's scan permission through
  // an explicit per-school role_permission_overrides grant.
  static const Set<String> _attendanceAdminPermissions = {
    Permission.attendanceClassScan,
    Permission.attendanceSubjectScan,
    Permission.attendanceStaffScan,
    Permission.attendanceBoardingScan,
    Permission.attendanceGateScan,
    Permission.attendanceMealsScan,
    Permission.attendanceLibraryScan,
    Permission.attendanceTransportScan,
    Permission.attendanceVisitorsScan,
    Permission.attendanceCustomScan,
    Permission.attendanceOverride,
  };

  /// Calendar administration is granular for future custom roles, while the
  /// existing broad calendar.manage grant remains compatible with deployed
  /// role overrides and Firestore rules.
  static const Set<String> _calendarAdminPermissions = {
    Permission.calendarManage,
    Permission.calendarView,
    Permission.calendarCreate,
    Permission.calendarEdit,
    Permission.calendarPublish,
    Permission.calendarCancel,
    Permission.calendarArchive,
    Permission.calendarManageHolidays,
    Permission.calendarManageExamWindows,
    Permission.calendarManageDeadlines,
    Permission.calendarExport,
    Permission.academicYearView,
    Permission.academicYearCreate,
    Permission.academicYearEdit,
    Permission.academicYearActivate,
    Permission.academicYearClose,
    Permission.academicYearReopen,
    Permission.academicPeriodView,
    Permission.academicPeriodCreate,
    Permission.academicPeriodEdit,
    Permission.academicPeriodActivate,
    Permission.academicPeriodClose,
    Permission.academicPeriodReopen,
  };

  static const Set<String> _integrationsAdminPermissions = {
    Permission.integrationsView,
    Permission.integrationsConfigure,
    Permission.integrationsConnect,
    Permission.integrationsDisconnect,
    Permission.integrationsTest,
    Permission.integrationsSync,
    Permission.integrationsViewLogs,
    Permission.integrationsManagePayments,
    Permission.integrationsManageCommunication,
    Permission.integrationsManageDevices,
    Permission.integrationsManageDomains,
    Permission.integrationsManageWebhooks,
    Permission.integrationsManagePrinters,
    Permission.integrationsViewSensitiveMetadata,
  };

  static const Set<String> _communicationsAdminPermissions = {
    Permission.communicationsView,
    Permission.communicationsCreate,
    Permission.communicationsEditDraft,
    Permission.communicationsSchedule,
    Permission.communicationsPublish,
    Permission.communicationsCancel,
    Permission.communicationsArchive,
    Permission.communicationsSendStaff,
    Permission.communicationsSendParents,
    Permission.communicationsSendStudents,
    Permission.communicationsSendEmergency,
    Permission.communicationsViewDelivery,
    Permission.communicationsViewAudit,
    Permission.communicationsManageTemplates,
  };

  // Narrower authority for roles that raise emergency alerts but do not run
  // the full Communication Center (drafts, templates, non-emergency sends).
  static const Set<String> _communicationsEmergencyOnlyPermissions = {
    Permission.communicationsView,
    Permission.communicationsCreate,
    Permission.communicationsSendEmergency,
    Permission.communicationsViewDelivery,
  };

  static const Set<String> _approvalAdminPermissions = {
    Permission.approvalsView,
    Permission.approvalsSubmit,
    Permission.approvalsApprove,
    Permission.approvalsReject,
    Permission.approvalsReturn,
    Permission.approvalsDelegate,
    Permission.approvalsEscalate,
    Permission.approvalsBulk,
    Permission.approvalsViewSensitive,
    Permission.approvalsManagePolicies,
    Permission.approvalsViewAudit,
  };

  static const Map<UserRole, Set<String>> defaults = {
    UserRole.gatekeeper: {
      ..._gatekeeperPermissions,
      Permission.attendanceGateScan,
    },
    UserRole.receptionist: {
      ..._gatekeeperPermissions,
      ..._admissionsPermissions,
      ..._notificationSenderPermissions,
      Permission.attendanceVisitorsScan,
      ..._appointmentOfficePermissions,
    },
    UserRole.securityHead: {
      ..._securityLeadPermissions,
      ..._notificationOfficePermissions,
      ..._communicationsEmergencyOnlyPermissions,
      // Security leads raise emergency alerts (lockdown, intruder, missing
      // student) without needing a head teacher to be reachable first.
      Permission.notificationSendEmergency,
    },
    UserRole.schoolAdmin: {
      ..._supportAuditAdminPermissions,
      ..._moduleControlAdminPermissions,
      ..._institutionHealthAdminPermissions,
      ..._subscriptionAdminPermissions,
      ..._dataManagementAdminPermissions,
      ..._centralReportsAdminPermissions,
      ..._securityLeadPermissions,
      ..._securityCenterAdminPermissions,
      ..._admissionsPermissions,
      ..._notificationAdminPermissions,
      ..._attendanceAdminPermissions,
      ..._calendarAdminPermissions,
      ..._approvalAdminPermissions,
      ..._integrationsAdminPermissions,
      ..._communicationsAdminPermissions,
      Permission.announcementManage,
      Permission.structureGradingView,
      Permission.structureGradingManage,
      ..._appointmentOfficePermissions,
    },
    UserRole.director: {
      ..._supportAuditAdminPermissions,
      ..._moduleControlAdminPermissions,
      ..._institutionHealthAdminPermissions,
      ..._subscriptionAdminPermissions,
      ..._dataManagementAdminPermissions,
      ..._centralReportsAdminPermissions,
      ..._securityLeadPermissions,
      ..._securityCenterAdminPermissions,
      ..._admissionsPermissions,
      ..._notificationAdminPermissions,
      ..._attendanceAdminPermissions,
      ..._approvalAdminPermissions,
      ..._integrationsAdminPermissions,
      ..._communicationsAdminPermissions,
      Permission.announcementManage,
      Permission.structureGradingView,
      Permission.structureGradingManage,
      ..._appointmentOfficePermissions,
    },
    UserRole.headTeacher: {
      ..._supportAuditAdminPermissions,
      ..._moduleControlAdminPermissions,
      ..._institutionHealthAdminPermissions,
      ..._subscriptionAdminPermissions,
      ..._dataManagementAdminPermissions,
      ..._centralReportsAdminPermissions,
      ..._securityCenterAdminPermissions,
      ..._securityLeadPermissions,
      ..._admissionsPermissions,
      ..._notificationAdminPermissions,
      ..._attendanceAdminPermissions,
      ..._approvalAdminPermissions,
      ..._integrationsAdminPermissions,
      ..._communicationsAdminPermissions,
      Permission.announcementManage,
      Permission.structureGradingView,
      Permission.structureGradingManage,
      ..._appointmentOfficePermissions,
    },
    UserRole.deputyHead: {
      Permission.reportsView,
      ..._moduleControlAdminPermissions,
      ..._securityLeadPermissions,
      ..._admissionsPermissions,
      ..._notificationAdminPermissions,
      ..._attendanceAdminPermissions,
      ..._approvalAdminPermissions,
      ..._communicationsAdminPermissions,
      Permission.structureGradingView,
      Permission.structureGradingManage,
      ..._appointmentOfficePermissions,
    },
    UserRole.deanOfStudies: {
      Permission.reportsView,
      ..._admissionsPermissions,
      ..._notificationOfficePermissions,
      ..._approvalAdminPermissions,
      Permission.attendanceClassScan,
      Permission.attendanceSubjectScan,
    },
    UserRole.hrOfficer: {
      ..._admissionsPermissions,
      ..._notificationOfficePermissions,
      Permission.attendanceStaffScan,
    },
    UserRole.nurse: {..._nursePermissions, ..._notificationSenderPermissions},
    UserRole.bursar: {
      ..._bursarPermissions,
      ..._notificationOfficePermissions,
      ..._approvalAdminPermissions,
      Permission.reportsView,
      Permission.reportsViewSensitive,
    },
    UserRole.librarian: {
      ..._librarianPermissions,
      ..._notificationSenderPermissions,
      Permission.attendanceLibraryScan,
    },
    UserRole.transportCoordinator: {
      ..._transportCoordinatorPermissions,
      ..._notificationOfficePermissions,
      Permission.attendanceTransportScan,
    },
    UserRole.cateringManager: {
      ..._cateringManagerPermissions,
      ..._notificationSenderPermissions,
      Permission.attendanceMealsScan,
    },
    UserRole.classTeacher: {
      ..._notificationSenderPermissions,
      Permission.attendanceClassScan,
    },
    UserRole.subjectTeacher: {
      ..._notificationSenderPermissions,
      Permission.attendanceSubjectScan,
    },
    UserRole.boardingMatron: {
      ..._notificationSenderPermissions,
      Permission.attendanceBoardingScan,
    },
    UserRole.boardingPatron: {
      ..._notificationSenderPermissions,
      Permission.attendanceBoardingScan,
    },
    UserRole.guidanceDiscipline: _notificationSenderPermissions,
    UserRole.gamesMaster: _notificationSenderPermissions,
    UserRole.religiousLeader: _notificationSenderPermissions,
  };

  static Set<String> permissionsFor(List<UserRole> roles) {
    final result = <String>{};
    for (final role in roles) {
      result.addAll(defaults[role] ?? const {});
    }
    return result;
  }
}
