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

  Future<Map<String, dynamic>> healthSummary() async => Map<String, dynamic>.from(
    (await _functions
            .httpsCallable('getIntegrationHealthSummary')
            .call<Map<String, dynamic>>())
        .data['summary'] as Map,
  );

  Future<List<Map<String, dynamic>>> listDevices() async {
    final result = await _functions
        .httpsCallable('listIntegrationDevices')
        .call<Map<String, dynamic>>();
    return List<Map<String, dynamic>>.from(
      (result.data['devices'] as List? ?? const []).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    );
  }

  Future<String> registerDevice(Map<String, dynamic> device) async {
    final result = await _functions
        .httpsCallable('registerIntegrationDevice')
        .call<Map<String, dynamic>>(device);
    return result.data['deviceId'] as String;
  }

  Future<void> updateDeviceStatus(String deviceId, String status) =>
      _functions.httpsCallable('updateIntegrationDeviceStatus').call({
        'deviceId': deviceId,
        'status': status,
      });

  Future<void> revokeDevice(String deviceId) => _functions
      .httpsCallable('revokeIntegrationDevice')
      .call({'deviceId': deviceId});

  Future<List<Map<String, dynamic>>> listWebhooks() async {
    final result = await _functions
        .httpsCallable('listIntegrationWebhooks')
        .call<Map<String, dynamic>>();
    return List<Map<String, dynamic>>.from(
      (result.data['webhooks'] as List? ?? const []).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    );
  }

  /// Returns the newly created webhook's raw signing secret. This is the
  /// only moment it is ever available - the caller must show it once and
  /// never persist it client-side.
  Future<Map<String, dynamic>> createWebhook({
    required String url,
    required List<String> events,
  }) async => Map<String, dynamic>.from(
    (await _functions
            .httpsCallable('createIntegrationWebhook')
            .call<Map<String, dynamic>>({'url': url, 'events': events}))
        .data,
  );

  Future<void> disableWebhook(String webhookId) => _functions
      .httpsCallable('disableIntegrationWebhook')
      .call({'webhookId': webhookId});

  Future<List<Map<String, dynamic>>> syncJobs(String integrationId) async {
    final result = await _functions
        .httpsCallable('getIntegrationSyncJobs')
        .call<Map<String, dynamic>>({'integrationId': integrationId});
    return List<Map<String, dynamic>>.from(
      (result.data['jobs'] as List? ?? const []).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    );
  }

  Future<String> startSync(
    String integrationId, {
    String direction = 'export',
    String entityType = 'unknown',
  }) async {
    final result = await _functions
        .httpsCallable('startIntegrationSync')
        .call<Map<String, dynamic>>({
          'integrationId': integrationId,
          'direction': direction,
          'entityType': entityType,
        });
    return result.data['syncJobId'] as String;
  }
}
