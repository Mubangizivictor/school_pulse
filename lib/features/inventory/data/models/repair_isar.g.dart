// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRepairIsarCollection on Isar {
  IsarCollection<RepairIsar> get repairIsars => this.collection();
}

const RepairIsarSchema = CollectionSchema(
  name: r'RepairIsar',
  id: 2436990566170988935,
  properties: {
    r'actualCost': PropertySchema(
      id: 0,
      name: r'actualCost',
      type: IsarType.double,
    ),
    r'afterPhotoUrl': PropertySchema(
      id: 1,
      name: r'afterPhotoUrl',
      type: IsarType.string,
    ),
    r'assetId': PropertySchema(id: 2, name: r'assetId', type: IsarType.string),
    r'assetName': PropertySchema(
      id: 3,
      name: r'assetName',
      type: IsarType.string,
    ),
    r'beforePhotoUrl': PropertySchema(
      id: 4,
      name: r'beforePhotoUrl',
      type: IsarType.string,
    ),
    r'completionDate': PropertySchema(
      id: 5,
      name: r'completionDate',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 6,
      name: r'description',
      type: IsarType.string,
    ),
    r'estimatedCost': PropertySchema(
      id: 7,
      name: r'estimatedCost',
      type: IsarType.double,
    ),
    r'isSynced': PropertySchema(id: 8, name: r'isSynced', type: IsarType.bool),
    r'notes': PropertySchema(id: 9, name: r'notes', type: IsarType.string),
    r'partsUsed': PropertySchema(
      id: 10,
      name: r'partsUsed',
      type: IsarType.stringList,
    ),
    r'repairId': PropertySchema(
      id: 11,
      name: r'repairId',
      type: IsarType.string,
    ),
    r'requestDate': PropertySchema(
      id: 12,
      name: r'requestDate',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 13,
      name: r'status',
      type: IsarType.byte,
      enumMap: _RepairIsarstatusEnumValueMap,
    ),
    r'technicianName': PropertySchema(
      id: 14,
      name: r'technicianName',
      type: IsarType.string,
    ),
  },
  estimateSize: _repairIsarEstimateSize,
  serialize: _repairIsarSerialize,
  deserialize: _repairIsarDeserialize,
  deserializeProp: _repairIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'repairId': IndexSchema(
      id: 5539083612788839883,
      name: r'repairId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'repairId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _repairIsarGetId,
  getLinks: _repairIsarGetLinks,
  attach: _repairIsarAttach,
  version: '3.1.0+1',
);

int _repairIsarEstimateSize(
  RepairIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.afterPhotoUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.assetId.length * 3;
  bytesCount += 3 + object.assetName.length * 3;
  {
    final value = object.beforePhotoUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.description.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.partsUsed.length * 3;
  {
    for (var i = 0; i < object.partsUsed.length; i++) {
      final value = object.partsUsed[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.repairId.length * 3;
  {
    final value = object.technicianName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _repairIsarSerialize(
  RepairIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.actualCost);
  writer.writeString(offsets[1], object.afterPhotoUrl);
  writer.writeString(offsets[2], object.assetId);
  writer.writeString(offsets[3], object.assetName);
  writer.writeString(offsets[4], object.beforePhotoUrl);
  writer.writeDateTime(offsets[5], object.completionDate);
  writer.writeString(offsets[6], object.description);
  writer.writeDouble(offsets[7], object.estimatedCost);
  writer.writeBool(offsets[8], object.isSynced);
  writer.writeString(offsets[9], object.notes);
  writer.writeStringList(offsets[10], object.partsUsed);
  writer.writeString(offsets[11], object.repairId);
  writer.writeDateTime(offsets[12], object.requestDate);
  writer.writeByte(offsets[13], object.status.index);
  writer.writeString(offsets[14], object.technicianName);
}

RepairIsar _repairIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RepairIsar();
  object.actualCost = reader.readDouble(offsets[0]);
  object.afterPhotoUrl = reader.readStringOrNull(offsets[1]);
  object.assetId = reader.readString(offsets[2]);
  object.assetName = reader.readString(offsets[3]);
  object.beforePhotoUrl = reader.readStringOrNull(offsets[4]);
  object.completionDate = reader.readDateTimeOrNull(offsets[5]);
  object.description = reader.readString(offsets[6]);
  object.estimatedCost = reader.readDouble(offsets[7]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[8]);
  object.notes = reader.readStringOrNull(offsets[9]);
  object.partsUsed = reader.readStringList(offsets[10]) ?? [];
  object.repairId = reader.readString(offsets[11]);
  object.requestDate = reader.readDateTime(offsets[12]);
  object.status =
      _RepairIsarstatusValueEnumMap[reader.readByteOrNull(offsets[13])] ??
      RepairStatus.pending;
  object.technicianName = reader.readStringOrNull(offsets[14]);
  return object;
}

P _repairIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (_RepairIsarstatusValueEnumMap[reader.readByteOrNull(offset)] ??
              RepairStatus.pending)
          as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RepairIsarstatusEnumValueMap = {
  'pending': 0,
  'approved': 1,
  'inProgress': 2,
  'completed': 3,
  'cancelled': 4,
};
const _RepairIsarstatusValueEnumMap = {
  0: RepairStatus.pending,
  1: RepairStatus.approved,
  2: RepairStatus.inProgress,
  3: RepairStatus.completed,
  4: RepairStatus.cancelled,
};

Id _repairIsarGetId(RepairIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _repairIsarGetLinks(RepairIsar object) {
  return [];
}

void _repairIsarAttach(IsarCollection<dynamic> col, Id id, RepairIsar object) {
  object.id = id;
}

extension RepairIsarByIndex on IsarCollection<RepairIsar> {
  Future<RepairIsar?> getByRepairId(String repairId) {
    return getByIndex(r'repairId', [repairId]);
  }

  RepairIsar? getByRepairIdSync(String repairId) {
    return getByIndexSync(r'repairId', [repairId]);
  }

  Future<bool> deleteByRepairId(String repairId) {
    return deleteByIndex(r'repairId', [repairId]);
  }

  bool deleteByRepairIdSync(String repairId) {
    return deleteByIndexSync(r'repairId', [repairId]);
  }

  Future<List<RepairIsar?>> getAllByRepairId(List<String> repairIdValues) {
    final values = repairIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'repairId', values);
  }

  List<RepairIsar?> getAllByRepairIdSync(List<String> repairIdValues) {
    final values = repairIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'repairId', values);
  }

  Future<int> deleteAllByRepairId(List<String> repairIdValues) {
    final values = repairIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'repairId', values);
  }

  int deleteAllByRepairIdSync(List<String> repairIdValues) {
    final values = repairIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'repairId', values);
  }

  Future<Id> putByRepairId(RepairIsar object) {
    return putByIndex(r'repairId', object);
  }

  Id putByRepairIdSync(RepairIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'repairId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRepairId(List<RepairIsar> objects) {
    return putAllByIndex(r'repairId', objects);
  }

  List<Id> putAllByRepairIdSync(
    List<RepairIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'repairId', objects, saveLinks: saveLinks);
  }
}

extension RepairIsarQueryWhereSort
    on QueryBuilder<RepairIsar, RepairIsar, QWhere> {
  QueryBuilder<RepairIsar, RepairIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RepairIsarQueryWhere
    on QueryBuilder<RepairIsar, RepairIsar, QWhereClause> {
  QueryBuilder<RepairIsar, RepairIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterWhereClause> repairIdEqualTo(
    String repairId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'repairId', value: [repairId]),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterWhereClause> repairIdNotEqualTo(
    String repairId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'repairId',
                lower: [],
                upper: [repairId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'repairId',
                lower: [repairId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'repairId',
                lower: [repairId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'repairId',
                lower: [],
                upper: [repairId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension RepairIsarQueryFilter
    on QueryBuilder<RepairIsar, RepairIsar, QFilterCondition> {
  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> actualCostEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'actualCost',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  actualCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'actualCost',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  actualCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'actualCost',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> actualCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'actualCost',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  afterPhotoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'afterPhotoUrl'),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  afterPhotoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'afterPhotoUrl'),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  afterPhotoUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'afterPhotoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  afterPhotoUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'afterPhotoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  afterPhotoUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'afterPhotoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  afterPhotoUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'afterPhotoUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  afterPhotoUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'afterPhotoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  afterPhotoUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'afterPhotoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  afterPhotoUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'afterPhotoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  afterPhotoUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'afterPhotoUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  afterPhotoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'afterPhotoUrl', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  afterPhotoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'afterPhotoUrl', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> assetIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'assetId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  assetIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'assetId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> assetIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'assetId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> assetIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'assetId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> assetIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'assetId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> assetIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'assetId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> assetIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'assetId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> assetIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'assetId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> assetIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'assetId', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  assetIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'assetId', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> assetNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'assetName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  assetNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'assetName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> assetNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'assetName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> assetNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'assetName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  assetNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'assetName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> assetNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'assetName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> assetNameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'assetName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> assetNameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'assetName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  assetNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'assetName', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  assetNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'assetName', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  beforePhotoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'beforePhotoUrl'),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  beforePhotoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'beforePhotoUrl'),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  beforePhotoUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'beforePhotoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  beforePhotoUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'beforePhotoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  beforePhotoUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'beforePhotoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  beforePhotoUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'beforePhotoUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  beforePhotoUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'beforePhotoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  beforePhotoUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'beforePhotoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  beforePhotoUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'beforePhotoUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  beforePhotoUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'beforePhotoUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  beforePhotoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'beforePhotoUrl', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  beforePhotoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'beforePhotoUrl', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  completionDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'completionDate'),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  completionDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'completionDate'),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  completionDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completionDate', value: value),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  completionDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completionDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  completionDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completionDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  completionDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completionDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  descriptionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'description',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'description',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'description',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'description', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  estimatedCostEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'estimatedCost',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  estimatedCostGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'estimatedCost',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  estimatedCostLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'estimatedCost',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  estimatedCostBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'estimatedCost',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> isSyncedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isSynced', value: value),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'notes'),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> notesGreaterThan(
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> notesLessThan(
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> notesBetween(
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> notesContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> notesMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'notes', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'partsUsed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'partsUsed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'partsUsed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'partsUsed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'partsUsed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'partsUsed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'partsUsed',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'partsUsed',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'partsUsed', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'partsUsed', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'partsUsed', length, true, length, true);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'partsUsed', 0, true, 0, true);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'partsUsed', 0, false, 999999, true);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'partsUsed', 0, true, length, include);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'partsUsed', length, include, 999999, true);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  partsUsedLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'partsUsed',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> repairIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'repairId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  repairIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'repairId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> repairIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'repairId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> repairIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'repairId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  repairIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'repairId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> repairIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'repairId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> repairIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'repairId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> repairIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'repairId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  repairIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'repairId', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  repairIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'repairId', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  requestDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'requestDate', value: value),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  requestDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'requestDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  requestDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'requestDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  requestDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'requestDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> statusEqualTo(
    RepairStatus value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> statusGreaterThan(
    RepairStatus value, {
    bool include = false,
  }) {
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> statusLessThan(
    RepairStatus value, {
    bool include = false,
  }) {
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition> statusBetween(
    RepairStatus lower,
    RepairStatus upper, {
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

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  technicianNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'technicianName'),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  technicianNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'technicianName'),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  technicianNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'technicianName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  technicianNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'technicianName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  technicianNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'technicianName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  technicianNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'technicianName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  technicianNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'technicianName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  technicianNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'technicianName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  technicianNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'technicianName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  technicianNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'technicianName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  technicianNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'technicianName', value: ''),
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterFilterCondition>
  technicianNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'technicianName', value: ''),
      );
    });
  }
}

extension RepairIsarQueryObject
    on QueryBuilder<RepairIsar, RepairIsar, QFilterCondition> {}

extension RepairIsarQueryLinks
    on QueryBuilder<RepairIsar, RepairIsar, QFilterCondition> {}

extension RepairIsarQuerySortBy
    on QueryBuilder<RepairIsar, RepairIsar, QSortBy> {
  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByActualCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualCost', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByActualCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualCost', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByAfterPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterPhotoUrl', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByAfterPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterPhotoUrl', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByAssetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetId', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByAssetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetId', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByAssetName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetName', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByAssetNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetName', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByBeforePhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforePhotoUrl', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy>
  sortByBeforePhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforePhotoUrl', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionDate', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy>
  sortByCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionDate', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByEstimatedCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedCost', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByEstimatedCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedCost', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByRepairId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repairId', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByRepairIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repairId', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByRequestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestDate', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByRequestDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestDate', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> sortByTechnicianName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'technicianName', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy>
  sortByTechnicianNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'technicianName', Sort.desc);
    });
  }
}

extension RepairIsarQuerySortThenBy
    on QueryBuilder<RepairIsar, RepairIsar, QSortThenBy> {
  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByActualCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualCost', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByActualCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualCost', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByAfterPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterPhotoUrl', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByAfterPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'afterPhotoUrl', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByAssetId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetId', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByAssetIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetId', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByAssetName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetName', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByAssetNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assetName', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByBeforePhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforePhotoUrl', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy>
  thenByBeforePhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'beforePhotoUrl', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionDate', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy>
  thenByCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionDate', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByEstimatedCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedCost', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByEstimatedCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedCost', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByRepairId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repairId', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByRepairIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'repairId', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByRequestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestDate', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByRequestDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestDate', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy> thenByTechnicianName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'technicianName', Sort.asc);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QAfterSortBy>
  thenByTechnicianNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'technicianName', Sort.desc);
    });
  }
}

extension RepairIsarQueryWhereDistinct
    on QueryBuilder<RepairIsar, RepairIsar, QDistinct> {
  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByActualCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualCost');
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByAfterPhotoUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'afterPhotoUrl',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByAssetId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByAssetName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assetName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByBeforePhotoUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'beforePhotoUrl',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completionDate');
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByEstimatedCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estimatedCost');
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByNotes({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByPartsUsed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partsUsed');
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByRepairId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'repairId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByRequestDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestDate');
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<RepairIsar, RepairIsar, QDistinct> distinctByTechnicianName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'technicianName',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension RepairIsarQueryProperty
    on QueryBuilder<RepairIsar, RepairIsar, QQueryProperty> {
  QueryBuilder<RepairIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RepairIsar, double, QQueryOperations> actualCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualCost');
    });
  }

  QueryBuilder<RepairIsar, String?, QQueryOperations> afterPhotoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'afterPhotoUrl');
    });
  }

  QueryBuilder<RepairIsar, String, QQueryOperations> assetIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetId');
    });
  }

  QueryBuilder<RepairIsar, String, QQueryOperations> assetNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assetName');
    });
  }

  QueryBuilder<RepairIsar, String?, QQueryOperations> beforePhotoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'beforePhotoUrl');
    });
  }

  QueryBuilder<RepairIsar, DateTime?, QQueryOperations>
  completionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completionDate');
    });
  }

  QueryBuilder<RepairIsar, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<RepairIsar, double, QQueryOperations> estimatedCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estimatedCost');
    });
  }

  QueryBuilder<RepairIsar, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<RepairIsar, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<RepairIsar, List<String>, QQueryOperations> partsUsedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partsUsed');
    });
  }

  QueryBuilder<RepairIsar, String, QQueryOperations> repairIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'repairId');
    });
  }

  QueryBuilder<RepairIsar, DateTime, QQueryOperations> requestDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestDate');
    });
  }

  QueryBuilder<RepairIsar, RepairStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<RepairIsar, String?, QQueryOperations> technicianNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'technicianName');
    });
  }
}
