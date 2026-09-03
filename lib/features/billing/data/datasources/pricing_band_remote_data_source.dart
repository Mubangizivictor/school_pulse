import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:school_pulse/features/billing/domain/entities/pricing_band.dart';

/// Access to the `student_pricing_bands` collection and its owner-only
/// mutation callables (functions/student_pricing_bands.js), used by the
/// Super Admin "Student pricing" screen (Phase 3C).
///
/// Reads go straight to Firestore rather than through the `getPricingBands`
/// callable - firestore.rules allows any signed-in staff member (or the
/// owner) to read `student_pricing_bands` directly (same shared,
/// non-sensitive catalog shape as `subscription_plans`), and a direct watch
/// is simpler than a callable round-trip for a screen that just lists bands.
/// Writes (create/update/deactivate) go through the callables since those
/// are owner-gated server-side with overlap/immutability validation that
/// must not be duplicated client-side.
class PricingBandRemoteDataSource {
  PricingBandRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  Future<List<PricingBand>> getPricingBands() async {
    final snapshot = await _firestore
        .collection('student_pricing_bands')
        .get();
    return snapshot.docs
        .map((doc) => PricingBand.fromMap({'id': doc.id, ...doc.data()}))
        .toList()
      ..sort((a, b) => a.minStudents.compareTo(b.minStudents));
  }

  Future<void> createPricingBand({
    required int minStudents,
    int? maxStudents,
    required int amountUgx,
    bool isActive = true,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
  }) async {
    await _functions.httpsCallable('createPricingBand').call({
      'minStudents': minStudents,
      'maxStudents': maxStudents,
      'amountUgx': amountUgx,
      'isActive': isActive,
      if (effectiveFrom != null)
        'effectiveFrom': effectiveFrom.toIso8601String(),
      if (effectiveTo != null) 'effectiveTo': effectiveTo.toIso8601String(),
    });
  }

  Future<void> updatePricingBand({
    required String bandId,
    int? minStudents,
    int? maxStudents,

    /// Must be true when the caller wants to explicitly set/clear
    /// [maxStudents] (including setting it to null for "unbounded") -
    /// distinguishes "leave maxStudents alone" from "set maxStudents to
    /// null", since the callable itself distinguishes the two the same way.
    bool maxStudentsProvided = false,
    int? amountUgx,
    bool? isActive,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
  }) async {
    // Deliberately omit keys rather than sending explicit null: the
    // callable (functions/student_pricing_bands.js updatePricingBand)
    // distinguishes "field not sent" (keep current value) from "field sent
    // as null" (e.g. maxStudents:null means "unbounded", a real value) - a
    // stray null on minStudents/amountUgx would be coerced to 0 server-side.
    final data = <String, dynamic>{'bandId': bandId};
    if (minStudents != null) data['minStudents'] = minStudents;
    if (maxStudentsProvided) data['maxStudents'] = maxStudents;
    if (amountUgx != null) data['amountUgx'] = amountUgx;
    if (isActive != null) data['isActive'] = isActive;
    if (effectiveFrom != null) {
      data['effectiveFrom'] = effectiveFrom.toIso8601String();
    }
    if (effectiveTo != null) data['effectiveTo'] = effectiveTo.toIso8601String();
    await _functions.httpsCallable('updatePricingBand').call(data);
  }

  Future<void> deactivatePricingBand(String bandId) async {
    await _functions.httpsCallable('deactivatePricingBand').call({
      'bandId': bandId,
    });
  }
}
