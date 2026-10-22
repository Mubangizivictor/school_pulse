import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/entities/manual_subscription_payment.dart';
import '../../domain/entities/subscription_plan.dart';

/// Thin owner-console boundary around the payment Cloud Functions. All
/// authorization, amount validation, activation and renewal calculations stay
/// server-side; this service never writes payment or school records directly.
class ManualPaymentService {
  ManualPaymentService({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFunctions _functions;

  /// [schoolId], when given, is enforced server-side by the callable (a
  /// real `where('schoolId', ...)` clause, not a client-side filter of an
  /// unscoped fetch) - see getManualPaymentsForOwner in
  /// public_functions/payments.js.
  Future<List<ManualSubscriptionPayment>> getPayments({
    ManualPaymentStatus? status,
    String? schoolId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final result = await _functions
        .httpsCallable('getManualPaymentsForOwner')
        .call<Map<String, dynamic>>({
          'status': status == null ? 'all' : _statusWire(status),
          'schoolId': ?schoolId,
          if (startDate != null)
            'startDateMs': startDate.millisecondsSinceEpoch,
          if (endDate != null) 'endDateMs': endDate.millisecondsSinceEpoch,
        });
    final raw = result.data['payments'] as List<dynamic>? ?? const [];
    return raw
        .map(
          (item) => ManualSubscriptionPayment.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);
  }

  Future<Uri> getProofUrl(String paymentId) async {
    final result = await _functions
        .httpsCallable('getManualPaymentProofUrl')
        .call<Map<String, dynamic>>({'paymentId': paymentId});
    final raw = result.data['url']?.toString() ?? '';
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme) {
      throw StateError('Payment proof URL was not returned by the server.');
    }
    return uri;
  }

  Future<void> approve(String paymentId) async {
    await _functions
        .httpsCallable('approveManualPayment')
        .call<Map<String, dynamic>>({'paymentId': paymentId});
  }

  Future<void> reject(String paymentId, String reason) async {
    await _functions
        .httpsCallable('rejectManualPayment')
        .call<Map<String, dynamic>>({
          'paymentId': paymentId,
          'reason': reason.trim(),
        });
  }

  Future<void> updatePlanPricing({
    required SubscriptionPlan plan,
    required int priceUgx,
    required BillingCycle billingCycle,
    required int termLengthDays,
  }) async {
    await _functions
        .httpsCallable('updateSubscriptionPlanPricing')
        .call<Map<String, dynamic>>({
          'planId': plan.id,
          'price': priceUgx,
          'billingCycle': billingCycle.name,
          'termLengthDays': termLengthDays,
        });
  }

  Future<void> updatePlan({
    required String planId,
    required String name,
    required String description,
    required int priceUgx,
    required BillingCycle billingCycle,
    required int termLengthDays,
    int trialDays = 0,
    required int maxStudents,
    required int maxStaff,
    required double storageLimitGb,
    int smsLimitPerMonth = 0,
    required List<String> includedFeatures,
    List<String> includedModules = const [],
    required bool isPublic,
    required bool isActive,
    required bool isPopular,
    required int displayOrder,
  }) async {
    await _functions
        .httpsCallable('updateSubscriptionPlan')
        .call<Map<String, dynamic>>({
          'planId': planId,
          'name': name,
          'description': description,
          'price': priceUgx,
          'billingCycle': billingCycle.name,
          'termLengthDays': termLengthDays,
          'trialDays': trialDays,
          'maxStudents': maxStudents,
          'maxStaff': maxStaff,
          'storageLimitGb': storageLimitGb,
          'smsLimitPerMonth': smsLimitPerMonth,
          'includedFeatures': includedFeatures,
          'includedModules': includedModules,
          'isPublic': isPublic,
          'isActive': isActive,
          'isPopular': isPopular,
          'displayOrder': displayOrder,
        });
  }

  Future<void> createPlan({
    required String planId,
    required String name,
    required String description,
    required int priceUgx,
    required BillingCycle billingCycle,
    required int termLengthDays,
    int trialDays = 0,
    required int maxStudents,
    required int maxStaff,
    required double storageLimitGb,
    int smsLimitPerMonth = 0,
    required List<String> includedFeatures,
    List<String> includedModules = const [],
    required bool isPublic,
    required bool isActive,
    required bool isPopular,
    required int displayOrder,
  }) async {
    await _functions
        .httpsCallable('createSubscriptionPlan')
        .call<Map<String, dynamic>>({
          'planId': planId,
          'name': name,
          'description': description,
          'price': priceUgx,
          'billingCycle': billingCycle.name,
          'termLengthDays': termLengthDays,
          'trialDays': trialDays,
          'maxStudents': maxStudents,
          'maxStaff': maxStaff,
          'storageLimitGb': storageLimitGb,
          'smsLimitPerMonth': smsLimitPerMonth,
          'includedFeatures': includedFeatures,
          'includedModules': includedModules,
          'isPublic': isPublic,
          'isActive': isActive,
          'isPopular': isPopular,
          'displayOrder': displayOrder,
        });
  }

  Future<void> archivePlan(String planId) async {
    await _functions
        .httpsCallable('archiveSubscriptionPlan')
        .call<Map<String, dynamic>>({'planId': planId});
  }

  Future<void> reactivatePlan(String planId) async {
    await _functions
        .httpsCallable('reactivateSubscriptionPlan')
        .call<Map<String, dynamic>>({'planId': planId});
  }

  static String _statusWire(ManualPaymentStatus status) => switch (status) {
    ManualPaymentStatus.pendingVerification => 'pending_verification',
    ManualPaymentStatus.approved => 'approved',
    ManualPaymentStatus.rejected => 'rejected',
  };
}
