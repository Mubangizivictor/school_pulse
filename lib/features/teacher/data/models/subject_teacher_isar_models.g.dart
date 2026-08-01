// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_teacher_isar_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStaffRoleAssignmentIsarCollection on Isar {
  IsarCollection<StaffRoleAssignmentIsar> get staffRoleAssignmentIsars =>
      this.collection();
}

const StaffRoleAssignmentIsarSchema = CollectionSchema(
  name: r'StaffRoleAssignmentIsar',
  id: 1938436553422120166,
  properties: {
    r'academicYearId': PropertySchema(
      id: 0,
      name: r'academicYearId',
      type: IsarType.string,
    ),
    r'assignedAt': PropertySchema(
      id: 1,
      name: r'assignedAt',
      type: IsarType.dateTime,
    ),
    r'assignedBy': PropertySchema(
      id: 2,
      name: r'assignedBy',
      type: IsarType.string,
    ),
    r'assignmentId': PropertySchema(
      id: 3,
      name: r'assignmentId',
      type: IsarType.string,
    ),
    r'cachedAt': PropertySchema(
      id: 4,
      name: r'cachedAt',
      type: IsarType.dateTime,
    ),
    r'campusId': PropertySchema(
      id: 5,
      name: r'campusId',
      type: IsarType.string,
    ),
    r'classId': PropertySchema(
      id: 6,
      name: r'classId',
      type: IsarType.string,
    ),
    r'className': PropertySchema(
      id: 7,
      name: r'className',
      type: IsarType.string,
    ),
    r'departmentId': PropertySchema(
      id: 8,
      name: r'departmentId',
      type: IsarType.string,
    ),
    r'endDate': PropertySchema(
      id: 9,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'houseId': PropertySchema(
      id: 10,
      name: r'houseId',
      type: IsarType.string,
    ),
    r'permissions': PropertySchema(
      id: 11,
      name: r'permissions',
      type: IsarType.stringList,
    ),
    r'roleType': PropertySchema(
      id: 12,
      name: r'roleType',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 13,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'scopeTermIds': PropertySchema(
      id: 14,
      name: r'scopeTermIds',
      type: IsarType.stringList,
    ),
    r'staffId': PropertySchema(
      id: 15,
      name: r'staffId',
      type: IsarType.string,
    ),
    r'startDate': PropertySchema(
      id: 16,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 17,
      name: r'status',
      type: IsarType.string,
    ),
    r'streamId': PropertySchema(
      id: 18,
      name: r'streamId',
      type: IsarType.string,
    ),
    r'streamName': PropertySchema(
      id: 19,
      name: r'streamName',
      type: IsarType.string,
    ),
    r'subjectId': PropertySchema(
      id: 20,
      name: r'subjectId',
      type: IsarType.string,
    ),
    r'subjectName': PropertySchema(
      id: 21,
      name: r'subjectName',
      type: IsarType.string,
    ),
    r'substituteForStaffId': PropertySchema(
      id: 22,
      name: r'substituteForStaffId',
      type: IsarType.string,
    ),
    r'termId': PropertySchema(
      id: 23,
      name: r'termId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 24,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'updatedBy': PropertySchema(
      id: 25,
      name: r'updatedBy',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 26,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _staffRoleAssignmentIsarEstimateSize,
  serialize: _staffRoleAssignmentIsarSerialize,
  deserialize: _staffRoleAssignmentIsarDeserialize,
  deserializeProp: _staffRoleAssignmentIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'assignmentId': IndexSchema(
      id: -2077143699295136292,
      name: r'assignmentId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'assignmentId',
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
    r'staffId': IndexSchema(
      id: 4156753416256495883,
      name: r'staffId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'staffId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'academicYearId': IndexSchema(
      id: 6150310572743030444,
      name: r'academicYearId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'academicYearId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _staffRoleAssignmentIsarGetId,
  getLinks: _staffRoleAssignmentIsarGetLinks,
  attach: _staffRoleAssignmentIsarAttach,
  version: '3.1.0+1',
);

int _staffRoleAssignmentIsarEstimateSize(
  StaffRoleAssignmentIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.academicYearId.length * 3;
  bytesCount += 3 + object.assignedBy.length * 3;
  bytesCount += 3 + object.assignmentId.length * 3;
  bytesCount += 3 + object.campusId.length * 3;
  {
    final value = object.classId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.className;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.departmentId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.houseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.permissions.length * 3;
  {
    for (var i = 0; i < object.permissions.length; i++) {
      final value = object.permissions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.roleType.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.scopeTermIds.length * 3;
  {
    for (var i = 0; i < object.scopeTermIds.length; i++) {
      final value = object.scopeTermIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.staffId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  {
    final value = object.streamId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.streamName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.subjectId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.subjectName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.substituteForStaffId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.termId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.updatedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _staffRoleAssignmentIsarSerialize(
  StaffRoleAssignmentIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.academicYearId);
  writer.writeDateTime(offsets[1], object.assignedAt);
  writer.writeString(offsets[2], object.assignedBy);
  writer.writeString(offsets[3], object.assignmentId);
  writer.writeDateTime(offsets[4], object.cachedAt);
  writer.writeString(offsets[5], object.campusId);
  writer.writeString(offsets[6], object.classId);
  writer.writeString(offsets[7], object.className);
  writer.writeString(offsets[8], object.departmentId);
  writer.writeDateTime(offsets[9], object.endDate);
  writer.writeString(offsets[10], object.houseId);
  writer.writeStringList(offsets[11], object.permissions);
  writer.writeString(offsets[12], object.roleType);
  writer.writeString(offsets[13], object.schoolId);
  writer.writeStringList(offsets[14], object.scopeTermIds);
  writer.writeString(offsets[15], object.staffId);
  writer.writeDateTime(offsets[16], object.startDate);
  writer.writeString(offsets[17], object.status);
  writer.writeString(offsets[18], object.streamId);
  writer.writeString(offsets[19], object.streamName);
  writer.writeString(offsets[20], object.subjectId);
  writer.writeString(offsets[21], object.subjectName);
  writer.writeString(offsets[22], object.substituteForStaffId);
  writer.writeString(offsets[23], object.termId);
  writer.writeDateTime(offsets[24], object.updatedAt);
  writer.writeString(offsets[25], object.updatedBy);
  writer.writeString(offsets[26], object.userId);
}

StaffRoleAssignmentIsar _staffRoleAssignmentIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StaffRoleAssignmentIsar();
  object.academicYearId = reader.readString(offsets[0]);
  object.assignedAt = reader.readDateTime(offsets[1]);
  object.assignedBy = reader.readString(offsets[2]);
  object.assignmentId = reader.readString(offsets[3]);
  object.cachedAt = reader.readDateTime(offsets[4]);
  object.campusId = reader.readString(offsets[5]);
  object.classId = reader.readStringOrNull(offsets[6]);
  object.className = reader.readStringOrNull(offsets[7]);
  object.departmentId = reader.readStringOrNull(offsets[8]);
  object.endDate = reader.readDateTimeOrNull(offsets[9]);
  object.houseId = reader.readStringOrNull(offsets[10]);
  object.id = id;
  object.permissions = reader.readStringList(offsets[11]) ?? [];
  object.roleType = reader.readString(offsets[12]);
  object.schoolId = reader.readString(offsets[13]);
  object.scopeTermIds = reader.readStringList(offsets[14]) ?? [];
  object.staffId = reader.readString(offsets[15]);
  object.startDate = reader.readDateTime(offsets[16]);
  object.status = reader.readString(offsets[17]);
  object.streamId = reader.readStringOrNull(offsets[18]);
  object.streamName = reader.readStringOrNull(offsets[19]);
  object.subjectId = reader.readStringOrNull(offsets[20]);
  object.subjectName = reader.readStringOrNull(offsets[21]);
  object.substituteForStaffId = reader.readStringOrNull(offsets[22]);
  object.termId = reader.readStringOrNull(offsets[23]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[24]);
  object.updatedBy = reader.readStringOrNull(offsets[25]);
  object.userId = reader.readString(offsets[26]);
  return object;
}

P _staffRoleAssignmentIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringList(offset) ?? []) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readStringList(offset) ?? []) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readDateTime(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _staffRoleAssignmentIsarGetId(StaffRoleAssignmentIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _staffRoleAssignmentIsarGetLinks(
    StaffRoleAssignmentIsar object) {
  return [];
}

void _staffRoleAssignmentIsarAttach(
    IsarCollection<dynamic> col, Id id, StaffRoleAssignmentIsar object) {
  object.id = id;
}

extension StaffRoleAssignmentIsarByIndex
    on IsarCollection<StaffRoleAssignmentIsar> {
  Future<StaffRoleAssignmentIsar?> getByAssignmentId(String assignmentId) {
    return getByIndex(r'assignmentId', [assignmentId]);
  }

  StaffRoleAssignmentIsar? getByAssignmentIdSync(String assignmentId) {
    return getByIndexSync(r'assignmentId', [assignmentId]);
  }

  Future<bool> deleteByAssignmentId(String assignmentId) {
    return deleteByIndex(r'assignmentId', [assignmentId]);
  }

  bool deleteByAssignmentIdSync(String assignmentId) {
    return deleteByIndexSync(r'assignmentId', [assignmentId]);
  }

  Future<List<StaffRoleAssignmentIsar?>> getAllByAssignmentId(
      List<String> assignmentIdValues) {
    final values = assignmentIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'assignmentId', values);
  }

  List<StaffRoleAssignmentIsar?> getAllByAssignmentIdSync(
      List<String> assignmentIdValues) {
    final values = assignmentIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'assignmentId', values);
  }

  Future<int> deleteAllByAssignmentId(List<String> assignmentIdValues) {
    final values = assignmentIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'assignmentId', values);
  }

  int deleteAllByAssignmentIdSync(List<String> assignmentIdValues) {
    final values = assignmentIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'assignmentId', values);
  }

  Future<Id> putByAssignmentId(StaffRoleAssignmentIsar object) {
    return putByIndex(r'assignmentId', object);
  }

  Id putByAssignmentIdSync(StaffRoleAssignmentIsar object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'assignmentId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByAssignmentId(List<StaffRoleAssignmentIsar> objects) {
    return putAllByIndex(r'assignmentId', objects);
  }

  List<Id> putAllByAssignmentIdSync(List<StaffRoleAssignmentIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'assignmentId', objects, saveLinks: saveLinks);
  }
}

extension StaffRoleAssignmentIsarQueryWhereSort
    on QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QWhere> {
  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StaffRoleAssignmentIsarQueryWhere on QueryBuilder<
    StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QWhereClause> {
  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterWhereClause> assignmentIdEqualTo(String assignmentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'assignmentId',
        value: [assignmentId],
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterWhereClause> assignmentIdNotEqualTo(String assignmentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assignmentId',
              lower: [],
              upper: [assignmentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assignmentId',
              lower: [assignmentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assignmentId',
              lower: [assignmentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'assignmentId',
              lower: [],
              upper: [assignmentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterWhereClause> schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterWhereClause> schoolIdNotEqualTo(String schoolId) {
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterWhereClause> staffIdEqualTo(String staffId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'staffId',
        value: [staffId],
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterWhereClause> staffIdNotEqualTo(String staffId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'staffId',
              lower: [],
              upper: [staffId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'staffId',
              lower: [staffId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'staffId',
              lower: [staffId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'staffId',
              lower: [],
              upper: [staffId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterWhereClause> userIdEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterWhereClause> userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterWhereClause> academicYearIdEqualTo(String academicYearId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'academicYearId',
        value: [academicYearId],
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterWhereClause> academicYearIdNotEqualTo(String academicYearId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'academicYearId',
              lower: [],
              upper: [academicYearId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'academicYearId',
              lower: [academicYearId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'academicYearId',
              lower: [academicYearId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'academicYearId',
              lower: [],
              upper: [academicYearId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension StaffRoleAssignmentIsarQueryFilter on QueryBuilder<
    StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QFilterCondition> {
  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> academicYearIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> academicYearIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> academicYearIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> academicYearIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'academicYearId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> academicYearIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> academicYearIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      academicYearIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      academicYearIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'academicYearId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> academicYearIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> academicYearIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignedByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignedByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignedByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignedByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      assignedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      assignedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignmentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignmentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignmentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignmentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignmentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignmentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignmentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      assignmentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      assignmentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignmentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignmentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> assignmentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> cachedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> cachedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> cachedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> cachedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cachedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> campusIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> campusIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> campusIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> campusIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'campusId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> campusIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> campusIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      campusIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      campusIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'campusId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> campusIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> campusIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'classId',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'classId',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'classId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      classIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      classIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'classId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'className',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'className',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classNameEqualTo(
    String? value, {
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classNameGreaterThan(
    String? value, {
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classNameLessThan(
    String? value, {
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classNameBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classNameStartsWith(
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classNameEndsWith(
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      classNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      classNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'className',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'className',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> classNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'className',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> departmentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'departmentId',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> departmentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'departmentId',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> departmentIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> departmentIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> departmentIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> departmentIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'departmentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> departmentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> departmentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      departmentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'departmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      departmentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'departmentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> departmentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> departmentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'departmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> endDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> endDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> endDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> endDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> endDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> houseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'houseId',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> houseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'houseId',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> houseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'houseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> houseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'houseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> houseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'houseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> houseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'houseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> houseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'houseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> houseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'houseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      houseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'houseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      houseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'houseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> houseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'houseId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> houseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'houseId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> permissionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> permissionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> permissionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> permissionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'permissions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> permissionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> permissionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      permissionsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'permissions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      permissionsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'permissions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> permissionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'permissions',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> permissionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'permissions',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> permissionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'permissions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> permissionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'permissions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> permissionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'permissions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> permissionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'permissions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> permissionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'permissions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> permissionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'permissions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'roleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'roleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'roleType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'roleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'roleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      roleTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'roleType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      roleTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'roleType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleType',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roleType',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> scopeTermIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scopeTermIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> scopeTermIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scopeTermIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> scopeTermIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scopeTermIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> scopeTermIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scopeTermIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> scopeTermIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scopeTermIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> scopeTermIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scopeTermIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      scopeTermIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scopeTermIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      scopeTermIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scopeTermIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> scopeTermIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scopeTermIds',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> scopeTermIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scopeTermIds',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> scopeTermIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'scopeTermIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> scopeTermIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'scopeTermIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> scopeTermIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'scopeTermIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> scopeTermIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'scopeTermIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> scopeTermIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'scopeTermIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> scopeTermIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'scopeTermIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> staffIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'staffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> staffIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'staffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> staffIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'staffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> staffIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'staffId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> staffIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'staffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> staffIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'staffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      staffIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'staffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      staffIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'staffId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> staffIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'staffId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> staffIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'staffId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> startDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> startDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> startDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streamId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      streamIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      streamIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streamId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamName',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamName',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streamName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streamName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streamName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'streamName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'streamName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      streamNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streamName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      streamNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streamName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamName',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> streamNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamName',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subjectId',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subjectId',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      subjectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      subjectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subjectName',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subjectName',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      subjectNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      subjectNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectName',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> subjectNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectName',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> substituteForStaffIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'substituteForStaffId',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> substituteForStaffIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'substituteForStaffId',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> substituteForStaffIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'substituteForStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> substituteForStaffIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'substituteForStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> substituteForStaffIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'substituteForStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> substituteForStaffIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'substituteForStaffId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> substituteForStaffIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'substituteForStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> substituteForStaffIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'substituteForStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      substituteForStaffIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'substituteForStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      substituteForStaffIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'substituteForStaffId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> substituteForStaffIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'substituteForStaffId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> substituteForStaffIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'substituteForStaffId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> termIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'termId',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> termIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'termId',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> termIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> termIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'termId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> termIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'termId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> termIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'termId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> termIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'termId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> termIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'termId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      termIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'termId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      termIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'termId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> termIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> termIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'termId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime? value, {
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedBy',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedBy',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'updatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'updatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      updatedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'updatedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      updatedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'updatedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> updatedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'updatedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension StaffRoleAssignmentIsarQueryObject on QueryBuilder<
    StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QFilterCondition> {}

extension StaffRoleAssignmentIsarQueryLinks on QueryBuilder<
    StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QFilterCondition> {}

extension StaffRoleAssignmentIsarQuerySortBy
    on QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QSortBy> {
  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByAssignedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAt', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByAssignedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAt', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByAssignedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBy', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByAssignedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBy', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignmentId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignmentId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByDepartmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByDepartmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByHouseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'houseId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByHouseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'houseId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByRoleType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleType', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByRoleTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleType', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByStreamName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamName', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByStreamNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamName', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortBySubstituteForStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'substituteForStaffId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortBySubstituteForStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'substituteForStaffId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByTermId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByTermIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByUpdatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByUpdatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension StaffRoleAssignmentIsarQuerySortThenBy on QueryBuilder<
    StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QSortThenBy> {
  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByAssignedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAt', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByAssignedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedAt', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByAssignedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBy', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByAssignedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBy', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignmentId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignmentId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByDepartmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByDepartmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByHouseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'houseId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByHouseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'houseId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByRoleType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleType', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByRoleTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleType', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByStreamName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamName', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByStreamNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamName', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenBySubstituteForStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'substituteForStaffId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenBySubstituteForStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'substituteForStaffId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByTermId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByTermIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByUpdatedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByUpdatedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedBy', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension StaffRoleAssignmentIsarQueryWhereDistinct on QueryBuilder<
    StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct> {
  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByAcademicYearId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'academicYearId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByAssignedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedAt');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByAssignedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByAssignmentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignmentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cachedAt');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByCampusId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'campusId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByClassId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByClassName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'className', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByDepartmentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'departmentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByHouseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'houseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByPermissions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permissions');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByRoleType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roleType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByScopeTermIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scopeTermIds');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByStaffId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'staffId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByStreamId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByStreamName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctBySubjectId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctBySubjectName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctBySubstituteForStaffId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'substituteForStaffId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByTermId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'termId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByUpdatedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension StaffRoleAssignmentIsarQueryProperty on QueryBuilder<
    StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QQueryProperty> {
  QueryBuilder<StaffRoleAssignmentIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String, QQueryOperations>
      academicYearIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'academicYearId');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, DateTime, QQueryOperations>
      assignedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedAt');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String, QQueryOperations>
      assignedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedBy');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String, QQueryOperations>
      assignmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignmentId');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, DateTime, QQueryOperations>
      cachedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cachedAt');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String, QQueryOperations>
      campusIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campusId');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String?, QQueryOperations>
      classIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classId');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String?, QQueryOperations>
      classNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'className');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String?, QQueryOperations>
      departmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'departmentId');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, DateTime?, QQueryOperations>
      endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String?, QQueryOperations>
      houseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'houseId');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, List<String>, QQueryOperations>
      permissionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permissions');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String, QQueryOperations>
      roleTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roleType');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, List<String>, QQueryOperations>
      scopeTermIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scopeTermIds');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String, QQueryOperations>
      staffIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'staffId');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, DateTime, QQueryOperations>
      startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String?, QQueryOperations>
      streamIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamId');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String?, QQueryOperations>
      streamNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamName');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String?, QQueryOperations>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectId');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String?, QQueryOperations>
      subjectNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectName');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String?, QQueryOperations>
      substituteForStaffIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'substituteForStaffId');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String?, QQueryOperations>
      termIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'termId');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String?, QQueryOperations>
      updatedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedBy');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubjectEnrollmentIsarCollection on Isar {
  IsarCollection<SubjectEnrollmentIsar> get subjectEnrollmentIsars =>
      this.collection();
}

const SubjectEnrollmentIsarSchema = CollectionSchema(
  name: r'SubjectEnrollmentIsar',
  id: 7674630548694594751,
  properties: {
    r'academicYearId': PropertySchema(
      id: 0,
      name: r'academicYearId',
      type: IsarType.string,
    ),
    r'campusId': PropertySchema(
      id: 1,
      name: r'campusId',
      type: IsarType.string,
    ),
    r'classId': PropertySchema(
      id: 2,
      name: r'classId',
      type: IsarType.string,
    ),
    r'effectiveFrom': PropertySchema(
      id: 3,
      name: r'effectiveFrom',
      type: IsarType.dateTime,
    ),
    r'effectiveTo': PropertySchema(
      id: 4,
      name: r'effectiveTo',
      type: IsarType.dateTime,
    ),
    r'enrolledAt': PropertySchema(
      id: 5,
      name: r'enrolledAt',
      type: IsarType.dateTime,
    ),
    r'enrolledBy': PropertySchema(
      id: 6,
      name: r'enrolledBy',
      type: IsarType.string,
    ),
    r'enrollmentId': PropertySchema(
      id: 7,
      name: r'enrollmentId',
      type: IsarType.string,
    ),
    r'isMandatory': PropertySchema(
      id: 8,
      name: r'isMandatory',
      type: IsarType.bool,
    ),
    r'removalReason': PropertySchema(
      id: 9,
      name: r'removalReason',
      type: IsarType.string,
    ),
    r'removedAt': PropertySchema(
      id: 10,
      name: r'removedAt',
      type: IsarType.dateTime,
    ),
    r'removedBy': PropertySchema(
      id: 11,
      name: r'removedBy',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 12,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 13,
      name: r'status',
      type: IsarType.string,
    ),
    r'streamId': PropertySchema(
      id: 14,
      name: r'streamId',
      type: IsarType.string,
    ),
    r'studentId': PropertySchema(
      id: 15,
      name: r'studentId',
      type: IsarType.string,
    ),
    r'subjectId': PropertySchema(
      id: 16,
      name: r'subjectId',
      type: IsarType.string,
    )
  },
  estimateSize: _subjectEnrollmentIsarEstimateSize,
  serialize: _subjectEnrollmentIsarSerialize,
  deserialize: _subjectEnrollmentIsarDeserialize,
  deserializeProp: _subjectEnrollmentIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'enrollmentId': IndexSchema(
      id: 7414494948003187168,
      name: r'enrollmentId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'enrollmentId',
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
    r'studentId': IndexSchema(
      id: -6791323312898281473,
      name: r'studentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'studentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'subjectId': IndexSchema(
      id: 440306668014799972,
      name: r'subjectId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'subjectId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'classId': IndexSchema(
      id: 5352960816261817663,
      name: r'classId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'classId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'academicYearId': IndexSchema(
      id: 6150310572743030444,
      name: r'academicYearId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'academicYearId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _subjectEnrollmentIsarGetId,
  getLinks: _subjectEnrollmentIsarGetLinks,
  attach: _subjectEnrollmentIsarAttach,
  version: '3.1.0+1',
);

int _subjectEnrollmentIsarEstimateSize(
  SubjectEnrollmentIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.academicYearId.length * 3;
  bytesCount += 3 + object.campusId.length * 3;
  bytesCount += 3 + object.classId.length * 3;
  bytesCount += 3 + object.enrolledBy.length * 3;
  bytesCount += 3 + object.enrollmentId.length * 3;
  {
    final value = object.removalReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.removedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  {
    final value = object.streamId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.studentId.length * 3;
  bytesCount += 3 + object.subjectId.length * 3;
  return bytesCount;
}

void _subjectEnrollmentIsarSerialize(
  SubjectEnrollmentIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.academicYearId);
  writer.writeString(offsets[1], object.campusId);
  writer.writeString(offsets[2], object.classId);
  writer.writeDateTime(offsets[3], object.effectiveFrom);
  writer.writeDateTime(offsets[4], object.effectiveTo);
  writer.writeDateTime(offsets[5], object.enrolledAt);
  writer.writeString(offsets[6], object.enrolledBy);
  writer.writeString(offsets[7], object.enrollmentId);
  writer.writeBool(offsets[8], object.isMandatory);
  writer.writeString(offsets[9], object.removalReason);
  writer.writeDateTime(offsets[10], object.removedAt);
  writer.writeString(offsets[11], object.removedBy);
  writer.writeString(offsets[12], object.schoolId);
  writer.writeString(offsets[13], object.status);
  writer.writeString(offsets[14], object.streamId);
  writer.writeString(offsets[15], object.studentId);
  writer.writeString(offsets[16], object.subjectId);
}

SubjectEnrollmentIsar _subjectEnrollmentIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubjectEnrollmentIsar();
  object.academicYearId = reader.readString(offsets[0]);
  object.campusId = reader.readString(offsets[1]);
  object.classId = reader.readString(offsets[2]);
  object.effectiveFrom = reader.readDateTimeOrNull(offsets[3]);
  object.effectiveTo = reader.readDateTimeOrNull(offsets[4]);
  object.enrolledAt = reader.readDateTime(offsets[5]);
  object.enrolledBy = reader.readString(offsets[6]);
  object.enrollmentId = reader.readString(offsets[7]);
  object.id = id;
  object.isMandatory = reader.readBool(offsets[8]);
  object.removalReason = reader.readStringOrNull(offsets[9]);
  object.removedAt = reader.readDateTimeOrNull(offsets[10]);
  object.removedBy = reader.readStringOrNull(offsets[11]);
  object.schoolId = reader.readString(offsets[12]);
  object.status = reader.readString(offsets[13]);
  object.streamId = reader.readStringOrNull(offsets[14]);
  object.studentId = reader.readString(offsets[15]);
  object.subjectId = reader.readString(offsets[16]);
  return object;
}

P _subjectEnrollmentIsarDeserializeProp<P>(
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _subjectEnrollmentIsarGetId(SubjectEnrollmentIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subjectEnrollmentIsarGetLinks(
    SubjectEnrollmentIsar object) {
  return [];
}

void _subjectEnrollmentIsarAttach(
    IsarCollection<dynamic> col, Id id, SubjectEnrollmentIsar object) {
  object.id = id;
}

extension SubjectEnrollmentIsarByIndex
    on IsarCollection<SubjectEnrollmentIsar> {
  Future<SubjectEnrollmentIsar?> getByEnrollmentId(String enrollmentId) {
    return getByIndex(r'enrollmentId', [enrollmentId]);
  }

  SubjectEnrollmentIsar? getByEnrollmentIdSync(String enrollmentId) {
    return getByIndexSync(r'enrollmentId', [enrollmentId]);
  }

  Future<bool> deleteByEnrollmentId(String enrollmentId) {
    return deleteByIndex(r'enrollmentId', [enrollmentId]);
  }

  bool deleteByEnrollmentIdSync(String enrollmentId) {
    return deleteByIndexSync(r'enrollmentId', [enrollmentId]);
  }

  Future<List<SubjectEnrollmentIsar?>> getAllByEnrollmentId(
      List<String> enrollmentIdValues) {
    final values = enrollmentIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'enrollmentId', values);
  }

  List<SubjectEnrollmentIsar?> getAllByEnrollmentIdSync(
      List<String> enrollmentIdValues) {
    final values = enrollmentIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'enrollmentId', values);
  }

  Future<int> deleteAllByEnrollmentId(List<String> enrollmentIdValues) {
    final values = enrollmentIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'enrollmentId', values);
  }

  int deleteAllByEnrollmentIdSync(List<String> enrollmentIdValues) {
    final values = enrollmentIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'enrollmentId', values);
  }

  Future<Id> putByEnrollmentId(SubjectEnrollmentIsar object) {
    return putByIndex(r'enrollmentId', object);
  }

  Id putByEnrollmentIdSync(SubjectEnrollmentIsar object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'enrollmentId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEnrollmentId(List<SubjectEnrollmentIsar> objects) {
    return putAllByIndex(r'enrollmentId', objects);
  }

  List<Id> putAllByEnrollmentIdSync(List<SubjectEnrollmentIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'enrollmentId', objects, saveLinks: saveLinks);
  }
}

extension SubjectEnrollmentIsarQueryWhereSort
    on QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QWhere> {
  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubjectEnrollmentIsarQueryWhere on QueryBuilder<SubjectEnrollmentIsar,
    SubjectEnrollmentIsar, QWhereClause> {
  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
      enrollmentIdEqualTo(String enrollmentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'enrollmentId',
        value: [enrollmentId],
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
      enrollmentIdNotEqualTo(String enrollmentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'enrollmentId',
              lower: [],
              upper: [enrollmentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'enrollmentId',
              lower: [enrollmentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'enrollmentId',
              lower: [enrollmentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'enrollmentId',
              lower: [],
              upper: [enrollmentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
      schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
      studentIdEqualTo(String studentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'studentId',
        value: [studentId],
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
      studentIdNotEqualTo(String studentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studentId',
              lower: [],
              upper: [studentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studentId',
              lower: [studentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studentId',
              lower: [studentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studentId',
              lower: [],
              upper: [studentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
      subjectIdEqualTo(String subjectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subjectId',
        value: [subjectId],
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
      subjectIdNotEqualTo(String subjectId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [],
              upper: [subjectId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [subjectId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [subjectId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [],
              upper: [subjectId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
      classIdEqualTo(String classId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'classId',
        value: [classId],
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
      classIdNotEqualTo(String classId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'classId',
              lower: [],
              upper: [classId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'classId',
              lower: [classId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'classId',
              lower: [classId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'classId',
              lower: [],
              upper: [classId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
      academicYearIdEqualTo(String academicYearId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'academicYearId',
        value: [academicYearId],
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterWhereClause>
      academicYearIdNotEqualTo(String academicYearId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'academicYearId',
              lower: [],
              upper: [academicYearId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'academicYearId',
              lower: [academicYearId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'academicYearId',
              lower: [academicYearId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'academicYearId',
              lower: [],
              upper: [academicYearId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SubjectEnrollmentIsarQueryFilter on QueryBuilder<
    SubjectEnrollmentIsar, SubjectEnrollmentIsar, QFilterCondition> {
  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> academicYearIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> academicYearIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> academicYearIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> academicYearIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'academicYearId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> academicYearIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> academicYearIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      academicYearIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      academicYearIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'academicYearId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> academicYearIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> academicYearIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> campusIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> campusIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> campusIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> campusIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'campusId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> campusIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> campusIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      campusIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      campusIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'campusId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> campusIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> campusIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> classIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> classIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> classIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> classIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'classId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> classIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> classIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      classIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      classIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'classId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> classIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> classIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> effectiveFromIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'effectiveFrom',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> effectiveFromIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'effectiveFrom',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> effectiveFromEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'effectiveFrom',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> effectiveFromGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'effectiveFrom',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> effectiveFromLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'effectiveFrom',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> effectiveFromBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'effectiveFrom',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> effectiveToIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'effectiveTo',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> effectiveToIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'effectiveTo',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> effectiveToEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'effectiveTo',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> effectiveToGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'effectiveTo',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> effectiveToLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'effectiveTo',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> effectiveToBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'effectiveTo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrolledAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enrolledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrolledAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'enrolledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrolledAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'enrolledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrolledAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'enrolledAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrolledByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enrolledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrolledByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'enrolledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrolledByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'enrolledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrolledByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'enrolledBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrolledByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'enrolledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrolledByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'enrolledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      enrolledByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'enrolledBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      enrolledByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'enrolledBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrolledByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enrolledBy',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrolledByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'enrolledBy',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrollmentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enrollmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrollmentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'enrollmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrollmentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'enrollmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrollmentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'enrollmentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrollmentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'enrollmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrollmentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'enrollmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      enrollmentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'enrollmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      enrollmentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'enrollmentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrollmentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enrollmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> enrollmentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'enrollmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> isMandatoryEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMandatory',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removalReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'removalReason',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removalReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'removalReason',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removalReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'removalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removalReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'removalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removalReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'removalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removalReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'removalReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removalReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'removalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removalReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'removalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      removalReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'removalReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      removalReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'removalReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removalReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'removalReason',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removalReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'removalReason',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'removedAt',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'removedAt',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'removedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'removedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'removedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'removedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'removedBy',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'removedBy',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'removedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'removedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'removedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'removedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'removedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'removedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      removedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'removedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      removedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'removedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'removedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> removedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'removedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> streamIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> streamIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> streamIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> streamIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> streamIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> streamIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streamId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> streamIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> streamIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      streamIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      streamIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streamId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> streamIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> streamIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> studentIdEqualTo(
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> studentIdGreaterThan(
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> studentIdLessThan(
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> studentIdBetween(
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> studentIdStartsWith(
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> studentIdEndsWith(
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      studentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      studentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'studentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> studentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> studentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> subjectIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> subjectIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> subjectIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> subjectIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> subjectIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> subjectIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      subjectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
          QAfterFilterCondition>
      subjectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> subjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> subjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectId',
        value: '',
      ));
    });
  }
}

extension SubjectEnrollmentIsarQueryObject on QueryBuilder<
    SubjectEnrollmentIsar, SubjectEnrollmentIsar, QFilterCondition> {}

extension SubjectEnrollmentIsarQueryLinks on QueryBuilder<SubjectEnrollmentIsar,
    SubjectEnrollmentIsar, QFilterCondition> {}

extension SubjectEnrollmentIsarQuerySortBy
    on QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QSortBy> {
  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByEffectiveFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveFrom', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByEffectiveFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveFrom', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByEffectiveTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveTo', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByEffectiveToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveTo', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByEnrolledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrolledAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByEnrolledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrolledAt', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByEnrolledBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrolledBy', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByEnrolledByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrolledBy', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByEnrollmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrollmentId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByEnrollmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrollmentId', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByIsMandatory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMandatory', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByIsMandatoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMandatory', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByRemovalReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removalReason', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByRemovalReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removalReason', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByRemovedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removedAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByRemovedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removedAt', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByRemovedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removedBy', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByRemovedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removedBy', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }
}

extension SubjectEnrollmentIsarQuerySortThenBy
    on QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QSortThenBy> {
  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByEffectiveFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveFrom', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByEffectiveFromDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveFrom', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByEffectiveTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveTo', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByEffectiveToDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveTo', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByEnrolledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrolledAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByEnrolledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrolledAt', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByEnrolledBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrolledBy', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByEnrolledByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrolledBy', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByEnrollmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrollmentId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByEnrollmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrollmentId', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByIsMandatory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMandatory', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByIsMandatoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMandatory', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByRemovalReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removalReason', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByRemovalReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removalReason', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByRemovedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removedAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByRemovedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removedAt', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByRemovedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removedBy', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByRemovedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'removedBy', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }
}

extension SubjectEnrollmentIsarQueryWhereDistinct
    on QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct> {
  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByAcademicYearId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'academicYearId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByCampusId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'campusId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByClassId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByEffectiveFrom() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effectiveFrom');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByEffectiveTo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effectiveTo');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByEnrolledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enrolledAt');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByEnrolledBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enrolledBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByEnrollmentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enrollmentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByIsMandatory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMandatory');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByRemovalReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'removalReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByRemovedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'removedAt');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByRemovedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'removedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByStreamId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctByStudentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QDistinct>
      distinctBySubjectId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectId', caseSensitive: caseSensitive);
    });
  }
}

extension SubjectEnrollmentIsarQueryProperty on QueryBuilder<
    SubjectEnrollmentIsar, SubjectEnrollmentIsar, QQueryProperty> {
  QueryBuilder<SubjectEnrollmentIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, String, QQueryOperations>
      academicYearIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'academicYearId');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, String, QQueryOperations>
      campusIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campusId');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, String, QQueryOperations>
      classIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classId');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, DateTime?, QQueryOperations>
      effectiveFromProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effectiveFrom');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, DateTime?, QQueryOperations>
      effectiveToProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effectiveTo');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, DateTime, QQueryOperations>
      enrolledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enrolledAt');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, String, QQueryOperations>
      enrolledByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enrolledBy');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, String, QQueryOperations>
      enrollmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enrollmentId');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, bool, QQueryOperations>
      isMandatoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMandatory');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, String?, QQueryOperations>
      removalReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'removalReason');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, DateTime?, QQueryOperations>
      removedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'removedAt');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, String?, QQueryOperations>
      removedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'removedBy');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, String, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, String?, QQueryOperations>
      streamIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamId');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, String, QQueryOperations>
      studentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studentId');
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, String, QQueryOperations>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubjectTeacherOfflineOperationIsarCollection on Isar {
  IsarCollection<SubjectTeacherOfflineOperationIsar>
      get subjectTeacherOfflineOperationIsars => this.collection();
}

const SubjectTeacherOfflineOperationIsarSchema = CollectionSchema(
  name: r'SubjectTeacherOfflineOperationIsar',
  id: 2014210292882834400,
  properties: {
    r'action': PropertySchema(
      id: 0,
      name: r'action',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deviceId': PropertySchema(
      id: 2,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'entityId': PropertySchema(
      id: 3,
      name: r'entityId',
      type: IsarType.string,
    ),
    r'entityType': PropertySchema(
      id: 4,
      name: r'entityType',
      type: IsarType.string,
    ),
    r'lastError': PropertySchema(
      id: 5,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'operationId': PropertySchema(
      id: 6,
      name: r'operationId',
      type: IsarType.string,
    ),
    r'payloadJson': PropertySchema(
      id: 7,
      name: r'payloadJson',
      type: IsarType.string,
    ),
    r'retryCount': PropertySchema(
      id: 8,
      name: r'retryCount',
      type: IsarType.long,
    ),
    r'roleAssignmentId': PropertySchema(
      id: 9,
      name: r'roleAssignmentId',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 10,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 11,
      name: r'status',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 12,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _subjectTeacherOfflineOperationIsarEstimateSize,
  serialize: _subjectTeacherOfflineOperationIsarSerialize,
  deserialize: _subjectTeacherOfflineOperationIsarDeserialize,
  deserializeProp: _subjectTeacherOfflineOperationIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'operationId': IndexSchema(
      id: 7498062369325286803,
      name: r'operationId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'operationId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'entityType': IndexSchema(
      id: -5109706325448941117,
      name: r'entityType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entityType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
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
  getId: _subjectTeacherOfflineOperationIsarGetId,
  getLinks: _subjectTeacherOfflineOperationIsarGetLinks,
  attach: _subjectTeacherOfflineOperationIsarAttach,
  version: '3.1.0+1',
);

int _subjectTeacherOfflineOperationIsarEstimateSize(
  SubjectTeacherOfflineOperationIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.action.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.entityId.length * 3;
  bytesCount += 3 + object.entityType.length * 3;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.operationId.length * 3;
  bytesCount += 3 + object.payloadJson.length * 3;
  bytesCount += 3 + object.roleAssignmentId.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _subjectTeacherOfflineOperationIsarSerialize(
  SubjectTeacherOfflineOperationIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.action);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.deviceId);
  writer.writeString(offsets[3], object.entityId);
  writer.writeString(offsets[4], object.entityType);
  writer.writeString(offsets[5], object.lastError);
  writer.writeString(offsets[6], object.operationId);
  writer.writeString(offsets[7], object.payloadJson);
  writer.writeLong(offsets[8], object.retryCount);
  writer.writeString(offsets[9], object.roleAssignmentId);
  writer.writeString(offsets[10], object.schoolId);
  writer.writeString(offsets[11], object.status);
  writer.writeString(offsets[12], object.userId);
}

SubjectTeacherOfflineOperationIsar
    _subjectTeacherOfflineOperationIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubjectTeacherOfflineOperationIsar();
  object.action = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.deviceId = reader.readString(offsets[2]);
  object.entityId = reader.readString(offsets[3]);
  object.entityType = reader.readString(offsets[4]);
  object.id = id;
  object.lastError = reader.readStringOrNull(offsets[5]);
  object.operationId = reader.readString(offsets[6]);
  object.payloadJson = reader.readString(offsets[7]);
  object.retryCount = reader.readLong(offsets[8]);
  object.roleAssignmentId = reader.readString(offsets[9]);
  object.schoolId = reader.readString(offsets[10]);
  object.status = reader.readString(offsets[11]);
  object.userId = reader.readString(offsets[12]);
  return object;
}

P _subjectTeacherOfflineOperationIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _subjectTeacherOfflineOperationIsarGetId(
    SubjectTeacherOfflineOperationIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _subjectTeacherOfflineOperationIsarGetLinks(
    SubjectTeacherOfflineOperationIsar object) {
  return [];
}

void _subjectTeacherOfflineOperationIsarAttach(IsarCollection<dynamic> col,
    Id id, SubjectTeacherOfflineOperationIsar object) {
  object.id = id;
}

extension SubjectTeacherOfflineOperationIsarByIndex
    on IsarCollection<SubjectTeacherOfflineOperationIsar> {
  Future<SubjectTeacherOfflineOperationIsar?> getByOperationId(
      String operationId) {
    return getByIndex(r'operationId', [operationId]);
  }

  SubjectTeacherOfflineOperationIsar? getByOperationIdSync(String operationId) {
    return getByIndexSync(r'operationId', [operationId]);
  }

  Future<bool> deleteByOperationId(String operationId) {
    return deleteByIndex(r'operationId', [operationId]);
  }

  bool deleteByOperationIdSync(String operationId) {
    return deleteByIndexSync(r'operationId', [operationId]);
  }

  Future<List<SubjectTeacherOfflineOperationIsar?>> getAllByOperationId(
      List<String> operationIdValues) {
    final values = operationIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'operationId', values);
  }

  List<SubjectTeacherOfflineOperationIsar?> getAllByOperationIdSync(
      List<String> operationIdValues) {
    final values = operationIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'operationId', values);
  }

  Future<int> deleteAllByOperationId(List<String> operationIdValues) {
    final values = operationIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'operationId', values);
  }

  int deleteAllByOperationIdSync(List<String> operationIdValues) {
    final values = operationIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'operationId', values);
  }

  Future<Id> putByOperationId(SubjectTeacherOfflineOperationIsar object) {
    return putByIndex(r'operationId', object);
  }

  Id putByOperationIdSync(SubjectTeacherOfflineOperationIsar object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'operationId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOperationId(
      List<SubjectTeacherOfflineOperationIsar> objects) {
    return putAllByIndex(r'operationId', objects);
  }

  List<Id> putAllByOperationIdSync(
      List<SubjectTeacherOfflineOperationIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'operationId', objects, saveLinks: saveLinks);
  }
}

extension SubjectTeacherOfflineOperationIsarQueryWhereSort on QueryBuilder<
    SubjectTeacherOfflineOperationIsar,
    SubjectTeacherOfflineOperationIsar,
    QWhere> {
  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubjectTeacherOfflineOperationIsarQueryWhere on QueryBuilder<
    SubjectTeacherOfflineOperationIsar,
    SubjectTeacherOfflineOperationIsar,
    QWhereClause> {
  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterWhereClause> operationIdEqualTo(String operationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'operationId',
        value: [operationId],
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterWhereClause> operationIdNotEqualTo(String operationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationId',
              lower: [],
              upper: [operationId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationId',
              lower: [operationId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationId',
              lower: [operationId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'operationId',
              lower: [],
              upper: [operationId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterWhereClause> entityTypeEqualTo(String entityType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entityType',
        value: [entityType],
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterWhereClause> entityTypeNotEqualTo(String entityType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType',
              lower: [],
              upper: [entityType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType',
              lower: [entityType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType',
              lower: [entityType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entityType',
              lower: [],
              upper: [entityType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterWhereClause> statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterWhereClause> statusNotEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterWhereClause> schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterWhereClause> schoolIdNotEqualTo(String schoolId) {
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

extension SubjectTeacherOfflineOperationIsarQueryFilter on QueryBuilder<
    SubjectTeacherOfflineOperationIsar,
    SubjectTeacherOfflineOperationIsar,
    QFilterCondition> {
  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> actionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> actionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> actionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> actionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'action',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> actionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> actionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      actionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'action',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      actionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'action',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> actionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'action',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> actionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'action',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      entityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      entityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      entityTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      entityTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> entityTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityType',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> operationIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> operationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'operationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> operationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'operationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> operationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'operationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> operationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'operationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> operationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'operationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      operationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'operationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      operationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'operationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> operationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'operationId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> operationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'operationId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      payloadJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'payloadJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      payloadJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'payloadJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> payloadJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payloadJson',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> payloadJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'payloadJson',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> retryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'retryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> roleAssignmentIdEqualTo(
    String value, {
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> roleAssignmentIdGreaterThan(
    String value, {
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> roleAssignmentIdLessThan(
    String value, {
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> roleAssignmentIdBetween(
    String lower,
    String upper, {
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      roleAssignmentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'roleAssignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      roleAssignmentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'roleAssignmentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> roleAssignmentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleAssignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> roleAssignmentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roleAssignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> statusEqualTo(
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> statusLessThan(
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

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> statusBetween(
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> statusEndsWith(
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

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterFilterCondition> userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
          SubjectTeacherOfflineOperationIsar, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension SubjectTeacherOfflineOperationIsarQueryObject on QueryBuilder<
    SubjectTeacherOfflineOperationIsar,
    SubjectTeacherOfflineOperationIsar,
    QFilterCondition> {}

extension SubjectTeacherOfflineOperationIsarQueryLinks on QueryBuilder<
    SubjectTeacherOfflineOperationIsar,
    SubjectTeacherOfflineOperationIsar,
    QFilterCondition> {}

extension SubjectTeacherOfflineOperationIsarQuerySortBy on QueryBuilder<
    SubjectTeacherOfflineOperationIsar,
    SubjectTeacherOfflineOperationIsar,
    QSortBy> {
  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByOperationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationId', Sort.asc);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterSortBy> sortByOperationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationId', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByPayloadJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.asc);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterSortBy> sortByPayloadJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterSortBy> sortByRoleAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.asc);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterSortBy> sortByRoleAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SubjectTeacherOfflineOperationIsarQuerySortThenBy on QueryBuilder<
    SubjectTeacherOfflineOperationIsar,
    SubjectTeacherOfflineOperationIsar,
    QSortThenBy> {
  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'action', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByEntityType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByEntityTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityType', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByOperationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationId', Sort.asc);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterSortBy> thenByOperationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'operationId', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByPayloadJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.asc);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterSortBy> thenByPayloadJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryCount', Sort.desc);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterSortBy> thenByRoleAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.asc);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterSortBy> thenByRoleAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension SubjectTeacherOfflineOperationIsarQueryWhereDistinct on QueryBuilder<
    SubjectTeacherOfflineOperationIsar,
    SubjectTeacherOfflineOperationIsar,
    QDistinct> {
  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QDistinct> distinctByAction({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'action', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QDistinct> distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QDistinct> distinctByEntityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QDistinct> distinctByEntityType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QDistinct> distinctByLastError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QDistinct> distinctByOperationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'operationId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QDistinct> distinctByPayloadJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payloadJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QDistinct> distinctByRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryCount');
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QDistinct> distinctByRoleAssignmentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roleAssignmentId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QDistinct> distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QDistinct> distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QDistinct> distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension SubjectTeacherOfflineOperationIsarQueryProperty on QueryBuilder<
    SubjectTeacherOfflineOperationIsar,
    SubjectTeacherOfflineOperationIsar,
    QQueryProperty> {
  QueryBuilder<SubjectTeacherOfflineOperationIsar, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar, String, QQueryOperations>
      actionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'action');
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar, String, QQueryOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar, String, QQueryOperations>
      entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar, String, QQueryOperations>
      entityTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityType');
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar, String?, QQueryOperations>
      lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar, String, QQueryOperations>
      operationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'operationId');
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar, String, QQueryOperations>
      payloadJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payloadJson');
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar, int, QQueryOperations>
      retryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryCount');
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar, String, QQueryOperations>
      roleAssignmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roleAssignmentId');
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar, String, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<SubjectTeacherOfflineOperationIsar, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
