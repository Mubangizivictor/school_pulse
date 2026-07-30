// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_isar_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGateIsarCollection on Isar {
  IsarCollection<GateIsar> get gateIsars => this.collection();
}

const GateIsarSchema = CollectionSchema(
  name: r'GateIsar',
  id: -3614276195813190784,
  properties: {
    r'allowedUserRoles': PropertySchema(
      id: 0,
      name: r'allowedUserRoles',
      type: IsarType.stringList,
    ),
    r'assignedOfficerIds': PropertySchema(
      id: 1,
      name: r'assignedOfficerIds',
      type: IsarType.stringList,
    ),
    r'gateId': PropertySchema(
      id: 2,
      name: r'gateId',
      type: IsarType.string,
    ),
    r'location': PropertySchema(
      id: 3,
      name: r'location',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'operatingHoursJson': PropertySchema(
      id: 5,
      name: r'operatingHoursJson',
      type: IsarType.string,
    ),
    r'requiredVerificationMethods': PropertySchema(
      id: 6,
      name: r'requiredVerificationMethods',
      type: IsarType.stringList,
    ),
    r'schoolId': PropertySchema(
      id: 7,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 8,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _gateIsarEstimateSize,
  serialize: _gateIsarSerialize,
  deserialize: _gateIsarDeserialize,
  deserializeProp: _gateIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'gateId': IndexSchema(
      id: 7381608507701441698,
      name: r'gateId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'gateId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _gateIsarGetId,
  getLinks: _gateIsarGetLinks,
  attach: _gateIsarAttach,
  version: '3.1.0+1',
);

int _gateIsarEstimateSize(
  GateIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.allowedUserRoles.length * 3;
  {
    for (var i = 0; i < object.allowedUserRoles.length; i++) {
      final value = object.allowedUserRoles[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.assignedOfficerIds.length * 3;
  {
    for (var i = 0; i < object.assignedOfficerIds.length; i++) {
      final value = object.assignedOfficerIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.gateId.length * 3;
  bytesCount += 3 + object.location.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.operatingHoursJson.length * 3;
  bytesCount += 3 + object.requiredVerificationMethods.length * 3;
  {
    for (var i = 0; i < object.requiredVerificationMethods.length; i++) {
      final value = object.requiredVerificationMethods[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _gateIsarSerialize(
  GateIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.allowedUserRoles);
  writer.writeStringList(offsets[1], object.assignedOfficerIds);
  writer.writeString(offsets[2], object.gateId);
  writer.writeString(offsets[3], object.location);
  writer.writeString(offsets[4], object.name);
  writer.writeString(offsets[5], object.operatingHoursJson);
  writer.writeStringList(offsets[6], object.requiredVerificationMethods);
  writer.writeString(offsets[7], object.schoolId);
  writer.writeString(offsets[8], object.type);
}

GateIsar _gateIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GateIsar();
  object.allowedUserRoles = reader.readStringList(offsets[0]) ?? [];
  object.assignedOfficerIds = reader.readStringList(offsets[1]) ?? [];
  object.gateId = reader.readString(offsets[2]);
  object.id = id;
  object.location = reader.readString(offsets[3]);
  object.name = reader.readString(offsets[4]);
  object.operatingHoursJson = reader.readString(offsets[5]);
  object.requiredVerificationMethods = reader.readStringList(offsets[6]) ?? [];
  object.schoolId = reader.readString(offsets[7]);
  object.type = reader.readString(offsets[8]);
  return object;
}

P _gateIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _gateIsarGetId(GateIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _gateIsarGetLinks(GateIsar object) {
  return [];
}

void _gateIsarAttach(IsarCollection<dynamic> col, Id id, GateIsar object) {
  object.id = id;
}

extension GateIsarByIndex on IsarCollection<GateIsar> {
  Future<GateIsar?> getByGateId(String gateId) {
    return getByIndex(r'gateId', [gateId]);
  }

  GateIsar? getByGateIdSync(String gateId) {
    return getByIndexSync(r'gateId', [gateId]);
  }

  Future<bool> deleteByGateId(String gateId) {
    return deleteByIndex(r'gateId', [gateId]);
  }

  bool deleteByGateIdSync(String gateId) {
    return deleteByIndexSync(r'gateId', [gateId]);
  }

  Future<List<GateIsar?>> getAllByGateId(List<String> gateIdValues) {
    final values = gateIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'gateId', values);
  }

  List<GateIsar?> getAllByGateIdSync(List<String> gateIdValues) {
    final values = gateIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'gateId', values);
  }

  Future<int> deleteAllByGateId(List<String> gateIdValues) {
    final values = gateIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'gateId', values);
  }

  int deleteAllByGateIdSync(List<String> gateIdValues) {
    final values = gateIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'gateId', values);
  }

  Future<Id> putByGateId(GateIsar object) {
    return putByIndex(r'gateId', object);
  }

  Id putByGateIdSync(GateIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'gateId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByGateId(List<GateIsar> objects) {
    return putAllByIndex(r'gateId', objects);
  }

  List<Id> putAllByGateIdSync(List<GateIsar> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'gateId', objects, saveLinks: saveLinks);
  }
}

extension GateIsarQueryWhereSort on QueryBuilder<GateIsar, GateIsar, QWhere> {
  QueryBuilder<GateIsar, GateIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GateIsarQueryWhere on QueryBuilder<GateIsar, GateIsar, QWhereClause> {
  QueryBuilder<GateIsar, GateIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<GateIsar, GateIsar, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<GateIsar, GateIsar, QAfterWhereClause> gateIdEqualTo(
      String gateId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'gateId',
        value: [gateId],
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterWhereClause> gateIdNotEqualTo(
      String gateId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gateId',
              lower: [],
              upper: [gateId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gateId',
              lower: [gateId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gateId',
              lower: [gateId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'gateId',
              lower: [],
              upper: [gateId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension GateIsarQueryFilter
    on QueryBuilder<GateIsar, GateIsar, QFilterCondition> {
  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allowedUserRoles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'allowedUserRoles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'allowedUserRoles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'allowedUserRoles',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'allowedUserRoles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'allowedUserRoles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'allowedUserRoles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'allowedUserRoles',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allowedUserRoles',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'allowedUserRoles',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedUserRoles',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedUserRoles',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedUserRoles',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedUserRoles',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedUserRoles',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      allowedUserRolesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allowedUserRoles',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedOfficerIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedOfficerIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedOfficerIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedOfficerIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedOfficerIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedOfficerIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedOfficerIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedOfficerIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedOfficerIds',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedOfficerIds',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assignedOfficerIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assignedOfficerIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assignedOfficerIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assignedOfficerIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assignedOfficerIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      assignedOfficerIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'assignedOfficerIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> gateIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> gateIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> gateIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> gateIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gateId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> gateIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> gateIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> gateIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> gateIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gateId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> gateIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gateId',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> gateIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gateId',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> locationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> locationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> locationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> locationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'location',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> locationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> locationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> locationContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> locationMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'location',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> locationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> locationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      operatingHoursJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operatingHoursJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      operatingHoursJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operatingHoursJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      operatingHoursJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operatingHoursJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      operatingHoursJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operatingHoursJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      operatingHoursJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operatingHoursJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      operatingHoursJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operatingHoursJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      operatingHoursJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operatingHoursJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      operatingHoursJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operatingHoursJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      operatingHoursJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operatingHoursJson',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      operatingHoursJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operatingHoursJson',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requiredVerificationMethods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requiredVerificationMethods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requiredVerificationMethods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requiredVerificationMethods',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requiredVerificationMethods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requiredVerificationMethods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requiredVerificationMethods',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requiredVerificationMethods',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requiredVerificationMethods',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requiredVerificationMethods',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'requiredVerificationMethods',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'requiredVerificationMethods',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'requiredVerificationMethods',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'requiredVerificationMethods',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'requiredVerificationMethods',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition>
      requiredVerificationMethodsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'requiredVerificationMethods',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> schoolIdEqualTo(
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

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> schoolIdGreaterThan(
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

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> schoolIdLessThan(
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

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> schoolIdBetween(
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

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> schoolIdStartsWith(
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

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> schoolIdEndsWith(
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

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> schoolIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> schoolIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> typeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension GateIsarQueryObject
    on QueryBuilder<GateIsar, GateIsar, QFilterCondition> {}

extension GateIsarQueryLinks
    on QueryBuilder<GateIsar, GateIsar, QFilterCondition> {}

extension GateIsarQuerySortBy on QueryBuilder<GateIsar, GateIsar, QSortBy> {
  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> sortByGateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.asc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> sortByGateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.desc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> sortByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> sortByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> sortByOperatingHoursJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatingHoursJson', Sort.asc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy>
      sortByOperatingHoursJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatingHoursJson', Sort.desc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension GateIsarQuerySortThenBy
    on QueryBuilder<GateIsar, GateIsar, QSortThenBy> {
  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> thenByGateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.asc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> thenByGateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.desc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> thenByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> thenByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> thenByOperatingHoursJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatingHoursJson', Sort.asc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy>
      thenByOperatingHoursJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatingHoursJson', Sort.desc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension GateIsarQueryWhereDistinct
    on QueryBuilder<GateIsar, GateIsar, QDistinct> {
  QueryBuilder<GateIsar, GateIsar, QDistinct> distinctByAllowedUserRoles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allowedUserRoles');
    });
  }

  QueryBuilder<GateIsar, GateIsar, QDistinct> distinctByAssignedOfficerIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedOfficerIds');
    });
  }

  QueryBuilder<GateIsar, GateIsar, QDistinct> distinctByGateId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gateId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QDistinct> distinctByLocation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'location', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QDistinct> distinctByOperatingHoursJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operatingHoursJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QDistinct>
      distinctByRequiredVerificationMethods() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requiredVerificationMethods');
    });
  }

  QueryBuilder<GateIsar, GateIsar, QDistinct> distinctBySchoolId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GateIsar, GateIsar, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension GateIsarQueryProperty
    on QueryBuilder<GateIsar, GateIsar, QQueryProperty> {
  QueryBuilder<GateIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GateIsar, List<String>, QQueryOperations>
      allowedUserRolesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allowedUserRoles');
    });
  }

  QueryBuilder<GateIsar, List<String>, QQueryOperations>
      assignedOfficerIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedOfficerIds');
    });
  }

  QueryBuilder<GateIsar, String, QQueryOperations> gateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gateId');
    });
  }

  QueryBuilder<GateIsar, String, QQueryOperations> locationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'location');
    });
  }

  QueryBuilder<GateIsar, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<GateIsar, String, QQueryOperations>
      operatingHoursJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operatingHoursJson');
    });
  }

  QueryBuilder<GateIsar, List<String>, QQueryOperations>
      requiredVerificationMethodsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requiredVerificationMethods');
    });
  }

  QueryBuilder<GateIsar, String, QQueryOperations> schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<GateIsar, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSecurityIncidentIsarCollection on Isar {
  IsarCollection<SecurityIncidentIsar> get securityIncidentIsars =>
      this.collection();
}

const SecurityIncidentIsarSchema = CollectionSchema(
  name: r'SecurityIncidentIsar',
  id: 8859738775266885274,
  properties: {
    r'description': PropertySchema(
      id: 0,
      name: r'description',
      type: IsarType.string,
    ),
    r'incidentId': PropertySchema(
      id: 1,
      name: r'incidentId',
      type: IsarType.string,
    ),
    r'involvedPersonIds': PropertySchema(
      id: 2,
      name: r'involvedPersonIds',
      type: IsarType.stringList,
    ),
    r'isSynced': PropertySchema(
      id: 3,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'location': PropertySchema(
      id: 4,
      name: r'location',
      type: IsarType.string,
    ),
    r'photoUrls': PropertySchema(
      id: 5,
      name: r'photoUrls',
      type: IsarType.stringList,
    ),
    r'report': PropertySchema(
      id: 6,
      name: r'report',
      type: IsarType.string,
    ),
    r'reportedByOfficerId': PropertySchema(
      id: 7,
      name: r'reportedByOfficerId',
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
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 10,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'type': PropertySchema(
      id: 11,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _securityIncidentIsarEstimateSize,
  serialize: _securityIncidentIsarSerialize,
  deserialize: _securityIncidentIsarDeserialize,
  deserializeProp: _securityIncidentIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'incidentId': IndexSchema(
      id: 8421601180046468367,
      name: r'incidentId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'incidentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _securityIncidentIsarGetId,
  getLinks: _securityIncidentIsarGetLinks,
  attach: _securityIncidentIsarAttach,
  version: '3.1.0+1',
);

int _securityIncidentIsarEstimateSize(
  SecurityIncidentIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.incidentId.length * 3;
  bytesCount += 3 + object.involvedPersonIds.length * 3;
  {
    for (var i = 0; i < object.involvedPersonIds.length; i++) {
      final value = object.involvedPersonIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.location.length * 3;
  bytesCount += 3 + object.photoUrls.length * 3;
  {
    for (var i = 0; i < object.photoUrls.length; i++) {
      final value = object.photoUrls[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.report.length * 3;
  bytesCount += 3 + object.reportedByOfficerId.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _securityIncidentIsarSerialize(
  SecurityIncidentIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.description);
  writer.writeString(offsets[1], object.incidentId);
  writer.writeStringList(offsets[2], object.involvedPersonIds);
  writer.writeBool(offsets[3], object.isSynced);
  writer.writeString(offsets[4], object.location);
  writer.writeStringList(offsets[5], object.photoUrls);
  writer.writeString(offsets[6], object.report);
  writer.writeString(offsets[7], object.reportedByOfficerId);
  writer.writeString(offsets[8], object.schoolId);
  writer.writeString(offsets[9], object.status);
  writer.writeDateTime(offsets[10], object.timestamp);
  writer.writeString(offsets[11], object.type);
}

SecurityIncidentIsar _securityIncidentIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SecurityIncidentIsar();
  object.description = reader.readString(offsets[0]);
  object.id = id;
  object.incidentId = reader.readString(offsets[1]);
  object.involvedPersonIds = reader.readStringList(offsets[2]) ?? [];
  object.isSynced = reader.readBool(offsets[3]);
  object.location = reader.readString(offsets[4]);
  object.photoUrls = reader.readStringList(offsets[5]) ?? [];
  object.report = reader.readString(offsets[6]);
  object.reportedByOfficerId = reader.readString(offsets[7]);
  object.schoolId = reader.readString(offsets[8]);
  object.status = reader.readString(offsets[9]);
  object.timestamp = reader.readDateTime(offsets[10]);
  object.type = reader.readString(offsets[11]);
  return object;
}

P _securityIncidentIsarDeserializeProp<P>(
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
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _securityIncidentIsarGetId(SecurityIncidentIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _securityIncidentIsarGetLinks(
    SecurityIncidentIsar object) {
  return [];
}

void _securityIncidentIsarAttach(
    IsarCollection<dynamic> col, Id id, SecurityIncidentIsar object) {
  object.id = id;
}

extension SecurityIncidentIsarByIndex on IsarCollection<SecurityIncidentIsar> {
  Future<SecurityIncidentIsar?> getByIncidentId(String incidentId) {
    return getByIndex(r'incidentId', [incidentId]);
  }

  SecurityIncidentIsar? getByIncidentIdSync(String incidentId) {
    return getByIndexSync(r'incidentId', [incidentId]);
  }

  Future<bool> deleteByIncidentId(String incidentId) {
    return deleteByIndex(r'incidentId', [incidentId]);
  }

  bool deleteByIncidentIdSync(String incidentId) {
    return deleteByIndexSync(r'incidentId', [incidentId]);
  }

  Future<List<SecurityIncidentIsar?>> getAllByIncidentId(
      List<String> incidentIdValues) {
    final values = incidentIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'incidentId', values);
  }

  List<SecurityIncidentIsar?> getAllByIncidentIdSync(
      List<String> incidentIdValues) {
    final values = incidentIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'incidentId', values);
  }

  Future<int> deleteAllByIncidentId(List<String> incidentIdValues) {
    final values = incidentIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'incidentId', values);
  }

  int deleteAllByIncidentIdSync(List<String> incidentIdValues) {
    final values = incidentIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'incidentId', values);
  }

  Future<Id> putByIncidentId(SecurityIncidentIsar object) {
    return putByIndex(r'incidentId', object);
  }

  Id putByIncidentIdSync(SecurityIncidentIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'incidentId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByIncidentId(List<SecurityIncidentIsar> objects) {
    return putAllByIndex(r'incidentId', objects);
  }

  List<Id> putAllByIncidentIdSync(List<SecurityIncidentIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'incidentId', objects, saveLinks: saveLinks);
  }
}

extension SecurityIncidentIsarQueryWhereSort
    on QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QWhere> {
  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SecurityIncidentIsarQueryWhere
    on QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QWhereClause> {
  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterWhereClause>
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

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterWhereClause>
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

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterWhereClause>
      incidentIdEqualTo(String incidentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'incidentId',
        value: [incidentId],
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterWhereClause>
      incidentIdNotEqualTo(String incidentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'incidentId',
              lower: [],
              upper: [incidentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'incidentId',
              lower: [incidentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'incidentId',
              lower: [incidentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'incidentId',
              lower: [],
              upper: [incidentId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SecurityIncidentIsarQueryFilter on QueryBuilder<SecurityIncidentIsar,
    SecurityIncidentIsar, QFilterCondition> {
  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
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

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
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

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
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

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> incidentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'incidentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> incidentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'incidentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> incidentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'incidentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> incidentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'incidentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> incidentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'incidentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> incidentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'incidentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      incidentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'incidentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      incidentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'incidentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> incidentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'incidentId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> incidentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'incidentId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> involvedPersonIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'involvedPersonIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> involvedPersonIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'involvedPersonIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> involvedPersonIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'involvedPersonIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> involvedPersonIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'involvedPersonIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> involvedPersonIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'involvedPersonIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> involvedPersonIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'involvedPersonIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      involvedPersonIdsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'involvedPersonIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      involvedPersonIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'involvedPersonIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> involvedPersonIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'involvedPersonIds',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> involvedPersonIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'involvedPersonIds',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> involvedPersonIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'involvedPersonIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> involvedPersonIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'involvedPersonIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> involvedPersonIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'involvedPersonIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> involvedPersonIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'involvedPersonIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> involvedPersonIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'involvedPersonIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> involvedPersonIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'involvedPersonIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> locationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> locationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> locationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> locationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'location',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> locationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> locationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      locationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      locationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'location',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> locationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> locationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> photoUrlsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> photoUrlsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> photoUrlsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> photoUrlsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoUrls',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> photoUrlsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> photoUrlsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      photoUrlsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      photoUrlsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoUrls',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> photoUrlsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> photoUrlsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> photoUrlsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoUrls',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> photoUrlsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoUrls',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> photoUrlsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoUrls',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> photoUrlsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoUrls',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> photoUrlsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoUrls',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> photoUrlsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoUrls',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'report',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'report',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'report',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'report',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'report',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'report',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      reportContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'report',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      reportMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'report',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'report',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'report',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportedByOfficerIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reportedByOfficerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportedByOfficerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reportedByOfficerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportedByOfficerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reportedByOfficerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportedByOfficerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reportedByOfficerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportedByOfficerIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reportedByOfficerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportedByOfficerIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reportedByOfficerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      reportedByOfficerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reportedByOfficerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      reportedByOfficerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reportedByOfficerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportedByOfficerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reportedByOfficerId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> reportedByOfficerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reportedByOfficerId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
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

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
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

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
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

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
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

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
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

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
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

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
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

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
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

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
          QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension SecurityIncidentIsarQueryObject on QueryBuilder<SecurityIncidentIsar,
    SecurityIncidentIsar, QFilterCondition> {}

extension SecurityIncidentIsarQueryLinks on QueryBuilder<SecurityIncidentIsar,
    SecurityIncidentIsar, QFilterCondition> {}

extension SecurityIncidentIsarQuerySortBy
    on QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QSortBy> {
  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByIncidentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incidentId', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByIncidentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incidentId', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByReport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'report', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByReportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'report', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByReportedByOfficerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportedByOfficerId', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByReportedByOfficerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportedByOfficerId', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension SecurityIncidentIsarQuerySortThenBy
    on QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QSortThenBy> {
  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByIncidentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incidentId', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByIncidentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'incidentId', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByReport() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'report', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByReportDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'report', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByReportedByOfficerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportedByOfficerId', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByReportedByOfficerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reportedByOfficerId', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension SecurityIncidentIsarQueryWhereDistinct
    on QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QDistinct> {
  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QDistinct>
      distinctByIncidentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'incidentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QDistinct>
      distinctByInvolvedPersonIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'involvedPersonIds');
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QDistinct>
      distinctByLocation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'location', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QDistinct>
      distinctByPhotoUrls() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoUrls');
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QDistinct>
      distinctByReport({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'report', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QDistinct>
      distinctByReportedByOfficerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reportedByOfficerId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<SecurityIncidentIsar, SecurityIncidentIsar, QDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension SecurityIncidentIsarQueryProperty on QueryBuilder<
    SecurityIncidentIsar, SecurityIncidentIsar, QQueryProperty> {
  QueryBuilder<SecurityIncidentIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SecurityIncidentIsar, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<SecurityIncidentIsar, String, QQueryOperations>
      incidentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'incidentId');
    });
  }

  QueryBuilder<SecurityIncidentIsar, List<String>, QQueryOperations>
      involvedPersonIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'involvedPersonIds');
    });
  }

  QueryBuilder<SecurityIncidentIsar, bool, QQueryOperations>
      isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<SecurityIncidentIsar, String, QQueryOperations>
      locationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'location');
    });
  }

  QueryBuilder<SecurityIncidentIsar, List<String>, QQueryOperations>
      photoUrlsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoUrls');
    });
  }

  QueryBuilder<SecurityIncidentIsar, String, QQueryOperations>
      reportProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'report');
    });
  }

  QueryBuilder<SecurityIncidentIsar, String, QQueryOperations>
      reportedByOfficerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reportedByOfficerId');
    });
  }

  QueryBuilder<SecurityIncidentIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<SecurityIncidentIsar, String, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<SecurityIncidentIsar, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<SecurityIncidentIsar, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStudentMovementIsarCollection on Isar {
  IsarCollection<StudentMovementIsar> get studentMovementIsars =>
      this.collection();
}

const StudentMovementIsarSchema = CollectionSchema(
  name: r'StudentMovementIsar',
  id: 594846526303693428,
  properties: {
    r'className': PropertySchema(
      id: 0,
      name: r'className',
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
    r'gateId': PropertySchema(
      id: 3,
      name: r'gateId',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 4,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'movementId': PropertySchema(
      id: 5,
      name: r'movementId',
      type: IsarType.string,
    ),
    r'movementType': PropertySchema(
      id: 6,
      name: r'movementType',
      type: IsarType.string,
    ),
    r'officerId': PropertySchema(
      id: 7,
      name: r'officerId',
      type: IsarType.string,
    ),
    r'pickupDetailsJson': PropertySchema(
      id: 8,
      name: r'pickupDetailsJson',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 9,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'studentId': PropertySchema(
      id: 10,
      name: r'studentId',
      type: IsarType.string,
    ),
    r'studentName': PropertySchema(
      id: 11,
      name: r'studentName',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 12,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'verificationMethod': PropertySchema(
      id: 13,
      name: r'verificationMethod',
      type: IsarType.string,
    )
  },
  estimateSize: _studentMovementIsarEstimateSize,
  serialize: _studentMovementIsarSerialize,
  deserialize: _studentMovementIsarDeserialize,
  deserializeProp: _studentMovementIsarDeserializeProp,
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
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _studentMovementIsarGetId,
  getLinks: _studentMovementIsarGetLinks,
  attach: _studentMovementIsarAttach,
  version: '3.1.0+1',
);

int _studentMovementIsarEstimateSize(
  StudentMovementIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.className.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.direction.length * 3;
  bytesCount += 3 + object.gateId.length * 3;
  bytesCount += 3 + object.movementId.length * 3;
  bytesCount += 3 + object.movementType.length * 3;
  bytesCount += 3 + object.officerId.length * 3;
  {
    final value = object.pickupDetailsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.studentId.length * 3;
  bytesCount += 3 + object.studentName.length * 3;
  bytesCount += 3 + object.verificationMethod.length * 3;
  return bytesCount;
}

void _studentMovementIsarSerialize(
  StudentMovementIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.className);
  writer.writeString(offsets[1], object.deviceId);
  writer.writeString(offsets[2], object.direction);
  writer.writeString(offsets[3], object.gateId);
  writer.writeBool(offsets[4], object.isSynced);
  writer.writeString(offsets[5], object.movementId);
  writer.writeString(offsets[6], object.movementType);
  writer.writeString(offsets[7], object.officerId);
  writer.writeString(offsets[8], object.pickupDetailsJson);
  writer.writeString(offsets[9], object.schoolId);
  writer.writeString(offsets[10], object.studentId);
  writer.writeString(offsets[11], object.studentName);
  writer.writeDateTime(offsets[12], object.timestamp);
  writer.writeString(offsets[13], object.verificationMethod);
}

StudentMovementIsar _studentMovementIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StudentMovementIsar();
  object.className = reader.readString(offsets[0]);
  object.deviceId = reader.readString(offsets[1]);
  object.direction = reader.readString(offsets[2]);
  object.gateId = reader.readString(offsets[3]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[4]);
  object.movementId = reader.readString(offsets[5]);
  object.movementType = reader.readString(offsets[6]);
  object.officerId = reader.readString(offsets[7]);
  object.pickupDetailsJson = reader.readStringOrNull(offsets[8]);
  object.schoolId = reader.readString(offsets[9]);
  object.studentId = reader.readString(offsets[10]);
  object.studentName = reader.readString(offsets[11]);
  object.timestamp = reader.readDateTime(offsets[12]);
  object.verificationMethod = reader.readString(offsets[13]);
  return object;
}

P _studentMovementIsarDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _studentMovementIsarGetId(StudentMovementIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _studentMovementIsarGetLinks(
    StudentMovementIsar object) {
  return [];
}

void _studentMovementIsarAttach(
    IsarCollection<dynamic> col, Id id, StudentMovementIsar object) {
  object.id = id;
}

extension StudentMovementIsarByIndex on IsarCollection<StudentMovementIsar> {
  Future<StudentMovementIsar?> getByMovementId(String movementId) {
    return getByIndex(r'movementId', [movementId]);
  }

  StudentMovementIsar? getByMovementIdSync(String movementId) {
    return getByIndexSync(r'movementId', [movementId]);
  }

  Future<bool> deleteByMovementId(String movementId) {
    return deleteByIndex(r'movementId', [movementId]);
  }

  bool deleteByMovementIdSync(String movementId) {
    return deleteByIndexSync(r'movementId', [movementId]);
  }

  Future<List<StudentMovementIsar?>> getAllByMovementId(
      List<String> movementIdValues) {
    final values = movementIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'movementId', values);
  }

  List<StudentMovementIsar?> getAllByMovementIdSync(
      List<String> movementIdValues) {
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

  Future<Id> putByMovementId(StudentMovementIsar object) {
    return putByIndex(r'movementId', object);
  }

  Id putByMovementIdSync(StudentMovementIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'movementId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMovementId(List<StudentMovementIsar> objects) {
    return putAllByIndex(r'movementId', objects);
  }

  List<Id> putAllByMovementIdSync(List<StudentMovementIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'movementId', objects, saveLinks: saveLinks);
  }
}

extension StudentMovementIsarQueryWhereSort
    on QueryBuilder<StudentMovementIsar, StudentMovementIsar, QWhere> {
  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StudentMovementIsarQueryWhere
    on QueryBuilder<StudentMovementIsar, StudentMovementIsar, QWhereClause> {
  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterWhereClause>
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

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterWhereClause>
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

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterWhereClause>
      movementIdEqualTo(String movementId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'movementId',
        value: [movementId],
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterWhereClause>
      movementIdNotEqualTo(String movementId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'movementId',
              lower: [],
              upper: [movementId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'movementId',
              lower: [movementId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'movementId',
              lower: [movementId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'movementId',
              lower: [],
              upper: [movementId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension StudentMovementIsarQueryFilter on QueryBuilder<StudentMovementIsar,
    StudentMovementIsar, QFilterCondition> {
  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      classNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      classNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      classNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      classNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'className',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      classNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      classNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      classNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      classNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'className',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      classNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'className',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      classNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'className',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      deviceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      deviceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      deviceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      deviceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      directionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      directionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      directionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      directionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'direction',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      directionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      directionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      directionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'direction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      directionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'direction',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      directionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'direction',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      directionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'direction',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      gateIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      gateIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      gateIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      gateIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gateId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      gateIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      gateIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      gateIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      gateIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gateId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      gateIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gateId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      gateIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gateId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'movementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'movementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'movementId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'movementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'movementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'movementId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'movementId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'movementId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'movementType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'movementType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementType',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      movementTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'movementType',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      officerIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'officerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      officerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'officerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      officerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'officerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      officerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'officerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      officerIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'officerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      officerIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'officerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      officerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'officerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      officerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'officerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      officerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'officerId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      officerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'officerId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      pickupDetailsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pickupDetailsJson',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      pickupDetailsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pickupDetailsJson',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      pickupDetailsJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pickupDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      pickupDetailsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pickupDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      pickupDetailsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pickupDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      pickupDetailsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pickupDetailsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      pickupDetailsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pickupDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      pickupDetailsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pickupDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      pickupDetailsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pickupDetailsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      pickupDetailsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pickupDetailsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      pickupDetailsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pickupDetailsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      pickupDetailsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pickupDetailsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      schoolIdEqualTo(
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

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      schoolIdGreaterThan(
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

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      schoolIdLessThan(
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

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      schoolIdBetween(
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

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      schoolIdStartsWith(
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

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      schoolIdEndsWith(
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

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'studentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'studentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'studentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'studentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'studentName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'studentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'studentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'studentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'studentName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      studentNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'studentName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      verificationMethodEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verificationMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      verificationMethodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'verificationMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      verificationMethodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'verificationMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      verificationMethodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'verificationMethod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      verificationMethodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'verificationMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      verificationMethodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'verificationMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      verificationMethodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'verificationMethod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      verificationMethodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'verificationMethod',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      verificationMethodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'verificationMethod',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterFilterCondition>
      verificationMethodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'verificationMethod',
        value: '',
      ));
    });
  }
}

extension StudentMovementIsarQueryObject on QueryBuilder<StudentMovementIsar,
    StudentMovementIsar, QFilterCondition> {}

extension StudentMovementIsarQueryLinks on QueryBuilder<StudentMovementIsar,
    StudentMovementIsar, QFilterCondition> {}

extension StudentMovementIsarQuerySortBy
    on QueryBuilder<StudentMovementIsar, StudentMovementIsar, QSortBy> {
  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByGateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByGateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByMovementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementId', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByMovementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementId', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByMovementType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementType', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByMovementTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementType', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByOfficerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'officerId', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByOfficerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'officerId', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByPickupDetailsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pickupDetailsJson', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByPickupDetailsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pickupDetailsJson', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByStudentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentName', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByStudentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentName', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByVerificationMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationMethod', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      sortByVerificationMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationMethod', Sort.desc);
    });
  }
}

extension StudentMovementIsarQuerySortThenBy
    on QueryBuilder<StudentMovementIsar, StudentMovementIsar, QSortThenBy> {
  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByGateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByGateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByMovementId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementId', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByMovementIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementId', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByMovementType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementType', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByMovementTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementType', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByOfficerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'officerId', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByOfficerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'officerId', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByPickupDetailsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pickupDetailsJson', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByPickupDetailsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pickupDetailsJson', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByStudentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentName', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByStudentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentName', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByVerificationMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationMethod', Sort.asc);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QAfterSortBy>
      thenByVerificationMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'verificationMethod', Sort.desc);
    });
  }
}

extension StudentMovementIsarQueryWhereDistinct
    on QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct> {
  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct>
      distinctByClassName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'className', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct>
      distinctByDirection({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'direction', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct>
      distinctByGateId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gateId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct>
      distinctByMovementId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movementId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct>
      distinctByMovementType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movementType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct>
      distinctByOfficerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'officerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct>
      distinctByPickupDetailsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pickupDetailsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct>
      distinctByStudentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct>
      distinctByStudentName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studentName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<StudentMovementIsar, StudentMovementIsar, QDistinct>
      distinctByVerificationMethod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'verificationMethod',
          caseSensitive: caseSensitive);
    });
  }
}

extension StudentMovementIsarQueryProperty
    on QueryBuilder<StudentMovementIsar, StudentMovementIsar, QQueryProperty> {
  QueryBuilder<StudentMovementIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StudentMovementIsar, String, QQueryOperations>
      classNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'className');
    });
  }

  QueryBuilder<StudentMovementIsar, String, QQueryOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<StudentMovementIsar, String, QQueryOperations>
      directionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'direction');
    });
  }

  QueryBuilder<StudentMovementIsar, String, QQueryOperations> gateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gateId');
    });
  }

  QueryBuilder<StudentMovementIsar, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<StudentMovementIsar, String, QQueryOperations>
      movementIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movementId');
    });
  }

  QueryBuilder<StudentMovementIsar, String, QQueryOperations>
      movementTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movementType');
    });
  }

  QueryBuilder<StudentMovementIsar, String, QQueryOperations>
      officerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'officerId');
    });
  }

  QueryBuilder<StudentMovementIsar, String?, QQueryOperations>
      pickupDetailsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pickupDetailsJson');
    });
  }

  QueryBuilder<StudentMovementIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<StudentMovementIsar, String, QQueryOperations>
      studentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studentId');
    });
  }

  QueryBuilder<StudentMovementIsar, String, QQueryOperations>
      studentNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studentName');
    });
  }

  QueryBuilder<StudentMovementIsar, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<StudentMovementIsar, String, QQueryOperations>
      verificationMethodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'verificationMethod');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEmergencyEventIsarCollection on Isar {
  IsarCollection<EmergencyEventIsar> get emergencyEventIsars =>
      this.collection();
}

const EmergencyEventIsarSchema = CollectionSchema(
  name: r'EmergencyEventIsar',
  id: 958179405254888653,
  properties: {
    r'description': PropertySchema(
      id: 0,
      name: r'description',
      type: IsarType.string,
    ),
    r'endTime': PropertySchema(
      id: 1,
      name: r'endTime',
      type: IsarType.dateTime,
    ),
    r'eventId': PropertySchema(
      id: 2,
      name: r'eventId',
      type: IsarType.string,
    ),
    r'involvedPersonIds': PropertySchema(
      id: 3,
      name: r'involvedPersonIds',
      type: IsarType.stringList,
    ),
    r'isSynced': PropertySchema(
      id: 4,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'responseActions': PropertySchema(
      id: 5,
      name: r'responseActions',
      type: IsarType.stringList,
    ),
    r'schoolId': PropertySchema(
      id: 6,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'startTime': PropertySchema(
      id: 7,
      name: r'startTime',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 8,
      name: r'status',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 9,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _emergencyEventIsarEstimateSize,
  serialize: _emergencyEventIsarSerialize,
  deserialize: _emergencyEventIsarDeserialize,
  deserializeProp: _emergencyEventIsarDeserializeProp,
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
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _emergencyEventIsarGetId,
  getLinks: _emergencyEventIsarGetLinks,
  attach: _emergencyEventIsarAttach,
  version: '3.1.0+1',
);

int _emergencyEventIsarEstimateSize(
  EmergencyEventIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.eventId.length * 3;
  bytesCount += 3 + object.involvedPersonIds.length * 3;
  {
    for (var i = 0; i < object.involvedPersonIds.length; i++) {
      final value = object.involvedPersonIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.responseActions.length * 3;
  {
    for (var i = 0; i < object.responseActions.length; i++) {
      final value = object.responseActions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _emergencyEventIsarSerialize(
  EmergencyEventIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.description);
  writer.writeDateTime(offsets[1], object.endTime);
  writer.writeString(offsets[2], object.eventId);
  writer.writeStringList(offsets[3], object.involvedPersonIds);
  writer.writeBool(offsets[4], object.isSynced);
  writer.writeStringList(offsets[5], object.responseActions);
  writer.writeString(offsets[6], object.schoolId);
  writer.writeDateTime(offsets[7], object.startTime);
  writer.writeString(offsets[8], object.status);
  writer.writeString(offsets[9], object.type);
}

EmergencyEventIsar _emergencyEventIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EmergencyEventIsar();
  object.description = reader.readString(offsets[0]);
  object.endTime = reader.readDateTimeOrNull(offsets[1]);
  object.eventId = reader.readString(offsets[2]);
  object.id = id;
  object.involvedPersonIds = reader.readStringList(offsets[3]) ?? [];
  object.isSynced = reader.readBool(offsets[4]);
  object.responseActions = reader.readStringList(offsets[5]) ?? [];
  object.schoolId = reader.readString(offsets[6]);
  object.startTime = reader.readDateTime(offsets[7]);
  object.status = reader.readString(offsets[8]);
  object.type = reader.readString(offsets[9]);
  return object;
}

P _emergencyEventIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _emergencyEventIsarGetId(EmergencyEventIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _emergencyEventIsarGetLinks(
    EmergencyEventIsar object) {
  return [];
}

void _emergencyEventIsarAttach(
    IsarCollection<dynamic> col, Id id, EmergencyEventIsar object) {
  object.id = id;
}

extension EmergencyEventIsarByIndex on IsarCollection<EmergencyEventIsar> {
  Future<EmergencyEventIsar?> getByEventId(String eventId) {
    return getByIndex(r'eventId', [eventId]);
  }

  EmergencyEventIsar? getByEventIdSync(String eventId) {
    return getByIndexSync(r'eventId', [eventId]);
  }

  Future<bool> deleteByEventId(String eventId) {
    return deleteByIndex(r'eventId', [eventId]);
  }

  bool deleteByEventIdSync(String eventId) {
    return deleteByIndexSync(r'eventId', [eventId]);
  }

  Future<List<EmergencyEventIsar?>> getAllByEventId(
      List<String> eventIdValues) {
    final values = eventIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'eventId', values);
  }

  List<EmergencyEventIsar?> getAllByEventIdSync(List<String> eventIdValues) {
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

  Future<Id> putByEventId(EmergencyEventIsar object) {
    return putByIndex(r'eventId', object);
  }

  Id putByEventIdSync(EmergencyEventIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'eventId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEventId(List<EmergencyEventIsar> objects) {
    return putAllByIndex(r'eventId', objects);
  }

  List<Id> putAllByEventIdSync(List<EmergencyEventIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'eventId', objects, saveLinks: saveLinks);
  }
}

extension EmergencyEventIsarQueryWhereSort
    on QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QWhere> {
  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension EmergencyEventIsarQueryWhere
    on QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QWhereClause> {
  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterWhereClause>
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

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterWhereClause>
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

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterWhereClause>
      eventIdEqualTo(String eventId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'eventId',
        value: [eventId],
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterWhereClause>
      eventIdNotEqualTo(String eventId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventId',
              lower: [],
              upper: [eventId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventId',
              lower: [eventId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventId',
              lower: [eventId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventId',
              lower: [],
              upper: [eventId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension EmergencyEventIsarQueryFilter
    on QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QFilterCondition> {
  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      endTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      endTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      endTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      endTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      endTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      endTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      eventIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      eventIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      eventIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      eventIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eventId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      eventIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      eventIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      eventIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      eventIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eventId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      eventIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      eventIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eventId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'involvedPersonIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'involvedPersonIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'involvedPersonIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'involvedPersonIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'involvedPersonIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'involvedPersonIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'involvedPersonIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'involvedPersonIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'involvedPersonIds',
        value: '',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'involvedPersonIds',
        value: '',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'involvedPersonIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'involvedPersonIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'involvedPersonIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'involvedPersonIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'involvedPersonIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      involvedPersonIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'involvedPersonIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'responseActions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'responseActions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'responseActions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'responseActions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'responseActions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'responseActions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'responseActions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'responseActions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'responseActions',
        value: '',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'responseActions',
        value: '',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'responseActions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'responseActions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'responseActions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'responseActions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'responseActions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      responseActionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'responseActions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      schoolIdEqualTo(
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

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      schoolIdGreaterThan(
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

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      schoolIdLessThan(
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

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      schoolIdBetween(
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

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      schoolIdStartsWith(
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

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      schoolIdEndsWith(
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

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      startTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      startTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      startTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension EmergencyEventIsarQueryObject
    on QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QFilterCondition> {}

extension EmergencyEventIsarQueryLinks
    on QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QFilterCondition> {}

extension EmergencyEventIsarQuerySortBy
    on QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QSortBy> {
  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension EmergencyEventIsarQuerySortThenBy
    on QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QSortThenBy> {
  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventId', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension EmergencyEventIsarQueryWhereDistinct
    on QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QDistinct> {
  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QDistinct>
      distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QDistinct>
      distinctByEventId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QDistinct>
      distinctByInvolvedPersonIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'involvedPersonIds');
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QDistinct>
      distinctByResponseActions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'responseActions');
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QDistinct>
      distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QDistinct>
      distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension EmergencyEventIsarQueryProperty
    on QueryBuilder<EmergencyEventIsar, EmergencyEventIsar, QQueryProperty> {
  QueryBuilder<EmergencyEventIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EmergencyEventIsar, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<EmergencyEventIsar, DateTime?, QQueryOperations>
      endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<EmergencyEventIsar, String, QQueryOperations> eventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventId');
    });
  }

  QueryBuilder<EmergencyEventIsar, List<String>, QQueryOperations>
      involvedPersonIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'involvedPersonIds');
    });
  }

  QueryBuilder<EmergencyEventIsar, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<EmergencyEventIsar, List<String>, QQueryOperations>
      responseActionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'responseActions');
    });
  }

  QueryBuilder<EmergencyEventIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<EmergencyEventIsar, DateTime, QQueryOperations>
      startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }

  QueryBuilder<EmergencyEventIsar, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<EmergencyEventIsar, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSecurityPatrolIsarCollection on Isar {
  IsarCollection<SecurityPatrolIsar> get securityPatrolIsars =>
      this.collection();
}

const SecurityPatrolIsarSchema = CollectionSchema(
  name: r'SecurityPatrolIsar',
  id: 5134525467887018459,
  properties: {
    r'isSynced': PropertySchema(
      id: 0,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'issuesFound': PropertySchema(
      id: 1,
      name: r'issuesFound',
      type: IsarType.stringList,
    ),
    r'location': PropertySchema(
      id: 2,
      name: r'location',
      type: IsarType.string,
    ),
    r'observations': PropertySchema(
      id: 3,
      name: r'observations',
      type: IsarType.string,
    ),
    r'officerId': PropertySchema(
      id: 4,
      name: r'officerId',
      type: IsarType.string,
    ),
    r'patrolId': PropertySchema(
      id: 5,
      name: r'patrolId',
      type: IsarType.string,
    ),
    r'photoUrls': PropertySchema(
      id: 6,
      name: r'photoUrls',
      type: IsarType.stringList,
    ),
    r'schoolId': PropertySchema(
      id: 7,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 8,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _securityPatrolIsarEstimateSize,
  serialize: _securityPatrolIsarSerialize,
  deserialize: _securityPatrolIsarDeserialize,
  deserializeProp: _securityPatrolIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'patrolId': IndexSchema(
      id: -7416788140426994002,
      name: r'patrolId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'patrolId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _securityPatrolIsarGetId,
  getLinks: _securityPatrolIsarGetLinks,
  attach: _securityPatrolIsarAttach,
  version: '3.1.0+1',
);

int _securityPatrolIsarEstimateSize(
  SecurityPatrolIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.issuesFound.length * 3;
  {
    for (var i = 0; i < object.issuesFound.length; i++) {
      final value = object.issuesFound[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.location.length * 3;
  bytesCount += 3 + object.observations.length * 3;
  bytesCount += 3 + object.officerId.length * 3;
  bytesCount += 3 + object.patrolId.length * 3;
  bytesCount += 3 + object.photoUrls.length * 3;
  {
    for (var i = 0; i < object.photoUrls.length; i++) {
      final value = object.photoUrls[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolId.length * 3;
  return bytesCount;
}

void _securityPatrolIsarSerialize(
  SecurityPatrolIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isSynced);
  writer.writeStringList(offsets[1], object.issuesFound);
  writer.writeString(offsets[2], object.location);
  writer.writeString(offsets[3], object.observations);
  writer.writeString(offsets[4], object.officerId);
  writer.writeString(offsets[5], object.patrolId);
  writer.writeStringList(offsets[6], object.photoUrls);
  writer.writeString(offsets[7], object.schoolId);
  writer.writeDateTime(offsets[8], object.timestamp);
}

SecurityPatrolIsar _securityPatrolIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SecurityPatrolIsar();
  object.id = id;
  object.isSynced = reader.readBool(offsets[0]);
  object.issuesFound = reader.readStringList(offsets[1]) ?? [];
  object.location = reader.readString(offsets[2]);
  object.observations = reader.readString(offsets[3]);
  object.officerId = reader.readString(offsets[4]);
  object.patrolId = reader.readString(offsets[5]);
  object.photoUrls = reader.readStringList(offsets[6]) ?? [];
  object.schoolId = reader.readString(offsets[7]);
  object.timestamp = reader.readDateTime(offsets[8]);
  return object;
}

P _securityPatrolIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _securityPatrolIsarGetId(SecurityPatrolIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _securityPatrolIsarGetLinks(
    SecurityPatrolIsar object) {
  return [];
}

void _securityPatrolIsarAttach(
    IsarCollection<dynamic> col, Id id, SecurityPatrolIsar object) {
  object.id = id;
}

extension SecurityPatrolIsarByIndex on IsarCollection<SecurityPatrolIsar> {
  Future<SecurityPatrolIsar?> getByPatrolId(String patrolId) {
    return getByIndex(r'patrolId', [patrolId]);
  }

  SecurityPatrolIsar? getByPatrolIdSync(String patrolId) {
    return getByIndexSync(r'patrolId', [patrolId]);
  }

  Future<bool> deleteByPatrolId(String patrolId) {
    return deleteByIndex(r'patrolId', [patrolId]);
  }

  bool deleteByPatrolIdSync(String patrolId) {
    return deleteByIndexSync(r'patrolId', [patrolId]);
  }

  Future<List<SecurityPatrolIsar?>> getAllByPatrolId(
      List<String> patrolIdValues) {
    final values = patrolIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'patrolId', values);
  }

  List<SecurityPatrolIsar?> getAllByPatrolIdSync(List<String> patrolIdValues) {
    final values = patrolIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'patrolId', values);
  }

  Future<int> deleteAllByPatrolId(List<String> patrolIdValues) {
    final values = patrolIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'patrolId', values);
  }

  int deleteAllByPatrolIdSync(List<String> patrolIdValues) {
    final values = patrolIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'patrolId', values);
  }

  Future<Id> putByPatrolId(SecurityPatrolIsar object) {
    return putByIndex(r'patrolId', object);
  }

  Id putByPatrolIdSync(SecurityPatrolIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'patrolId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPatrolId(List<SecurityPatrolIsar> objects) {
    return putAllByIndex(r'patrolId', objects);
  }

  List<Id> putAllByPatrolIdSync(List<SecurityPatrolIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'patrolId', objects, saveLinks: saveLinks);
  }
}

extension SecurityPatrolIsarQueryWhereSort
    on QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QWhere> {
  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SecurityPatrolIsarQueryWhere
    on QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QWhereClause> {
  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterWhereClause>
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

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterWhereClause>
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

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterWhereClause>
      patrolIdEqualTo(String patrolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'patrolId',
        value: [patrolId],
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterWhereClause>
      patrolIdNotEqualTo(String patrolId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'patrolId',
              lower: [],
              upper: [patrolId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'patrolId',
              lower: [patrolId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'patrolId',
              lower: [patrolId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'patrolId',
              lower: [],
              upper: [patrolId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SecurityPatrolIsarQueryFilter
    on QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QFilterCondition> {
  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuesFound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'issuesFound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'issuesFound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'issuesFound',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'issuesFound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'issuesFound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'issuesFound',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'issuesFound',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'issuesFound',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'issuesFound',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'issuesFound',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'issuesFound',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'issuesFound',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'issuesFound',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'issuesFound',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      issuesFoundLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'issuesFound',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      locationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      locationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      locationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      locationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'location',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      locationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      locationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      locationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      locationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'location',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      locationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      locationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      observationsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'observations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      observationsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'observations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      observationsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'observations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      observationsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'observations',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      observationsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'observations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      observationsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'observations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      observationsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'observations',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      observationsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'observations',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      observationsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'observations',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      observationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'observations',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      officerIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'officerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      officerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'officerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      officerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'officerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      officerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'officerId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      officerIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'officerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      officerIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'officerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      officerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'officerId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      officerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'officerId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      officerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'officerId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      officerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'officerId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      patrolIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'patrolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      patrolIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'patrolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      patrolIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'patrolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      patrolIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'patrolId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      patrolIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'patrolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      patrolIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'patrolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      patrolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'patrolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      patrolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'patrolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      patrolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'patrolId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      patrolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'patrolId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoUrls',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoUrls',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoUrls',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoUrls',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoUrls',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoUrls',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoUrls',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoUrls',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoUrls',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      photoUrlsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photoUrls',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      schoolIdEqualTo(
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

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      schoolIdGreaterThan(
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

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      schoolIdLessThan(
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

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      schoolIdBetween(
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

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      schoolIdStartsWith(
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

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      schoolIdEndsWith(
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

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SecurityPatrolIsarQueryObject
    on QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QFilterCondition> {}

extension SecurityPatrolIsarQueryLinks
    on QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QFilterCondition> {}

extension SecurityPatrolIsarQuerySortBy
    on QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QSortBy> {
  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      sortByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      sortByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      sortByObservations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observations', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      sortByObservationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observations', Sort.desc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      sortByOfficerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'officerId', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      sortByOfficerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'officerId', Sort.desc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      sortByPatrolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patrolId', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      sortByPatrolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patrolId', Sort.desc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension SecurityPatrolIsarQuerySortThenBy
    on QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QSortThenBy> {
  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenByObservations() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observations', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenByObservationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observations', Sort.desc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenByOfficerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'officerId', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenByOfficerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'officerId', Sort.desc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenByPatrolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patrolId', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenByPatrolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'patrolId', Sort.desc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension SecurityPatrolIsarQueryWhereDistinct
    on QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QDistinct> {
  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QDistinct>
      distinctByIssuesFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'issuesFound');
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QDistinct>
      distinctByLocation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'location', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QDistinct>
      distinctByObservations({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'observations', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QDistinct>
      distinctByOfficerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'officerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QDistinct>
      distinctByPatrolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'patrolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QDistinct>
      distinctByPhotoUrls() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoUrls');
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension SecurityPatrolIsarQueryProperty
    on QueryBuilder<SecurityPatrolIsar, SecurityPatrolIsar, QQueryProperty> {
  QueryBuilder<SecurityPatrolIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SecurityPatrolIsar, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<SecurityPatrolIsar, List<String>, QQueryOperations>
      issuesFoundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'issuesFound');
    });
  }

  QueryBuilder<SecurityPatrolIsar, String, QQueryOperations>
      locationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'location');
    });
  }

  QueryBuilder<SecurityPatrolIsar, String, QQueryOperations>
      observationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'observations');
    });
  }

  QueryBuilder<SecurityPatrolIsar, String, QQueryOperations>
      officerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'officerId');
    });
  }

  QueryBuilder<SecurityPatrolIsar, String, QQueryOperations>
      patrolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'patrolId');
    });
  }

  QueryBuilder<SecurityPatrolIsar, List<String>, QQueryOperations>
      photoUrlsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoUrls');
    });
  }

  QueryBuilder<SecurityPatrolIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<SecurityPatrolIsar, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
