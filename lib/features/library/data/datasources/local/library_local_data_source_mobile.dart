import 'package:isar/isar.dart';
import '../../../domain/entities/library_resource.dart';
import '../../../domain/entities/library_borrowing.dart';
import '../../models/library_isar_models.dart';
import 'library_local_data_source.dart';

LibraryLocalDataSource create({dynamic isar, dynamic remote}) =>
    LibraryLocalDataSourceImpl(isar: isar as Isar);

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  final Isar isar;

  LibraryLocalDataSourceImpl({required this.isar});

  @override
  Future<void> cacheResources(List<LibraryResource> resources) async {
    await isar.writeTxn(() async {
      await isar.libraryResourceIsars.putAll(
        resources.map(LibraryResourceIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<LibraryResource>> getCachedResources(String schoolId) async {
    final cached = await isar.libraryResourceIsars
        .filter()
        .schoolIdEqualTo(schoolId)
        .findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> cacheBorrowings(List<LibraryBorrowing> borrowings) async {
    await isar.writeTxn(() async {
      await isar.libraryBorrowingIsars.putAll(
        borrowings.map(LibraryBorrowingIsar.fromEntity).toList(),
      );
    });
  }

  @override
  Future<List<LibraryBorrowing>> getCachedBorrowings(
    String schoolId, {
    String? borrowerId,
  }) async {
    var query = isar.libraryBorrowingIsars.filter().schoolIdEqualTo(schoolId);
    if (borrowerId != null) {
      query = query.borrowerIdEqualTo(borrowerId);
    }
    final cached = await query.findAll();
    return cached.map((c) => c.toEntity()).toList();
  }

  @override
  Future<void> clearCache(String schoolId) async {
    await isar.writeTxn(() async {
      await isar.libraryResourceIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .deleteAll();
      await isar.libraryBorrowingIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .deleteAll();
      await isar.libraryReservationIsars
          .filter()
          .schoolIdEqualTo(schoolId)
          .deleteAll();
    });
  }
}
