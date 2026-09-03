import 'package:get_it/get_it.dart';

import 'package:school_pulse/features/super_admin/data/datasources/super_admin_remote_datasource.dart';
import 'package:school_pulse/features/super_admin/data/repositories/super_admin_repository_impl.dart';
import 'package:school_pulse/features/super_admin/domain/repositories/super_admin_repository.dart';
import 'package:school_pulse/features/super_admin/presentation/bloc/super_admin_bloc.dart';

/// Dependency-injection wiring for the SaaS owner console (`super_admin`
/// feature). Called once from `injection_container.dart`'s `init()` so the
/// bloc / repository / datasource graph for this module lives inside the
/// module.
///
/// Note: [SecuritySettingsRemoteDataSource] and [OwnerSessionRemoteDataSource]
/// are still registered directly in `init()`, right after the core
/// `FirebaseFirestore` / `FirebaseAuth` singletons they depend on - their
/// registration order matters, so they are deliberately not moved here.
void registerSuperAdmin(GetIt sl) {
  sl.registerFactory(() => SuperAdminBloc(repository: sl(), auth: sl()));

  sl.registerLazySingleton<SuperAdminRepository>(
    () => SuperAdminRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<SuperAdminRemoteDataSource>(
    () => SuperAdminRemoteDataSourceImpl(firestore: sl(), auth: sl()),
  );
}
