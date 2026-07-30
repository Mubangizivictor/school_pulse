// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pre_approved_visitor_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPreApprovedVisitorIsarCollection on Isar {
  IsarCollection<PreApprovedVisitorIsar> get preApprovedVisitorIsars =>
      this.collection();
}

const PreApprovedVisitorIsarSchema = CollectionSchema(
  name: r'PreApprovedVisitorIsar',
  id: -2384556426751319347,
  properties: {
    r'expectedDate': PropertySchema(
      id: 0,
      name: r'expectedDate',
      type: IsarType.dateTime,
    ),
    r'fullName': PropertySchema(
      id: 1,
      name: r'fullName',
      type: IsarType.string,
    ),
    r'host': PropertySchema(
      id: 2,
      name: r'host',
      type: IsarType.string,
    ),
    r'isUsed': PropertySchema(
      id: 3,
      name: r'isUsed',
      type: IsarType.bool,
    ),
    r'phone': PropertySchema(
      id: 4,
      name: r'phone',
      type: IsarType.string,
    ),
    r'preApprovedId': PropertySchema(
      id: 5,
      name: r'preApprovedId',
      type: IsarType.string,
    ),
    r'purpose': PropertySchema(
      id: 6,
      name: r'purpose',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 7,
      name: r'schoolId',
      type: IsarType.string,
    )
  },
  estimateSize: _preApprovedVisitorIsarEstimateSize,
  serialize: _preApprovedVisitorIsarSerialize,
  deserialize: _preApprovedVisitorIsarDeserialize,
  deserializeProp: _preApprovedVisitorIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'preApprovedId': IndexSchema(
      id: 2536605780918544216,
      name: r'preApprovedId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'preApprovedId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _preApprovedVisitorIsarGetId,
  getLinks: _preApprovedVisitorIsarGetLinks,
  attach: _preApprovedVisitorIsarAttach,
  version: '3.1.0+1',
);

int _preApprovedVisitorIsarEstimateSize(
  PreApprovedVisitorIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fullName.length * 3;
  bytesCount += 3 + object.host.length * 3;
  bytesCount += 3 + object.phone.length * 3;
  bytesCount += 3 + object.preApprovedId.length * 3;
  bytesCount += 3 + object.purpose.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  return bytesCount;
}

void _preApprovedVisitorIsarSerialize(
  PreApprovedVisitorIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.expectedDate);
  writer.writeString(offsets[1], object.fullName);
  writer.writeString(offsets[2], object.host);
  writer.writeBool(offsets[3], object.isUsed);
  writer.writeString(offsets[4], object.phone);
  writer.writeString(offsets[5], object.preApprovedId);
  writer.writeString(offsets[6], object.purpose);
  writer.writeString(offsets[7], object.schoolId);
}

PreApprovedVisitorIsar _preApprovedVisitorIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PreApprovedVisitorIsar();
  object.expectedDate = reader.readDateTime(offsets[0]);
  object.fullName = reader.readString(offsets[1]);
  object.host = reader.readString(offsets[2]);
  object.id = id;
  object.isUsed = reader.readBool(offsets[3]);
  object.phone = reader.readString(offsets[4]);
  object.preApprovedId = reader.readString(offsets[5]);
  object.purpose = reader.readString(offsets[6]);
  object.schoolId = reader.readString(offsets[7]);
  return object;
}

P _preApprovedVisitorIsarDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
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

Id _preApprovedVisitorIsarGetId(PreApprovedVisitorIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _preApprovedVisitorIsarGetLinks(
    PreApprovedVisitorIsar object) {
  return [];
}

void _preApprovedVisitorIsarAttach(
    IsarCollection<dynamic> col, Id id, PreApprovedVisitorIsar object) {
  object.id = id;
}

extension PreApprovedVisitorIsarByIndex
    on IsarCollection<PreApprovedVisitorIsar> {
  Future<PreApprovedVisitorIsar?> getByPreApprovedId(String preApprovedId) {
    return getByIndex(r'preApprovedId', [preApprovedId]);
  }

  PreApprovedVisitorIsar? getByPreApprovedIdSync(String preApprovedId) {
    return getByIndexSync(r'preApprovedId', [preApprovedId]);
  }

  Future<bool> deleteByPreApprovedId(String preApprovedId) {
    return deleteByIndex(r'preApprovedId', [preApprovedId]);
  }

  bool deleteByPreApprovedIdSync(String preApprovedId) {
    return deleteByIndexSync(r'preApprovedId', [preApprovedId]);
  }

  Future<List<PreApprovedVisitorIsar?>> getAllByPreApprovedId(
      List<String> preApprovedIdValues) {
    final values = preApprovedIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'preApprovedId', values);
  }

  List<PreApprovedVisitorIsar?> getAllByPreApprovedIdSync(
      List<String> preApprovedIdValues) {
    final values = preApprovedIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'preApprovedId', values);
  }

  Future<int> deleteAllByPreApprovedId(List<String> preApprovedIdValues) {
    final values = preApprovedIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'preApprovedId', values);
  }

  int deleteAllByPreApprovedIdSync(List<String> preApprovedIdValues) {
    final values = preApprovedIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'preApprovedId', values);
  }

  Future<Id> putByPreApprovedId(PreApprovedVisitorIsar object) {
    return putByIndex(r'preApprovedId', object);
  }

  Id putByPreApprovedIdSync(PreApprovedVisitorIsar object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'preApprovedId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPreApprovedId(List<PreApprovedVisitorIsar> objects) {
    return putAllByIndex(r'preApprovedId', objects);
  }

  List<Id> putAllByPreApprovedIdSync(List<PreApprovedVisitorIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'preApprovedId', objects, saveLinks: saveLinks);
  }
}

extension PreApprovedVisitorIsarQueryWhereSort
    on QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QWhere> {
  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PreApprovedVisitorIsarQueryWhere on QueryBuilder<
    PreApprovedVisitorIsar, PreApprovedVisitorIsar, QWhereClause> {
  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterWhereClause> preApprovedIdEqualTo(String preApprovedId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'preApprovedId',
        value: [preApprovedId],
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterWhereClause> preApprovedIdNotEqualTo(String preApprovedId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'preApprovedId',
              lower: [],
              upper: [preApprovedId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'preApprovedId',
              lower: [preApprovedId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'preApprovedId',
              lower: [preApprovedId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'preApprovedId',
              lower: [],
              upper: [preApprovedId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PreApprovedVisitorIsarQueryFilter on QueryBuilder<
    PreApprovedVisitorIsar, PreApprovedVisitorIsar, QFilterCondition> {
  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> expectedDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> expectedDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> expectedDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> expectedDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> hostEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> hostGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> hostLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> hostBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'host',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> hostStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> hostEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
          QAfterFilterCondition>
      hostContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
          QAfterFilterCondition>
      hostMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'host',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> hostIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'host',
        value: '',
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> hostIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'host',
        value: '',
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> isUsedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isUsed',
        value: value,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> phoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> phoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> preApprovedIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preApprovedId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> preApprovedIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preApprovedId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> preApprovedIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preApprovedId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> preApprovedIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preApprovedId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> preApprovedIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'preApprovedId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> preApprovedIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'preApprovedId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
          QAfterFilterCondition>
      preApprovedIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'preApprovedId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
          QAfterFilterCondition>
      preApprovedIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'preApprovedId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> preApprovedIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preApprovedId',
        value: '',
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> preApprovedIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'preApprovedId',
        value: '',
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> purposeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> purposeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> purposeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> purposeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purpose',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> purposeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> purposeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
          QAfterFilterCondition>
      purposeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
          QAfterFilterCondition>
      purposeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'purpose',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> purposeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purpose',
        value: '',
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> purposeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'purpose',
        value: '',
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
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

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar,
      QAfterFilterCondition> schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }
}

extension PreApprovedVisitorIsarQueryObject on QueryBuilder<
    PreApprovedVisitorIsar, PreApprovedVisitorIsar, QFilterCondition> {}

extension PreApprovedVisitorIsarQueryLinks on QueryBuilder<
    PreApprovedVisitorIsar, PreApprovedVisitorIsar, QFilterCondition> {}

extension PreApprovedVisitorIsarQuerySortBy
    on QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QSortBy> {
  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortByExpectedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDate', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortByExpectedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDate', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortByHost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortByHostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortByIsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUsed', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortByIsUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUsed', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortByPreApprovedId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preApprovedId', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortByPreApprovedIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preApprovedId', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortByPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortByPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }
}

extension PreApprovedVisitorIsarQuerySortThenBy on QueryBuilder<
    PreApprovedVisitorIsar, PreApprovedVisitorIsar, QSortThenBy> {
  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByExpectedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDate', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByExpectedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDate', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByHost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByHostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByIsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUsed', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByIsUsedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isUsed', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByPreApprovedId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preApprovedId', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByPreApprovedIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preApprovedId', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenByPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.desc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }
}

extension PreApprovedVisitorIsarQueryWhereDistinct
    on QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QDistinct> {
  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QDistinct>
      distinctByExpectedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedDate');
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QDistinct>
      distinctByFullName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QDistinct>
      distinctByHost({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'host', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QDistinct>
      distinctByIsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isUsed');
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QDistinct>
      distinctByPhone({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QDistinct>
      distinctByPreApprovedId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preApprovedId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QDistinct>
      distinctByPurpose({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purpose', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, PreApprovedVisitorIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }
}

extension PreApprovedVisitorIsarQueryProperty on QueryBuilder<
    PreApprovedVisitorIsar, PreApprovedVisitorIsar, QQueryProperty> {
  QueryBuilder<PreApprovedVisitorIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, DateTime, QQueryOperations>
      expectedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedDate');
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, String, QQueryOperations>
      fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, String, QQueryOperations>
      hostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'host');
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, bool, QQueryOperations>
      isUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isUsed');
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, String, QQueryOperations>
      phoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phone');
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, String, QQueryOperations>
      preApprovedIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preApprovedId');
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, String, QQueryOperations>
      purposeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purpose');
    });
  }

  QueryBuilder<PreApprovedVisitorIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }
}
