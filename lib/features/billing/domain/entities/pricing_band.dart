import 'package:equatable/equatable.dart';

/// A row from the `student_pricing_bands` collection
/// (functions/student_pricing_bands.js) - the sole source of term pricing
/// under the Phase 3 pricing-band model. Every active school is priced
/// solely by its verified enrolled student count matching exactly one
/// active band; there is no plan-based pricing any more.
class PricingBand extends Equatable {
  final String id;
  final int minStudents;

  /// Null means "unbounded" (the top-most band).
  final int? maxStudents;
  final int amountUgx;
  final bool isActive;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;

  const PricingBand({
    required this.id,
    required this.minStudents,
    this.maxStudents,
    required this.amountUgx,
    required this.isActive,
    this.effectiveFrom,
    this.effectiveTo,
  });

  /// True when this band's amount/range are still editable - i.e. it has
  /// not yet gone live for anyone (effectiveFrom is in the future). Mirrors
  /// the immutability guard in functions/student_pricing_bands.js
  /// updatePricingBand (which blocks amount/range edits on a band that has
  /// already been snapshotted by an issued invoice) as a client-side
  /// best-effort check so the UI doesn't offer an edit action that the
  /// callable will reject; the callable remains the source of truth.
  bool get isFutureEffective =>
      effectiveFrom != null && effectiveFrom!.isAfter(DateTime.now());

  factory PricingBand.fromMap(Map<String, dynamic> map) => PricingBand(
    id: map['id']?.toString() ?? '',
    minStudents: ((map['minStudents'] ?? 0) as num).toInt(),
    maxStudents: map['maxStudents'] == null
        ? null
        : (map['maxStudents'] as num).toInt(),
    amountUgx: ((map['amountUgx'] ?? 0) as num).toInt(),
    isActive: map['isActive'] == true,
    effectiveFrom: _parseDate(map['effectiveFrom']),
    effectiveTo: _parseDate(map['effectiveTo']),
  );

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  List<Object?> get props => [
    id,
    minStudents,
    maxStudents,
    amountUgx,
    isActive,
    effectiveFrom,
    effectiveTo,
  ];
}
