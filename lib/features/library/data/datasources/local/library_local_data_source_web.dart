import '../../../domain/entities/library_resource.dart';
import '../../../domain/entities/library_borrowing.dart';
import '../library_remote_data_source.dart';
import 'library_local_data_source.dart';

LibraryLocalDataSource create({dynamic isar, dynamic remote}) =>
    LibraryLocalDataSourceWeb(remote: remote as LibraryRemoteDataSource);

/// No local database on web - reads straight from Firestore via the
/// existing remote datasource (taking the first snapshot of its watch
/// streams for one-shot reads). No caching, no offline behavior.
class LibraryLocalDataSourceWeb implements LibraryLocalDataSource {
  final LibraryRemoteDataSource remote;

  LibraryLocalDataSourceWeb({required this.remote});

  @override
  Future<void> cacheResources(List<LibraryResource> resources) async {}

  @override
  Future<List<LibraryResource>> getCachedResources(String schoolId) {
    return remote.watchResources(schoolId).first;
  }

  @override
  Future<void> cacheBorrowings(List<LibraryBorrowing> borrowings) async {}

  @override
  Future<List<LibraryBorrowing>> getCachedBorrowings(
    String schoolId, {
    String? borrowerId,
  }) {
    return remote.watchBorrowingHistory(schoolId, borrowerId: borrowerId).first;
  }

  @override
  Future<void> clearCache(String schoolId) async {}
}
