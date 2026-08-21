// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_resource_isar_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSubjectResourceIsarCollection on Isar {
  IsarCollection<SubjectResourceIsar> get subjectResourceIsars =>
      this.collection();
}

const SubjectResourceIsarSchema = CollectionSchema(
  name: r'SubjectResourceIsar',
  id: 6973133716611751033,
  properties: {
    r'academicYearId': PropertySchema(
      id: 0,
      name: r'academicYearId',
      type: IsarType.string,
    ),
    r'audience': PropertySchema(
      id: 1,
      name: r'audience',
      type: IsarType.string,
    ),
    r'availableOffline': PropertySchema(
      id: 2,
      name: r'availableOffline',
      type: IsarType.bool,
    ),
    r'cachedAt': PropertySchema(
      id: 3,
      name: r'cachedAt',
      type: IsarType.dateTime,
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
    r'description': PropertySchema(
      id: 6,
      name: r'description',
      type: IsarType.string,
    ),
    r'downloadCount': PropertySchema(
      id: 7,
      name: r'downloadCount',
      type: IsarType.long,
    ),
    r'downloadUrl': PropertySchema(
      id: 8,
      name: r'downloadUrl',
      type: IsarType.string,
    ),
    r'externalUrl': PropertySchema(
      id: 9,
      name: r'externalUrl',
      type: IsarType.string,
    ),
    r'folderId': PropertySchema(
      id: 10,
      name: r'folderId',
      type: IsarType.string,
    ),
    r'kind': PropertySchema(
      id: 11,
      name: r'kind',
      type: IsarType.string,
    ),
    r'localFilePath': PropertySchema(
      id: 12,
      name: r'localFilePath',
      type: IsarType.string,
    ),
    r'mimeType': PropertySchema(
      id: 13,
      name: r'mimeType',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 14,
      name: r'name',
      type: IsarType.string,
    ),
    r'origin': PropertySchema(
      id: 15,
      name: r'origin',
      type: IsarType.string,
    ),
    r'resourceId': PropertySchema(
      id: 16,
      name: r'resourceId',
      type: IsarType.string,
    ),
    r'roleAssignmentId': PropertySchema(
      id: 17,
      name: r'roleAssignmentId',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 18,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'sizeBytes': PropertySchema(
      id: 19,
      name: r'sizeBytes',
      type: IsarType.long,
    ),
    r'sourceResourceId': PropertySchema(
      id: 20,
      name: r'sourceResourceId',
      type: IsarType.string,
    ),
    r'storagePath': PropertySchema(
      id: 21,
      name: r'storagePath',
      type: IsarType.string,
    ),
    r'streamId': PropertySchema(
      id: 22,
      name: r'streamId',
      type: IsarType.string,
    ),
    r'subjectId': PropertySchema(
      id: 23,
      name: r'subjectId',
      type: IsarType.string,
    ),
    r'termId': PropertySchema(
      id: 24,
      name: r'termId',
      type: IsarType.string,
    ),
    r'uploadedAt': PropertySchema(
      id: 25,
      name: r'uploadedAt',
      type: IsarType.dateTime,
    ),
    r'uploadedByUserId': PropertySchema(
      id: 26,
      name: r'uploadedByUserId',
      type: IsarType.string,
    )
  },
  estimateSize: _subjectResourceIsarEstimateSize,
  serialize: _subjectResourceIsarSerialize,
  deserialize: _subjectResourceIsarDeserialize,
  deserializeProp: _subjectResourceIsarDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'resourceId': IndexSchema(
      id: 8413634267385686812,
      name: r'resourceId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'resourceId',
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _subjectResourceIsarGetId,
  getLinks: _subjectResourceIsarGetLinks,
  attach: _subjectResourceIsarAttach,
  version: '3.1.0+1',
);

int _subjectResourceIsarEstimateSize(
  SubjectResourceIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.academicYearId.length * 3;
  bytesCount += 3 + object.audience.length * 3;
  bytesCount += 3 + object.campusId.length * 3;
  bytesCount += 3 + object.classId.length * 3;
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.downloadUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.externalUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.folderId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.kind.length * 3;
  {
    final value = object.localFilePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.mimeType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.origin.length * 3;
  bytesCount += 3 + object.resourceId.length * 3;
  bytesCount += 3 + object.roleAssignmentId.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  {
    final value = object.sourceResourceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.storagePath;
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
  bytesCount += 3 + object.subjectId.length * 3;
  {
    final value = object.termId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.uploadedByUserId.length * 3;
  return bytesCount;
}

void _subjectResourceIsarSerialize(
  SubjectResourceIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.academicYearId);
  writer.writeString(offsets[1], object.audience);
  writer.writeBool(offsets[2], object.availableOffline);
  writer.writeDateTime(offsets[3], object.cachedAt);
  writer.writeString(offsets[4], object.campusId);
  writer.writeString(offsets[5], object.classId);
  writer.writeString(offsets[6], object.description);
  writer.writeLong(offsets[7], object.downloadCount);
  writer.writeString(offsets[8], object.downloadUrl);
  writer.writeString(offsets[9], object.externalUrl);
  writer.writeString(offsets[10], object.folderId);
  writer.writeString(offsets[11], object.kind);
  writer.writeString(offsets[12], object.localFilePath);
  writer.writeString(offsets[13], object.mimeType);
  writer.writeString(offsets[14], object.name);
  writer.writeString(offsets[15], object.origin);
  writer.writeString(offsets[16], object.resourceId);
  writer.writeString(offsets[17], object.roleAssignmentId);
  writer.writeString(offsets[18], object.schoolId);
  writer.writeLong(offsets[19], object.sizeBytes);
  writer.writeString(offsets[20], object.sourceResourceId);
  writer.writeString(offsets[21], object.storagePath);
  writer.writeString(offsets[22], object.streamId);
  writer.writeString(offsets[23], object.subjectId);
  writer.writeString(offsets[24], object.termId);
  writer.writeDateTime(offsets[25], object.uploadedAt);
  writer.writeString(offsets[26], object.uploadedByUserId);
}

SubjectResourceIsar _subjectResourceIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SubjectResourceIsar();
  object.academicYearId = reader.readString(offsets[0]);
  object.audience = reader.readString(offsets[1]);
  object.availableOffline = reader.readBool(offsets[2]);
  object.cachedAt = reader.readDateTime(offsets[3]);
  object.campusId = reader.readString(offsets[4]);
  object.classId = reader.readString(offsets[5]);
  object.description = reader.readStringOrNull(offsets[6]);
  object.downloadCount = reader.readLong(offsets[7]);
  object.downloadUrl = reader.readStringOrNull(offsets[8]);
  object.externalUrl = reader.readStringOrNull(offsets[9]);
  object.folderId = reader.readStringOrNull(offsets[10]);
  object.kind = reader.readString(offsets[11]);
  object.localFilePath = reader.readStringOrNull(offsets[12]);
  object.mimeType = reader.readStringOrNull(offsets[13]);
  object.name = reader.readString(offsets[14]);
  object.origin = reader.readString(offsets[15]);
  object.resourceId = reader.readString(offsets[16]);
  object.roleAssignmentId = reader.readString(offsets[17]);
  object.schoolId = reader.readString(offsets[18]);
  object.sizeBytes = reader.readLongOrNull(offsets[19]);
  object.sourceResourceId = reader.readStringOrNull(offsets[20]);
  object.storagePath = reader.readStringOrNull(offsets[21]);
  object.streamId = reader.readStringOrNull(offsets[22]);
  object.subjectId = reader.readString(offsets[23]);
  object.termId = reader.readStringOrNull(offsets[24]);
  object.uploadedAt = reader.readDateTime(offsets[25]);
  object.uploadedByUserId = reader.readString(offsets[26]);
  return object;
}

P _subjectResourceIsarDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readLongOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readDateTime(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _subjectResourceIsarGetId(SubjectResourceIsar object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _subjectResourceIsarGetLinks(
    SubjectResourceIsar object) {
  return [];
}

void _subjectResourceIsarAttach(
    IsarCollection<dynamic> col, Id id, SubjectResourceIsar object) {}

extension SubjectResourceIsarByIndex on IsarCollection<SubjectResourceIsar> {
  Future<SubjectResourceIsar?> getByResourceId(String resourceId) {
    return getByIndex(r'resourceId', [resourceId]);
  }

  SubjectResourceIsar? getByResourceIdSync(String resourceId) {
    return getByIndexSync(r'resourceId', [resourceId]);
  }

  Future<bool> deleteByResourceId(String resourceId) {
    return deleteByIndex(r'resourceId', [resourceId]);
  }

  bool deleteByResourceIdSync(String resourceId) {
    return deleteByIndexSync(r'resourceId', [resourceId]);
  }

  Future<List<SubjectResourceIsar?>> getAllByResourceId(
      List<String> resourceIdValues) {
    final values = resourceIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'resourceId', values);
  }

  List<SubjectResourceIsar?> getAllByResourceIdSync(
      List<String> resourceIdValues) {
    final values = resourceIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'resourceId', values);
  }

  Future<int> deleteAllByResourceId(List<String> resourceIdValues) {
    final values = resourceIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'resourceId', values);
  }

  int deleteAllByResourceIdSync(List<String> resourceIdValues) {
    final values = resourceIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'resourceId', values);
  }

  Future<Id> putByResourceId(SubjectResourceIsar object) {
    return putByIndex(r'resourceId', object);
  }

  Id putByResourceIdSync(SubjectResourceIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'resourceId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByResourceId(List<SubjectResourceIsar> objects) {
    return putAllByIndex(r'resourceId', objects);
  }

  List<Id> putAllByResourceIdSync(List<SubjectResourceIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'resourceId', objects, saveLinks: saveLinks);
  }
}

extension SubjectResourceIsarQueryWhereSort
    on QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QWhere> {
  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SubjectResourceIsarQueryWhere
    on QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QWhereClause> {
  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterWhereClause>
      isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterWhereClause>
      isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterWhereClause>
      resourceIdEqualTo(String resourceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'resourceId',
        value: [resourceId],
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterWhereClause>
      resourceIdNotEqualTo(String resourceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'resourceId',
              lower: [],
              upper: [resourceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'resourceId',
              lower: [resourceId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'resourceId',
              lower: [resourceId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'resourceId',
              lower: [],
              upper: [resourceId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterWhereClause>
      schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterWhereClause>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterWhereClause>
      subjectIdEqualTo(String subjectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subjectId',
        value: [subjectId],
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterWhereClause>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterWhereClause>
      classIdEqualTo(String classId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'classId',
        value: [classId],
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterWhereClause>
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
}

extension SubjectResourceIsarQueryFilter on QueryBuilder<SubjectResourceIsar,
    SubjectResourceIsar, QFilterCondition> {
  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      academicYearIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      academicYearIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'academicYearId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      academicYearIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      academicYearIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      audienceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audience',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      audienceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'audience',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      audienceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'audience',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      audienceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'audience',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      audienceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'audience',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      audienceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'audience',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      audienceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'audience',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      audienceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'audience',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      audienceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audience',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      audienceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'audience',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      availableOfflineEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'availableOffline',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      cachedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      cachedAtGreaterThan(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      cachedAtLessThan(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      cachedAtBetween(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      campusIdEqualTo(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      campusIdLessThan(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      campusIdBetween(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      campusIdEndsWith(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      campusIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      campusIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'campusId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      campusIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      campusIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      classIdEqualTo(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      classIdLessThan(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      classIdBetween(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      classIdStartsWith(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      classIdEndsWith(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      classIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      classIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'classId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      classIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      classIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downloadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downloadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downloadCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'downloadUrl',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'downloadUrl',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downloadUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downloadUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downloadUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'downloadUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'downloadUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'downloadUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'downloadUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      downloadUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'downloadUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      externalUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'externalUrl',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      externalUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'externalUrl',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      externalUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'externalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      externalUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'externalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      externalUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'externalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      externalUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'externalUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      externalUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'externalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      externalUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'externalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      externalUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'externalUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      externalUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'externalUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      externalUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'externalUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      externalUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'externalUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      folderIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'folderId',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      folderIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'folderId',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      folderIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'folderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      folderIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'folderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      folderIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'folderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      folderIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'folderId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      folderIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'folderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      folderIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'folderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      folderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'folderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      folderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'folderId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      folderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'folderId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      folderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'folderId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      kindEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      kindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      kindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      kindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kind',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      kindStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      kindEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      kindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      kindMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'kind',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      localFilePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localFilePath',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      localFilePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localFilePath',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      localFilePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      localFilePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      localFilePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      localFilePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localFilePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      localFilePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      localFilePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      localFilePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      localFilePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localFilePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      localFilePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      localFilePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      mimeTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mimeType',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      mimeTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mimeType',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      mimeTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mimeType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      mimeTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mimeType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      mimeTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mimeType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      mimeTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mimeType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      mimeTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mimeType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      mimeTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mimeType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      mimeTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mimeType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      mimeTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mimeType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      mimeTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mimeType',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      mimeTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mimeType',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      nameEqualTo(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      nameGreaterThan(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      nameLessThan(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      nameBetween(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      nameStartsWith(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      nameEndsWith(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      originEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      originGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      originLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      originBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'origin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      originStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      originEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      originContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      originMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'origin',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      originIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origin',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      originIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'origin',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      resourceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      resourceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'resourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      resourceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'resourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      resourceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'resourceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      resourceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'resourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      resourceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'resourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      resourceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'resourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      resourceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'resourceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      resourceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'resourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      resourceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'resourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      roleAssignmentIdEqualTo(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      roleAssignmentIdGreaterThan(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      roleAssignmentIdLessThan(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      roleAssignmentIdBetween(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      roleAssignmentIdStartsWith(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      roleAssignmentIdEndsWith(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      roleAssignmentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'roleAssignmentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      roleAssignmentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'roleAssignmentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      roleAssignmentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleAssignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      roleAssignmentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roleAssignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sizeBytesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sizeBytes',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sizeBytesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sizeBytes',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sizeBytesEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sizeBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sizeBytesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sizeBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sizeBytesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sizeBytes',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sizeBytesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sizeBytes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sourceResourceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceResourceId',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sourceResourceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceResourceId',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sourceResourceIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceResourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sourceResourceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceResourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sourceResourceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceResourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sourceResourceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceResourceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sourceResourceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceResourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sourceResourceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceResourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sourceResourceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceResourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sourceResourceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceResourceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sourceResourceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceResourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      sourceResourceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceResourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      storagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'storagePath',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      storagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'storagePath',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      storagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      storagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'storagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      storagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'storagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      storagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'storagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      storagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'storagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      storagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'storagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      storagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'storagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      storagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'storagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      storagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      storagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'storagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      streamIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      streamIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      streamIdEqualTo(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      streamIdLessThan(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      streamIdBetween(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      streamIdEndsWith(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      streamIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      streamIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streamId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      streamIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      streamIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      subjectIdEqualTo(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      subjectIdLessThan(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      subjectIdBetween(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      subjectIdEndsWith(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      subjectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      subjectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      subjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      subjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      termIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'termId',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      termIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'termId',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      termIdEqualTo(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      termIdGreaterThan(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      termIdLessThan(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      termIdBetween(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      termIdStartsWith(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      termIdEndsWith(
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

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      termIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'termId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      termIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'termId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      termIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      termIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'termId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      uploadedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploadedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      uploadedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uploadedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      uploadedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uploadedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      uploadedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uploadedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      uploadedByUserIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploadedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      uploadedByUserIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uploadedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      uploadedByUserIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uploadedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      uploadedByUserIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uploadedByUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      uploadedByUserIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uploadedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      uploadedByUserIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uploadedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      uploadedByUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uploadedByUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      uploadedByUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uploadedByUserId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      uploadedByUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uploadedByUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterFilterCondition>
      uploadedByUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uploadedByUserId',
        value: '',
      ));
    });
  }
}

extension SubjectResourceIsarQueryObject on QueryBuilder<SubjectResourceIsar,
    SubjectResourceIsar, QFilterCondition> {}

extension SubjectResourceIsarQueryLinks on QueryBuilder<SubjectResourceIsar,
    SubjectResourceIsar, QFilterCondition> {}

extension SubjectResourceIsarQuerySortBy
    on QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QSortBy> {
  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByAudience() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audience', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByAudienceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audience', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByAvailableOffline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableOffline', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByAvailableOfflineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableOffline', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByDownloadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadCount', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByDownloadCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadCount', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByDownloadUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadUrl', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByDownloadUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadUrl', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByExternalUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalUrl', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByExternalUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalUrl', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByFolderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByLocalFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFilePath', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByLocalFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFilePath', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByMimeType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByMimeTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByOrigin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByOriginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByResourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByResourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByRoleAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByRoleAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortBySizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeBytes', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortBySizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeBytes', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortBySourceResourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceResourceId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortBySourceResourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceResourceId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByStoragePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storagePath', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByStoragePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storagePath', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByTermId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByTermIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByUploadedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByUploadedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedAt', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByUploadedByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedByUserId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      sortByUploadedByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedByUserId', Sort.desc);
    });
  }
}

extension SubjectResourceIsarQuerySortThenBy
    on QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QSortThenBy> {
  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByAudience() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audience', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByAudienceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audience', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByAvailableOffline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableOffline', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByAvailableOfflineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableOffline', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByDownloadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadCount', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByDownloadCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadCount', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByDownloadUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadUrl', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByDownloadUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadUrl', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByExternalUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalUrl', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByExternalUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'externalUrl', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByFolderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByFolderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByLocalFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFilePath', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByLocalFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFilePath', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByMimeType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByMimeTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByOrigin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByOriginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByResourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByResourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByRoleAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByRoleAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenBySizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeBytes', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenBySizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeBytes', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenBySourceResourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceResourceId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenBySourceResourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceResourceId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByStoragePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storagePath', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByStoragePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storagePath', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByTermId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByTermIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByUploadedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedAt', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByUploadedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedAt', Sort.desc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByUploadedByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedByUserId', Sort.asc);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QAfterSortBy>
      thenByUploadedByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uploadedByUserId', Sort.desc);
    });
  }
}

extension SubjectResourceIsarQueryWhereDistinct
    on QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct> {
  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByAcademicYearId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'academicYearId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByAudience({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audience', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByAvailableOffline() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'availableOffline');
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cachedAt');
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByCampusId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'campusId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByClassId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByDownloadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadCount');
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByDownloadUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByExternalUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'externalUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByFolderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'folderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByKind({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByLocalFilePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localFilePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByMimeType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mimeType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByOrigin({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origin', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByResourceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resourceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByRoleAssignmentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roleAssignmentId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctBySizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sizeBytes');
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctBySourceResourceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceResourceId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByStoragePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storagePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByStreamId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctBySubjectId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByTermId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'termId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByUploadedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uploadedAt');
    });
  }

  QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QDistinct>
      distinctByUploadedByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uploadedByUserId',
          caseSensitive: caseSensitive);
    });
  }
}

extension SubjectResourceIsarQueryProperty
    on QueryBuilder<SubjectResourceIsar, SubjectResourceIsar, QQueryProperty> {
  QueryBuilder<SubjectResourceIsar, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<SubjectResourceIsar, String, QQueryOperations>
      academicYearIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'academicYearId');
    });
  }

  QueryBuilder<SubjectResourceIsar, String, QQueryOperations>
      audienceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audience');
    });
  }

  QueryBuilder<SubjectResourceIsar, bool, QQueryOperations>
      availableOfflineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'availableOffline');
    });
  }

  QueryBuilder<SubjectResourceIsar, DateTime, QQueryOperations>
      cachedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cachedAt');
    });
  }

  QueryBuilder<SubjectResourceIsar, String, QQueryOperations>
      campusIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campusId');
    });
  }

  QueryBuilder<SubjectResourceIsar, String, QQueryOperations>
      classIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classId');
    });
  }

  QueryBuilder<SubjectResourceIsar, String?, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<SubjectResourceIsar, int, QQueryOperations>
      downloadCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadCount');
    });
  }

  QueryBuilder<SubjectResourceIsar, String?, QQueryOperations>
      downloadUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadUrl');
    });
  }

  QueryBuilder<SubjectResourceIsar, String?, QQueryOperations>
      externalUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'externalUrl');
    });
  }

  QueryBuilder<SubjectResourceIsar, String?, QQueryOperations>
      folderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'folderId');
    });
  }

  QueryBuilder<SubjectResourceIsar, String, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<SubjectResourceIsar, String?, QQueryOperations>
      localFilePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localFilePath');
    });
  }

  QueryBuilder<SubjectResourceIsar, String?, QQueryOperations>
      mimeTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mimeType');
    });
  }

  QueryBuilder<SubjectResourceIsar, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<SubjectResourceIsar, String, QQueryOperations> originProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origin');
    });
  }

  QueryBuilder<SubjectResourceIsar, String, QQueryOperations>
      resourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resourceId');
    });
  }

  QueryBuilder<SubjectResourceIsar, String, QQueryOperations>
      roleAssignmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roleAssignmentId');
    });
  }

  QueryBuilder<SubjectResourceIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<SubjectResourceIsar, int?, QQueryOperations>
      sizeBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sizeBytes');
    });
  }

  QueryBuilder<SubjectResourceIsar, String?, QQueryOperations>
      sourceResourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceResourceId');
    });
  }

  QueryBuilder<SubjectResourceIsar, String?, QQueryOperations>
      storagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storagePath');
    });
  }

  QueryBuilder<SubjectResourceIsar, String?, QQueryOperations>
      streamIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamId');
    });
  }

  QueryBuilder<SubjectResourceIsar, String, QQueryOperations>
      subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectId');
    });
  }

  QueryBuilder<SubjectResourceIsar, String?, QQueryOperations>
      termIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'termId');
    });
  }

  QueryBuilder<SubjectResourceIsar, DateTime, QQueryOperations>
      uploadedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uploadedAt');
    });
  }

  QueryBuilder<SubjectResourceIsar, String, QQueryOperations>
      uploadedByUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uploadedByUserId');
    });
  }
}
