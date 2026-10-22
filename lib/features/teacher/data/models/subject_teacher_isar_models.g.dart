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
    r'isPrimary': PropertySchema(
      id: 11,
      name: r'isPrimary',
      type: IsarType.bool,
    ),
    r'monthlyBonusAmount': PropertySchema(
      id: 12,
      name: r'monthlyBonusAmount',
      type: IsarType.double,
    ),
    r'permissions': PropertySchema(
      id: 13,
      name: r'permissions',
      type: IsarType.stringList,
    ),
    r'roleDefinitionId': PropertySchema(
      id: 14,
      name: r'roleDefinitionId',
      type: IsarType.string,
    ),
    r'roleType': PropertySchema(
      id: 15,
      name: r'roleType',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 16,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'scopeTermIds': PropertySchema(
      id: 17,
      name: r'scopeTermIds',
      type: IsarType.stringList,
    ),
    r'staffId': PropertySchema(
      id: 18,
      name: r'staffId',
      type: IsarType.string,
    ),
    r'startDate': PropertySchema(
      id: 19,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 20,
      name: r'status',
      type: IsarType.string,
    ),
    r'streamId': PropertySchema(
      id: 21,
      name: r'streamId',
      type: IsarType.string,
    ),
    r'streamName': PropertySchema(
      id: 22,
      name: r'streamName',
      type: IsarType.string,
    ),
    r'subjectId': PropertySchema(
      id: 23,
      name: r'subjectId',
      type: IsarType.string,
    ),
    r'subjectName': PropertySchema(
      id: 24,
      name: r'subjectName',
      type: IsarType.string,
    ),
    r'substituteForStaffId': PropertySchema(
      id: 25,
      name: r'substituteForStaffId',
      type: IsarType.string,
    ),
    r'termId': PropertySchema(
      id: 26,
      name: r'termId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 27,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'updatedBy': PropertySchema(
      id: 28,
      name: r'updatedBy',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 29,
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
  bytesCount += 3 + object.roleDefinitionId.length * 3;
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
  writer.writeBool(offsets[11], object.isPrimary);
  writer.writeDouble(offsets[12], object.monthlyBonusAmount);
  writer.writeStringList(offsets[13], object.permissions);
  writer.writeString(offsets[14], object.roleDefinitionId);
  writer.writeString(offsets[15], object.roleType);
  writer.writeString(offsets[16], object.schoolId);
  writer.writeStringList(offsets[17], object.scopeTermIds);
  writer.writeString(offsets[18], object.staffId);
  writer.writeDateTime(offsets[19], object.startDate);
  writer.writeString(offsets[20], object.status);
  writer.writeString(offsets[21], object.streamId);
  writer.writeString(offsets[22], object.streamName);
  writer.writeString(offsets[23], object.subjectId);
  writer.writeString(offsets[24], object.subjectName);
  writer.writeString(offsets[25], object.substituteForStaffId);
  writer.writeString(offsets[26], object.termId);
  writer.writeDateTime(offsets[27], object.updatedAt);
  writer.writeString(offsets[28], object.updatedBy);
  writer.writeString(offsets[29], object.userId);
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
  object.isPrimary = reader.readBool(offsets[11]);
  object.monthlyBonusAmount = reader.readDoubleOrNull(offsets[12]);
  object.permissions = reader.readStringList(offsets[13]) ?? [];
  object.roleDefinitionId = reader.readString(offsets[14]);
  object.roleType = reader.readString(offsets[15]);
  object.schoolId = reader.readString(offsets[16]);
  object.scopeTermIds = reader.readStringList(offsets[17]) ?? [];
  object.staffId = reader.readString(offsets[18]);
  object.startDate = reader.readDateTime(offsets[19]);
  object.status = reader.readString(offsets[20]);
  object.streamId = reader.readStringOrNull(offsets[21]);
  object.streamName = reader.readStringOrNull(offsets[22]);
  object.subjectId = reader.readStringOrNull(offsets[23]);
  object.subjectName = reader.readStringOrNull(offsets[24]);
  object.substituteForStaffId = reader.readStringOrNull(offsets[25]);
  object.termId = reader.readStringOrNull(offsets[26]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[27]);
  object.updatedBy = reader.readStringOrNull(offsets[28]);
  object.userId = reader.readString(offsets[29]);
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
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    case 13:
      return (reader.readStringList(offset) ?? []) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readStringList(offset) ?? []) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readDateTime(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 28:
      return (reader.readStringOrNull(offset)) as P;
    case 29:
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
      QAfterFilterCondition> isPrimaryEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPrimary',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> monthlyBonusAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'monthlyBonusAmount',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> monthlyBonusAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'monthlyBonusAmount',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> monthlyBonusAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthlyBonusAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> monthlyBonusAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monthlyBonusAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> monthlyBonusAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monthlyBonusAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> monthlyBonusAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monthlyBonusAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
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
      QAfterFilterCondition> roleDefinitionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleDefinitionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleDefinitionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'roleDefinitionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleDefinitionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'roleDefinitionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleDefinitionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'roleDefinitionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleDefinitionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'roleDefinitionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleDefinitionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'roleDefinitionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      roleDefinitionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'roleDefinitionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
          QAfterFilterCondition>
      roleDefinitionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'roleDefinitionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleDefinitionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleDefinitionId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar,
      QAfterFilterCondition> roleDefinitionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roleDefinitionId',
        value: '',
      ));
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
      sortByIsPrimary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrimary', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByIsPrimaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrimary', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByMonthlyBonusAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyBonusAmount', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByMonthlyBonusAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyBonusAmount', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByRoleDefinitionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleDefinitionId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      sortByRoleDefinitionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleDefinitionId', Sort.desc);
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
      thenByIsPrimary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrimary', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByIsPrimaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPrimary', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByMonthlyBonusAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyBonusAmount', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByMonthlyBonusAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthlyBonusAmount', Sort.desc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByRoleDefinitionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleDefinitionId', Sort.asc);
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QAfterSortBy>
      thenByRoleDefinitionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleDefinitionId', Sort.desc);
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
      distinctByIsPrimary() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPrimary');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByMonthlyBonusAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monthlyBonusAmount');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByPermissions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permissions');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, StaffRoleAssignmentIsar, QDistinct>
      distinctByRoleDefinitionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roleDefinitionId',
          caseSensitive: caseSensitive);
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

  QueryBuilder<StaffRoleAssignmentIsar, bool, QQueryOperations>
      isPrimaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPrimary');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, double?, QQueryOperations>
      monthlyBonusAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthlyBonusAmount');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, List<String>, QQueryOperations>
      permissionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permissions');
    });
  }

  QueryBuilder<StaffRoleAssignmentIsar, String, QQueryOperations>
      roleDefinitionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roleDefinitionId');
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
    r'roleAssignmentId': PropertySchema(
      id: 12,
      name: r'roleAssignmentId',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 13,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 14,
      name: r'status',
      type: IsarType.string,
    ),
    r'streamId': PropertySchema(
      id: 15,
      name: r'streamId',
      type: IsarType.string,
    ),
    r'studentId': PropertySchema(
      id: 16,
      name: r'studentId',
      type: IsarType.string,
    ),
    r'subjectId': PropertySchema(
      id: 17,
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
  bytesCount += 3 + object.roleAssignmentId.length * 3;
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
  writer.writeString(offsets[12], object.roleAssignmentId);
  writer.writeString(offsets[13], object.schoolId);
  writer.writeString(offsets[14], object.status);
  writer.writeString(offsets[15], object.streamId);
  writer.writeString(offsets[16], object.studentId);
  writer.writeString(offsets[17], object.subjectId);
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
  object.roleAssignmentId = reader.readString(offsets[12]);
  object.schoolId = reader.readString(offsets[13]);
  object.status = reader.readString(offsets[14]);
  object.streamId = reader.readStringOrNull(offsets[15]);
  object.studentId = reader.readString(offsets[16]);
  object.subjectId = reader.readString(offsets[17]);
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
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
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

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> roleAssignmentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleAssignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar,
      QAfterFilterCondition> roleAssignmentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roleAssignmentId',
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
      sortByRoleAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      sortByRoleAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.desc);
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
      thenByRoleAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.asc);
    });
  }

  QueryBuilder<SubjectEnrollmentIsar, SubjectEnrollmentIsar, QAfterSortBy>
      thenByRoleAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.desc);
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
      distinctByRoleAssignmentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roleAssignmentId',
          caseSensitive: caseSensitive);
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
      roleAssignmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roleAssignmentId');
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
    r'nextRetryAt': PropertySchema(
      id: 6,
      name: r'nextRetryAt',
      type: IsarType.dateTime,
    ),
    r'operationId': PropertySchema(
      id: 7,
      name: r'operationId',
      type: IsarType.string,
    ),
    r'payloadJson': PropertySchema(
      id: 8,
      name: r'payloadJson',
      type: IsarType.string,
    ),
    r'retryCount': PropertySchema(
      id: 9,
      name: r'retryCount',
      type: IsarType.long,
    ),
    r'roleAssignmentId': PropertySchema(
      id: 10,
      name: r'roleAssignmentId',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 11,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 12,
      name: r'status',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 13,
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
  writer.writeDateTime(offsets[6], object.nextRetryAt);
  writer.writeString(offsets[7], object.operationId);
  writer.writeString(offsets[8], object.payloadJson);
  writer.writeLong(offsets[9], object.retryCount);
  writer.writeString(offsets[10], object.roleAssignmentId);
  writer.writeString(offsets[11], object.schoolId);
  writer.writeString(offsets[12], object.status);
  writer.writeString(offsets[13], object.userId);
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
  object.nextRetryAt = reader.readDateTimeOrNull(offsets[6]);
  object.operationId = reader.readString(offsets[7]);
  object.payloadJson = reader.readString(offsets[8]);
  object.retryCount = reader.readLong(offsets[9]);
  object.roleAssignmentId = reader.readString(offsets[10]);
  object.schoolId = reader.readString(offsets[11]);
  object.status = reader.readString(offsets[12]);
  object.userId = reader.readString(offsets[13]);
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
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
      QAfterFilterCondition> nextRetryAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextRetryAt',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> nextRetryAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextRetryAt',
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterFilterCondition> nextRetryAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextRetryAt',
        value: value,
      ));
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
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
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> sortByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.asc);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterSortBy> sortByNextRetryAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.desc);
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
      SubjectTeacherOfflineOperationIsar, QAfterSortBy> thenByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.asc);
    });
  }

  QueryBuilder<
      SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar,
      QAfterSortBy> thenByNextRetryAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.desc);
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

  QueryBuilder<SubjectTeacherOfflineOperationIsar,
      SubjectTeacherOfflineOperationIsar, QDistinct> distinctByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextRetryAt');
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

  QueryBuilder<SubjectTeacherOfflineOperationIsar, DateTime?, QQueryOperations>
      nextRetryAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextRetryAt');
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

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLessonIsarCollection on Isar {
  IsarCollection<LessonIsar> get lessonIsars => this.collection();
}

const LessonIsarSchema = CollectionSchema(
  name: r'LessonIsar',
  id: -5169964325402194336,
  properties: {
    r'academicYearId': PropertySchema(
      id: 0,
      name: r'academicYearId',
      type: IsarType.string,
    ),
    r'actualEnd': PropertySchema(
      id: 1,
      name: r'actualEnd',
      type: IsarType.dateTime,
    ),
    r'actualStart': PropertySchema(
      id: 2,
      name: r'actualStart',
      type: IsarType.dateTime,
    ),
    r'attendanceSubmitted': PropertySchema(
      id: 3,
      name: r'attendanceSubmitted',
      type: IsarType.bool,
    ),
    r'campusId': PropertySchema(
      id: 4,
      name: r'campusId',
      type: IsarType.string,
    ),
    r'classId': PropertySchema(
      id: 5,
      name: r'classId',
      type: IsarType.string,
    ),
    r'className': PropertySchema(
      id: 6,
      name: r'className',
      type: IsarType.string,
    ),
    r'enrolledCount': PropertySchema(
      id: 7,
      name: r'enrolledCount',
      type: IsarType.long,
    ),
    r'lessonId': PropertySchema(
      id: 8,
      name: r'lessonId',
      type: IsarType.string,
    ),
    r'lessonNoteCount': PropertySchema(
      id: 9,
      name: r'lessonNoteCount',
      type: IsarType.long,
    ),
    r'relatedAssessmentId': PropertySchema(
      id: 10,
      name: r'relatedAssessmentId',
      type: IsarType.string,
    ),
    r'resourceCount': PropertySchema(
      id: 11,
      name: r'resourceCount',
      type: IsarType.long,
    ),
    r'room': PropertySchema(
      id: 12,
      name: r'room',
      type: IsarType.string,
    ),
    r'scheduledEnd': PropertySchema(
      id: 13,
      name: r'scheduledEnd',
      type: IsarType.dateTime,
    ),
    r'scheduledStart': PropertySchema(
      id: 14,
      name: r'scheduledStart',
      type: IsarType.dateTime,
    ),
    r'schoolId': PropertySchema(
      id: 15,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 16,
      name: r'status',
      type: IsarType.string,
    ),
    r'statusReason': PropertySchema(
      id: 17,
      name: r'statusReason',
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
    r'substituteStaffId': PropertySchema(
      id: 22,
      name: r'substituteStaffId',
      type: IsarType.string,
    ),
    r'subtopic': PropertySchema(
      id: 23,
      name: r'subtopic',
      type: IsarType.string,
    ),
    r'teacherStaffId': PropertySchema(
      id: 24,
      name: r'teacherStaffId',
      type: IsarType.string,
    ),
    r'termId': PropertySchema(
      id: 25,
      name: r'termId',
      type: IsarType.string,
    ),
    r'timetableSlotId': PropertySchema(
      id: 26,
      name: r'timetableSlotId',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 27,
      name: r'title',
      type: IsarType.string,
    ),
    r'topic': PropertySchema(
      id: 28,
      name: r'topic',
      type: IsarType.string,
    )
  },
  estimateSize: _lessonIsarEstimateSize,
  serialize: _lessonIsarSerialize,
  deserialize: _lessonIsarDeserialize,
  deserializeProp: _lessonIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'lessonId': IndexSchema(
      id: 2130166291500416829,
      name: r'lessonId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'lessonId',
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
    r'teacherStaffId': IndexSchema(
      id: -359714737199388209,
      name: r'teacherStaffId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'teacherStaffId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'scheduledStart': IndexSchema(
      id: -3096438766822159990,
      name: r'scheduledStart',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'scheduledStart',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _lessonIsarGetId,
  getLinks: _lessonIsarGetLinks,
  attach: _lessonIsarAttach,
  version: '3.1.0+1',
);

int _lessonIsarEstimateSize(
  LessonIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.academicYearId.length * 3;
  bytesCount += 3 + object.campusId.length * 3;
  bytesCount += 3 + object.classId.length * 3;
  bytesCount += 3 + object.className.length * 3;
  bytesCount += 3 + object.lessonId.length * 3;
  {
    final value = object.relatedAssessmentId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.room;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  {
    final value = object.statusReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
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
  bytesCount += 3 + object.subjectId.length * 3;
  bytesCount += 3 + object.subjectName.length * 3;
  {
    final value = object.substituteStaffId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.subtopic;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.teacherStaffId.length * 3;
  bytesCount += 3 + object.termId.length * 3;
  bytesCount += 3 + object.timetableSlotId.length * 3;
  bytesCount += 3 + object.title.length * 3;
  {
    final value = object.topic;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _lessonIsarSerialize(
  LessonIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.academicYearId);
  writer.writeDateTime(offsets[1], object.actualEnd);
  writer.writeDateTime(offsets[2], object.actualStart);
  writer.writeBool(offsets[3], object.attendanceSubmitted);
  writer.writeString(offsets[4], object.campusId);
  writer.writeString(offsets[5], object.classId);
  writer.writeString(offsets[6], object.className);
  writer.writeLong(offsets[7], object.enrolledCount);
  writer.writeString(offsets[8], object.lessonId);
  writer.writeLong(offsets[9], object.lessonNoteCount);
  writer.writeString(offsets[10], object.relatedAssessmentId);
  writer.writeLong(offsets[11], object.resourceCount);
  writer.writeString(offsets[12], object.room);
  writer.writeDateTime(offsets[13], object.scheduledEnd);
  writer.writeDateTime(offsets[14], object.scheduledStart);
  writer.writeString(offsets[15], object.schoolId);
  writer.writeString(offsets[16], object.status);
  writer.writeString(offsets[17], object.statusReason);
  writer.writeString(offsets[18], object.streamId);
  writer.writeString(offsets[19], object.streamName);
  writer.writeString(offsets[20], object.subjectId);
  writer.writeString(offsets[21], object.subjectName);
  writer.writeString(offsets[22], object.substituteStaffId);
  writer.writeString(offsets[23], object.subtopic);
  writer.writeString(offsets[24], object.teacherStaffId);
  writer.writeString(offsets[25], object.termId);
  writer.writeString(offsets[26], object.timetableSlotId);
  writer.writeString(offsets[27], object.title);
  writer.writeString(offsets[28], object.topic);
}

LessonIsar _lessonIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LessonIsar();
  object.academicYearId = reader.readString(offsets[0]);
  object.actualEnd = reader.readDateTimeOrNull(offsets[1]);
  object.actualStart = reader.readDateTimeOrNull(offsets[2]);
  object.attendanceSubmitted = reader.readBool(offsets[3]);
  object.campusId = reader.readString(offsets[4]);
  object.classId = reader.readString(offsets[5]);
  object.className = reader.readString(offsets[6]);
  object.enrolledCount = reader.readLong(offsets[7]);
  object.id = id;
  object.lessonId = reader.readString(offsets[8]);
  object.lessonNoteCount = reader.readLong(offsets[9]);
  object.relatedAssessmentId = reader.readStringOrNull(offsets[10]);
  object.resourceCount = reader.readLong(offsets[11]);
  object.room = reader.readStringOrNull(offsets[12]);
  object.scheduledEnd = reader.readDateTime(offsets[13]);
  object.scheduledStart = reader.readDateTime(offsets[14]);
  object.schoolId = reader.readString(offsets[15]);
  object.status = reader.readString(offsets[16]);
  object.statusReason = reader.readStringOrNull(offsets[17]);
  object.streamId = reader.readStringOrNull(offsets[18]);
  object.streamName = reader.readStringOrNull(offsets[19]);
  object.subjectId = reader.readString(offsets[20]);
  object.subjectName = reader.readString(offsets[21]);
  object.substituteStaffId = reader.readStringOrNull(offsets[22]);
  object.subtopic = reader.readStringOrNull(offsets[23]);
  object.teacherStaffId = reader.readString(offsets[24]);
  object.termId = reader.readString(offsets[25]);
  object.timetableSlotId = reader.readString(offsets[26]);
  object.title = reader.readString(offsets[27]);
  object.topic = reader.readStringOrNull(offsets[28]);
  return object;
}

P _lessonIsarDeserializeProp<P>(
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readString(offset)) as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readString(offset)) as P;
    case 28:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _lessonIsarGetId(LessonIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _lessonIsarGetLinks(LessonIsar object) {
  return [];
}

void _lessonIsarAttach(IsarCollection<dynamic> col, Id id, LessonIsar object) {
  object.id = id;
}

extension LessonIsarByIndex on IsarCollection<LessonIsar> {
  Future<LessonIsar?> getByLessonId(String lessonId) {
    return getByIndex(r'lessonId', [lessonId]);
  }

  LessonIsar? getByLessonIdSync(String lessonId) {
    return getByIndexSync(r'lessonId', [lessonId]);
  }

  Future<bool> deleteByLessonId(String lessonId) {
    return deleteByIndex(r'lessonId', [lessonId]);
  }

  bool deleteByLessonIdSync(String lessonId) {
    return deleteByIndexSync(r'lessonId', [lessonId]);
  }

  Future<List<LessonIsar?>> getAllByLessonId(List<String> lessonIdValues) {
    final values = lessonIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'lessonId', values);
  }

  List<LessonIsar?> getAllByLessonIdSync(List<String> lessonIdValues) {
    final values = lessonIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'lessonId', values);
  }

  Future<int> deleteAllByLessonId(List<String> lessonIdValues) {
    final values = lessonIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'lessonId', values);
  }

  int deleteAllByLessonIdSync(List<String> lessonIdValues) {
    final values = lessonIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'lessonId', values);
  }

  Future<Id> putByLessonId(LessonIsar object) {
    return putByIndex(r'lessonId', object);
  }

  Id putByLessonIdSync(LessonIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'lessonId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLessonId(List<LessonIsar> objects) {
    return putAllByIndex(r'lessonId', objects);
  }

  List<Id> putAllByLessonIdSync(List<LessonIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'lessonId', objects, saveLinks: saveLinks);
  }
}

extension LessonIsarQueryWhereSort
    on QueryBuilder<LessonIsar, LessonIsar, QWhere> {
  QueryBuilder<LessonIsar, LessonIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhere> anyScheduledStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'scheduledStart'),
      );
    });
  }
}

extension LessonIsarQueryWhere
    on QueryBuilder<LessonIsar, LessonIsar, QWhereClause> {
  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> lessonIdEqualTo(
      String lessonId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lessonId',
        value: [lessonId],
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> lessonIdNotEqualTo(
      String lessonId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lessonId',
              lower: [],
              upper: [lessonId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lessonId',
              lower: [lessonId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lessonId',
              lower: [lessonId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lessonId',
              lower: [],
              upper: [lessonId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> schoolIdEqualTo(
      String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> schoolIdNotEqualTo(
      String schoolId) {
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> subjectIdEqualTo(
      String subjectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subjectId',
        value: [subjectId],
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> subjectIdNotEqualTo(
      String subjectId) {
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> classIdEqualTo(
      String classId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'classId',
        value: [classId],
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> classIdNotEqualTo(
      String classId) {
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> teacherStaffIdEqualTo(
      String teacherStaffId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'teacherStaffId',
        value: [teacherStaffId],
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause>
      teacherStaffIdNotEqualTo(String teacherStaffId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'teacherStaffId',
              lower: [],
              upper: [teacherStaffId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'teacherStaffId',
              lower: [teacherStaffId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'teacherStaffId',
              lower: [teacherStaffId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'teacherStaffId',
              lower: [],
              upper: [teacherStaffId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> scheduledStartEqualTo(
      DateTime scheduledStart) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'scheduledStart',
        value: [scheduledStart],
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause>
      scheduledStartNotEqualTo(DateTime scheduledStart) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledStart',
              lower: [],
              upper: [scheduledStart],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledStart',
              lower: [scheduledStart],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledStart',
              lower: [scheduledStart],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledStart',
              lower: [],
              upper: [scheduledStart],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause>
      scheduledStartGreaterThan(
    DateTime scheduledStart, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scheduledStart',
        lower: [scheduledStart],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause>
      scheduledStartLessThan(
    DateTime scheduledStart, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scheduledStart',
        lower: [],
        upper: [scheduledStart],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterWhereClause> scheduledStartBetween(
    DateTime lowerScheduledStart,
    DateTime upperScheduledStart, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'scheduledStart',
        lower: [lowerScheduledStart],
        includeLower: includeLower,
        upper: [upperScheduledStart],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LessonIsarQueryFilter
    on QueryBuilder<LessonIsar, LessonIsar, QFilterCondition> {
  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      academicYearIdEqualTo(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      academicYearIdGreaterThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      academicYearIdLessThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      academicYearIdBetween(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      academicYearIdStartsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      academicYearIdEndsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      academicYearIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      academicYearIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'academicYearId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      academicYearIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      academicYearIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      actualEndIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actualEnd',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      actualEndIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actualEnd',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> actualEndEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      actualEndGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> actualEndLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> actualEndBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualEnd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      actualStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actualStart',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      actualStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actualStart',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      actualStartEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualStart',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      actualStartGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualStart',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      actualStartLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualStart',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      actualStartBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualStart',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      attendanceSubmittedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attendanceSubmitted',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> campusIdEqualTo(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      campusIdGreaterThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> campusIdLessThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> campusIdBetween(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      campusIdStartsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> campusIdEndsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> campusIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> campusIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'campusId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      campusIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      campusIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> classIdEqualTo(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      classIdGreaterThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> classIdLessThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> classIdBetween(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> classIdStartsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> classIdEndsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> classIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> classIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'classId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> classIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      classIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> classNameEqualTo(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> classNameLessThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> classNameBetween(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> classNameEndsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> classNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> classNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'className',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      classNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'className',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      classNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'className',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      enrolledCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enrolledCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      enrolledCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'enrolledCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      enrolledCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'enrolledCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      enrolledCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'enrolledCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> lessonIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lessonId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      lessonIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lessonId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> lessonIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lessonId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> lessonIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lessonId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      lessonIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lessonId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> lessonIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lessonId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> lessonIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lessonId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> lessonIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lessonId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      lessonIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lessonId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      lessonIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lessonId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      lessonNoteCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lessonNoteCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      lessonNoteCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lessonNoteCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      lessonNoteCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lessonNoteCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      lessonNoteCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lessonNoteCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      relatedAssessmentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'relatedAssessmentId',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      relatedAssessmentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'relatedAssessmentId',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      relatedAssessmentIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedAssessmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      relatedAssessmentIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relatedAssessmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      relatedAssessmentIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relatedAssessmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      relatedAssessmentIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relatedAssessmentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      relatedAssessmentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relatedAssessmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      relatedAssessmentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relatedAssessmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      relatedAssessmentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relatedAssessmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      relatedAssessmentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relatedAssessmentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      relatedAssessmentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedAssessmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      relatedAssessmentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relatedAssessmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      resourceCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resourceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      resourceCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'resourceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      resourceCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'resourceCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      resourceCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'resourceCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> roomIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'room',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> roomIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'room',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> roomEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'room',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> roomGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'room',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> roomLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'room',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> roomBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'room',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> roomStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'room',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> roomEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'room',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> roomContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'room',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> roomMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'room',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> roomIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'room',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> roomIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'room',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      scheduledEndEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      scheduledEndGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      scheduledEndLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      scheduledEndBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledEnd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      scheduledStartEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledStart',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      scheduledStartGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledStart',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      scheduledStartLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledStart',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      scheduledStartBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledStart',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> schoolIdEqualTo(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> schoolIdLessThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> schoolIdBetween(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> schoolIdEndsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> schoolIdContains(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> schoolIdMatches(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> statusEqualTo(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> statusGreaterThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> statusLessThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> statusBetween(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> statusStartsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> statusEndsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> statusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      statusReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'statusReason',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      statusReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'statusReason',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      statusReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      statusReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'statusReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      statusReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'statusReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      statusReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'statusReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      statusReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'statusReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      statusReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'statusReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      statusReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'statusReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      statusReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'statusReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      statusReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusReason',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      statusReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'statusReason',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> streamIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      streamIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> streamIdEqualTo(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      streamIdGreaterThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> streamIdLessThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> streamIdBetween(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      streamIdStartsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> streamIdEndsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> streamIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> streamIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streamId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      streamIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      streamIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      streamNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamName',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      streamNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamName',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> streamNameEqualTo(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      streamNameGreaterThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      streamNameLessThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> streamNameBetween(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      streamNameStartsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      streamNameEndsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      streamNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streamName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> streamNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streamName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      streamNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamName',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      streamNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamName',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> subjectIdEqualTo(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subjectIdGreaterThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> subjectIdLessThan(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> subjectIdBetween(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subjectIdStartsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> subjectIdEndsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> subjectIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> subjectIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subjectNameEqualTo(
    String value, {
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subjectNameGreaterThan(
    String value, {
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subjectNameLessThan(
    String value, {
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subjectNameBetween(
    String lower,
    String upper, {
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subjectNameStartsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subjectNameEndsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subjectNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subjectNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subjectNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectName',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subjectNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectName',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      substituteStaffIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'substituteStaffId',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      substituteStaffIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'substituteStaffId',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      substituteStaffIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'substituteStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      substituteStaffIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'substituteStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      substituteStaffIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'substituteStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      substituteStaffIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'substituteStaffId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      substituteStaffIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'substituteStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      substituteStaffIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'substituteStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      substituteStaffIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'substituteStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      substituteStaffIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'substituteStaffId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      substituteStaffIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'substituteStaffId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      substituteStaffIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'substituteStaffId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> subtopicIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subtopic',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subtopicIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subtopic',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> subtopicEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtopic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subtopicGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subtopic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> subtopicLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subtopic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> subtopicBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subtopic',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subtopicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subtopic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> subtopicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subtopic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> subtopicContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subtopic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> subtopicMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subtopic',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subtopicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtopic',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      subtopicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subtopic',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      teacherStaffIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'teacherStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      teacherStaffIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'teacherStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      teacherStaffIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'teacherStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      teacherStaffIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'teacherStaffId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      teacherStaffIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'teacherStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      teacherStaffIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'teacherStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      teacherStaffIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'teacherStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      teacherStaffIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'teacherStaffId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      teacherStaffIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'teacherStaffId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      teacherStaffIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'teacherStaffId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> termIdEqualTo(
    String value, {
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> termIdGreaterThan(
    String value, {
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> termIdLessThan(
    String value, {
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> termIdBetween(
    String lower,
    String upper, {
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> termIdStartsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> termIdEndsWith(
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

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> termIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'termId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> termIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'termId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> termIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      termIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'termId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      timetableSlotIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timetableSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      timetableSlotIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timetableSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      timetableSlotIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timetableSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      timetableSlotIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timetableSlotId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      timetableSlotIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'timetableSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      timetableSlotIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'timetableSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      timetableSlotIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'timetableSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      timetableSlotIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'timetableSlotId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      timetableSlotIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timetableSlotId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      timetableSlotIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'timetableSlotId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> topicIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'topic',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> topicIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'topic',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> topicEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> topicGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> topicLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> topicBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topic',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> topicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> topicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> topicContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> topicMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'topic',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition> topicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topic',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterFilterCondition>
      topicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'topic',
        value: '',
      ));
    });
  }
}

extension LessonIsarQueryObject
    on QueryBuilder<LessonIsar, LessonIsar, QFilterCondition> {}

extension LessonIsarQueryLinks
    on QueryBuilder<LessonIsar, LessonIsar, QFilterCondition> {}

extension LessonIsarQuerySortBy
    on QueryBuilder<LessonIsar, LessonIsar, QSortBy> {
  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      sortByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByActualEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualEnd', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByActualEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualEnd', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByActualStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualStart', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByActualStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualStart', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      sortByAttendanceSubmitted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceSubmitted', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      sortByAttendanceSubmittedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceSubmitted', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByEnrolledCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrolledCount', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByEnrolledCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrolledCount', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByLessonId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByLessonIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByLessonNoteCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonNoteCount', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      sortByLessonNoteCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonNoteCount', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      sortByRelatedAssessmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedAssessmentId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      sortByRelatedAssessmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedAssessmentId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByResourceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceCount', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByResourceCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceCount', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByRoom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'room', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByRoomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'room', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByScheduledEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledEnd', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByScheduledEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledEnd', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByScheduledStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledStart', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      sortByScheduledStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledStart', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByStatusReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusReason', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByStatusReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusReason', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByStreamName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamName', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByStreamNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamName', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortBySubstituteStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'substituteStaffId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      sortBySubstituteStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'substituteStaffId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortBySubtopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtopic', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortBySubtopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtopic', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByTeacherStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacherStaffId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      sortByTeacherStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacherStaffId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByTermId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByTermIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByTimetableSlotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timetableSlotId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      sortByTimetableSlotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timetableSlotId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> sortByTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.desc);
    });
  }
}

extension LessonIsarQuerySortThenBy
    on QueryBuilder<LessonIsar, LessonIsar, QSortThenBy> {
  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      thenByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByActualEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualEnd', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByActualEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualEnd', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByActualStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualStart', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByActualStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualStart', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      thenByAttendanceSubmitted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceSubmitted', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      thenByAttendanceSubmittedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceSubmitted', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByEnrolledCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrolledCount', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByEnrolledCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enrolledCount', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByLessonId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByLessonIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByLessonNoteCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonNoteCount', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      thenByLessonNoteCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonNoteCount', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      thenByRelatedAssessmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedAssessmentId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      thenByRelatedAssessmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedAssessmentId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByResourceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceCount', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByResourceCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceCount', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByRoom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'room', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByRoomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'room', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByScheduledEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledEnd', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByScheduledEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledEnd', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByScheduledStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledStart', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      thenByScheduledStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledStart', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByStatusReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusReason', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByStatusReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusReason', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByStreamName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamName', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByStreamNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamName', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenBySubjectName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenBySubjectNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectName', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenBySubstituteStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'substituteStaffId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      thenBySubstituteStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'substituteStaffId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenBySubtopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtopic', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenBySubtopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtopic', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByTeacherStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacherStaffId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      thenByTeacherStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacherStaffId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByTermId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByTermIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByTimetableSlotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timetableSlotId', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy>
      thenByTimetableSlotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timetableSlotId', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.asc);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QAfterSortBy> thenByTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.desc);
    });
  }
}

extension LessonIsarQueryWhereDistinct
    on QueryBuilder<LessonIsar, LessonIsar, QDistinct> {
  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByAcademicYearId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'academicYearId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByActualEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualEnd');
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByActualStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualStart');
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct>
      distinctByAttendanceSubmitted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attendanceSubmitted');
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByCampusId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'campusId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByClassId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByClassName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'className', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByEnrolledCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enrolledCount');
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByLessonId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lessonId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByLessonNoteCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lessonNoteCount');
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByRelatedAssessmentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relatedAssessmentId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByResourceCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resourceCount');
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByRoom(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'room', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByScheduledEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledEnd');
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByScheduledStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledStart');
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctBySchoolId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByStatusReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statusReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByStreamId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByStreamName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctBySubjectId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctBySubjectName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctBySubstituteStaffId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'substituteStaffId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctBySubtopic(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtopic', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByTeacherStaffId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'teacherStaffId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByTermId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'termId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByTimetableSlotId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timetableSlotId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonIsar, LessonIsar, QDistinct> distinctByTopic(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topic', caseSensitive: caseSensitive);
    });
  }
}

extension LessonIsarQueryProperty
    on QueryBuilder<LessonIsar, LessonIsar, QQueryProperty> {
  QueryBuilder<LessonIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LessonIsar, String, QQueryOperations> academicYearIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'academicYearId');
    });
  }

  QueryBuilder<LessonIsar, DateTime?, QQueryOperations> actualEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualEnd');
    });
  }

  QueryBuilder<LessonIsar, DateTime?, QQueryOperations> actualStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualStart');
    });
  }

  QueryBuilder<LessonIsar, bool, QQueryOperations>
      attendanceSubmittedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attendanceSubmitted');
    });
  }

  QueryBuilder<LessonIsar, String, QQueryOperations> campusIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campusId');
    });
  }

  QueryBuilder<LessonIsar, String, QQueryOperations> classIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classId');
    });
  }

  QueryBuilder<LessonIsar, String, QQueryOperations> classNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'className');
    });
  }

  QueryBuilder<LessonIsar, int, QQueryOperations> enrolledCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enrolledCount');
    });
  }

  QueryBuilder<LessonIsar, String, QQueryOperations> lessonIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lessonId');
    });
  }

  QueryBuilder<LessonIsar, int, QQueryOperations> lessonNoteCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lessonNoteCount');
    });
  }

  QueryBuilder<LessonIsar, String?, QQueryOperations>
      relatedAssessmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relatedAssessmentId');
    });
  }

  QueryBuilder<LessonIsar, int, QQueryOperations> resourceCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resourceCount');
    });
  }

  QueryBuilder<LessonIsar, String?, QQueryOperations> roomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'room');
    });
  }

  QueryBuilder<LessonIsar, DateTime, QQueryOperations> scheduledEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledEnd');
    });
  }

  QueryBuilder<LessonIsar, DateTime, QQueryOperations>
      scheduledStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledStart');
    });
  }

  QueryBuilder<LessonIsar, String, QQueryOperations> schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<LessonIsar, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<LessonIsar, String?, QQueryOperations> statusReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statusReason');
    });
  }

  QueryBuilder<LessonIsar, String?, QQueryOperations> streamIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamId');
    });
  }

  QueryBuilder<LessonIsar, String?, QQueryOperations> streamNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamName');
    });
  }

  QueryBuilder<LessonIsar, String, QQueryOperations> subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectId');
    });
  }

  QueryBuilder<LessonIsar, String, QQueryOperations> subjectNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectName');
    });
  }

  QueryBuilder<LessonIsar, String?, QQueryOperations>
      substituteStaffIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'substituteStaffId');
    });
  }

  QueryBuilder<LessonIsar, String?, QQueryOperations> subtopicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtopic');
    });
  }

  QueryBuilder<LessonIsar, String, QQueryOperations> teacherStaffIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'teacherStaffId');
    });
  }

  QueryBuilder<LessonIsar, String, QQueryOperations> termIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'termId');
    });
  }

  QueryBuilder<LessonIsar, String, QQueryOperations> timetableSlotIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timetableSlotId');
    });
  }

  QueryBuilder<LessonIsar, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<LessonIsar, String?, QQueryOperations> topicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topic');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLessonAttendanceIsarCollection on Isar {
  IsarCollection<LessonAttendanceIsar> get lessonAttendanceIsars =>
      this.collection();
}

const LessonAttendanceIsarSchema = CollectionSchema(
  name: r'LessonAttendanceIsar',
  id: -3047831940479390368,
  properties: {
    r'academicYearId': PropertySchema(
      id: 0,
      name: r'academicYearId',
      type: IsarType.string,
    ),
    r'attendanceId': PropertySchema(
      id: 1,
      name: r'attendanceId',
      type: IsarType.string,
    ),
    r'campusId': PropertySchema(
      id: 2,
      name: r'campusId',
      type: IsarType.string,
    ),
    r'classId': PropertySchema(
      id: 3,
      name: r'classId',
      type: IsarType.string,
    ),
    r'deviceId': PropertySchema(
      id: 4,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'entries': PropertySchema(
      id: 5,
      name: r'entries',
      type: IsarType.objectList,
      target: r'LessonAttendanceEntryIsar',
    ),
    r'lessonId': PropertySchema(
      id: 6,
      name: r'lessonId',
      type: IsarType.string,
    ),
    r'roleAssignmentId': PropertySchema(
      id: 7,
      name: r'roleAssignmentId',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 8,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'staffId': PropertySchema(
      id: 9,
      name: r'staffId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 10,
      name: r'status',
      type: IsarType.string,
    ),
    r'streamId': PropertySchema(
      id: 11,
      name: r'streamId',
      type: IsarType.string,
    ),
    r'subjectId': PropertySchema(
      id: 12,
      name: r'subjectId',
      type: IsarType.string,
    ),
    r'submittedAt': PropertySchema(
      id: 13,
      name: r'submittedAt',
      type: IsarType.dateTime,
    ),
    r'termId': PropertySchema(
      id: 14,
      name: r'termId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 15,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _lessonAttendanceIsarEstimateSize,
  serialize: _lessonAttendanceIsarSerialize,
  deserialize: _lessonAttendanceIsarDeserialize,
  deserializeProp: _lessonAttendanceIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'lessonId': IndexSchema(
      id: 2130166291500416829,
      name: r'lessonId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'lessonId',
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
    )
  },
  links: {},
  embeddedSchemas: {
    r'LessonAttendanceEntryIsar': LessonAttendanceEntryIsarSchema
  },
  getId: _lessonAttendanceIsarGetId,
  getLinks: _lessonAttendanceIsarGetLinks,
  attach: _lessonAttendanceIsarAttach,
  version: '3.1.0+1',
);

int _lessonAttendanceIsarEstimateSize(
  LessonAttendanceIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.academicYearId.length * 3;
  bytesCount += 3 + object.attendanceId.length * 3;
  bytesCount += 3 + object.campusId.length * 3;
  bytesCount += 3 + object.classId.length * 3;
  {
    final value = object.deviceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.entries.length * 3;
  {
    final offsets = allOffsets[LessonAttendanceEntryIsar]!;
    for (var i = 0; i < object.entries.length; i++) {
      final value = object.entries[i];
      bytesCount += LessonAttendanceEntryIsarSchema.estimateSize(
          value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.lessonId.length * 3;
  bytesCount += 3 + object.roleAssignmentId.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.staffId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  {
    final value = object.streamId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.subjectId.length * 3;
  bytesCount += 3 + object.termId.length * 3;
  return bytesCount;
}

void _lessonAttendanceIsarSerialize(
  LessonAttendanceIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.academicYearId);
  writer.writeString(offsets[1], object.attendanceId);
  writer.writeString(offsets[2], object.campusId);
  writer.writeString(offsets[3], object.classId);
  writer.writeString(offsets[4], object.deviceId);
  writer.writeObjectList<LessonAttendanceEntryIsar>(
    offsets[5],
    allOffsets,
    LessonAttendanceEntryIsarSchema.serialize,
    object.entries,
  );
  writer.writeString(offsets[6], object.lessonId);
  writer.writeString(offsets[7], object.roleAssignmentId);
  writer.writeString(offsets[8], object.schoolId);
  writer.writeString(offsets[9], object.staffId);
  writer.writeString(offsets[10], object.status);
  writer.writeString(offsets[11], object.streamId);
  writer.writeString(offsets[12], object.subjectId);
  writer.writeDateTime(offsets[13], object.submittedAt);
  writer.writeString(offsets[14], object.termId);
  writer.writeDateTime(offsets[15], object.updatedAt);
}

LessonAttendanceIsar _lessonAttendanceIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LessonAttendanceIsar();
  object.academicYearId = reader.readString(offsets[0]);
  object.attendanceId = reader.readString(offsets[1]);
  object.campusId = reader.readString(offsets[2]);
  object.classId = reader.readString(offsets[3]);
  object.deviceId = reader.readStringOrNull(offsets[4]);
  object.entries = reader.readObjectList<LessonAttendanceEntryIsar>(
        offsets[5],
        LessonAttendanceEntryIsarSchema.deserialize,
        allOffsets,
        LessonAttendanceEntryIsar(),
      ) ??
      [];
  object.id = id;
  object.lessonId = reader.readString(offsets[6]);
  object.roleAssignmentId = reader.readString(offsets[7]);
  object.schoolId = reader.readString(offsets[8]);
  object.staffId = reader.readString(offsets[9]);
  object.status = reader.readString(offsets[10]);
  object.streamId = reader.readStringOrNull(offsets[11]);
  object.subjectId = reader.readString(offsets[12]);
  object.submittedAt = reader.readDateTimeOrNull(offsets[13]);
  object.termId = reader.readString(offsets[14]);
  object.updatedAt = reader.readDateTime(offsets[15]);
  return object;
}

P _lessonAttendanceIsarDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readObjectList<LessonAttendanceEntryIsar>(
            offset,
            LessonAttendanceEntryIsarSchema.deserialize,
            allOffsets,
            LessonAttendanceEntryIsar(),
          ) ??
          []) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _lessonAttendanceIsarGetId(LessonAttendanceIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _lessonAttendanceIsarGetLinks(
    LessonAttendanceIsar object) {
  return [];
}

void _lessonAttendanceIsarAttach(
    IsarCollection<dynamic> col, Id id, LessonAttendanceIsar object) {
  object.id = id;
}

extension LessonAttendanceIsarByIndex on IsarCollection<LessonAttendanceIsar> {
  Future<LessonAttendanceIsar?> getByLessonId(String lessonId) {
    return getByIndex(r'lessonId', [lessonId]);
  }

  LessonAttendanceIsar? getByLessonIdSync(String lessonId) {
    return getByIndexSync(r'lessonId', [lessonId]);
  }

  Future<bool> deleteByLessonId(String lessonId) {
    return deleteByIndex(r'lessonId', [lessonId]);
  }

  bool deleteByLessonIdSync(String lessonId) {
    return deleteByIndexSync(r'lessonId', [lessonId]);
  }

  Future<List<LessonAttendanceIsar?>> getAllByLessonId(
      List<String> lessonIdValues) {
    final values = lessonIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'lessonId', values);
  }

  List<LessonAttendanceIsar?> getAllByLessonIdSync(
      List<String> lessonIdValues) {
    final values = lessonIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'lessonId', values);
  }

  Future<int> deleteAllByLessonId(List<String> lessonIdValues) {
    final values = lessonIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'lessonId', values);
  }

  int deleteAllByLessonIdSync(List<String> lessonIdValues) {
    final values = lessonIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'lessonId', values);
  }

  Future<Id> putByLessonId(LessonAttendanceIsar object) {
    return putByIndex(r'lessonId', object);
  }

  Id putByLessonIdSync(LessonAttendanceIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'lessonId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLessonId(List<LessonAttendanceIsar> objects) {
    return putAllByIndex(r'lessonId', objects);
  }

  List<Id> putAllByLessonIdSync(List<LessonAttendanceIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'lessonId', objects, saveLinks: saveLinks);
  }
}

extension LessonAttendanceIsarQueryWhereSort
    on QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QWhere> {
  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LessonAttendanceIsarQueryWhere
    on QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QWhereClause> {
  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterWhereClause>
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterWhereClause>
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterWhereClause>
      lessonIdEqualTo(String lessonId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lessonId',
        value: [lessonId],
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterWhereClause>
      lessonIdNotEqualTo(String lessonId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lessonId',
              lower: [],
              upper: [lessonId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lessonId',
              lower: [lessonId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lessonId',
              lower: [lessonId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lessonId',
              lower: [],
              upper: [lessonId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterWhereClause>
      schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterWhereClause>
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterWhereClause>
      subjectIdEqualTo(String subjectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subjectId',
        value: [subjectId],
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterWhereClause>
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterWhereClause>
      statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterWhereClause>
      statusNotEqualTo(String status) {
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
}

extension LessonAttendanceIsarQueryFilter on QueryBuilder<LessonAttendanceIsar,
    LessonAttendanceIsar, QFilterCondition> {
  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> academicYearIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> academicYearIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> attendanceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attendanceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> attendanceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attendanceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> attendanceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attendanceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> attendanceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attendanceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> attendanceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'attendanceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> attendanceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'attendanceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
          QAfterFilterCondition>
      attendanceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'attendanceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
          QAfterFilterCondition>
      attendanceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'attendanceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> attendanceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attendanceId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> attendanceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'attendanceId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> campusIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> campusIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> classIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> classIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> deviceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deviceId',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> deviceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deviceId',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> deviceIdEqualTo(
    String? value, {
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> deviceIdGreaterThan(
    String? value, {
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> deviceIdLessThan(
    String? value, {
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> deviceIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> entriesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'entries',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> entriesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'entries',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> entriesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'entries',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> entriesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'entries',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> entriesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'entries',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> entriesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'entries',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> lessonIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lessonId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> lessonIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lessonId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> lessonIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lessonId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> lessonIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lessonId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> lessonIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lessonId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> lessonIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lessonId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
          QAfterFilterCondition>
      lessonIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lessonId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
          QAfterFilterCondition>
      lessonIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lessonId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> lessonIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lessonId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> lessonIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lessonId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> roleAssignmentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleAssignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> roleAssignmentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roleAssignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> staffIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'staffId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> staffIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'staffId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> streamIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> streamIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> streamIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> streamIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> subjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> subjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> submittedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'submittedAt',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> submittedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'submittedAt',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> submittedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'submittedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> submittedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'submittedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> submittedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'submittedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> submittedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'submittedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> termIdEqualTo(
    String value, {
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> termIdGreaterThan(
    String value, {
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> termIdLessThan(
    String value, {
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> termIdBetween(
    String lower,
    String upper, {
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> termIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> termIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'termId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
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

extension LessonAttendanceIsarQueryObject on QueryBuilder<LessonAttendanceIsar,
    LessonAttendanceIsar, QFilterCondition> {
  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar,
          QAfterFilterCondition>
      entriesElement(FilterQuery<LessonAttendanceEntryIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'entries');
    });
  }
}

extension LessonAttendanceIsarQueryLinks on QueryBuilder<LessonAttendanceIsar,
    LessonAttendanceIsar, QFilterCondition> {}

extension LessonAttendanceIsarQuerySortBy
    on QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QSortBy> {
  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByAttendanceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByAttendanceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByLessonId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByLessonIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByRoleAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByRoleAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortBySubmittedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByTermId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByTermIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LessonAttendanceIsarQuerySortThenBy
    on QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QSortThenBy> {
  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByAttendanceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByAttendanceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByLessonId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByLessonIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lessonId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByRoleAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByRoleAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenBySubmittedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByTermId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByTermIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.desc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension LessonAttendanceIsarQueryWhereDistinct
    on QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct> {
  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctByAcademicYearId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'academicYearId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctByAttendanceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attendanceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctByCampusId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'campusId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctByClassId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctByLessonId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lessonId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctByRoleAssignmentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roleAssignmentId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctByStaffId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'staffId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctByStreamId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctBySubjectId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'submittedAt');
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctByTermId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'termId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LessonAttendanceIsar, LessonAttendanceIsar, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension LessonAttendanceIsarQueryProperty on QueryBuilder<
    LessonAttendanceIsar, LessonAttendanceIsar, QQueryProperty> {
  QueryBuilder<LessonAttendanceIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LessonAttendanceIsar, String, QQueryOperations>
      academicYearIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'academicYearId');
    });
  }

  QueryBuilder<LessonAttendanceIsar, String, QQueryOperations>
      attendanceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attendanceId');
    });
  }

  QueryBuilder<LessonAttendanceIsar, String, QQueryOperations>
      campusIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campusId');
    });
  }

  QueryBuilder<LessonAttendanceIsar, String, QQueryOperations>
      classIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classId');
    });
  }

  QueryBuilder<LessonAttendanceIsar, String?, QQueryOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<LessonAttendanceIsar, List<LessonAttendanceEntryIsar>,
      QQueryOperations> entriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entries');
    });
  }

  QueryBuilder<LessonAttendanceIsar, String, QQueryOperations>
      lessonIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lessonId');
    });
  }

  QueryBuilder<LessonAttendanceIsar, String, QQueryOperations>
      roleAssignmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roleAssignmentId');
    });
  }

  QueryBuilder<LessonAttendanceIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<LessonAttendanceIsar, String, QQueryOperations>
      staffIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'staffId');
    });
  }

  QueryBuilder<LessonAttendanceIsar, String, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<LessonAttendanceIsar, String?, QQueryOperations>
      streamIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamId');
    });
  }

  QueryBuilder<LessonAttendanceIsar, String, QQueryOperations>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectId');
    });
  }

  QueryBuilder<LessonAttendanceIsar, DateTime?, QQueryOperations>
      submittedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'submittedAt');
    });
  }

  QueryBuilder<LessonAttendanceIsar, String, QQueryOperations>
      termIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'termId');
    });
  }

  QueryBuilder<LessonAttendanceIsar, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const LessonAttendanceEntryIsarSchema = Schema(
  name: r'LessonAttendanceEntryIsar',
  id: -205858137302790696,
  properties: {
    r'markedAt': PropertySchema(
      id: 0,
      name: r'markedAt',
      type: IsarType.dateTime,
    ),
    r'note': PropertySchema(
      id: 1,
      name: r'note',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 2,
      name: r'status',
      type: IsarType.string,
    ),
    r'studentId': PropertySchema(
      id: 3,
      name: r'studentId',
      type: IsarType.string,
    )
  },
  estimateSize: _lessonAttendanceEntryIsarEstimateSize,
  serialize: _lessonAttendanceEntryIsarSerialize,
  deserialize: _lessonAttendanceEntryIsarDeserialize,
  deserializeProp: _lessonAttendanceEntryIsarDeserializeProp,
);

int _lessonAttendanceEntryIsarEstimateSize(
  LessonAttendanceEntryIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.status;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.studentId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _lessonAttendanceEntryIsarSerialize(
  LessonAttendanceEntryIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.markedAt);
  writer.writeString(offsets[1], object.note);
  writer.writeString(offsets[2], object.status);
  writer.writeString(offsets[3], object.studentId);
}

LessonAttendanceEntryIsar _lessonAttendanceEntryIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LessonAttendanceEntryIsar();
  object.markedAt = reader.readDateTimeOrNull(offsets[0]);
  object.note = reader.readStringOrNull(offsets[1]);
  object.status = reader.readStringOrNull(offsets[2]);
  object.studentId = reader.readStringOrNull(offsets[3]);
  return object;
}

P _lessonAttendanceEntryIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension LessonAttendanceEntryIsarQueryFilter on QueryBuilder<
    LessonAttendanceEntryIsar, LessonAttendanceEntryIsar, QFilterCondition> {
  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> markedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'markedAt',
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> markedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'markedAt',
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> markedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'markedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> markedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'markedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> markedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'markedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> markedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'markedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
          QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
          QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> statusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> statusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'status',
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> statusEqualTo(
    String? value, {
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> statusGreaterThan(
    String? value, {
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> statusLessThan(
    String? value, {
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> statusBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> studentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'studentId',
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> studentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'studentId',
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> studentIdEqualTo(
    String? value, {
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> studentIdGreaterThan(
    String? value, {
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> studentIdLessThan(
    String? value, {
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> studentIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
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

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> studentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<LessonAttendanceEntryIsar, LessonAttendanceEntryIsar,
      QAfterFilterCondition> studentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'studentId',
        value: '',
      ));
    });
  }
}

extension LessonAttendanceEntryIsarQueryObject on QueryBuilder<
    LessonAttendanceEntryIsar, LessonAttendanceEntryIsar, QFilterCondition> {}
