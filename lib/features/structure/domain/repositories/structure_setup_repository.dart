import '../entities/structure_setup_preferences.dart';

abstract class StructureSetupRepository {
  Stream<StructureSetupPreferences> watchPreferences();
  Future<void> savePreferences(StructureSetupPreferences preferences);
}
