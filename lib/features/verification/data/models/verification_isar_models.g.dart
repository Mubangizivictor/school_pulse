// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_isar_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCachedCredentialIsarCollection on Isar {
  IsarCollection<CachedCredentialIsar> get cachedCredentialIsars =>
      this.collection();
}

const CachedCredentialIsarSchema = CollectionSchema(
  name: r'CachedCredentialIsar',
  id: -1583512350188039195,
  properties: {
    r'credentialType': PropertySchema(
      id: 0,
      name: r'credentialType',
      type: IsarType.string,
    ),
    r'credentialValue': PropertySchema(
      id: 1,
      name: r'credentialValue',
      type: IsarType.string,
    ),
    r'identityId': PropertySchema(
      id: 2,
      name: r'identityId',
      type: IsarType.string,
    ),
    r'identityType': PropertySchema(
      id: 3,
      name: r'identityType',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 4,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(id: 5, name: r'status', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _cachedCredentialIsarEstimateSize,
  serialize: _cachedCredentialIsarSerialize,
  deserialize: _cachedCredentialIsarDeserialize,
  deserializeProp: _cachedCredentialIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'credentialValue': IndexSchema(
      id: -6424725189873027203,
      name: r'credentialValue',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'credentialValue',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'schoolId': IndexSchema(
      id: 6631843591736686975,
      name: r'schoolId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'schoolId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _cachedCredentialIsarGetId,
  getLinks: _cachedCredentialIsarGetLinks,
  attach: _cachedCredentialIsarAttach,
  version: '3.1.0+1',
);

int _cachedCredentialIsarEstimateSize(
  CachedCredentialIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.credentialType.length * 3;
  bytesCount += 3 + object.credentialValue.length * 3;
  bytesCount += 3 + object.identityId.length * 3;
  bytesCount += 3 + object.identityType.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _cachedCredentialIsarSerialize(
  CachedCredentialIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.credentialType);
  writer.writeString(offsets[1], object.credentialValue);
  writer.writeString(offsets[2], object.identityId);
  writer.writeString(offsets[3], object.identityType);
  writer.writeString(offsets[4], object.schoolId);
  writer.writeString(offsets[5], object.status);
  writer.writeDateTime(offsets[6], object.updatedAt);
}

CachedCredentialIsar _cachedCredentialIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CachedCredentialIsar();
  object.credentialType = reader.readString(offsets[0]);
  object.credentialValue = reader.readString(offsets[1]);
  object.id = id;
  object.identityId = reader.readString(offsets[2]);
  object.identityType = reader.readString(offsets[3]);
  object.schoolId = reader.readString(offsets[4]);
  object.status = reader.readString(offsets[5]);
  object.updatedAt = reader.readDateTime(offsets[6]);
  return object;
}

P _cachedCredentialIsarDeserializeProp<P>(
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

Id _cachedCredentialIsarGetId(CachedCredentialIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cachedCredentialIsarGetLinks(
  CachedCredentialIsar object,
) {
  return [];
}

void _cachedCredentialIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  CachedCredentialIsar object,
) {
  object.id = id;
}

extension CachedCredentialIsarByIndex on IsarCollection<CachedCredentialIsar> {
  Future<CachedCredentialIsar?> getByCredentialValue(String credentialValue) {
    return getByIndex(r'credentialValue', [credentialValue]);
  }

  CachedCredentialIsar? getByCredentialValueSync(String credentialValue) {
    return getByIndexSync(r'credentialValue', [credentialValue]);
  }

  Future<bool> deleteByCredentialValue(String credentialValue) {
    return deleteByIndex(r'credentialValue', [credentialValue]);
  }

  bool deleteByCredentialValueSync(String credentialValue) {
    return deleteByIndexSync(r'credentialValue', [credentialValue]);
  }

  Future<List<CachedCredentialIsar?>> getAllByCredentialValue(
    List<String> credentialValueValues,
  ) {
    final values = credentialValueValues.map((e) => [e]).toList();
    return getAllByIndex(r'credentialValue', values);
  }

  List<CachedCredentialIsar?> getAllByCredentialValueSync(
    List<String> credentialValueValues,
  ) {
    final values = credentialValueValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'credentialValue', values);
  }

  Future<int> deleteAllByCredentialValue(List<String> credentialValueValues) {
    final values = credentialValueValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'credentialValue', values);
  }

  int deleteAllByCredentialValueSync(List<String> credentialValueValues) {
    final values = credentialValueValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'credentialValue', values);
  }

  Future<Id> putByCredentialValue(CachedCredentialIsar object) {
    return putByIndex(r'credentialValue', object);
  }

  Id putByCredentialValueSync(
    CachedCredentialIsar object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'credentialValue', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCredentialValue(List<CachedCredentialIsar> objects) {
    return putAllByIndex(r'credentialValue', objects);
  }

  List<Id> putAllByCredentialValueSync(
    List<CachedCredentialIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'credentialValue', objects, saveLinks: saveLinks);
  }
}

extension CachedCredentialIsarQueryWhereSort
    on QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QWhere> {
  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CachedCredentialIsarQueryWhere
    on QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QWhereClause> {
  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterWhereClause>
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

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterWhereClause>
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

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterWhereClause>
  credentialValueEqualTo(String credentialValue) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'credentialValue',
          value: [credentialValue],
        ),
      );
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterWhereClause>
  credentialValueNotEqualTo(String credentialValue) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'credentialValue',
                lower: [],
                upper: [credentialValue],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'credentialValue',
                lower: [credentialValue],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'credentialValue',
                lower: [credentialValue],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'credentialValue',
                lower: [],
                upper: [credentialValue],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterWhereClause>
  schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'schoolId', value: [schoolId]),
      );
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterWhereClause>
  schoolIdNotEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [],
                upper: [schoolId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [schoolId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [schoolId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [],
                upper: [schoolId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension CachedCredentialIsarQueryFilter
    on
        QueryBuilder<
          CachedCredentialIsar,
          CachedCredentialIsar,
          QFilterCondition
        > {
  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'credentialType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'credentialType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'credentialType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'credentialType',
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
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'credentialType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'credentialType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'credentialType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'credentialType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'credentialType', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'credentialType', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'credentialValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'credentialValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'credentialValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'credentialValue',
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
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'credentialValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'credentialValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'credentialValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'credentialValue',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'credentialValue', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'credentialValue', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
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
    CachedCredentialIsar,
    CachedCredentialIsar,
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
    CachedCredentialIsar,
    CachedCredentialIsar,
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
    CachedCredentialIsar,
    CachedCredentialIsar,
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
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'identityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'identityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'identityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'identityId',
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
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'identityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'identityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'identityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'identityId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'identityId', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'identityId', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'identityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'identityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'identityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'identityType',
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
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'identityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'identityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'identityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'identityType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'identityType', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  identityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'identityType', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  statusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
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
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
    QAfterFilterCondition
  >
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<
    CachedCredentialIsar,
    CachedCredentialIsar,
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
    CachedCredentialIsar,
    CachedCredentialIsar,
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
    CachedCredentialIsar,
    CachedCredentialIsar,
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
    CachedCredentialIsar,
    CachedCredentialIsar,
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

extension CachedCredentialIsarQueryObject
    on
        QueryBuilder<
          CachedCredentialIsar,
          CachedCredentialIsar,
          QFilterCondition
        > {}

extension CachedCredentialIsarQueryLinks
    on
        QueryBuilder<
          CachedCredentialIsar,
          CachedCredentialIsar,
          QFilterCondition
        > {}

extension CachedCredentialIsarQuerySortBy
    on QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QSortBy> {
  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  sortByCredentialType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialType', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  sortByCredentialTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialType', Sort.desc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  sortByCredentialValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialValue', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  sortByCredentialValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialValue', Sort.desc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  sortByIdentityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityId', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  sortByIdentityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityId', Sort.desc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  sortByIdentityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityType', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  sortByIdentityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityType', Sort.desc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CachedCredentialIsarQuerySortThenBy
    on QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QSortThenBy> {
  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenByCredentialType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialType', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenByCredentialTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialType', Sort.desc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenByCredentialValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialValue', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenByCredentialValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialValue', Sort.desc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenByIdentityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityId', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenByIdentityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityId', Sort.desc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenByIdentityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityType', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenByIdentityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityType', Sort.desc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CachedCredentialIsarQueryWhereDistinct
    on QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QDistinct> {
  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QDistinct>
  distinctByCredentialType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'credentialType',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QDistinct>
  distinctByCredentialValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'credentialValue',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QDistinct>
  distinctByIdentityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'identityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QDistinct>
  distinctByIdentityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'identityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QDistinct>
  distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedCredentialIsar, CachedCredentialIsar, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension CachedCredentialIsarQueryProperty
    on
        QueryBuilder<
          CachedCredentialIsar,
          CachedCredentialIsar,
          QQueryProperty
        > {
  QueryBuilder<CachedCredentialIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CachedCredentialIsar, String, QQueryOperations>
  credentialTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'credentialType');
    });
  }

  QueryBuilder<CachedCredentialIsar, String, QQueryOperations>
  credentialValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'credentialValue');
    });
  }

  QueryBuilder<CachedCredentialIsar, String, QQueryOperations>
  identityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'identityId');
    });
  }

  QueryBuilder<CachedCredentialIsar, String, QQueryOperations>
  identityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'identityType');
    });
  }

  QueryBuilder<CachedCredentialIsar, String, QQueryOperations>
  schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<CachedCredentialIsar, String, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<CachedCredentialIsar, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRevokedCredentialIsarCollection on Isar {
  IsarCollection<RevokedCredentialIsar> get revokedCredentialIsars =>
      this.collection();
}

const RevokedCredentialIsarSchema = CollectionSchema(
  name: r'RevokedCredentialIsar',
  id: -8188034227960797383,
  properties: {
    r'credentialValue': PropertySchema(
      id: 0,
      name: r'credentialValue',
      type: IsarType.string,
    ),
    r'reason': PropertySchema(id: 1, name: r'reason', type: IsarType.string),
    r'revokedAt': PropertySchema(
      id: 2,
      name: r'revokedAt',
      type: IsarType.dateTime,
    ),
    r'schoolId': PropertySchema(
      id: 3,
      name: r'schoolId',
      type: IsarType.string,
    ),
  },
  estimateSize: _revokedCredentialIsarEstimateSize,
  serialize: _revokedCredentialIsarSerialize,
  deserialize: _revokedCredentialIsarDeserialize,
  deserializeProp: _revokedCredentialIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'credentialValue': IndexSchema(
      id: -6424725189873027203,
      name: r'credentialValue',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'credentialValue',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'schoolId': IndexSchema(
      id: 6631843591736686975,
      name: r'schoolId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'schoolId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _revokedCredentialIsarGetId,
  getLinks: _revokedCredentialIsarGetLinks,
  attach: _revokedCredentialIsarAttach,
  version: '3.1.0+1',
);

int _revokedCredentialIsarEstimateSize(
  RevokedCredentialIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.credentialValue.length * 3;
  bytesCount += 3 + object.reason.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  return bytesCount;
}

void _revokedCredentialIsarSerialize(
  RevokedCredentialIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.credentialValue);
  writer.writeString(offsets[1], object.reason);
  writer.writeDateTime(offsets[2], object.revokedAt);
  writer.writeString(offsets[3], object.schoolId);
}

RevokedCredentialIsar _revokedCredentialIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RevokedCredentialIsar();
  object.credentialValue = reader.readString(offsets[0]);
  object.id = id;
  object.reason = reader.readString(offsets[1]);
  object.revokedAt = reader.readDateTime(offsets[2]);
  object.schoolId = reader.readString(offsets[3]);
  return object;
}

P _revokedCredentialIsarDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _revokedCredentialIsarGetId(RevokedCredentialIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _revokedCredentialIsarGetLinks(
  RevokedCredentialIsar object,
) {
  return [];
}

void _revokedCredentialIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  RevokedCredentialIsar object,
) {
  object.id = id;
}

extension RevokedCredentialIsarByIndex
    on IsarCollection<RevokedCredentialIsar> {
  Future<RevokedCredentialIsar?> getByCredentialValue(String credentialValue) {
    return getByIndex(r'credentialValue', [credentialValue]);
  }

  RevokedCredentialIsar? getByCredentialValueSync(String credentialValue) {
    return getByIndexSync(r'credentialValue', [credentialValue]);
  }

  Future<bool> deleteByCredentialValue(String credentialValue) {
    return deleteByIndex(r'credentialValue', [credentialValue]);
  }

  bool deleteByCredentialValueSync(String credentialValue) {
    return deleteByIndexSync(r'credentialValue', [credentialValue]);
  }

  Future<List<RevokedCredentialIsar?>> getAllByCredentialValue(
    List<String> credentialValueValues,
  ) {
    final values = credentialValueValues.map((e) => [e]).toList();
    return getAllByIndex(r'credentialValue', values);
  }

  List<RevokedCredentialIsar?> getAllByCredentialValueSync(
    List<String> credentialValueValues,
  ) {
    final values = credentialValueValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'credentialValue', values);
  }

  Future<int> deleteAllByCredentialValue(List<String> credentialValueValues) {
    final values = credentialValueValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'credentialValue', values);
  }

  int deleteAllByCredentialValueSync(List<String> credentialValueValues) {
    final values = credentialValueValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'credentialValue', values);
  }

  Future<Id> putByCredentialValue(RevokedCredentialIsar object) {
    return putByIndex(r'credentialValue', object);
  }

  Id putByCredentialValueSync(
    RevokedCredentialIsar object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'credentialValue', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCredentialValue(
    List<RevokedCredentialIsar> objects,
  ) {
    return putAllByIndex(r'credentialValue', objects);
  }

  List<Id> putAllByCredentialValueSync(
    List<RevokedCredentialIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'credentialValue', objects, saveLinks: saveLinks);
  }
}

extension RevokedCredentialIsarQueryWhereSort
    on QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QWhere> {
  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RevokedCredentialIsarQueryWhere
    on
        QueryBuilder<
          RevokedCredentialIsar,
          RevokedCredentialIsar,
          QWhereClause
        > {
  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterWhereClause>
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

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterWhereClause>
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

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterWhereClause>
  credentialValueEqualTo(String credentialValue) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'credentialValue',
          value: [credentialValue],
        ),
      );
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterWhereClause>
  credentialValueNotEqualTo(String credentialValue) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'credentialValue',
                lower: [],
                upper: [credentialValue],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'credentialValue',
                lower: [credentialValue],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'credentialValue',
                lower: [credentialValue],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'credentialValue',
                lower: [],
                upper: [credentialValue],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterWhereClause>
  schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'schoolId', value: [schoolId]),
      );
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterWhereClause>
  schoolIdNotEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [],
                upper: [schoolId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [schoolId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [schoolId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [],
                upper: [schoolId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension RevokedCredentialIsarQueryFilter
    on
        QueryBuilder<
          RevokedCredentialIsar,
          RevokedCredentialIsar,
          QFilterCondition
        > {
  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'credentialValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'credentialValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'credentialValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'credentialValue',
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
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'credentialValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'credentialValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'credentialValue',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'credentialValue',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'credentialValue', value: ''),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  credentialValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'credentialValue', value: ''),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
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
    RevokedCredentialIsar,
    RevokedCredentialIsar,
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
    RevokedCredentialIsar,
    RevokedCredentialIsar,
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
    RevokedCredentialIsar,
    RevokedCredentialIsar,
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
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  reasonEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  reasonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  reasonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  reasonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reason',
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
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  reasonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  reasonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'reason',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reason', value: ''),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'reason', value: ''),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  revokedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'revokedAt', value: value),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  revokedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'revokedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  revokedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'revokedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  revokedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'revokedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<
    RevokedCredentialIsar,
    RevokedCredentialIsar,
    QAfterFilterCondition
  >
  schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'schoolId', value: ''),
      );
    });
  }
}

extension RevokedCredentialIsarQueryObject
    on
        QueryBuilder<
          RevokedCredentialIsar,
          RevokedCredentialIsar,
          QFilterCondition
        > {}

extension RevokedCredentialIsarQueryLinks
    on
        QueryBuilder<
          RevokedCredentialIsar,
          RevokedCredentialIsar,
          QFilterCondition
        > {}

extension RevokedCredentialIsarQuerySortBy
    on QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QSortBy> {
  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  sortByCredentialValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialValue', Sort.asc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  sortByCredentialValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialValue', Sort.desc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  sortByRevokedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revokedAt', Sort.asc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  sortByRevokedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revokedAt', Sort.desc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }
}

extension RevokedCredentialIsarQuerySortThenBy
    on QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QSortThenBy> {
  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  thenByCredentialValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialValue', Sort.asc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  thenByCredentialValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialValue', Sort.desc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  thenByRevokedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revokedAt', Sort.asc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  thenByRevokedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'revokedAt', Sort.desc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QAfterSortBy>
  thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }
}

extension RevokedCredentialIsarQueryWhereDistinct
    on QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QDistinct> {
  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QDistinct>
  distinctByCredentialValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'credentialValue',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QDistinct>
  distinctByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QDistinct>
  distinctByRevokedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'revokedAt');
    });
  }

  QueryBuilder<RevokedCredentialIsar, RevokedCredentialIsar, QDistinct>
  distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }
}

extension RevokedCredentialIsarQueryProperty
    on
        QueryBuilder<
          RevokedCredentialIsar,
          RevokedCredentialIsar,
          QQueryProperty
        > {
  QueryBuilder<RevokedCredentialIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RevokedCredentialIsar, String, QQueryOperations>
  credentialValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'credentialValue');
    });
  }

  QueryBuilder<RevokedCredentialIsar, String, QQueryOperations>
  reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<RevokedCredentialIsar, DateTime, QQueryOperations>
  revokedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'revokedAt');
    });
  }

  QueryBuilder<RevokedCredentialIsar, String, QQueryOperations>
  schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVerificationEventIsarCollection on Isar {
  IsarCollection<VerificationEventIsar> get verificationEventIsars =>
      this.collection();
}

const VerificationEventIsarSchema = CollectionSchema(
  name: r'VerificationEventIsar',
  id: 3640940316751862221,
  properties: {
    r'credentialKind': PropertySchema(
      id: 0,
      name: r'credentialKind',
      type: IsarType.string,
    ),
    r'deviceId': PropertySchema(
      id: 1,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'direction': PropertySchema(
      id: 2,
      name: r'direction',
      type: IsarType.string,
    ),
    r'eventId': PropertySchema(id: 3, name: r'eventId', type: IsarType.string),
    r'gateId': PropertySchema(id: 4, name: r'gateId', type: IsarType.string),
    r'identityId': PropertySchema(
      id: 5,
      name: r'identityId',
      type: IsarType.string,
    ),
    r'identityType': PropertySchema(
      id: 6,
      name: r'identityType',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(id: 7, name: r'isSynced', type: IsarType.bool),
    r'operatorId': PropertySchema(
      id: 8,
      name: r'operatorId',
      type: IsarType.string,
    ),
    r'outcome': PropertySchema(id: 9, name: r'outcome', type: IsarType.string),
    r'reasonCode': PropertySchema(
      id: 10,
      name: r'reasonCode',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 11,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 12,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _verificationEventIsarEstimateSize,
  serialize: _verificationEventIsarSerialize,
  deserialize: _verificationEventIsarDeserialize,
  deserializeProp: _verificationEventIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'eventId': IndexSchema(
      id: -2707901133518603130,
      name: r'eventId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'eventId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'schoolId': IndexSchema(
      id: 6631843591736686975,
      name: r'schoolId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'schoolId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'gateId': IndexSchema(
      id: 7381608507701441698,
      name: r'gateId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'gateId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'isSynced': IndexSchema(
      id: -39763503327887510,
      name: r'isSynced',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isSynced',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _verificationEventIsarGetId,
  getLinks: _verificationEventIsarGetLinks,
  attach: _verificationEventIsarAttach,
  version: '3.1.0+1',
);

int _verificationEventIsarEstimateSize(
  VerificationEventIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.credentialKind.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.direction.length * 3;
  bytesCount += 3 + object.eventId.length * 3;
  bytesCount += 3 + object.gateId.length * 3;
  bytesCount += 3 + object.identityId.length * 3;
  bytesCount += 3 + object.identityType.length * 3;
  bytesCount += 3 + object.operatorId.length * 3;
  bytesCount += 3 + object.outcome.length * 3;
  {
    final value = object.reasonCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolId.length * 3;
  return bytesCount;
}

void _verificationEventIsarSerialize(
  VerificationEventIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.credentialKind);
  writer.writeString(offsets[1], object.deviceId);
  writer.writeString(offsets[2], object.direction);
  writer.writeString(offsets[3], object.eventId);
  writer.writeString(offsets[4], object.gateId);
  writer.writeString(offsets[5], object.identityId);
  writer.writeString(offsets[6], object.identityType);
  writer.writeBool(offsets[7], object.isSynced);
  writer.writeString(offsets[8], object.operatorId);
  writer.writeString(offsets[9], object.outcome);
  writer.writeString(offsets[10], object.reasonCode);
  writer.writeString(offsets[11], object.schoolId);
  writer.writeDateTime(offsets[12], object.timestamp);
}

VerificationEventIsar _verificationEventIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VerificationEventIsar();
  object.credentialKind = reader.readString(offsets[0]);
  object.deviceId = reader.readString(offsets[1]);
  object.direction = reader.readString(offsets[2]);
  object.eventId = reader.readString(offsets[3]);
  object.gateId = reader.readString(offsets[4]);
  object.id = id;
  object.identityId = reader.readString(offsets[5]);
  object.identityType = reader.readString(offsets[6]);
  object.isSynced = reader.readBool(offsets[7]);
  object.operatorId = reader.readString(offsets[8]);
  object.outcome = reader.readString(offsets[9]);
  object.reasonCode = reader.readStringOrNull(offsets[10]);
  object.schoolId = reader.readString(offsets[11]);
  object.timestamp = reader.readDateTime(offsets[12]);
  return object;
}

P _verificationEventIsarDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _verificationEventIsarGetId(VerificationEventIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _verificationEventIsarGetLinks(
  VerificationEventIsar object,
) {
  return [];
}

void _verificationEventIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  VerificationEventIsar object,
) {
  object.id = id;
}

extension VerificationEventIsarByIndex
    on IsarCollection<VerificationEventIsar> {
  Future<VerificationEventIsar?> getByEventId(String eventId) {
    return getByIndex(r'eventId', [eventId]);
  }

  VerificationEventIsar? getByEventIdSync(String eventId) {
    return getByIndexSync(r'eventId', [eventId]);
  }

  Future<bool> deleteByEventId(String eventId) {
    return deleteByIndex(r'eventId', [eventId]);
  }

  bool deleteByEventIdSync(String eventId) {
    return deleteByIndexSync(r'eventId', [eventId]);
  }

  Future<List<VerificationEventIsar?>> getAllByEventId(
    List<String> eventIdValues,
  ) {
    final values = eventIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'eventId', values);
  }

  List<VerificationEventIsar?> getAllByEventIdSync(List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'eventId', values);
  }

  Future<int> deleteAllByEventId(List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'eventId', values);
  }

  int deleteAllByEventIdSync(List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'eventId', values);
  }

  Future<Id> putByEventId(VerificationEventIsar object) {
    return putByIndex(r'eventId', object);
  }

  Id putByEventIdSync(VerificationEventIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'eventId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEventId(List<VerificationEventIsar> objects) {
    return putAllByIndex(r'eventId', objects);
  }

  List<Id> putAllByEventIdSync(
    List<VerificationEventIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'eventId', objects, saveLinks: saveLinks);
  }
}

extension VerificationEventIsarQueryWhereSort
    on QueryBuilder<VerificationEventIsar, VerificationEventIsar, QWhere> {
  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhere>
  anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhere>
  anyIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSynced'),
      );
    });
  }
}

extension VerificationEventIsarQueryWhere
    on
        QueryBuilder<
          VerificationEventIsar,
          VerificationEventIsar,
          QWhereClause
        > {
  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
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

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
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

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  eventIdEqualTo(String eventId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'eventId', value: [eventId]),
      );
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  eventIdNotEqualTo(String eventId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [],
                upper: [eventId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [eventId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [eventId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'eventId',
                lower: [],
                upper: [eventId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'schoolId', value: [schoolId]),
      );
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  schoolIdNotEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [],
                upper: [schoolId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [schoolId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [schoolId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [],
                upper: [schoolId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  gateIdEqualTo(String gateId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'gateId', value: [gateId]),
      );
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  gateIdNotEqualTo(String gateId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'gateId',
                lower: [],
                upper: [gateId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'gateId',
                lower: [gateId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'gateId',
                lower: [gateId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'gateId',
                lower: [],
                upper: [gateId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'timestamp', value: [timestamp]),
      );
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [],
                upper: [timestamp],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [timestamp],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [timestamp],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'timestamp',
                lower: [],
                upper: [timestamp],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  timestampGreaterThan(DateTime timestamp, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [timestamp],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  timestampLessThan(DateTime timestamp, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [],
          upper: [timestamp],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'timestamp',
          lower: [lowerTimestamp],
          includeLower: includeLower,
          upper: [upperTimestamp],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  isSyncedEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'isSynced', value: [isSynced]),
      );
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterWhereClause>
  isSyncedNotEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isSynced',
                lower: [],
                upper: [isSynced],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isSynced',
                lower: [isSynced],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isSynced',
                lower: [isSynced],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isSynced',
                lower: [],
                upper: [isSynced],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension VerificationEventIsarQueryFilter
    on
        QueryBuilder<
          VerificationEventIsar,
          VerificationEventIsar,
          QFilterCondition
        > {
  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  credentialKindEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'credentialKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  credentialKindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'credentialKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  credentialKindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'credentialKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  credentialKindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'credentialKind',
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
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  credentialKindStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'credentialKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  credentialKindEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'credentialKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  credentialKindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'credentialKind',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  credentialKindMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'credentialKind',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  credentialKindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'credentialKind', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  credentialKindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'credentialKind', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  deviceIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deviceId',
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
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  deviceIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  deviceIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'deviceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deviceId', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'deviceId', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  directionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  directionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  directionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  directionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'direction',
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
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  directionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  directionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  directionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'direction',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  directionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'direction',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  directionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'direction', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  directionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'direction', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  eventIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  eventIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  eventIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  eventIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'eventId',
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
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  eventIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  eventIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  eventIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'eventId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  eventIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'eventId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  eventIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'eventId', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  eventIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'eventId', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  gateIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'gateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  gateIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'gateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  gateIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'gateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  gateIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'gateId',
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
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  gateIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'gateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  gateIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'gateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  gateIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'gateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  gateIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'gateId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  gateIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'gateId', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  gateIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'gateId', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
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
    VerificationEventIsar,
    VerificationEventIsar,
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
    VerificationEventIsar,
    VerificationEventIsar,
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
    VerificationEventIsar,
    VerificationEventIsar,
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
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'identityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'identityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'identityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'identityId',
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
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'identityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'identityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'identityId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'identityId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'identityId', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'identityId', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'identityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'identityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'identityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'identityType',
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
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'identityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'identityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'identityType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'identityType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'identityType', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  identityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'identityType', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isSynced', value: value),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  operatorIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'operatorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  operatorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'operatorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  operatorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'operatorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  operatorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'operatorId',
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
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  operatorIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'operatorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  operatorIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'operatorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  operatorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'operatorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  operatorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'operatorId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  operatorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'operatorId', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  operatorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'operatorId', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  outcomeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  outcomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  outcomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  outcomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'outcome',
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
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  outcomeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  outcomeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  outcomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'outcome',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  outcomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'outcome',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  outcomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'outcome', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  outcomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'outcome', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  reasonCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'reasonCode'),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  reasonCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'reasonCode'),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  reasonCodeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'reasonCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  reasonCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reasonCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  reasonCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reasonCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  reasonCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reasonCode',
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
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  reasonCodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'reasonCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  reasonCodeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'reasonCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  reasonCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'reasonCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  reasonCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'reasonCode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  reasonCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reasonCode', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  reasonCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'reasonCode', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  timestampGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  timestampLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    VerificationEventIsar,
    VerificationEventIsar,
    QAfterFilterCondition
  >
  timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension VerificationEventIsarQueryObject
    on
        QueryBuilder<
          VerificationEventIsar,
          VerificationEventIsar,
          QFilterCondition
        > {}

extension VerificationEventIsarQueryLinks
    on
        QueryBuilder<
          VerificationEventIsar,
          VerificationEventIsar,
          QFilterCondition
        > {}

extension VerificationEventIsarQuerySortBy
    on QueryBuilder<VerificationEventIsar, VerificationEventIsar, QSortBy> {
  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByCredentialKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialKind', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByCredentialKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialKind', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByGateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByGateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByIdentityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityId', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByIdentityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityId', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByIdentityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityType', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByIdentityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityType', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByOperatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByOperatorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByOutcomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByReasonCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reasonCode', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByReasonCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reasonCode', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension VerificationEventIsarQuerySortThenBy
    on QueryBuilder<VerificationEventIsar, VerificationEventIsar, QSortThenBy> {
  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByCredentialKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialKind', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByCredentialKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'credentialKind', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByGateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByGateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByIdentityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityId', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByIdentityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityId', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByIdentityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityType', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByIdentityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identityType', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByOperatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByOperatorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByOutcomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByReasonCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reasonCode', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByReasonCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reasonCode', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension VerificationEventIsarQueryWhereDistinct
    on QueryBuilder<VerificationEventIsar, VerificationEventIsar, QDistinct> {
  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QDistinct>
  distinctByCredentialKind({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'credentialKind',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QDistinct>
  distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QDistinct>
  distinctByDirection({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'direction', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QDistinct>
  distinctByEventId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QDistinct>
  distinctByGateId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gateId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QDistinct>
  distinctByIdentityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'identityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QDistinct>
  distinctByIdentityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'identityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QDistinct>
  distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QDistinct>
  distinctByOperatorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operatorId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QDistinct>
  distinctByOutcome({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outcome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QDistinct>
  distinctByReasonCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reasonCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QDistinct>
  distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VerificationEventIsar, VerificationEventIsar, QDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension VerificationEventIsarQueryProperty
    on
        QueryBuilder<
          VerificationEventIsar,
          VerificationEventIsar,
          QQueryProperty
        > {
  QueryBuilder<VerificationEventIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VerificationEventIsar, String, QQueryOperations>
  credentialKindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'credentialKind');
    });
  }

  QueryBuilder<VerificationEventIsar, String, QQueryOperations>
  deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<VerificationEventIsar, String, QQueryOperations>
  directionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'direction');
    });
  }

  QueryBuilder<VerificationEventIsar, String, QQueryOperations>
  eventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventId');
    });
  }

  QueryBuilder<VerificationEventIsar, String, QQueryOperations>
  gateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gateId');
    });
  }

  QueryBuilder<VerificationEventIsar, String, QQueryOperations>
  identityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'identityId');
    });
  }

  QueryBuilder<VerificationEventIsar, String, QQueryOperations>
  identityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'identityType');
    });
  }

  QueryBuilder<VerificationEventIsar, bool, QQueryOperations>
  isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<VerificationEventIsar, String, QQueryOperations>
  operatorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operatorId');
    });
  }

  QueryBuilder<VerificationEventIsar, String, QQueryOperations>
  outcomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outcome');
    });
  }

  QueryBuilder<VerificationEventIsar, String?, QQueryOperations>
  reasonCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reasonCode');
    });
  }

  QueryBuilder<VerificationEventIsar, String, QQueryOperations>
  schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<VerificationEventIsar, DateTime, QQueryOperations>
  timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAuthorizedDeviceIsarCollection on Isar {
  IsarCollection<AuthorizedDeviceIsar> get authorizedDeviceIsars =>
      this.collection();
}

const AuthorizedDeviceIsarSchema = CollectionSchema(
  name: r'AuthorizedDeviceIsar',
  id: -1952359740929325639,
  properties: {
    r'deviceId': PropertySchema(
      id: 0,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'gateId': PropertySchema(id: 1, name: r'gateId', type: IsarType.string),
    r'isActive': PropertySchema(id: 2, name: r'isActive', type: IsarType.bool),
    r'label': PropertySchema(id: 3, name: r'label', type: IsarType.string),
    r'registeredAt': PropertySchema(
      id: 4,
      name: r'registeredAt',
      type: IsarType.dateTime,
    ),
    r'schoolId': PropertySchema(
      id: 5,
      name: r'schoolId',
      type: IsarType.string,
    ),
  },
  estimateSize: _authorizedDeviceIsarEstimateSize,
  serialize: _authorizedDeviceIsarSerialize,
  deserialize: _authorizedDeviceIsarDeserialize,
  deserializeProp: _authorizedDeviceIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'deviceId': IndexSchema(
      id: 4442814072367132509,
      name: r'deviceId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'deviceId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'schoolId': IndexSchema(
      id: 6631843591736686975,
      name: r'schoolId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'schoolId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _authorizedDeviceIsarGetId,
  getLinks: _authorizedDeviceIsarGetLinks,
  attach: _authorizedDeviceIsarAttach,
  version: '3.1.0+1',
);

int _authorizedDeviceIsarEstimateSize(
  AuthorizedDeviceIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.deviceId.length * 3;
  {
    final value = object.gateId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.label.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  return bytesCount;
}

void _authorizedDeviceIsarSerialize(
  AuthorizedDeviceIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.deviceId);
  writer.writeString(offsets[1], object.gateId);
  writer.writeBool(offsets[2], object.isActive);
  writer.writeString(offsets[3], object.label);
  writer.writeDateTime(offsets[4], object.registeredAt);
  writer.writeString(offsets[5], object.schoolId);
}

AuthorizedDeviceIsar _authorizedDeviceIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AuthorizedDeviceIsar();
  object.deviceId = reader.readString(offsets[0]);
  object.gateId = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.isActive = reader.readBool(offsets[2]);
  object.label = reader.readString(offsets[3]);
  object.registeredAt = reader.readDateTime(offsets[4]);
  object.schoolId = reader.readString(offsets[5]);
  return object;
}

P _authorizedDeviceIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _authorizedDeviceIsarGetId(AuthorizedDeviceIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _authorizedDeviceIsarGetLinks(
  AuthorizedDeviceIsar object,
) {
  return [];
}

void _authorizedDeviceIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  AuthorizedDeviceIsar object,
) {
  object.id = id;
}

extension AuthorizedDeviceIsarByIndex on IsarCollection<AuthorizedDeviceIsar> {
  Future<AuthorizedDeviceIsar?> getByDeviceId(String deviceId) {
    return getByIndex(r'deviceId', [deviceId]);
  }

  AuthorizedDeviceIsar? getByDeviceIdSync(String deviceId) {
    return getByIndexSync(r'deviceId', [deviceId]);
  }

  Future<bool> deleteByDeviceId(String deviceId) {
    return deleteByIndex(r'deviceId', [deviceId]);
  }

  bool deleteByDeviceIdSync(String deviceId) {
    return deleteByIndexSync(r'deviceId', [deviceId]);
  }

  Future<List<AuthorizedDeviceIsar?>> getAllByDeviceId(
    List<String> deviceIdValues,
  ) {
    final values = deviceIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'deviceId', values);
  }

  List<AuthorizedDeviceIsar?> getAllByDeviceIdSync(
    List<String> deviceIdValues,
  ) {
    final values = deviceIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'deviceId', values);
  }

  Future<int> deleteAllByDeviceId(List<String> deviceIdValues) {
    final values = deviceIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'deviceId', values);
  }

  int deleteAllByDeviceIdSync(List<String> deviceIdValues) {
    final values = deviceIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'deviceId', values);
  }

  Future<Id> putByDeviceId(AuthorizedDeviceIsar object) {
    return putByIndex(r'deviceId', object);
  }

  Id putByDeviceIdSync(AuthorizedDeviceIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'deviceId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDeviceId(List<AuthorizedDeviceIsar> objects) {
    return putAllByIndex(r'deviceId', objects);
  }

  List<Id> putAllByDeviceIdSync(
    List<AuthorizedDeviceIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'deviceId', objects, saveLinks: saveLinks);
  }
}

extension AuthorizedDeviceIsarQueryWhereSort
    on QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QWhere> {
  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AuthorizedDeviceIsarQueryWhere
    on QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QWhereClause> {
  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterWhereClause>
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

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterWhereClause>
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

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterWhereClause>
  deviceIdEqualTo(String deviceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'deviceId', value: [deviceId]),
      );
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterWhereClause>
  deviceIdNotEqualTo(String deviceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'deviceId',
                lower: [],
                upper: [deviceId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'deviceId',
                lower: [deviceId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'deviceId',
                lower: [deviceId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'deviceId',
                lower: [],
                upper: [deviceId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterWhereClause>
  schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'schoolId', value: [schoolId]),
      );
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterWhereClause>
  schoolIdNotEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [],
                upper: [schoolId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [schoolId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [schoolId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'schoolId',
                lower: [],
                upper: [schoolId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension AuthorizedDeviceIsarQueryFilter
    on
        QueryBuilder<
          AuthorizedDeviceIsar,
          AuthorizedDeviceIsar,
          QFilterCondition
        > {
  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  deviceIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deviceId',
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
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  deviceIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  deviceIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'deviceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'deviceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deviceId', value: ''),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'deviceId', value: ''),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  gateIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'gateId'),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  gateIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'gateId'),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  gateIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'gateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  gateIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'gateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  gateIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'gateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  gateIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'gateId',
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
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  gateIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'gateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  gateIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'gateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  gateIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'gateId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  gateIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'gateId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  gateIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'gateId', value: ''),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  gateIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'gateId', value: ''),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
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
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
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
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
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
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
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
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isActive', value: value),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  labelEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'label',
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
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  labelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  labelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'label',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'label',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'label', value: ''),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  registeredAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'registeredAt', value: value),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  registeredAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'registeredAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  registeredAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'registeredAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  registeredAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'registeredAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<
    AuthorizedDeviceIsar,
    AuthorizedDeviceIsar,
    QAfterFilterCondition
  >
  schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'schoolId', value: ''),
      );
    });
  }
}

extension AuthorizedDeviceIsarQueryObject
    on
        QueryBuilder<
          AuthorizedDeviceIsar,
          AuthorizedDeviceIsar,
          QFilterCondition
        > {}

extension AuthorizedDeviceIsarQueryLinks
    on
        QueryBuilder<
          AuthorizedDeviceIsar,
          AuthorizedDeviceIsar,
          QFilterCondition
        > {}

extension AuthorizedDeviceIsarQuerySortBy
    on QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QSortBy> {
  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  sortByGateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.asc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  sortByGateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.desc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  sortByRegisteredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registeredAt', Sort.asc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  sortByRegisteredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registeredAt', Sort.desc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }
}

extension AuthorizedDeviceIsarQuerySortThenBy
    on QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QSortThenBy> {
  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  thenByGateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.asc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  thenByGateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.desc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  thenByRegisteredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registeredAt', Sort.asc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  thenByRegisteredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registeredAt', Sort.desc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QAfterSortBy>
  thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }
}

extension AuthorizedDeviceIsarQueryWhereDistinct
    on QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QDistinct> {
  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QDistinct>
  distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QDistinct>
  distinctByGateId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gateId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QDistinct>
  distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QDistinct>
  distinctByLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QDistinct>
  distinctByRegisteredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'registeredAt');
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, AuthorizedDeviceIsar, QDistinct>
  distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }
}

extension AuthorizedDeviceIsarQueryProperty
    on
        QueryBuilder<
          AuthorizedDeviceIsar,
          AuthorizedDeviceIsar,
          QQueryProperty
        > {
  QueryBuilder<AuthorizedDeviceIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, String, QQueryOperations>
  deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, String?, QQueryOperations>
  gateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gateId');
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, bool, QQueryOperations>
  isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, String, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, DateTime, QQueryOperations>
  registeredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'registeredAt');
    });
  }

  QueryBuilder<AuthorizedDeviceIsar, String, QQueryOperations>
  schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOperatorPermissionSnapshotIsarCollection on Isar {
  IsarCollection<OperatorPermissionSnapshotIsar>
  get operatorPermissionSnapshotIsars => this.collection();
}

const OperatorPermissionSnapshotIsarSchema = CollectionSchema(
  name: r'OperatorPermissionSnapshotIsar',
  id: -5469687383880972295,
  properties: {
    r'expiresAt': PropertySchema(
      id: 0,
      name: r'expiresAt',
      type: IsarType.dateTime,
    ),
    r'operatorId': PropertySchema(
      id: 1,
      name: r'operatorId',
      type: IsarType.string,
    ),
    r'permissionIds': PropertySchema(
      id: 2,
      name: r'permissionIds',
      type: IsarType.stringList,
    ),
    r'schoolId': PropertySchema(
      id: 3,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'version': PropertySchema(id: 4, name: r'version', type: IsarType.long),
  },
  estimateSize: _operatorPermissionSnapshotIsarEstimateSize,
  serialize: _operatorPermissionSnapshotIsarSerialize,
  deserialize: _operatorPermissionSnapshotIsarDeserialize,
  deserializeProp: _operatorPermissionSnapshotIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'operatorId': IndexSchema(
      id: 189059888765928123,
      name: r'operatorId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'operatorId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _operatorPermissionSnapshotIsarGetId,
  getLinks: _operatorPermissionSnapshotIsarGetLinks,
  attach: _operatorPermissionSnapshotIsarAttach,
  version: '3.1.0+1',
);

int _operatorPermissionSnapshotIsarEstimateSize(
  OperatorPermissionSnapshotIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.operatorId.length * 3;
  bytesCount += 3 + object.permissionIds.length * 3;
  {
    for (var i = 0; i < object.permissionIds.length; i++) {
      final value = object.permissionIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolId.length * 3;
  return bytesCount;
}

void _operatorPermissionSnapshotIsarSerialize(
  OperatorPermissionSnapshotIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.expiresAt);
  writer.writeString(offsets[1], object.operatorId);
  writer.writeStringList(offsets[2], object.permissionIds);
  writer.writeString(offsets[3], object.schoolId);
  writer.writeLong(offsets[4], object.version);
}

OperatorPermissionSnapshotIsar _operatorPermissionSnapshotIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OperatorPermissionSnapshotIsar();
  object.expiresAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.operatorId = reader.readString(offsets[1]);
  object.permissionIds = reader.readStringList(offsets[2]) ?? [];
  object.schoolId = reader.readString(offsets[3]);
  object.version = reader.readLong(offsets[4]);
  return object;
}

P _operatorPermissionSnapshotIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _operatorPermissionSnapshotIsarGetId(OperatorPermissionSnapshotIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _operatorPermissionSnapshotIsarGetLinks(
  OperatorPermissionSnapshotIsar object,
) {
  return [];
}

void _operatorPermissionSnapshotIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  OperatorPermissionSnapshotIsar object,
) {
  object.id = id;
}

extension OperatorPermissionSnapshotIsarByIndex
    on IsarCollection<OperatorPermissionSnapshotIsar> {
  Future<OperatorPermissionSnapshotIsar?> getByOperatorId(String operatorId) {
    return getByIndex(r'operatorId', [operatorId]);
  }

  OperatorPermissionSnapshotIsar? getByOperatorIdSync(String operatorId) {
    return getByIndexSync(r'operatorId', [operatorId]);
  }

  Future<bool> deleteByOperatorId(String operatorId) {
    return deleteByIndex(r'operatorId', [operatorId]);
  }

  bool deleteByOperatorIdSync(String operatorId) {
    return deleteByIndexSync(r'operatorId', [operatorId]);
  }

  Future<List<OperatorPermissionSnapshotIsar?>> getAllByOperatorId(
    List<String> operatorIdValues,
  ) {
    final values = operatorIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'operatorId', values);
  }

  List<OperatorPermissionSnapshotIsar?> getAllByOperatorIdSync(
    List<String> operatorIdValues,
  ) {
    final values = operatorIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'operatorId', values);
  }

  Future<int> deleteAllByOperatorId(List<String> operatorIdValues) {
    final values = operatorIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'operatorId', values);
  }

  int deleteAllByOperatorIdSync(List<String> operatorIdValues) {
    final values = operatorIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'operatorId', values);
  }

  Future<Id> putByOperatorId(OperatorPermissionSnapshotIsar object) {
    return putByIndex(r'operatorId', object);
  }

  Id putByOperatorIdSync(
    OperatorPermissionSnapshotIsar object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'operatorId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOperatorId(
    List<OperatorPermissionSnapshotIsar> objects,
  ) {
    return putAllByIndex(r'operatorId', objects);
  }

  List<Id> putAllByOperatorIdSync(
    List<OperatorPermissionSnapshotIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'operatorId', objects, saveLinks: saveLinks);
  }
}

extension OperatorPermissionSnapshotIsarQueryWhereSort
    on
        QueryBuilder<
          OperatorPermissionSnapshotIsar,
          OperatorPermissionSnapshotIsar,
          QWhere
        > {
  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterWhere
  >
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OperatorPermissionSnapshotIsarQueryWhere
    on
        QueryBuilder<
          OperatorPermissionSnapshotIsar,
          OperatorPermissionSnapshotIsar,
          QWhereClause
        > {
  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterWhereClause
  >
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

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterWhereClause
  >
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

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterWhereClause
  >
  operatorIdEqualTo(String operatorId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'operatorId', value: [operatorId]),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterWhereClause
  >
  operatorIdNotEqualTo(String operatorId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'operatorId',
                lower: [],
                upper: [operatorId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'operatorId',
                lower: [operatorId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'operatorId',
                lower: [operatorId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'operatorId',
                lower: [],
                upper: [operatorId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension OperatorPermissionSnapshotIsarQueryFilter
    on
        QueryBuilder<
          OperatorPermissionSnapshotIsar,
          OperatorPermissionSnapshotIsar,
          QFilterCondition
        > {
  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  expiresAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expiresAt', value: value),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  expiresAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  expiresAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  expiresAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expiresAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
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
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
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
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
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
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
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
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  operatorIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'operatorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  operatorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'operatorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  operatorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'operatorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  operatorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'operatorId',
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
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  operatorIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'operatorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  operatorIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'operatorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  operatorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'operatorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  operatorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'operatorId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  operatorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'operatorId', value: ''),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  operatorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'operatorId', value: ''),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'permissionIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'permissionIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'permissionIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'permissionIds',
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
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'permissionIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'permissionIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'permissionIds',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'permissionIds',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'permissionIds', value: ''),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'permissionIds', value: ''),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'permissionIds', length, true, length, true);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'permissionIds', 0, true, 0, true);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'permissionIds', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'permissionIds', 0, true, length, include);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'permissionIds', length, include, 999999, true);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  permissionIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'permissionIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'version', value: value),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  versionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'version',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  versionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'version',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterFilterCondition
  >
  versionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'version',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension OperatorPermissionSnapshotIsarQueryObject
    on
        QueryBuilder<
          OperatorPermissionSnapshotIsar,
          OperatorPermissionSnapshotIsar,
          QFilterCondition
        > {}

extension OperatorPermissionSnapshotIsarQueryLinks
    on
        QueryBuilder<
          OperatorPermissionSnapshotIsar,
          OperatorPermissionSnapshotIsar,
          QFilterCondition
        > {}

extension OperatorPermissionSnapshotIsarQuerySortBy
    on
        QueryBuilder<
          OperatorPermissionSnapshotIsar,
          OperatorPermissionSnapshotIsar,
          QSortBy
        > {
  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  sortByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  sortByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  sortByOperatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.asc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  sortByOperatorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.desc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension OperatorPermissionSnapshotIsarQuerySortThenBy
    on
        QueryBuilder<
          OperatorPermissionSnapshotIsar,
          OperatorPermissionSnapshotIsar,
          QSortThenBy
        > {
  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  thenByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  thenByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  thenByOperatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.asc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  thenByOperatorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.desc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QAfterSortBy
  >
  thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension OperatorPermissionSnapshotIsarQueryWhereDistinct
    on
        QueryBuilder<
          OperatorPermissionSnapshotIsar,
          OperatorPermissionSnapshotIsar,
          QDistinct
        > {
  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QDistinct
  >
  distinctByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresAt');
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QDistinct
  >
  distinctByOperatorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operatorId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QDistinct
  >
  distinctByPermissionIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permissionIds');
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QDistinct
  >
  distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    OperatorPermissionSnapshotIsar,
    OperatorPermissionSnapshotIsar,
    QDistinct
  >
  distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }
}

extension OperatorPermissionSnapshotIsarQueryProperty
    on
        QueryBuilder<
          OperatorPermissionSnapshotIsar,
          OperatorPermissionSnapshotIsar,
          QQueryProperty
        > {
  QueryBuilder<OperatorPermissionSnapshotIsar, int, QQueryOperations>
  idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OperatorPermissionSnapshotIsar, DateTime, QQueryOperations>
  expiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresAt');
    });
  }

  QueryBuilder<OperatorPermissionSnapshotIsar, String, QQueryOperations>
  operatorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operatorId');
    });
  }

  QueryBuilder<OperatorPermissionSnapshotIsar, List<String>, QQueryOperations>
  permissionIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permissionIds');
    });
  }

  QueryBuilder<OperatorPermissionSnapshotIsar, String, QQueryOperations>
  schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<OperatorPermissionSnapshotIsar, int, QQueryOperations>
  versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
