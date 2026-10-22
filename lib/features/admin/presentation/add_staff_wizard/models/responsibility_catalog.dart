import 'package:school_pulse/core/user_roles.dart';

/// A single responsibility (job function) a staff member can be tagged with
/// in the Add Staff wizard's "Roles & responsibilities" step. Distinct from
/// [UserRole]: a responsibility describes *what the person does* day to day,
/// while [UserRole] (and its access defaults) governs *what they can access*
/// in the app - set separately in the Account access step. Where a
/// responsibility corresponds to an existing system role (e.g. Class
/// Teacher), [mappedRole] links the two so the existing scope-configuration
/// (class/subject assignment) and access-impact preview keep working;
/// responsibilities with no system-role equivalent yet (most operational/
/// support roles) carry a null [mappedRole] and are descriptive-only for now.
class Responsibility {
  final String id;
  final String category;
  final String title;
  final String description;
  final UserRole? mappedRole;
  final bool sensitive;

  const Responsibility({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    this.mappedRole,
    this.sensitive = false,
  });
}

/// Starter category order, matching the reference design's rail/chip order.
const List<String> kResponsibilityCategories = [
  'Leadership',
  'Teaching & learning',
  'Learner wellbeing & safeguarding',
  'Administration & finance',
  'Operations & facilities',
  'Boarding, transport & gate',
  'Health, catering & welfare',
  'Co-curricular, faith & community',
  'Library, ICT & digital learning',
];

/// Version tag for this static seed catalogue. Bump when the starter set
/// changes shape (added/removed/renamed entries) so a future
/// tenant-configurable catalogue can detect and migrate schools still on an
/// older default set.
const String kResponsibilityCatalogVersion = '1.0.0';

/// Uganda-ready starter responsibility catalogue (v1, static). This is
/// intentionally NOT hard-coded into any widget - widgets read from
/// [kResponsibilityCatalog] / [responsibilitiesByCategory] only, so a future
/// Firestore-backed tenant catalogue (enable/disable/rename/extend per
/// school) can replace this source without touching UI code, as long as it
/// serves the same [Responsibility] shape.
const List<Responsibility> kResponsibilityCatalog = [
  // Leadership
  Responsibility(
    id: 'proprietor_owner',
    category: 'Leadership',
    title: 'Proprietor / School Owner',
    description: 'Owns the school and holds ultimate governance authority.',
    sensitive: true,
  ),
  Responsibility(
    id: 'board_secretary',
    category: 'Leadership',
    title: 'Board Secretary',
    description:
        'Manages board records, minutes and governance correspondence.',
    sensitive: true,
  ),
  Responsibility(
    id: 'school_director',
    category: 'Leadership',
    title: 'School Director',
    description: 'Directs overall school strategy and operations.',
    mappedRole: UserRole.director,
    sensitive: true,
  ),
  Responsibility(
    id: 'head_teacher_principal',
    category: 'Leadership',
    title: 'Head Teacher / Principal',
    description:
        'Leads the school\'s day-to-day academic and administrative operations.',
    mappedRole: UserRole.headTeacher,
    sensitive: true,
  ),
  Responsibility(
    id: 'deputy_head_teacher',
    category: 'Leadership',
    title: 'Deputy Head Teacher',
    description: 'Supports the Head Teacher and deputises in their absence.',
    mappedRole: UserRole.deputyHead,
    sensitive: true,
  ),
  Responsibility(
    id: 'director_of_studies',
    category: 'Leadership',
    title: 'Director of Studies',
    description: 'Oversees the academic curriculum and teaching quality.',
  ),
  Responsibility(
    id: 'academic_coordinator',
    category: 'Leadership',
    title: 'Academic Coordinator',
    description:
        'Coordinates academic programmes across departments or sections.',
  ),
  Responsibility(
    id: 'head_lower_primary',
    category: 'Leadership',
    title: 'Head of Lower School / Primary Section',
    description:
        'Leads the primary section\'s academic and pastoral operations.',
  ),
  Responsibility(
    id: 'head_secondary_section',
    category: 'Leadership',
    title: 'Head of Secondary Section',
    description:
        'Leads the secondary section\'s academic and pastoral operations.',
  ),
  Responsibility(
    id: 'early_years_coordinator',
    category: 'Leadership',
    title: 'Early Years Coordinator',
    description: 'Coordinates nursery/reception programmes and staff.',
  ),
  Responsibility(
    id: 'campus_head',
    category: 'Leadership',
    title: 'Campus Head',
    description:
        'Leads operations for a specific campus in a multi-campus school.',
  ),
  Responsibility(
    id: 'dean_of_students',
    category: 'Leadership',
    title: 'Dean of Students',
    description: 'Oversees student welfare, discipline and conduct.',
    mappedRole: UserRole.deanOfStudies,
  ),
  Responsibility(
    id: 'deputy_director_of_studies',
    category: 'Leadership',
    title: 'Deputy Director of Studies',
    description: 'Supports the Director of Studies in curriculum oversight.',
  ),
  Responsibility(
    id: 'quality_assurance_supervisor',
    category: 'Leadership',
    title: 'Quality Assurance / Internal Supervisor',
    description: 'Monitors teaching standards and internal quality assurance.',
  ),

  // Teaching & learning
  Responsibility(
    id: 'class_teacher',
    category: 'Teaching & learning',
    title: 'Class Teacher',
    description:
        'Teaches a class, manages day-to-day learning and supports students\' progress.',
    mappedRole: UserRole.classTeacher,
  ),
  Responsibility(
    id: 'subject_teacher',
    category: 'Teaching & learning',
    title: 'Subject Teacher',
    description: 'Teaches a specific subject across one or more year groups.',
    mappedRole: UserRole.subjectTeacher,
  ),
  Responsibility(
    id: 'early_years_teacher',
    category: 'Teaching & learning',
    title: 'Early Years / Nursery Teacher',
    description:
        'Teaches in early years (e.g. nursery, reception) and supports early development.',
  ),
  Responsibility(
    id: 'primary_teacher',
    category: 'Teaching & learning',
    title: 'Primary Teacher',
    description: 'Teaches within the primary section.',
  ),
  Responsibility(
    id: 'secondary_teacher',
    category: 'Teaching & learning',
    title: 'Secondary Teacher',
    description: 'Teaches within the secondary section.',
  ),
  Responsibility(
    id: 'international_curriculum_teacher',
    category: 'Teaching & learning',
    title: 'International Curriculum Teacher',
    description:
        'Teaches an international curriculum stream (e.g. Cambridge, IB).',
  ),
  Responsibility(
    id: 'teaching_assistant',
    category: 'Teaching & learning',
    title: 'Teaching Assistant',
    description:
        'Supports teaching and learning in the classroom and with individual learners.',
  ),
  Responsibility(
    id: 'learning_support_assistant',
    category: 'Teaching & learning',
    title: 'Learning Support Assistant',
    description: 'Provides targeted support to learners who need extra help.',
  ),
  Responsibility(
    id: 'special_needs_teacher',
    category: 'Teaching & learning',
    title: 'Special Needs / Inclusive Education Teacher',
    description:
        'Supports learners with additional needs and drives inclusive teaching practices.',
  ),
  Responsibility(
    id: 'head_of_department',
    category: 'Teaching & learning',
    title: 'Head of Department',
    description:
        'Leads a subject department, coordinates teaching and monitors academic standards.',
  ),
  Responsibility(
    id: 'subject_coordinator',
    category: 'Teaching & learning',
    title: 'Subject Coordinator',
    description: 'Coordinates a subject\'s curriculum delivery across classes.',
  ),
  Responsibility(
    id: 'examinations_coordinator',
    category: 'Teaching & learning',
    title: 'Examinations Coordinator',
    description:
        'Manages internal and external examinations and related processes.',
  ),
  Responsibility(
    id: 'assessment_coordinator',
    category: 'Teaching & learning',
    title: 'Assessment Coordinator',
    description: 'Coordinates assessment design, moderation and reporting.',
  ),
  Responsibility(
    id: 'timetable_coordinator',
    category: 'Teaching & learning',
    title: 'Timetable Coordinator',
    description: 'Builds and maintains the school timetable.',
  ),
  Responsibility(
    id: 'curriculum_coordinator',
    category: 'Teaching & learning',
    title: 'Curriculum Coordinator',
    description: 'Coordinates curriculum planning and delivery school-wide.',
  ),
  Responsibility(
    id: 'careers_guidance_teacher',
    category: 'Teaching & learning',
    title: 'Careers and Guidance Teacher',
    description:
        'Provides careers education, guidance and university/work preparation.',
  ),
  Responsibility(
    id: 'school_librarian',
    category: 'Teaching & learning',
    title: 'School Librarian',
    description:
        'Manages the library, supports reading programmes and information literacy.',
    mappedRole: UserRole.librarian,
  ),
  Responsibility(
    id: 'reading_literacy_coordinator',
    category: 'Teaching & learning',
    title: 'Reading / Literacy Coordinator',
    description: 'Leads school-wide reading and literacy initiatives.',
  ),
  Responsibility(
    id: 'ict_computer_studies_teacher',
    category: 'Teaching & learning',
    title: 'ICT / Computer Studies Teacher',
    description: 'Teaches ICT / computer studies.',
  ),
  Responsibility(
    id: 'laboratory_technician',
    category: 'Teaching & learning',
    title: 'Laboratory Technician',
    description:
        'Prepares and maintains science laboratory equipment and materials.',
  ),
  Responsibility(
    id: 'laboratory_assistant',
    category: 'Teaching & learning',
    title: 'Laboratory Assistant',
    description: 'Assists with laboratory setup and practical sessions.',
  ),
  Responsibility(
    id: 'music_teacher',
    category: 'Teaching & learning',
    title: 'Music Teacher',
    description: 'Teaches music.',
  ),
  Responsibility(
    id: 'art_design_teacher',
    category: 'Teaching & learning',
    title: 'Art and Design Teacher',
    description: 'Teaches art and design.',
  ),
  Responsibility(
    id: 'games_pe_teacher',
    category: 'Teaching & learning',
    title: 'Games / Physical Education Teacher',
    description: 'Teaches physical education and coordinates games.',
    mappedRole: UserRole.gamesMaster,
  ),
  Responsibility(
    id: 'languages_teacher',
    category: 'Teaching & learning',
    title: 'Languages Teacher',
    description: 'Teaches one or more languages.',
  ),
  Responsibility(
    id: 'religious_education_teacher',
    category: 'Teaching & learning',
    title: 'Religious Education Teacher',
    description: 'Teaches religious education.',
  ),

  // Learner wellbeing & safeguarding
  Responsibility(
    id: 'senior_woman_teacher',
    category: 'Learner wellbeing & safeguarding',
    title: 'Senior Woman Teacher',
    description: 'Supports the welfare and guidance of female students.',
    sensitive: true,
  ),
  Responsibility(
    id: 'senior_man_teacher',
    category: 'Learner wellbeing & safeguarding',
    title: 'Senior Man Teacher',
    description: 'Supports the welfare and guidance of male students.',
    sensitive: true,
  ),
  Responsibility(
    id: 'school_counsellor',
    category: 'Learner wellbeing & safeguarding',
    title: 'School Counsellor',
    description: 'Provides counselling support to students.',
    sensitive: true,
  ),
  Responsibility(
    id: 'guidance_discipline_teacher',
    category: 'Learner wellbeing & safeguarding',
    title: 'Guidance and Discipline Teacher',
    description: 'Manages student guidance and discipline processes.',
    mappedRole: UserRole.guidanceDiscipline,
    sensitive: true,
  ),
  Responsibility(
    id: 'child_protection_lead',
    category: 'Learner wellbeing & safeguarding',
    title: 'Child Protection / Safeguarding Lead',
    description:
        'Leads the school\'s child protection and safeguarding response.',
    sensitive: true,
  ),
  Responsibility(
    id: 'special_needs_coordinator',
    category: 'Learner wellbeing & safeguarding',
    title: 'Special Needs Coordinator',
    description:
        'Coordinates support for learners with special educational needs.',
  ),
  Responsibility(
    id: 'welfare_officer',
    category: 'Learner wellbeing & safeguarding',
    title: 'Welfare Officer',
    description: 'Monitors and supports overall student welfare.',
    sensitive: true,
  ),
  Responsibility(
    id: 'attendance_officer',
    category: 'Learner wellbeing & safeguarding',
    title: 'Attendance Officer',
    description: 'Monitors and follows up on student attendance.',
  ),
  Responsibility(
    id: 'behaviour_discipline_coordinator',
    category: 'Learner wellbeing & safeguarding',
    title: 'Behaviour / Discipline Coordinator',
    description: 'Coordinates the school\'s behaviour and discipline policy.',
  ),
  Responsibility(
    id: 'school_social_worker',
    category: 'Learner wellbeing & safeguarding',
    title: 'School Social Worker',
    description: 'Provides social work support to students and families.',
    sensitive: true,
  ),
  Responsibility(
    id: 'careers_counsellor',
    category: 'Learner wellbeing & safeguarding',
    title: 'Careers Counsellor',
    description: 'Provides careers counselling to students.',
  ),
  Responsibility(
    id: 'peer_support_coordinator',
    category: 'Learner wellbeing & safeguarding',
    title: 'Peer Support Coordinator',
    description: 'Coordinates peer-support/mentoring programmes.',
  ),

  // Administration & finance
  Responsibility(
    id: 'school_administrator',
    category: 'Administration & finance',
    title: 'School Administrator',
    description: 'Manages general school administration.',
  ),
  Responsibility(
    id: 'bursar',
    category: 'Administration & finance',
    title: 'Bursar',
    description: 'Manages school finances, fees and accounts.',
    mappedRole: UserRole.bursar,
    sensitive: true,
  ),
  Responsibility(
    id: 'accountant',
    category: 'Administration & finance',
    title: 'Accountant',
    description: 'Maintains the school\'s financial accounts.',
    sensitive: true,
  ),
  Responsibility(
    id: 'accounts_assistant',
    category: 'Administration & finance',
    title: 'Accounts Assistant',
    description: 'Supports the finance office with accounts processing.',
    sensitive: true,
  ),
  Responsibility(
    id: 'finance_manager',
    category: 'Administration & finance',
    title: 'Finance Manager',
    description: 'Oversees the school\'s financial management.',
    sensitive: true,
  ),
  Responsibility(
    id: 'payroll_officer',
    category: 'Administration & finance',
    title: 'Payroll Officer',
    description: 'Manages staff payroll processing.',
    sensitive: true,
  ),
  Responsibility(
    id: 'cashier',
    category: 'Administration & finance',
    title: 'Cashier',
    description: 'Handles day-to-day cash receipts and payments.',
    sensitive: true,
  ),
  Responsibility(
    id: 'registrar',
    category: 'Administration & finance',
    title: 'Registrar',
    description: 'Manages student records and registration.',
    mappedRole: UserRole.registrar,
  ),
  Responsibility(
    id: 'admissions_officer',
    category: 'Administration & finance',
    title: 'Admissions Officer',
    description: 'Manages the student admissions process.',
    mappedRole: UserRole.admissions,
  ),
  Responsibility(
    id: 'receptionist',
    category: 'Administration & finance',
    title: 'Receptionist',
    description: 'Manages front-desk enquiries and visitor reception.',
    mappedRole: UserRole.receptionist,
  ),
  Responsibility(
    id: 'secretary',
    category: 'Administration & finance',
    title: 'Secretary',
    description: 'Provides administrative and secretarial support.',
  ),
  Responsibility(
    id: 'data_clerk',
    category: 'Administration & finance',
    title: 'Data Clerk',
    description: 'Handles data entry and records maintenance.',
  ),
  Responsibility(
    id: 'records_officer',
    category: 'Administration & finance',
    title: 'Records Officer',
    description: 'Maintains official school records.',
  ),
  Responsibility(
    id: 'procurement_officer',
    category: 'Administration & finance',
    title: 'Procurement Officer',
    description: 'Manages purchasing and vendor procurement.',
  ),
  Responsibility(
    id: 'storekeeper',
    category: 'Administration & finance',
    title: 'Storekeeper',
    description: 'Manages store stock and issuance.',
    mappedRole: UserRole.storeInventory,
  ),
  Responsibility(
    id: 'inventory_assets_officer',
    category: 'Administration & finance',
    title: 'Inventory / Assets Officer',
    description: 'Tracks and manages school inventory and assets.',
  ),
  Responsibility(
    id: 'hr_officer',
    category: 'Administration & finance',
    title: 'Human Resources Officer',
    description: 'Manages staff HR matters, contracts and records.',
    mappedRole: UserRole.hrOfficer,
    sensitive: true,
  ),
  Responsibility(
    id: 'communications_pr_officer',
    category: 'Administration & finance',
    title: 'Communications / Public Relations Officer',
    description: 'Manages school communications and public relations.',
  ),

  // Operations & facilities
  Responsibility(
    id: 'operations_manager',
    category: 'Operations & facilities',
    title: 'Operations Manager',
    description: 'Oversees day-to-day operational management.',
  ),
  Responsibility(
    id: 'facilities_manager',
    category: 'Operations & facilities',
    title: 'Facilities Manager',
    description: 'Manages school facilities and infrastructure.',
  ),
  Responsibility(
    id: 'maintenance_supervisor',
    category: 'Operations & facilities',
    title: 'Maintenance Supervisor',
    description: 'Supervises facility maintenance work.',
  ),
  Responsibility(
    id: 'electrician',
    category: 'Operations & facilities',
    title: 'Electrician',
    description: 'Handles electrical maintenance and repairs.',
  ),
  Responsibility(
    id: 'plumber',
    category: 'Operations & facilities',
    title: 'Plumber',
    description: 'Handles plumbing maintenance and repairs.',
  ),
  Responsibility(
    id: 'groundskeeper',
    category: 'Operations & facilities',
    title: 'Groundskeeper',
    description: 'Maintains school grounds and gardens.',
  ),
  Responsibility(
    id: 'cleaner_housekeeper',
    category: 'Operations & facilities',
    title: 'Cleaner / Housekeeper',
    description: 'Maintains cleanliness of school premises.',
  ),
  Responsibility(
    id: 'laundry_attendant',
    category: 'Operations & facilities',
    title: 'Laundry Attendant',
    description: 'Handles laundry services, typically for boarding schools.',
  ),
  Responsibility(
    id: 'driver',
    category: 'Operations & facilities',
    title: 'Driver',
    description: 'Drives school vehicles.',
  ),
  Responsibility(
    id: 'fleet_coordinator',
    category: 'Operations & facilities',
    title: 'Fleet Coordinator',
    description: 'Coordinates the school\'s vehicle fleet.',
  ),
  Responsibility(
    id: 'printer_reprographics_officer',
    category: 'Operations & facilities',
    title: 'Printer / Reprographics Officer',
    description: 'Manages printing and reprographics services.',
  ),
  Responsibility(
    id: 'security_supervisor',
    category: 'Operations & facilities',
    title: 'Security Supervisor',
    description: 'Supervises the school\'s security team.',
    mappedRole: UserRole.securityHead,
    sensitive: true,
  ),
  Responsibility(
    id: 'security_guard',
    category: 'Operations & facilities',
    title: 'Security Guard',
    description: 'Provides on-site security.',
    sensitive: true,
  ),
  Responsibility(
    id: 'gatekeeper',
    category: 'Operations & facilities',
    title: 'Gatekeeper',
    description: 'Manages gate access and entry logging.',
    mappedRole: UserRole.gatekeeper,
    sensitive: true,
  ),
  Responsibility(
    id: 'visitor_management_officer',
    category: 'Operations & facilities',
    title: 'Visitor Management Officer',
    description: 'Manages visitor sign-in and access control.',
    sensitive: true,
  ),

  // Boarding, transport & gate
  Responsibility(
    id: 'boarding_master',
    category: 'Boarding, transport & gate',
    title: 'Boarding Master',
    description: 'Oversees boarding operations for male students.',
    mappedRole: UserRole.boardingPatron,
  ),
  Responsibility(
    id: 'boarding_mistress',
    category: 'Boarding, transport & gate',
    title: 'Boarding Mistress',
    description: 'Oversees boarding operations for female students.',
    mappedRole: UserRole.boardingMatron,
  ),
  Responsibility(
    id: 'dormitory_matron',
    category: 'Boarding, transport & gate',
    title: 'Dormitory Matron',
    description: 'Manages a dormitory\'s day-to-day welfare for girls.',
    mappedRole: UserRole.boardingMatron,
  ),
  Responsibility(
    id: 'dormitory_patron',
    category: 'Boarding, transport & gate',
    title: 'Dormitory Patron',
    description: 'Manages a dormitory\'s day-to-day welfare for boys.',
    mappedRole: UserRole.boardingPatron,
  ),
  Responsibility(
    id: 'boarding_warden',
    category: 'Boarding, transport & gate',
    title: 'Boarding Warden',
    description: 'Oversees overall boarding house welfare and discipline.',
  ),
  Responsibility(
    id: 'transport_manager',
    category: 'Boarding, transport & gate',
    title: 'Transport Manager',
    description: 'Manages the school\'s transport operations.',
    mappedRole: UserRole.transportCoordinator,
  ),
  Responsibility(
    id: 'transport_coordinator',
    category: 'Boarding, transport & gate',
    title: 'Transport Coordinator',
    description: 'Coordinates transport routes and schedules.',
    mappedRole: UserRole.transportCoordinator,
  ),
  Responsibility(
    id: 'school_bus_driver',
    category: 'Boarding, transport & gate',
    title: 'School Bus Driver',
    description: 'Drives a school bus on an assigned route.',
  ),
  Responsibility(
    id: 'bus_attendant',
    category: 'Boarding, transport & gate',
    title: 'Bus Attendant',
    description: 'Supervises students on school transport.',
  ),
  Responsibility(
    id: 'route_supervisor',
    category: 'Boarding, transport & gate',
    title: 'Route Supervisor',
    description: 'Supervises a specific transport route.',
  ),
  Responsibility(
    id: 'gate_security_officer',
    category: 'Boarding, transport & gate',
    title: 'Gate Security Officer',
    description: 'Manages gate security and access control.',
    sensitive: true,
  ),
  Responsibility(
    id: 'biometric_identity_check_officer',
    category: 'Boarding, transport & gate',
    title: 'Biometric / Identity Check Officer',
    description:
        'Verifies identity via biometric or ID checks at entry points.',
    sensitive: true,
  ),

  // Health, catering & welfare
  Responsibility(
    id: 'school_nurse',
    category: 'Health, catering & welfare',
    title: 'School Nurse',
    description: 'Provides on-site medical care and health monitoring.',
    mappedRole: UserRole.nurse,
    sensitive: true,
  ),
  Responsibility(
    id: 'clinical_officer',
    category: 'Health, catering & welfare',
    title: 'Clinical Officer',
    description: 'Provides clinical care at the school health facility.',
    sensitive: true,
  ),
  Responsibility(
    id: 'health_safety_officer',
    category: 'Health, catering & welfare',
    title: 'Health and Safety Officer',
    description: 'Oversees school health and safety compliance.',
    sensitive: true,
  ),
  Responsibility(
    id: 'first_aid_officer',
    category: 'Health, catering & welfare',
    title: 'First Aid Officer',
    description: 'Provides first-aid response.',
    sensitive: true,
  ),
  Responsibility(
    id: 'nutritionist',
    category: 'Health, catering & welfare',
    title: 'Nutritionist',
    description: 'Advises on student nutrition and meal planning.',
  ),
  Responsibility(
    id: 'catering_manager',
    category: 'Health, catering & welfare',
    title: 'Catering Manager',
    description: 'Manages the school\'s catering operations.',
    mappedRole: UserRole.cateringManager,
  ),
  Responsibility(
    id: 'chef_cook',
    category: 'Health, catering & welfare',
    title: 'Chef / Cook',
    description: 'Prepares meals for students and staff.',
  ),
  Responsibility(
    id: 'kitchen_assistant',
    category: 'Health, catering & welfare',
    title: 'Kitchen Assistant',
    description: 'Supports kitchen and food preparation.',
  ),
  Responsibility(
    id: 'food_storekeeper',
    category: 'Health, catering & welfare',
    title: 'Food Storekeeper',
    description: 'Manages food stock and storage.',
  ),
  Responsibility(
    id: 'sanitation_officer',
    category: 'Health, catering & welfare',
    title: 'Sanitation Officer',
    description: 'Oversees school sanitation and hygiene standards.',
  ),
  Responsibility(
    id: 'welfare_coordinator',
    category: 'Health, catering & welfare',
    title: 'Welfare Coordinator',
    description: 'Coordinates staff and student welfare initiatives.',
  ),

  // Co-curricular, faith & community
  Responsibility(
    id: 'games_sports_coordinator',
    category: 'Co-curricular, faith & community',
    title: 'Games Master / Sports Coordinator',
    description: 'Coordinates sports and games programmes.',
    mappedRole: UserRole.gamesMaster,
  ),
  Responsibility(
    id: 'coach',
    category: 'Co-curricular, faith & community',
    title: 'Coach',
    description: 'Coaches a school sports team.',
  ),
  Responsibility(
    id: 'club_patron',
    category: 'Co-curricular, faith & community',
    title: 'Club Patron',
    description: 'Patron of a co-curricular club.',
  ),
  Responsibility(
    id: 'debate_patron',
    category: 'Co-curricular, faith & community',
    title: 'Debate Patron',
    description: 'Patron of the debate club/society.',
  ),
  Responsibility(
    id: 'music_choir_director',
    category: 'Co-curricular, faith & community',
    title: 'Music / Choir Director',
    description: 'Directs the school choir/music programme.',
  ),
  Responsibility(
    id: 'drama_patron',
    category: 'Co-curricular, faith & community',
    title: 'Drama Patron',
    description: 'Patron of the drama club/society.',
  ),
  Responsibility(
    id: 'scouts_guides_coordinator',
    category: 'Co-curricular, faith & community',
    title: 'Scouts / Guides Coordinator',
    description: 'Coordinates scouting/guiding activities.',
  ),
  Responsibility(
    id: 'religious_leader_chaplain',
    category: 'Co-curricular, faith & community',
    title: 'Religious Leader / Chaplain',
    description: 'Leads school religious/spiritual activities.',
    mappedRole: UserRole.religiousLeader,
  ),
  Responsibility(
    id: 'community_engagement_officer',
    category: 'Co-curricular, faith & community',
    title: 'Community Engagement Officer',
    description: 'Coordinates school-community engagement activities.',
  ),
  Responsibility(
    id: 'alumni_coordinator',
    category: 'Co-curricular, faith & community',
    title: 'Alumni Coordinator',
    description: 'Coordinates alumni relations.',
  ),
  Responsibility(
    id: 'parent_liaison_officer',
    category: 'Co-curricular, faith & community',
    title: 'Parent Liaison Officer',
    description: 'Liaises between the school and parents.',
  ),

  // Library, ICT & digital learning
  Responsibility(
    id: 'ict_manager',
    category: 'Library, ICT & digital learning',
    title: 'ICT Manager',
    description: 'Manages the school\'s ICT infrastructure.',
    sensitive: true,
  ),
  Responsibility(
    id: 'it_support_officer',
    category: 'Library, ICT & digital learning',
    title: 'IT Support Officer',
    description: 'Provides day-to-day IT support.',
  ),
  Responsibility(
    id: 'systems_administrator',
    category: 'Library, ICT & digital learning',
    title: 'Systems Administrator',
    description: 'Administers school information systems.',
    sensitive: true,
  ),
  Responsibility(
    id: 'digital_learning_coordinator',
    category: 'Library, ICT & digital learning',
    title: 'Digital Learning Coordinator',
    description: 'Coordinates digital learning tools and adoption.',
  ),
  Responsibility(
    id: 'computer_lab_assistant',
    category: 'Library, ICT & digital learning',
    title: 'Computer Lab Assistant',
    description: 'Supports the computer lab and student ICT use.',
  ),
  Responsibility(
    id: 'elearning_content_coordinator',
    category: 'Library, ICT & digital learning',
    title: 'E-Learning Content Coordinator',
    description: 'Coordinates development of e-learning content.',
  ),
  Responsibility(
    id: 'library_assistant',
    category: 'Library, ICT & digital learning',
    title: 'Library Assistant',
    description: 'Assists with library operations.',
  ),
  Responsibility(
    id: 'media_av_technician',
    category: 'Library, ICT & digital learning',
    title: 'Media / AV Technician',
    description: 'Manages media and audio-visual equipment.',
  ),
  Responsibility(
    id: 'data_protection_officer',
    category: 'Library, ICT & digital learning',
    title: 'Data Protection Officer',
    description: 'Oversees compliance with data protection requirements.',
    sensitive: true,
  ),
];

final Map<String, List<Responsibility>> responsibilitiesByCategory = {
  for (final category in kResponsibilityCategories)
    category: kResponsibilityCatalog
        .where((r) => r.category == category)
        .toList(growable: false),
};

final Map<String, Responsibility> responsibilityById = {
  for (final r in kResponsibilityCatalog) r.id: r,
};

/// Responsibility ids that are mutually exclusive with each other (picking
/// one clears the other) - mirrors the existing Matron/Patron gender-scope
/// exclusivity already enforced for [UserRole.boardingMatron]/
/// [UserRole.boardingPatron] in the role picker.
const List<Set<String>> kIncompatibleResponsibilityGroups = [
  {'boarding_master', 'boarding_mistress'},
  {'dormitory_matron', 'dormitory_patron'},
];

/// Responsibility ids the same set of incompatible groups apply to when
/// selecting [id] - used to auto-clear the conflicting choice.
Set<String> incompatibleResponsibilitiesFor(String id) {
  for (final group in kIncompatibleResponsibilityGroups) {
    if (group.contains(id)) return group.difference({id});
  }
  return const {};
}
