import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item_model.dart';
import '../models/stock_movement_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<InventoryItemModel>> getItems();
  Future<List<StockMovementModel>> getRecentMovements();
  Future<void> addStock({required String itemId, required String itemName, required String category, required String unit, required int lowStockThreshold, required int quantity});
  Future<void> issueItem({required String itemId, required int quantity, required String note});
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final FirebaseFirestore firestore;

  InventoryRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<InventoryItemModel>> getItems() async {
    final snapshot = await firestore.collection('inventory_items').orderBy('name').get();
    return snapshot.docs.map((doc) => InventoryItemModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<StockMovementModel>> getRecentMovements() async {
    final snapshot = await firestore
        .collection('inventory_movements')
        .orderBy('date', descending: true)
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => StockMovementModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addStock({
    required String itemId,
    required String itemName,
    required String category,
    required String unit,
    required int lowStockThreshold,
    required int quantity,
  }) async {
    final itemsRef = firestore.collection('inventory_items');
    DocumentReference<Map<String, dynamic>> docRef;

    if (itemId.isEmpty) {
      docRef = await itemsRef.add({
        'name': itemName,
        'category': category,
        'unit': unit,
        'lowStockThreshold': lowStockThreshold,
        'quantity': quantity,
      });
    } else {
      docRef = itemsRef.doc(itemId);
      await docRef.update({'quantity': FieldValue.increment(quantity)});
    }

    await firestore.collection('inventory_movements').add({
      'itemId': docRef.id,
      'itemName': itemName,
      'type': 'restock',
      'quantity': quantity,
      'date': Timestamp.fromDate(DateTime.now()),
      'note': '',
    });
  }

  @override
  Future<void> issueItem({required String itemId, required int quantity, required String note}) async {
    final itemDoc = firestore.collection('inventory_items').doc(itemId);
    final snapshot = await itemDoc.get();
    final itemName = snapshot.data()?['name'] ?? '';

    await itemDoc.update({'quantity': FieldValue.increment(-quantity)});

    await firestore.collection('inventory_movements').add({
      'itemId': itemId,
      'itemName': itemName,
      'type': 'issue',
      'quantity': quantity,
      'date': Timestamp.fromDate(DateTime.now()),
      'note': note,
    });
  }
}
