import 'package:school_pulse/features/admin/domain/repositories/role_permission_override_repository.dart';
import 'package:school_pulse/features/relationships/data/datasources/relationship_remote_data_source.dart';
import 'package:school_pulse/features/relationships/data/repositories/relationship_repository_impl.dart';
import 'package:school_pulse/features/relationships/domain/repositories/relationship_repository.dart';
import 'package:school_pulse/features/relationships/domain/usecases/create_relationship.dart';
import 'package:school_pulse/features/relationships/domain/usecases/get_people_policy.dart';
import 'package:school_pulse/features/relationships/domain/usecases/get_relationships_for_parent.dart';
import 'package:school_pulse/features/relationships/domain/usecases/get_relationships_for_student.dart';
import 'package:school_pulse/features/relationships/domain/usecases/reallocate_relationship.dart';
import 'package:school_pulse/features/relationships/domain/usecases/record_enrolment_change.dart';
import 'package:school_pulse/features/relationships/domain/usecases/update_people_policy.dart';
import 'package:school_pulse/features/parent_access/domain/services/parent_module_resolver.dart';
import 'package:school_pulse/features/admin/data/repositories/role_permission_override_repository_impl.dart';
import 'package:school_pulse/features/admin/domain/usecases/get_role_permission_overrides.dart';
import 'package:school_pulse/features/admin/domain/usecases/save_role_permission_override.dart';
import 'package:school_pulse/features/institution/data/datasources/institution_context_remote_datasource.dart';
import 'package:school_pulse/features/institution/data/repositories/institution_context_repository_impl.dart';
import 'package:school_pulse/features/institution/domain/repositories/institution_context_repository.dart';
import 'package:school_pulse/features/institution/presentation/bloc/institution_context_cubit.dart';
import 'package:school_pulse/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:school_pulse/features/appointments/domain/usecases/appointment_usecases.dart'
    hide GetStudentsByIds;
import 'package:school_pulse/features/appointments/domain/usecases/appointment_usecases.dart'
    as appointments_usecases
    show GetStudentsByIds;
import 'package:school_pulse/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:school_pulse/features/appointments/data/datasources/appointment_remote_data_source.dart';
import 'package:school_pulse/features/appointments/presentation/bloc/appointment_settings_bloc.dart';
import 'package:school_pulse/features/appointments/presentation/bloc/appointment_action_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:isar/isar.dart';
import 'package:school_pulse/core/platform/isar_bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_pulse/core/access/effective_access_resolver.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/core/services/printer/printer_service.dart';
import 'package:school_pulse/features/gate_ops/domain/repositories/gate_ops_repository.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/watch_gates.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/record_movement_event.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/watch_movement_events.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/check_in_visitor.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/check_out_visitor.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/watch_visitors.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/report_incident.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/trigger_emergency.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/resolve_emergency.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/watch_active_emergencies.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/get_gate_ops_dashboard_stats.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/get_pickup_authorizations.dart';
import 'package:school_pulse/features/gate_ops/domain/usecases/add_pickup_authorization.dart';
import 'package:school_pulse/features/gate_ops/data/sync/movement_sync_engine.dart';
import 'package:school_pulse/features/gate_ops/data/repositories/gate_ops_repository_impl.dart';
import 'package:school_pulse/features/gate_ops/data/datasources/gate_ops_remote_data_source.dart';
import 'package:school_pulse/features/gate_ops/data/datasources/gate_ops_local_data_source.dart';
import 'package:school_pulse/features/gate_ops/data/datasources/gate_ops_local_data_source_factory.dart';
import 'package:school_pulse/features/gate_ops/domain/policies/movement_verification_policy.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:school_pulse/features/super_admin/data/datasources/security_settings_remote_data_source.dart';
import 'package:school_pulse/features/super_admin/data/datasources/owner_session_remote_data_source.dart';
import 'package:school_pulse/core/utils/device_info_service.dart';
import 'package:school_pulse/core/utils/biometric_auth_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:school_pulse/features/attendance_qr_integration/domain/repositories/attendance_qr_repository.dart';
import 'package:school_pulse/features/attendance_qr_integration/data/repositories/attendance_qr_repository_factory.dart';
import 'package:school_pulse/features/attendance_qr_integration/presentation/bloc/attendance_qr_bloc.dart';
import 'package:school_pulse/features/student_identity/data/repositories/student_identity_local_cache_factory.dart';
import 'package:school_pulse/features/inventory/data/datasources/stores_assets_local_data_source_factory.dart';
import 'package:school_pulse/features/library/data/datasources/local/library_local_data_source_factory.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/data/branding_local_cache_factory.dart';
import 'package:school_pulse/features/branding/domain/usecases/get_school_branding.dart';

import 'package:school_pulse/features/messages/domain/repositories/messages_repository.dart';
import 'package:school_pulse/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_bloc.dart';
import 'package:school_pulse/features/teacher/domain/usecases/generate_reports.dart';
import 'package:school_pulse/features/finance/domain/services/finance_service.dart';
import 'package:school_pulse/features/student/domain/services/admission_service.dart';
import 'package:school_pulse/features/student/domain/services/document_service.dart';
import 'package:school_pulse/features/student/domain/services/parent_linking_service.dart';
import 'package:school_pulse/features/student/domain/services/promotion_service.dart';
import 'package:school_pulse/features/student/domain/services/student_service.dart';
import 'package:school_pulse/features/finance/domain/usecases/initialize_student_financials.dart';

import 'package:school_pulse/features/admin/domain/repositories/admin_attendance_repository.dart';
import 'package:school_pulse/features/admin/data/repositories/admin_attendance_repository_impl.dart';

// Super Admin
import 'package:school_pulse/features/super_admin/domain/repositories/super_admin_repository.dart';
import 'package:school_pulse/features/subscription_payment/data/repositories/subscription_payment_repository_impl.dart';
import 'package:school_pulse/features/subscription_payment/domain/repositories/subscription_payment_repository.dart';
import 'package:school_pulse/features/subscription_payment/presentation/bloc/subscription_payment_cubit.dart';
import 'package:school_pulse/features/super_admin/data/repositories/super_admin_repository_impl.dart';
import 'package:school_pulse/features/super_admin/data/datasources/super_admin_remote_datasource.dart';
import 'package:school_pulse/features/super_admin/presentation/bloc/super_admin_bloc.dart';

// Admin / System Config
import 'package:school_pulse/features/admin/data/repositories/system_config_repository.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_bloc.dart';

// Exams/Assessment
import 'package:school_pulse/features/exams/domain/repositories/assessment_repository.dart';
import 'package:school_pulse/features/exams/data/repositories/assessment_repository_impl.dart';
import 'package:school_pulse/features/exams/data/datasources/assessment_remote_data_source.dart';
import 'package:school_pulse/features/exams/presentation/bloc/assessment_bloc.dart';

// Exams (dashboard)
import 'package:school_pulse/features/exams/domain/repositories/exams_repository.dart';
import 'package:school_pulse/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:school_pulse/features/exams/data/datasources/exams_remote_data_source.dart';
import 'package:school_pulse/features/exams/presentation/bloc/exams_bloc.dart';

// Academic
import 'package:school_pulse/features/academic/domain/repositories/academic_repository.dart';
import 'package:school_pulse/features/academic/data/repositories/academic_repository_impl.dart';
import 'package:school_pulse/features/academic/data/datasources/academic_remote_data_source.dart';
import 'package:school_pulse/features/academic/domain/usecases/get_academic_records.dart';
import 'package:school_pulse/features/academic/domain/usecases/get_attendance_records.dart';
import 'package:school_pulse/features/academic/domain/usecases/manage_report_cards.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';

// Auth
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:school_pulse/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_owner.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_with_email.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_parent.dart';
import 'package:school_pulse/features/auth/domain/usecases/enter_support_mode.dart';
import 'package:school_pulse/features/auth/domain/usecases/exit_support_mode.dart';
import 'package:school_pulse/features/auth/domain/usecases/complete_parent_pin_setup.dart';
import 'package:school_pulse/features/auth/domain/usecases/logout.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_current_user.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';

// Student
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student/data/repositories/student_repository_impl.dart';
import 'package:school_pulse/features/student/data/datasources/student_remote_data_source.dart';
import 'package:school_pulse/features/student/data/datasources/student_local_data_source.dart';
import 'package:school_pulse/features/student/data/datasources/student_local_data_source_factory.dart';
import 'package:school_pulse/features/student/domain/usecases/create_student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_students_by_ids.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'package:school_pulse/features/student/domain/usecases/get_homework_for_student.dart';
import 'package:school_pulse/features/student/domain/usecases/search_students.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/student_homework_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/admission_bloc.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/student_identity/data/repositories/student_identity_repository_impl.dart';
import 'package:school_pulse/features/student_identity/presentation/bloc/student_identity_bloc.dart';
import 'package:school_pulse/features/student_identity/domain/services/id_card_service.dart';
import 'package:school_pulse/features/auth/domain/services/staff_id_card_service.dart';
import 'package:school_pulse/features/student_identity/domain/services/id_generator_service.dart';
import 'package:school_pulse/features/student_identity/domain/services/nfc_credential_service.dart';

// Admin Dashboard
import 'package:school_pulse/features/admin/domain/usecases/get_admin_dashboard_stats.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_bloc.dart';

// Calendar
import 'package:school_pulse/features/school_calendar/domain/repositories/school_calendar_repository.dart';
import 'package:school_pulse/features/school_calendar/data/repositories/school_calendar_repository_impl.dart';
import 'package:school_pulse/features/school_calendar/data/datasources/school_calendar_remote_data_source.dart';
import 'package:school_pulse/features/school_calendar/presentation/bloc/school_calendar_bloc.dart';

// Announcements
import 'package:school_pulse/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:school_pulse/features/announcements/data/repositories/announcement_repository_impl.dart';
import 'package:school_pulse/features/announcements/data/datasources/announcement_remote_data_source.dart';
import 'package:school_pulse/features/announcements/presentation/bloc/announcement_bloc.dart';

// School Directory
import 'package:school_pulse/features/school_directory/domain/repositories/school_directory_repository.dart';
import 'package:school_pulse/features/school_directory/data/repositories/school_directory_repository_impl.dart';
import 'package:school_pulse/features/school_directory/data/datasources/school_directory_remote_data_source.dart';
import 'package:school_pulse/features/school_directory/presentation/bloc/school_directory_bloc.dart';
import 'package:school_pulse/features/attendance_hub/presentation/bloc/attendance_bloc.dart';
import 'package:school_pulse/features/attendance_hub/domain/repositories/attendance_repository.dart';
import 'package:school_pulse/features/attendance_hub/data/repositories/attendance_repository_impl.dart';
import 'package:school_pulse/features/attendance_hub/data/datasources/attendance_remote_data_source.dart';
import 'package:school_pulse/features/attendance_hub/domain/services/attendance_participant_resolver.dart';
import 'package:school_pulse/features/attendance_hub/domain/services/attendance_participant_resolver_impl.dart';
import 'package:school_pulse/features/attendance_hub/domain/repositories/sheets_integration_repository.dart';
import 'package:school_pulse/features/attendance_hub/data/repositories/sheets_integration_repository_impl.dart';
import 'package:school_pulse/features/attendance_hub/data/datasources/sheets_integration_remote_data_source.dart';

// Catering
import 'package:school_pulse/features/catering/domain/repositories/catering_repository.dart';
import 'package:school_pulse/features/catering/domain/services/catering_eligibility_service.dart';
import 'package:school_pulse/features/catering/data/repositories/catering_repository_impl.dart';
import 'package:school_pulse/features/catering/data/datasources/catering_remote_data_source.dart';
import 'package:school_pulse/features/catering/data/datasources/catering_local_data_source.dart';
import 'package:school_pulse/features/catering/presentation/bloc/catering_bloc.dart';
import 'package:school_pulse/features/catering/data/datasources/catering_local_data_source_factory.dart';

// Dean
import 'package:school_pulse/features/dean/domain/repositories/dean_repository.dart';
import 'package:school_pulse/features/dean/data/repositories/dean_repository_impl.dart';
import 'package:school_pulse/features/dean/data/datasources/dean_remote_data_source.dart';
import 'package:school_pulse/features/dean/domain/usecases/get_dean_stats.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';

// Director
import 'package:school_pulse/features/director/presentation/bloc/director_bloc.dart';

// Discipline
import 'package:school_pulse/features/discipline/domain/repositories/discipline_repository.dart';
import 'package:school_pulse/features/discipline/data/repositories/discipline_repository_impl.dart';
import 'package:school_pulse/features/discipline/data/datasources/discipline_remote_data_source.dart';
import 'package:school_pulse/features/discipline/domain/usecases/get_discipline_incidents.dart';
import 'package:school_pulse/features/discipline/domain/usecases/get_recent_discipline_incidents.dart';
import 'package:school_pulse/features/discipline/domain/usecases/log_discipline_incident.dart';
import 'package:school_pulse/features/discipline/domain/usecases/get_counseling_sessions.dart';
import 'package:school_pulse/features/discipline/domain/usecases/log_counseling_session.dart';
import 'package:school_pulse/features/discipline/presentation/bloc/discipline_bloc.dart';

// Finance
import 'package:school_pulse/features/finance/domain/repositories/finance_repository.dart';
import 'package:school_pulse/features/finance/domain/services/bursar_student_projection_service.dart';
import 'package:school_pulse/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:school_pulse/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';

// Games
import 'package:school_pulse/features/games/domain/repositories/games_repository.dart';
import 'package:school_pulse/features/games/data/repositories/games_repository_impl.dart';
import 'package:school_pulse/features/games/data/datasources/games_remote_data_source.dart';
import 'package:school_pulse/features/games/presentation/bloc/games_bloc.dart';

// Health
import 'package:school_pulse/features/health/domain/repositories/health_repository.dart';
import 'package:school_pulse/features/health/data/repositories/health_repository_impl.dart';
import 'package:school_pulse/features/health/data/datasources/health_remote_data_source.dart';
import 'package:school_pulse/features/health/domain/usecases/health_usecases.dart';
import 'package:school_pulse/features/health/domain/services/nurse_student_projection_service.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';

// HR
import 'package:school_pulse/features/hr/domain/repositories/hr_repository.dart';
import 'package:school_pulse/features/hr/data/repositories/hr_repository_impl.dart';
import 'package:school_pulse/features/hr/data/datasources/hr_remote_data_source.dart';
import 'package:school_pulse/features/hr/presentation/bloc/hr_bloc.dart';

// Inventory
import 'package:school_pulse/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:school_pulse/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:school_pulse/features/inventory/data/datasources/inventory_remote_data_source.dart';
import 'package:school_pulse/features/inventory/domain/usecases/get_inventory_items.dart';
import 'package:school_pulse/features/inventory/domain/usecases/get_recent_movements.dart';
import 'package:school_pulse/features/inventory/domain/usecases/add_stock.dart';
import 'package:school_pulse/features/inventory/domain/usecases/issue_item.dart';
import 'package:school_pulse/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:school_pulse/features/inventory/domain/repositories/stores_assets_repository.dart';
import 'package:school_pulse/features/inventory/data/repositories/stores_assets_repository_impl.dart';
import 'package:school_pulse/features/inventory/data/datasources/stores_assets_local_data_source.dart';
import 'package:school_pulse/features/inventory/data/datasources/stores_assets_remote_data_source.dart';
import 'package:school_pulse/features/inventory/presentation/bloc/stores_assets_bloc.dart';

// Library
import 'package:school_pulse/features/library/domain/repositories/library_repository.dart';
import 'package:school_pulse/features/library/domain/services/library_eligibility_service.dart';
import 'package:school_pulse/features/library/data/repositories/library_repository_impl.dart';
import 'package:school_pulse/features/library/data/datasources/library_remote_data_source.dart';
import 'package:school_pulse/features/library/data/datasources/local/library_local_data_source.dart';
import 'package:school_pulse/features/library/presentation/bloc/library_bloc.dart';

// Matron
import 'package:school_pulse/features/matron/domain/repositories/matron_repository.dart';
import 'package:school_pulse/features/matron/data/repositories/matron_repository_impl.dart';
import 'package:school_pulse/features/matron/data/sources/matron_remote_data_source.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';

// Patron
import 'package:school_pulse/features/patron/domain/repositories/patron_repository.dart';
import 'package:school_pulse/features/patron/data/repositories/patron_repository_impl.dart';
import 'package:school_pulse/features/patron/data/sources/patron_remote_data_source.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';

// Notifications
import 'package:school_pulse/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:school_pulse/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:school_pulse/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:school_pulse/features/notifications/domain/usecases/get_alerts.dart';
import 'package:school_pulse/features/notifications/domain/usecases/mark_alert_read.dart';
import 'package:school_pulse/features/notifications/domain/usecases/send_notification.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notifications_bloc.dart';

// Religion
import 'package:school_pulse/features/religion/domain/repositories/religion_repository.dart';
import 'package:school_pulse/features/religion/data/repositories/religion_repository_impl.dart';
import 'package:school_pulse/features/religion/data/datasources/religion_remote_data_source.dart';
import 'package:school_pulse/features/religion/presentation/bloc/religion_bloc.dart';

// Teacher
import 'package:school_pulse/features/teacher/domain/repositories/teacher_repository.dart';
import 'package:school_pulse/features/teacher/data/repositories/teacher_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/datasources/teacher_remote_data_source.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_students_by_class.dart';
import 'package:school_pulse/features/teacher/domain/usecases/submit_attendance.dart';
import 'package:school_pulse/features/teacher/domain/usecases/submit_marks.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_attendance_history.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_teacher_dashboard_stats.dart';
import 'package:school_pulse/features/teacher/domain/usecases/manage_homework.dart';
import 'package:school_pulse/features/teacher/domain/usecases/manage_report_comments.dart';
import 'package:school_pulse/features/teacher/domain/usecases/manage_competency_ratings.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';

// Subject Teacher panel
import 'package:school_pulse/features/teacher/data/datasources/subject_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/subject_teacher_remote_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_local_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_remote_data_source.dart';
import 'package:school_pulse/features/teacher/data/datasources/class_teacher_local_data_source_factory.dart';
import 'package:school_pulse/features/teacher/data/datasources/subject_teacher_local_data_source_factory.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_attendance_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_communication_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_performance_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_report_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_resource_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_task_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_work_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_dashboard_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/repositories/class_student_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/repositories/lesson_attendance_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/repositories/lesson_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/repositories/marks_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/repositories/staff_assignment_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/repositories/subject_student_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/services/academic_calendar_service_impl.dart';
import 'package:school_pulse/features/teacher/data/services/active_responsibility_service_impl.dart';
import 'package:school_pulse/features/teacher/data/services/class_teacher_assignment_service_impl.dart';
import 'package:school_pulse/features/teacher/data/services/subject_audit_service_impl.dart';
import 'package:school_pulse/features/teacher/data/services/subject_sync_service_impl.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_attendance_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_communication_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_performance_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_report_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_resource_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_task_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_work_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_dashboard_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_student_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/lesson_attendance_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/lesson_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/marks_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/staff_assignment_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/subject_student_repository.dart';
import 'package:school_pulse/features/teacher/domain/services/academic_calendar_service.dart';
import 'package:school_pulse/features/teacher/domain/services/active_responsibility_service.dart';
import 'package:school_pulse/features/teacher/domain/services/class_teacher_assignment_service.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_audit_service.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_sync_service.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_dashboard/class_teacher_dashboard_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_attendance/class_attendance_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_attendance/class_attendance_history_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_students/class_students_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_announcements/class_announcements_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_performance/class_performance_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_reports/class_reports_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_tasks/class_tasks_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_work/class_work_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_resources/class_resource_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_dashboard/subject_teacher_dashboard_bloc.dart';

// Transport
import 'package:school_pulse/features/transport/domain/repositories/transport_repository.dart';
import 'package:school_pulse/features/transport/domain/services/transport_student_projection_service.dart';
import 'package:school_pulse/features/transport/data/repositories/transport_repository_impl.dart';
import 'package:school_pulse/features/transport/data/datasources/transport_remote_data_source.dart';
import 'package:school_pulse/features/transport/domain/usecases/get_transport_info.dart';
import 'package:school_pulse/features/transport/presentation/bloc/transport_bloc.dart';

// Lesson Plans
import 'package:school_pulse/features/lesson_plans/domain/repositories/lesson_plans_repository.dart';
import 'package:school_pulse/features/lesson_plans/data/repositories/lesson_plans_repository_impl.dart';
import 'package:school_pulse/features/lesson_plans/data/datasources/lesson_plans_remote_data_source.dart';
import 'package:school_pulse/features/lesson_plans/domain/usecases/add_lesson_plan.dart';
import 'package:school_pulse/features/lesson_plans/domain/usecases/get_lesson_plans.dart';

// Admin - Access Codes (part of Student feature)
import 'package:school_pulse/features/student/domain/usecases/manage_parent_access_codes.dart';

// Admin - Staff Accounts (part of Auth feature)
import 'package:school_pulse/features/auth/domain/usecases/create_staff_account.dart';
import 'package:school_pulse/features/auth/domain/usecases/admin_reset_staff_password.dart';
import 'package:school_pulse/features/auth/domain/usecases/delete_staff_member.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/domain/usecases/set_new_password.dart';
import 'package:school_pulse/features/auth/domain/usecases/toggle_staff_status.dart';
import 'package:school_pulse/features/auth/domain/usecases/update_staff_member.dart';

// Admin - Staff Attendance / Subscription (self-contained Firestore repos)
import 'package:school_pulse/features/admin/data/repositories/staff_attendance_repository.dart';
import 'package:school_pulse/features/admin/data/repositories/subscription_repository.dart';

// Structure module
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/structure/domain/services/structure_dependency_service.dart';
import 'package:school_pulse/features/structure/data/repositories/structure_repository_impl.dart';
import 'package:school_pulse/features/structure/data/datasources/structure_remote_data_source.dart';
import 'package:school_pulse/features/structure/data/datasources/structure_local_data_source.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/role_assignment_cubit.dart';
import 'package:school_pulse/features/structure/data/datasources/structure_local_data_source_factory.dart';
import 'package:school_pulse/features/structure/domain/services/structure_configuration_service.dart';
import 'package:school_pulse/features/structure/data/services/structure_configuration_service_impl.dart';
import 'package:school_pulse/features/structure/domain/repositories/timetable_repository.dart';
import 'package:school_pulse/features/structure/data/repositories/timetable_repository_impl.dart';
import 'package:school_pulse/features/structure/data/datasources/timetable_remote_data_source.dart';
import 'package:school_pulse/features/structure/domain/services/timetable_conflict_resolver.dart';
import 'package:school_pulse/features/structure/presentation/bloc/timetable_bloc.dart';

// Finance - additional usecases
import 'package:school_pulse/features/finance/domain/usecases/get_all_fees.dart';
import 'package:school_pulse/features/finance/domain/usecases/get_all_payment_history.dart';
import 'package:school_pulse/features/finance/domain/usecases/process_payment.dart';

// Library - additional usecases
import 'package:school_pulse/features/library/domain/usecases/get_all_borrowed_books.dart';
import 'package:school_pulse/features/library/domain/usecases/issue_book.dart';
import 'package:school_pulse/features/library/domain/usecases/return_book.dart';

import 'package:school_pulse/features/biometrics/domain/repositories/biometric_repository.dart';
import 'package:school_pulse/features/biometrics/domain/repositories/biometric_device_service.dart';
import 'package:school_pulse/features/biometrics/data/repositories/biometric_repository_impl.dart';
import 'package:school_pulse/features/biometrics/data/datasources/biometric_remote_data_source.dart';
import 'package:school_pulse/features/biometrics/data/datasources/biometric_local_data_source.dart';
import 'package:school_pulse/features/biometrics/data/datasources/mock_biometric_device_service.dart';
import 'package:school_pulse/features/biometrics/domain/usecases/biometric_usecases.dart';
import 'package:school_pulse/features/biometrics/presentation/bloc/biometrics_bloc.dart';
import 'package:school_pulse/features/biometrics/data/datasources/biometric_local_data_source_factory.dart';
import 'package:school_pulse/features/notifications/data/datasources/notification_local_data_source_factory.dart';
import 'package:school_pulse/features/notifications/domain/repositories/notification_repository.dart';
import 'package:school_pulse/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:school_pulse/features/notifications/data/datasources/notification_local_data_source.dart';
import 'package:school_pulse/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notification_center_bloc.dart';
import 'package:school_pulse/app/router.dart' as app_router;
import 'package:school_pulse/features/notifications/notification_coordinator.dart';
import 'package:school_pulse/features/notifications/push/handlers/notification_push_handler.dart';
import 'package:school_pulse/features/notifications/routing/deep_link_router/notification_deep_link_router.dart';
import 'package:school_pulse/features/notifications/data/notification_image_cache.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import 'package:school_pulse/features/notifications/local/notification_presenter.dart';
import 'package:school_pulse/features/notifications/push/token_management/notification_token_manager.dart';
import 'package:school_pulse/features/notifications/push/token_management/token_local_cache_factory.dart';
import 'package:school_pulse/features/notifications/push/notification_badge_service.dart';
import 'package:school_pulse/features/notifications/testing/notification_test_service/notification_test_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:school_pulse/features/verification/data/datasources/verification_local_data_source.dart';
import 'package:school_pulse/features/verification/data/datasources/verification_local_data_source_factory.dart';
import 'package:school_pulse/features/verification/data/repositories/identity_resolver_impl.dart';
import 'package:school_pulse/features/verification/data/repositories/permission_evaluator_impl.dart';
import 'package:school_pulse/features/verification/data/repositories/verification_event_recorder_impl.dart';
import 'package:school_pulse/features/verification/domain/repositories/identity_resolver.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import 'package:school_pulse/features/verification/domain/repositories/verification_event_recorder.dart';
import 'package:school_pulse/features/verification/domain/repositories/verification_policy_evaluator.dart';
import 'package:school_pulse/features/verification/domain/repositories/nfc_credential_repository.dart';
import 'package:school_pulse/features/verification/data/repositories/nfc_credential_repository_impl.dart';
import 'package:school_pulse/features/verification/domain/services/verification_feedback_service.dart';
import 'package:school_pulse/features/verification/presentation/services/haptic_verification_feedback_service.dart';
import 'package:school_pulse/features/verification/presentation/adapters/qr_credential_reader_adapter.dart';
import 'package:school_pulse/features/verification/presentation/adapters/fingerprint_credential_reader_adapter.dart';
import 'package:school_pulse/features/verification/presentation/bloc/verification_session_bloc.dart';
import 'package:school_pulse/features/verification/presentation/bloc/credential_scan_bloc.dart';
import 'package:school_pulse/features/verification/domain/repositories/credential_reader_adapter.dart';
import 'package:school_pulse/core/services/nfc/nfc_credential_reader_adapter.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Assessment
  sl.registerFactory(() => AssessmentBloc(repository: sl()));

  // Features - Auth
  sl.registerFactory(() => SuperAdminBloc(repository: sl(), auth: sl()));

  sl.registerLazySingleton<SuperAdminRepository>(
    () => SuperAdminRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<SuperAdminRemoteDataSource>(
    () => SuperAdminRemoteDataSourceImpl(firestore: sl(), auth: sl()),
  );

  sl.registerLazySingleton<AssessmentRepository>(
    () => AssessmentRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<AssessmentRemoteDataSource>(
    () => AssessmentRemoteDataSourceImpl(firestore: sl()),
  );

  // AssessmentLocalDataSource: confirmed unused anywhere in the codebase
  // (registered but never sl<AssessmentLocalDataSource>()'d) - not
  // registered here since its Isar model has no web-safe path and nothing
  // depends on it. See lib/features/exams/data/datasources/
  // assessment_local_data_source.dart if this needs reviving later.

  // Features - Gate Operations (Gatekeeper Simple Mode rebuild)
  // Note: GateOpsBloc itself is registered once the presentation layer
  // lands in a later commit - these usecases/repository are needed now
  // because MovementVerificationPolicy and VerificationSessionBloc
  // already depend on them.
  sl.registerLazySingleton(() => WatchGates(sl()));
  sl.registerLazySingleton(() => RecordMovementEvent(sl()));
  sl.registerLazySingleton(() => WatchMovementEvents(sl()));
  sl.registerLazySingleton(() => CheckInVisitor(sl()));
  sl.registerLazySingleton(() => CheckOutVisitor(sl()));
  sl.registerLazySingleton(() => WatchVisitors(sl()));
  sl.registerLazySingleton(() => ReportIncident(sl()));
  sl.registerLazySingleton(() => TriggerEmergency(sl()));
  sl.registerLazySingleton(() => ResolveEmergency(sl()));
  sl.registerLazySingleton(() => WatchActiveEmergencies(sl()));
  sl.registerLazySingleton(() => GetGateOpsDashboardStats(sl()));
  sl.registerLazySingleton(() => GetPickupAuthorizations(sl()));
  sl.registerLazySingleton(() => AddPickupAuthorization(sl()));

  sl.registerLazySingleton(
    () => MovementSyncEngine(networkInfo: sl(), firestore: sl(), storage: sl()),
  );
  sl.registerLazySingleton<GateOpsRepository>(
    () => GateOpsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      syncEngine: sl(),
    ),
  );
  sl.registerLazySingleton<GateOpsRemoteDataSource>(
    () => GateOpsRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<GateOpsLocalDataSource>(
    () => createGateOpsLocalDataSource(
      isar: kIsWeb ? null : sl<Isar>(),
      remote: sl<GateOpsRemoteDataSource>(),
    ),
  );

  // Features - Appointments & Meeting Management
  sl.registerFactory(
    () => AppointmentSettingsBloc(
      watchAppointmentTypes: sl(),
      saveAppointmentType: sl(),
      deleteAppointmentType: sl(),
      getStaffAvailability: sl(),
      saveStaffAvailability: sl(),
    ),
  );
  sl.registerFactory(
    () => AppointmentActionBloc(
      requestAppointment: sl(),
      respondToAppointment: sl(),
      cancelAppointment: sl(),
      checkInAppointment: sl(),
      checkOutAppointment: sl(),
      addAppointmentNote: sl(),
    ),
  );

  sl.registerLazySingleton(() => WatchAppointmentTypes(sl()));
  sl.registerLazySingleton(() => SaveAppointmentType(sl()));
  sl.registerLazySingleton(() => DeleteAppointmentType(sl()));
  sl.registerLazySingleton(() => GetStaffAvailability(sl()));
  sl.registerLazySingleton(() => SaveStaffAvailability(sl()));
  sl.registerLazySingleton(() => GetStaffByRoles(sl()));
  sl.registerLazySingleton(() => appointments_usecases.GetStudentsByIds(sl()));
  sl.registerLazySingleton(() => GetAvailableSlots(sl()));
  sl.registerLazySingleton(() => RequestAppointment(sl()));
  sl.registerLazySingleton(() => RespondToAppointment(sl()));
  sl.registerLazySingleton(() => CancelAppointment(sl()));
  sl.registerLazySingleton(() => CheckInAppointment(sl()));
  sl.registerLazySingleton(() => CheckOutAppointment(sl()));
  sl.registerLazySingleton(() => MarkAppointmentCompleted(sl()));
  sl.registerLazySingleton(() => WatchAppointmentsForParent(sl()));
  sl.registerLazySingleton(() => WatchAppointmentsForStaff(sl()));
  sl.registerLazySingleton(() => WatchAppointmentsForSchool(sl()));
  sl.registerLazySingleton(() => AddAppointmentNote(sl()));
  sl.registerLazySingleton(() => WatchAppointmentNotes(sl()));

  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSourceImpl(sl()),
  );

  // Admin/System Config
  sl.registerLazySingleton(() => SystemConfigRepository());
  sl.registerFactory(() => SystemConfigBloc(repository: sl()));

  // Branding
  sl.registerLazySingleton(() => GetSchoolBranding(sl()));
  sl.registerFactory(
    () => BrandingBloc(
      localCache: createBrandingLocalCache(isar: kIsWeb ? null : sl<Isar>()),
      getSchoolBranding: sl(),
    ),
  );

  // Features - Exams (dashboard)
  sl.registerFactory(() => ExamsBloc(repository: sl()));

  sl.registerLazySingleton<ExamsRepository>(
    () => ExamsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ExamsRemoteDataSource>(
    () => ExamsRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerFactory(
    () => AcademicBloc(
      getAcademicRecords: sl(),
      getAttendanceRecords: sl(),
      getReportCards: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetAcademicRecords(sl()));
  sl.registerLazySingleton(() => GetAttendanceRecords(sl()));
  sl.registerLazySingleton(() => GetReportCards(sl()));
  sl.registerLazySingleton(() => SignReportCard(sl()));

  sl.registerLazySingleton<AcademicRepository>(
    () => AcademicRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AcademicRemoteDataSource>(
    () => AcademicRemoteDataSourceImpl(firestore: sl()),
  );

  // Features - Student
  sl.registerFactory(
    () => StudentsBloc(getStudentsByIds: sl(), getAllStudents: sl()),
  );

  sl.registerFactory(() => StudentHomeworkBloc(getHomeworkForStudent: sl()));

  sl.registerLazySingleton(() => GetStudentsByIds(sl()));
  sl.registerLazySingleton(() => GetAllStudents(sl()));
  sl.registerLazySingleton(() => ResolveParentAccessCode(sl()));
  sl.registerLazySingleton(() => GetHomeworkForStudent(sl()));
  sl.registerLazySingleton(() => SearchStudents(sl()));
  sl.registerLazySingleton(() => CreateStudent(sl()));

  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      matronRemoteDataSource: sl(),
      relationshipRepository: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<StudentRemoteDataSource>(
    () => StudentRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
      functions: sl(),
    ),
  );

  sl.registerLazySingleton<StudentLocalDataSource>(
    () => createStudentLocalDataSource(
      isar: kIsWeb ? null : sl<Isar>(),
      remote: sl<StudentRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton(
    () => AdmissionService(
      sl(),
      idGenerator: sl(),
      identityRepository: sl(),
      initializeFinancials: sl(),
    ),
  );
  sl.registerLazySingleton(() => StudentService(sl()));
  sl.registerLazySingleton(() => DocumentService(sl()));
  sl.registerLazySingleton(() => PromotionService(sl()));

  sl.registerLazySingleton(() => ParentLinkingService(sl(), sl()));

  sl.registerFactory(
    () => AdmissionBloc(admissionService: sl(), permissionEvaluator: sl()),
  );

  // Features - Student Identity (QR / ID card resolution, used by the
  // security module's gate verification workflow)
  sl.registerLazySingleton(() => IdGeneratorService());

  // Also never registered - StudentIdCardScreen's print button resolves
  // this via GetIt.I<IdCardService>() and would have thrown
  // "type IdCardService is not registered" the moment anyone pressed it.
  sl.registerLazySingleton(() => IdCardService());
  sl.registerLazySingleton(() => StaffIdCardService());

  sl.registerLazySingleton<StudentIdentityRepository>(
    () => StudentIdentityRepositoryImpl(
      firestore: sl(),
      localCache: createStudentIdentityLocalCache(
        isar: kIsWeb ? null : sl<Isar>(),
      ),
      idGenerator: sl(),
      functions: sl(),
    ),
  );

  // Was built correctly (offline-first Isar queue, real StudentIdentity
  // lookup) but never registered, so the QR/manual attendance stub
  // screens had nothing real to call - see qr_scanner_screen.dart etc.
  sl.registerLazySingleton<AttendanceQrRepository>(
    () => createAttendanceQrRepository(
      firestore: sl<FirebaseFirestore>(),
      isar: kIsWeb ? null : sl<Isar>(),
    ),
  );
  sl.registerFactory(
    () =>
        AttendanceQrBloc(attendanceRepository: sl(), identityRepository: sl()),
  );

  // Was never registered even though StudentIdCardScreen already read it
  // via context.read<StudentIdentityBloc>() - that screen would have
  // thrown a ProviderNotFoundException the moment anyone navigated to it.
  sl.registerFactory(
    () => StudentIdentityBloc(repository: sl(), nfcCredentialService: sl()),
  );

  // Features - Auth
  // Singleton, not a factory: this bloc represents the one app-wide auth
  // session, and GoRouter's redirect logic (see app/router.dart) needs to
  // read/listen to that same instance rather than a fresh, disconnected
  // one each time di.sl<AuthBloc>() is called.
  sl.registerLazySingleton(
    () => AuthBloc(
      loginWithEmail: sl(),
      loginOwnerWithEmail: sl(),
      loginOwnerWithGoogle: sl(),
      loginOwnerWithApple: sl(),
      verifyOwnerSession: sl(),
      loginParent: sl(),
      completeParentPinSetup: sl(),
      logout: sl(),
      getCurrentUser: sl(),
      resolveParentAccessCode: sl(),
      enterSupportMode: sl(),
      exitSupportMode: sl(),
      brandingBloc: sl(),
      verificationLocalDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => LoginWithEmail(sl()));
  sl.registerLazySingleton(() => LoginOwnerWithEmail(sl()));
  sl.registerLazySingleton(() => LoginOwnerWithGoogle(sl()));
  sl.registerLazySingleton(() => LoginOwnerWithApple(sl()));
  sl.registerLazySingleton(() => VerifyOwnerSession(sl()));
  sl.registerLazySingleton(() => LoginParent(sl()));
  sl.registerLazySingleton(() => CompleteParentPinSetup(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => EnterSupportMode(sl()));
  sl.registerLazySingleton(() => ExitSupportMode(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      functions: sl(),
      // assertPlatformOwnerAccess and the rest of the publicwebsite Cloud
      // Functions codebase are deployed to europe-west1, not the default
      // region `sl<FirebaseFunctions>()` resolves to - see
      // AuthRemoteDataSourceImpl.ownerFunctions' doc comment.
      ownerFunctions: FirebaseFunctions.instanceFor(region: 'europe-west1'),
    ),
  );

  // Features - Admin Dashboard
  sl.registerFactory(
    () =>
        AdminDashboardBloc(getAdminDashboardStats: sl(), auditRepository: sl()),
  );

  sl.registerLazySingleton(
    () => GetAdminDashboardStats(
      authRepository: sl(),
      gateOpsRepository: sl(),
      firestore: sl(),
      adminAttendanceRepository: sl(),
      financeRepository: sl(),
      structureRepository: sl(),
    ),
  );

  sl.registerLazySingleton<AdminAttendanceRepository>(
    () => AdminAttendanceRepositoryImpl(firestore: sl()),
  );

  sl.registerLazySingleton(() => AuditRepository());

  // Features - School Calendar
  sl.registerFactory(
    () => SchoolCalendarBloc(repository: sl(), permissionEvaluator: sl()),
  );

  sl.registerLazySingleton<SchoolCalendarRepository>(
    () => SchoolCalendarRepositoryImpl(
      remoteDataSource: sl(),
      structureRepository: sl(),
    ),
  );

  sl.registerLazySingleton<SchoolCalendarRemoteDataSource>(
    () => SchoolCalendarRemoteDataSourceImpl(firestore: sl()),
  );

  // Features - Announcements
  sl.registerLazySingleton<AnnouncementRemoteDataSource>(
    () => AnnouncementRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<AnnouncementRepository>(
    () => AnnouncementRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(
    () => AnnouncementBloc(repository: sl(), permissionEvaluator: sl()),
  );

  // Features - School Directory
  sl.registerLazySingleton<SchoolDirectoryRemoteDataSource>(
    () => SchoolDirectoryRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<SchoolDirectoryRepository>(
    () => SchoolDirectoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(() => SchoolDirectoryBloc(repository: sl()));

  // Features - Attendance Hub
  sl.registerFactory(
    () => AttendanceBloc(
      repository: sl(),
      permissionEvaluator: sl(),
      participantResolver: sl(),
    ),
  );

  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      remoteDataSource: sl(),
      structureRepository: sl(),
      studentRepository: sl(),
      getStaffMembers: sl(),
    ),
  );

  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(firestore: sl()),
  );

  // Central attendance access resolver - see the class doc comment for why
  // every attendance surface (dropdown, scopes, roster, NFC/QR, Previous
  // Attendance, Sheets export) must go through this instead of deriving its
  // own participant list from a role check.
  sl.registerLazySingleton<AttendanceParticipantResolver>(
    () => AttendanceParticipantResolverImpl(
      assignmentRepository: sl(),
      calendarService: sl(),
      permissionEvaluator: sl(),
    ),
  );

  sl.registerLazySingleton<SheetsIntegrationRepository>(
    () => SheetsIntegrationRepositoryImpl(
      remoteDataSource: sl(),
      functions: sl(),
    ),
  );

  sl.registerLazySingleton<SheetsIntegrationRemoteDataSource>(
    () => SheetsIntegrationRemoteDataSourceImpl(firestore: sl()),
  );

  // Features - Catering
  sl.registerFactory(() => CateringBloc(repository: sl()));

  sl.registerLazySingleton<CateringRepository>(
    () => CateringRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton(
    () => CateringEligibilityService(
      permissionEvaluator: sl(),
      studentRepository: sl(),
      cateringRepository: sl(),
    ),
  );

  sl.registerLazySingleton<CateringRemoteDataSource>(
    () => CateringRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<CateringLocalDataSource>(
    () => createCateringLocalDataSource(
      isar: kIsWeb ? null : sl<Isar>(),
      remote: sl<CateringRemoteDataSource>(),
    ),
  );

  // Features - Dean
  sl.registerFactory(() => DeanBloc(repository: sl()));

  sl.registerLazySingleton(() => GetDeanStats(sl()));

  sl.registerLazySingleton<DeanRepository>(
    () => DeanRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<DeanRemoteDataSource>(
    () => DeanRemoteDataSourceImpl(),
  );

  // Director
  sl.registerFactory(() => DirectorBloc());

  // Features - Discipline
  sl.registerFactory(
    () => DisciplineBloc(
      getDisciplineIncidents: sl(),
      getRecentDisciplineIncidents: sl(),
      logDisciplineIncident: sl(),
      getCounselingSessions: sl(),
      logCounselingSession: sl(),
      studentRepository: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetDisciplineIncidents(sl()));
  sl.registerLazySingleton(() => GetRecentDisciplineIncidents(sl()));
  sl.registerLazySingleton(() => LogDisciplineIncident(sl()));
  sl.registerLazySingleton(() => GetCounselingSessions(sl()));
  sl.registerLazySingleton(() => LogCounselingSession(sl()));

  sl.registerLazySingleton<DisciplineRepository>(
    () => DisciplineRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<DisciplineRemoteDataSource>(
    () => DisciplineRemoteDataSourceImpl(firestore: sl()),
  );

  // Features - Finance
  sl.registerLazySingleton(() => FinanceService(sl()));

  sl.registerFactory(
    () => FinanceBloc(
      repository: sl(),
      financeService: sl(),
      printerService: sl(),
    ),
  );

  sl.registerLazySingleton<FinanceRepository>(
    () => FinanceRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(
    () => BursarStudentProjectionService(
      permissionEvaluator: sl(),
      studentRepository: sl(),
      financeRepository: sl(),
    ),
  );

  sl.registerLazySingleton<FinanceRemoteDataSource>(
    () => FinanceRemoteDataSourceImpl(firestore: sl()),
  );

  // Features - Games
  sl.registerFactory(() => GamesBloc(repository: sl()));

  sl.registerLazySingleton<GamesRepository>(
    () => GamesRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<GamesRemoteDataSource>(
    () => GamesRemoteDataSourceImpl(firestore: sl()),
  );

  // Features - Health
  sl.registerFactory(
    () => HealthBloc(
      getStudentHealthProfile: sl(),
      updateStudentHealthProfile: sl(),
      getClinicVisits: sl(),
      recordClinicVisit: sl(),
      getEmergencyIncidents: sl(),
      recordEmergencyIncident: sl(),
      getMedicalInventory: sl(),
      updateInventoryItem: sl(),
      getMedicalSupplyRequests: sl(),
      createSupplyRequest: sl(),
      getHealthAnalytics: sl(),
      studentRepository: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetStudentHealthProfile(sl()));
  sl.registerLazySingleton(() => UpdateStudentHealthProfile(sl()));
  sl.registerLazySingleton(() => GetClinicVisits(sl()));
  sl.registerLazySingleton(() => RecordClinicVisit(sl()));
  sl.registerLazySingleton(() => GetEmergencyIncidents(sl()));
  sl.registerLazySingleton(() => RecordEmergencyIncident(sl()));
  sl.registerLazySingleton(() => GetMedicalInventory(sl()));
  sl.registerLazySingleton(() => UpdateInventoryItem(sl()));
  sl.registerLazySingleton(() => GetMedicalSupplyRequests(sl()));
  sl.registerLazySingleton(() => CreateSupplyRequest(sl()));
  sl.registerLazySingleton(() => UpdateSupplyRequestStatus(sl()));
  sl.registerLazySingleton(() => GetHealthAnalytics(sl()));

  sl.registerLazySingleton<HealthRepository>(
    () => HealthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<HealthRemoteDataSource>(
    () => HealthRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton(
    () => NurseStudentProjectionService(
      permissionEvaluator: sl(),
      studentRepository: sl(),
      healthRepository: sl(),
    ),
  );

  // Features - HR
  sl.registerFactory(() => HrBloc(repository: sl()));

  sl.registerLazySingleton<HrRepository>(
    () => HrRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<HrRemoteDataSource>(
    () => HrRemoteDataSourceImpl(firestore: sl()),
  );

  // Features - Inventory
  sl.registerFactory(
    () => InventoryBloc(
      getInventoryItems: sl(),
      getRecentMovements: sl(),
      addStock: sl(),
      issueItem: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetInventoryItems(sl()));
  sl.registerLazySingleton(() => GetRecentMovements(sl()));
  sl.registerLazySingleton(() => AddStock(sl()));
  sl.registerLazySingleton(() => IssueItem(sl()));

  sl.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(firestore: sl()),
  );

  // Features - Stores & Assets (Assets / Repairs / Maintenance / Procurement)
  sl.registerFactory(() => StoresAssetsBloc(repository: sl()));

  sl.registerLazySingleton<StoresAssetsRepository>(
    () => StoresAssetsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<StoresAssetsRemoteDataSource>(
    () => StoresAssetsRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<StoresAssetsLocalDataSource>(
    () => createStoresAssetsLocalDataSource(
      isar: kIsWeb ? null : sl<Isar>(),
      remote: sl<StoresAssetsRemoteDataSource>(),
    ),
  );

  // Features - Library
  sl.registerFactory(() => LibraryBloc(repository: sl()));

  sl.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      auditRepository: sl(),
      financeRepository: sl(),
      storesAssetsRepository: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => LibraryEligibilityService(
      permissionEvaluator: sl(),
      studentRepository: sl(),
      libraryRepository: sl(),
    ),
  );

  sl.registerLazySingleton<LibraryRemoteDataSource>(
    () => LibraryRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<LibraryLocalDataSource>(
    () => createLibraryLocalDataSource(
      isar: kIsWeb ? null : sl<Isar>(),
      remote: sl<LibraryRemoteDataSource>(),
    ),
  );

  // Features - Matron
  sl.registerFactory(() => MatronBloc(repository: sl()));

  sl.registerLazySingleton<MatronRepository>(
    () => MatronRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<MatronRemoteDataSource>(
    () => MatronRemoteDataSourceImpl(firestore: sl(), auditRepository: sl()),
  );

  // Features - Patron
  sl.registerFactory(() => PatronBloc(repository: sl()));

  sl.registerLazySingleton<PatronRepository>(
    () => PatronRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PatronRemoteDataSource>(
    () => PatronRemoteDataSourceImpl(firestore: sl(), auditRepository: sl()),
  );

  // Features - Messages
  sl.registerLazySingleton<MessagesRepository>(
    () => MessagesRepositoryImpl(firestore: sl(), storage: sl()),
  );

  // Features - Notifications
  sl.registerFactory(
    () => NotificationsBloc(
      getAlerts: sl(),
      markAlertRead: sl(),
      sendNotification: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetAlerts(sl()));
  sl.registerLazySingleton(() => MarkAlertRead(sl()));
  sl.registerLazySingleton(() => SendNotificationUseCase(sl()));

  sl.registerLazySingleton(() => InitializeStudentFinancials(sl()));

  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(firestore: sl()),
  );

  // Notification centre (typed, offline-first). Registered alongside the older
  // alert-based NotificationsBloc above rather than replacing it, so the
  // screens still reading `alerts` keep working while they are migrated.
  sl.registerFactory(() => NotificationCenterBloc(repository: sl()));

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      isConnected: () => sl<NetworkInfo>().isConnected,
    ),
  );

  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<NotificationLocalDataSource>(
    () => createNotificationLocalDataSource(
      isar: kIsWeb ? null : sl<Isar>(),
      remote: sl<NotificationRemoteDataSource>(),
    ),
  );

  // Push delivery pipeline.
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  // Image cache. Wifi detection is approximated by the existing connectivity
  // check: InternetConnectionChecker reports reachability, not connection
  // type, so "connected" is treated as unmetered only when the platform
  // exposes nothing better. Erring toward not downloading would leave images
  // permanently blank for users who are always on mobile data.
  sl.registerLazySingleton(
    () => NotificationImageCache(isOnWifi: () => sl<NetworkInfo>().isConnected),
  );

  sl.registerLazySingleton(
    () => NotificationPresenter(
      plugin: sl(),
      // Rich push needs a local file path - the OS cannot render a remote URL -
      // so the presenter resolves images through the cache before display.
      resolveLocalImage: (url) => sl<NotificationImageCache>().resolve(url),
    ),
  );

  sl.registerLazySingleton(
    () => NotificationTokenManager(
      messaging: FirebaseMessaging.instance,
      firestore: sl(),
      localCache: createTokenLocalCache(isar: kIsWeb ? null : sl<Isar>()),
    ),
  );

  sl.registerLazySingleton(
    () => NotificationBadgeService(repository: sl(), plugin: sl()),
  );

  // Delivery testing tool (real push to the caller's own devices only).
  sl.registerLazySingleton(
    () => NotificationTestService(
      plugin: sl(),
      presenter: sl(),
      functions: FirebaseFunctions.instance,
    ),
  );

  // Send requests go to Firestore for a Cloud Function to fan out; the client
  // never writes notification documents or calls FCM itself.
  sl.registerLazySingleton(() => NotificationSendService(firestore: sl()));

  // Push handler and coordinator. The handler reads the live session from the
  // coordinator rather than holding its own copy, so there is one source of
  // truth for who is signed in when a push arrives.
  sl.registerLazySingleton(
    () => NotificationPushHandler(
      messaging: FirebaseMessaging.instance,
      repository: sl(),
      presenter: sl(),
      currentUser: () => sl<NotificationCoordinator>().session,
      navigate: (notification) async {
        // Navigation goes through the deep-link router, which re-checks
        // authentication, tenancy and permission before producing a route -
        // a push payload is never navigated to verbatim.
        final resolution = await const NotificationDeepLinkRouter().resolve(
          notification: notification,
          user: sl<NotificationCoordinator>().user,
        );
        final destination = resolution.destination;
        if (destination != null) {
          app_router.router.push(destination.route, extra: destination.extra);
        } else {
          // Refused: fall back to the notification centre rather than silently
          // doing nothing on a tap.
          app_router.router.push('/staff/notifications');
        }
      },
    ),
  );

  sl.registerLazySingleton(
    () => NotificationCoordinator(
      plugin: sl(),
      tokenManager: sl(),
      badgeService: sl(),
      repository: sl(),
      pushHandler: sl(),
    ),
  );

  // Features - Religion
  sl.registerFactory(() => ReligionBloc(repository: sl()));

  sl.registerLazySingleton<ReligionRepository>(
    () => ReligionRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ReligionRemoteDataSource>(
    () => ReligionRemoteDataSourceImpl(firestore: sl()),
  );

  // Features - Teacher
  sl.registerFactory(
    () => TeacherBloc(
      getStudentsByClass: sl(),
      submitAttendance: sl(),
      submitMarks: sl(),
      getAttendanceHistory: sl(),
      getTeacherDashboardStats: sl(),
      getHomework: sl(),
      createHomework: sl(),
      updateHomework: sl(),
      deleteHomework: sl(),
      getReportComments: sl(),
      saveReportComment: sl(),
      getCompetencyRatings: sl(),
      saveCompetencyRating: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetStudentsByClass(sl()));
  sl.registerLazySingleton(() => SubmitAttendance(sl()));
  sl.registerLazySingleton(() => SubmitMarks(sl()));
  sl.registerLazySingleton(() => GetAttendanceHistory(sl()));
  sl.registerLazySingleton(() => GetTeacherDashboardStats(sl()));
  sl.registerLazySingleton(() => GetHomework(sl()));
  sl.registerLazySingleton(() => CreateHomework(sl()));
  sl.registerLazySingleton(() => UpdateHomework(sl()));
  sl.registerLazySingleton(() => DeleteHomework(sl()));
  sl.registerLazySingleton(() => GetReportComments(sl()));
  sl.registerLazySingleton(() => SaveReportComment(sl()));
  sl.registerLazySingleton(() => GetCompetencyRatings(sl()));
  sl.registerLazySingleton(() => SaveCompetencyRating(sl()));
  sl.registerLazySingleton(() => GenerateReports(sl()));

  sl.registerLazySingleton<TeacherRepository>(
    () => TeacherRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<TeacherRemoteDataSource>(
    () => TeacherRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerFactory(() => ReportWizardBloc(generateReports: sl()));

  // Features - Subject Teacher panel
  //
  // The context BLoC is a lazy singleton, not a factory: it owns which
  // responsibility the teacher is acting under, and every tab has to read the
  // same answer. A factory would give the Students tab a different active
  // subject from the Marks tab.
  sl.registerLazySingleton(
    () => SubjectTeacherContextBloc(
      responsibilityService: sl(),
      assignmentRepository: sl(),
      calendarService: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => SubjectTeacherDashboardBloc(
      studentRepository: sl(),
      lessonRepository: sl(),
    ),
  );

  // Features - Class Teacher panel
  //
  // Shares the responsibility service with the Subject Teacher panel above:
  // one account holds both, and both must agree on which assignment is in
  // effect. A lazy singleton for the same reason - Home, Students, Reports
  // and Tasks all have to read the same active class.
  sl.registerLazySingleton(
    () => ClassTeacherContextBloc(
      responsibilityService: sl(),
      assignmentService: sl(),
      assignmentRepository: sl(),
      calendarService: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ClassTeacherDashboardBloc(dashboardRepository: sl()),
  );

  sl.registerLazySingleton(
    () =>
        ClassStudentsBloc(studentRepository: sl(), attendanceRepository: sl()),
  );

  sl.registerLazySingleton(
    () => ClassAttendanceBloc(
      attendanceRepository: sl(),
      studentRepository: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ClassAttendanceHistoryBloc(attendanceRepository: sl()),
  );

  sl.registerLazySingleton(
    () => ClassWorkBloc(workRepository: sl(), studentRepository: sl()),
  );

  sl.registerLazySingleton<ClassWorkRepository>(
    () => ClassWorkRepositoryImpl(
      remoteDataSource: sl(),
      assignmentService: sl(),
      auditService: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ClassAnnouncementsBloc(communicationRepository: sl()),
  );

  sl.registerLazySingleton<ClassCommunicationRepository>(
    () => ClassCommunicationRepositoryImpl(
      remoteDataSource: sl(),
      studentRepository: sl(),
      assignmentService: sl(),
      auditService: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ClassPerformanceBloc(performanceRepository: sl()),
  );

  sl.registerLazySingleton<ClassPerformanceRepository>(
    () => ClassPerformanceRepositoryImpl(
      remoteDataSource: sl(),
      studentRepository: sl(),
      attendanceRepository: sl(),
      workRepository: sl(),
      assignmentService: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(() => ClassReportsBloc(reportRepository: sl()));

  sl.registerLazySingleton<ClassReportRepository>(
    () => ClassReportRepositoryImpl(
      remoteDataSource: sl(),
      studentRepository: sl(),
      assignmentService: sl(),
      auditService: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(() => ClassTasksBloc(taskRepository: sl()));

  sl.registerLazySingleton<ClassTaskRepository>(
    () => ClassTaskRepositoryImpl(
      remoteDataSource: sl(),
      auditService: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ClassResourceRepository>(
    () => ClassResourceRepositoryImpl(
      firestore: sl(),
      storage: sl(),
      assignmentService: sl(),
      auditService: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(() => ClassResourceBloc(repository: sl()));

  sl.registerLazySingleton<ClassAttendanceRepository>(
    () => ClassAttendanceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      // Shares the Subject Teacher panel's offline queue: one device, one
      // replay order, so a class register and a lesson register cannot be
      // pushed out of sequence relative to each other.
      queueDataSource: sl(),
      structureRepository: sl(),
      assignmentService: sl(),
      auditService: sl(),
      networkInfo: sl(),
      deviceIdService: sl(),
    ),
  );

  sl.registerLazySingleton<ClassTeacherAssignmentService>(
    () => ClassTeacherAssignmentServiceImpl(
      assignmentRepository: sl(),
      responsibilityService: sl(),
    ),
  );

  sl.registerLazySingleton<ClassStudentRepository>(
    () => ClassStudentRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      assignmentService: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ClassDashboardRepository>(
    () => ClassDashboardRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      studentRepository: sl(),
      assignmentService: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ClassTeacherRemoteDataSource>(
    () => ClassTeacherRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<ClassTeacherLocalDataSource>(
    () => createClassTeacherLocalDataSource(
      isar: kIsWeb ? null : sl<Isar>(),
      remote: sl<ClassTeacherRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<MarksRepository>(
    () => MarksRepositoryImpl(
      remoteDataSource: sl(),
      studentRepository: sl(),
      auditService: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<LessonRepository>(
    () => LessonRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      auditService: sl(),
      networkInfo: sl(),
      deviceIdService: sl(),
    ),
  );

  sl.registerLazySingleton<ActiveResponsibilityService>(
    () => ActiveResponsibilityServiceImpl(
      assignmentRepository: sl(),
      calendarService: sl(),
    ),
  );

  sl.registerLazySingleton<AcademicCalendarService>(
    () => AcademicCalendarServiceImpl(structureRepository: sl()),
  );

  sl.registerLazySingleton<StaffAssignmentRepository>(
    () => StaffAssignmentRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      preferences: sl(),
      // Read at call time rather than captured, so the persisted selection is
      // always keyed to whoever is signed in now.
      currentUserId: () => sl<FirebaseAuth>().currentUser?.uid ?? '',
    ),
  );

  sl.registerLazySingleton<SubjectStudentRepository>(
    () => SubjectStudentRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      auditService: sl(),
      networkInfo: sl(),
    ),
  );

  // Everywhere else constructs this directly; the audit service takes it as a
  // dependency so tests can supply a fixed device id.
  sl.registerLazySingleton(() => DeviceIdService());

  sl.registerLazySingleton<SubjectSyncService>(
    () => SubjectSyncServiceImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      classRemoteDataSource: sl(),
      classLocalDataSource: sl(),
      auditService: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<LessonAttendanceRepository>(
    () => LessonAttendanceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      auditService: sl(),
      networkInfo: sl(),
      deviceIdService: sl(),
    ),
  );

  sl.registerLazySingleton<SubjectAuditService>(
    () => SubjectAuditServiceImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      deviceIdService: sl(),
    ),
  );

  sl.registerLazySingleton<SubjectTeacherRemoteDataSource>(
    () => SubjectTeacherRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<SubjectTeacherLocalDataSource>(
    () => createSubjectTeacherLocalDataSource(isar: kIsWeb ? null : sl<Isar>()),
  );

  // Features - Transport
  sl.registerFactory(() => TransportBloc(getTransportInfo: sl()));

  sl.registerLazySingleton(() => GetTransportInfo(sl()));

  sl.registerLazySingleton<TransportRepository>(
    () => TransportRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(
    () => TransportStudentProjectionService(
      permissionEvaluator: sl(),
      studentRepository: sl(),
      transportRepository: sl(),
    ),
  );

  sl.registerLazySingleton<TransportRemoteDataSource>(
    () => TransportRemoteDataSourceImpl(firestore: sl()),
  );

  // Features - Lesson Plans
  sl.registerLazySingleton(() => AddLessonPlan(sl()));
  sl.registerLazySingleton(() => GetLessonPlans(sl()));

  sl.registerLazySingleton<LessonPlansRepository>(
    () => LessonPlansRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<LessonPlansRemoteDataSource>(
    () => LessonPlansRemoteDataSourceImpl(firestore: sl()),
  );

  // Admin - Parent Access Codes (StudentRepository already registered above)
  sl.registerLazySingleton(() => GetAllAccessCodes(sl()));
  sl.registerLazySingleton(() => CreateAccessCode(sl()));
  sl.registerLazySingleton(() => ToggleAccessCodeStatus(sl()));
  sl.registerLazySingleton(() => DeleteAccessCode(sl()));
  sl.registerLazySingleton(() => UpdateAccessCode(sl()));

  // Admin - Staff Accounts (AuthRepository already registered above)
  sl.registerLazySingleton(() => GetStaffMembers(sl()));
  sl.registerLazySingleton(() => CreateStaffAccount(sl()));
  sl.registerLazySingleton(() => ToggleStaffStatus(sl()));
  sl.registerLazySingleton(() => DeleteStaffMember(sl()));
  sl.registerLazySingleton(() => AdminResetStaffPassword(sl()));
  sl.registerLazySingleton(() => UpdateStaffMember(sl()));
  sl.registerLazySingleton(() => SetNewPassword(sl()));

  // Admin - Role Permission Overrides
  sl.registerLazySingleton<RolePermissionOverrideRepository>(
    () => RolePermissionOverrideRepositoryImpl(firestore: sl()),
  );
  sl.registerLazySingleton(() => GetRolePermissionOverrides(sl()));
  sl.registerLazySingleton(() => SaveRolePermissionOverride(sl()));

  // Admin - Staff Attendance / Subscription
  sl.registerLazySingleton(() => StaffAttendanceRepository());
  sl.registerLazySingleton(() => SubscriptionRepository());

  // Subscription Payment - MTN Mobile Money
  sl.registerLazySingleton<SubscriptionPaymentRepository>(
    () => SubscriptionPaymentRepositoryImpl(
      functions: FirebaseFunctions.instanceFor(region: 'europe-west1'),
      firestore: sl(),
    ),
  );
  sl.registerFactory(() => SubscriptionPaymentCubit(repository: sl()));

  // Features - Relationships (Phase 4: parent-student links, enrolment
  // history, guardian-limit policy)
  sl.registerLazySingleton<RelationshipRemoteDataSource>(
    () => RelationshipRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<RelationshipRepository>(
    () => RelationshipRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => CreateRelationship(sl()));
  sl.registerLazySingleton(() => ReallocateRelationship(sl()));
  sl.registerLazySingleton(() => GetRelationshipsForStudent(sl()));
  sl.registerLazySingleton(() => GetRelationshipsForParent(sl()));
  sl.registerLazySingleton(() => GetPeoplePolicy(sl()));
  sl.registerLazySingleton(() => UpdatePeoplePolicy(sl()));
  sl.registerLazySingleton(() => RecordEnrolmentChange(sl()));

  // Features - Parent Access (module visibility resolver, consumes
  // relationship access flags + structure feature toggles + people policy).
  // ParentAccessCubit itself is built in ParentShell, not registered here -
  // it needs the signed-in parent's userId and the app-wide
  // SelectedStudentBloc instance, neither of which sl() can supply.
  sl.registerLazySingleton(() => const ParentModuleResolver());

  // Features - Structure
  sl.registerFactory(() => StructureBloc(repository: sl()));

  // Assigns/ends/reactivates StaffRoleAssignment rows. Wraps the teacher
  // feature's StaffAssignmentRepository since the screens that use this
  // (Assign Role, Role Details, staff profile Roles tab) are Structure-side.
  sl.registerFactory(
    () => RoleAssignmentCubit(
      repository: sl(),
      auditRepository: sl(),
      notificationSender: sl(),
    ),
  );

  sl.registerLazySingleton<StructureRepository>(
    () =>
        StructureRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<StructureRemoteDataSource>(
    () => StructureRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<StructureLocalDataSource>(
    () => createStructureLocalDataSource(isar: kIsWeb ? null : sl<Isar>()),
  );

  sl.registerLazySingleton(() => StructureDependencyService(firestore: sl()));

  sl.registerLazySingleton<StructureConfigurationService>(
    () => StructureConfigurationServiceImpl(repository: sl()),
  );

  sl.registerFactory(
    () => TimetableBloc(repository: sl(), conflictResolver: sl()),
  );

  sl.registerLazySingleton(() => const TimetableConflictResolver());

  sl.registerLazySingleton<TimetableRepository>(
    () => TimetableRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<TimetableRemoteDataSource>(
    () => TimetableRemoteDataSourceImpl(firestore: sl()),
  );

  // Finance - additional usecases (FinanceRepository already registered above)
  sl.registerLazySingleton(() => GetAllFees(sl()));
  sl.registerLazySingleton(() => GetAllPaymentHistory(sl()));
  sl.registerLazySingleton(() => ProcessPayment(sl()));

  // Health - usecases already registered above

  // Library - additional usecases (LibraryRepository already registered above)
  sl.registerLazySingleton(() => GetAllBorrowedBooks(sl()));
  sl.registerLazySingleton(() => IssueBook(sl()));
  sl.registerLazySingleton(() => ReturnBook(sl()));

  // Features - Biometrics
  sl.registerFactory(
    () => BiometricsBloc(
      getBiometricSettings: sl(),
      updateBiometricSettings: sl(),
      enrollFingerprint: sl(),
      verifyFingerprint: sl(),
      getAuditLogs: sl(),
      syncBiometrics: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetBiometricSettings(sl()));
  sl.registerLazySingleton(() => UpdateBiometricSettings(sl()));
  sl.registerLazySingleton(() => EnrollFingerprint(sl(), sl()));
  sl.registerLazySingleton(() => VerifyFingerprint(sl(), sl()));
  sl.registerLazySingleton(() => GetAuditLogs(sl()));
  sl.registerLazySingleton(() => SyncBiometrics(sl()));

  sl.registerLazySingleton<BiometricRepository>(
    () =>
        BiometricRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<BiometricRemoteDataSource>(
    () => BiometricRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<BiometricLocalDataSource>(
    () => createBiometricLocalDataSource(isar: kIsWeb ? null : sl<Isar>()),
  );

  // `VerifyFingerprint`/`EnrollFingerprint` already depended on this but it
  // was never registered - pre-existing gap, would throw as soon as either
  // usecase was resolved. Fixed here since `IdentityResolverImpl` (Phase 1
  // verification engine) is the first thing that forces `VerifyFingerprint`
  // to actually resolve.
  sl.registerLazySingleton<BiometricDeviceService>(
    () => MockBiometricDeviceService(),
  );

  // Features - Verification (shared verification engine, Phase 1: Security/Gate)
  sl.registerFactory(
    () => VerificationSessionBloc(
      identityResolver: sl(),
      policyEvaluator: sl(),
      eventRecorder: sl(),
      feedbackService: sl(),
      recordMovementEvent: sl(),
    ),
  );

  sl.registerFactory(
    () => CredentialScanBloc(
      adapters: {
        ScanCredentialKind.qr: sl<QrCredentialReaderAdapter>(),
        ScanCredentialKind.nfc: sl<NfcCredentialReaderAdapter>(),
        ScanCredentialKind.fingerprint:
            sl<FingerprintCredentialReaderAdapter>(),
      },
    ),
  );

  sl.registerLazySingleton<IdentityResolver>(
    () => IdentityResolverImpl(
      studentIdentityRepository: sl(),
      getStaffMembers: sl(),
      resolveParentAccessCode: sl(),
      verifyFingerprint: sl(),
      localDataSource: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<PermissionEvaluator>(
    () => PermissionEvaluatorImpl(
      localDataSource: sl(),
      overrideRepository: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => EffectiveAccessResolver(
      permissionEvaluator: sl(),
      responsibilityService: sl(),
    ),
  );

  sl.registerLazySingleton<VerificationPolicyEvaluator>(
    () => MovementVerificationPolicy(
      permissionEvaluator: sl(),
      gateOpsRepository: sl(),
    ),
  );

  sl.registerLazySingleton<VerificationEventRecorder>(
    () => VerificationEventRecorderImpl(
      localDataSource: sl(),
      firestore: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<VerificationFeedbackService>(
    () => HapticVerificationFeedbackService(),
  );

  sl.registerLazySingleton<VerificationLocalDataSource>(
    () => createVerificationLocalDataSource(
      isar: kIsWeb ? null : sl<Isar>(),
      remote: kIsWeb ? sl<FirebaseFirestore>() : null,
    ),
  );

  sl.registerLazySingleton<NfcCredentialRepository>(
    () => NfcCredentialRepositoryImpl(
      localDataSource: sl(),
      firestore: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => NfcCredentialService(
      nfcCredentialRepository: sl(),
      studentIdentityRepository: sl(),
    ),
  );

  sl.registerLazySingleton(() => QrCredentialReaderAdapter());
  sl.registerLazySingleton(() => NfcCredentialReaderAdapter());
  sl.registerLazySingleton(() => FingerprintCredentialReaderAdapter(sl()));

  //! Printer Service
  sl.registerLazySingleton<PrinterService>(() => ThermalPrinterService());

  //! External
  final preferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => preferences);

  // No local database on web: every XLocalDataSource is registered with a
  // web-specific implementation that talks to Firestore directly (see the
  // conditional-import factory used on each registration below), so
  // sl<Isar>() is never resolved on web. The schema list itself is also
  // unreachable to the web compiler - it lives entirely inside
  // isar_bootstrap_mobile.dart, which openIsarForMobile() only reaches via
  // conditional import (see lib/core/platform/isar_bootstrap.dart).
  if (!kIsWeb) {
    final isar = await openIsarForMobile();
    sl.registerLazySingleton<Isar>(() => isar as Isar);
  }

  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<SecuritySettingsRemoteDataSource>(
    () => SecuritySettingsRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<OwnerSessionRemoteDataSource>(
    () => OwnerSessionRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton(() => DeviceInfoService());
  sl.registerLazySingleton(() => BiometricAuthService());
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => FirebaseFunctions.instance);
  // `InternetConnectionChecker` constructs `dart:io` sockets eagerly (even
  // just to build the singleton), which throws on web - so its
  // registration, and the `NetworkInfo` that would wrap it, must never be
  // reached there. See WebNetworkInfo's doc comment for the full story.
  if (kIsWeb) {
    sl.registerLazySingleton<NetworkInfo>(() => const WebNetworkInfo());
  } else {
    sl.registerLazySingleton(() => InternetConnectionChecker());
    sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  }

  sl.registerLazySingleton<InstitutionContextRemoteDataSource>(
    () => InstitutionContextRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<InstitutionContextRepository>(
    () => InstitutionContextRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory(
    () => InstitutionContextCubit(repository: sl(), preferences: sl()),
  );
}
