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
import 'package:school_pulse/features/visitors/domain/usecases/visitor_usecases.dart';
import 'package:school_pulse/features/visitors/domain/repositories/visitor_repository.dart'
    as visitor_domain;
import 'package:school_pulse/features/visitors/data/repositories/visitor_repository_impl.dart';
import 'package:school_pulse/features/visitors/data/datasources/visitor_local_data_source.dart';
import 'package:school_pulse/features/visitors/data/datasources/visitor_remote_data_source.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_bloc.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/features/visitors/data/models/visitor_isar.dart';
import 'package:school_pulse/features/visitors/data/models/visitor_blacklist_isar.dart';
import 'package:school_pulse/features/visitors/data/models/pre_approved_visitor_isar.dart';
import 'package:school_pulse/features/visitors/data/models/scheduled_visit_isar.dart';
import 'package:school_pulse/features/visitors/data/models/package_delivery_isar.dart';
import 'package:school_pulse/core/services/printer/printer_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:school_pulse/features/attendance_qr_integration/domain/services/google_sheets_service.dart';
import 'package:school_pulse/features/attendance_qr_integration/data/models/attendance_log_isar.dart';
import 'package:school_pulse/features/student_identity/data/models/student_cache_isar.dart';
import 'package:school_pulse/features/inventory/data/models/asset_isar.dart';
import 'package:school_pulse/features/inventory/data/models/inventory_item_isar.dart';
import 'package:school_pulse/features/inventory/data/models/stock_movement_isar.dart';
import 'package:school_pulse/features/inventory/data/models/supplier_isar.dart';
import 'package:school_pulse/features/inventory/data/models/purchase_order_isar.dart';
import 'package:school_pulse/features/inventory/data/models/repair_isar.dart';
import 'package:school_pulse/features/inventory/data/models/maintenance_isar.dart';
import 'package:school_pulse/features/inventory/data/models/procurement_request_isar.dart';
import 'package:school_pulse/features/library/data/models/library_isar_models.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/data/models/school_branding_isar.dart';
import 'package:school_pulse/features/branding/domain/usecases/get_school_branding.dart';

import 'package:school_pulse/features/messages/domain/repositories/messages_repository.dart';
import 'package:school_pulse/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_bloc.dart';
import 'package:school_pulse/features/teacher/domain/usecases/generate_reports.dart';
import 'package:school_pulse/features/finance/domain/services/finance_service.dart';
import 'package:school_pulse/features/student/domain/services/admission_service.dart';
import 'package:school_pulse/features/student/domain/services/parent_linking_service.dart';
import 'package:school_pulse/features/finance/domain/usecases/initialize_student_financials.dart';

// Super Admin
import 'package:school_pulse/features/super_admin/domain/repositories/super_admin_repository.dart';
import 'package:school_pulse/features/super_admin/data/repositories/super_admin_repository_impl.dart';
import 'package:school_pulse/features/super_admin/data/datasources/super_admin_remote_datasource.dart';
import 'package:school_pulse/features/super_admin/presentation/bloc/super_admin_bloc.dart';
import 'package:school_pulse/features/super_admin/domain/repositories/billing_repository.dart';
import 'package:school_pulse/features/super_admin/data/repositories/billing_repository_impl.dart';
import 'package:school_pulse/features/super_admin/data/datasources/billing_remote_datasource.dart';

// Admin / System Config
import 'package:school_pulse/features/admin/data/repositories/system_config_repository.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_bloc.dart';

// Exams/Assessment
import 'package:school_pulse/features/exams/domain/repositories/assessment_repository.dart';
import 'package:school_pulse/features/exams/data/repositories/assessment_repository_impl.dart';
import 'package:school_pulse/features/exams/data/datasources/assessment_remote_data_source.dart';
import 'package:school_pulse/features/exams/data/datasources/assessment_local_data_source.dart';
import 'package:school_pulse/features/exams/data/models/isar_assessment_mark.dart';
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
import 'package:school_pulse/features/auth/domain/usecases/login_with_email.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_parent.dart';
import 'package:school_pulse/features/auth/domain/usecases/complete_parent_pin_setup.dart';
import 'package:school_pulse/features/auth/domain/usecases/logout.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_current_user.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';

// Student
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student/data/repositories/student_repository_impl.dart';
import 'package:school_pulse/features/student/data/datasources/student_remote_data_source.dart';
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
import 'package:school_pulse/features/visitors/domain/services/visitor_id_card_service.dart';
import 'package:school_pulse/features/student_identity/domain/services/id_generator_service.dart';
import 'package:school_pulse/features/student_identity/domain/services/nfc_credential_service.dart';

// Admin Dashboard
import 'package:school_pulse/features/admin/domain/usecases/get_admin_dashboard_stats.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/admin/data/repositories/visitor_repository.dart'
    as admin_visitor;
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_bloc.dart';

// Calendar
import 'package:school_pulse/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:school_pulse/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:school_pulse/features/calendar/data/datasources/calendar_remote_data_source.dart';
import 'package:school_pulse/features/calendar/domain/usecases/add_event.dart';
import 'package:school_pulse/features/calendar/domain/usecases/delete_event.dart';
import 'package:school_pulse/features/calendar/domain/usecases/get_upcoming_events.dart';
import 'package:school_pulse/features/calendar/presentation/bloc/calendar_bloc.dart';

// Catering
import 'package:school_pulse/features/catering/domain/repositories/catering_repository.dart';
import 'package:school_pulse/features/catering/domain/services/catering_eligibility_service.dart';
import 'package:school_pulse/features/catering/data/repositories/catering_repository_impl.dart';
import 'package:school_pulse/features/catering/data/datasources/catering_remote_data_source.dart';
import 'package:school_pulse/features/catering/data/datasources/catering_local_data_source.dart';
import 'package:school_pulse/features/catering/presentation/bloc/catering_bloc.dart';
import 'package:school_pulse/features/catering/data/models/meal_record_isar.dart';

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

// Security
import 'package:school_pulse/features/security/domain/repositories/security_repository.dart';
import 'package:school_pulse/features/security/domain/usecases/security_usecases.dart';
import 'package:school_pulse/features/security/data/repositories/security_repository_impl.dart';
import 'package:school_pulse/features/security/data/datasources/security_remote_data_source.dart';
import 'package:school_pulse/features/security/data/datasources/security_local_data_source.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_bloc.dart';
import 'package:school_pulse/features/security/data/models/security_isar_models.dart';

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
import 'package:school_pulse/features/teacher/data/models/subject_teacher_isar_models.dart';
import 'package:school_pulse/features/teacher/data/repositories/staff_assignment_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/repositories/subject_student_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/services/academic_calendar_service_impl.dart';
import 'package:school_pulse/features/teacher/data/services/active_responsibility_service_impl.dart';
import 'package:school_pulse/features/teacher/data/services/subject_audit_service_impl.dart';
import 'package:school_pulse/features/teacher/domain/repositories/staff_assignment_repository.dart';
import 'package:school_pulse/features/teacher/domain/repositories/subject_student_repository.dart';
import 'package:school_pulse/features/teacher/domain/services/academic_calendar_service.dart';
import 'package:school_pulse/features/teacher/domain/services/active_responsibility_service.dart';
import 'package:school_pulse/features/teacher/domain/services/subject_audit_service.dart';
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
import 'package:school_pulse/features/structure/data/repositories/structure_repository_impl.dart';
import 'package:school_pulse/features/structure/data/datasources/structure_remote_data_source.dart';
import 'package:school_pulse/features/structure/data/datasources/structure_local_data_source.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/data/models/structure_isar_models.dart';

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
import 'package:school_pulse/features/biometrics/data/models/biometric_template_isar.dart';
import 'package:school_pulse/features/notifications/data/models/notification_isar.dart';
import 'package:school_pulse/features/notifications/data/models/notification_token_isar.dart';
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
import 'package:school_pulse/features/notifications/push/notification_badge_service.dart';
import 'package:school_pulse/features/notifications/testing/notification_test_service/notification_test_service.dart';
import 'package:school_pulse/features/notifications/testing/seed_runner/notification_seed_runner.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:school_pulse/features/verification/data/datasources/verification_local_data_source.dart';
import 'package:school_pulse/features/verification/data/models/verification_isar_models.dart';
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
import 'package:school_pulse/features/security/domain/policies/gate_verification_policy.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Assessment
  sl.registerFactory(() => AssessmentBloc(repository: sl()));

  // Features - Auth
  sl.registerFactory(
    () => SuperAdminBloc(repository: sl(), billingRepository: sl(), auth: sl()),
  );

  sl.registerLazySingleton<SuperAdminRepository>(
    () => SuperAdminRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<BillingRepository>(
    () => BillingRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<SuperAdminRemoteDataSource>(
    () => SuperAdminRemoteDataSourceImpl(firestore: sl(), auth: sl()),
  );

  sl.registerLazySingleton<BillingRemoteDataSource>(
    () => BillingRemoteDataSourceImpl(firestore: sl(), functions: sl()),
  );

  sl.registerLazySingleton<AssessmentRepository>(
    () => AssessmentRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<AssessmentRemoteDataSource>(
    () => AssessmentRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<AssessmentLocalDataSource>(
    () => AssessmentLocalDataSourceImpl(isar: sl()),
  );

  // Features - Visitors
  sl.registerFactory(
    () => VisitorsBloc(
      getVisitors: sl(),
      watchVisitors: sl(),
      checkInVisitor: sl(),
      checkOutVisitor: sl(),
      searchVisitors: sl(),
      getVisitorBlacklist: sl(),
      addToBlacklist: sl(),
      getPreApprovedVisitors: sl(),
      markPreApprovedAsUsed: sl(),
      syncVisitors: sl(),
      getActiveVisitors: sl(),
      getOverstayedVisitors: sl(),
      getScheduledVisits: sl(),
      approveScheduledVisit: sl(),
      rejectScheduledVisit: sl(),
      checkInScheduledVisit: sl(),
      logPackageDelivery: sl(),
      getPackageDeliveries: sl(),
      markPackageAsCollected: sl(),
      exportVisitorsToSheets: sl(),
      reissueBadge: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetVisitors(sl()));
  sl.registerLazySingleton(() => WatchVisitors(sl()));
  sl.registerLazySingleton(() => CheckInVisitor(sl()));
  sl.registerLazySingleton(() => CheckOutVisitor(sl()));
  sl.registerLazySingleton(() => SearchVisitors(sl()));
  sl.registerLazySingleton(() => GetVisitorBlacklist(sl()));
  sl.registerLazySingleton(() => AddToBlacklist(sl()));
  sl.registerLazySingleton(() => GetPreApprovedVisitors(sl()));
  sl.registerLazySingleton(() => MarkPreApprovedAsUsed(sl()));
  sl.registerLazySingleton(() => SyncVisitors(sl()));
  sl.registerLazySingleton(() => GetActiveVisitors(sl()));
  sl.registerLazySingleton(() => GetOverstayedVisitors(sl()));
  sl.registerLazySingleton(() => GetScheduledVisits(sl()));
  sl.registerLazySingleton(() => ApproveScheduledVisit(sl()));
  sl.registerLazySingleton(() => RejectScheduledVisit(sl()));
  sl.registerLazySingleton(() => CheckInScheduledVisit(sl()));
  sl.registerLazySingleton(() => LogPackageDelivery(sl()));
  sl.registerLazySingleton(() => GetPackageDeliveries(sl()));
  sl.registerLazySingleton(() => MarkPackageAsCollected(sl()));
  sl.registerLazySingleton(() => ExportVisitorsToSheets(sl()));
  sl.registerLazySingleton(() => ReissueBadge(sl()));

  // Repository
  sl.registerLazySingleton<visitor_domain.VisitorRepository>(
    () => VisitorRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
      storage: sl(),
      googleSheetsService: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<VisitorLocalDataSource>(
    () => VisitorLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<VisitorRemoteDataSource>(
    () => VisitorRemoteDataSourceImpl(sl()),
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
  sl.registerFactory(
    () => SystemConfigBloc(repository: sl(), brandingBloc: sl()),
  );

  // Branding
  sl.registerLazySingleton(() => GetSchoolBranding(sl()));
  sl.registerFactory(() => BrandingBloc(isar: sl(), getSchoolBranding: sl()));

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

  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(
      remoteDataSource: sl(),
      matronRemoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<StudentRemoteDataSource>(
    () => StudentRemoteDataSourceImpl(firestore: sl(), storage: sl()),
  );

  sl.registerLazySingleton(
    () => AdmissionService(
      sl(),
      idGenerator: sl(),
      identityRepository: sl(),
      initializeFinancials: sl(),
    ),
  );

  sl.registerLazySingleton(() => ParentLinkingService(sl()));

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
  sl.registerLazySingleton(() => VisitorIdCardService());

  sl.registerLazySingleton<StudentIdentityRepository>(
    () => StudentIdentityRepositoryImpl(firestore: sl(), isar: sl(), idGenerator: sl()),
  );

  // Was never registered even though StudentIdCardScreen already read it
  // via context.read<StudentIdentityBloc>() - that screen would have
  // thrown a ProviderNotFoundException the moment anyone navigated to it.
  sl.registerFactory(
    () => StudentIdentityBloc(repository: sl(), nfcCredentialService: sl()),
  );

  // Features - Auth
  sl.registerFactory(
    () => AuthBloc(
      loginWithEmail: sl(),
      loginParent: sl(),
      completeParentPinSetup: sl(),
      logout: sl(),
      getCurrentUser: sl(),
      resolveParentAccessCode: sl(),
      brandingBloc: sl(),
    ),
  );

  sl.registerLazySingleton(() => LoginWithEmail(sl()));
  sl.registerLazySingleton(() => LoginParent(sl()));
  sl.registerLazySingleton(() => CompleteParentPinSetup(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      functions: sl(),
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
      studentRepository: sl(),
      visitorRepository: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton(() => AuditRepository());
  sl.registerLazySingleton(() => admin_visitor.VisitorRepository());

  // Features - Calendar
  sl.registerFactory(
    () => CalendarBloc(
      getUpcomingEvents: sl(),
      addEvent: sl(),
      deleteEvent: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetUpcomingEvents(sl()));
  sl.registerLazySingleton(() => AddEvent(sl()));
  sl.registerLazySingleton(() => DeleteEvent(sl()));

  sl.registerLazySingleton<CalendarRepository>(
    () => CalendarRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<CalendarRemoteDataSource>(
    () => CalendarRemoteDataSourceImpl(firestore: sl()),
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
    () => CateringLocalDataSourceImpl(isar: sl()),
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
  sl.registerFactory(() => DirectorBloc(auditRepository: sl()));

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
    () => StoresAssetsLocalDataSourceImpl(isar: sl()),
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
    () => LibraryLocalDataSourceImpl(isar: sl()),
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
    () => NotificationLocalDataSourceImpl(isar: sl()),
  );

  // Push delivery pipeline.
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  // Image cache. Wifi detection is approximated by the existing connectivity
  // check: InternetConnectionChecker reports reachability, not connection
  // type, so "connected" is treated as unmetered only when the platform
  // exposes nothing better. Erring toward not downloading would leave images
  // permanently blank for users who are always on mobile data.
  sl.registerLazySingleton(
    () => NotificationImageCache(
      isOnWifi: () => sl<NetworkInfo>().isConnected,
    ),
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
      isar: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => NotificationBadgeService(repository: sl(), plugin: sl()),
  );

  // Delivery testing and development seed data. Registered unconditionally;
  // NotificationSeedRunner itself refuses to run under kReleaseMode, so the
  // guard lives with the behaviour rather than with the wiring.
  sl.registerLazySingleton(
    () => NotificationTestService(
      plugin: sl(),
      presenter: sl(),
      functions: FirebaseFunctions.instance,
    ),
  );

  sl.registerLazySingleton(() => NotificationSeedRunner(isar: sl()));

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

  // Features - Security
  sl.registerFactory(
    () => SecurityBloc(
      watchGates: sl(),
      createGate: sl(),
      updateGate: sl(),
      recordStudentMovement: sl(),
      watchStudentMovements: sl(),
      recordStaffMovement: sl(),
      watchStaffMovements: sl(),
      reportIncident: sl(),
      watchIncidents: sl(),
      updateIncidentStatus: sl(),
      triggerEmergency: sl(),
      watchActiveEmergencies: sl(),
      resolveEmergency: sl(),
      recordPatrol: sl(),
      watchPatrols: sl(),
      getSecurityDashboardStats: sl(),
      reportFoundItem: sl(),
      claimItem: sl(),
      watchLostAndFound: sl(),
    ),
  );

  sl.registerLazySingleton(() => WatchGates(sl()));
  sl.registerLazySingleton(() => CreateGate(sl()));
  sl.registerLazySingleton(() => UpdateGate(sl()));
  sl.registerLazySingleton(() => RecordStudentMovement(sl()));
  sl.registerLazySingleton(() => WatchStudentMovements(sl()));
  sl.registerLazySingleton(() => RecordStaffMovement(sl()));
  sl.registerLazySingleton(() => WatchStaffMovements(sl()));
  sl.registerLazySingleton(() => ReportIncident(sl()));
  sl.registerLazySingleton(() => WatchIncidents(sl()));
  sl.registerLazySingleton(() => UpdateIncidentStatus(sl()));
  sl.registerLazySingleton(() => TriggerEmergency(sl()));
  sl.registerLazySingleton(() => WatchActiveEmergencies(sl()));
  sl.registerLazySingleton(() => ResolveEmergency(sl()));
  sl.registerLazySingleton(() => RecordPatrol(sl()));
  sl.registerLazySingleton(() => WatchPatrols(sl()));
  sl.registerLazySingleton(() => GetSecurityDashboardStats(sl()));
  sl.registerLazySingleton(() => ReportFoundItem(sl()));
  sl.registerLazySingleton(() => ClaimItem(sl()));
  sl.registerLazySingleton(() => WatchLostAndFound(sl()));
  sl.registerLazySingleton(() => GetPickupAuthorizations(sl()));
  sl.registerLazySingleton(() => AddPickupAuthorization(sl()));
  sl.registerLazySingleton(() => SyncSecurityData(sl()));

  sl.registerLazySingleton<SecurityRepository>(
    () => SecurityRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<SecurityRemoteDataSource>(
    () => SecurityRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<SecurityLocalDataSource>(
    () => SecurityLocalDataSourceImpl(isar: sl()),
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
    () => SubjectTeacherDashboardBloc(studentRepository: sl()),
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
    () => SubjectTeacherLocalDataSourceImpl(isar: sl()),
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
  sl.registerLazySingleton(() => UpdateStaffMember(sl()));
  sl.registerLazySingleton(() => SetNewPassword(sl()));

  // Admin - Staff Attendance / Subscription
  sl.registerLazySingleton(() => StaffAttendanceRepository());
  sl.registerLazySingleton(() => SubscriptionRepository());

  // Features - Structure
  sl.registerFactory(() => StructureBloc(repository: sl()));

  sl.registerLazySingleton<StructureRepository>(
    () =>
        StructureRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton<StructureRemoteDataSource>(
    () => StructureRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<StructureLocalDataSource>(
    () => StructureLocalDataSourceImpl(isar: sl()),
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
    () => BiometricLocalDataSourceImpl(sl()),
  );

  // `VerifyFingerprint`/`EnrollFingerprint` already depended on this but it
  // was never registered - pre-existing gap, would throw as soon as either
  // usecase was resolved. Fixed here since `IdentityResolverImpl` (Phase 1
  // verification engine) is the first thing that forces `VerifyFingerprint`
  // to actually resolve.
  sl.registerLazySingleton<BiometricDeviceService>(() => MockBiometricDeviceService());

  // Features - Verification (shared verification engine, Phase 1: Security/Gate)
  sl.registerFactory(
    () => VerificationSessionBloc(
      identityResolver: sl(),
      policyEvaluator: sl(),
      eventRecorder: sl(),
      feedbackService: sl(),
      recordStudentMovement: sl(),
      recordStaffMovement: sl(),
    ),
  );

  sl.registerFactory(
    () => CredentialScanBloc(adapters: {
      ScanCredentialKind.qr: sl<QrCredentialReaderAdapter>(),
      ScanCredentialKind.nfc: sl<NfcCredentialReaderAdapter>(),
      ScanCredentialKind.fingerprint: sl<FingerprintCredentialReaderAdapter>(),
    }),
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
    () => PermissionEvaluatorImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<VerificationPolicyEvaluator>(
    () => GateVerificationPolicy(permissionEvaluator: sl(), securityRepository: sl()),
  );

  sl.registerLazySingleton<VerificationEventRecorder>(
    () => VerificationEventRecorderImpl(localDataSource: sl(), firestore: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton<VerificationFeedbackService>(() => HapticVerificationFeedbackService());

  sl.registerLazySingleton<VerificationLocalDataSource>(() => VerificationLocalDataSourceImpl(sl()));

  sl.registerLazySingleton<NfcCredentialRepository>(
    () => NfcCredentialRepositoryImpl(localDataSource: sl(), firestore: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(
    () => NfcCredentialService(nfcCredentialRepository: sl(), studentIdentityRepository: sl()),
  );

  sl.registerLazySingleton(() => QrCredentialReaderAdapter());
  sl.registerLazySingleton(() => NfcCredentialReaderAdapter());
  sl.registerLazySingleton(() => FingerprintCredentialReaderAdapter(sl()));

  //! Printer Service
  sl.registerLazySingleton<PrinterService>(() => ThermalPrinterService());

  //! External
  final preferences = await SharedPreferences.getInstance();
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    VisitorIsarSchema,
    VisitorBlacklistIsarSchema,
    PreApprovedVisitorIsarSchema,
    ScheduledVisitIsarSchema,
    PackageDeliveryIsarSchema,
    StudentCacheIsarSchema,
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
    SecurityIncidentIsarSchema,
    StudentMovementIsarSchema,
    StaffMovementIsarSchema,
    EmergencyEventIsarSchema,
    SecurityPatrolIsarSchema,
    LostAndFoundItemIsarSchema,
    PickupAuthorizationIsarSchema,
    EducationalLevelIsarSchema,
    AcademicYearIsarSchema,
    AcademicTermIsarSchema,
    SchoolClassIsarSchema,
    ClassStreamIsarSchema,
    SubjectIsarSchema,
    DepartmentIsarSchema,
    StaffDesignationIsarSchema,
    StaffRoleIsarSchema,
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
  ], directory: dir.path);
  sl.registerLazySingleton(() => isar);

  sl.registerLazySingleton(() => preferences);

  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => FirebaseFunctions.instance);
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => GoogleSheetsService());
}
