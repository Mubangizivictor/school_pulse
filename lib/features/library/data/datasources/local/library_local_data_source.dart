import 'package:isar/isar.dart';
import '../../models/library_isar_models.dart';

abstract class LibraryLocalDataSource {
  Future<void> cacheResources(List<LibraryResourceIsar> resources);
  Future<List<LibraryResourceIsar>> getCachedResources(String schoolId);
  Future<void> cacheBorrowings(List<LibraryBorrowingIsar> borrowings);
  Future<List<LibraryBorrowingIsar>> getCachedBorrowings(String schoolId, {String? borrowerId});
  Future<void> clearCache(String schoolId);
}

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  final Isar isar;

  LibraryLocalDataSourceImpl({required this.isar});

  @override
  Future<void> cacheResources(List<LibraryResourceIsar> resources) async {
    await isar.writeTxn(() async {
      await isar.libraryResourceIsars.putAll(resources);
    });
  }

  @override
  Future<List<LibraryResourceIsar>> getCachedResources(String schoolId) async {
    return await isar.libraryResourceIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .findAll();
  }

  @override
  Future<void> cacheBorrowings(List<LibraryBorrowingIsar> borrowings) async {
    await isar.writeTxn(() async {
      await isar.libraryBorrowingIsars.putAll(borrowings);
    });
  }

  @override
  Future<List<LibraryBorrowingIsar>> getCachedBorrowings(String schoolId, {String? borrowerId}) async {
    var query = isar.libraryBorrowingIsars.filter().schoolIdEqualTo(schoolId);
    if (borrowerId != null) {
      query = query.borrowerIdEqualTo(borrowerId);
    }
    return await query.findAll();
  }

  @override
  Future<void> clearCache(String schoolId) async {
    await isar.writeTxn(() async {
      await isar.libraryResourceIsars.filter().schoolIdEqualTo(schoolId).deleteAll();
      await isar.libraryBorrowingIsars.filter().schoolIdEqualTo(schoolId).deleteAll();
      await isar.libraryReservationIsars.filter().schoolIdEqualTo(schoolId).deleteAll();
    });
  }
}
