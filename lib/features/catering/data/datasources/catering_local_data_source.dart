import '../../domain/entities/meal_record.dart';

/// No Isar/isar-model import here on purpose - see
/// catering_local_data_source_mobile.dart for why. Mobile and web
/// implementations are selected at compile time via
/// catering_local_data_source_factory.dart's conditional import.
///
/// Mobile is a local-first write queue for dining-hall meal scans done
/// without connectivity - cacheMealRecord always writes locally first
/// (isSynced = false); getUnsyncedRecords/markAsSynced exist for a future
/// sync flusher (not yet wired up anywhere in the app - confirmed no
/// current caller). Web has no offline dining-hall scanning use case -
/// writes go straight to Firestore, so nothing is ever pending.
abstract class CateringLocalDataSource {
  Future<void> cacheMealRecord(MealRecord record);
  Future<List<MealRecord>> getUnsyncedRecords();
  Future<void> markAsSynced(List<String> ids);
}
