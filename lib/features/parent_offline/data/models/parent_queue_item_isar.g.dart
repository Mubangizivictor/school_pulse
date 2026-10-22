// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_queue_item_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetParentQueueItemIsarCollection on Isar {
  IsarCollection<ParentQueueItemIsar> get parentQueueItemIsars =>
      this.collection();
}

const ParentQueueItemIsarSchema = CollectionSchema(
  name: r'ParentQueueItemIsar',
  id: -5407304707700485245,
  properties: {
    r'actionType': PropertySchema(
      id: 0,
      name: r'actionType',
      type: IsarType.byte,
      enumMap: _ParentQueueItemIsaractionTypeEnumValueMap,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'idempotencyKey': PropertySchema(
      id: 2,
      name: r'idempotencyKey',
      type: IsarType.string,
    ),
    r'lastError': PropertySchema(
      id: 3,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'learnerId': PropertySchema(
      id: 4,
      name: r'learnerId',
      type: IsarType.string,
    ),
    r'parentId': PropertySchema(
      id: 5,
      name: r'parentId',
      type: IsarType.string,
    ),
    r'payloadJson': PropertySchema(
      id: 6,
      name: r'payloadJson',
      type: IsarType.string,
    ),
    r'payloadVersion': PropertySchema(
      id: 7,
      name: r'payloadVersion',
      type: IsarType.long,
    ),
    r'retryCount': PropertySchema(
      id: 8,
      name: r'retryCount',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 9,
      name: r'status',
      type: IsarType.byte,
      enumMap: _ParentQueueItemIsarstatusEnumValueMap,
    ),
    r'tenantId': PropertySchema(
      id: 10,
      name: r'tenantId',
      type: IsarType.string,
    ),
  },
  estimateSize: _parentQueueItemIsarEstimateSize,
  serialize: _parentQueueItemIsarSerialize,
  deserialize: _parentQueueItemIsarDeserialize,
  deserializeProp: _parentQueueItemIsarDeserializeProp,
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
  },
  links: {},
  embeddedSchemas: {},
  getId: _parentQueueItemIsarGetId,
  getLinks: _parentQueueItemIsarGetLinks,
  attach: _parentQueueItemIsarAttach,
  version: '3.1.0+1',
);

int _parentQueueItemIsarEstimateSize(
  ParentQueueItemIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.idempotencyKey.length * 3;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.learnerId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.parentId.length * 3;
  bytesCount += 3 + object.payloadJson.length * 3;
  bytesCount += 3 + object.tenantId.length * 3;
  return bytesCount;
}

void _parentQueueItemIsarSerialize(
  ParentQueueItemIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeByte(offsets[0], object.actionType.index);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.idempotencyKey);
  writer.writeString(offsets[3], object.lastError);
  writer.writeString(offsets[4], object.learnerId);
  writer.writeString(offsets[5], object.parentId);
  writer.writeString(offsets[6], object.payloadJson);
  writer.writeLong(offsets[7], object.payloadVersion);
  writer.writeLong(offsets[8], object.retryCount);
  writer.writeByte(offsets[9], object.status.index);
  writer.writeString(offsets[10], object.tenantId);
}

ParentQueueItemIsar _parentQueueItemIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ParentQueueItemIsar();
  object.actionType =
      _ParentQueueItemIsaractionTypeValueEnumMap[reader.readByteOrNull(
        offsets[0],
      )] ??
      ParentQueueActionType.markMessageRead;
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.idempotencyKey = reader.readString(offsets[2]);
  object.lastError = reader.readStringOrNull(offsets[3]);
  object.learnerId = reader.readStringOrNull(offsets[4]);
  object.parentId = reader.readString(offsets[5]);
  object.payloadJson = reader.readString(offsets[6]);
  object.payloadVersion = reader.readLong(offsets[7]);
  object.retryCount = reader.readLong(offsets[8]);
  object.status =
      _ParentQueueItemIsarstatusValueEnumMap[reader.readByteOrNull(
        offsets[9],
      )] ??
      ParentQueueStatus.pending;
  object.tenantId = reader.readString(offsets[10]);
  return object;
}

P _parentQueueItemIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_ParentQueueItemIsaractionTypeValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              ParentQueueActionType.markMessageRead)
          as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (_ParentQueueItemIsarstatusValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              ParentQueueStatus.pending)
          as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ParentQueueItemIsaractionTypeEnumValueMap = {
  'markMessageRead': 0,
  'markAnnouncementRead': 1,
  'acknowledgement': 2,
  'saveMessageDraft': 3,
  'absenceRequest': 4,
  'appointmentRequest': 5,
  'appointmentCancellation': 6,
  'contactPreferenceUpdate': 7,
  'notificationPreferenceUpdate': 8,
  'externalPaymentReference': 9,
};
const _ParentQueueItemIsaractionTypeValueEnumMap = {
  0: ParentQueueActionType.markMessageRead,
  1: ParentQueueActionType.markAnnouncementRead,
  2: ParentQueueActionType.acknowledgement,
  3: ParentQueueActionType.saveMessageDraft,
  4: ParentQueueActionType.absenceRequest,
  5: ParentQueueActionType.appointmentRequest,
  6: ParentQueueActionType.appointmentCancellation,
  7: ParentQueueActionType.contactPreferenceUpdate,
  8: ParentQueueActionType.notificationPreferenceUpdate,
  9: ParentQueueActionType.externalPaymentReference,
};
const _ParentQueueItemIsarstatusEnumValueMap = {
  'pending': 0,
  'syncing': 1,
  'failed': 2,
  'done': 3,
};
const _ParentQueueItemIsarstatusValueEnumMap = {
  0: ParentQueueStatus.pending,
  1: ParentQueueStatus.syncing,
  2: ParentQueueStatus.failed,
  3: ParentQueueStatus.done,
};

Id _parentQueueItemIsarGetId(ParentQueueItemIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _parentQueueItemIsarGetLinks(
  ParentQueueItemIsar object,
) {
  return [];
}

void _parentQueueItemIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  ParentQueueItemIsar object,
) {
  object.id = id;
}

extension ParentQueueItemIsarByIndex on IsarCollection<ParentQueueItemIsar> {
  Future<ParentQueueItemIsar?> getByIdempotencyKey(String idempotencyKey) {
    return getByIndex(r'idempotencyKey', [idempotencyKey]);
  }

  ParentQueueItemIsar? getByIdempotencyKeySync(String idempotencyKey) {
    return getByIndexSync(r'idempotencyKey', [idempotencyKey]);
  }

  Future<bool> deleteByIdempotencyKey(String idempotencyKey) {
    return deleteByIndex(r'idempotencyKey', [idempotencyKey]);
  }

  bool deleteByIdempotencyKeySync(String idempotencyKey) {
    return deleteByIndexSync(r'idempotencyKey', [idempotencyKey]);
  }

  Future<List<ParentQueueItemIsar?>> getAllByIdempotencyKey(
    List<String> idempotencyKeyValues,
  ) {
    final values = idempotencyKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'idempotencyKey', values);
  }

  List<ParentQueueItemIsar?> getAllByIdempotencyKeySync(
    List<String> idempotencyKeyValues,
  ) {
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

  Future<Id> putByIdempotencyKey(ParentQueueItemIsar object) {
    return putByIndex(r'idempotencyKey', object);
  }

  Id putByIdempotencyKeySync(
    ParentQueueItemIsar object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'idempotencyKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByIdempotencyKey(List<ParentQueueItemIsar> objects) {
    return putAllByIndex(r'idempotencyKey', objects);
  }

  List<Id> putAllByIdempotencyKeySync(
    List<ParentQueueItemIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'idempotencyKey', objects, saveLinks: saveLinks);
  }
}

extension ParentQueueItemIsarQueryWhereSort
    on QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QWhere> {
  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ParentQueueItemIsarQueryWhere
    on QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QWhereClause> {
  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterWhereClause>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterWhereClause>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterWhereClause>
  idempotencyKeyEqualTo(String idempotencyKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'idempotencyKey',
          value: [idempotencyKey],
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterWhereClause>
  idempotencyKeyNotEqualTo(String idempotencyKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'idempotencyKey',
                lower: [],
                upper: [idempotencyKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'idempotencyKey',
                lower: [idempotencyKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'idempotencyKey',
                lower: [idempotencyKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'idempotencyKey',
                lower: [],
                upper: [idempotencyKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterWhereClause>
  tenantIdEqualTo(String tenantId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'tenantId', value: [tenantId]),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterWhereClause>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterWhereClause>
  parentIdEqualTo(String parentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'parentId', value: [parentId]),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterWhereClause>
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
}

extension ParentQueueItemIsarQueryFilter
    on
        QueryBuilder<
          ParentQueueItemIsar,
          ParentQueueItemIsar,
          QFilterCondition
        > {
  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  actionTypeEqualTo(ParentQueueActionType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'actionType', value: value),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  actionTypeGreaterThan(ParentQueueActionType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'actionType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  actionTypeLessThan(ParentQueueActionType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'actionType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  actionTypeBetween(
    ParentQueueActionType lower,
    ParentQueueActionType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'actionType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  idempotencyKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'idempotencyKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  idempotencyKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'idempotencyKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  idempotencyKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'idempotencyKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  idempotencyKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'idempotencyKey',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  idempotencyKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'idempotencyKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  idempotencyKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'idempotencyKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  idempotencyKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'idempotencyKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  idempotencyKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'idempotencyKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  idempotencyKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'idempotencyKey', value: ''),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  idempotencyKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'idempotencyKey', value: ''),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastError'),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastError'),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  lastErrorEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastError',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  lastErrorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  lastErrorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lastError',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lastError',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastError', value: ''),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lastError', value: ''),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  learnerIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'learnerId'),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  learnerIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'learnerId'),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  learnerIdEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  learnerIdGreaterThan(
    String? value, {
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  learnerIdLessThan(
    String? value, {
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  learnerIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  learnerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'learnerId', value: ''),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  learnerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'learnerId', value: ''),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  parentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'parentId', value: ''),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  parentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'parentId', value: ''),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  payloadJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payloadJson', value: ''),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  payloadJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'payloadJson', value: ''),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  payloadVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'payloadVersion', value: value),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  payloadVersionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'payloadVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  payloadVersionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'payloadVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  payloadVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'payloadVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  retryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'retryCount', value: value),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  retryCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'retryCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  retryCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'retryCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  retryCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'retryCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  statusEqualTo(ParentQueueStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  statusGreaterThan(ParentQueueStatus value, {bool include = false}) {
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  statusLessThan(ParentQueueStatus value, {bool include = false}) {
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  statusBetween(
    ParentQueueStatus lower,
    ParentQueueStatus upper, {
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
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

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  tenantIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tenantId', value: ''),
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterFilterCondition>
  tenantIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tenantId', value: ''),
      );
    });
  }
}

extension ParentQueueItemIsarQueryObject
    on
        QueryBuilder<
          ParentQueueItemIsar,
          ParentQueueItemIsar,
          QFilterCondition
        > {}

extension ParentQueueItemIsarQueryLinks
    on
        QueryBuilder<
          ParentQueueItemIsar,
          ParentQueueItemIsar,
          QFilterCondition
        > {}

extension ParentQueueItemIsarQuerySortBy
    on QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QSortBy> {
  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByActionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByIdempotencyKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idempotencyKey', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByIdempotencyKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idempotencyKey', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByLearnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnerId', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByLearnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnerId', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByPayloadJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByPayloadJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByPayloadVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadVersion', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByPayloadVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadVersion', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  sortByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }
}

extension ParentQueueItemIsarQuerySortThenBy
    on QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QSortThenBy> {
  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByActionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByIdempotencyKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idempotencyKey', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByIdempotencyKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idempotencyKey', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByLearnerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnerId', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByLearnerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'learnerId', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentId', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByPayloadJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByPayloadJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByPayloadVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadVersion', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByPayloadVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadVersion', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QAfterSortBy>
  thenByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }
}

extension ParentQueueItemIsarQueryWhereDistinct
    on QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QDistinct> {
  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QDistinct>
  distinctByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionType');
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QDistinct>
  distinctByIdempotencyKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'idempotencyKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QDistinct>
  distinctByLastError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QDistinct>
  distinctByLearnerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'learnerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QDistinct>
  distinctByParentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QDistinct>
  distinctByPayloadJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payloadJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QDistinct>
  distinctByPayloadVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payloadVersion');
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QDistinct>
  distinctByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryCount');
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QDistinct>
  distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QDistinct>
  distinctByTenantId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tenantId', caseSensitive: caseSensitive);
    });
  }
}

extension ParentQueueItemIsarQueryProperty
    on QueryBuilder<ParentQueueItemIsar, ParentQueueItemIsar, QQueryProperty> {
  QueryBuilder<ParentQueueItemIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueActionType, QQueryOperations>
  actionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionType');
    });
  }

  QueryBuilder<ParentQueueItemIsar, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ParentQueueItemIsar, String, QQueryOperations>
  idempotencyKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idempotencyKey');
    });
  }

  QueryBuilder<ParentQueueItemIsar, String?, QQueryOperations>
  lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<ParentQueueItemIsar, String?, QQueryOperations>
  learnerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'learnerId');
    });
  }

  QueryBuilder<ParentQueueItemIsar, String, QQueryOperations>
  parentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentId');
    });
  }

  QueryBuilder<ParentQueueItemIsar, String, QQueryOperations>
  payloadJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payloadJson');
    });
  }

  QueryBuilder<ParentQueueItemIsar, int, QQueryOperations>
  payloadVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payloadVersion');
    });
  }

  QueryBuilder<ParentQueueItemIsar, int, QQueryOperations>
  retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryCount');
    });
  }

  QueryBuilder<ParentQueueItemIsar, ParentQueueStatus, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<ParentQueueItemIsar, String, QQueryOperations>
  tenantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tenantId');
    });
  }
}
