import 'package:equatable/equatable.dart';

/// A reusable named pay component (`schools/{schoolId}/pay_component_catalogue/{id}`)
/// that feeds the componentId/name picker when building a salary-structure
/// line. Not money-authoritative - [suggestedAmountUgx] is only a UI
/// default; the authoritative amount is whatever is typed into a specific
/// structure's line and published via `publishSalaryStructure`.
class PayComponentCatalogueItem extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String? defaultComponentKey;
  final int? suggestedAmountUgx;

  const PayComponentCatalogueItem({
    required this.id,
    required this.schoolId,
    required this.name,
    this.defaultComponentKey,
    this.suggestedAmountUgx,
  });

  factory PayComponentCatalogueItem.fromJson(
    String id,
    Map<String, dynamic> json,
  ) => PayComponentCatalogueItem(
    id: id,
    schoolId: json['schoolId'] as String? ?? '',
    name: json['name'] as String? ?? '',
    defaultComponentKey: json['defaultComponentKey'] as String?,
    suggestedAmountUgx: (json['suggestedAmountUgx'] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => {
    'schoolId': schoolId,
    'name': name,
    if (defaultComponentKey != null) 'defaultComponentKey': defaultComponentKey,
    if (suggestedAmountUgx != null) 'suggestedAmountUgx': suggestedAmountUgx,
  };

  @override
  List<Object?> get props => [
    id,
    schoolId,
    name,
    defaultComponentKey,
    suggestedAmountUgx,
  ];
}
