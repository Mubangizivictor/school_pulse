import 'package:equatable/equatable.dart';

/// A reusable named charge (`schools/{schoolId}/fee_catalogue/{chargeId}`)
/// that feeds the chargeId/name picker when building a fee-plan line. Not
/// money-authoritative - [suggestedAmountUgx] is only a UI default; the
/// authoritative amount is whatever is typed into a specific plan's line
/// and published via `publishFeePlan`.
class FeeCatalogueItem extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String? defaultServiceKey;
  final int? suggestedAmountUgx;

  const FeeCatalogueItem({
    required this.id,
    required this.schoolId,
    required this.name,
    this.defaultServiceKey,
    this.suggestedAmountUgx,
  });

  factory FeeCatalogueItem.fromJson(String id, Map<String, dynamic> json) =>
      FeeCatalogueItem(
        id: id,
        schoolId: json['schoolId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        defaultServiceKey: json['defaultServiceKey'] as String?,
        suggestedAmountUgx: (json['suggestedAmountUgx'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
    'schoolId': schoolId,
    'name': name,
    if (defaultServiceKey != null) 'defaultServiceKey': defaultServiceKey,
    if (suggestedAmountUgx != null) 'suggestedAmountUgx': suggestedAmountUgx,
  };

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    defaultServiceKey,
    suggestedAmountUgx,
  ];
}
