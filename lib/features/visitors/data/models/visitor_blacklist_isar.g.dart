// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitor_blacklist_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVisitorBlacklistIsarCollection on Isar {
  IsarCollection<VisitorBlacklistIsar> get visitorBlacklistIsars =>
      this.collection();
}

const VisitorBlacklistIsarSchema = CollectionSchema(
  name: r'VisitorBlacklistIsar',
  id: -6717935053172690004,
  properties: {
    r'addedBy': PropertySchema(
      id: 0,
      name: r'addedBy',
      type: IsarType.string,
    ),
    r'blacklistId': PropertySchema(
      id: 1,
      name: r'blacklistId',
      type: IsarType.string,
    ),
    r'dateAdded': PropertySchema(
      id: 2,
      name: r'dateAdded',
      type: IsarType.dateTime,
    ),
    r'fullName': PropertySchema(
      id: 3,
      name: r'fullName',
      type: IsarType.string,
    ),
    r'phone': PropertySchema(
      id: 4,
      name: r'phone',
      type: IsarType.string,
    ),
    r'reason': PropertySchema(
      id: 5,
      name: r'reason',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 6,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'visitorId': PropertySchema(
      id: 7,
      name: r'visitorId',
      type: IsarType.string,
    )
  },
  estimateSize: _visitorBlacklistIsarEstimateSize,
  serialize: _visitorBlacklistIsarSerialize,
  deserialize: _visitorBlacklistIsarDeserialize,
  deserializeProp: _visitorBlacklistIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'blacklistId': IndexSchema(
      id: 2619339513525734294,
      name: r'blacklistId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'blacklistId',
          type: IndexType.hash,
          caseSensitive: true,
        )
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
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _visitorBlacklistIsarGetId,
  getLinks: _visitorBlacklistIsarGetLinks,
  attach: _visitorBlacklistIsarAttach,
  version: '3.1.0+1',
);

int _visitorBlacklistIsarEstimateSize(
  VisitorBlacklistIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.addedBy.length * 3;
  bytesCount += 3 + object.blacklistId.length * 3;
  bytesCount += 3 + object.fullName.length * 3;
  bytesCount += 3 + object.phone.length * 3;
  bytesCount += 3 + object.reason.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.visitorId.length * 3;
  return bytesCount;
}

void _visitorBlacklistIsarSerialize(
  VisitorBlacklistIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.addedBy);
  writer.writeString(offsets[1], object.blacklistId);
  writer.writeDateTime(offsets[2], object.dateAdded);
  writer.writeString(offsets[3], object.fullName);
  writer.writeString(offsets[4], object.phone);
  writer.writeString(offsets[5], object.reason);
  writer.writeString(offsets[6], object.schoolId);
  writer.writeString(offsets[7], object.visitorId);
}

VisitorBlacklistIsar _visitorBlacklistIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VisitorBlacklistIsar();
  object.addedBy = reader.readString(offsets[0]);
  object.blacklistId = reader.readString(offsets[1]);
  object.dateAdded = reader.readDateTime(offsets[2]);
  object.fullName = reader.readString(offsets[3]);
  object.id = id;
  object.phone = reader.readString(offsets[4]);
  object.reason = reader.readString(offsets[5]);
  object.schoolId = reader.readString(offsets[6]);
  object.visitorId = reader.readString(offsets[7]);
  return object;
}

P _visitorBlacklistIsarDeserializeProp<P>(
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
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _visitorBlacklistIsarGetId(VisitorBlacklistIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _visitorBlacklistIsarGetLinks(
    VisitorBlacklistIsar object) {
  return [];
}

void _visitorBlacklistIsarAttach(
    IsarCollection<dynamic> col, Id id, VisitorBlacklistIsar object) {
  object.id = id;
}

extension VisitorBlacklistIsarByIndex on IsarCollection<VisitorBlacklistIsar> {
  Future<VisitorBlacklistIsar?> getByBlacklistId(String blacklistId) {
    return getByIndex(r'blacklistId', [blacklistId]);
  }

  VisitorBlacklistIsar? getByBlacklistIdSync(String blacklistId) {
    return getByIndexSync(r'blacklistId', [blacklistId]);
  }

  Future<bool> deleteByBlacklistId(String blacklistId) {
    return deleteByIndex(r'blacklistId', [blacklistId]);
  }

  bool deleteByBlacklistIdSync(String blacklistId) {
    return deleteByIndexSync(r'blacklistId', [blacklistId]);
  }

  Future<List<VisitorBlacklistIsar?>> getAllByBlacklistId(
      List<String> blacklistIdValues) {
    final values = blacklistIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'blacklistId', values);
  }

  List<VisitorBlacklistIsar?> getAllByBlacklistIdSync(
      List<String> blacklistIdValues) {
    final values = blacklistIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'blacklistId', values);
  }

  Future<int> deleteAllByBlacklistId(List<String> blacklistIdValues) {
    final values = blacklistIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'blacklistId', values);
  }

  int deleteAllByBlacklistIdSync(List<String> blacklistIdValues) {
    final values = blacklistIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'blacklistId', values);
  }

  Future<Id> putByBlacklistId(VisitorBlacklistIsar object) {
    return putByIndex(r'blacklistId', object);
  }

  Id putByBlacklistIdSync(VisitorBlacklistIsar object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'blacklistId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByBlacklistId(List<VisitorBlacklistIsar> objects) {
    return putAllByIndex(r'blacklistId', objects);
  }

  List<Id> putAllByBlacklistIdSync(List<VisitorBlacklistIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'blacklistId', objects, saveLinks: saveLinks);
  }
}

extension VisitorBlacklistIsarQueryWhereSort
    on QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QWhere> {
  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VisitorBlacklistIsarQueryWhere
    on QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QWhereClause> {
  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterWhereClause>
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

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterWhereClause>
      blacklistIdEqualTo(String blacklistId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'blacklistId',
        value: [blacklistId],
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterWhereClause>
      blacklistIdNotEqualTo(String blacklistId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'blacklistId',
              lower: [],
              upper: [blacklistId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'blacklistId',
              lower: [blacklistId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'blacklistId',
              lower: [blacklistId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'blacklistId',
              lower: [],
              upper: [blacklistId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterWhereClause>
      schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterWhereClause>
      schoolIdNotEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schoolId',
              lower: [],
              upper: [schoolId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schoolId',
              lower: [schoolId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schoolId',
              lower: [schoolId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schoolId',
              lower: [],
              upper: [schoolId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension VisitorBlacklistIsarQueryFilter on QueryBuilder<VisitorBlacklistIsar,
    VisitorBlacklistIsar, QFilterCondition> {
  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> addedByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> addedByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> addedByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> addedByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> addedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'addedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> addedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'addedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
          QAfterFilterCondition>
      addedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'addedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
          QAfterFilterCondition>
      addedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'addedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> addedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> addedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'addedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> blacklistIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blacklistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> blacklistIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blacklistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> blacklistIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blacklistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> blacklistIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blacklistId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> blacklistIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'blacklistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> blacklistIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'blacklistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
          QAfterFilterCondition>
      blacklistIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'blacklistId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
          QAfterFilterCondition>
      blacklistIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'blacklistId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> blacklistIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blacklistId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> blacklistIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'blacklistId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> dateAddedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> dateAddedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> dateAddedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateAdded',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> dateAddedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateAdded',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> fullNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> fullNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> fullNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> fullNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fullName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> fullNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> fullNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
          QAfterFilterCondition>
      fullNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
          QAfterFilterCondition>
      fullNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fullName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> phoneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> phoneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> phoneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> phoneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> phoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> phoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
          QAfterFilterCondition>
      phoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
          QAfterFilterCondition>
      phoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> phoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> phoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> reasonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> reasonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> reasonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> reasonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> reasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
          QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
          QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> schoolIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> schoolIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> schoolIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> schoolIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schoolId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> schoolIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> schoolIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
          QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
          QAfterFilterCondition>
      schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> visitorIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> visitorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> visitorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> visitorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'visitorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> visitorIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> visitorIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
          QAfterFilterCondition>
      visitorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
          QAfterFilterCondition>
      visitorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visitorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> visitorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visitorId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar,
      QAfterFilterCondition> visitorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visitorId',
        value: '',
      ));
    });
  }
}

extension VisitorBlacklistIsarQueryObject on QueryBuilder<VisitorBlacklistIsar,
    VisitorBlacklistIsar, QFilterCondition> {}

extension VisitorBlacklistIsarQueryLinks on QueryBuilder<VisitorBlacklistIsar,
    VisitorBlacklistIsar, QFilterCondition> {}

extension VisitorBlacklistIsarQuerySortBy
    on QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QSortBy> {
  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortByAddedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedBy', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortByAddedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedBy', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortByBlacklistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blacklistId', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortByBlacklistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blacklistId', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortByDateAddedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortByVisitorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorId', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      sortByVisitorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorId', Sort.desc);
    });
  }
}

extension VisitorBlacklistIsarQuerySortThenBy
    on QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QSortThenBy> {
  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByAddedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedBy', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByAddedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedBy', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByBlacklistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blacklistId', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByBlacklistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blacklistId', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByDateAddedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateAdded', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByVisitorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorId', Sort.asc);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QAfterSortBy>
      thenByVisitorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorId', Sort.desc);
    });
  }
}

extension VisitorBlacklistIsarQueryWhereDistinct
    on QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QDistinct> {
  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QDistinct>
      distinctByAddedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QDistinct>
      distinctByBlacklistId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blacklistId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QDistinct>
      distinctByDateAdded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateAdded');
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QDistinct>
      distinctByFullName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QDistinct>
      distinctByPhone({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QDistinct>
      distinctByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorBlacklistIsar, VisitorBlacklistIsar, QDistinct>
      distinctByVisitorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visitorId', caseSensitive: caseSensitive);
    });
  }
}

extension VisitorBlacklistIsarQueryProperty on QueryBuilder<
    VisitorBlacklistIsar, VisitorBlacklistIsar, QQueryProperty> {
  QueryBuilder<VisitorBlacklistIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VisitorBlacklistIsar, String, QQueryOperations>
      addedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedBy');
    });
  }

  QueryBuilder<VisitorBlacklistIsar, String, QQueryOperations>
      blacklistIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blacklistId');
    });
  }

  QueryBuilder<VisitorBlacklistIsar, DateTime, QQueryOperations>
      dateAddedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateAdded');
    });
  }

  QueryBuilder<VisitorBlacklistIsar, String, QQueryOperations>
      fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }

  QueryBuilder<VisitorBlacklistIsar, String, QQueryOperations> phoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phone');
    });
  }

  QueryBuilder<VisitorBlacklistIsar, String, QQueryOperations>
      reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<VisitorBlacklistIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<VisitorBlacklistIsar, String, QQueryOperations>
      visitorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visitorId');
    });
  }
}
