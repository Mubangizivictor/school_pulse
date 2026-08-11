import '../../../domain/entities/library_resource.dart';
import '../../../domain/entities/library_borrowing.dart';
import 'library_local_data_source.dart';

LibraryLocalDataSource create({dynamic isar, dynamic remote}) =>
    _LibraryLocalDataSourceStub();

class _LibraryLocalDataSourceStub implements LibraryLocalDataSource {
  @override
  Future<void> cacheResources(List<LibraryResource> resources) =>
      _unsupported();

  @override
  Future<List<LibraryResource>> getCachedResources(String schoolId) =>
      _unsupported();

  @override
  Future<void> cacheBorrowings(List<LibraryBorrowing> borrowings) =>
      _unsupported();

  @override
  Future<List<LibraryBorrowing>> getCachedBorrowings(
    String schoolId, {
    String? borrowerId,
  }) => _unsupported();

  @override
  Future<void> clearCache(String schoolId) => _unsupported();

  Never _unsupported() =>
      throw UnimplementedError('No LibraryLocalDataSource for this platform');
}
