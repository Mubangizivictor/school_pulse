import 'package:cloud_functions/cloud_functions.dart';

class IntegrationCenterService {
  IntegrationCenterService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;
  final FirebaseFunctions _functions;

  Future<List<Map<String, dynamic>>> load() async {
    final result = await _functions
        .httpsCallable('getIntegrationCenter')
        .call<Map<String, dynamic>>();
    return List<Map<String, dynamic>>.from(
      (result.data['integrations'] as List? ?? const []).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    );
  }

  Future<void> save(
    String key, {
    required Map<String, String> configuration,
    required String account,
    required bool enabled,
  }) => _functions.httpsCallable('saveIntegrationMetadata').call({
    'integrationKey': key,
    'configuration': configuration,
    'connectedAccountDisplay': account,
    'enabled': enabled,
  });
  Future<Map<String, dynamic>> test(String key) async =>
      Map<String, dynamic>.from(
        (await _functions
                .httpsCallable('testIntegrationConnection')
                .call<Map<String, dynamic>>({'integrationKey': key}))
            .data,
      );
  Future<void> disconnect(String key) => _functions
      .httpsCallable('disconnectIntegration')
      .call({'integrationKey': key});
}
