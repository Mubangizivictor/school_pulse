import 'package:equatable/equatable.dart';
import '../../presentation/bloc/structure_state.dart';

/// One configurable section of Structure, and whether it has any records yet.
class StructureProgressSection extends Equatable {
  final String title;
  final String route;
  final bool isConfigured;
  final bool isCore;

  const StructureProgressSection({
    required this.title,
    required this.route,
    required this.isConfigured,
    this.isCore = false,
  });

  @override
  List<Object?> get props => [title, route, isConfigured, isCore];
}

class StructureSetupProgress extends Equatable {
  final List<StructureProgressSection> sections;

  const StructureSetupProgress(this.sections);

  int get configuredCount => sections.where((s) => s.isConfigured).length;
  int get pendingCount => sections.length - configuredCount;
  double get ratio => sections.isEmpty ? 0 : configuredCount / sections.length;
  int get percentage => (ratio * 100).round();

  @override
  List<Object?> get props => [sections];
}

/// Computes Structure's setup completeness from the live [StructureState],
/// so the hub, the setup wizard, and the standalone progress screen all
/// read one definition of "configured" instead of three hand-rolled copies.
class StructureSetupProgressCalculator {
  StructureSetupProgress calculate(StructureState state) {
    final sections = <StructureProgressSection>[
      StructureProgressSection(
        title: 'Institution Profile',
        route: '/staff/admin/structure?section=institution',
        // An institution's name is the minimum identity required before any
        // downstream academic or operational setup can safely begin. The
        // remaining profile fields are optional by school type and region.
        isConfigured: state.institutionProfile.name.trim().isNotEmpty,
        isCore: true,
      ),
      StructureProgressSection(
        title: 'Educational Levels',
        route: '/staff/admin/structure/academic?tab=0',
        isConfigured: state.levels.isNotEmpty,
        isCore: true,
      ),
      StructureProgressSection(
        title: 'Academic Years',
        route: '/staff/admin/structure/academic?tab=0',
        isConfigured: state.academicYears.isNotEmpty,
        isCore: true,
      ),
      StructureProgressSection(
        title: 'Terms',
        route: '/staff/admin/structure/academic?tab=0',
        isConfigured: state.academicTerms.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Classes',
        route: '/staff/admin/structure/academic?tab=1',
        isConfigured: state.classes.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Streams / Sections',
        route: '/staff/admin/structure/academic?tab=1',
        isConfigured: state.streams.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Subjects',
        route: '/staff/admin/structure/academic?tab=2',
        isConfigured: state.subjects.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Departments',
        route: '/staff/admin/structure/people?tab=0',
        isConfigured: state.departments.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Staff Designations',
        route: '/staff/admin/structure/people?tab=1',
        isConfigured: state.designations.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Staff Roles',
        route: '/staff/admin/structure/people?tab=2',
        isConfigured: state.staffRoles.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Campuses',
        route: '/staff/admin/structure/campus?tab=0',
        isConfigured: state.campuses.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Houses',
        route: '/staff/admin/structure/campus?tab=1',
        isConfigured: state.houses.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Clubs',
        route: '/staff/admin/structure/campus?tab=2',
        isConfigured: state.clubs.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Facilities',
        route: '/staff/admin/structure/campus?tab=3',
        isConfigured: state.facilities.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Hostel Structure',
        route: '/staff/admin/structure/operations',
        isConfigured: state.hostels.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Transport Structure',
        route: '/staff/admin/structure/operations',
        isConfigured: state.transportRoutes.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Fee Categories',
        route: '/staff/admin/structure/assessment?tab=0',
        isConfigured: state.feeCategories.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Assessment Structure',
        route: '/staff/admin/structure/assessment?tab=1',
        isConfigured: state.assessmentTypes.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Grading Systems',
        route: '/staff/admin/structure/academics/grading-systems',
        isConfigured: state.gradingSystems.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Timetable Configuration',
        route: '/staff/admin/structure/timetable-config',
        isConfigured: state.timetableConfig.slots.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Attendance Configuration',
        route: '/staff/admin/structure/attendance-config',
        isConfigured: state.attendanceTypes.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Communication Configuration',
        route: '/staff/admin/structure/communication-config',
        isConfigured:
            state.announcementCategories.isNotEmpty ||
            state.notificationCategories.isNotEmpty ||
            state.messageTemplates.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Document Templates',
        route: '/staff/admin/structure/document-templates',
        isConfigured: state.documentTemplates.isNotEmpty,
      ),
      StructureProgressSection(
        title: 'Custom Fields',
        route: '/staff/admin/structure/custom-fields',
        isConfigured: state.customFields.isNotEmpty,
      ),
    ];
    return StructureSetupProgress(sections);
  }
}
