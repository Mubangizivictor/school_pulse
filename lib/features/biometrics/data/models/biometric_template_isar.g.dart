// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biometric_template_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBiometricTemplateIsarCollection on Isar {
  IsarCollection<BiometricTemplateIsar> get biometricTemplateIsars =>
      this.collection();
}

const BiometricTemplateIsarSchema = CollectionSchema(
  name: r'BiometricTemplateIsar',
  id: -5256661131026024289,
  properties: {
    r'encryptedTemplate': PropertySchema(
      id: 0,
      name: r'encryptedTemplate',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 1,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'personId': PropertySchema(
      id: 2,
      name: r'personId',
      type: IsarType.string,
    ),
    r'personType': PropertySchema(
      id: 3,
      name: r'personType',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 4,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _biometricTemplateIsarEstimateSize,
  serialize: _biometricTemplateIsarSerialize,
  deserialize: _biometricTemplateIsarDeserialize,
  deserializeProp: _biometricTemplateIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'personId': IndexSchema(
      id: 750717629518044662,
      name: r'personId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'personId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _biometricTemplateIsarGetId,
  getLinks: _biometricTemplateIsarGetLinks,
  attach: _biometricTemplateIsarAttach,
  version: '3.1.0+1',
);

int _biometricTemplateIsarEstimateSize(
  BiometricTemplateIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.encryptedTemplate.length * 3;
  bytesCount += 3 + object.personId.length * 3;
  bytesCount += 3 + object.personType.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  return bytesCount;
}

void _biometricTemplateIsarSerialize(
  BiometricTemplateIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.encryptedTemplate);
  writer.writeBool(offsets[1], object.isSynced);
  writer.writeString(offsets[2], object.personId);
  writer.writeString(offsets[3], object.personType);
  writer.writeString(offsets[4], object.schoolId);
  writer.writeDateTime(offsets[5], object.updatedAt);
}

BiometricTemplateIsar _biometricTemplateIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BiometricTemplateIsar();
  object.encryptedTemplate = reader.readString(offsets[0]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[1]);
  object.personId = reader.readString(offsets[2]);
  object.personType = reader.readString(offsets[3]);
  object.schoolId = reader.readString(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  return object;
}

P _biometricTemplateIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _biometricTemplateIsarGetId(BiometricTemplateIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _biometricTemplateIsarGetLinks(
    BiometricTemplateIsar object) {
  return [];
}

void _biometricTemplateIsarAttach(
    IsarCollection<dynamic> col, Id id, BiometricTemplateIsar object) {
  object.id = id;
}

extension BiometricTemplateIsarByIndex
    on IsarCollection<BiometricTemplateIsar> {
  Future<BiometricTemplateIsar?> getByPersonId(String personId) {
    return getByIndex(r'personId', [personId]);
  }

  BiometricTemplateIsar? getByPersonIdSync(String personId) {
    return getByIndexSync(r'personId', [personId]);
  }

  Future<bool> deleteByPersonId(String personId) {
    return deleteByIndex(r'personId', [personId]);
  }

  bool deleteByPersonIdSync(String personId) {
    return deleteByIndexSync(r'personId', [personId]);
  }

  Future<List<BiometricTemplateIsar?>> getAllByPersonId(
      List<String> personIdValues) {
    final values = personIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'personId', values);
  }

  List<BiometricTemplateIsar?> getAllByPersonIdSync(
      List<String> personIdValues) {
    final values = personIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'personId', values);
  }

  Future<int> deleteAllByPersonId(List<String> personIdValues) {
    final values = personIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'personId', values);
  }

  int deleteAllByPersonIdSync(List<String> personIdValues) {
    final values = personIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'personId', values);
  }

  Future<Id> putByPersonId(BiometricTemplateIsar object) {
    return putByIndex(r'personId', object);
  }

  Id putByPersonIdSync(BiometricTemplateIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'personId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPersonId(List<BiometricTemplateIsar> objects) {
    return putAllByIndex(r'personId', objects);
  }

  List<Id> putAllByPersonIdSync(List<BiometricTemplateIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'personId', objects, saveLinks: saveLinks);
  }
}

extension BiometricTemplateIsarQueryWhereSort
    on QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QWhere> {
  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BiometricTemplateIsarQueryWhere on QueryBuilder<BiometricTemplateIsar,
    BiometricTemplateIsar, QWhereClause> {
  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterWhereClause>
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

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterWhereClause>
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

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterWhereClause>
      personIdEqualTo(String personId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'personId',
        value: [personId],
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterWhereClause>
      personIdNotEqualTo(String personId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'personId',
              lower: [],
              upper: [personId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'personId',
              lower: [personId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'personId',
              lower: [personId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'personId',
              lower: [],
              upper: [personId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension BiometricTemplateIsarQueryFilter on QueryBuilder<
    BiometricTemplateIsar, BiometricTemplateIsar, QFilterCondition> {
  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> encryptedTemplateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptedTemplate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> encryptedTemplateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'encryptedTemplate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> encryptedTemplateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'encryptedTemplate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> encryptedTemplateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'encryptedTemplate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> encryptedTemplateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'encryptedTemplate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> encryptedTemplateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'encryptedTemplate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
          QAfterFilterCondition>
      encryptedTemplateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'encryptedTemplate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
          QAfterFilterCondition>
      encryptedTemplateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'encryptedTemplate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> encryptedTemplateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptedTemplate',
        value: '',
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> encryptedTemplateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'encryptedTemplate',
        value: '',
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
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

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
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

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
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

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'personId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'personId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'personId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'personId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'personId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
          QAfterFilterCondition>
      personIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'personId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
          QAfterFilterCondition>
      personIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'personId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personId',
        value: '',
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'personId',
        value: '',
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'personType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'personType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'personType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'personType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'personType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
          QAfterFilterCondition>
      personTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'personType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
          QAfterFilterCondition>
      personTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'personType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personType',
        value: '',
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> personTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'personType',
        value: '',
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
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

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
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

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
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

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
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

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
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

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
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

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
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

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
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

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar,
      QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BiometricTemplateIsarQueryObject on QueryBuilder<
    BiometricTemplateIsar, BiometricTemplateIsar, QFilterCondition> {}

extension BiometricTemplateIsarQueryLinks on QueryBuilder<BiometricTemplateIsar,
    BiometricTemplateIsar, QFilterCondition> {}

extension BiometricTemplateIsarQuerySortBy
    on QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QSortBy> {
  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      sortByEncryptedTemplate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedTemplate', Sort.asc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      sortByEncryptedTemplateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedTemplate', Sort.desc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      sortByPersonId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personId', Sort.asc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      sortByPersonIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personId', Sort.desc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      sortByPersonType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personType', Sort.asc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      sortByPersonTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personType', Sort.desc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension BiometricTemplateIsarQuerySortThenBy
    on QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QSortThenBy> {
  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      thenByEncryptedTemplate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedTemplate', Sort.asc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      thenByEncryptedTemplateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedTemplate', Sort.desc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      thenByPersonId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personId', Sort.asc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      thenByPersonIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personId', Sort.desc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      thenByPersonType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personType', Sort.asc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      thenByPersonTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personType', Sort.desc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension BiometricTemplateIsarQueryWhereDistinct
    on QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QDistinct> {
  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QDistinct>
      distinctByEncryptedTemplate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'encryptedTemplate',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QDistinct>
      distinctByPersonId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QDistinct>
      distinctByPersonType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BiometricTemplateIsar, BiometricTemplateIsar, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension BiometricTemplateIsarQueryProperty on QueryBuilder<
    BiometricTemplateIsar, BiometricTemplateIsar, QQueryProperty> {
  QueryBuilder<BiometricTemplateIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BiometricTemplateIsar, String, QQueryOperations>
      encryptedTemplateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encryptedTemplate');
    });
  }

  QueryBuilder<BiometricTemplateIsar, bool, QQueryOperations>
      isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<BiometricTemplateIsar, String, QQueryOperations>
      personIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personId');
    });
  }

  QueryBuilder<BiometricTemplateIsar, String, QQueryOperations>
      personTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personType');
    });
  }

  QueryBuilder<BiometricTemplateIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<BiometricTemplateIsar, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
