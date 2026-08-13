// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMaintenanceIsarCollection on Isar {
  IsarCollection<MaintenanceIsar> get maintenanceIsars => this.collection();
}

const MaintenanceIsarSchema = CollectionSchema(
  name: r'MaintenanceIsar',
  id: -353916871964044053,
  properties: {
    r'assetId': PropertySchema(
      id: 0,
      name: r'assetId',
      type: IsarType.string,
    ),
    r'assetName': PropertySchema(
      id: 1,
      name: r'assetName',
      type: IsarType.string,
    ),
    r'completionDate': PropertySchema(
      id: 2,
      name: r'completionDate',
      type: IsarType.dateTime,
    ),
    r'cost': PropertySchema(
      id: 3,
      name: r'cost',
      type: IsarType.double,
    ),
    r'description': PropertySchema(
      id: 4,
      name: r'description',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 5,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'maintenanceId': PropertySchema(
      id: 6,
      name: r'maintenanceId',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 7,
      name: r'notes',
      type: IsarType.string,
    ),
    r'performedBy': PropertySchema(
      id: 8,
      name: r'performedBy',
      type: IsarType.string,
    ),
    r'scheduledDate': PropertySchema(
      id: 9,
      name: r'scheduledDate',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 10,
      name: r'status',
      type: IsarType.byte,
      enumMap: _MaintenanceIsarstatusEnumValueMap,
    ),
    r'type': PropertySchema(
      id: 11,
      name: r'type',
      type: IsarType.byte,
      enumMap: _MaintenanceIsartypeEnumValueMap,
    )
  },
  estimateSize: _maintenanceIsarEstimateSize,
  serialize: _maintenanceIsarSerialize,
  deserialize: _maintenanceIsarDeserialize,
  deserializeProp: _maintenanceIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'maintenanceId': IndexSchema(
      id: -4341299200936385774,
      name: r'maintenanceId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'maintenanceId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _maintenanceIsarGetId,
  getLinks: _maintenanceIsarGetLinks,
  attach: _maintenanceIsarAttach,
  version: '3.1.0+1',
);

int _maintenanceIsarEstimateSize(
  MaintenanceIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.assetId.length * 3;
  bytesCount += 3 + object.assetName.length * 3;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.maintenanceId.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.performedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _maintenanceIsarSerialize(
  MaintenanceIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.assetId);
  writer.writeString(offsets[1], object.assetName);
  writer.writeDateTime(offsets[2], object.completionDate);
  writer.writeDouble(offsets[3], object.cost);
  writer.writeString(offsets[4], object.description);
  writer.writeBool(offsets[5], object.isSynced);
  writer.writeString(offsets[6], object.maintenanceId);
  writer.writeString(offsets[7], object.notes);
  writer.writeString(offsets[8], object.performedBy);
  writer.writeDateTime(offsets[9], object.scheduledDate);
  writer.writeByte(offsets[10], object.status.index);
  writer.writeByte(offsets[11], object.type.index);
}

MaintenanceIsar _maintenanceIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MaintenanceIsar();
  object.assetId = reader.readString(offsets[0]);
  object.assetName = reader.readString(offsets[1]);
  object.completionDate = reader.readDateTimeOrNull(offsets[2]);
  object.cost = reader.readDouble(offsets[3]);
  object.description = reader.readString(offsets[4]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[5]);
  object.maintenanceId = reader.readString(offsets[6]);
  object.notes = reader.readStringOrNull(offsets[7]);
  object.performedBy = reader.readStringOrNull(offsets[8]);
  object.scheduledDate = reader.readDateTime(offsets[9]);
  object.status =
      _MaintenanceIsarstatusValueEnumMap[reader.readByteOrNull(offsets[10])] ??
          MaintenanceStatus.scheduled;
  object.type =
      _MaintenanceIsartypeValueEnumMap[reader.readByteOrNull(offsets[11])] ??
          MaintenanceType.routine;
  return object;
}

P _maintenanceIsarDeserializeProp<P>(
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (_MaintenanceIsarstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MaintenanceStatus.scheduled) as P;
    case 11:
      return (_MaintenanceIsartypeValueEnumMap[reader.readByteOrNull(offset)] ??
          MaintenanceType.routine) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MaintenanceIsarstatusEnumValueMap = {
  'scheduled': 0,
  'inProgress': 1,
  'completed': 2,
  'cancelled': 3,
};
const _MaintenanceIsarstatusValueEnumMap = {
  0: MaintenanceStatus.scheduled,
  1: MaintenanceStatus.inProgress,
  2: MaintenanceStatus.completed,
  3: MaintenanceStatus.cancelled,
};
const _MaintenanceIsartypeEnumValueMap = {
  'routine': 0,
  'preventive': 1,
  'emergency': 2,
};
const _MaintenanceIsartypeValueEnumMap = {
  0: MaintenanceType.routine,
  1: MaintenanceType.preventive,
  2: MaintenanceType.emergency,
};

Id _maintenanceIsarGetId(MaintenanceIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _maintenanceIsarGetLinks(MaintenanceIsar object) {
  return [];
}

void _maintenanceIsarAttach(
    IsarCollection<dynamic> col, Id id, MaintenanceIsar object) {
  object.id = id;
}

extension MaintenanceIsarByIndex on IsarCollection<MaintenanceIsar> {
  Future<MaintenanceIsar?> getByMaintenanceId(String maintenanceId) {
    return getByIndex(r'maintenanceId', [maintenanceId]);
  }

  MaintenanceIsar? getByMaintenanceIdSync(String maintenanceId) {
    return getByIndexSync(r'maintenanceId', [maintenanceId]);
  }

  Future<bool> deleteByMaintenanceId(String maintenanceId) {
    return deleteByIndex(r'maintenanceId', [maintenanceId]);
  }

  bool deleteByMaintenanceIdSync(String maintenanceId) {
    return deleteByIndexSync(r'maintenanceId', [maintenanceId]);
  }

  Future<List<MaintenanceIsar?>> getAllByMaintenanceId(
      List<String> maintenanceIdValues) {
    final values = maintenanceIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'maintenanceId', values);
  }

  List<MaintenanceIsar?> getAllByMaintenanceIdSync(
      List<String> maintenanceIdValues) {
    final values = maintenanceIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'maintenanceId', values);
  }

  Future<int> deleteAllByMaintenanceId(List<String> maintenanceIdValues) {
    final values = maintenanceIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'maintenanceId', values);
  }

  int deleteAllByMaintenanceIdSync(List<String> maintenanceIdValues) {
    final values = maintenanceIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'maintenanceId', values);
  }

  Future<Id> putByMaintenanceId(MaintenanceIsar object) {
    return putByIndex(r'maintenanceId', object);
  }

  Id putByMaintenanceIdSync(MaintenanceIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'maintenanceId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMaintenanceId(List<MaintenanceIsar> objects) {
    return putAllByIndex(r'maintenanceId', objects);
  }

  List<Id> putAllByMaintenanceIdSync(List<MaintenanceIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'maintenanceId', objects, saveLinks: saveLinks);
  }
}

extension MaintenanceIsarQueryWhereSort
    on QueryBuilder<MaintenanceIsar, MaintenanceIsar, QWhere> {
  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MaintenanceIsarQueryWhere
    on QueryBuilder<MaintenanceIsar, MaintenanceIsar, QWhereClause> {
  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterWhereClause>
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

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterWhereClause>
      maintenanceIdEqualTo(String maintenanceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'maintenanceId',
        value: [maintenanceId],
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterWhereClause>
      maintenanceIdNotEqualTo(String maintenanceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'maintenanceId',
              lower: [],
              upper: [maintenanceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'maintenanceId',
              lower: [maintenanceId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'maintenanceId',
              lower: [maintenanceId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'maintenanceId',
              lower: [],
              upper: [maintenanceId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MaintenanceIsarQueryFilter
    on QueryBuilder<MaintenanceIsar, MaintenanceIsar, QFilterCondition> {
  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assetId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assetId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetId',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assetId',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assetName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assetName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assetName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assetName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assetName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assetName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assetName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assetName',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      assetNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assetName',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      completionDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'completionDate',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      completionDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'completionDate',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      completionDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      completionDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      completionDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      completionDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completionDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      costEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      costGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      costLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cost',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      costBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
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

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
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

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
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

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
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

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
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

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
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

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
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

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
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

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
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

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      maintenanceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maintenanceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      maintenanceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maintenanceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      maintenanceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maintenanceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      maintenanceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maintenanceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      maintenanceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'maintenanceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      maintenanceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'maintenanceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      maintenanceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'maintenanceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      maintenanceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'maintenanceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      maintenanceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maintenanceId',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      maintenanceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'maintenanceId',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      performedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'performedBy',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      performedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'performedBy',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      performedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'performedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      performedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'performedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      performedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'performedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      performedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'performedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      performedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'performedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      performedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'performedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      performedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'performedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      performedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'performedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      performedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'performedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      performedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'performedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      scheduledDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      scheduledDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      scheduledDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledDate',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      scheduledDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      statusEqualTo(MaintenanceStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      statusGreaterThan(
    MaintenanceStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      statusLessThan(
    MaintenanceStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      statusBetween(
    MaintenanceStatus lower,
    MaintenanceStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      typeEqualTo(MaintenanceType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      typeGreaterThan(
    MaintenanceType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      typeLessThan(
    MaintenanceType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterFilterCondition>
      typeBetween(
    MaintenanceType lower,
    MaintenanceType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MaintenanceIsarQueryObject
    on QueryBuilder<MaintenanceIsar, MaintenanceIsar, QFilterCondition> {}

extension MaintenanceIsarQueryLinks
    on QueryBuilder<MaintenanceIsar, MaintenanceIsar, QFilterCondition> {}

extension MaintenanceIsarQuerySortBy
    on QueryBuilder<MaintenanceIsar, MaintenanceIsar, QSortBy> {
  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy> sortByAssetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetId', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByAssetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetId', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByAssetName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetName', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByAssetNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetName', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionDate', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionDate', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy> sortByCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cost', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cost', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByMaintenanceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceId', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByMaintenanceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceId', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByPerformedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedBy', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByPerformedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedBy', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByScheduledDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension MaintenanceIsarQuerySortThenBy
    on QueryBuilder<MaintenanceIsar, MaintenanceIsar, QSortThenBy> {
  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy> thenByAssetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetId', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByAssetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetId', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByAssetName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetName', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByAssetNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetName', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionDate', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionDate', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy> thenByCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cost', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cost', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByMaintenanceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceId', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByMaintenanceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maintenanceId', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByPerformedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedBy', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByPerformedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'performedBy', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByScheduledDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledDate', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension MaintenanceIsarQueryWhereDistinct
    on QueryBuilder<MaintenanceIsar, MaintenanceIsar, QDistinct> {
  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QDistinct> distinctByAssetId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QDistinct> distinctByAssetName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QDistinct>
      distinctByCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completionDate');
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QDistinct> distinctByCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cost');
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QDistinct>
      distinctByMaintenanceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maintenanceId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QDistinct>
      distinctByPerformedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'performedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QDistinct>
      distinctByScheduledDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledDate');
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceIsar, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension MaintenanceIsarQueryProperty
    on QueryBuilder<MaintenanceIsar, MaintenanceIsar, QQueryProperty> {
  QueryBuilder<MaintenanceIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MaintenanceIsar, String, QQueryOperations> assetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetId');
    });
  }

  QueryBuilder<MaintenanceIsar, String, QQueryOperations> assetNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetName');
    });
  }

  QueryBuilder<MaintenanceIsar, DateTime?, QQueryOperations>
      completionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completionDate');
    });
  }

  QueryBuilder<MaintenanceIsar, double, QQueryOperations> costProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cost');
    });
  }

  QueryBuilder<MaintenanceIsar, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<MaintenanceIsar, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<MaintenanceIsar, String, QQueryOperations>
      maintenanceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maintenanceId');
    });
  }

  QueryBuilder<MaintenanceIsar, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<MaintenanceIsar, String?, QQueryOperations>
      performedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'performedBy');
    });
  }

  QueryBuilder<MaintenanceIsar, DateTime, QQueryOperations>
      scheduledDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledDate');
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<MaintenanceIsar, MaintenanceType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
