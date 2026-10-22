import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/institution/domain/entities/access_mode.dart';
import 'package:school_pulse/features/institution/domain/entities/institution_context.dart';
import 'package:school_pulse/features/super_admin/domain/entities/school.dart';

InstitutionContext _trialSchool({
  required DateTime expiry,
  String subscriptionStatus = 'trial',
  String? accessMode,
}) {
  return InstitutionContext(
    institutionId: 'school-1',
    displayLabel: 'Trial School',
    classification: InstitutionClassification.primary,
    divisions: const [],
    status: SchoolStatus.trial,
    enabledFeatures: const [],
    loadedAt: DateTime(2026, 1, 1),
    subscriptionExpiry: expiry,
    subscriptionStatus: subscriptionStatus,
    hasEverActivated: false,
    accessMode: accessMode,
  );
}

void main() {
  final future = DateTime.now().add(const Duration(days: 20));
  final past = DateTime.now().subtract(const Duration(days: 1));

  test('an unexpired free trial has full access without payment', () {
    final ctx = _trialSchool(expiry: future);
    expect(ctx.isInActiveTrial, isTrue);
    expect(ctx.isInitialPaymentRequired, isFalse);
    expect(ctx.resolvedAccessMode, AccessMode.full);
  });

  test('an expired trial no longer counts as active', () {
    final ctx = _trialSchool(expiry: past);
    expect(ctx.isInActiveTrial, isFalse);
    expect(ctx.isInitialPaymentRequired, isTrue);
  });

  test('the server read-only flag wins once the trial has ended', () {
    final ctx = _trialSchool(
      expiry: past,
      subscriptionStatus: 'payment_due',
      accessMode: 'readOnly',
    );
    expect(ctx.resolvedAccessMode, AccessMode.readOnly);
  });

  test(
    'a trial school awaiting payment (pre-trial approvals) is still gated',
    () {
      final ctx = _trialSchool(
        expiry: past,
        subscriptionStatus: 'awaiting_payment',
      );
      expect(ctx.isInitialPaymentRequired, isTrue);
    },
  );
}
