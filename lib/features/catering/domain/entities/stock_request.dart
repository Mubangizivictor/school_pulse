import 'package:equatable/equatable.dart';

enum StockRequestStatus { pending, approved, issued, rejected }

class StockRequest extends Equatable {
  final String id;
  final String requestedBy;
  final DateTime requestedAt;
  final List<StockRequestItem> items;
  final StockRequestStatus status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? comments;

  const StockRequest({
    required this.id,
    required this.requestedBy,
    required this.requestedAt,
    required this.items,
    this.status = StockRequestStatus.pending,
    this.approvedBy,
    this.approvedAt,
    this.comments,
  });

  @override
  List<Object?> get props => [id, requestedBy, requestedAt, items, status, approvedBy, approvedAt, comments];
}

class StockRequestItem extends Equatable {
  final String foodItemId;
  final String foodItemName;
  final double quantity;
  final String unit;

  const StockRequestItem({
    required this.foodItemId,
    required this.foodItemName,
    required this.quantity,
    required this.unit,
  });

  @override
  List<Object?> get props => [foodItemId, foodItemName, quantity, unit];
}
