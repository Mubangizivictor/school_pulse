import 'package:isar/isar.dart';
import 'package:school_pulse/features/biometrics/data/models/biometric_template_isar.dart';

abstract class BiometricLocalDataSource {
  Future<void> saveTemplate(BiometricTemplateIsar template);
  Future<BiometricTemplateIsar?> getTemplate(String personId);
  Future<List<BiometricTemplateIsar>> getPendingSyncTemplates();
  Future<void> markTemplateAsSynced(String personId);
  Future<void> clearAllTemplates();
}

class BiometricLocalDataSourceImpl implements BiometricLocalDataSource {
  final Isar isar;

  BiometricLocalDataSourceImpl(this.isar);

  @override
  Future<void> saveTemplate(BiometricTemplateIsar template) async {
    await isar.writeTxn(() async {
      await isar.biometricTemplateIsars.put(template);
    });
  }

  @override
  Future<BiometricTemplateIsar?> getTemplate(String personId) async {
    return await isar.biometricTemplateIsars.filter().personIdEqualTo(personId).findFirst();
  }

  @override
  Future<List<BiometricTemplateIsar>> getPendingSyncTemplates() async {
    return await isar.biometricTemplateIsars.filter().isSyncedEqualTo(false).findAll();
  }

  @override
  Future<void> markTemplateAsSynced(String personId) async {
    await isar.writeTxn(() async {
      final template = await isar.biometricTemplateIsars.filter().personIdEqualTo(personId).findFirst();
      if (template != null) {
        template.isSynced = true;
        await isar.biometricTemplateIsars.put(template);
      }
    });
  }

  @override
  Future<void> clearAllTemplates() async {
    await isar.writeTxn(() async {
      await isar.biometricTemplateIsars.clear();
    });
  }
}
