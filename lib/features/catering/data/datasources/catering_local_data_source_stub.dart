import '../../domain/entities/meal_record.dart';
import 'catering_local_data_source.dart';

CateringLocalDataSource create({dynamic isar, dynamic remote}) =>
    _CateringLocalDataSourceStub();

class _CateringLocalDataSourceStub implements CateringLocalDataSource {
  @override
  Future<void> cacheMealRecord(MealRecord record) => _unsupported();
  @override
  Future<List<MealRecord>> getUnsyncedRecords() => _unsupported();
  @override
  Future<void> markAsSynced(List<String> ids) => _unsupported();

  Never _unsupported() =>
      throw UnimplementedError('No CateringLocalDataSource for this platform');
}
