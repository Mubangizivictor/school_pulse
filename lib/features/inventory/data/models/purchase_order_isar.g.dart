// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_order_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPurchaseOrderIsarCollection on Isar {
  IsarCollection<PurchaseOrderIsar> get purchaseOrderIsars => this.collection();
}

const PurchaseOrderIsarSchema = CollectionSchema(
  name: r'PurchaseOrderIsar',
  id: -235726150100336787,
  properties: {
    r'approvedBy': PropertySchema(
      id: 0,
      name: r'approvedBy',
      type: IsarType.string,
    ),
    r'createdBy': PropertySchema(
      id: 1,
      name: r'createdBy',
      type: IsarType.string,
    ),
    r'date': PropertySchema(id: 2, name: r'date', type: IsarType.dateTime),
    r'isSynced': PropertySchema(id: 3, name: r'isSynced', type: IsarType.bool),
    r'items': PropertySchema(
      id: 4,
      name: r'items',
      type: IsarType.objectList,
      target: r'OrderItemEmbeddable',
    ),
    r'notes': PropertySchema(id: 5, name: r'notes', type: IsarType.string),
    r'orderId': PropertySchema(id: 6, name: r'orderId', type: IsarType.string),
    r'orderNumber': PropertySchema(
      id: 7,
      name: r'orderNumber',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 8,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 9,
      name: r'status',
      type: IsarType.byte,
      enumMap: _PurchaseOrderIsarstatusEnumValueMap,
    ),
    r'supplierId': PropertySchema(
      id: 10,
      name: r'supplierId',
      type: IsarType.string,
    ),
    r'supplierName': PropertySchema(
      id: 11,
      name: r'supplierName',
      type: IsarType.string,
    ),
    r'totalAmount': PropertySchema(
      id: 12,
      name: r'totalAmount',
      type: IsarType.double,
    ),
  },
  estimateSize: _purchaseOrderIsarEstimateSize,
  serialize: _purchaseOrderIsarSerialize,
  deserialize: _purchaseOrderIsarDeserialize,
  deserializeProp: _purchaseOrderIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'orderId': IndexSchema(
      id: -6176610178429382285,
      name: r'orderId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'orderId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'OrderItemEmbeddable': OrderItemEmbeddableSchema},
  getId: _purchaseOrderIsarGetId,
  getLinks: _purchaseOrderIsarGetLinks,
  attach: _purchaseOrderIsarAttach,
  version: '3.1.0+1',
);

int _purchaseOrderIsarEstimateSize(
  PurchaseOrderIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.approvedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.createdBy.length * 3;
  bytesCount += 3 + object.items.length * 3;
  {
    final offsets = allOffsets[OrderItemEmbeddable]!;
    for (var i = 0; i < object.items.length; i++) {
      final value = object.items[i];
      bytesCount += OrderItemEmbeddableSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.orderId.length * 3;
  bytesCount += 3 + object.orderNumber.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.supplierId.length * 3;
  bytesCount += 3 + object.supplierName.length * 3;
  return bytesCount;
}

void _purchaseOrderIsarSerialize(
  PurchaseOrderIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.approvedBy);
  writer.writeString(offsets[1], object.createdBy);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeBool(offsets[3], object.isSynced);
  writer.writeObjectList<OrderItemEmbeddable>(
    offsets[4],
    allOffsets,
    OrderItemEmbeddableSchema.serialize,
    object.items,
  );
  writer.writeString(offsets[5], object.notes);
  writer.writeString(offsets[6], object.orderId);
  writer.writeString(offsets[7], object.orderNumber);
  writer.writeString(offsets[8], object.schoolId);
  writer.writeByte(offsets[9], object.status.index);
  writer.writeString(offsets[10], object.supplierId);
  writer.writeString(offsets[11], object.supplierName);
  writer.writeDouble(offsets[12], object.totalAmount);
}

PurchaseOrderIsar _purchaseOrderIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PurchaseOrderIsar();
  object.approvedBy = reader.readStringOrNull(offsets[0]);
  object.createdBy = reader.readString(offsets[1]);
  object.date = reader.readDateTime(offsets[2]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[3]);
  object.items =
      reader.readObjectList<OrderItemEmbeddable>(
        offsets[4],
        OrderItemEmbeddableSchema.deserialize,
        allOffsets,
        OrderItemEmbeddable(),
      ) ??
      [];
  object.notes = reader.readStringOrNull(offsets[5]);
  object.orderId = reader.readString(offsets[6]);
  object.orderNumber = reader.readString(offsets[7]);
  object.schoolId = reader.readString(offsets[8]);
  object.status =
      _PurchaseOrderIsarstatusValueEnumMap[reader.readByteOrNull(offsets[9])] ??
      PurchaseOrderStatus.pending;
  object.supplierId = reader.readString(offsets[10]);
  object.supplierName = reader.readString(offsets[11]);
  object.totalAmount = reader.readDouble(offsets[12]);
  return object;
}

P _purchaseOrderIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readObjectList<OrderItemEmbeddable>(
                offset,
                OrderItemEmbeddableSchema.deserialize,
                allOffsets,
                OrderItemEmbeddable(),
              ) ??
              [])
          as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (_PurchaseOrderIsarstatusValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              PurchaseOrderStatus.pending)
          as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PurchaseOrderIsarstatusEnumValueMap = {
  'pending': 0,
  'approved': 1,
  'ordered': 2,
  'received': 3,
  'cancelled': 4,
};
const _PurchaseOrderIsarstatusValueEnumMap = {
  0: PurchaseOrderStatus.pending,
  1: PurchaseOrderStatus.approved,
  2: PurchaseOrderStatus.ordered,
  3: PurchaseOrderStatus.received,
  4: PurchaseOrderStatus.cancelled,
};

Id _purchaseOrderIsarGetId(PurchaseOrderIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _purchaseOrderIsarGetLinks(
  PurchaseOrderIsar object,
) {
  return [];
}

void _purchaseOrderIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  PurchaseOrderIsar object,
) {
  object.id = id;
}

extension PurchaseOrderIsarByIndex on IsarCollection<PurchaseOrderIsar> {
  Future<PurchaseOrderIsar?> getByOrderId(String orderId) {
    return getByIndex(r'orderId', [orderId]);
  }

  PurchaseOrderIsar? getByOrderIdSync(String orderId) {
    return getByIndexSync(r'orderId', [orderId]);
  }

  Future<bool> deleteByOrderId(String orderId) {
    return deleteByIndex(r'orderId', [orderId]);
  }

  bool deleteByOrderIdSync(String orderId) {
    return deleteByIndexSync(r'orderId', [orderId]);
  }

  Future<List<PurchaseOrderIsar?>> getAllByOrderId(List<String> orderIdValues) {
    final values = orderIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'orderId', values);
  }

  List<PurchaseOrderIsar?> getAllByOrderIdSync(List<String> orderIdValues) {
    final values = orderIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'orderId', values);
  }

  Future<int> deleteAllByOrderId(List<String> orderIdValues) {
    final values = orderIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'orderId', values);
  }

  int deleteAllByOrderIdSync(List<String> orderIdValues) {
    final values = orderIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'orderId', values);
  }

  Future<Id> putByOrderId(PurchaseOrderIsar object) {
    return putByIndex(r'orderId', object);
  }

  Id putByOrderIdSync(PurchaseOrderIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'orderId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOrderId(List<PurchaseOrderIsar> objects) {
    return putAllByIndex(r'orderId', objects);
  }

  List<Id> putAllByOrderIdSync(
    List<PurchaseOrderIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'orderId', objects, saveLinks: saveLinks);
  }
}

extension PurchaseOrderIsarQueryWhereSort
    on QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QWhere> {
  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PurchaseOrderIsarQueryWhere
    on QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QWhereClause> {
  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterWhereClause>
  orderIdEqualTo(String orderId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'orderId', value: [orderId]),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterWhereClause>
  orderIdNotEqualTo(String orderId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'orderId',
                lower: [],
                upper: [orderId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'orderId',
                lower: [orderId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'orderId',
                lower: [orderId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'orderId',
                lower: [],
                upper: [orderId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension PurchaseOrderIsarQueryFilter
    on QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QFilterCondition> {
  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  approvedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'approvedBy'),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  approvedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'approvedBy'),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  approvedByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'approvedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  approvedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'approvedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  approvedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'approvedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  approvedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'approvedBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  approvedByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'approvedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  approvedByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'approvedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  approvedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'approvedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  approvedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'approvedBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  approvedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'approvedBy', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  approvedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'approvedBy', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  createdByEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'createdBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  createdByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  createdByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  createdByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  createdByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'createdBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  createdByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'createdBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  createdByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'createdBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  createdByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'createdBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  createdByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdBy', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  createdByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'createdBy', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  dateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  dateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isSynced', value: value),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  itemsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'items', length, true, length, true);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  itemsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'items', 0, true, 0, true);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  itemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'items', 0, false, 999999, true);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  itemsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'items', 0, true, length, include);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  itemsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'items', length, include, 999999, true);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  itemsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  notesEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'notes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  notesStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  notesEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'notes',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'notes',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'orderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'orderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'orderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'orderId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'orderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'orderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'orderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'orderId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'orderId', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'orderId', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderNumberEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'orderNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'orderNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'orderNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'orderNumber',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderNumberStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'orderNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderNumberEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'orderNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'orderNumber',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'orderNumber',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'orderNumber', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  orderNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'orderNumber', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  schoolIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'schoolId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  schoolIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'schoolId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  schoolIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'schoolId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  schoolIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'schoolId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  schoolIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'schoolId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  schoolIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'schoolId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'schoolId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'schoolId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  statusEqualTo(PurchaseOrderStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  statusGreaterThan(PurchaseOrderStatus value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  statusLessThan(PurchaseOrderStatus value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  statusBetween(
    PurchaseOrderStatus lower,
    PurchaseOrderStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'supplierId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'supplierId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'supplierId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'supplierId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'supplierId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'supplierId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'supplierId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'supplierId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'supplierId', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'supplierId', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'supplierName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'supplierName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'supplierName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'supplierName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'supplierName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'supplierName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'supplierName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'supplierName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'supplierName', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  supplierNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'supplierName', value: ''),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  totalAmountEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'totalAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  totalAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  totalAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  totalAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }
}

extension PurchaseOrderIsarQueryObject
    on QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QFilterCondition> {
  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterFilterCondition>
  itemsElement(FilterQuery<OrderItemEmbeddable> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'items');
    });
  }
}

extension PurchaseOrderIsarQueryLinks
    on QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QFilterCondition> {}

extension PurchaseOrderIsarQuerySortBy
    on QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QSortBy> {
  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByApprovedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByApprovedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByOrderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderId', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByOrderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderId', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByOrderNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNumber', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByOrderNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNumber', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortBySupplierId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierId', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortBySupplierIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierId', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortBySupplierName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierName', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortBySupplierNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierName', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  sortByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }
}

extension PurchaseOrderIsarQuerySortThenBy
    on QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QSortThenBy> {
  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByApprovedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByApprovedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByCreatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByCreatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdBy', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByOrderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderId', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByOrderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderId', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByOrderNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNumber', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByOrderNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderNumber', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenBySupplierId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierId', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenBySupplierIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierId', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenBySupplierName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierName', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenBySupplierNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierName', Sort.desc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QAfterSortBy>
  thenByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }
}

extension PurchaseOrderIsarQueryWhereDistinct
    on QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QDistinct> {
  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QDistinct>
  distinctByApprovedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QDistinct>
  distinctByCreatedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QDistinct>
  distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QDistinct>
  distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QDistinct>
  distinctByNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QDistinct>
  distinctByOrderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QDistinct>
  distinctByOrderNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QDistinct>
  distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QDistinct>
  distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QDistinct>
  distinctBySupplierId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supplierId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QDistinct>
  distinctBySupplierName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supplierName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QDistinct>
  distinctByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmount');
    });
  }
}

extension PurchaseOrderIsarQueryProperty
    on QueryBuilder<PurchaseOrderIsar, PurchaseOrderIsar, QQueryProperty> {
  QueryBuilder<PurchaseOrderIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PurchaseOrderIsar, String?, QQueryOperations>
  approvedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvedBy');
    });
  }

  QueryBuilder<PurchaseOrderIsar, String, QQueryOperations>
  createdByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdBy');
    });
  }

  QueryBuilder<PurchaseOrderIsar, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<PurchaseOrderIsar, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<PurchaseOrderIsar, List<OrderItemEmbeddable>, QQueryOperations>
  itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'items');
    });
  }

  QueryBuilder<PurchaseOrderIsar, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<PurchaseOrderIsar, String, QQueryOperations> orderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderId');
    });
  }

  QueryBuilder<PurchaseOrderIsar, String, QQueryOperations>
  orderNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderNumber');
    });
  }

  QueryBuilder<PurchaseOrderIsar, String, QQueryOperations> schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<PurchaseOrderIsar, PurchaseOrderStatus, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PurchaseOrderIsar, String, QQueryOperations>
  supplierIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supplierId');
    });
  }

  QueryBuilder<PurchaseOrderIsar, String, QQueryOperations>
  supplierNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supplierName');
    });
  }

  QueryBuilder<PurchaseOrderIsar, double, QQueryOperations>
  totalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmount');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const OrderItemEmbeddableSchema = Schema(
  name: r'OrderItemEmbeddable',
  id: -5577102090679069759,
  properties: {
    r'itemName': PropertySchema(
      id: 0,
      name: r'itemName',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(id: 1, name: r'quantity', type: IsarType.long),
    r'unitPrice': PropertySchema(
      id: 2,
      name: r'unitPrice',
      type: IsarType.double,
    ),
  },
  estimateSize: _orderItemEmbeddableEstimateSize,
  serialize: _orderItemEmbeddableSerialize,
  deserialize: _orderItemEmbeddableDeserialize,
  deserializeProp: _orderItemEmbeddableDeserializeProp,
);

int _orderItemEmbeddableEstimateSize(
  OrderItemEmbeddable object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.itemName.length * 3;
  return bytesCount;
}

void _orderItemEmbeddableSerialize(
  OrderItemEmbeddable object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.itemName);
  writer.writeLong(offsets[1], object.quantity);
  writer.writeDouble(offsets[2], object.unitPrice);
}

OrderItemEmbeddable _orderItemEmbeddableDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OrderItemEmbeddable();
  object.itemName = reader.readString(offsets[0]);
  object.quantity = reader.readLong(offsets[1]);
  object.unitPrice = reader.readDouble(offsets[2]);
  return object;
}

P _orderItemEmbeddableDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension OrderItemEmbeddableQueryFilter
    on
        QueryBuilder<
          OrderItemEmbeddable,
          OrderItemEmbeddable,
          QFilterCondition
        > {
  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  itemNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itemName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  itemNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itemName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  itemNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itemName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  itemNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itemName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  itemNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itemName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  itemNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itemName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  itemNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itemName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  itemNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itemName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  itemNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itemName', value: ''),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  itemNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'itemName', value: ''),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quantity', value: value),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  quantityGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'quantity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  quantityLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'quantity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'quantity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  unitPriceEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'unitPrice',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  unitPriceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'unitPrice',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  unitPriceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'unitPrice',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<OrderItemEmbeddable, OrderItemEmbeddable, QAfterFilterCondition>
  unitPriceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unitPrice',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }
}

extension OrderItemEmbeddableQueryObject
    on
        QueryBuilder<
          OrderItemEmbeddable,
          OrderItemEmbeddable,
          QFilterCondition
        > {}
