import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/app/school_splash_user_resolver.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/login_flow/welcome_screen.dart';
import 'package:school_pulse/features/auth/login_flow/parent_login_screens.dart';
import 'package:school_pulse/features/auth/login_flow/staff_login_screens.dart';
import 'package:school_pulse/features/auth/login_flow/platform_owner_access_screen.dart';
import 'package:school_pulse/features/auth/login_flow/mfa_challenge_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_pulse/features/auth/login_flow/student_login_screen.dart';
import 'package:school_pulse/features/shared/boarding/dorm_screens.dart';
import 'package:school_pulse/features/matron/presentation/screens/dormitory_management_screen.dart'
    as matron_scr;
import 'package:school_pulse/features/patron/presentation/screens/dormitory_management_screen.dart'
    as patron_scr;
import 'package:school_pulse/features/admin/admin_dashboard_screen.dart';
import 'package:school_pulse/features/admin/school_workspace_screen.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_cubit.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_state.dart';
import 'package:school_pulse/app/screens/institution_suspended_screen.dart';
import 'package:school_pulse/features/student_identity/presentation/bloc/student_identity_bloc.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart'
    as matron_scr;
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/matron/presentation/screens/bed_management_screen.dart'
    as matron_scr;
import 'package:school_pulse/features/patron/presentation/screens/bed_management_screen.dart';
import 'package:school_pulse/features/matron/presentation/screens/roll_call_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/roll_call_screen.dart';
import 'package:school_pulse/features/auth/login_flow/force_set_password_screen.dart';
import 'package:school_pulse/features/auth/login_flow/onboarding/onboarding_flow_screen.dart';
import 'package:school_pulse/features/auth/login_flow/school_splash_screen.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/parent_access/presentation/bloc/parent_access_cubit.dart';
import 'package:school_pulse/features/parent_access/presentation/widgets/parent_module_guard.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/presentation/screens/staff_panel_host.dart';
import 'package:school_pulse/features/teacher/presentation/screens/class_activities_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/class_teacher_tasks_screen.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/admin/presentation/pages/user_management_page.dart';
import 'package:school_pulse/features/admin/presentation/screens/access_codes_screen.dart';
import 'package:school_pulse/features/admin/presentation/pages/staff_list_page.dart';
import 'package:school_pulse/features/admin/presentation/pages/staff_detail_screen.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/add_staff_wizard_page.dart';
import 'package:school_pulse/features/admin/broadcast_sms_screen.dart';
import 'package:school_pulse/features/admin/system_config_screen.dart';
import 'package:school_pulse/features/integrations/presentation/integrations_center_screen.dart';
import 'package:school_pulse/features/integrations/presentation/integration_detail_screen.dart';
import 'package:school_pulse/features/integrations/presentation/integration_health_screen.dart';
import 'package:school_pulse/features/integrations/presentation/integration_devices_screen.dart';
import 'package:school_pulse/features/integrations/presentation/integration_webhooks_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/structure_wizard_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/academics/levels_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/academics/years_terms_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/academics/classes_streams_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/fee_plan_builder/fee_plan_builder_screen.dart';
import 'package:school_pulse/features/hr/presentation/screens/salary_structure_builder/salary_structure_builder_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/academics/subjects_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/academics/subject_class_assignments_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/academics/departments_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/academics/grading_systems_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/academics/assessment_types_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/people_structure_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/assessment_grading_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/campus_facilities_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/institution_settings_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/operations_config_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/feature_toggles_screen.dart';
import 'package:school_pulse/features/module_control/presentation/module_control_center_screen.dart';
import 'package:school_pulse/features/module_control/presentation/policy_center_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/structure_validation_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/timetable_config_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/timetables/timetables_list_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/timetables/timetable_builder_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/attendance_config_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/communication_config_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/document_templates_screen.dart';
import 'package:school_pulse/features/structure/presentation/screens/custom_fields_screen.dart';
import 'package:school_pulse/features/admin/admin_staff_attendance_screen.dart';
import 'package:school_pulse/features/appointments/presentation/screens/appointments_workspace_screen.dart';
import 'package:school_pulse/features/admin/audit_log_screen.dart';
import 'package:school_pulse/features/admin/support_center_screen.dart';
import 'package:school_pulse/features/communication_center/presentation/screens/communication_center_screen.dart';
import 'package:school_pulse/features/communication_center/presentation/screens/communication_compose_screen.dart';
import 'package:school_pulse/features/communication_center/presentation/screens/communication_detail_screen.dart';
import 'package:school_pulse/features/communication_center/presentation/screens/communication_templates_screen.dart';
import 'package:school_pulse/features/admin/security_center_screen.dart';
import 'package:school_pulse/features/admin/broadcast_history_screen.dart';
import 'package:school_pulse/features/admin/subscription_screen.dart';
import 'package:school_pulse/features/data_management/presentation/data_management_center_screen.dart';
import 'package:school_pulse/features/institution_health/presentation/institution_health_center_screen.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/parent/home_screen.dart';
import 'package:school_pulse/features/parent/academics_screen.dart';
import 'package:school_pulse/features/parent/report_card_screen.dart';
import 'package:school_pulse/features/parent/attendance_detail_screen.dart';
import 'package:school_pulse/features/parent/fees_screen.dart';
import 'package:school_pulse/features/parent/how_to_pay_screen.dart';
import 'package:school_pulse/features/parent/receipts_screen.dart';
import 'package:school_pulse/features/parent/health_screen.dart';
import 'package:school_pulse/features/parent/library_screen.dart';
import 'package:school_pulse/features/parent/discipline_screen.dart';
import 'package:school_pulse/features/parent/transport_screen.dart';
import 'package:school_pulse/features/parent/appointments_screen.dart';
import 'package:school_pulse/features/messages/domain/entities/message_models.dart';
import 'package:school_pulse/features/messages/presentation/screens/messages_list_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/chat_conversation_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/new_message_type_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/select_contacts_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/new_group_details_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/search_messages_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/chat_info_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/starred_messages_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/pinned_messages_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/contact_profile_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/media_links_docs_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/message_requests_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/broadcast_details_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/chat_settings_screen.dart';
import 'package:school_pulse/features/messages/presentation/screens/archived_chats_screen.dart';
import 'package:school_pulse/features/messages/presentation/widgets/messages_nav_icon.dart';
import 'package:school_pulse/features/parent_offline/presentation/widgets/parent_offline_gate.dart';
import 'package:school_pulse/features/parent_offline/presentation/widgets/parent_web_online_gate.dart';
import 'package:school_pulse/features/parent/profile_screen.dart';
import 'package:school_pulse/features/parent/boarding_screen.dart';
import 'package:school_pulse/features/parent/security_activity_screen.dart';
import 'package:school_pulse/features/shared/shell_screen.dart';
import 'package:school_pulse/features/shared/presentation/staff_hub_screen.dart';
import 'package:school_pulse/features/student/domain/entities/admission_application.dart';
import 'package:school_pulse/features/student/presentation/screens/admission_review_screen.dart';
import 'package:school_pulse/features/student/presentation/enrollment_setup/screens/enrollment_setup_wizard_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/admissions_list_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/admin_student_directory_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/admin_student_profile_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/admin_student_documents_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_portal_codes_screen.dart';
import 'package:school_pulse/features/student_identity/presentation/screens/identity_and_cards_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/new_application_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/direct_student_registration_screen.dart';
import 'package:school_pulse/features/profile/presentation/screens/profile_more_screen.dart';
import 'package:school_pulse/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:school_pulse/features/profile/presentation/screens/personal_information_screen.dart';
import 'package:school_pulse/features/profile/presentation/screens/security_privacy_screen.dart';
import 'package:school_pulse/features/profile/presentation/screens/change_password_screen.dart';
import 'package:school_pulse/features/profile/presentation/screens/two_factor_auth_screen.dart';
import 'package:school_pulse/features/profile/presentation/screens/active_sessions_screen.dart';
import 'package:school_pulse/features/profile/presentation/screens/account_activity_screen.dart';
import 'package:school_pulse/features/profile/presentation/screens/help_center_screen.dart';
import 'package:school_pulse/features/profile/presentation/screens/terms_of_service_screen.dart';
import 'package:school_pulse/features/profile/presentation/screens/attendance_settings_screen.dart';
import 'package:school_pulse/features/profile/presentation/screens/offline_data_screen.dart';
import 'package:school_pulse/features/profile/presentation/screens/about_school_pulse_screen.dart';
import 'package:school_pulse/features/school_directory/presentation/screens/school_directory_screen.dart';
import 'package:school_pulse/features/announcements/presentation/screens/announcements_screen.dart';
import 'package:school_pulse/features/announcements/presentation/screens/announcement_detail_screen.dart';
import 'package:school_pulse/features/announcements/presentation/screens/announcement_editor_screen.dart';
import 'package:school_pulse/features/teacher/attendance_screen.dart';
import 'package:school_pulse/features/teacher/attendance_history_screen.dart';
import 'package:school_pulse/features/teacher/class_analytics_screen.dart';
import 'package:school_pulse/features/teacher/homework_screen.dart';
import 'package:school_pulse/features/teacher/report_comments_screen.dart';
import 'package:school_pulse/features/school_calendar/presentation/screens/calendar_home_screen.dart';
import 'package:school_pulse/features/shared/tasks/presentation/screens/task_list_screen.dart';
import 'package:school_pulse/features/shared/tasks/presentation/screens/task_details_screen.dart';
import 'package:school_pulse/features/shared/tasks/presentation/screens/create_task_screen.dart';
import 'package:school_pulse/features/shared/tasks/presentation/screens/edit_task_screen.dart';
import 'package:school_pulse/features/shared/tasks/presentation/screens/task_attachments_screen.dart';
import 'package:school_pulse/features/shared/tasks/presentation/screens/task_dormitory_assignment_screen.dart';
import 'package:school_pulse/features/shared/tasks/presentation/screens/task_filter_screen.dart';
import 'package:school_pulse/features/shared/tasks/presentation/screens/task_history_screen.dart';
import 'package:school_pulse/features/shared/tasks/presentation/screens/task_reminders_screen.dart';
import 'package:school_pulse/features/shared/tasks/domain/entities/mock_tasks.dart';
import 'package:school_pulse/features/lesson_plans/presentation/lesson_plans_screen.dart';
import 'package:school_pulse/features/finance/presentation/shell/bursar_shell.dart';
import 'package:school_pulse/features/finance/presentation/shell/bursar_section.dart';
import 'package:school_pulse/features/finance/presentation/screens/student_billing/student_bills_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/clearance_policy_editor_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/payment_voucher_screen.dart';
import 'package:school_pulse/features/nurse/presentation/shell/nurse_shell.dart';
import 'package:school_pulse/features/health/presentation/screens/nurse_student_lookup_screen.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/library/presentation/screens/library_dashboard_screen.dart';
import 'package:school_pulse/features/library/presentation/screens/library_student_lookup_screen.dart';
import 'package:school_pulse/features/matron/presentation/screens/matron_dashboard_screen.dart';
import 'package:school_pulse/features/matron/presentation/screens/leave_management_screen.dart'
    as matron_scr;
import 'package:school_pulse/features/matron/presentation/screens/welfare_management_screen.dart'
    as matron_scr;
import 'package:school_pulse/features/matron/presentation/screens/discipline_management_screen.dart'
    as matron_scr;
import 'package:school_pulse/features/matron/presentation/screens/communication_screen.dart'
    as matron_scr;
import 'package:school_pulse/features/matron/presentation/screens/reports_screen.dart'
    as matron_scr;
import 'package:school_pulse/features/inventory/inventory_dashboard.dart';
import 'package:school_pulse/features/patron/presentation/screens/patron_dashboard.dart';
import 'package:school_pulse/features/patron/presentation/screens/welfare_management_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/discipline_management_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/leave_management_screen.dart'
    as patron_scr;
import 'package:school_pulse/features/patron/presentation/screens/communication_screen.dart'
    as patron_scr;
import 'package:school_pulse/features/patron/presentation/screens/reports_screen.dart'
    as patron_scr;
import 'package:school_pulse/features/shared/boarding/boarding_more_screen.dart';
import 'package:school_pulse/features/matron/presentation/screens/student_profile_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/student_profile_screen.dart';
import 'package:school_pulse/features/matron/presentation/screens/dorm_student_roster_screen.dart';
import 'package:school_pulse/features/patron/presentation/screens/dorm_student_roster_screen.dart';
import 'package:school_pulse/features/catering/presentation/catering_dashboard_screen.dart';
import 'package:school_pulse/features/catering/presentation/screens/catering_student_lookup_screen.dart';
import 'package:school_pulse/features/gate_ops/presentation/home/gatekeeper_home_screen.dart';
import 'package:school_pulse/features/gate_ops/presentation/home/gate_ops_minimal_dashboard_screen.dart';
import 'package:school_pulse/features/gate_ops/presentation/pickup/pickup_release_screen.dart';
import 'package:school_pulse/features/transport/presentation/transport_coordinator_dashboard_screen.dart';
import 'package:school_pulse/features/transport/presentation/screens/transport_student_lookup_screen.dart';
import 'package:school_pulse/features/discipline/presentation/discipline_dashboard_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/workload/teacher_workload_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/approvals/dean_approvals_screen.dart';
import 'package:school_pulse/features/headteacher/presentation/screens/headteacher_report_queue_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/interventions/academic_interventions_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/analytics/performance_analytics_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/curriculum/curriculum_management_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/monitoring/lesson_monitoring_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/qa/marks_qa_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/observations/class_observations_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/operations/todays_operations_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/alerts/academic_alerts_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/exams/exams_overview_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/monitoring/missed_lessons_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/assessments/assessments_overview_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/students/student_academic_profile_screen.dart';
import 'package:school_pulse/features/dean/presentation/screens/more/dean_more_screen.dart';
import 'package:school_pulse/features/religion/presentation/religious_leader_dashboard_screen.dart';
import 'package:school_pulse/features/exams/presentation/exams_dashboard_screen.dart';
import 'package:school_pulse/features/hr/presentation/screens/hr_dashboard_screen.dart';
import 'package:school_pulse/features/approvals/presentation/screens/approval_center_screen.dart';
import 'package:school_pulse/features/approvals/presentation/screens/work_inbox_screen.dart';
import 'package:school_pulse/features/approvals/presentation/screens/approval_policy_manager_screen.dart';
import 'package:school_pulse/features/approvals/presentation/screens/approval_delegation_screen.dart';
import 'package:school_pulse/features/approvals/presentation/screens/approval_request_submission_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/director_dashboard_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/director_reports_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/strategic_goals_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/leadership_meetings_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/school_performance_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/financial_overview_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/finance_analytics_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/academic_overview_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/student_analytics_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/staff_overview_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/parent_engagement_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/departments_overview_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/incidents_screen.dart';
import 'package:school_pulse/features/director/presentation/screens/communication_screen.dart';
import 'package:school_pulse/features/student_identity/presentation/screens/student_id_card_screen.dart';
import 'package:school_pulse/features/student_identity/presentation/screens/batch_id_card_screen.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/super_admin/domain/owner_security_session_service.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/super_admin_dashboard.dart';
import 'package:school_pulse/features/super_admin/presentation/widgets/super_admin_mobile_nav_shell.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/super_admin_notifications_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/owner_notification_preferences_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/owner_notification_history_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/security_center_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/help_support_home_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/submit_support_request_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/support_ticket_conversation_screen.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/contact_about_screen.dart';
import 'package:school_pulse/features/portal/domain/portal_runtime.dart';
import 'package:school_pulse/features/super_admin/presentation/pages/privacy_policy_screen.dart';
import 'package:school_pulse/features/games/presentation/screens/games_dashboard_screen.dart';
import 'package:school_pulse/features/dean/presentation/shell/dean_shell.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_logo.dart';

import 'package:school_pulse/features/attendance/presentation/screens/attendance_method_screen.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_category.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_session_handoff.dart';
import 'package:school_pulse/features/attendance_hub/presentation/bloc/attendance_bloc.dart';
import 'package:school_pulse/features/attendance_hub/presentation/screens/manual_attendance_screen.dart'
    as attendance_hub;
import 'package:school_pulse/features/attendance_hub/presentation/screens/nfc_scan_screen.dart'
    as attendance_hub;
import 'package:school_pulse/features/attendance_hub/presentation/screens/qr_scan_screen.dart'
    as attendance_hub;
import 'package:school_pulse/features/attendance_hub/presentation/screens/previous_attendance_screen.dart'
    as attendance_hub;
import 'package:school_pulse/features/attendance_hub/presentation/screens/attendance_statistics_screen.dart'
    as attendance_hub;
import 'package:school_pulse/features/attendance_hub/presentation/screens/sheets_integration_screen.dart'
    as attendance_hub;
import 'package:school_pulse/features/attendance/presentation/screens/attendance_summary_screen.dart';
import 'package:school_pulse/features/attendance/presentation/screens/attendance_list_screen.dart';
import 'package:school_pulse/features/branding/presentation/screens/splash_screen.dart'
    as pulse_splash;
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_state.dart';

import 'package:school_pulse/features/student/presentation/student_shell.dart';
import 'package:school_pulse/features/student/presentation/screens/student_dashboard_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_academics_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_homework_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_library_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_more_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_profile_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_fees_screen.dart';
import 'package:school_pulse/features/student/presentation/screens/student_timetable_screen.dart';
import 'package:school_pulse/features/teacher/teacher_student_list_screen.dart';
import 'package:school_pulse/features/teacher/teacher_student_profile_screen.dart';
import 'package:school_pulse/features/teacher/teacher_student_attendance_screen.dart';
import 'package:school_pulse/features/teacher/teacher_student_performance_screen.dart';
import 'package:school_pulse/features/teacher/teacher_student_assessments_screen.dart';
import 'package:school_pulse/features/teacher/teacher_student_behaviour_screen.dart';
import 'package:school_pulse/features/teacher/teacher_student_more_options_screen.dart';
import 'package:school_pulse/features/teacher/teacher_student_health_info_screen.dart';
import 'package:school_pulse/features/teacher/teacher_student_leave_applications_screen.dart';
import 'package:school_pulse/features/teacher/teacher_student_communications_screen.dart';
import 'package:school_pulse/features/teacher/teacher_student_documents_screen.dart';
import 'package:school_pulse/features/teacher/teacher_student_sibling_info_screen.dart';
import 'package:school_pulse/features/teacher/teacher_student_notes_screen.dart';
import 'package:school_pulse/features/teacher/teacher_classes_list_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/classes/class_details_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/classes/class_students_list_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/classes/class_timetable_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/classes/class_assignments_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/classes/class_performance_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/classes/class_announcements_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/classes/class_more_options_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/classes/class_resources_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/classes/class_behaviour_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/report_making/reports_dashboard_screen.dart';
import 'package:school_pulse/features/reports/presentation/screens/central_reports_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/report_making/class_report_detail_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/report_making/class_report_card_preview_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/marks/marks_dashboard_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/marks/select_assessment_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/marks/select_component_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/marks/enter_marks_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/marks/review_submit_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/marks/student_marks_detail_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/marks/class_marks_summary_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/marks/edit_marks_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/marks/import_marks_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/marks/marks_history_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/marks/marks_analytics_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/lessons/lessons_home_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/lessons/my_classes_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/lessons/class_lessons_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/lessons/lesson_details_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/lessons/take_attendance_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/lessons/lesson_notes_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/lessons/add_lesson_note_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/lessons/lesson_resources_screen.dart';

// ... (keep existing imports)

import 'package:school_pulse/features/health/presentation/screens/nurse_records_hub_screen.dart';
import 'package:school_pulse/features/health/presentation/screens/nurse_clinic_visits_screen.dart';
import 'package:school_pulse/features/health/presentation/screens/record_clinic_visit_screen.dart';
import 'package:school_pulse/features/health/presentation/screens/student_health_profile_screen.dart';
import 'package:school_pulse/features/health/presentation/screens/health_history_screen.dart';
import 'package:school_pulse/features/health/presentation/screens/incident_details_screen.dart';
import 'package:school_pulse/features/nurse/presentation/screens/medicine_inventory_screen.dart';

import 'package:school_pulse/features/notifications/presentation/screens/notification_list_screen.dart';
import 'package:school_pulse/features/notifications/presentation/screens/notification_details_screen.dart';
import 'package:school_pulse/features/notifications/presentation/screens/notification_details_loader_screen.dart';
import 'package:school_pulse/features/notifications/testing/notification_test_service/notification_test_screen.dart';
import 'package:school_pulse/features/notifications/presentation/screens/notification_delivery_report_screen.dart';
import 'package:school_pulse/features/notifications/presentation/screens/school_notification_settings_screen.dart';
import 'package:school_pulse/features/notifications/presentation/screens/notification_center_grouped_screen.dart';
import 'package:school_pulse/features/notifications/presentation/screens/notification_filter_screen.dart';
import 'package:school_pulse/features/notifications/presentation/screens/notification_search_screen.dart';
import 'package:school_pulse/features/notifications/presentation/screens/notification_preferences_screen.dart';
import 'package:school_pulse/features/notifications/presentation/screens/add_notification_screen.dart';
import 'package:school_pulse/features/notifications/presentation/screens/attachment_viewer_screen.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';

import 'package:school_pulse/features/teacher/presentation/screens/more/teacher_subjects_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/more/teacher_timetable_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/more/teacher_reports_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/more/teacher_downloads_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/more/teacher_leave_requests_screen.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_resource.dart';
import 'package:school_pulse/features/teacher/presentation/screens/resources/resources_home_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/resources/my_resources_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/resources/upload_resource_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/resources/create_folder_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/resources/resource_details_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/resources/share_resource_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/resources/folders_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/resources/add_link_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/resources/resource_categories_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/resources/recent_activity_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/resources/offline_resources_screen.dart';
import 'package:school_pulse/features/teacher/presentation/screens/resources/storage_usage_screen.dart';

/// Adapts a [Stream] (here, [AuthBloc]'s state stream) into the
/// [Listenable] GoRouter's `refreshListenable` expects, so a `redirect`
/// re-evaluation is triggered every time auth state changes - not just on
/// navigation. Without this, a still-resolving `AuthCheckRequested` (e.g.
/// web's async session restore) can strand the router on whatever it
/// evaluated first, since nothing else tells it to check again once the
/// real Authenticated/Unauthenticated state lands.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final router = GoRouter(
  initialLocation: '/',
  // di.sl<AuthBloc>() is a lazy singleton (see injection_container.dart),
  // so this is the exact same instance main.dart's BlocProvider supplies
  // via context - not a second, disconnected AuthBloc.
  refreshListenable: GoRouterRefreshStream(di.sl<AuthBloc>().stream),
  redirect: (context, state) async {
    final authState = context.read<AuthBloc>().state;
    final isLoggingIn =
        state.uri.path.contains('/login') ||
        state.uri.path.contains('/welcome') ||
        state.uri.path == '/owner-login' ||
        state.uri.path == '/owner/mfa-setup' ||
        state.uri.path == '/';

    if (authState is AuthInitial && !isLoggingIn) return '/';

    // While AuthCheckRequested is still resolving (e.g. on web, where
    // restoring a persisted Firebase session from IndexedDB is async),
    // stay put instead of bouncing a still-logged-in user to /welcome —
    // the redirect re-evaluates automatically once AuthBloc emits its
    // real Authenticated/Unauthenticated state.
    if (authState is AuthLoading) return null;

    // Host selection is not authorization. A valid portal hostname must
    // still match the authenticated user's home tenant, preventing a user
    // from carrying a School A session into School B's URL (including via a
    // hand-crafted deep link). Platform owners use the root console only.
    final portalTenant = PortalRuntime.tenant;
    if (portalTenant != null &&
        authState is AuthAuthenticated &&
        (authState.user.role == UserRole.superAdmin ||
            authState.user.schoolId != portalTenant.schoolId)) {
      return '/welcome';
    }

    // A Firebase session alone is never enough to render a tenant route.
    // The branding state is loaded only by /school-splash after the
    // authenticated profile has supplied a trusted schoolId.
    final path = state.uri.path;
    final isPipelineRoute =
        path == '/' ||
        path == '/welcome' ||
        path == '/school-splash' ||
        path.startsWith('/auth') ||
        path.startsWith('/owner') ||
        path == '/institution-suspended';
    if (authState is AuthAuthenticated &&
        authState.user.role != UserRole.superAdmin &&
        !isPipelineRoute) {
      final branding = context.read<BrandingBloc>().state;
      if (branding is! BrandingLoaded ||
          branding.branding?.schoolId != authState.user.schoolId) {
        return '/school-splash';
      }
    }

    // The seeded SaaS Owner must never render Staff Gateway (or any
    // /staff/* screen), even transiently - e.g. the MFA-challenge screen
    // (shared by staff and owner TOTP) always lands back on /staff/login
    // after resolveSignIn(), relying on StaffCredentialsScreen's own
    // listener to notice AuthAuthenticated and bounce away. That's a UI
    // convenience, not a security boundary: this router-level guard is the
    // actual one, catching a superAdmin session on any staff surface
    // before it ever builds, and sending it through the same
    // /school-splash -> /super-admin path a fresh owner login takes.
    if (authState is AuthAuthenticated &&
        authState.user.role == UserRole.superAdmin &&
        (state.uri.path == '/staff/login' ||
            state.uri.path.startsWith('/staff/'))) {
      return '/school-splash';
    }

    // Protect Super Admin routes
    if (state.uri.path.startsWith('/super-admin')) {
      if (authState is AuthAuthenticated) {
        if (authState.user.role != UserRole.superAdmin) {
          return UserRoleRouting.dashboardPath(authState.user.role);
        }
        // Mandatory TOTP: Firebase only *enforces* an MFA challenge at
        // sign-in for a user who already has a factor enrolled
        // (FirebaseAuthMultiFactorException gates AuthAuthenticated from
        // ever emitting in that case). It does not require enrollment to
        // exist in the first place, so an owner who never set up an
        // authenticator app reaches here on the first factor alone.
        // Force enrollment before the console ever renders.
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final factors = await currentUser.multiFactor.getEnrolledFactors();
          if (factors.isEmpty) return '/owner/mfa-setup';
        }

        // The unified elevated session every owner login path converges
        // into (password+TOTP, Google+TOTP, recovery code) - re-validated
        // live against the server on every navigation into /super-admin,
        // never trusted from AuthBloc's client-side role state alone. A
        // session explicitly revoked (Revoke All Sessions) fails closed
        // here even though the underlying Firebase session is still valid -
        // that's the whole point of a separate revocation surface.
        //
        // The in-memory sessionId does not survive an app restart (by
        // design - never persisted to SharedPreferences/localStorage), so
        // a restart re-establishes a fresh session here rather than
        // bouncing an otherwise-fully-authenticated owner back to
        // /owner-login: Firebase's own persisted session plus a still-live
        // `currentUser.multiFactor` enrollment already prove the owner
        // completed both factors previously, and requireOwner() gates the
        // establish call itself, so this is not a weaker check - it is the
        // same guarantee the original login already gave, just re-derived
        // instead of re-proven.
        final session = await OwnerSecuritySessionService.instance
            .validateOrReestablish();
        if (session == null) return '/owner-login';
      } else {
        return '/welcome';
      }
    }

    // Institution Context Engine gating. superAdmin operates platform-wide
    // and has no tenant to scope to, so it's exempt from all of this.
    final isInstitutionSuspendedRoute =
        state.uri.path == '/institution-suspended';
    if (authState is AuthAuthenticated &&
        authState.user.role != UserRole.superAdmin &&
        !isLoggingIn &&
        !isInstitutionSuspendedRoute &&
        !state.uri.path.startsWith('/super-admin')) {
      // The router owns this redirect callback; its context remains valid for
      // the life of the redirect evaluation after the security await above.
      // ignore: use_build_context_synchronously
      final contextState = context.read<InstitutionContextCubit>().state;
      if (contextState is InstitutionContextSuspended) {
        return '/institution-suspended';
      }
    }
    // A user who was suspended and got reactivated shouldn't stay stuck on
    // the suspended screen once the context reloads as active.
    if (isInstitutionSuspendedRoute && authState is AuthAuthenticated) {
      // ignore: use_build_context_synchronously
      final contextState = context.read<InstitutionContextCubit>().state;
      if (contextState is InstitutionContextLoaded) {
        return UserRoleRouting.dashboardPath(authState.user.role);
      }
    }

    // Force a first-login password/PIN change before any protected route
    // renders, even for a session restored on relaunch or reached via a
    // deep link - staff_login_screens.dart's BlocConsumer listener only
    // catches the moment of login itself, not an already-authenticated
    // session landing here later (app restart, deep link, notification
    // tap). This is the actual enforcement boundary; that listener is a
    // fast-path UX nicety only.
    if (authState is AuthAuthenticated && authState.user.mustChangePassword) {
      final targetPath = authState.user.role == UserRole.schoolAdmin
          ? '/auth/onboarding'
          : '/auth/force-setup';
      if (state.uri.path != targetPath) {
        return targetPath;
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const pulse_splash.SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/institution-suspended',
      builder: (context, state) => const InstitutionSuspendedScreen(),
    ),
    // A shared standalone route so every role sees the same About experience
    // without inheriting any role shell or bottom navigation.
    GoRoute(
      path: '/about-school-pulse',
      builder: (context, state) => const AboutSchoolPulseScreen(),
    ),
    GoRoute(
      path: '/school-splash',
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        // superAdmin is the SaaS platform owner, not a school tenant - they
        // have no schoolId to resolve and every other route in this file
        // already exempts them from the tenant pipeline (see the top-level
        // redirect above). SchoolSplashScreen has no exit of its own once
        // landed on, so without this a superAdmin routed here from any
        // login/session-restore path was stuck indefinitely resolving
        // branding for a school they don't belong to.
        if (authState is AuthAuthenticated &&
            authState.user.role == UserRole.superAdmin) {
          return UserRoleRouting.dashboardPath(UserRole.superAdmin);
        }
        final user = resolveSchoolSplashUser(state.extra, authState);
        return user == null ? '/welcome' : null;
      },
      builder: (context, state) {
        final user = resolveSchoolSplashUser(
          state.extra,
          context.read<AuthBloc>().state,
        )!;
        return SchoolSplashScreen(user: user);
      },
    ),
    ShellRoute(
      builder: (context, state, child) => StudentShell(child: child),
      routes: [
        GoRoute(
          path: '/student/dashboard',
          builder: (context, state) => const StudentDashboardScreen(),
        ),
        GoRoute(
          path: '/student/academics',
          builder: (context, state) => const StudentAcademicsScreen(),
          routes: [
            GoRoute(
              path: 'report-card',
              builder: (context, state) => const ReportCardScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/student/homework',
          builder: (context, state) => const StudentHomeworkScreen(),
        ),
        GoRoute(
          path: '/student/timetable',
          builder: (context, state) => const StudentTimetableScreen(),
        ),
        GoRoute(
          path: '/student/library',
          builder: (context, state) => const StudentLibraryScreen(),
        ),
        GoRoute(
          path: '/student/notifications',
          builder: (context, state) => const NotificationListScreen(),
          routes: [
            // Literal-path children must be declared before the `:id`
            // wildcard below - go_router matches nested routes in
            // declaration order, so `:id` would otherwise shadow every
            // named route (e.g. a push to .../filter would match `:id`
            // with id == 'filter' instead of the filter screen).
            GoRoute(
              path: 'filter',
              builder: (context, state) => const NotificationFilterScreen(),
            ),
            GoRoute(
              path: 'center',
              builder: (context, state) =>
                  const NotificationCenterGroupedScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                // The list passes the notification as `extra` so the details
                // screen paints immediately. A push tapped from the system
                // tray has no `extra`, so that path loads by id instead.
                final notification = state.extra;
                if (notification is NotificationItem) {
                  return NotificationDetailsScreen(notification: notification);
                }
                return NotificationDetailsLoaderScreen(
                  notificationId: state.pathParameters['id'] ?? '',
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/student/more',
          builder: (context, state) => const StudentMoreScreen(),
        ),
        GoRoute(
          path: '/student/profile',
          builder: (context, state) => const StudentProfileScreen(),
        ),
        GoRoute(
          path: '/student/fees',
          builder: (context, state) => const StudentFeesScreen(),
        ),
        GoRoute(
          path: '/student/messages',
          builder: (context, state) => const MessagesListScreen(),
        ),
        GoRoute(
          path: '/student/health',
          builder: (context, state) => const HealthScreen(),
        ),
        GoRoute(
          path: '/student/discipline',
          builder: (context, state) => const DisciplineScreen(),
        ),
        GoRoute(
          path: '/student/transport',
          builder: (context, state) => const TransportScreen(),
        ),
        GoRoute(
          path: '/student/id-card',
          builder: (context, state) => BlocProvider(
            create: (_) => di.sl<StudentIdentityBloc>(),
            child: StudentIdCardScreen(student: state.extra as Student),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/parent/login/child-id',
      builder: (context, state) => const ChildIdScreen(),
    ),
    GoRoute(
      path: '/parent/login/verify',
      builder: (context, state) =>
          ParentPhoneScreen(accessCode: state.extra as ParentAccessCode?),
    ),
    GoRoute(
      path: '/parent/login/pin',
      // GoRouter's refreshListenable re-evaluates this route's builder on
      // every AuthBloc emission (e.g. the auto-login this screen itself
      // triggers after PIN setup: AuthLoading immediately, then
      // AuthAuthenticated once it resolves), but `extra` is only ever
      // populated on the original push - every one of those re-evaluations
      // sees it as null. Redirect instead of crashing, but only once the
      // outcome is actually known: AuthLoading is a mid-flight state, not a
      // failure, so bouncing on it would send an about-to-succeed login back
      // to square one before AuthAuthenticated ever gets to fire.
      redirect: (context, state) {
        final extra = state.extra;
        if (extra is! Map<String, dynamic> ||
            extra['accessCode'] is! ParentAccessCode ||
            extra['phoneNumber'] is! String) {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) return '/school-splash';
          if (authState is AuthLoading) return null;
          return '/parent/login/child-id';
        }
        return null;
      },
      builder: (context, state) {
        final extra = state.extra;
        // Mirrors the redirect above: during the AuthLoading window the
        // redirect deliberately stays put rather than navigating away, so
        // the builder must tolerate the same missing `extra` without
        // crashing - a brief loading frame beats a red error screen.
        if (extra is! Map<String, dynamic> ||
            extra['accessCode'] is! ParentAccessCode ||
            extra['phoneNumber'] is! String) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return ParentPinScreen(
          accessCode: extra['accessCode'] as ParentAccessCode,
          phoneNumber: extra['phoneNumber'] as String,
        );
      },
    ),
    GoRoute(
      path: '/staff/login',
      builder: (context, state) => const StaffCredentialsScreen(),
    ),
    GoRoute(
      path: '/owner-login',
      builder: (context, state) => const PlatformOwnerAccessScreen(),
    ),
    GoRoute(
      path: '/owner/mfa-setup',
      builder: (context, state) => const TwoFactorAuthScreen(),
    ),
    GoRoute(
      path: '/auth/mfa-challenge',
      builder: (context, state) =>
          MfaChallengeScreen(resolver: state.extra as MultiFactorResolver),
    ),
    GoRoute(
      path: '/student/login',
      builder: (context, state) => const StudentHubScreen(),
    ),
    GoRoute(
      path: '/auth/force-setup',
      builder: (context, state) {
        final authState = context.read<AuthBloc>().state;
        // extra carries the user across the normal login->force-setup
        // handoff; the router-level mustChangePassword guard above can also
        // land here directly (relaunch/deep-link) with no extra, so fall
        // back to AuthBloc's already-authenticated user in that case.
        final user =
            state.extra as UserEntity? ??
            (authState is AuthAuthenticated ? authState.user : null);
        return ForceSetPasswordScreen(user: user);
      },
    ),
    GoRoute(
      path: '/auth/onboarding',
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        if (state.extra == null && authState is! AuthAuthenticated) {
          return '/welcome';
        }
        return null;
      },
      builder: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final user =
            state.extra as UserEntity? ?? (authState as AuthAuthenticated).user;
        return OnboardingFlowScreen(user: user);
      },
    ),
    GoRoute(path: '/login', redirect: (context, state) => '/welcome'),
    ShellRoute(
      builder: (context, state, child) {
        return ParentShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/parent/home',
          builder: (context, state) => const ParentHomeScreen(),
        ),
        GoRoute(
          path: '/parent/learn',
          builder: (context, state) => ParentModuleGuard(
            isAllowed: (v) => v.academics,
            child: AcademicsScreen(
              initialTab: state.extra is int
                  ? state.extra as int
                  : AcademicsTab.homework,
            ),
          ),
          routes: [
            GoRoute(
              path: 'report-card',
              builder: (context, state) => ParentModuleGuard(
                isAllowed: (v) => v.reportCard,
                child: const ReportCardScreen(),
              ),
            ),
            GoRoute(
              path: 'attendance',
              builder: (context, state) => ParentModuleGuard(
                isAllowed: (v) => v.attendance,
                child: const AttendanceDetailScreen(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/parent/payments',
          builder: (context, state) => ParentModuleGuard(
            isAllowed: (v) => v.fees,
            child: const FeesScreen(),
          ),
          routes: [
            GoRoute(
              path: 'how-to-pay',
              builder: (context, state) => ParentModuleGuard(
                isAllowed: (v) => v.fees,
                child: const HowToPayScreen(),
              ),
            ),
            GoRoute(
              path: 'receipts',
              builder: (context, state) => ParentModuleGuard(
                isAllowed: (v) => v.fees,
                child: const ReceiptsScreen(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/parent/messages',
          builder: (context, state) => ParentModuleGuard(
            isAllowed: (v) => v.messages,
            child: const MessagesListScreen(),
          ),
        ),
        GoRoute(
          path: '/parent/more',
          redirect: (context, state) => '/parent/profile',
        ),
        GoRoute(
          path: '/parent/health',
          builder: (context, state) => ParentModuleGuard(
            isAllowed: (v) => v.health,
            child: const HealthScreen(),
          ),
        ),
        GoRoute(
          path: '/parent/library',
          builder: (context, state) => ParentModuleGuard(
            isAllowed: (v) => v.library,
            child: const LibraryScreen(),
          ),
        ),
        GoRoute(
          path: '/parent/discipline',
          builder: (context, state) => ParentModuleGuard(
            isAllowed: (v) => v.discipline,
            child: const DisciplineScreen(),
          ),
        ),
        GoRoute(
          path: '/parent/transport',
          builder: (context, state) => ParentModuleGuard(
            isAllowed: (v) => v.transport,
            child: const TransportScreen(),
          ),
        ),
        GoRoute(
          path: '/parent/appointments',
          builder: (context, state) => ParentModuleGuard(
            isAllowed: (v) => v.appointments,
            child: const ParentAppointmentsScreen(),
          ),
        ),
        GoRoute(
          path: '/parent/profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => const EditProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/parent/notifications',
          builder: (context, state) => const NotificationListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                // The list passes the notification as `extra` so the details
                // screen paints immediately. A push tapped from the system
                // tray has no `extra`, so that path loads by id instead -
                // previously this did a mockNotifications.firstWhere() with no
                // orElse, which threw on any real notification id.
                final notification = state.extra;
                if (notification is NotificationItem) {
                  return NotificationDetailsScreen(notification: notification);
                }
                return NotificationDetailsLoaderScreen(
                  notificationId: state.pathParameters['id'] ?? '',
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/parent/calendar',
          builder: (context, state) => const CalendarHomeScreen(),
        ),
        GoRoute(
          path: '/parent/announcements/:id',
          builder: (context, state) => AnnouncementDetailScreen(
            announcementId: state.pathParameters['id'] ?? '',
          ),
        ),
        GoRoute(
          path: '/parent/boarding',
          builder: (context, state) => ParentModuleGuard(
            isAllowed: (v) => v.boarding,
            child: const ParentBoardingScreen(),
          ),
        ),
        GoRoute(
          path: '/parent/security',
          builder: (context, state) => const SecurityActivityScreen(),
        ),
      ],
    ),
    GoRoute(path: '/staff', redirect: (context, state) => '/staff/dashboard'),
    ShellRoute(
      builder: (context, state, child) {
        return StaffShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/staff/dashboard',
          // Which panel opens follows the responsibility in effect, not the
          // job title on the user record - see StaffPanelHost.
          builder: (context, state) => const StaffPanelHost(),
        ),
        GoRoute(
          path: '/staff/students',
          builder: (context, state) => const TeacherStudentListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => TeacherStudentProfileScreen(
                studentId: state.pathParameters['id']!,
              ),
              routes: [
                GoRoute(
                  path: 'attendance',
                  builder: (context, state) => TeacherStudentAttendanceScreen(
                    studentId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'performance',
                  builder: (context, state) => TeacherStudentPerformanceScreen(
                    studentId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'assessments',
                  builder: (context, state) => TeacherStudentAssessmentsScreen(
                    studentId: state.pathParameters['id']!,
                    initialSubjectId: state.uri.queryParameters['subjectId'],
                  ),
                ),
                GoRoute(
                  path: 'behaviour',
                  builder: (context, state) => TeacherStudentBehaviourScreen(
                    studentId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'more-options',
                  builder: (context, state) => TeacherStudentMoreOptionsScreen(
                    studentId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'health',
                  builder: (context, state) => TeacherStudentHealthInfoScreen(
                    studentId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'leave-applications',
                  builder: (context, state) =>
                      TeacherStudentLeaveApplicationsScreen(
                        studentId: state.pathParameters['id']!,
                      ),
                ),
                GoRoute(
                  path: 'communications',
                  builder: (context, state) =>
                      TeacherStudentCommunicationsScreen(
                        studentId: state.pathParameters['id']!,
                      ),
                ),
                GoRoute(
                  path: 'documents',
                  builder: (context, state) => TeacherStudentDocumentsScreen(
                    studentId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'siblings',
                  builder: (context, state) => TeacherStudentSiblingInfoScreen(
                    studentId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'notes',
                  builder: (context, state) => TeacherStudentNotesScreen(
                    studentId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/staff/classes',
          builder: (context, state) => const TeacherClassesListScreen(),
          routes: [
            GoRoute(
              path: ':classId',
              builder: (context, state) =>
                  ClassDetailsScreen(classId: state.pathParameters['classId']!),
              routes: [
                GoRoute(
                  path: 'students',
                  builder: (context, state) => ClassStudentsListScreen(
                    classId: state.pathParameters['classId']!,
                  ),
                ),
                GoRoute(
                  // ClassAttendanceScreen used to render here but was a fully
                  // mocked shell (hardcoded roster/percentages, no-op Save) -
                  // /staff/roll-call is the real ClassAttendanceBloc-backed
                  // register, so route there instead of showing fake data.
                  path: 'attendance',
                  redirect: (context, state) => '/staff/roll-call',
                ),
                GoRoute(
                  path: 'timetable',
                  builder: (context, state) => ClassTimetableScreen(
                    classId: state.pathParameters['classId']!,
                  ),
                ),
                GoRoute(
                  path: 'assignments',
                  builder: (context, state) => ClassAssignmentsScreen(
                    classId: state.pathParameters['classId']!,
                  ),
                ),
                GoRoute(
                  path: 'performance',
                  builder: (context, state) => ClassPerformanceScreen(
                    classId: state.pathParameters['classId']!,
                  ),
                ),
                GoRoute(
                  path: 'announcements',
                  builder: (context, state) => ClassAnnouncementsScreen(
                    classId: state.pathParameters['classId']!,
                  ),
                ),
                GoRoute(
                  path: 'more',
                  builder: (context, state) => ClassMoreOptionsScreen(
                    classId: state.pathParameters['classId']!,
                  ),
                ),
                GoRoute(
                  path: 'behaviour',
                  builder: (context, state) => ClassBehaviourScreen(
                    classId: state.pathParameters['classId']!,
                  ),
                ),
                GoRoute(
                  path: 'resources',
                  builder: (context, state) => ClassResourcesScreen(
                    classId: state.pathParameters['classId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/staff/admin/reports',
          builder: (context, state) => const CentralReportsScreen(),
        ),
        GoRoute(
          path: '/staff/reports',
          builder: (context, state) => const ReportsDashboardScreen(),
          routes: [
            GoRoute(
              path: 'student/:studentId',
              builder: (context, state) => ClassReportDetailScreen(
                studentId: state.pathParameters['studentId']!,
              ),
            ),
            // The real report-card preview - opened via `extra` since it
            // needs the full ActiveResponsibilityContext alongside the
            // report card id, not just a path parameter. See
            // ReportsDashboardScreen's "View Report" action.
            GoRoute(
              path: 'preview',
              builder: (context, state) {
                final extra = state.extra as ClassReportCardPreviewArgs;
                return ClassReportCardPreviewScreen(
                  reportCardId: extra.reportCardId,
                  responsibilityContext: extra.context,
                );
              },
            ),
            // Catches any stale deep link into the old 12-screen report
            // wizard, since removed - it used sample classes, students and
            // PDF content and duplicated what ClassReportDetailScreen above
            // already does against real data.
            GoRoute(
              path: ':legacy',
              redirect: (context, state) => '/staff/reports',
            ),
          ],
        ),
        GoRoute(
          path: '/staff/hub',
          builder: (context, state) => const StaffHubScreen(),
        ),
        GoRoute(
          path: '/staff/bursar',
          redirect: (context, state) {
            final auth = context.read<AuthBloc>().state;
            if (auth is! AuthAuthenticated) return '/welcome';
            const permitted = {
              UserRole.bursar,
              UserRole.schoolAdmin,
              UserRole.headTeacher,
              UserRole.director,
            };
            if (!auth.user.roles.any(permitted.contains)) {
              return UserRoleRouting.dashboardPath(auth.user.role);
            }
            return null;
          },
          builder: (context, state) =>
              const BursarShell(section: BursarSection.overview),
          routes: [
            GoRoute(
              path: 'lookup',
              builder: (context, state) =>
                  const BursarShell(section: BursarSection.students),
            ),
            // Console sections. Every `/staff/bursar/<slug>` builds
            // `BursarShell(section: …)`, which renders the width-appropriate
            // chrome (desktop sidebar / tablet rail / mobile bottom-nav) and
            // resolves that exact section — so direct URL load, browser
            // refresh, back/forward and shared links all land correctly at
            // every width. On mobile a section without its own tab opens on
            // **More** with the section screen pushed.
            GoRoute(
              path: 'overview',
              builder: (context, state) =>
                  const BursarShell(section: BursarSection.overview),
            ),
            GoRoute(
              path: 'students',
              builder: (context, state) =>
                  const BursarShell(section: BursarSection.students),
            ),
            GoRoute(
              path: 'approvals',
              builder: (context, state) =>
                  const BursarShell(section: BursarSection.approvals),
            ),
            GoRoute(
              path: 'cash-bank',
              builder: (context, state) =>
                  const BursarShell(section: BursarSection.cashBank),
            ),
            GoRoute(
              path: 'budget',
              builder: (context, state) =>
                  const BursarShell(section: BursarSection.budget),
            ),
            GoRoute(
              path: 'expenses',
              builder: (context, state) =>
                  const BursarShell(section: BursarSection.expenses),
            ),
            GoRoute(
              path: 'suppliers',
              builder: (context, state) =>
                  const BursarShell(section: BursarSection.suppliers),
            ),
            GoRoute(
              path: 'petty-cash',
              builder: (context, state) =>
                  const BursarShell(section: BursarSection.pettyCash),
            ),
            GoRoute(
              path: 'payroll',
              builder: (context, state) =>
                  const BursarShell(section: BursarSection.payroll),
            ),
            GoRoute(
              path: 'reports',
              builder: (context, state) =>
                  const BursarShell(section: BursarSection.reports),
            ),
            GoRoute(
              path: 'report-release',
              builder: (context, state) =>
                  const BursarShell(section: BursarSection.reportRelease),
            ),
            GoRoute(
              path: 'entitlements',
              builder: (context, state) =>
                  const BursarShell(section: BursarSection.entitlements),
            ),
            GoRoute(
              path: 'clearance-policy',
              builder: (context, state) => const ClearancePolicyEditorScreen(),
            ),
            // Payment vouchers is reachable from the mobile "More" list; this
            // route gives it a URL + deep link so it is also reachable on
            // tablet/desktop/web (the sidebar button for it is added with the
            // tablet-rail work in bursar_web_shell.dart).
            GoRoute(
              path: 'payment-vouchers',
              builder: (context, state) => const PaymentVouchersListScreen(),
            ),
            GoRoute(
              path: 'audit',
              builder: (context, state) =>
                  const BursarShell(section: BursarSection.audit),
            ),
            GoRoute(
              path: 'student/:studentId/bills',
              builder: (context, state) {
                final auth = context.read<AuthBloc>().state;
                final schoolId = auth is AuthAuthenticated
                    ? auth.user.schoolId
                    : '';
                return BursarShell(
                  section: BursarSection.students,
                  studentDetail: StudentBillsScreen(
                    schoolId: schoolId,
                    studentId: state.pathParameters['studentId']!,
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/staff/nurse',
          redirect: (context, state) {
            final auth = context.read<AuthBloc>().state;
            if (auth is! AuthAuthenticated) return '/welcome';
            const permitted = {
              UserRole.nurse,
              UserRole.schoolAdmin,
              UserRole.headTeacher,
              UserRole.deputyHead,
              UserRole.director,
            };
            if (!auth.user.roles.any(permitted.contains)) {
              return UserRoleRouting.dashboardPath(auth.user.role);
            }
            return null;
          },
          builder: (context, state) => const NurseShell(),
          routes: [
            GoRoute(
              path: 'records',
              builder: (context, state) => BlocProvider.value(
                value: context.read<HealthBloc>(),
                child: const NurseRecordsHubScreen(),
              ),
            ),
            GoRoute(
              path: 'visits',
              builder: (context, state) => BlocProvider.value(
                value: context.read<HealthBloc>(),
                child: const NurseClinicVisitsScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => BlocProvider.value(
                    value: context.read<HealthBloc>(),
                    child: RecordClinicVisitScreen(
                      studentId: state.extra as String,
                    ),
                  ),
                ),
              ],
            ),
            GoRoute(
              path: 'inventory',
              builder: (context, state) => BlocProvider.value(
                value: context.read<HealthBloc>(),
                child: const MedicineInventoryScreen(),
              ),
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) => BlocProvider.value(
                value: context.read<HealthBloc>(),
                child: const HealthHistoryScreen(),
              ),
            ),
            GoRoute(
              path: 'profile/:id',
              builder: (context, state) => BlocProvider.value(
                value: context.read<HealthBloc>(),
                child: StudentHealthProfileScreen(
                  studentId: state.pathParameters['id']!,
                ),
              ),
            ),
            GoRoute(
              path: 'incident/:id',
              builder: (context, state) => BlocProvider.value(
                value: context.read<HealthBloc>(),
                child: IncidentDetailsScreen(
                  incidentId: state.pathParameters['id']!,
                ),
              ),
            ),
            GoRoute(
              path: 'lookup',
              builder: (context, state) => const NurseStudentLookupScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/librarian',
          builder: (context, state) {
            final authState = context.read<AuthBloc>().state;
            final schoolId = authState is AuthAuthenticated
                ? authState.user.schoolId
                : '';
            return LibraryDashboardScreen(schoolId: schoolId);
          },
          routes: [
            GoRoute(
              path: 'lookup',
              builder: (context, state) => const LibraryStudentLookupScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/security',
          redirect: (context, state) {
            final auth = context.read<AuthBloc>().state;
            if (auth is! AuthAuthenticated) return '/welcome';
            const permitted = {
              UserRole.gatekeeper,
              UserRole.securityHead,
              UserRole.receptionist,
              UserRole.schoolAdmin,
              UserRole.director,
              UserRole.headTeacher,
              UserRole.deputyHead,
            };
            if (!auth.user.roles.any(permitted.contains)) {
              return UserRoleRouting.dashboardPath(auth.user.role);
            }
            return null;
          },
          builder: (context, state) {
            final auth = context.read<AuthBloc>().state;
            final isGatekeeper =
                auth is AuthAuthenticated &&
                auth.user.roles.contains(UserRole.gatekeeper) &&
                !auth.user.roles.any(
                  {
                    UserRole.securityHead,
                    UserRole.receptionist,
                    UserRole.schoolAdmin,
                    UserRole.director,
                    UserRole.headTeacher,
                    UserRole.deputyHead,
                  }.contains,
                );
            return isGatekeeper
                ? const GatekeeperHomeScreen()
                : const GateOpsMinimalDashboardScreen();
          },
          routes: [
            GoRoute(
              path: 'pickup',
              builder: (context, state) => const PickupReleaseScreen(),
            ),
            // gates, pickup-authorizations, lost-and-found, patrols,
            // settings, reports, visitors/* are out of scope for the
            // Gatekeeper Simple Mode rebuild's first phase and are
            // reintroduced in later phases.
          ],
        ),
        GoRoute(
          path: '/staff/inventory',
          builder: (context, state) => const InventoryDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/matron',
          redirect: (context, state) {
            final auth = context.read<AuthBloc>().state;
            if (auth is! AuthAuthenticated) return '/welcome';
            const permitted = {
              UserRole.boardingMatron,
              ...UserRoleDisplay.adminConsoleRoles,
            };
            if (!auth.user.roles.any(permitted.contains)) {
              return UserRoleRouting.dashboardPath(auth.user.role);
            }
            return null;
          },
          builder: (context, state) => const MatronDashboardScreen(),
          routes: [
            GoRoute(
              path: 'dorms',
              builder: (context, state) =>
                  const matron_scr.DormitoryManagementScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) {
                    final dorm = state.extra as matron_scr.Dormitory?;
                    return AddDormitoryScreen(
                      dormitoryName: dorm?.name,
                      capacity: dorm?.capacity,
                      location: dorm?.location,
                    );
                  },
                ),
                GoRoute(
                  path: 'leadership',
                  builder: (context, state) {
                    final dorm = state.extra as matron_scr.Dormitory?;
                    return SetDormLeadershipScreen(
                      roomLeaderName: dorm?.roomLeaderName,
                      dormPrefectName: dorm?.dormPrefectName,
                    );
                  },
                ),
                GoRoute(
                  path: 'history',
                  builder: (context, state) => const TransferHistoryScreen(),
                ),
                GoRoute(
                  path: 'beds',
                  builder: (context, state) => matron_scr.BedManagementScreen(
                    dormitory: state.extra as matron_scr.Dormitory,
                  ),
                ),
                GoRoute(
                  path: 'students',
                  builder: (context, state) => MatronDormStudentRosterScreen(
                    dormitory: state.extra as matron_scr.Dormitory,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: 'roll-call',
              builder: (context, state) => const MatronRollCallScreen(),
            ),
            GoRoute(
              path: 'students/:id',
              builder: (context, state) => MatronStudentProfileScreen(
                studentId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: 'more',
              builder: (context, state) => const BoardingMoreScreen(
                basePath: '/staff/matron',
                genderLabel: 'Girls',
              ),
            ),
            GoRoute(
              path: 'leave',
              builder: (context, state) =>
                  const matron_scr.LeaveManagementScreen(),
            ),
            GoRoute(
              path: 'welfare',
              builder: (context, state) =>
                  const matron_scr.WelfareManagementScreen(),
            ),
            GoRoute(
              path: 'discipline',
              builder: (context, state) =>
                  const matron_scr.DisciplineManagementScreen(),
            ),
            GoRoute(
              path: 'communication',
              builder: (context, state) =>
                  const matron_scr.CommunicationScreen(),
            ),
            GoRoute(
              path: 'reports',
              builder: (context, state) => const matron_scr.ReportsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/patron',
          redirect: (context, state) {
            final auth = context.read<AuthBloc>().state;
            if (auth is! AuthAuthenticated) return '/welcome';
            const permitted = {
              UserRole.boardingPatron,
              ...UserRoleDisplay.adminConsoleRoles,
            };
            if (!auth.user.roles.any(permitted.contains)) {
              return UserRoleRouting.dashboardPath(auth.user.role);
            }
            return null;
          },
          builder: (context, state) => const PatronDashboard(),
          routes: [
            GoRoute(
              path: 'dorms',
              builder: (context, state) =>
                  const patron_scr.DormitoryManagementScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) {
                    final dorm = state.extra as Dormitory?;
                    return AddDormitoryScreen(
                      dormitoryName: dorm?.name,
                      capacity: dorm?.capacity,
                      location: dorm?.location,
                    );
                  },
                ),
                GoRoute(
                  path: 'leadership',
                  builder: (context, state) {
                    final dorm = state.extra as Dormitory?;
                    return SetDormLeadershipScreen(
                      roomLeaderName: dorm?.roomLeaderName,
                      dormPrefectName: dorm?.dormPrefectName,
                    );
                  },
                ),
                GoRoute(
                  path: 'history',
                  builder: (context, state) => const TransferHistoryScreen(),
                ),
                GoRoute(
                  path: 'beds',
                  builder: (context, state) =>
                      BedManagementScreen(dormitory: state.extra as Dormitory),
                ),
                GoRoute(
                  path: 'students',
                  builder: (context, state) => PatronDormStudentRosterScreen(
                    dormitory: state.extra as Dormitory,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: 'roll-call',
              builder: (context, state) => const PatronRollCallScreen(),
            ),
            GoRoute(
              path: 'students/:id',
              builder: (context, state) => PatronStudentProfileScreen(
                studentId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: 'more',
              builder: (context, state) => const BoardingMoreScreen(
                basePath: '/staff/patron',
                genderLabel: 'Boys',
              ),
            ),
            GoRoute(
              path: 'leave',
              builder: (context, state) =>
                  const patron_scr.LeaveManagementScreen(),
            ),
            GoRoute(
              path: 'welfare',
              builder: (context, state) => const WelfareManagementScreen(),
            ),
            GoRoute(
              path: 'discipline',
              builder: (context, state) => const DisciplineManagementScreen(),
            ),
            GoRoute(
              path: 'communication',
              builder: (context, state) =>
                  const patron_scr.CommunicationScreen(),
            ),
            GoRoute(
              path: 'reports',
              builder: (context, state) => const patron_scr.ReportsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/catering',
          builder: (context, state) => const CateringDashboardScreen(),
          routes: [
            GoRoute(
              path: 'lookup',
              builder: (context, state) => const CateringStudentLookupScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/games',
          builder: (context, state) => const GamesDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/transport',
          builder: (context, state) =>
              const TransportCoordinatorDashboardScreen(),
          routes: [
            GoRoute(
              path: 'lookup',
              builder: (context, state) => const TransportStudentLookupScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/discipline',
          builder: (context, state) => const DisciplineDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/dean',
          builder: (context, state) => const DeanShell(),
          routes: [
            GoRoute(
              path: 'curriculum',
              builder: (context, state) => const CurriculumManagementScreen(),
            ),
            GoRoute(
              path: 'workload',
              builder: (context, state) => const TeacherWorkloadScreen(),
            ),
            GoRoute(
              path: 'lessons',
              builder: (context, state) => const LessonMonitoringScreen(),
            ),
            GoRoute(
              path: 'marks-qa',
              builder: (context, state) => const MarksQAScreen(),
            ),
            GoRoute(
              path: 'approvals',
              builder: (context, state) => const DeanApprovalsScreen(),
              routes: [
                GoRoute(
                  path: 'reports',
                  builder: (context, state) => const ApprovalCenterScreen(
                    moduleKeyFilter: 'academics',
                    title: 'Report Card Approvals',
                  ),
                ),
              ],
            ),
            GoRoute(
              path: 'interventions',
              builder: (context, state) => const AcademicInterventionsScreen(),
            ),
            GoRoute(
              path: 'observations',
              builder: (context, state) => const ClassObservationsScreen(),
            ),
            GoRoute(
              path: 'analytics',
              builder: (context, state) => const PerformanceAnalyticsScreen(),
            ),
            GoRoute(
              path: 'today',
              builder: (context, state) => const TodaysOperationsScreen(),
            ),
            GoRoute(
              path: 'alerts',
              builder: (context, state) => const AcademicAlertsScreen(),
            ),
            GoRoute(
              path: 'exams',
              builder: (context, state) => const ExamsOverviewScreen(),
            ),
            GoRoute(
              path: 'missed-lessons',
              builder: (context, state) => const MissedLessonsScreen(),
            ),
            GoRoute(
              path: 'assessments',
              builder: (context, state) => const AssessmentsOverviewScreen(),
            ),
            GoRoute(
              path: 'students/:id',
              builder: (context, state) => StudentAcademicProfileScreen(
                studentId: state.pathParameters['id'] ?? '',
              ),
            ),
            GoRoute(
              path: 'more',
              builder: (context, state) => const DeanMoreScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/religious-leader',
          builder: (context, state) => const ReligiousLeaderDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/exams',
          builder: (context, state) => const ExamsDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/hr',
          builder: (context, state) => const HRDashboardScreen(),
        ),
        GoRoute(
          path: '/staff/director',
          builder: (context, state) => const DirectorDashboardScreen(),
          routes: [
            GoRoute(
              path: 'approvals',
              builder: (context, state) => const ApprovalCenterScreen(),
              routes: [
                GoRoute(
                  path: 'policies',
                  builder: (context, state) =>
                      const ApprovalPolicyManagerScreen(),
                ),
                GoRoute(
                  path: 'delegations',
                  builder: (context, state) => const ApprovalDelegationScreen(),
                ),
                GoRoute(
                  path: 'submit',
                  builder: (context, state) =>
                      const ApprovalRequestSubmissionScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'reports',
              builder: (context, state) => const DirectorReportsScreen(),
            ),
            GoRoute(
              path: 'goals',
              builder: (context, state) => const StrategicGoalsScreen(),
            ),
            GoRoute(
              path: 'meetings',
              builder: (context, state) => const LeadershipMeetingsScreen(),
            ),
            GoRoute(
              path: 'performance',
              builder: (context, state) => const SchoolPerformanceScreen(),
            ),
            GoRoute(
              path: 'finance',
              builder: (context, state) => const FinancialOverviewScreen(),
            ),
            GoRoute(
              path: 'finance/analytics',
              builder: (context, state) => const FinanceAnalyticsScreen(),
            ),
            GoRoute(
              path: 'academics',
              builder: (context, state) => const AcademicOverviewScreen(),
            ),
            GoRoute(
              path: 'students',
              builder: (context, state) => const StudentAnalyticsScreen(),
            ),
            GoRoute(
              path: 'staff',
              builder: (context, state) => const StaffOverviewScreen(),
            ),
            GoRoute(
              path: 'parents',
              builder: (context, state) => const ParentEngagementScreen(),
            ),
            GoRoute(
              path: 'departments',
              builder: (context, state) => const DepartmentsOverviewScreen(),
            ),
            GoRoute(
              path: 'incidents',
              builder: (context, state) => const IncidentsScreen(),
            ),
            GoRoute(
              path: 'communication',
              builder: (context, state) => const CommunicationScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/headteacher/report-approvals',
          redirect: (context, state) {
            final auth = context.read<AuthBloc>().state;
            if (auth is! AuthAuthenticated) return '/welcome';
            const permitted = {
              UserRole.headTeacher,
              UserRole.director,
              UserRole.schoolAdmin,
            };
            return auth.user.roles.any(permitted.contains)
                ? null
                : UserRoleRouting.dashboardPath(auth.user.role);
          },
          builder: (context, state) => const HeadteacherReportQueueScreen(),
        ),
        GoRoute(
          path: '/staff/admin',
          builder: (context, state) => const AdminDashboardScreen(),
          routes: [
            GoRoute(
              path: 'data-management',
              redirect: (context, state) {
                final auth = context.read<AuthBloc>().state;
                if (auth is! AuthAuthenticated) return '/welcome';
                const permitted = {
                  UserRole.schoolAdmin,
                  UserRole.headTeacher,
                  UserRole.director,
                };
                return auth.user.roles.any(permitted.contains)
                    ? null
                    : UserRoleRouting.dashboardPath(auth.user.role);
              },
              builder: (context, state) => const DataManagementCenterScreen(),
            ),
            GoRoute(
              path: 'institution-health',
              redirect: (context, state) {
                final auth = context.read<AuthBloc>().state;
                if (auth is! AuthAuthenticated) return '/welcome';
                const permitted = {
                  UserRole.schoolAdmin,
                  UserRole.headTeacher,
                  UserRole.director,
                };
                return auth.user.roles.any(permitted.contains)
                    ? null
                    : UserRoleRouting.dashboardPath(auth.user.role);
              },
              builder: (context, state) =>
                  const InstitutionHealthCenterScreen(),
            ),
            GoRoute(
              path: 'approvals',
              builder: (context, state) => const ApprovalCenterScreen(),
              routes: [
                GoRoute(
                  path: 'policies',
                  builder: (context, state) =>
                      const ApprovalPolicyManagerScreen(),
                ),
                GoRoute(
                  path: 'delegations',
                  builder: (context, state) => const ApprovalDelegationScreen(),
                ),
                GoRoute(
                  path: 'submit',
                  builder: (context, state) =>
                      const ApprovalRequestSubmissionScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'parents',
              builder: (context, state) => const AccessCodesScreen(),
            ),
            GoRoute(
              path: 'users',
              builder: (context, state) => const StaffListPage(),
              routes: [
                GoRoute(
                  path: 'overview',
                  builder: (context, state) => const UserManagementPage(),
                ),
                GoRoute(
                  path: 'access-codes',
                  builder: (context, state) => const AccessCodesScreen(),
                ),
                GoRoute(
                  path: 'add-staff',
                  redirect: (context, state) {
                    final auth = context.read<AuthBloc>().state;
                    if (auth is! AuthAuthenticated) return '/welcome';
                    // Deputy Head shares the admin console UI but the
                    // createStaffAccount Cloud Function does not permit them
                    // to actually create staff - they can still navigate the
                    // wizard (Step 11 disables Confirm for them), but every
                    // other route into the admin console is exposed to the
                    // same UserRoleDisplay.adminConsoleRoles set, so this
                    // route uses that too rather than a narrower list that
                    // would make it a dead end reachable from nowhere.
                    if (!auth.user.roles.any(
                      UserRoleDisplay.adminConsoleRoles.contains,
                    )) {
                      return UserRoleRouting.dashboardPath(auth.user.role);
                    }
                    return null;
                  },
                  builder: (context, state) => const AddStaffWizardPage(),
                ),
                // Must stay below the literal 'overview'/'add-staff' routes -
                // go_router matches path segments in declaration order, and
                // this wildcard would otherwise capture them as a :uid.
                GoRoute(
                  path: ':uid',
                  builder: (context, state) =>
                      StaffDetailScreen(uid: state.pathParameters['uid']!),
                ),
              ],
            ),
            GoRoute(
              path: 'broadcast-sms',
              builder: (context, state) => const BroadcastSmsScreen(),
            ),
            GoRoute(
              path: 'config',
              builder: (context, state) => const SystemConfigScreen(),
            ),
            GoRoute(
              path: 'integrations',
              redirect: (context, state) {
                final auth = context.read<AuthBloc>().state;
                if (auth is! AuthAuthenticated) return '/welcome';
                // Integrations Center exposes provider connection lifecycle
                // and (masked) configuration for the whole institution - the
                // same School Admin/Head Teacher/Director subset that holds
                // Permission.integrationsView by default, never ordinary
                // staff even though they can reach the shared admin shell.
                const allowedRoles = [
                  UserRole.schoolAdmin,
                  UserRole.headTeacher,
                  UserRole.director,
                ];
                if (!auth.user.roles.any(allowedRoles.contains)) {
                  return UserRoleRouting.dashboardPath(auth.user.role);
                }
                return null;
              },
              builder: (context, state) => const IntegrationsCenterScreen(),
              routes: [
                GoRoute(
                  path: 'health',
                  builder: (context, state) => const IntegrationHealthScreen(),
                ),
                GoRoute(
                  path: 'devices',
                  builder: (context, state) => const IntegrationDevicesScreen(),
                ),
                GoRoute(
                  path: 'webhooks',
                  builder: (context, state) =>
                      const IntegrationWebhooksScreen(),
                ),
                GoRoute(
                  path: ':integrationKey',
                  builder: (context, state) => IntegrationDetailScreen(
                    integrationKey: state.pathParameters['integrationKey']!,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: 'structure',
              // Structure has exactly one canonical entry point: the
              // sequential setup wizard gate. It renders the current
              // incomplete step directly, or the roadmap/management
              // `StructureScreen` once every step is complete. Old deep
              // links that used to carry `?section=...` now land on the
              // same gate rather than jumping into an obsolete tabbed view.
              builder: (context, state) => const StructureWizardScreen(),
              routes: [
                GoRoute(
                  path: 'institution',
                  builder: (context, state) => InstitutionSettingsScreen(
                    wizardStep: int.tryParse(
                      state.uri.queryParameters['wizardStep'] ?? '',
                    ),
                    wizardTotal: int.tryParse(
                      state.uri.queryParameters['wizardTotal'] ?? '',
                    ),
                    wizardStepId:
                        state.uri.queryParameters['wizardStepId'] ??
                        'institution-info',
                  ),
                ),
                GoRoute(
                  path: 'academic',
                  redirect: (context, state) =>
                      '/staff/admin/structure?section=academics',
                ),
                GoRoute(
                  path: 'academics',
                  // Only redirects the bare `academics` path itself - a
                  // redirect on a parent GoRoute in go_router fires for every
                  // matched location under it, so returning unconditionally
                  // here was also hijacking every child route below (fee-
                  // structures, subjects, levels, etc.), bouncing them all
                  // back to the wizard gate before their own builder ran.
                  //
                  // `state.matchedLocation` is NOT the requested URL here -
                  // for an ancestor GoRoute it is always that route's own
                  // matched prefix ('/staff/admin/structure/academics'),
                  // identical whether the actual request is bare `academics`
                  // or `academics/fee-structures` beneath it. A prior fix
                  // compared against `matchedLocation` expecting it to differ
                  // between those two requests; it never does, so the
                  // redirect kept firing for every child unconditionally.
                  // `state.uri.path` is the actual full requested path and is
                  // the only field that distinguishes the two.
                  redirect: (context, state) =>
                      state.uri.path == '/staff/admin/structure/academics'
                      ? '/staff/admin/structure?section=academics'
                      : null,
                  routes: [
                    GoRoute(
                      path: 'levels',
                      builder: (context, state) => LevelsScreen(
                        wizardStep: int.tryParse(
                          state.uri.queryParameters['wizardStep'] ?? '',
                        ),
                        wizardTotal: int.tryParse(
                          state.uri.queryParameters['wizardTotal'] ?? '',
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'years-terms',
                      builder: (context, state) => YearsTermsScreen(
                        showTerms: state.uri.queryParameters['mode'] == 'terms',
                        wizardStep: int.tryParse(
                          state.uri.queryParameters['wizardStep'] ?? '',
                        ),
                        wizardTotal: int.tryParse(
                          state.uri.queryParameters['wizardTotal'] ?? '',
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'classes-streams',
                      builder: (context, state) => ClassesStreamsScreen(
                        wizardStep: int.tryParse(
                          state.uri.queryParameters['wizardStep'] ?? '',
                        ),
                        wizardTotal: int.tryParse(
                          state.uri.queryParameters['wizardTotal'] ?? '',
                        ),
                        wizardStepId:
                            state.uri.queryParameters['wizardStepId'] ??
                            'classes',
                      ),
                    ),
                    GoRoute(
                      path: 'fee-structures',
                      // Phase 1: the new Fee Plan Builder (immutable
                      // published fee-plan versions, integer UGX) replaces
                      // the legacy FeeConfigurationScreen here. School admin
                      // reaches this from Structure > Academics > Fee Plans
                      // without going through any Bursar-prefixed screen.
                      // FeeConfigurationScreen itself is left in place for
                      // any other legacy caller/read path.
                      builder: (context, state) => const FeePlanBuilderScreen(),
                    ),
                    GoRoute(
                      path: 'subjects',
                      builder: (context, state) => SubjectsScreen(
                        wizardStep: int.tryParse(
                          state.uri.queryParameters['wizardStep'] ?? '',
                        ),
                        wizardTotal: int.tryParse(
                          state.uri.queryParameters['wizardTotal'] ?? '',
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'subject-class-assignments',
                      builder: (context, state) =>
                          SubjectClassAssignmentsScreen(
                            wizardStep: int.tryParse(
                              state.uri.queryParameters['wizardStep'] ?? '',
                            ),
                            wizardTotal: int.tryParse(
                              state.uri.queryParameters['wizardTotal'] ?? '',
                            ),
                          ),
                    ),
                    GoRoute(
                      path: 'departments',
                      builder: (context, state) => DepartmentsScreen(
                        wizardStep: int.tryParse(
                          state.uri.queryParameters['wizardStep'] ?? '',
                        ),
                        wizardTotal: int.tryParse(
                          state.uri.queryParameters['wizardTotal'] ?? '',
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'grading-systems',
                      builder: (context, state) => GradingSystemsScreen(
                        wizardStep: int.tryParse(
                          state.uri.queryParameters['wizardStep'] ?? '',
                        ),
                        wizardTotal: int.tryParse(
                          state.uri.queryParameters['wizardTotal'] ?? '',
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'assessment-types',
                      builder: (context, state) =>
                          const AssessmentTypesScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'people',
                  builder: (context, state) => const PeopleStructureScreen(),
                  routes: [
                    GoRoute(
                      path: 'salary-structures',
                      // Salary Structure Builder (immutable published
                      // structure versions, integer UGX, keyed by staff
                      // designation) - mirrors the Fee Plan Builder pattern
                      // for payroll. Reached from Structure > People >
                      // Salary Structures.
                      builder: (context, state) =>
                          const SalaryStructureBuilderScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'assessment',
                  builder: (context, state) => const AssessmentGradingScreen(),
                ),
                GoRoute(
                  path: 'campus',
                  builder: (context, state) => const CampusFacilitiesScreen(),
                ),
                GoRoute(
                  path: 'operations',
                  builder: (context, state) => const OperationsConfigScreen(),
                ),
                GoRoute(
                  path: 'feature-toggles',
                  builder: (context, state) => const FeatureTogglesScreen(),
                ),
                GoRoute(
                  path: 'modules',
                  redirect: (context, state) {
                    final auth = context.read<AuthBloc>().state;
                    if (auth is! AuthAuthenticated) return '/welcome';
                    const roles = {
                      UserRole.schoolAdmin,
                      UserRole.director,
                      UserRole.headTeacher,
                      UserRole.deputyHead,
                    };
                    return auth.user.roles.any(roles.contains)
                        ? null
                        : UserRoleRouting.dashboardPath(auth.user.role);
                  },
                  builder: (context, state) =>
                      const ModuleControlCenterScreen(),
                ),
                GoRoute(
                  path: 'policies',
                  redirect: (context, state) {
                    final auth = context.read<AuthBloc>().state;
                    if (auth is! AuthAuthenticated) return '/welcome';
                    const roles = {
                      UserRole.schoolAdmin,
                      UserRole.director,
                      UserRole.headTeacher,
                      UserRole.deputyHead,
                    };
                    return auth.user.roles.any(roles.contains)
                        ? null
                        : UserRoleRouting.dashboardPath(auth.user.role);
                  },
                  builder: (context, state) => const PolicyCenterScreen(),
                ),
                GoRoute(
                  path: 'wizard',
                  redirect: (context, state) => '/staff/admin/structure',
                ),
                GoRoute(
                  path: 'progress',
                  redirect: (context, state) => '/staff/admin/structure',
                ),
                GoRoute(
                  path: 'validation',
                  builder: (context, state) =>
                      const StructureValidationScreen(),
                ),
                GoRoute(
                  path: 'timetable-config',
                  builder: (context, state) => const TimetableConfigScreen(),
                ),
                GoRoute(
                  path: 'timetables',
                  builder: (context, state) => const TimetablesListScreen(),
                  routes: [
                    GoRoute(
                      path: ':timetableId',
                      builder: (context, state) => TimetableBuilderScreen(
                        timetableId: state.pathParameters['timetableId']!,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'attendance-config',
                  builder: (context, state) => AttendanceConfigScreen(
                    initialTab:
                        int.tryParse(state.uri.queryParameters['tab'] ?? '0') ??
                        0,
                  ),
                ),
                GoRoute(
                  path: 'communication-config',
                  builder: (context, state) => CommunicationConfigScreen(
                    initialTab:
                        int.tryParse(state.uri.queryParameters['tab'] ?? '0') ??
                        0,
                  ),
                ),
                GoRoute(
                  path: 'document-templates',
                  builder: (context, state) => const DocumentTemplatesScreen(),
                ),
                GoRoute(
                  path: 'custom-fields',
                  builder: (context, state) => const CustomFieldsScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'staff-attendance',
              builder: (context, state) => const AdminStaffAttendanceScreen(),
            ),
            GoRoute(
              path: 'batch-id-cards',
              // Deep-linkable and otherwise ungated - any authenticated
              // staff member could reach ID card issuance before this,
              // unlike every other admin/{...} route with this class of
              // access. Same permitted set as admissions below.
              redirect: (context, state) {
                final auth = context.read<AuthBloc>().state;
                if (auth is! AuthAuthenticated) return '/welcome';
                const permitted = {
                  UserRole.schoolAdmin,
                  UserRole.director,
                  UserRole.headTeacher,
                  UserRole.deputyHead,
                  UserRole.deanOfStudies,
                  UserRole.receptionist,
                  UserRole.hrOfficer,
                };
                if (!auth.user.roles.any(permitted.contains)) {
                  return UserRoleRouting.dashboardPath(auth.user.role);
                }
                return null;
              },
              builder: (context, state) => const BatchIdCardScreen(),
            ),
            GoRoute(
              path: 'admissions',
              redirect: (context, state) {
                final auth = context.read<AuthBloc>().state;
                if (auth is! AuthAuthenticated) return '/welcome';
                const permitted = {
                  UserRole.schoolAdmin,
                  UserRole.director,
                  UserRole.headTeacher,
                  UserRole.deputyHead,
                  UserRole.deanOfStudies,
                  UserRole.receptionist,
                  UserRole.hrOfficer,
                };
                if (!auth.user.roles.any(permitted.contains)) {
                  return UserRoleRouting.dashboardPath(auth.user.role);
                }
                return null;
              },
              builder: (context, state) => const AdmissionsListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) =>
                      NewApplicationScreen(schoolId: state.extra as String),
                ),
                GoRoute(
                  path: 'register',
                  builder: (context, state) => DirectStudentRegistrationScreen(
                    schoolId: state.extra as String,
                  ),
                ),
                GoRoute(
                  path: 'review',
                  builder: (context, state) => AdmissionReviewScreen(
                    application: state.extra as AdmissionApplication,
                  ),
                  routes: [
                    GoRoute(
                      path: 'enroll',
                      builder: (context, state) {
                        final extra =
                            state.extra as EnrollmentSetupWizardRouteExtra;
                        return EnrollmentSetupWizardScreen(
                          application: extra.application,
                          studentId: extra.studentId,
                          schoolCode: extra.schoolCode,
                          uniqueSystemId: extra.uniqueSystemId,
                          studentCode: extra.studentCode,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: 'students',
              redirect: (context, state) {
                final auth = context.read<AuthBloc>().state;
                if (auth is! AuthAuthenticated) return '/welcome';
                const permitted = {
                  UserRole.schoolAdmin,
                  UserRole.director,
                  UserRole.headTeacher,
                  UserRole.deputyHead,
                  UserRole.deanOfStudies,
                  UserRole.receptionist,
                  UserRole.hrOfficer,
                };
                if (!auth.user.roles.any(permitted.contains)) {
                  return UserRoleRouting.dashboardPath(auth.user.role);
                }
                return null;
              },
              // Students is a working directory, not a dashboard. The
              // dashboard remains available from its own workspace entry;
              // this route deliberately matches the compact learner list.
              builder: (context, state) => const AdminStudentDirectoryScreen(),
              routes: [
                GoRoute(
                  path: 'list',
                  builder: (context, state) =>
                      const AdminStudentDirectoryScreen(),
                ),
                GoRoute(
                  path: 'directory',
                  builder: (context, state) =>
                      const AdminStudentDirectoryScreen(),
                ),
                GoRoute(
                  path: ':id',
                  // An optional `?tab=` query parameter selects the initial
                  // profile tab (used by the enrolment success screen's "Set
                  // up fee plan" action). Omitting it - the existing plain
                  // `students/:id` deep link - still lands on Overview.
                  builder: (context, state) => AdminStudentProfileScreen(
                    studentId: state.pathParameters['id']!,
                    initialTab:
                        int.tryParse(state.uri.queryParameters['tab'] ?? '') ??
                        StudentProfileTab.overview,
                  ),
                  routes: [
                    GoRoute(
                      path: 'documents',
                      builder: (context, state) => AdminStudentDocumentsScreen(
                        student: state.extra as Student,
                        canMutate: true,
                      ),
                    ),
                    GoRoute(
                      path: 'identity',
                      builder: (context, state) => BlocProvider(
                        create: (_) => di.sl<StudentIdentityBloc>(),
                        child: IdentityAndCardsScreen(
                          student: state.extra as Student,
                          canMutate: true,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'portal',
                      builder: (context, state) => StudentPortalCodesScreen(
                        student: state.extra as Student,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: 'appointments',
              redirect: (context, state) {
                final auth = context.read<AuthBloc>().state;
                if (auth is! AuthAuthenticated) return '/welcome';
                const permitted = {
                  UserRole.director,
                  UserRole.headTeacher,
                  UserRole.deputyHead,
                  UserRole.schoolAdmin,
                  UserRole.receptionist,
                  UserRole.securityHead,
                };
                return auth.user.roles.any(permitted.contains)
                    ? null
                    : UserRoleRouting.dashboardPath(auth.user.role);
              },
              builder: (context, state) => const AppointmentsWorkspaceScreen(),
            ),
            GoRoute(
              path: 'audit-log',
              redirect: (context, state) {
                final auth = context.read<AuthBloc>().state;
                if (auth is! AuthAuthenticated) return '/welcome';
                const permitted = {
                  UserRole.director,
                  UserRole.headTeacher,
                  UserRole.schoolAdmin,
                };
                return auth.user.roles.any(permitted.contains)
                    ? null
                    : UserRoleRouting.dashboardPath(auth.user.role);
              },
              builder: (context, state) => const AuditLogScreen(),
            ),
            GoRoute(
              path: 'support',
              redirect: (context, state) {
                final auth = context.read<AuthBloc>().state;
                if (auth is! AuthAuthenticated) return '/welcome';
                const permitted = {
                  UserRole.director,
                  UserRole.headTeacher,
                  UserRole.schoolAdmin,
                };
                return auth.user.roles.any(permitted.contains)
                    ? null
                    : UserRoleRouting.dashboardPath(auth.user.role);
              },
              builder: (context, state) => const SupportCenterScreen(),
            ),
            GoRoute(
              path: 'communication-center',
              redirect: (context, state) {
                final auth = context.read<AuthBloc>().state;
                if (auth is! AuthAuthenticated) return '/welcome';
                // securityHead only holds communications.send_emergency, but
                // still needs to reach the center to raise one - the bloc
                // gates individual actions by permission from there.
                const permitted = {
                  UserRole.director,
                  UserRole.headTeacher,
                  UserRole.schoolAdmin,
                  UserRole.deputyHead,
                  UserRole.securityHead,
                };
                return auth.user.roles.any(permitted.contains)
                    ? null
                    : UserRoleRouting.dashboardPath(auth.user.role);
              },
              builder: (context, state) => const CommunicationCenterScreen(),
              routes: [
                GoRoute(
                  path: 'compose',
                  builder: (context, state) => CommunicationComposeScreen(
                    campaignId: state.uri.queryParameters['campaignId'],
                    templateId: state.uri.queryParameters['templateId'],
                  ),
                ),
                GoRoute(
                  path: ':campaignId',
                  builder: (context, state) => CommunicationDetailScreen(
                    campaignId: state.pathParameters['campaignId']!,
                  ),
                ),
                GoRoute(
                  path: 'templates',
                  builder: (context, state) =>
                      const CommunicationTemplatesScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'security',
              redirect: (context, state) {
                final auth = context.read<AuthBloc>().state;
                if (auth is! AuthAuthenticated) return '/welcome';
                const permitted = {
                  UserRole.director,
                  UserRole.headTeacher,
                  UserRole.schoolAdmin,
                };
                return auth.user.roles.any(permitted.contains)
                    ? null
                    : UserRoleRouting.dashboardPath(auth.user.role);
              },
              builder: (context, state) => const AdminSecurityCenterScreen(),
            ),
            GoRoute(
              path: 'broadcast-history',
              builder: (context, state) => const BroadcastHistoryScreen(),
            ),
            GoRoute(
              path: 'subscription',
              builder: (context, state) => const SubscriptionScreen(),
            ),
            GoRoute(
              path: 'student-id-card',
              builder: (context, state) {
                final student = state.extra as Student;
                return BlocProvider(
                  create: (_) => di.sl<StudentIdentityBloc>(),
                  child: StudentIdCardScreen(student: student),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/staff/notifications',
          builder: (context, state) => const NotificationListScreen(),
          routes: [
            GoRoute(
              path: 'center',
              builder: (context, state) =>
                  const NotificationCenterGroupedScreen(),
            ),
            GoRoute(
              path: 'search',
              builder: (context, state) => const NotificationSearchScreen(),
            ),
            GoRoute(
              path: 'filter',
              builder: (context, state) => const NotificationFilterScreen(),
            ),
            GoRoute(
              path: 'preferences',
              builder: (context, state) =>
                  const NotificationPreferencesScreen(),
            ),
            // Delivery test tool. Reachable at /staff/notifications/test;
            // it only ever sends to the signed-in user's own devices.
            GoRoute(
              path: 'test',
              builder: (context, state) => const NotificationTestScreen(),
            ),
            // Delivery outcomes for notifications this user sent.
            GoRoute(
              path: 'reports',
              builder: (context, state) =>
                  const NotificationDeliveryReportScreen(),
            ),
            // School-wide notification policy. Gated to roles holding
            // notification.manage_settings.
            GoRoute(
              path: 'school-settings',
              builder: (context, state) =>
                  const SchoolNotificationSettingsScreen(),
            ),
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddNotificationScreen(),
            ),
            GoRoute(
              path: 'add-announcement',
              builder: (context, state) =>
                  const AddNotificationScreen(isAnnouncement: true),
            ),
            GoRoute(
              path: 'attachments',
              builder: (context, state) {
                final attachments =
                    state.extra as List<NotificationAttachment>?;
                return AttachmentViewerScreen(attachments: attachments);
              },
            ),
            GoRoute(
              path: 'image-viewer',
              builder: (context, state) {
                final imageUrl = state.extra as String?;
                return ImageViewerScreen(imageUrl: imageUrl);
              },
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                // The list passes the notification as `extra` so the details
                // screen paints immediately. A push tapped from the system
                // tray has no `extra`, so that path loads by id instead -
                // previously this did a mockNotifications.firstWhere() with no
                // orElse, which threw on any real notification id.
                final notification = state.extra;
                if (notification is NotificationItem) {
                  return NotificationDetailsScreen(notification: notification);
                }
                return NotificationDetailsLoaderScreen(
                  notificationId: state.pathParameters['id'] ?? '',
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/staff/attendance',
          redirect: (context, state) {
            final auth = context.read<AuthBloc>().state;
            if (auth is! AuthAuthenticated) return '/welcome';
            const permitted = {
              UserRole.boardingMatron,
              UserRole.boardingPatron,
              UserRole.classTeacher,
              UserRole.subjectTeacher,
              ...UserRoleDisplay.adminConsoleRoles,
            };
            if (!auth.user.roles.any(permitted.contains)) {
              return UserRoleRouting.dashboardPath(auth.user.role);
            }
            return null;
          },
          builder: (context, state) => BlocProvider(
            create: (_) => di.sl<AttendanceBloc>(),
            child: const AttendanceMethodScreen(),
          ),
          routes: [
            GoRoute(
              path: 'nfc',
              builder: (context, state) => BlocProvider(
                create: (_) => di.sl<AttendanceBloc>(),
                child: attendance_hub.NfcScanScreen(
                  handoff: state.extra as AttendanceSessionHandoff?,
                ),
              ),
            ),
            // Legacy route kept as a redirect in case anything still links
            // here directly - the real NFC flow now lives entirely on the
            // 'nfc' route above (attendance_hub.NfcScanScreen).
            GoRoute(
              path: 'nfc-success',
              redirect: (context, state) => '/staff/attendance',
            ),
            GoRoute(
              path: 'qr',
              builder: (context, state) => BlocProvider(
                create: (_) => di.sl<AttendanceBloc>(),
                child: attendance_hub.QrScanScreen(
                  handoff: state.extra as AttendanceSessionHandoff?,
                ),
              ),
            ),
            // Legacy route kept as a redirect in case anything still links
            // here directly - the real QR flow now lives entirely on the
            // 'qr' route above (attendance_hub.QrScanScreen).
            GoRoute(
              path: 'qr-success',
              redirect: (context, state) => '/staff/attendance',
            ),
            GoRoute(
              path: 'manual',
              builder: (context, state) => BlocProvider(
                create: (_) => di.sl<AttendanceBloc>(),
                child: attendance_hub.ManualAttendanceScreen(
                  category:
                      (state.extra as AttendanceCategory?) ??
                      AttendanceCategory.students,
                ),
              ),
            ),
            GoRoute(
              path: 'summary',
              builder: (context, state) => const AttendanceSummaryScreen(),
            ),
            GoRoute(
              path: 'list',
              builder: (context, state) => const AttendanceListScreen(),
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) => BlocProvider(
                create: (_) => di.sl<AttendanceBloc>(),
                child: const attendance_hub.PreviousAttendanceScreen(),
              ),
            ),
            GoRoute(
              path: 'statistics',
              builder: (context, state) => BlocProvider(
                create: (_) => di.sl<AttendanceBloc>(),
                child: const attendance_hub.AttendanceStatisticsScreen(),
              ),
            ),
            GoRoute(
              path: 'sheets',
              builder: (context, state) =>
                  const attendance_hub.SheetsIntegrationScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/marks',
          builder: (context, state) => const MarksDashboardScreen(),
          routes: [
            GoRoute(
              path: 'select-assessment',
              builder: (context, state) => const SelectAssessmentScreen(),
            ),
            GoRoute(
              path: 'select-component',
              builder: (context, state) => const SelectComponentScreen(),
            ),
            GoRoute(
              path: 'enter',
              builder: (context, state) => const EnterMarksScreen(),
            ),
            GoRoute(
              path: 'review',
              builder: (context, state) => const ReviewSubmitScreen(),
            ),
            GoRoute(
              path: 'student/:id',
              builder: (context, state) => StudentMarksDetailScreen(
                studentId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: 'summary',
              builder: (context, state) => const ClassMarksSummaryScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              builder: (context, state) =>
                  EditMarksScreen(studentId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'import',
              builder: (context, state) => const ImportMarksScreen(),
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) => const MarksHistoryScreen(),
            ),
            GoRoute(
              path: 'analytics',
              builder: (context, state) => const MarksAnalyticsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/lessons',
          builder: (context, state) => const LessonsHomeScreen(),
          routes: [
            GoRoute(
              path: 'my-classes',
              builder: (context, state) => const MyClassesScreen(),
            ),
            GoRoute(
              path: 'class/:id',
              builder: (context, state) =>
                  ClassLessonsScreen(classId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'details/:id',
              builder: (context, state) =>
                  LessonDetailsScreen(lessonId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'attendance/:id',
              builder: (context, state) =>
                  TakeAttendanceScreen(lessonId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'notes/:id',
              builder: (context, state) =>
                  LessonNotesScreen(lessonId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'add-note/:id',
              builder: (context, state) =>
                  AddLessonNoteScreen(lessonId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'resources/:id',
              builder: (context, state) =>
                  LessonResourcesScreen(lessonId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/messages',
          builder: (context, state) => const MessagesListScreen(),
        ),
        GoRoute(
          path: '/staff/timetable',
          builder: (context, state) => const TeacherTimetableScreen(),
        ),
        GoRoute(
          path: '/staff/activities',
          builder: (context, state) => const ClassActivitiesScreen(),
        ),
        GoRoute(
          path: '/staff/work',
          builder: (context, state) => const WorkInboxScreen(),
        ),
        GoRoute(
          path: '/staff/school',
          builder: (context, state) => const SchoolWorkspaceScreen(),
        ),
        GoRoute(
          path: '/staff/more',
          // A nurse must never fall through to the shared admin/teacher More
          // route. Their portal owns its own navigation and More screen.
          redirect: (context, state) {
            final auth = context.read<AuthBloc>().state;
            if (auth is AuthAuthenticated && auth.user.role == UserRole.nurse) {
              return '/staff/nurse';
            }
            return null;
          },
          builder: (context, state) => const ProfileMoreScreen(),
          routes: [
            GoRoute(
              path: 'subjects',
              builder: (context, state) => const TeacherSubjectsScreen(),
            ),
            GoRoute(
              path: 'timetable',
              builder: (context, state) => const TeacherTimetableScreen(),
            ),
            GoRoute(
              path: 'reports',
              builder: (context, state) => const TeacherReportsScreen(),
            ),
            GoRoute(
              path: 'downloads',
              builder: (context, state) => const TeacherDownloadsScreen(),
            ),
            GoRoute(
              path: 'leave-requests',
              builder: (context, state) => const TeacherLeaveRequestsScreen(),
            ),
            GoRoute(
              path: 'edit-profile',
              builder: (context, state) => const EditProfileScreen(),
            ),
            GoRoute(
              path: 'personal-information',
              builder: (context, state) => const PersonalInformationScreen(),
            ),
            GoRoute(
              path: 'notification-preferences',
              builder: (context, state) =>
                  const NotificationPreferencesScreen(),
            ),
            GoRoute(
              path: 'attendance-settings',
              builder: (context, state) => const AttendanceSettingsScreen(),
            ),
            GoRoute(
              path: 'offline-data',
              builder: (context, state) => const OfflineDataScreen(),
            ),
            GoRoute(
              path: 'about',
              builder: (context, state) => const AboutSchoolPulseScreen(),
            ),
            GoRoute(
              path: 'security-privacy',
              builder: (context, state) => const SecurityPrivacyScreen(),
              routes: [
                GoRoute(
                  path: 'change-password',
                  builder: (context, state) => const ChangePasswordScreen(),
                ),
                GoRoute(
                  path: 'two-factor',
                  builder: (context, state) => const TwoFactorAuthScreen(),
                ),
                GoRoute(
                  path: 'active-sessions',
                  builder: (context, state) => const ActiveSessionsScreen(),
                ),
                GoRoute(
                  path: 'account-activity',
                  builder: (context, state) => const AccountActivityScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'school-directory',
              builder: (context, state) => const SchoolDirectoryScreen(),
            ),
            GoRoute(
              path: 'announcements',
              builder: (context, state) => const AnnouncementsScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const AnnouncementEditorScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => AnnouncementDetailScreen(
                    announcementId: state.pathParameters['id']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) => AnnouncementEditorScreen(
                        announcementId: state.pathParameters['id'],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: 'help-center',
              builder: (context, state) => const HelpCenterScreen(),
            ),
            GoRoute(
              path: 'terms-of-service',
              builder: (context, state) => const TermsOfServiceScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/homework',
          builder: (context, state) => const HomeworkScreen(),
        ),
        // The Class Teacher's own daily register - distinct from the shared
        // /staff/attendance method-chooser above, which every staff role
        // with any attendance duty (boarding matron/patron, admin) also
        // reaches and which is not scoped to one class. TeacherAttendanceScreen
        // and TeacherAttendanceHistoryScreen are wired to ClassAttendanceBloc /
        // ClassAttendanceHistoryBloc, so this route is what the dashboard's
        // Roll Call action and the Present/Absent tiles need to reach.
        GoRoute(
          path: '/staff/roll-call',
          builder: (context, state) => const TeacherAttendanceScreen(),
          routes: [
            GoRoute(
              path: 'history',
              builder: (context, state) =>
                  const TeacherAttendanceHistoryScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/staff/report-comments',
          builder: (context, state) => const ReportCommentsScreen(),
        ),
        GoRoute(
          path: '/staff/class-analytics',
          builder: (context, state) => const ClassAnalyticsScreen(),
        ),
        GoRoute(
          path: '/staff/calendar',
          builder: (context, state) => const CalendarHomeScreen(),
        ),
        GoRoute(
          path: '/staff/class-tasks',
          builder: (context, state) => const ClassTeacherTasksScreen(),
        ),
        GoRoute(
          path: '/staff/tasks',
          builder: (context, state) => const TaskListScreen(),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) => const CreateTaskScreen(),
            ),
            GoRoute(
              path: 'filter',
              builder: (context, state) => const TaskFilterScreen(),
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) => const TaskHistoryScreen(),
            ),
            GoRoute(
              path: 'reminders',
              builder: (context, state) => const TaskRemindersScreen(),
            ),
            GoRoute(
              path: 'edit/:id',
              builder: (context, state) =>
                  EditTaskScreen(taskId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'attachments/:id',
              builder: (context, state) =>
                  TaskAttachmentsScreen(taskId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'dormitory-assignment',
              builder: (context, state) =>
                  const TaskDormitoryAssignmentScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                final task = mockTasks.firstWhere((t) => t.id == id);
                return TaskDetailsScreen(task: task);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/staff/lesson-plans',
          builder: (context, state) => const LessonPlansScreen(),
        ),
        GoRoute(
          path: '/staff/resources',
          builder: (context, state) => const ResourcesHomeScreen(),
          routes: [
            GoRoute(
              path: 'my-resources',
              builder: (context, state) => const MyResourcesScreen(),
            ),
            GoRoute(
              path: 'upload',
              builder: (context, state) => const UploadResourceScreen(),
            ),
            GoRoute(
              path: 'create-folder',
              builder: (context, state) => const CreateFolderScreen(),
            ),
            GoRoute(
              path: 'details',
              builder: (context, state) => ResourceDetailsScreen(
                resource: state.extra as ClassResource?,
              ),
            ),
            GoRoute(
              path: 'share',
              builder: (context, state) =>
                  ShareResourceScreen(resource: state.extra as ClassResource?),
            ),
            GoRoute(
              path: 'folders',
              builder: (context, state) => const FoldersScreen(),
            ),
            GoRoute(
              path: 'add-link',
              builder: (context, state) => const AddLinkScreen(),
            ),
            GoRoute(
              path: 'categories',
              builder: (context, state) => const ResourceCategoriesScreen(),
            ),
            GoRoute(
              path: 'activity',
              builder: (context, state) => const RecentActivityScreen(),
            ),
            GoRoute(
              path: 'offline',
              builder: (context, state) => const OfflineResourcesScreen(),
            ),
            GoRoute(
              path: 'storage',
              builder: (context, state) => const StorageUsageScreen(),
            ),
          ],
        ),
      ],
    ),
    ShellRoute(
      // Messaging uses shared routes for every role. Keep the parent shell
      // around those shared subflows so selecting a contact, opening a chat,
      // or changing message settings never makes the parent navigation vanish.
      builder: (context, state, child) => _messagingShell(context, child),
      routes: [
        GoRoute(
          path: '/messages',
          builder: (context, state) => const MessagesListScreen(),
          routes: [
            GoRoute(
              path: 'search',
              builder: (context, state) => const SearchMessagesScreen(),
            ),
            GoRoute(
              path: 'requests',
              builder: (context, state) => const MessageRequestsScreen(),
            ),
            GoRoute(
              path: 'archived',
              builder: (context, state) => const ArchivedChatsScreen(),
            ),
            GoRoute(
              path: 'starred',
              builder: (context, state) => const StarredMessagesScreen(),
            ),
            GoRoute(
              path: 'pinned',
              builder: (context, state) => const PinnedMessagesScreen(),
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const ChatSettingsScreen(),
            ),
            GoRoute(
              path: 'broadcast/:id',
              builder: (context, state) => BroadcastDetailsScreen(
                broadcastId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: 'new',
              builder: (context, state) => const NewMessageTypeScreen(),
              routes: [
                GoRoute(
                  path: 'contacts',
                  builder: (context, state) => const SelectContactsScreen(),
                ),
                GoRoute(
                  path: 'group',
                  builder: (context, state) =>
                      const SelectContactsScreen(isGroupSelection: true),
                  routes: [
                    // Shared by the group, broadcast and channel flows - which
                    // one is being created travels in the NewConversationDraft.
                    GoRoute(
                      path: 'details',
                      builder: (context, state) => NewGroupDetailsScreen(
                        draft: state.extra as NewConversationDraft?,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'broadcast',
                  builder: (context, state) => const SelectContactsScreen(
                    isGroupSelection: true,
                    conversationType: ChatType.broadcast,
                  ),
                ),
                GoRoute(
                  path: 'channel',
                  builder: (context, state) => const SelectContactsScreen(
                    isGroupSelection: true,
                    conversationType: ChatType.channel,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: 'chat/:chatId',
              builder: (context, state) => ChatConversationScreen(
                chatId: state.pathParameters['chatId']!,
              ),
              routes: [
                GoRoute(
                  path: 'info',
                  builder: (context, state) =>
                      ChatInfoScreen(chatId: state.pathParameters['chatId']!),
                ),
                GoRoute(
                  path: 'media',
                  builder: (context, state) => MediaLinksDocsScreen(
                    chatId: state.pathParameters['chatId']!,
                  ),
                ),
                GoRoute(
                  path: 'profile',
                  builder: (context, state) => ContactProfileScreen(
                    contactId: state.pathParameters['chatId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // Deliberately outside every ShellRoute above - the owner console has
    // its own complete navigation (sidebar on wide, bottom nav on mobile)
    // and must never be wrapped in StaffShell's staff-facing bottom nav.
    GoRoute(
      path: '/super-admin',
      builder: (context, state) => const SuperAdminDashboard(),
      routes: [
        // Top-level sidebar/bottom-nav sections. Each renders the same
        // SuperAdminDashboard, which reads the active section back out of
        // the URL (see `_sectionIndexForLocation` in super_admin_dashboard
        // .dart) - giving every section its own real, refreshable,
        // back/forward-able address without duplicating the dashboard's
        // IndexedStack/nested-Navigator shell per route.
        //
        // Detail screens (School Details, Application Review, Payment
        // Review) are deliberately NOT full GoRoutes: they're pushed onto
        // the section's own nested Navigator (SuperAdminTabNavigator) so
        // the sidebar/bottom-nav stays visible, exactly as before this
        // change. Their :id child routes below exist only so the URL bar
        // reflects that a detail screen is open and Back/Forward has a
        // history entry to land on - navigating to one directly (no
        // `extra`, e.g. a cold refresh) falls back to the section list,
        // since there is no fetch-by-id path yet for these entities.
        GoRoute(
          path: 'schools',
          builder: (context, state) => const SuperAdminDashboard(),
          routes: [
            GoRoute(
              path: ':schoolId',
              builder: (context, state) => const SuperAdminDashboard(),
            ),
            GoRoute(
              path: 'applications/:applicationId',
              builder: (context, state) => const SuperAdminDashboard(),
            ),
          ],
        ),
        GoRoute(
          path: 'payments',
          builder: (context, state) => const SuperAdminDashboard(),
          routes: [
            GoRoute(
              path: ':paymentId',
              builder: (context, state) => const SuperAdminDashboard(),
            ),
          ],
        ),
        GoRoute(
          path: 'plans',
          builder: (context, state) => const SuperAdminDashboard(),
        ),
        GoRoute(
          path: 'notifications',
          builder: (context, state) => const SuperAdminDashboard(),
        ),
        GoRoute(
          path: 'audit-logs',
          builder: (context, state) => const SuperAdminDashboard(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SuperAdminDashboard(),
        ),
        GoRoute(
          path: 'settings/notifications',
          builder: (context, state) => const SuperAdminMobileNavShell(
            child: SuperAdminNotificationsScreen(),
          ),
          routes: [
            GoRoute(
              path: 'preferences',
              builder: (context, state) => const SuperAdminMobileNavShell(
                child: OwnerNotificationPreferencesScreen(),
              ),
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) => const SuperAdminMobileNavShell(
                child: OwnerNotificationHistoryScreen(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'settings/security',
          builder: (context, state) =>
              const SuperAdminMobileNavShell(child: SecurityCenterScreen()),
        ),
        GoRoute(
          path: 'settings/support',
          builder: (context, state) =>
              const SuperAdminMobileNavShell(child: HelpSupportHomeScreen()),
          routes: [
            GoRoute(
              path: 'help-center',
              builder: (context, state) => const SuperAdminMobileNavShell(
                child: SupportHelpCenterScreen(),
              ),
            ),
            GoRoute(
              path: 'faqs',
              builder: (context, state) =>
                  const SuperAdminMobileNavShell(child: SupportFaqsScreen()),
            ),
            GoRoute(
              path: 'new',
              builder: (context, state) => SuperAdminMobileNavShell(
                child: SubmitSupportRequestScreen(
                  args:
                      state.extra as SubmitSupportRequestArgs? ??
                      const SubmitSupportRequestArgs(origin: 'submit_request'),
                ),
              ),
            ),
            GoRoute(
              path: 'ticket/:id',
              builder: (context, state) => SuperAdminMobileNavShell(
                child: SupportTicketConversationScreen(
                  ticketId: state.pathParameters['id']!,
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'settings/about',
          builder: (context, state) =>
              const SuperAdminMobileNavShell(child: ContactAboutScreen()),
          routes: [
            GoRoute(
              path: 'privacy-policy',
              builder: (context, state) =>
                  const SuperAdminMobileNavShell(child: PrivacyPolicyScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
);

Widget _messagingShell(BuildContext context, Widget child) {
  final authState = context.read<AuthBloc>().state;
  if (authState is AuthAuthenticated &&
      authState.user.roles.contains(UserRole.parent)) {
    // Web Parent Portal is online-only; mobile instead gets the local
    // PIN/biometric re-entry gate so setup-completed parents can reopen the
    // portal offline. See ParentWebOnlineGate / ParentOfflineGate docs.
    final shell = ParentShell(child: child);
    return kIsWeb
        ? ParentWebOnlineGate(child: shell)
        : ParentOfflineGate(child: shell);
  }
  return child;
}

class ParentShell extends StatelessWidget {
  final Widget child;
  const ParentShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/parent/home')) return 0;
    if (location.startsWith('/parent/learn')) return 1;
    if (location.startsWith('/parent/messages')) return 2;
    if (location.startsWith('/messages')) return 2;
    if (location.startsWith('/parent/payments')) return 3;
    if (location.startsWith('/parent/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/parent/home');
        break;
      case 1:
        context.go('/parent/learn');
        break;
      case 2:
        context.go('/parent/messages');
        break;
      case 3:
        context.go('/parent/payments');
        break;
      case 4:
        context.go('/parent/profile');
        break;
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutPressed());
              Navigator.pop(context);
              context.go('/welcome');
            },
            child: Text(
              'Logout',
              style: TextStyle(color: AppColors.danger(context)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedIconColor = AppColors.textPrimary(context);
    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_rounded),
        selectedIcon: Icon(Icons.home_rounded, color: selectedIconColor),
        label: 'Home',
      ),
      NavigationDestination(
        icon: const Icon(Icons.auto_stories_outlined),
        selectedIcon: Icon(Icons.auto_stories, color: selectedIconColor),
        label: 'Academics',
      ),
      NavigationDestination(
        icon: const MessagesNavIcon(icon: Icons.chat_bubble_outline_rounded),
        selectedIcon: MessagesNavIcon(
          icon: Icons.chat_bubble_rounded,
          color: selectedIconColor,
        ),
        label: 'Messages',
      ),
      NavigationDestination(
        icon: const Icon(Icons.account_balance_wallet_rounded),
        selectedIcon: Icon(
          Icons.account_balance_wallet_rounded,
          color: selectedIconColor,
        ),
        label: 'Fees',
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded, color: selectedIconColor),
        label: 'Profile',
      ),
    ];

    return BlocProvider(
      create: (_) {
        final authState = context.read<AuthBloc>().state;
        return ParentAccessCubit(
          getRelationshipsForParent: di.sl(),
          getPeoplePolicy: di.sl(),
          structureRepository: di.sl(),
          parentUserId: authState is AuthAuthenticated ? authState.user.id : '',
          selectedStudentBloc: context.read<SelectedStudentBloc>(),
          resolver: di.sl(),
        );
      },
      child: _buildScaffold(context, isMobile, isDark, destinations),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    bool isMobile,
    bool isDark,
    List<NavigationDestination> destinations,
  ) {
    return Scaffold(
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: MediaQuery.of(context).size.width > 1200 ? 280 : 80,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                border: Border(
                  right: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow(context),
                    blurRadius: 20,
                    offset: const Offset(5, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.x4l,
                    ),
                    child: PulseLogo(
                      size: 40,
                      variant: MediaQuery.of(context).size.width > 1200
                          ? PulseLogoVariant.full
                          : PulseLogoVariant.shield,
                    ),
                  ),
                  Expanded(
                    child: NavigationRail(
                      backgroundColor: Colors.transparent,
                      extended: MediaQuery.of(context).size.width > 1200,
                      selectedIndex: _calculateSelectedIndex(context),
                      onDestinationSelected: (idx) =>
                          _onItemTapped(idx, context),
                      minExtendedWidth: 280,
                      labelType: MediaQuery.of(context).size.width > 1200
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      unselectedLabelTextStyle: AppTypography.labelMedium
                          .copyWith(
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                      selectedLabelTextStyle: AppTypography.labelMedium
                          .copyWith(
                            color: AppColors.primary(context),
                            fontWeight: FontWeight.bold,
                          ),
                      destinations: destinations
                          .map(
                            (d) => NavigationRailDestination(
                              icon: d.icon,
                              selectedIcon: d.selectedIcon,
                              label: Text(d.label),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.m,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.x3l),
                    child: _LogoutButton(
                      onPressed: () => _handleLogout(context),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              color: AppColors.background(context),
              child: child,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile
          ? Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow(context),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    final selected = states.contains(WidgetState.selected);
                    return AppTypography.labelSmall.copyWith(
                      color: selected
                          ? AppColors.textPrimary(context)
                          : AppColors.textMuted(context),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    );
                  }),
                ),
                child: NavigationBar(
                  height: 64,
                  backgroundColor: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight,
                  indicatorColor: AppColors.surfaceContainerHigh(context),
                  selectedIndex: _calculateSelectedIndex(context),
                  onDestinationSelected: (idx) => _onItemTapped(idx, context),
                  destinations: destinations,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                ),
              ),
            )
          : null,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isExtended = MediaQuery.of(context).size.width > 1200;

    if (isExtended) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.logout_rounded, color: AppColors.black),
          label: Text(
            'Logout',
            style: AppTypography.labelLarge.copyWith(color: AppColors.black),
          ),
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.logout_rounded, color: AppColors.black),
      onPressed: onPressed,
      tooltip: 'Logout',
    );
  }
}
