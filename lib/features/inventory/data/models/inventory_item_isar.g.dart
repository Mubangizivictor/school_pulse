// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetInventoryItemIsarCollection on Isar {
  IsarCollection<InventoryItemIsar> get inventoryItemIsars => this.collection();
}

const InventoryItemIsarSchema = CollectionSchema(
  name: r'InventoryItemIsar',
  id: -7750643974937291806,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isSynced': PropertySchema(id: 2, name: r'isSynced', type: IsarType.bool),
    r'itemId': PropertySchema(id: 3, name: r'itemId', type: IsarType.string),
    r'lowStockThreshold': PropertySchema(
      id: 4,
      name: r'lowStockThreshold',
      type: IsarType.long,
    ),
    r'maximumStock': PropertySchema(
      id: 5,
      name: r'maximumStock',
      type: IsarType.long,
    ),
    r'name': PropertySchema(id: 6, name: r'name', type: IsarType.string),
    r'quantity': PropertySchema(id: 7, name: r'quantity', type: IsarType.long),
    r'reorderLevel': PropertySchema(
      id: 8,
      name: r'reorderLevel',
      type: IsarType.long,
    ),
    r'schoolId': PropertySchema(
      id: 9,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'storeLocation': PropertySchema(
      id: 10,
      name: r'storeLocation',
      type: IsarType.string,
    ),
    r'unit': PropertySchema(id: 11, name: r'unit', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 12,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'warehouseLocation': PropertySchema(
      id: 13,
      name: r'warehouseLocation',
      type: IsarType.string,
    ),
  },
  estimateSize: _inventoryItemIsarEstimateSize,
  serialize: _inventoryItemIsarSerialize,
  deserialize: _inventoryItemIsarDeserialize,
  deserializeProp: _inventoryItemIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'itemId': IndexSchema(
      id: -5342806140158601489,
      name: r'itemId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'itemId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _inventoryItemIsarGetId,
  getLinks: _inventoryItemIsarGetLinks,
  attach: _inventoryItemIsarAttach,
  version: '3.1.0+1',
);

int _inventoryItemIsarEstimateSize(
  InventoryItemIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.length * 3;
  bytesCount += 3 + object.itemId.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  {
    final value = object.storeLocation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.unit.length * 3;
  {
    final value = object.warehouseLocation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _inventoryItemIsarSerialize(
  InventoryItemIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeBool(offsets[2], object.isSynced);
  writer.writeString(offsets[3], object.itemId);
  writer.writeLong(offsets[4], object.lowStockThreshold);
  writer.writeLong(offsets[5], object.maximumStock);
  writer.writeString(offsets[6], object.name);
  writer.writeLong(offsets[7], object.quantity);
  writer.writeLong(offsets[8], object.reorderLevel);
  writer.writeString(offsets[9], object.schoolId);
  writer.writeString(offsets[10], object.storeLocation);
  writer.writeString(offsets[11], object.unit);
  writer.writeDateTime(offsets[12], object.updatedAt);
  writer.writeString(offsets[13], object.warehouseLocation);
}

InventoryItemIsar _inventoryItemIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InventoryItemIsar();
  object.category = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[2]);
  object.itemId = reader.readString(offsets[3]);
  object.lowStockThreshold = reader.readLong(offsets[4]);
  object.maximumStock = reader.readLongOrNull(offsets[5]);
  object.name = reader.readString(offsets[6]);
  object.quantity = reader.readLong(offsets[7]);
  object.reorderLevel = reader.readLongOrNull(offsets[8]);
  object.schoolId = reader.readString(offsets[9]);
  object.storeLocation = reader.readStringOrNull(offsets[10]);
  object.unit = reader.readString(offsets[11]);
  object.updatedAt = reader.readDateTime(offsets[12]);
  object.warehouseLocation = reader.readStringOrNull(offsets[13]);
  return object;
}

P _inventoryItemIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _inventoryItemIsarGetId(InventoryItemIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _inventoryItemIsarGetLinks(
  InventoryItemIsar object,
) {
  return [];
}

void _inventoryItemIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  InventoryItemIsar object,
) {
  object.id = id;
}

extension InventoryItemIsarByIndex on IsarCollection<InventoryItemIsar> {
  Future<InventoryItemIsar?> getByItemId(String itemId) {
    return getByIndex(r'itemId', [itemId]);
  }

  InventoryItemIsar? getByItemIdSync(String itemId) {
    return getByIndexSync(r'itemId', [itemId]);
  }

  Future<bool> deleteByItemId(String itemId) {
    return deleteByIndex(r'itemId', [itemId]);
  }

  bool deleteByItemIdSync(String itemId) {
    return deleteByIndexSync(r'itemId', [itemId]);
  }

  Future<List<InventoryItemIsar?>> getAllByItemId(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'itemId', values);
  }

  List<InventoryItemIsar?> getAllByItemIdSync(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'itemId', values);
  }

  Future<int> deleteAllByItemId(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'itemId', values);
  }

  int deleteAllByItemIdSync(List<String> itemIdValues) {
    final values = itemIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'itemId', values);
  }

  Future<Id> putByItemId(InventoryItemIsar object) {
    return putByIndex(r'itemId', object);
  }

  Id putByItemIdSync(InventoryItemIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'itemId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByItemId(List<InventoryItemIsar> objects) {
    return putAllByIndex(r'itemId', objects);
  }

  List<Id> putAllByItemIdSync(
    List<InventoryItemIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'itemId', objects, saveLinks: saveLinks);
  }
}

extension InventoryItemIsarQueryWhereSort
    on QueryBuilder<InventoryItemIsar, InventoryItemIsar, QWhere> {
  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension InventoryItemIsarQueryWhere
    on QueryBuilder<InventoryItemIsar, InventoryItemIsar, QWhereClause> {
  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterWhereClause>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterWhereClause>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterWhereClause>
  itemIdEqualTo(String itemId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'itemId', value: [itemId]),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterWhereClause>
  itemIdNotEqualTo(String itemId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'itemId',
                lower: [],
                upper: [itemId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'itemId',
                lower: [itemId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'itemId',
                lower: [itemId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'itemId',
                lower: [],
                upper: [itemId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension InventoryItemIsarQueryFilter
    on QueryBuilder<InventoryItemIsar, InventoryItemIsar, QFilterCondition> {
  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  categoryEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'category',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  categoryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  categoryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'category',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isSynced', value: value),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  itemIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  itemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  itemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  itemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itemId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  itemIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  itemIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  itemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itemId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  itemIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itemId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  itemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itemId', value: ''),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  itemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'itemId', value: ''),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  lowStockThresholdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lowStockThreshold', value: value),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  lowStockThresholdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lowStockThreshold',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  lowStockThresholdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lowStockThreshold',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  lowStockThresholdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lowStockThreshold',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  maximumStockIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'maximumStock'),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  maximumStockIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'maximumStock'),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  maximumStockEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'maximumStock', value: value),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  maximumStockGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'maximumStock',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  maximumStockLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'maximumStock',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  maximumStockBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'maximumStock',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  nameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quantity', value: value),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  reorderLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'reorderLevel'),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  reorderLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'reorderLevel'),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  reorderLevelEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reorderLevel', value: value),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  reorderLevelGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reorderLevel',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  reorderLevelLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reorderLevel',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  reorderLevelBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reorderLevel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
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

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  storeLocationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'storeLocation'),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  storeLocationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'storeLocation'),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  storeLocationEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'storeLocation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  storeLocationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'storeLocation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  storeLocationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'storeLocation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  storeLocationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'storeLocation',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  storeLocationStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'storeLocation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  storeLocationEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'storeLocation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  storeLocationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'storeLocation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  storeLocationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'storeLocation',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  storeLocationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'storeLocation', value: ''),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  storeLocationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'storeLocation', value: ''),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  unitEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  unitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  unitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  unitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'unit',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  unitStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  unitEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  unitContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'unit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  unitMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'unit',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'unit', value: ''),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'unit', value: ''),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  warehouseLocationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'warehouseLocation'),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  warehouseLocationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'warehouseLocation'),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  warehouseLocationEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'warehouseLocation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  warehouseLocationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'warehouseLocation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  warehouseLocationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'warehouseLocation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  warehouseLocationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'warehouseLocation',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  warehouseLocationStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'warehouseLocation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  warehouseLocationEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'warehouseLocation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  warehouseLocationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'warehouseLocation',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  warehouseLocationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'warehouseLocation',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  warehouseLocationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'warehouseLocation', value: ''),
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterFilterCondition>
  warehouseLocationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'warehouseLocation', value: ''),
      );
    });
  }
}

extension InventoryItemIsarQueryObject
    on QueryBuilder<InventoryItemIsar, InventoryItemIsar, QFilterCondition> {}

extension InventoryItemIsarQueryLinks
    on QueryBuilder<InventoryItemIsar, InventoryItemIsar, QFilterCondition> {}

extension InventoryItemIsarQuerySortBy
    on QueryBuilder<InventoryItemIsar, InventoryItemIsar, QSortBy> {
  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByLowStockThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowStockThreshold', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByLowStockThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowStockThreshold', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByMaximumStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maximumStock', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByMaximumStockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maximumStock', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByReorderLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reorderLevel', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByReorderLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reorderLevel', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByStoreLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeLocation', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByStoreLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeLocation', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByWarehouseLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warehouseLocation', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  sortByWarehouseLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warehouseLocation', Sort.desc);
    });
  }
}

extension InventoryItemIsarQuerySortThenBy
    on QueryBuilder<InventoryItemIsar, InventoryItemIsar, QSortThenBy> {
  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByLowStockThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowStockThreshold', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByLowStockThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lowStockThreshold', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByMaximumStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maximumStock', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByMaximumStockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maximumStock', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByReorderLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reorderLevel', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByReorderLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reorderLevel', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByStoreLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeLocation', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByStoreLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storeLocation', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByWarehouseLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warehouseLocation', Sort.asc);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QAfterSortBy>
  thenByWarehouseLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warehouseLocation', Sort.desc);
    });
  }
}

extension InventoryItemIsarQueryWhereDistinct
    on QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct> {
  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct>
  distinctByCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct>
  distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct>
  distinctByItemId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct>
  distinctByLowStockThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lowStockThreshold');
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct>
  distinctByMaximumStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maximumStock');
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct>
  distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct>
  distinctByReorderLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reorderLevel');
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct>
  distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct>
  distinctByStoreLocation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'storeLocation',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct> distinctByUnit({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<InventoryItemIsar, InventoryItemIsar, QDistinct>
  distinctByWarehouseLocation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'warehouseLocation',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension InventoryItemIsarQueryProperty
    on QueryBuilder<InventoryItemIsar, InventoryItemIsar, QQueryProperty> {
  QueryBuilder<InventoryItemIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<InventoryItemIsar, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<InventoryItemIsar, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<InventoryItemIsar, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<InventoryItemIsar, String, QQueryOperations> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemId');
    });
  }

  QueryBuilder<InventoryItemIsar, int, QQueryOperations>
  lowStockThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lowStockThreshold');
    });
  }

  QueryBuilder<InventoryItemIsar, int?, QQueryOperations>
  maximumStockProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maximumStock');
    });
  }

  QueryBuilder<InventoryItemIsar, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<InventoryItemIsar, int, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<InventoryItemIsar, int?, QQueryOperations>
  reorderLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reorderLevel');
    });
  }

  QueryBuilder<InventoryItemIsar, String, QQueryOperations> schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<InventoryItemIsar, String?, QQueryOperations>
  storeLocationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storeLocation');
    });
  }

  QueryBuilder<InventoryItemIsar, String, QQueryOperations> unitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unit');
    });
  }

  QueryBuilder<InventoryItemIsar, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<InventoryItemIsar, String?, QQueryOperations>
  warehouseLocationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'warehouseLocation');
    });
  }
}
