// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStockMovementIsarCollection on Isar {
  IsarCollection<StockMovementIsar> get stockMovementIsars => this.collection();
}

const StockMovementIsarSchema = CollectionSchema(
  name: r'StockMovementIsar',
  id: -7947339573163277239,
  properties: {
    r'date': PropertySchema(id: 0, name: r'date', type: IsarType.dateTime),
    r'isSynced': PropertySchema(id: 1, name: r'isSynced', type: IsarType.bool),
    r'itemId': PropertySchema(id: 2, name: r'itemId', type: IsarType.string),
    r'itemName': PropertySchema(
      id: 3,
      name: r'itemName',
      type: IsarType.string,
    ),
    r'movementId': PropertySchema(
      id: 4,
      name: r'movementId',
      type: IsarType.string,
    ),
    r'note': PropertySchema(id: 5, name: r'note', type: IsarType.string),
    r'quantity': PropertySchema(id: 6, name: r'quantity', type: IsarType.long),
    r'type': PropertySchema(
      id: 7,
      name: r'type',
      type: IsarType.byte,
      enumMap: _StockMovementIsartypeEnumValueMap,
    ),
  },
  estimateSize: _stockMovementIsarEstimateSize,
  serialize: _stockMovementIsarSerialize,
  deserialize: _stockMovementIsarDeserialize,
  deserializeProp: _stockMovementIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'movementId': IndexSchema(
      id: 1547802813824549110,
      name: r'movementId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'movementId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _stockMovementIsarGetId,
  getLinks: _stockMovementIsarGetLinks,
  attach: _stockMovementIsarAttach,
  version: '3.1.0+1',
);

int _stockMovementIsarEstimateSize(
  StockMovementIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.itemId.length * 3;
  bytesCount += 3 + object.itemName.length * 3;
  bytesCount += 3 + object.movementId.length * 3;
  bytesCount += 3 + object.note.length * 3;
  return bytesCount;
}

void _stockMovementIsarSerialize(
  StockMovementIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeBool(offsets[1], object.isSynced);
  writer.writeString(offsets[2], object.itemId);
  writer.writeString(offsets[3], object.itemName);
  writer.writeString(offsets[4], object.movementId);
  writer.writeString(offsets[5], object.note);
  writer.writeLong(offsets[6], object.quantity);
  writer.writeByte(offsets[7], object.type.index);
}

StockMovementIsar _stockMovementIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StockMovementIsar(
    date: reader.readDateTime(offsets[0]),
    isSynced: reader.readBoolOrNull(offsets[1]) ?? false,
    itemId: reader.readStringOrNull(offsets[2]) ?? '',
    itemName: reader.readStringOrNull(offsets[3]) ?? '',
    movementId: reader.readStringOrNull(offsets[4]) ?? '',
    note: reader.readStringOrNull(offsets[5]) ?? '',
    quantity: reader.readLongOrNull(offsets[6]) ?? 0,
    type:
        _StockMovementIsartypeValueEnumMap[reader.readByteOrNull(offsets[7])] ??
        StockMovementType.restock,
  );
  object.id = id;
  return object;
}

P _stockMovementIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 3:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 4:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 5:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 6:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 7:
      return (_StockMovementIsartypeValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              StockMovementType.restock)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _StockMovementIsartypeEnumValueMap = {'restock': 0, 'issue': 1};
const _StockMovementIsartypeValueEnumMap = {
  0: StockMovementType.restock,
  1: StockMovementType.issue,
};

Id _stockMovementIsarGetId(StockMovementIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _stockMovementIsarGetLinks(
  StockMovementIsar object,
) {
  return [];
}

void _stockMovementIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  StockMovementIsar object,
) {
  object.id = id;
}

extension StockMovementIsarByIndex on IsarCollection<StockMovementIsar> {
  Future<StockMovementIsar?> getByMovementId(String movementId) {
    return getByIndex(r'movementId', [movementId]);
  }

  StockMovementIsar? getByMovementIdSync(String movementId) {
    return getByIndexSync(r'movementId', [movementId]);
  }

  Future<bool> deleteByMovementId(String movementId) {
    return deleteByIndex(r'movementId', [movementId]);
  }

  bool deleteByMovementIdSync(String movementId) {
    return deleteByIndexSync(r'movementId', [movementId]);
  }

  Future<List<StockMovementIsar?>> getAllByMovementId(
    List<String> movementIdValues,
  ) {
    final values = movementIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'movementId', values);
  }

  List<StockMovementIsar?> getAllByMovementIdSync(
    List<String> movementIdValues,
  ) {
    final values = movementIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'movementId', values);
  }

  Future<int> deleteAllByMovementId(List<String> movementIdValues) {
    final values = movementIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'movementId', values);
  }

  int deleteAllByMovementIdSync(List<String> movementIdValues) {
    final values = movementIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'movementId', values);
  }

  Future<Id> putByMovementId(StockMovementIsar object) {
    return putByIndex(r'movementId', object);
  }

  Id putByMovementIdSync(StockMovementIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'movementId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMovementId(List<StockMovementIsar> objects) {
    return putAllByIndex(r'movementId', objects);
  }

  List<Id> putAllByMovementIdSync(
    List<StockMovementIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'movementId', objects, saveLinks: saveLinks);
  }
}

extension StockMovementIsarQueryWhereSort
    on QueryBuilder<StockMovementIsar, StockMovementIsar, QWhere> {
  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StockMovementIsarQueryWhere
    on QueryBuilder<StockMovementIsar, StockMovementIsar, QWhereClause> {
  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterWhereClause>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterWhereClause>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterWhereClause>
  movementIdEqualTo(String movementId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'movementId', value: [movementId]),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterWhereClause>
  movementIdNotEqualTo(String movementId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'movementId',
                lower: [],
                upper: [movementId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'movementId',
                lower: [movementId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'movementId',
                lower: [movementId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'movementId',
                lower: [],
                upper: [movementId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension StockMovementIsarQueryFilter
    on QueryBuilder<StockMovementIsar, StockMovementIsar, QFilterCondition> {
  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isSynced', value: value),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  itemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itemId', value: ''),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  itemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'itemId', value: ''),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  itemNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itemName', value: ''),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  itemNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'itemName', value: ''),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  movementIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'movementId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  movementIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'movementId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  movementIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'movementId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  movementIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'movementId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  movementIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'movementId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  movementIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'movementId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  movementIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'movementId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  movementIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'movementId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  movementIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'movementId', value: ''),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  movementIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'movementId', value: ''),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  noteEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  noteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  noteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  noteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'note',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  noteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  noteEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'note',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'note',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'note', value: ''),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'quantity', value: value),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
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

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  typeEqualTo(StockMovementType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: value),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  typeGreaterThan(StockMovementType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  typeLessThan(StockMovementType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterFilterCondition>
  typeBetween(
    StockMovementType lower,
    StockMovementType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension StockMovementIsarQueryObject
    on QueryBuilder<StockMovementIsar, StockMovementIsar, QFilterCondition> {}

extension StockMovementIsarQueryLinks
    on QueryBuilder<StockMovementIsar, StockMovementIsar, QFilterCondition> {}

extension StockMovementIsarQuerySortBy
    on QueryBuilder<StockMovementIsar, StockMovementIsar, QSortBy> {
  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByItemName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemName', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByItemNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemName', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByMovementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementId', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByMovementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementId', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension StockMovementIsarQuerySortThenBy
    on QueryBuilder<StockMovementIsar, StockMovementIsar, QSortThenBy> {
  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByItemName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemName', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByItemNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemName', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByMovementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementId', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByMovementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementId', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QAfterSortBy>
  thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension StockMovementIsarQueryWhereDistinct
    on QueryBuilder<StockMovementIsar, StockMovementIsar, QDistinct> {
  QueryBuilder<StockMovementIsar, StockMovementIsar, QDistinct>
  distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QDistinct>
  distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QDistinct>
  distinctByItemId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QDistinct>
  distinctByItemName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QDistinct>
  distinctByMovementId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movementId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QDistinct> distinctByNote({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QDistinct>
  distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementIsar, QDistinct>
  distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension StockMovementIsarQueryProperty
    on QueryBuilder<StockMovementIsar, StockMovementIsar, QQueryProperty> {
  QueryBuilder<StockMovementIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StockMovementIsar, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<StockMovementIsar, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<StockMovementIsar, String, QQueryOperations> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemId');
    });
  }

  QueryBuilder<StockMovementIsar, String, QQueryOperations> itemNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemName');
    });
  }

  QueryBuilder<StockMovementIsar, String, QQueryOperations>
  movementIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movementId');
    });
  }

  QueryBuilder<StockMovementIsar, String, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<StockMovementIsar, int, QQueryOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<StockMovementIsar, StockMovementType, QQueryOperations>
  typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
