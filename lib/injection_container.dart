import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:school_pulse/features/admin/data/repositories/visitor_repository.dart';
import 'package:school_pulse/features/admin/domain/usecases/get_admin_dashboard_stats.dart';
import 'package:school_pulse/features/admin/presentation/bloc/admin_dashboard_bloc.dart';
import 'package:school_pulse/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:school_pulse/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:school_pulse/features/auth/domain/repositories/auth_repository.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_parent.dart';
import 'package:school_pulse/features/auth/domain/usecases/complete_parent_pin_setup.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_current_user.dart';
import 'package:school_pulse/features/auth/domain/usecases/login_with_email.dart';
import 'package:school_pulse/features/auth/domain/usecases/logout.dart';
import 'package:school_pulse/features/auth/domain/usecases/create_staff_account.dart';
import 'package:school_pulse/features/auth/domain/usecases/set_new_password.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/academic/domain/usecases/get_academic_records.dart';
import 'package:school_pulse/features/academic/domain/usecases/get_attendance_records.dart';
import 'package:school_pulse/features/academic/domain/repositories/academic_repository.dart';
import 'package:school_pulse/features/academic/data/repositories/academic_repository_impl.dart';
import 'package:school_pulse/features/academic/data/datasources/academic_remote_data_source.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/domain/usecases/get_fees.dart';
import 'package:school_pulse/features/finance/domain/usecases/get_payment_history.dart';
import 'package:school_pulse/features/finance/domain/usecases/get_all_fees.dart';
import 'package:school_pulse/features/finance/domain/usecases/get_all_payment_history.dart';
import 'package:school_pulse/features/finance/domain/usecases/process_payment.dart';
import 'package:school_pulse/features/finance/domain/repositories/finance_repository.dart';
import 'package:school_pulse/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:school_pulse/features/finance/data/datasources/finance_remote_data_source.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/domain/usecases/get_health_visits.dart';
import 'package:school_pulse/features/health/domain/repositories/health_repository.dart';
import 'package:school_pulse/features/health/data/repositories/health_repository_impl.dart';
import 'package:school_pulse/features/health/data/datasources/health_remote_data_source.dart';
import 'package:school_pulse/features/transport/presentation/bloc/transport_bloc.dart';
import 'package:school_pulse/features/transport/domain/usecases/get_transport_info.dart';
import 'package:school_pulse/features/transport/domain/repositories/transport_repository.dart';
import 'package:school_pulse/features/transport/data/repositories/transport_repository_impl.dart';
import 'package:school_pulse/features/transport/data/datasources/transport_remote_data_source.dart';
import 'package:school_pulse/features/library/presentation/bloc/library_bloc.dart';
import 'package:school_pulse/features/library/domain/usecases/get_borrowed_books.dart';
import 'package:school_pulse/features/library/domain/usecases/get_all_borrowed_books.dart';
import 'package:school_pulse/features/library/domain/usecases/issue_book.dart';
import 'package:school_pulse/features/library/domain/usecases/return_book.dart';
import 'package:school_pulse/features/library/domain/repositories/library_repository.dart';
import 'package:school_pulse/features/library/data/repositories/library_repository_impl.dart';
import 'package:school_pulse/features/library/data/datasources/library_remote_data_source.dart';
import 'package:school_pulse/features/discipline/presentation/bloc/discipline_bloc.dart';
import 'package:school_pulse/features/discipline/domain/usecases/get_discipline_incidents.dart';
import 'package:school_pulse/features/discipline/domain/usecases/get_recent_discipline_incidents.dart';
import 'package:school_pulse/features/discipline/domain/usecases/log_discipline_incident.dart';
import 'package:school_pulse/features/discipline/domain/repositories/discipline_repository.dart';
import 'package:school_pulse/features/discipline/data/repositories/discipline_repository_impl.dart';
import 'package:school_pulse/features/discipline/data/datasources/discipline_remote_data_source.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/domain/usecases/get_students_by_ids.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/student/domain/usecases/create_student.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'package:school_pulse/features/student/domain/usecases/manage_parent_access_codes.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/student/data/repositories/student_repository_impl.dart';
import 'package:school_pulse/features/student/data/datasources/student_remote_data_source.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:school_pulse/features/notifications/domain/usecases/get_alerts.dart';
import 'package:school_pulse/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:school_pulse/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:school_pulse/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_students_by_class.dart';
import 'package:school_pulse/features/teacher/domain/usecases/submit_attendance.dart';
import 'package:school_pulse/features/teacher/domain/usecases/submit_marks.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_attendance_history.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_teacher_dashboard_stats.dart';
import 'package:school_pulse/features/teacher/domain/repositories/teacher_repository.dart';
import 'package:school_pulse/features/teacher/data/repositories/teacher_repository_impl.dart';
import 'package:school_pulse/features/teacher/data/datasources/teacher_remote_data_source.dart';
import 'package:school_pulse/features/gatekeeper/presentation/bloc/gatekeeper_bloc.dart';
import 'package:school_pulse/features/gatekeeper/domain/repositories/gatekeeper_repository.dart';
import 'package:school_pulse/features/gatekeeper/data/repositories/gatekeeper_repository_impl.dart';
import 'package:school_pulse/features/gatekeeper/data/datasources/gatekeeper_remote_data_source.dart';
import 'package:school_pulse/features/receptionist/presentation/bloc/receptionist_bloc.dart';
import 'package:school_pulse/features/receptionist/domain/repositories/receptionist_repository.dart';
import 'package:school_pulse/features/receptionist/data/repositories/receptionist_repository_impl.dart';
import 'package:school_pulse/features/receptionist/data/datasources/receptionist_remote_data_source.dart';
import 'package:school_pulse/features/catering/presentation/bloc/catering_bloc.dart';
import 'package:school_pulse/features/catering/domain/repositories/catering_repository.dart';
import 'package:school_pulse/features/catering/data/repositories/catering_repository_impl.dart';
import 'package:school_pulse/features/catering/data/datasources/catering_remote_data_source.dart';
import 'package:school_pulse/features/games/presentation/bloc/games_bloc.dart';
import 'package:school_pulse/features/games/domain/repositories/games_repository.dart';
import 'package:school_pulse/features/games/data/repositories/games_repository_impl.dart';
import 'package:school_pulse/features/games/data/datasources/games_remote_data_source.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_bloc.dart';
import 'package:school_pulse/features/security/domain/repositories/security_repository.dart';
import 'package:school_pulse/features/security/data/repositories/security_repository_impl.dart';
import 'package:school_pulse/features/security/data/datasources/security_remote_data_source.dart';
import 'package:school_pulse/features/transport/presentation/bloc/transport_coordinator_bloc.dart';
import 'package:school_pulse/features/transport/domain/repositories/transport_coordinator_repository.dart';
import 'package:school_pulse/features/transport/data/repositories/transport_coordinator_repository_impl.dart';
import 'package:school_pulse/features/exams/presentation/bloc/exams_bloc.dart';
import 'package:school_pulse/features/exams/domain/repositories/exams_repository.dart';
import 'package:school_pulse/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:school_pulse/features/exams/data/datasources/exams_remote_data_source.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/domain/repositories/matron_repository.dart';
import 'package:school_pulse/features/matron/data/repositories/matron_repository_impl.dart';
import 'package:school_pulse/features/matron/data/datasources/matron_remote_data_source.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/domain/usecases/get_dean_stats.dart';
import 'package:school_pulse/features/dean/domain/repositories/dean_repository.dart';
import 'package:school_pulse/features/dean/data/repositories/dean_repository_impl.dart';
import 'package:school_pulse/features/dean/data/datasources/dean_remote_data_source.dart';
import 'package:school_pulse/features/admin/data/repositories/system_config_repository.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/admin/data/repositories/school_structure_repository.dart';
import 'package:school_pulse/features/admin/data/repositories/staff_attendance_repository.dart';
import 'package:school_pulse/features/admin/presentation/bloc/system_config_bloc.dart';
import 'package:school_pulse/core/network/network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:school_pulse/features/auth/domain/usecases/update_staff_member.dart';
import 'package:school_pulse/features/auth/domain/usecases/delete_staff_member.dart';
import 'package:school_pulse/features/auth/domain/usecases/toggle_staff_status.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginWithEmail: sl(),
      loginParent: sl(),
      completeParentPinSetup: sl(),
      logout: sl(),
      getCurrentUser: sl(),
      resolveParentAccessCode: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginWithEmail(sl()));
  sl.registerLazySingleton(() => LoginParent(sl()));
  sl.registerLazySingleton(() => CompleteParentPinSetup(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => CreateStaffAccount(sl()));
  sl.registerLazySingleton(() => SetNewPassword(sl()));
  sl.registerLazySingleton(() => GetStaffMembers(sl()));
  sl.registerLazySingleton(() => ToggleStaffStatus(sl()));
  sl.registerLazySingleton(() => UpdateStaffMember(sl()));
  sl.registerLazySingleton(() => DeleteStaffMember(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      functions: sl(),
    ),
  );

  //! Features - Academic
  // Bloc
  sl.registerFactory(
    () => AcademicBloc(
      getAcademicRecords: sl(),
      getAttendanceRecords: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAcademicRecords(sl()));
  sl.registerLazySingleton(() => GetAttendanceRecords(sl()));

  // Repository
  sl.registerLazySingleton<AcademicRepository>(
    () => AcademicRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AcademicRemoteDataSource>(
    () => AcademicRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Finance
  // Bloc
  sl.registerFactory(
    () => FinanceBloc(
      getFees: sl(),
      getPaymentHistory: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetFees(sl()));
  sl.registerLazySingleton(() => GetPaymentHistory(sl()));
  sl.registerLazySingleton(() => GetAllFees(sl()));
  sl.registerLazySingleton(() => GetAllPaymentHistory(sl()));
  sl.registerLazySingleton(() => ProcessPayment(sl()));

  // Repository
  sl.registerLazySingleton<FinanceRepository>(
    () => FinanceRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<FinanceRemoteDataSource>(
    () => FinanceRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Health
  // Bloc
  sl.registerFactory(() => HealthBloc(getHealthVisits: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetHealthVisits(sl()));

  // Repository
  sl.registerLazySingleton<HealthRepository>(
    () => HealthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<HealthRemoteDataSource>(
    () => HealthRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Transport
  // Bloc
  sl.registerFactory(() => TransportBloc(getTransportInfo: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetTransportInfo(sl()));

  // Repository
  sl.registerLazySingleton<TransportRepository>(
    () => TransportRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<TransportRemoteDataSource>(
    () => TransportRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Library
  // Bloc
  sl.registerFactory(() => LibraryBloc(getBorrowedBooks: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetBorrowedBooks(sl()));
  sl.registerLazySingleton(() => GetAllBorrowedBooks(sl()));
  sl.registerLazySingleton(() => IssueBook(sl()));
  sl.registerLazySingleton(() => ReturnBook(sl()));

  // Repository
  sl.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<LibraryRemoteDataSource>(
    () => LibraryRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Discipline
  // Bloc
  sl.registerFactory(
    () => DisciplineBloc(
      getDisciplineIncidents: sl(),
      getRecentDisciplineIncidents: sl(),
      logDisciplineIncident: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDisciplineIncidents(sl()));
  sl.registerLazySingleton(() => GetRecentDisciplineIncidents(sl()));
  sl.registerLazySingleton(() => LogDisciplineIncident(sl()));

  // Repository
  sl.registerLazySingleton<DisciplineRepository>(
    () => DisciplineRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<DisciplineRemoteDataSource>(
    () => DisciplineRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Student
  // Bloc
  sl.registerFactory(() => StudentsBloc(getStudentsByIds: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetStudentsByIds(sl()));
  sl.registerLazySingleton(() => GetAllStudents(sl()));
  sl.registerLazySingleton(() => CreateStudent(sl()));
  sl.registerLazySingleton(() => ResolveParentAccessCode(sl()));
  sl.registerLazySingleton(() => GetAllAccessCodes(sl()));
  sl.registerLazySingleton(() => CreateAccessCode(sl()));
  sl.registerLazySingleton(() => RegenerateAccessCode(sl()));
  sl.registerLazySingleton(() => ToggleAccessCodeStatus(sl()));
  sl.registerLazySingleton(() => UpdateAccessCode(sl()));
  sl.registerLazySingleton(() => DeleteAccessCode(sl()));

  // Repository
  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<StudentRemoteDataSource>(
    () => StudentRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Notifications
  // Bloc
  sl.registerFactory(() => NotificationsBloc(getAlerts: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetAlerts(sl()));

  // Repository
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Teacher
  // Bloc
  sl.registerFactory(
    () => TeacherBloc(
      getStudentsByClass: sl(),
      submitAttendance: sl(),
      submitMarks: sl(),
      getAttendanceHistory: sl(),
      getTeacherDashboardStats: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetStudentsByClass(sl()));
  sl.registerLazySingleton(() => SubmitAttendance(sl()));
  sl.registerLazySingleton(() => SubmitMarks(sl()));
  sl.registerLazySingleton(() => GetAttendanceHistory(sl()));
  sl.registerLazySingleton(() => GetTeacherDashboardStats(sl()));

  // Repository
  sl.registerLazySingleton<TeacherRepository>(
    () => TeacherRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<TeacherRemoteDataSource>(
    () => TeacherRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Gatekeeper
  // Bloc
  sl.registerFactory(() => GatekeeperBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<GatekeeperRepository>(
    () => GatekeeperRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<GatekeeperRemoteDataSource>(
    () => GatekeeperRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Receptionist
  // Bloc
  sl.registerFactory(() => ReceptionistBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<ReceptionistRepository>(
    () => ReceptionistRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ReceptionistRemoteDataSource>(
    () => ReceptionistRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Matron
  // Bloc
  sl.registerFactory(() => MatronBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<MatronRepository>(
    () => MatronRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<MatronRemoteDataSource>(
    () => MatronRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Catering
  // Bloc
  sl.registerFactory(() => CateringBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<CateringRepository>(
    () => CateringRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CateringRemoteDataSource>(
    () => CateringRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Games
  // Bloc
  sl.registerFactory(() => GamesBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<GamesRepository>(
    () => GamesRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<GamesRemoteDataSource>(
    () => GamesRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Security
  // Bloc
  sl.registerFactory(() => SecurityBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<SecurityRepository>(
    () => SecurityRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<SecurityRemoteDataSource>(
    () => SecurityRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Transport Coordinator
  // Bloc
  sl.registerFactory(() => TransportCoordinatorBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<TransportCoordinatorRepository>(
    () => TransportCoordinatorRepositoryImpl(remoteDataSource: sl()),
  );

  //! Features - Exams
  // Bloc
  sl.registerFactory(() => ExamsBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<ExamsRepository>(
    () => ExamsRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ExamsRemoteDataSource>(
    () => ExamsRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Dean
  // Bloc
  sl.registerFactory(() => DeanBloc(getDeanStats: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetDeanStats(sl()));

  // Repository
  sl.registerLazySingleton<DeanRepository>(
    () => DeanRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<DeanRemoteDataSource>(
    () => DeanRemoteDataSourceImpl(firestore: sl()),
  );

  //! Features - Admin Dashboard
  sl.registerFactory(() => AdminDashboardBloc(
        getAdminDashboardStats: sl(),
        auditRepository: sl(),
      ));
  sl.registerLazySingleton(() => GetAdminDashboardStats(
        authRepository: sl(),
        studentRepository: sl(),
        visitorRepository: sl(),
      ));
  sl.registerLazySingleton(() => VisitorRepository());
  sl.registerLazySingleton(() => AuditRepository());
  sl.registerLazySingleton(() => SchoolStructureRepository());
  sl.registerLazySingleton(() => StaffAttendanceRepository());

  //! System Config
  sl.registerFactory(() => SystemConfigBloc(repository: sl()));
  sl.registerLazySingleton(() => SystemConfigRepository());

  //! External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => FirebaseFunctions.instance);
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}
