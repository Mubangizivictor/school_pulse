// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_attendance_queue_item_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStaffAttendanceQueueItemIsarCollection on Isar {
  IsarCollection<StaffAttendanceQueueItemIsar>
      get staffAttendanceQueueItemIsars => this.collection();
}

const StaffAttendanceQueueItemIsarSchema = CollectionSchema(
  name: r'StaffAttendanceQueueItemIsar',
  id: -7099520975372441599,
  properties: {
    r'actionType': PropertySchema(
      id: 0,
      name: r'actionType',
      type: IsarType.byte,
      enumMap: _StaffAttendanceQueueItemIsaractionTypeEnumValueMap,
    ),
    r'actorId': PropertySchema(
      id: 1,
      name: r'actorId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'idempotencyKey': PropertySchema(
      id: 3,
      name: r'idempotencyKey',
      type: IsarType.string,
    ),
    r'institutionId': PropertySchema(
      id: 4,
      name: r'institutionId',
      type: IsarType.string,
    ),
    r'lastError': PropertySchema(
      id: 5,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'payloadJson': PropertySchema(
      id: 6,
      name: r'payloadJson',
      type: IsarType.string,
    ),
    r'retryCount': PropertySchema(
      id: 7,
      name: r'retryCount',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 8,
      name: r'status',
      type: IsarType.byte,
      enumMap: _StaffAttendanceQueueItemIsarstatusEnumValueMap,
    )
  },
  estimateSize: _staffAttendanceQueueItemIsarEstimateSize,
  serialize: _staffAttendanceQueueItemIsarSerialize,
  deserialize: _staffAttendanceQueueItemIsarDeserialize,
  deserializeProp: _staffAttendanceQueueItemIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'idempotencyKey': IndexSchema(
      id: 6522471565226449816,
      name: r'idempotencyKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'idempotencyKey',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'institutionId': IndexSchema(
      id: 7372116058319502336,
      name: r'institutionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'institutionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'actorId': IndexSchema(
      id: 8635083428367205428,
      name: r'actorId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'actorId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _staffAttendanceQueueItemIsarGetId,
  getLinks: _staffAttendanceQueueItemIsarGetLinks,
  attach: _staffAttendanceQueueItemIsarAttach,
  version: '3.1.0+1',
);

int _staffAttendanceQueueItemIsarEstimateSize(
  StaffAttendanceQueueItemIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.actorId.length * 3;
  bytesCount += 3 + object.idempotencyKey.length * 3;
  bytesCount += 3 + object.institutionId.length * 3;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.payloadJson.length * 3;
  return bytesCount;
}

void _staffAttendanceQueueItemIsarSerialize(
  StaffAttendanceQueueItemIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.actionType.index);
  writer.writeString(offsets[1], object.actorId);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.idempotencyKey);
  writer.writeString(offsets[4], object.institutionId);
  writer.writeString(offsets[5], object.lastError);
  writer.writeString(offsets[6], object.payloadJson);
  writer.writeLong(offsets[7], object.retryCount);
  writer.writeByte(offsets[8], object.status.index);
}

StaffAttendanceQueueItemIsar _staffAttendanceQueueItemIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StaffAttendanceQueueItemIsar();
  object.actionType = _StaffAttendanceQueueItemIsaractionTypeValueEnumMap[
          reader.readByteOrNull(offsets[0])] ??
      StaffAttendanceQueueActionType.clockIn;
  object.actorId = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.id = id;
  object.idempotencyKey = reader.readString(offsets[3]);
  object.institutionId = reader.readString(offsets[4]);
  object.lastError = reader.readStringOrNull(offsets[5]);
  object.payloadJson = reader.readString(offsets[6]);
  object.retryCount = reader.readLong(offsets[7]);
  object.status = _StaffAttendanceQueueItemIsarstatusValueEnumMap[
          reader.readByteOrNull(offsets[8])] ??
      StaffAttendanceQueueStatus.pending;
  return object;
}

P _staffAttendanceQueueItemIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_StaffAttendanceQueueItemIsaractionTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          StaffAttendanceQueueActionType.clockIn) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (_StaffAttendanceQueueItemIsarstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          StaffAttendanceQueueStatus.pending) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _StaffAttendanceQueueItemIsaractionTypeEnumValueMap = {
  'clockIn': 0,
  'correction': 1,
};
const _StaffAttendanceQueueItemIsaractionTypeValueEnumMap = {
  0: StaffAttendanceQueueActionType.clockIn,
  1: StaffAttendanceQueueActionType.correction,
};
const _StaffAttendanceQueueItemIsarstatusEnumValueMap = {
  'pending': 0,
  'syncing': 1,
  'failed': 2,
  'done': 3,
};
const _StaffAttendanceQueueItemIsarstatusValueEnumMap = {
  0: StaffAttendanceQueueStatus.pending,
  1: StaffAttendanceQueueStatus.syncing,
  2: StaffAttendanceQueueStatus.failed,
  3: StaffAttendanceQueueStatus.done,
};

Id _staffAttendanceQueueItemIsarGetId(StaffAttendanceQueueItemIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _staffAttendanceQueueItemIsarGetLinks(
    StaffAttendanceQueueItemIsar object) {
  return [];
}

void _staffAttendanceQueueItemIsarAttach(
    IsarCollection<dynamic> col, Id id, StaffAttendanceQueueItemIsar object) {
  object.id = id;
}

extension StaffAttendanceQueueItemIsarByIndex
    on IsarCollection<StaffAttendanceQueueItemIsar> {
  Future<StaffAttendanceQueueItemIsar?> getByIdempotencyKey(
      String idempotencyKey) {
    return getByIndex(r'idempotencyKey', [idempotencyKey]);
  }

  StaffAttendanceQueueItemIsar? getByIdempotencyKeySync(String idempotencyKey) {
    return getByIndexSync(r'idempotencyKey', [idempotencyKey]);
  }

  Future<bool> deleteByIdempotencyKey(String idempotencyKey) {
    return deleteByIndex(r'idempotencyKey', [idempotencyKey]);
  }

  bool deleteByIdempotencyKeySync(String idempotencyKey) {
    return deleteByIndexSync(r'idempotencyKey', [idempotencyKey]);
  }

  Future<List<StaffAttendanceQueueItemIsar?>> getAllByIdempotencyKey(
      List<String> idempotencyKeyValues) {
    final values = idempotencyKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'idempotencyKey', values);
  }

  List<StaffAttendanceQueueItemIsar?> getAllByIdempotencyKeySync(
      List<String> idempotencyKeyValues) {
    final values = idempotencyKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'idempotencyKey', values);
  }

  Future<int> deleteAllByIdempotencyKey(List<String> idempotencyKeyValues) {
    final values = idempotencyKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'idempotencyKey', values);
  }

  int deleteAllByIdempotencyKeySync(List<String> idempotencyKeyValues) {
    final values = idempotencyKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'idempotencyKey', values);
  }

  Future<Id> putByIdempotencyKey(StaffAttendanceQueueItemIsar object) {
    return putByIndex(r'idempotencyKey', object);
  }

  Id putByIdempotencyKeySync(StaffAttendanceQueueItemIsar object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'idempotencyKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByIdempotencyKey(
      List<StaffAttendanceQueueItemIsar> objects) {
    return putAllByIndex(r'idempotencyKey', objects);
  }

  List<Id> putAllByIdempotencyKeySync(
      List<StaffAttendanceQueueItemIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'idempotencyKey', objects, saveLinks: saveLinks);
  }
}

extension StaffAttendanceQueueItemIsarQueryWhereSort on QueryBuilder<
    StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar, QWhere> {
  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StaffAttendanceQueueItemIsarQueryWhere on QueryBuilder<
    StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar, QWhereClause> {
  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
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

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
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

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterWhereClause> idempotencyKeyEqualTo(String idempotencyKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idempotencyKey',
        value: [idempotencyKey],
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterWhereClause> idempotencyKeyNotEqualTo(String idempotencyKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idempotencyKey',
              lower: [],
              upper: [idempotencyKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idempotencyKey',
              lower: [idempotencyKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idempotencyKey',
              lower: [idempotencyKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idempotencyKey',
              lower: [],
              upper: [idempotencyKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterWhereClause> institutionIdEqualTo(String institutionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'institutionId',
        value: [institutionId],
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterWhereClause> institutionIdNotEqualTo(String institutionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'institutionId',
              lower: [],
              upper: [institutionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'institutionId',
              lower: [institutionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'institutionId',
              lower: [institutionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'institutionId',
              lower: [],
              upper: [institutionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterWhereClause> actorIdEqualTo(String actorId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'actorId',
        value: [actorId],
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterWhereClause> actorIdNotEqualTo(String actorId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'actorId',
              lower: [],
              upper: [actorId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'actorId',
              lower: [actorId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'actorId',
              lower: [actorId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'actorId',
              lower: [],
              upper: [actorId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension StaffAttendanceQueueItemIsarQueryFilter on QueryBuilder<
    StaffAttendanceQueueItemIsar,
    StaffAttendanceQueueItemIsar,
    QFilterCondition> {
  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
          QAfterFilterCondition>
      actionTypeEqualTo(StaffAttendanceQueueActionType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionType',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> actionTypeGreaterThan(
    StaffAttendanceQueueActionType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actionType',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> actionTypeLessThan(
    StaffAttendanceQueueActionType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actionType',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> actionTypeBetween(
    StaffAttendanceQueueActionType lower,
    StaffAttendanceQueueActionType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actionType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> actorIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> actorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> actorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> actorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> actorIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> actorIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
          QAfterFilterCondition>
      actorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
          QAfterFilterCondition>
      actorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> actorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actorId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> actorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actorId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
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

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
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

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
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

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> idempotencyKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idempotencyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> idempotencyKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idempotencyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> idempotencyKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idempotencyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> idempotencyKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idempotencyKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> idempotencyKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'idempotencyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> idempotencyKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'idempotencyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
          QAfterFilterCondition>
      idempotencyKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'idempotencyKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
          QAfterFilterCondition>
      idempotencyKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'idempotencyKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> idempotencyKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idempotencyKey',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> idempotencyKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'idempotencyKey',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> institutionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'institutionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> institutionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'institutionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> institutionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'institutionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> institutionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'institutionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> institutionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'institutionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> institutionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'institutionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
          QAfterFilterCondition>
      institutionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'institutionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
          QAfterFilterCondition>
      institutionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'institutionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> institutionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'institutionId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> institutionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'institutionId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> lastErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> lastErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> lastErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
          QAfterFilterCondition>
      lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
          QAfterFilterCondition>
      lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> payloadJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payloadJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> payloadJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'payloadJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> payloadJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'payloadJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> payloadJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'payloadJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> payloadJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'payloadJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> payloadJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'payloadJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
          QAfterFilterCondition>
      payloadJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'payloadJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
          QAfterFilterCondition>
      payloadJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'payloadJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> payloadJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payloadJson',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> payloadJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'payloadJson',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> retryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> retryCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> retryCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> retryCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'retryCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> statusEqualTo(StaffAttendanceQueueStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> statusGreaterThan(
    StaffAttendanceQueueStatus value, {
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

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> statusLessThan(
    StaffAttendanceQueueStatus value, {
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

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterFilterCondition> statusBetween(
    StaffAttendanceQueueStatus lower,
    StaffAttendanceQueueStatus upper, {
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
}

extension StaffAttendanceQueueItemIsarQueryObject on QueryBuilder<
    StaffAttendanceQueueItemIsar,
    StaffAttendanceQueueItemIsar,
    QFilterCondition> {}

extension StaffAttendanceQueueItemIsarQueryLinks on QueryBuilder<
    StaffAttendanceQueueItemIsar,
    StaffAttendanceQueueItemIsar,
    QFilterCondition> {}

extension StaffAttendanceQueueItemIsarQuerySortBy on QueryBuilder<
    StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar, QSortBy> {
  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByActionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByIdempotencyKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idempotencyKey', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByIdempotencyKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idempotencyKey', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByInstitutionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institutionId', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByInstitutionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institutionId', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByPayloadJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByPayloadJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension StaffAttendanceQueueItemIsarQuerySortThenBy on QueryBuilder<
    StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar, QSortThenBy> {
  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByActionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByIdempotencyKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idempotencyKey', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByIdempotencyKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idempotencyKey', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByInstitutionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institutionId', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByInstitutionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institutionId', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByPayloadJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByPayloadJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension StaffAttendanceQueueItemIsarQueryWhereDistinct on QueryBuilder<
    StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar, QDistinct> {
  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QDistinct> distinctByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionType');
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QDistinct> distinctByActorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actorId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QDistinct> distinctByIdempotencyKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idempotencyKey',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QDistinct> distinctByInstitutionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'institutionId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QDistinct> distinctByLastError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QDistinct> distinctByPayloadJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payloadJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QDistinct> distinctByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryCount');
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueItemIsar,
      QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }
}

extension StaffAttendanceQueueItemIsarQueryProperty on QueryBuilder<
    StaffAttendanceQueueItemIsar,
    StaffAttendanceQueueItemIsar,
    QQueryProperty> {
  QueryBuilder<StaffAttendanceQueueItemIsar, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueActionType,
      QQueryOperations> actionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionType');
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, String, QQueryOperations>
      actorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actorId');
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, String, QQueryOperations>
      idempotencyKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idempotencyKey');
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, String, QQueryOperations>
      institutionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'institutionId');
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, String?, QQueryOperations>
      lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, String, QQueryOperations>
      payloadJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payloadJson');
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, int, QQueryOperations>
      retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryCount');
    });
  }

  QueryBuilder<StaffAttendanceQueueItemIsar, StaffAttendanceQueueStatus,
      QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
