import '../../../domain/entities/library_resource.dart';
import '../../../domain/entities/library_borrowing.dart';

/// No Isar/isar-model import here on purpose - see
/// library_local_data_source_mobile.dart for why. Mobile and web
/// implementations are selected at compile time via
/// library_local_data_source_factory.dart's conditional import.
abstract class LibraryLocalDataSource {
  Future<void> cacheResources(List<LibraryResource> resources);
  Future<List<LibraryResource>> getCachedResources(String schoolId);
  Future<void> cacheBorrowings(List<LibraryBorrowing> borrowings);
  Future<List<LibraryBorrowing>> getCachedBorrowings(
    String schoolId, {
    String? borrowerId,
  });
  Future<void> clearCache(String schoolId);
}
