// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_cache_entry_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetParentCacheEntryIsarCollection on Isar {
  IsarCollection<ParentCacheEntryIsar> get parentCacheEntryIsars =>
      this.collection();
}

const ParentCacheEntryIsarSchema = CollectionSchema(
  name: r'ParentCacheEntryIsar',
  id: 3849217859219250110,
  properties: {
    r'cacheKey': PropertySchema(
      id: 0,
      name: r'cacheKey',
      type: IsarType.string,
    ),
    r'compositeKey': PropertySchema(
      id: 1,
      name: r'compositeKey',
      type: IsarType.string,
    ),
    r'learnerId': PropertySchema(
      id: 2,
      name: r'learnerId',
      type: IsarType.string,
    ),
    r'parentId': PropertySchema(
      id: 3,
      name: r'parentId',
      type: IsarType.string,
    ),
    r'payloadJson': PropertySchema(
      id: 4,
      name: r'payloadJson',
      type: IsarType.string,
    ),
    r'tenantId': PropertySchema(
      id: 5,
      name: r'tenantId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _parentCacheEntryIsarEstimateSize,
  serialize: _parentCacheEntryIsarSerialize,
  deserialize: _parentCacheEntryIsarDeserialize,
  deserializeProp: _parentCacheEntryIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'compositeKey': IndexSchema(
      id: -66619599277560115,
      name: r'compositeKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'compositeKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'tenantId': IndexSchema(
      id: -1042425927805315167,
      name: r'tenantId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tenantId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'parentId': IndexSchema(
      id: -809199838039056779,
      name: r'parentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'parentId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'learnerId': IndexSchema(
      id: -6935398715013299467,
      name: r'learnerId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'learnerId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _parentCacheEntryIsarGetId,
  getLinks: _parentCacheEntryIsarGetLinks,
  attach: _parentCacheEntryIsarAttach,
  version: '3.1.0+1',
);

int _parentCacheEntryIsarEstimateSize(
  ParentCacheEntryIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cacheKey.length * 3;
  bytesCount += 3 + object.compositeKey.length * 3;
  bytesCount += 3 + object.learnerId.length * 3;
  bytesCount += 3 + object.parentId.length * 3;
  bytesCount += 3 + object.payloadJson.length * 3;
  bytesCount += 3 + object.tenantId.length * 3;
  return bytesCount;
}

void _parentCacheEntryIsarSerialize(
  ParentCacheEntryIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cacheKey);
  writer.writeString(offsets[1], object.compositeKey);
  writer.writeString(offsets[2], object.learnerId);
  writer.writeString(offsets[3], object.parentId);
  writer.writeString(offsets[4], object.payloadJson);
  writer.writeString(offsets[5], object.tenantId);
  writer.writeDateTime(offsets[6], object.updatedAt);
}

ParentCacheEntryIsar _parentCacheEntryIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ParentCacheEntryIsar();
  object.cacheKey = reader.readString(offsets[0]);
  object.compositeKey = reader.readString(offsets[1]);
  object.id = id;
  object.learnerId = reader.readString(offsets[2]);
  object.parentId = reader.readString(offsets[3]);
  object.payloadJson = reader.readString(offsets[4]);
  object.tenantId = reader.readString(offsets[5]);
  object.updatedAt = reader.readDateTime(offsets[6]);
  return object;
}

P _parentCacheEntryIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _parentCacheEntryIsarGetId(ParentCacheEntryIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _parentCacheEntryIsarGetLinks(
  ParentCacheEntryIsar object,
) {
  return [];
}

void _parentCacheEntryIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  ParentCacheEntryIsar object,
) {
  object.id = id;
}

extension ParentCacheEntryIsarByIndex on IsarCollection<ParentCacheEntryIsar> {
  Future<ParentCacheEntryIsar?> getByCompositeKey(String compositeKey) {
    return getByIndex(r'compositeKey', [compositeKey]);
  }

  ParentCacheEntryIsar? getByCompositeKeySync(String compositeKey) {
    return getByIndexSync(r'compositeKey', [compositeKey]);
  }

  Future<bool> deleteByCompositeKey(String compositeKey) {
    return deleteByIndex(r'compositeKey', [compositeKey]);
  }

  bool deleteByCompositeKeySync(String compositeKey) {
    return deleteByIndexSync(r'compositeKey', [compositeKey]);
  }

  Future<List<ParentCacheEntryIsar?>> getAllByCompositeKey(
    List<String> compositeKeyValues,
  ) {
    final values = compositeKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'compositeKey', values);
  }

  List<ParentCacheEntryIsar?> getAllByCompositeKeySync(
    List<String> compositeKeyValues,
  ) {
    final values = compositeKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'compositeKey', values);
  }

  Future<int> deleteAllByCompositeKey(List<String> compositeKeyValues) {
    final values = compositeKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'compositeKey', values);
  }

  int deleteAllByCompositeKeySync(List<String> compositeKeyValues) {
    final values = compositeKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'compositeKey', values);
  }

  Future<Id> putByCompositeKey(ParentCacheEntryIsar object) {
    return putByIndex(r'compositeKey', object);
  }

  Id putByCompositeKeySync(
    ParentCacheEntryIsar object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'compositeKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCompositeKey(List<ParentCacheEntryIsar> objects) {
    return putAllByIndex(r'compositeKey', objects);
  }

  List<Id> putAllByCompositeKeySync(
    List<ParentCacheEntryIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'compositeKey', objects, saveLinks: saveLinks);
  }
}

extension ParentCacheEntryIsarQueryWhereSort
    on QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QWhere> {
  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ParentCacheEntryIsarQueryWhere
    on QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QWhereClause> {
  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterWhereClause>
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

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterWhereClause>
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

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterWhereClause>
  compositeKeyEqualTo(String compositeKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'compositeKey',
          value: [compositeKey],
        ),
      );
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterWhereClause>
  compositeKeyNotEqualTo(String compositeKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'compositeKey',
                lower: [],
                upper: [compositeKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'compositeKey',
                lower: [compositeKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'compositeKey',
                lower: [compositeKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'compositeKey',
                lower: [],
                upper: [compositeKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterWhereClause>
  tenantIdEqualTo(String tenantId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'tenantId', value: [tenantId]),
      );
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterWhereClause>
  tenantIdNotEqualTo(String tenantId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tenantId',
                lower: [],
                upper: [tenantId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tenantId',
                lower: [tenantId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tenantId',
                lower: [tenantId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tenantId',
                lower: [],
                upper: [tenantId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterWhereClause>
  parentIdEqualTo(String parentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'parentId', value: [parentId]),
      );
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterWhereClause>
  parentIdNotEqualTo(String parentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentId',
                lower: [],
                upper: [parentId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentId',
                lower: [parentId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentId',
                lower: [parentId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'parentId',
                lower: [],
                upper: [parentId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterWhereClause>
  learnerIdEqualTo(String learnerId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'learnerId', value: [learnerId]),
      );
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterWhereClause>
  learnerIdNotEqualTo(String learnerId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'learnerId',
                lower: [],
                upper: [learnerId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'learnerId',
                lower: [learnerId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'learnerId',
                lower: [learnerId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'learnerId',
                lower: [],
                upper: [learnerId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension ParentCacheEntryIsarQueryFilter
    on
        QueryBuilder<
          ParentCacheEntryIsar,
          ParentCacheEntryIsar,
          QFilterCondition
        > {
  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  cacheKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cacheKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  cacheKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cacheKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  cacheKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cacheKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  cacheKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cacheKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  cacheKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cacheKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  cacheKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cacheKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  cacheKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cacheKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  cacheKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cacheKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  cacheKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cacheKey', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  cacheKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cacheKey', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  compositeKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'compositeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  compositeKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'compositeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  compositeKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'compositeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  compositeKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'compositeKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  compositeKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'compositeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  compositeKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'compositeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  compositeKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'compositeKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  compositeKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'compositeKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  compositeKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'compositeKey', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  compositeKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'compositeKey', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  learnerIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'learnerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  learnerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'learnerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  learnerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'learnerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  learnerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'learnerId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  learnerIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'learnerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  learnerIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'learnerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  learnerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'learnerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  learnerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'learnerId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  learnerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'learnerId', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  learnerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'learnerId', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  parentIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  parentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  parentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  parentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'parentId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  parentIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  parentIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  parentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'parentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  parentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'parentId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  parentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parentId', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  parentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'parentId', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  payloadJsonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'payloadJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  payloadJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'payloadJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  payloadJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'payloadJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  payloadJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'payloadJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  payloadJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'payloadJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  payloadJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'payloadJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  payloadJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'payloadJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  payloadJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'payloadJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  payloadJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payloadJson', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  payloadJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'payloadJson', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  tenantIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tenantId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  tenantIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tenantId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  tenantIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tenantId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  tenantIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tenantId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  tenantIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tenantId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  tenantIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tenantId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  tenantIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tenantId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  tenantIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tenantId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  tenantIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tenantId', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  tenantIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tenantId', value: ''),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ParentCacheEntryIsar,
    ParentCacheEntryIsar,
    QAfterFilterCondition
  >
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
}

extension ParentCacheEntryIsarQueryObject
    on
        QueryBuilder<
          ParentCacheEntryIsar,
          ParentCacheEntryIsar,
          QFilterCondition
        > {}

extension ParentCacheEntryIsarQueryLinks
    on
        QueryBuilder<
          ParentCacheEntryIsar,
          ParentCacheEntryIsar,
          QFilterCondition
        > {}

extension ParentCacheEntryIsarQuerySortBy
    on QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QSortBy> {
  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  sortByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  sortByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  sortByCompositeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compositeKey', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  sortByCompositeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compositeKey', Sort.desc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  sortByLearnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnerId', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  sortByLearnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnerId', Sort.desc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  sortByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  sortByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  sortByPayloadJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  sortByPayloadJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.desc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  sortByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  sortByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ParentCacheEntryIsarQuerySortThenBy
    on QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QSortThenBy> {
  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByCompositeKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compositeKey', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByCompositeKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compositeKey', Sort.desc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByLearnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnerId', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByLearnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnerId', Sort.desc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByPayloadJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByPayloadJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.desc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ParentCacheEntryIsarQueryWhereDistinct
    on QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QDistinct> {
  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QDistinct>
  distinctByCacheKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cacheKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QDistinct>
  distinctByCompositeKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'compositeKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QDistinct>
  distinctByLearnerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'learnerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QDistinct>
  distinctByParentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QDistinct>
  distinctByPayloadJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payloadJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QDistinct>
  distinctByTenantId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tenantId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParentCacheEntryIsar, ParentCacheEntryIsar, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ParentCacheEntryIsarQueryProperty
    on
        QueryBuilder<
          ParentCacheEntryIsar,
          ParentCacheEntryIsar,
          QQueryProperty
        > {
  QueryBuilder<ParentCacheEntryIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ParentCacheEntryIsar, String, QQueryOperations>
  cacheKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cacheKey');
    });
  }

  QueryBuilder<ParentCacheEntryIsar, String, QQueryOperations>
  compositeKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'compositeKey');
    });
  }

  QueryBuilder<ParentCacheEntryIsar, String, QQueryOperations>
  learnerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'learnerId');
    });
  }

  QueryBuilder<ParentCacheEntryIsar, String, QQueryOperations>
  parentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentId');
    });
  }

  QueryBuilder<ParentCacheEntryIsar, String, QQueryOperations>
  payloadJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payloadJson');
    });
  }

  QueryBuilder<ParentCacheEntryIsar, String, QQueryOperations>
  tenantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tenantId');
    });
  }

  QueryBuilder<ParentCacheEntryIsar, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
