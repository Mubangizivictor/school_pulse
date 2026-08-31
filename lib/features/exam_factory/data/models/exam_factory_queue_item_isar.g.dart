// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_factory_queue_item_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetExamFactoryQueueItemIsarCollection on Isar {
  IsarCollection<ExamFactoryQueueItemIsar> get examFactoryQueueItemIsars =>
      this.collection();
}

const ExamFactoryQueueItemIsarSchema = CollectionSchema(
  name: r'ExamFactoryQueueItemIsar',
  id: -2734375256197878804,
  properties: {
    r'actionType': PropertySchema(
      id: 0,
      name: r'actionType',
      type: IsarType.byte,
      enumMap: _ExamFactoryQueueItemIsaractionTypeEnumValueMap,
    ),
    r'actorId': PropertySchema(id: 1, name: r'actorId', type: IsarType.string),
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
      enumMap: _ExamFactoryQueueItemIsarstatusEnumValueMap,
    ),
  },
  estimateSize: _examFactoryQueueItemIsarEstimateSize,
  serialize: _examFactoryQueueItemIsarSerialize,
  deserialize: _examFactoryQueueItemIsarDeserialize,
  deserializeProp: _examFactoryQueueItemIsarDeserializeProp,
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
        ),
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
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _examFactoryQueueItemIsarGetId,
  getLinks: _examFactoryQueueItemIsarGetLinks,
  attach: _examFactoryQueueItemIsarAttach,
  version: '3.1.0+1',
);

int _examFactoryQueueItemIsarEstimateSize(
  ExamFactoryQueueItemIsar object,
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

void _examFactoryQueueItemIsarSerialize(
  ExamFactoryQueueItemIsar object,
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

ExamFactoryQueueItemIsar _examFactoryQueueItemIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ExamFactoryQueueItemIsar();
  object.actionType =
      _ExamFactoryQueueItemIsaractionTypeValueEnumMap[reader.readByteOrNull(
        offsets[0],
      )] ??
      ExamFactoryQueueActionType.saveQuestionDraft;
  object.actorId = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.id = id;
  object.idempotencyKey = reader.readString(offsets[3]);
  object.institutionId = reader.readString(offsets[4]);
  object.lastError = reader.readStringOrNull(offsets[5]);
  object.payloadJson = reader.readString(offsets[6]);
  object.retryCount = reader.readLong(offsets[7]);
  object.status =
      _ExamFactoryQueueItemIsarstatusValueEnumMap[reader.readByteOrNull(
        offsets[8],
      )] ??
      ExamFactoryQueueStatus.pending;
  return object;
}

P _examFactoryQueueItemIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_ExamFactoryQueueItemIsaractionTypeValueEnumMap[reader
                  .readByteOrNull(offset)] ??
              ExamFactoryQueueActionType.saveQuestionDraft)
          as P;
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
      return (_ExamFactoryQueueItemIsarstatusValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              ExamFactoryQueueStatus.pending)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ExamFactoryQueueItemIsaractionTypeEnumValueMap = {
  'saveQuestionDraft': 0,
  'submitQuestion': 1,
  'moderateQuestion': 2,
  'recordAttendance': 3,
  'reportIncident': 4,
  'saveMarkEntry': 5,
};
const _ExamFactoryQueueItemIsaractionTypeValueEnumMap = {
  0: ExamFactoryQueueActionType.saveQuestionDraft,
  1: ExamFactoryQueueActionType.submitQuestion,
  2: ExamFactoryQueueActionType.moderateQuestion,
  3: ExamFactoryQueueActionType.recordAttendance,
  4: ExamFactoryQueueActionType.reportIncident,
  5: ExamFactoryQueueActionType.saveMarkEntry,
};
const _ExamFactoryQueueItemIsarstatusEnumValueMap = {
  'pending': 0,
  'syncing': 1,
  'failed': 2,
  'done': 3,
};
const _ExamFactoryQueueItemIsarstatusValueEnumMap = {
  0: ExamFactoryQueueStatus.pending,
  1: ExamFactoryQueueStatus.syncing,
  2: ExamFactoryQueueStatus.failed,
  3: ExamFactoryQueueStatus.done,
};

Id _examFactoryQueueItemIsarGetId(ExamFactoryQueueItemIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _examFactoryQueueItemIsarGetLinks(
  ExamFactoryQueueItemIsar object,
) {
  return [];
}

void _examFactoryQueueItemIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  ExamFactoryQueueItemIsar object,
) {
  object.id = id;
}

extension ExamFactoryQueueItemIsarByIndex
    on IsarCollection<ExamFactoryQueueItemIsar> {
  Future<ExamFactoryQueueItemIsar?> getByIdempotencyKey(String idempotencyKey) {
    return getByIndex(r'idempotencyKey', [idempotencyKey]);
  }

  ExamFactoryQueueItemIsar? getByIdempotencyKeySync(String idempotencyKey) {
    return getByIndexSync(r'idempotencyKey', [idempotencyKey]);
  }

  Future<bool> deleteByIdempotencyKey(String idempotencyKey) {
    return deleteByIndex(r'idempotencyKey', [idempotencyKey]);
  }

  bool deleteByIdempotencyKeySync(String idempotencyKey) {
    return deleteByIndexSync(r'idempotencyKey', [idempotencyKey]);
  }

  Future<List<ExamFactoryQueueItemIsar?>> getAllByIdempotencyKey(
    List<String> idempotencyKeyValues,
  ) {
    final values = idempotencyKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'idempotencyKey', values);
  }

  List<ExamFactoryQueueItemIsar?> getAllByIdempotencyKeySync(
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

  Future<Id> putByIdempotencyKey(ExamFactoryQueueItemIsar object) {
    return putByIndex(r'idempotencyKey', object);
  }

  Id putByIdempotencyKeySync(
    ExamFactoryQueueItemIsar object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'idempotencyKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByIdempotencyKey(
    List<ExamFactoryQueueItemIsar> objects,
  ) {
    return putAllByIndex(r'idempotencyKey', objects);
  }

  List<Id> putAllByIdempotencyKeySync(
    List<ExamFactoryQueueItemIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'idempotencyKey', objects, saveLinks: saveLinks);
  }
}

extension ExamFactoryQueueItemIsarQueryWhereSort
    on
        QueryBuilder<
          ExamFactoryQueueItemIsar,
          ExamFactoryQueueItemIsar,
          QWhere
        > {
  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ExamFactoryQueueItemIsarQueryWhere
    on
        QueryBuilder<
          ExamFactoryQueueItemIsar,
          ExamFactoryQueueItemIsar,
          QWhereClause
        > {
  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterWhereClause
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterWhereClause
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterWhereClause
  >
  institutionIdEqualTo(String institutionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'institutionId',
          value: [institutionId],
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterWhereClause
  >
  institutionIdNotEqualTo(String institutionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'institutionId',
                lower: [],
                upper: [institutionId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'institutionId',
                lower: [institutionId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'institutionId',
                lower: [institutionId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'institutionId',
                lower: [],
                upper: [institutionId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterWhereClause
  >
  actorIdEqualTo(String actorId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'actorId', value: [actorId]),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterWhereClause
  >
  actorIdNotEqualTo(String actorId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'actorId',
                lower: [],
                upper: [actorId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'actorId',
                lower: [actorId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'actorId',
                lower: [actorId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'actorId',
                lower: [],
                upper: [actorId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension ExamFactoryQueueItemIsarQueryFilter
    on
        QueryBuilder<
          ExamFactoryQueueItemIsar,
          ExamFactoryQueueItemIsar,
          QFilterCondition
        > {
  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  actionTypeEqualTo(ExamFactoryQueueActionType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'actionType', value: value),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  actionTypeGreaterThan(
    ExamFactoryQueueActionType value, {
    bool include = false,
  }) {
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  actionTypeLessThan(ExamFactoryQueueActionType value, {bool include = false}) {
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  actionTypeBetween(
    ExamFactoryQueueActionType lower,
    ExamFactoryQueueActionType upper, {
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  actorIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'actorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  actorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'actorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  actorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'actorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  actorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'actorId',
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  actorIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'actorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  actorIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'actorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  actorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'actorId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  actorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'actorId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  actorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'actorId', value: ''),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  actorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'actorId', value: ''),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  idempotencyKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'idempotencyKey', value: ''),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  idempotencyKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'idempotencyKey', value: ''),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  institutionIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'institutionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  institutionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'institutionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  institutionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'institutionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  institutionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'institutionId',
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  institutionIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'institutionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  institutionIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'institutionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  institutionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'institutionId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  institutionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'institutionId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  institutionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'institutionId', value: ''),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  institutionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'institutionId', value: ''),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastError'),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastError'),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastError', value: ''),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lastError', value: ''),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
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
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  retryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'retryCount', value: value),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  statusEqualTo(ExamFactoryQueueStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value),
      );
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  statusGreaterThan(ExamFactoryQueueStatus value, {bool include = false}) {
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  statusLessThan(ExamFactoryQueueStatus value, {bool include = false}) {
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

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueItemIsar,
    QAfterFilterCondition
  >
  statusBetween(
    ExamFactoryQueueStatus lower,
    ExamFactoryQueueStatus upper, {
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
}

extension ExamFactoryQueueItemIsarQueryObject
    on
        QueryBuilder<
          ExamFactoryQueueItemIsar,
          ExamFactoryQueueItemIsar,
          QFilterCondition
        > {}

extension ExamFactoryQueueItemIsarQueryLinks
    on
        QueryBuilder<
          ExamFactoryQueueItemIsar,
          ExamFactoryQueueItemIsar,
          QFilterCondition
        > {}

extension ExamFactoryQueueItemIsarQuerySortBy
    on
        QueryBuilder<
          ExamFactoryQueueItemIsar,
          ExamFactoryQueueItemIsar,
          QSortBy
        > {
  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByActionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByIdempotencyKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idempotencyKey', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByIdempotencyKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idempotencyKey', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByInstitutionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institutionId', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByInstitutionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institutionId', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByPayloadJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByPayloadJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension ExamFactoryQueueItemIsarQuerySortThenBy
    on
        QueryBuilder<
          ExamFactoryQueueItemIsar,
          ExamFactoryQueueItemIsar,
          QSortThenBy
        > {
  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByActionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionType', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByActorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByActorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actorId', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByIdempotencyKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idempotencyKey', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByIdempotencyKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idempotencyKey', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByInstitutionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institutionId', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByInstitutionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institutionId', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByPayloadJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByPayloadJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension ExamFactoryQueueItemIsarQueryWhereDistinct
    on
        QueryBuilder<
          ExamFactoryQueueItemIsar,
          ExamFactoryQueueItemIsar,
          QDistinct
        > {
  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QDistinct>
  distinctByActionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionType');
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QDistinct>
  distinctByActorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actorId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QDistinct>
  distinctByIdempotencyKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'idempotencyKey',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QDistinct>
  distinctByInstitutionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'institutionId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QDistinct>
  distinctByLastError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QDistinct>
  distinctByPayloadJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payloadJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QDistinct>
  distinctByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryCount');
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, ExamFactoryQueueItemIsar, QDistinct>
  distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }
}

extension ExamFactoryQueueItemIsarQueryProperty
    on
        QueryBuilder<
          ExamFactoryQueueItemIsar,
          ExamFactoryQueueItemIsar,
          QQueryProperty
        > {
  QueryBuilder<ExamFactoryQueueItemIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueActionType,
    QQueryOperations
  >
  actionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionType');
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, String, QQueryOperations>
  actorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actorId');
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, String, QQueryOperations>
  idempotencyKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idempotencyKey');
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, String, QQueryOperations>
  institutionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'institutionId');
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, String?, QQueryOperations>
  lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, String, QQueryOperations>
  payloadJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payloadJson');
    });
  }

  QueryBuilder<ExamFactoryQueueItemIsar, int, QQueryOperations>
  retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryCount');
    });
  }

  QueryBuilder<
    ExamFactoryQueueItemIsar,
    ExamFactoryQueueStatus,
    QQueryOperations
  >
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
