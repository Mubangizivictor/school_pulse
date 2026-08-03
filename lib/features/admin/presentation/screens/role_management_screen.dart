import 'package:flutter/material.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/permissions/role_permission_defaults.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  UserRole _selectedRole = UserRole.schoolAdmin;
  late Map<UserRole, Set<String>> _rolePermissions;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // In a real app, this would be loaded from a repository/API
    _rolePermissions = Map.from(RolePermissionDefaults.defaults);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Role Permissions', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Row(
        children: [
          // Role Selector Sidebar (for larger screens) or a Dropdown for mobile
          if (MediaQuery.of(context).size.width > 800)
            _buildSidebar()
          else
            const SizedBox.shrink(),
          
          Expanded(
            child: Column(
              children: [
                if (MediaQuery.of(context).size.width <= 800)
                  _buildRoleDropdown(),
                _buildSearchAndFilters(),
                Expanded(
                  child: _buildPermissionList(),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.border(context), width: 0.5)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: UserRole.values.length,
        itemBuilder: (context, index) {
          final role = UserRole.values[index];
          final isSelected = _selectedRole == role;
          return ListTile(
            title: Text(
              UserRoleDisplay.name(role),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppColors.primary(context) : AppColors.textPrimary(context),
              ),
            ),
            selected: isSelected,
            selectedTileColor: AppColors.primary(context).withValues(alpha: 0.05),
            onTap: () => setState(() => _selectedRole = role),
          );
        },
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<UserRole>(
        value: _selectedRole,
        decoration: InputDecoration(
          labelText: 'Select Role to Edit',
          filled: true,
          fillColor: AppColors.surfaceContainer(context),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        items: UserRole.values.map((role) {
          return DropdownMenuItem(
            value: role,
            child: Text(UserRoleDisplay.name(role)),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedRole = val!),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search permissions...',
          prefixIcon: const Icon(Icons.search, size: 20),
          isDense: true,
          filled: true,
          fillColor: AppColors.surfaceContainer(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionList() {
    final permissions = _getAllPermissions();
    final filteredPermissions = permissions.where((p) => p.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    // Group permissions by category (first part of the ID)
    final grouped = <String, List<String>>{};
    for (final p in filteredPermissions) {
      final category = p.split('.').first;
      grouped.putIfAbsent(category, () => []).add(p);
    }

    final categories = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final items = grouped[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                  letterSpacing: 1.0,
                ),
              ),
            ),
            AppCard(
              padding: EdgeInsets.zero,
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: items.map((p) {
                  final isLast = items.last == p;
                  final hasPermission = _rolePermissions[_selectedRole]?.contains(p) ?? false;
                  return Column(
                    children: [
                      CheckboxListTile(
                        title: Text(
                          _formatPermissionName(p),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(p, style: TextStyle(fontSize: 11, color: AppColors.textMuted(context))),
                        value: hasPermission,
                        activeColor: AppColors.primary(context),
                        onChanged: (val) {
                          setState(() {
                            final current = _rolePermissions[_selectedRole] ?? {};
                            if (val == true) {
                              _rolePermissions[_selectedRole] = {...current, p};
                            } else {
                              _rolePermissions[_selectedRole] = current.where((item) => item != p).toSet();
                            }
                          });
                        },
                      ),
                      if (!isLast) const Divider(height: 1, indent: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(top: BorderSide(color: AppColors.border(context), width: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Changes here will affect all users assigned the ${UserRoleDisplay.name(_selectedRole)} role.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)),
            ),
          ),
          const SizedBox(width: 16),
          SecondaryButton(
            label: 'Discard',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          PrimaryButton(
            label: 'Save Changes',
            onPressed: () {
              // TODO: Implement save logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permissions updated successfully')),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatPermissionName(String id) {
    final parts = id.split('.');
    if (parts.length < 2) return id;
    final name = parts.skip(1).join(' ').replaceAll('_', ' ');
    return name[0].toUpperCase() + name.substring(1);
  }

  List<String> _getAllPermissions() {
    // Reflecting all permissions from the Permission class
    return [
      Permission.attendanceClassScan,
      Permission.attendanceSubjectScan,
      Permission.attendanceStaffScan,
      Permission.attendanceBoardingScan,
      Permission.attendanceGateScan,
      Permission.attendanceOverride,
      Permission.healthStudentVerify,
      Permission.healthStudentBasicRead,
      Permission.healthStudentClinicalRead,
      Permission.healthStudentVisitCreate,
      Permission.healthStudentEmergencyRead,
      Permission.mealsVerify,
      Permission.mealsServe,
      Permission.mealsOverride,
      Permission.mealsAuditRead,
      Permission.transportBoardingVerify,
      Permission.transportBoardingRecord,
      Permission.transportDropoffRecord,
      Permission.transportOverride,
      Permission.libraryMemberVerify,
      Permission.libraryBorrow,
      Permission.libraryReturn,
      Permission.financeStudentVerify,
      Permission.financeStudentBalanceRead,
      Permission.boardingRollcallScan,
      Permission.boardingStudentVerify,
      Permission.boardingOverride,
      Permission.examEligibilityVerify,
      Permission.examAttendanceScan,
      Permission.examOverride,
      Permission.securityIdentityVerify,
      Permission.securityEntryRecord,
      Permission.securityExitRecord,
      Permission.securityOverride,
      Permission.admissionApplicationCreate,
      Permission.admissionApplicationReview,
      Permission.admissionEnroll,
      Permission.studentBasicRead,
      Permission.studentFullRead,
      Permission.verificationOverride,
      Permission.verificationAuditRead,
      Permission.verificationDeviceManage,
      Permission.notificationView,
      Permission.notificationSend,
      Permission.notificationSendToParent,
      Permission.notificationSendToStudent,
      Permission.notificationSendToStaff,
      Permission.notificationBroadcast,
      Permission.notificationSchedule,
      Permission.notificationCancel,
      Permission.notificationUseImages,
      Permission.notificationUseAttachments,
      Permission.notificationSendEmergency,
      Permission.notificationViewDeliveryReports,
      Permission.notificationManageTemplates,
      Permission.notificationManageSettings,
      Permission.notificationAcknowledge,
      Permission.notificationArchive,
      Permission.notificationDelete,
      Permission.notificationSeedTestData,
      Permission.notificationRunDeliveryTest,
      Permission.subjectStudentsView,
      Permission.subjectStudentEnroll,
      Permission.subjectStudentRemove,
      Permission.subjectStudentHistoricalView,
      Permission.subjectLessonView,
      Permission.subjectLessonStart,
      Permission.subjectLessonComplete,
      Permission.subjectLessonCancel,
      Permission.subjectLessonReschedule,
      Permission.subjectAttendanceTake,
      Permission.subjectAttendanceEdit,
      Permission.subjectAttendanceEditHistorical,
      Permission.subjectLessonNoteCreate,
      Permission.subjectLessonNoteEdit,
      Permission.subjectResourceUpload,
      Permission.subjectResourceShare,
      Permission.subjectAssessmentCreate,
      Permission.subjectMarksView,
      Permission.subjectMarksEnter,
      Permission.subjectMarksEdit,
      Permission.subjectMarksEditSubmitted,
      Permission.subjectMarksSubmit,
      Permission.subjectMarksImport,
      Permission.subjectMarksExport,
      Permission.subjectReportView,
      Permission.subjectReportGenerate,
      Permission.subjectAnalyticsView,
      Permission.subjectParentMessage,
      Permission.subjectStudentMessage,
      Permission.subjectAnnouncementSend,
      Permission.subjectTimetableView,
      Permission.subjectTimetableEdit,
      Permission.classStudentsView,
      Permission.classStudentProfileView,
      Permission.classStudentHistoricalView,
      Permission.classStudentNoteWrite,
      Permission.classStudentDocumentView,
      Permission.classAttendanceTake,
      Permission.classAttendanceEdit,
      Permission.classAttendanceEditHistorical,
      Permission.classAttendanceView,
      Permission.classHomeworkCreate,
      Permission.classHomeworkPublish,
      Permission.classHomeworkEdit,
      Permission.classBehaviourRecord,
      Permission.classBehaviourView,
      Permission.classAchievementRecord,
      Permission.classHealthAlertView,
      Permission.classLeaveView,
      Permission.classParentMessage,
      Permission.classAnnouncementCreate,
      Permission.classAnnouncementPublish,
      Permission.classPerformanceView,
      Permission.classComparisonView,
      Permission.classInterventionNoteWrite,
      Permission.classReportEntry,
      Permission.classReportCompetencyEntry,
      Permission.classReportConductEntry,
      Permission.classReportCommentWrite,
      Permission.classReportRecommendationWrite,
      Permission.classReportSubmit,
      Permission.classReportGenerate,
      Permission.classReportShare,
      Permission.classReportExport,
      Permission.classTaskManage,
      Permission.classTaskCollaborate,
      Permission.classResourceUpload,
      Permission.classResourceShare,
      Permission.classResourceDelete,
      Permission.classTimetableView,
      Permission.classTeacherMultiAssignOverride,
    ];
  }
}
