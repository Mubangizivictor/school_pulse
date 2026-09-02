// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAttendanceRecordIsarCollection on Isar {
  IsarCollection<AttendanceRecordIsar> get attendanceRecordIsars =>
      this.collection();
}

const AttendanceRecordIsarSchema = CollectionSchema(
  name: r'AttendanceRecordIsar',
  id: -4831990265321389418,
  properties: {
    r'blockedReason': PropertySchema(
      id: 0,
      name: r'blockedReason',
      type: IsarType.string,
    ),
    r'category': PropertySchema(
      id: 1,
      name: r'category',
      type: IsarType.string,
    ),
    r'correctedAt': PropertySchema(
      id: 2,
      name: r'correctedAt',
      type: IsarType.dateTime,
    ),
    r'correctionOf': PropertySchema(
      id: 3,
      name: r'correctionOf',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(
      id: 5,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'deviceId': PropertySchema(
      id: 6,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'lastError': PropertySchema(
      id: 7,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'markedBy': PropertySchema(
      id: 8,
      name: r'markedBy',
      type: IsarType.string,
    ),
    r'method': PropertySchema(
      id: 9,
      name: r'method',
      type: IsarType.string,
    ),
    r'nextRetryAt': PropertySchema(
      id: 10,
      name: r'nextRetryAt',
      type: IsarType.dateTime,
    ),
    r'operatorId': PropertySchema(
      id: 11,
      name: r'operatorId',
      type: IsarType.string,
    ),
    r'personId': PropertySchema(
      id: 12,
      name: r'personId',
      type: IsarType.string,
    ),
    r'personName': PropertySchema(
      id: 13,
      name: r'personName',
      type: IsarType.string,
    ),
    r'recordId': PropertySchema(
      id: 14,
      name: r'recordId',
      type: IsarType.string,
    ),
    r'retryCount': PropertySchema(
      id: 15,
      name: r'retryCount',
      type: IsarType.long,
    ),
    r'roleAssignmentId': PropertySchema(
      id: 16,
      name: r'roleAssignmentId',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 17,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'scopeId': PropertySchema(
      id: 18,
      name: r'scopeId',
      type: IsarType.string,
    ),
    r'scopeName': PropertySchema(
      id: 19,
      name: r'scopeName',
      type: IsarType.string,
    ),
    r'sessionType': PropertySchema(
      id: 20,
      name: r'sessionType',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 21,
      name: r'status',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 22,
      name: r'syncStatus',
      type: IsarType.string,
    )
  },
  estimateSize: _attendanceRecordIsarEstimateSize,
  serialize: _attendanceRecordIsarSerialize,
  deserialize: _attendanceRecordIsarDeserialize,
  deserializeProp: _attendanceRecordIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'recordId': IndexSchema(
      id: 907839981883940929,
      name: r'recordId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'recordId',
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
    ),
    r'scopeId': IndexSchema(
      id: 2528183376744017072,
      name: r'scopeId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'scopeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'personId': IndexSchema(
      id: 750717629518044662,
      name: r'personId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'personId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'syncStatus': IndexSchema(
      id: 8239539375045684509,
      name: r'syncStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'syncStatus',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _attendanceRecordIsarGetId,
  getLinks: _attendanceRecordIsarGetLinks,
  attach: _attendanceRecordIsarAttach,
  version: '3.1.0+1',
);

int _attendanceRecordIsarEstimateSize(
  AttendanceRecordIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.blockedReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.category.length * 3;
  {
    final value = object.correctionOf;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.deviceId.length * 3;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.markedBy.length * 3;
  bytesCount += 3 + object.method.length * 3;
  bytesCount += 3 + object.operatorId.length * 3;
  bytesCount += 3 + object.personId.length * 3;
  bytesCount += 3 + object.personName.length * 3;
  bytesCount += 3 + object.recordId.length * 3;
  {
    final value = object.roleAssignmentId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.scopeId.length * 3;
  bytesCount += 3 + object.scopeName.length * 3;
  bytesCount += 3 + object.sessionType.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.syncStatus.length * 3;
  return bytesCount;
}

void _attendanceRecordIsarSerialize(
  AttendanceRecordIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.blockedReason);
  writer.writeString(offsets[1], object.category);
  writer.writeDateTime(offsets[2], object.correctedAt);
  writer.writeString(offsets[3], object.correctionOf);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeDateTime(offsets[5], object.date);
  writer.writeString(offsets[6], object.deviceId);
  writer.writeString(offsets[7], object.lastError);
  writer.writeString(offsets[8], object.markedBy);
  writer.writeString(offsets[9], object.method);
  writer.writeDateTime(offsets[10], object.nextRetryAt);
  writer.writeString(offsets[11], object.operatorId);
  writer.writeString(offsets[12], object.personId);
  writer.writeString(offsets[13], object.personName);
  writer.writeString(offsets[14], object.recordId);
  writer.writeLong(offsets[15], object.retryCount);
  writer.writeString(offsets[16], object.roleAssignmentId);
  writer.writeString(offsets[17], object.schoolId);
  writer.writeString(offsets[18], object.scopeId);
  writer.writeString(offsets[19], object.scopeName);
  writer.writeString(offsets[20], object.sessionType);
  writer.writeString(offsets[21], object.status);
  writer.writeString(offsets[22], object.syncStatus);
}

AttendanceRecordIsar _attendanceRecordIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AttendanceRecordIsar();
  object.blockedReason = reader.readStringOrNull(offsets[0]);
  object.category = reader.readString(offsets[1]);
  object.correctedAt = reader.readDateTimeOrNull(offsets[2]);
  object.correctionOf = reader.readStringOrNull(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.date = reader.readDateTime(offsets[5]);
  object.deviceId = reader.readString(offsets[6]);
  object.id = id;
  object.lastError = reader.readStringOrNull(offsets[7]);
  object.markedBy = reader.readString(offsets[8]);
  object.method = reader.readString(offsets[9]);
  object.nextRetryAt = reader.readDateTimeOrNull(offsets[10]);
  object.operatorId = reader.readString(offsets[11]);
  object.personId = reader.readString(offsets[12]);
  object.personName = reader.readString(offsets[13]);
  object.recordId = reader.readString(offsets[14]);
  object.retryCount = reader.readLong(offsets[15]);
  object.roleAssignmentId = reader.readStringOrNull(offsets[16]);
  object.schoolId = reader.readString(offsets[17]);
  object.scopeId = reader.readString(offsets[18]);
  object.scopeName = reader.readString(offsets[19]);
  object.sessionType = reader.readString(offsets[20]);
  object.status = reader.readString(offsets[21]);
  object.syncStatus = reader.readString(offsets[22]);
  return object;
}

P _attendanceRecordIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readLong(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _attendanceRecordIsarGetId(AttendanceRecordIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _attendanceRecordIsarGetLinks(
    AttendanceRecordIsar object) {
  return [];
}

void _attendanceRecordIsarAttach(
    IsarCollection<dynamic> col, Id id, AttendanceRecordIsar object) {
  object.id = id;
}

extension AttendanceRecordIsarByIndex on IsarCollection<AttendanceRecordIsar> {
  Future<AttendanceRecordIsar?> getByRecordId(String recordId) {
    return getByIndex(r'recordId', [recordId]);
  }

  AttendanceRecordIsar? getByRecordIdSync(String recordId) {
    return getByIndexSync(r'recordId', [recordId]);
  }

  Future<bool> deleteByRecordId(String recordId) {
    return deleteByIndex(r'recordId', [recordId]);
  }

  bool deleteByRecordIdSync(String recordId) {
    return deleteByIndexSync(r'recordId', [recordId]);
  }

  Future<List<AttendanceRecordIsar?>> getAllByRecordId(
      List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'recordId', values);
  }

  List<AttendanceRecordIsar?> getAllByRecordIdSync(
      List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'recordId', values);
  }

  Future<int> deleteAllByRecordId(List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'recordId', values);
  }

  int deleteAllByRecordIdSync(List<String> recordIdValues) {
    final values = recordIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'recordId', values);
  }

  Future<Id> putByRecordId(AttendanceRecordIsar object) {
    return putByIndex(r'recordId', object);
  }

  Id putByRecordIdSync(AttendanceRecordIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'recordId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRecordId(List<AttendanceRecordIsar> objects) {
    return putAllByIndex(r'recordId', objects);
  }

  List<Id> putAllByRecordIdSync(List<AttendanceRecordIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'recordId', objects, saveLinks: saveLinks);
  }
}

extension AttendanceRecordIsarQueryWhereSort
    on QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QWhere> {
  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhere>
      anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension AttendanceRecordIsarQueryWhere
    on QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QWhereClause> {
  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      recordIdEqualTo(String recordId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recordId',
        value: [recordId],
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      recordIdNotEqualTo(String recordId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordId',
              lower: [],
              upper: [recordId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordId',
              lower: [recordId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordId',
              lower: [recordId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordId',
              lower: [],
              upper: [recordId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      scopeIdEqualTo(String scopeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'scopeId',
        value: [scopeId],
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      scopeIdNotEqualTo(String scopeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scopeId',
              lower: [],
              upper: [scopeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scopeId',
              lower: [scopeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scopeId',
              lower: [scopeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scopeId',
              lower: [],
              upper: [scopeId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      dateEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      dateNotEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      personIdEqualTo(String personId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'personId',
        value: [personId],
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      syncStatusEqualTo(String syncStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncStatus',
        value: [syncStatus],
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterWhereClause>
      syncStatusNotEqualTo(String syncStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [],
              upper: [syncStatus],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [syncStatus],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [syncStatus],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [],
              upper: [syncStatus],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AttendanceRecordIsarQueryFilter on QueryBuilder<AttendanceRecordIsar,
    AttendanceRecordIsar, QFilterCondition> {
  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> blockedReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'blockedReason',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> blockedReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'blockedReason',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> blockedReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> blockedReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blockedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> blockedReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blockedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> blockedReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blockedReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> blockedReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'blockedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> blockedReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'blockedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      blockedReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'blockedReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      blockedReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'blockedReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> blockedReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blockedReason',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> blockedReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'blockedReason',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'correctedAt',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'correctedAt',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctionOfIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'correctionOf',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctionOfIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'correctionOf',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctionOfEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctionOf',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctionOfGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctionOf',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctionOfLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctionOf',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctionOfBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctionOf',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctionOfStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'correctionOf',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctionOfEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'correctionOf',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      correctionOfContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'correctionOf',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      correctionOfMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'correctionOf',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctionOfIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctionOf',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> correctionOfIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'correctionOf',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> deviceIdEqualTo(
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> deviceIdGreaterThan(
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> deviceIdLessThan(
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> deviceIdBetween(
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> deviceIdStartsWith(
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> deviceIdEndsWith(
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> markedByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> markedByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'markedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> markedByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'markedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> markedByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'markedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> markedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'markedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> markedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'markedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      markedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'markedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      markedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'markedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> markedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> markedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'markedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> methodEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'method',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> methodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'method',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> methodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'method',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> methodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'method',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> methodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'method',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> methodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'method',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      methodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'method',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      methodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'method',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> methodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'method',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> methodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'method',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> nextRetryAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextRetryAt',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> nextRetryAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextRetryAt',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> nextRetryAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextRetryAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> nextRetryAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextRetryAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> nextRetryAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextRetryAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> nextRetryAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextRetryAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> operatorIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> operatorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> operatorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> operatorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operatorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> operatorIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> operatorIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      operatorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operatorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      operatorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operatorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> operatorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operatorId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> operatorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operatorId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> personIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> personIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'personId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> personNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> personNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> personNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> personNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'personName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> personNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> personNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      personNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'personName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      personNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'personName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> personNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personName',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> personNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'personName',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> recordIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> recordIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> recordIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> recordIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> recordIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> recordIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      recordIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recordId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      recordIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recordId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> recordIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> recordIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recordId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> retryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> roleAssignmentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'roleAssignmentId',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> roleAssignmentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'roleAssignmentId',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> roleAssignmentIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleAssignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> roleAssignmentIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'roleAssignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> roleAssignmentIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'roleAssignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> roleAssignmentIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'roleAssignmentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> roleAssignmentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'roleAssignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> roleAssignmentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'roleAssignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      roleAssignmentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'roleAssignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      roleAssignmentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'roleAssignmentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> roleAssignmentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleAssignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> roleAssignmentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roleAssignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scopeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scopeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scopeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scopeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scopeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scopeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      scopeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scopeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      scopeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scopeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scopeId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scopeId',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scopeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scopeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scopeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scopeName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scopeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scopeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      scopeNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scopeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      scopeNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scopeName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scopeName',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> scopeNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scopeName',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> sessionTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> sessionTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> sessionTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> sessionTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> sessionTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sessionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> sessionTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sessionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      sessionTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sessionType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      sessionTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sessionType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> sessionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionType',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> sessionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionType',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
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

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> syncStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> syncStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> syncStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> syncStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> syncStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> syncStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
          QAfterFilterCondition>
      syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar,
      QAfterFilterCondition> syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }
}

extension AttendanceRecordIsarQueryObject on QueryBuilder<AttendanceRecordIsar,
    AttendanceRecordIsar, QFilterCondition> {}

extension AttendanceRecordIsarQueryLinks on QueryBuilder<AttendanceRecordIsar,
    AttendanceRecordIsar, QFilterCondition> {}

extension AttendanceRecordIsarQuerySortBy
    on QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QSortBy> {
  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByBlockedReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedReason', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByBlockedReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedReason', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByCorrectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByCorrectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByCorrectionOf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctionOf', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByCorrectionOfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctionOf', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByMarkedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markedBy', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByMarkedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markedBy', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'method', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'method', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByNextRetryAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByOperatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByOperatorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByPersonId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByPersonIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByPersonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByPersonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByRoleAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByRoleAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByScopeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByScopeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByScopeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeName', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByScopeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeName', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortBySessionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionType', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortBySessionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionType', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }
}

extension AttendanceRecordIsarQuerySortThenBy
    on QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QSortThenBy> {
  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByBlockedReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedReason', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByBlockedReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blockedReason', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByCorrectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByCorrectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByCorrectionOf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctionOf', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByCorrectionOfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctionOf', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByMarkedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markedBy', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByMarkedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'markedBy', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByMethod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'method', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByMethodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'method', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByNextRetryAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByOperatorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByOperatorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operatorId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByPersonId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByPersonIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByPersonName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByPersonNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personName', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByRoleAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByRoleAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByScopeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByScopeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByScopeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeName', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByScopeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scopeName', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenBySessionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionType', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenBySessionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionType', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }
}

extension AttendanceRecordIsarQueryWhereDistinct
    on QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct> {
  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByBlockedReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blockedReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByCorrectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctedAt');
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByCorrectionOf({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctionOf', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByLastError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByMarkedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'markedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByMethod({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'method', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextRetryAt');
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByOperatorId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operatorId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByPersonId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByPersonName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByRecordId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryCount');
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByRoleAssignmentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roleAssignmentId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByScopeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scopeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByScopeName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scopeName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctBySessionType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceRecordIsar, AttendanceRecordIsar, QDistinct>
      distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }
}

extension AttendanceRecordIsarQueryProperty on QueryBuilder<
    AttendanceRecordIsar, AttendanceRecordIsar, QQueryProperty> {
  QueryBuilder<AttendanceRecordIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String?, QQueryOperations>
      blockedReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blockedReason');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String, QQueryOperations>
      categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<AttendanceRecordIsar, DateTime?, QQueryOperations>
      correctedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctedAt');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String?, QQueryOperations>
      correctionOfProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctionOf');
    });
  }

  QueryBuilder<AttendanceRecordIsar, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AttendanceRecordIsar, DateTime, QQueryOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String, QQueryOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String?, QQueryOperations>
      lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String, QQueryOperations>
      markedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'markedBy');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String, QQueryOperations>
      methodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'method');
    });
  }

  QueryBuilder<AttendanceRecordIsar, DateTime?, QQueryOperations>
      nextRetryAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextRetryAt');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String, QQueryOperations>
      operatorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operatorId');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String, QQueryOperations>
      personIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personId');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String, QQueryOperations>
      personNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personName');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String, QQueryOperations>
      recordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordId');
    });
  }

  QueryBuilder<AttendanceRecordIsar, int, QQueryOperations>
      retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryCount');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String?, QQueryOperations>
      roleAssignmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roleAssignmentId');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String, QQueryOperations>
      scopeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scopeId');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String, QQueryOperations>
      scopeNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scopeName');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String, QQueryOperations>
      sessionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionType');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<AttendanceRecordIsar, String, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }
}
