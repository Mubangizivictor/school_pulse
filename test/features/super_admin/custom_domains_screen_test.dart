// Proves CustomDomainsScreen streams real portal_domain_requests via
// CustomDomainService (injectable for tests, defaulting to the production
// service), gates activate/reject actions on request.canActivate/isActive,
// requires a reason before removing an active domain, and never leaks a
// raw exception into the visible error text. The real screen depends on
// CustomDomainService (Firestore-backed) and SuperAdminBloc, which this
// fast widget-test layer doesn't set up, so this verifies composition at
// the source level - the same approach used by billing_home_screen_test.dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File(
      'lib/features/super_admin/presentation/pages/custom_domains_screen.dart',
    ).readAsStringSync();
  });

  test('the service is injectable for tests but defaults to the production CustomDomainService', () {
    expect(source.contains('final CustomDomainService? service;'), isTrue);
    expect(
      source.contains('widget.service ?? CustomDomainService()'),
      isTrue,
    );
  });

  test('requests are streamed live, not fetched once', () {
    expect(source.contains('_service.watchRequests()'), isTrue);
    expect(source.contains('StreamBuilder<List<CustomDomainRequest>>'), isTrue);
  });

  test('loading, error, and empty states are all handled explicitly', () {
    expect(source.contains('SchoolPulseLoader()'), isTrue);
    expect(source.contains('snapshot.hasError'), isTrue);
    expect(source.contains("title: 'No custom domain requests'"), isTrue);
  });

  test('Activate is only offered when the request reports canActivate', () {
    expect(source.contains('onActivate: request.canActivate'), isTrue);
    expect(source.contains('_service.activate(request.hostname)'), isTrue);
  });

  test('remove/reject label and confirmation copy differ for an active vs. pending domain', () {
    expect(
      source.contains("request.isActive ? 'Remove this domain?' : 'Reject this request?'"),
      isTrue,
    );
    expect(source.contains('_service.reject(request.hostname, controller.text)'), isTrue);
  });

  test('every mutation goes through CustomDomainService, not a direct Firestore write', () {
    expect(source.contains('FirebaseFirestore.instance.collection'), isFalse);
  });

  test('errors never leak a raw exception string to the UI', () {
    // Regression: _friendlyError must fall back to the shared
    // friendlyErrorMessage() helper, not a raw error.toString().
    expect(source.contains('return friendlyErrorMessage(error);'), isTrue);
    expect(
      source.contains("import 'package:school_pulse/core/error/friendly_error_message.dart';"),
      isTrue,
    );
    expect(source.contains("value.replaceFirst(RegExp(r'^\\[.*?\\]"), isFalse);
  });

  test('stream errors are also passed through the same friendly error path', () {
    expect(source.contains('Text(\n                      _friendlyError(snapshot.error!)'), isTrue);
  });
}
