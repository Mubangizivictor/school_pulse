// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_isar_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStudentProfileIsarCollection on Isar {
  IsarCollection<StudentProfileIsar> get studentProfileIsars =>
      this.collection();
}

const StudentProfileIsarSchema = CollectionSchema(
  name: r'StudentProfileIsar',
  id: -8993686633993945153,
  properties: {
    r'academicYearId': PropertySchema(
      id: 0,
      name: r'academicYearId',
      type: IsarType.string,
    ),
    r'admissionNumber': PropertySchema(
      id: 1,
      name: r'admissionNumber',
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
    r'dateOfBirth': PropertySchema(
      id: 4,
      name: r'dateOfBirth',
      type: IsarType.dateTime,
    ),
    r'documentsJson': PropertySchema(
      id: 5,
      name: r'documentsJson',
      type: IsarType.string,
    ),
    r'dormLeadershipDormId': PropertySchema(
      id: 6,
      name: r'dormLeadershipDormId',
      type: IsarType.string,
    ),
    r'dormLeadershipDormName': PropertySchema(
      id: 7,
      name: r'dormLeadershipDormName',
      type: IsarType.string,
    ),
    r'dormLeadershipRole': PropertySchema(
      id: 8,
      name: r'dormLeadershipRole',
      type: IsarType.string,
    ),
    r'emergencyContactsJson': PropertySchema(
      id: 9,
      name: r'emergencyContactsJson',
      type: IsarType.string,
    ),
    r'gender': PropertySchema(
      id: 10,
      name: r'gender',
      type: IsarType.string,
    ),
    r'level': PropertySchema(
      id: 11,
      name: r'level',
      type: IsarType.string,
    ),
    r'medicalInfoJson': PropertySchema(
      id: 12,
      name: r'medicalInfoJson',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 13,
      name: r'name',
      type: IsarType.string,
    ),
    r'parentIds': PropertySchema(
      id: 14,
      name: r'parentIds',
      type: IsarType.stringList,
    ),
    r'photoUrl': PropertySchema(
      id: 15,
      name: r'photoUrl',
      type: IsarType.string,
    ),
    r'previousSchool': PropertySchema(
      id: 16,
      name: r'previousSchool',
      type: IsarType.string,
    ),
    r'qrReference': PropertySchema(
      id: 17,
      name: r'qrReference',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 18,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 19,
      name: r'status',
      type: IsarType.string,
    ),
    r'streamId': PropertySchema(
      id: 20,
      name: r'streamId',
      type: IsarType.string,
    ),
    r'studentCode': PropertySchema(
      id: 21,
      name: r'studentCode',
      type: IsarType.string,
    ),
    r'studentId': PropertySchema(
      id: 22,
      name: r'studentId',
      type: IsarType.string,
    )
  },
  estimateSize: _studentProfileIsarEstimateSize,
  serialize: _studentProfileIsarSerialize,
  deserialize: _studentProfileIsarDeserialize,
  deserializeProp: _studentProfileIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'studentId': IndexSchema(
      id: -6791323312898281473,
      name: r'studentId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'studentId',
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
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    ),
    r'studentCode': IndexSchema(
      id: 3982672933658509782,
      name: r'studentCode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'studentCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'admissionNumber': IndexSchema(
      id: 4685976421903541169,
      name: r'admissionNumber',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'admissionNumber',
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
  embeddedSchemas: {},
  getId: _studentProfileIsarGetId,
  getLinks: _studentProfileIsarGetLinks,
  attach: _studentProfileIsarAttach,
  version: '3.1.0+1',
);

int _studentProfileIsarEstimateSize(
  StudentProfileIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.academicYearId.length * 3;
  bytesCount += 3 + object.admissionNumber.length * 3;
  {
    final value = object.campusId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.classId.length * 3;
  bytesCount += 3 + object.documentsJson.length * 3;
  {
    final value = object.dormLeadershipDormId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dormLeadershipDormName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dormLeadershipRole;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.emergencyContactsJson.length * 3;
  bytesCount += 3 + object.gender.length * 3;
  bytesCount += 3 + object.level.length * 3;
  {
    final value = object.medicalInfoJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.parentIds.length * 3;
  {
    for (var i = 0; i < object.parentIds.length; i++) {
      final value = object.parentIds[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.photoUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.previousSchool;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.qrReference;
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
  bytesCount += 3 + object.studentCode.length * 3;
  bytesCount += 3 + object.studentId.length * 3;
  return bytesCount;
}

void _studentProfileIsarSerialize(
  StudentProfileIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.academicYearId);
  writer.writeString(offsets[1], object.admissionNumber);
  writer.writeString(offsets[2], object.campusId);
  writer.writeString(offsets[3], object.classId);
  writer.writeDateTime(offsets[4], object.dateOfBirth);
  writer.writeString(offsets[5], object.documentsJson);
  writer.writeString(offsets[6], object.dormLeadershipDormId);
  writer.writeString(offsets[7], object.dormLeadershipDormName);
  writer.writeString(offsets[8], object.dormLeadershipRole);
  writer.writeString(offsets[9], object.emergencyContactsJson);
  writer.writeString(offsets[10], object.gender);
  writer.writeString(offsets[11], object.level);
  writer.writeString(offsets[12], object.medicalInfoJson);
  writer.writeString(offsets[13], object.name);
  writer.writeStringList(offsets[14], object.parentIds);
  writer.writeString(offsets[15], object.photoUrl);
  writer.writeString(offsets[16], object.previousSchool);
  writer.writeString(offsets[17], object.qrReference);
  writer.writeString(offsets[18], object.schoolId);
  writer.writeString(offsets[19], object.status);
  writer.writeString(offsets[20], object.streamId);
  writer.writeString(offsets[21], object.studentCode);
  writer.writeString(offsets[22], object.studentId);
}

StudentProfileIsar _studentProfileIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StudentProfileIsar();
  object.academicYearId = reader.readString(offsets[0]);
  object.admissionNumber = reader.readString(offsets[1]);
  object.campusId = reader.readStringOrNull(offsets[2]);
  object.classId = reader.readString(offsets[3]);
  object.dateOfBirth = reader.readDateTime(offsets[4]);
  object.documentsJson = reader.readString(offsets[5]);
  object.dormLeadershipDormId = reader.readStringOrNull(offsets[6]);
  object.dormLeadershipDormName = reader.readStringOrNull(offsets[7]);
  object.dormLeadershipRole = reader.readStringOrNull(offsets[8]);
  object.emergencyContactsJson = reader.readString(offsets[9]);
  object.gender = reader.readString(offsets[10]);
  object.id = id;
  object.level = reader.readString(offsets[11]);
  object.medicalInfoJson = reader.readStringOrNull(offsets[12]);
  object.name = reader.readString(offsets[13]);
  object.parentIds = reader.readStringList(offsets[14]) ?? [];
  object.photoUrl = reader.readStringOrNull(offsets[15]);
  object.previousSchool = reader.readStringOrNull(offsets[16]);
  object.qrReference = reader.readStringOrNull(offsets[17]);
  object.schoolId = reader.readString(offsets[18]);
  object.status = reader.readString(offsets[19]);
  object.streamId = reader.readStringOrNull(offsets[20]);
  object.studentCode = reader.readString(offsets[21]);
  object.studentId = reader.readString(offsets[22]);
  return object;
}

P _studentProfileIsarDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
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
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readStringList(offset) ?? []) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _studentProfileIsarGetId(StudentProfileIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _studentProfileIsarGetLinks(
    StudentProfileIsar object) {
  return [];
}

void _studentProfileIsarAttach(
    IsarCollection<dynamic> col, Id id, StudentProfileIsar object) {
  object.id = id;
}

extension StudentProfileIsarByIndex on IsarCollection<StudentProfileIsar> {
  Future<StudentProfileIsar?> getByStudentId(String studentId) {
    return getByIndex(r'studentId', [studentId]);
  }

  StudentProfileIsar? getByStudentIdSync(String studentId) {
    return getByIndexSync(r'studentId', [studentId]);
  }

  Future<bool> deleteByStudentId(String studentId) {
    return deleteByIndex(r'studentId', [studentId]);
  }

  bool deleteByStudentIdSync(String studentId) {
    return deleteByIndexSync(r'studentId', [studentId]);
  }

  Future<List<StudentProfileIsar?>> getAllByStudentId(
      List<String> studentIdValues) {
    final values = studentIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'studentId', values);
  }

  List<StudentProfileIsar?> getAllByStudentIdSync(
      List<String> studentIdValues) {
    final values = studentIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'studentId', values);
  }

  Future<int> deleteAllByStudentId(List<String> studentIdValues) {
    final values = studentIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'studentId', values);
  }

  int deleteAllByStudentIdSync(List<String> studentIdValues) {
    final values = studentIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'studentId', values);
  }

  Future<Id> putByStudentId(StudentProfileIsar object) {
    return putByIndex(r'studentId', object);
  }

  Id putByStudentIdSync(StudentProfileIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'studentId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStudentId(List<StudentProfileIsar> objects) {
    return putAllByIndex(r'studentId', objects);
  }

  List<Id> putAllByStudentIdSync(List<StudentProfileIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'studentId', objects, saveLinks: saveLinks);
  }
}

extension StudentProfileIsarQueryWhereSort
    on QueryBuilder<StudentProfileIsar, StudentProfileIsar, QWhere> {
  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StudentProfileIsarQueryWhere
    on QueryBuilder<StudentProfileIsar, StudentProfileIsar, QWhereClause> {
  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
      studentIdEqualTo(String studentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'studentId',
        value: [studentId],
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
      schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
      nameEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
      nameNotEqualTo(String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
      studentCodeEqualTo(String studentCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'studentCode',
        value: [studentCode],
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
      studentCodeNotEqualTo(String studentCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studentCode',
              lower: [],
              upper: [studentCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studentCode',
              lower: [studentCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studentCode',
              lower: [studentCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studentCode',
              lower: [],
              upper: [studentCode],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
      admissionNumberEqualTo(String admissionNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'admissionNumber',
        value: [admissionNumber],
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
      admissionNumberNotEqualTo(String admissionNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'admissionNumber',
              lower: [],
              upper: [admissionNumber],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'admissionNumber',
              lower: [admissionNumber],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'admissionNumber',
              lower: [admissionNumber],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'admissionNumber',
              lower: [],
              upper: [admissionNumber],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
      classIdEqualTo(String classId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'classId',
        value: [classId],
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
      statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterWhereClause>
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

extension StudentProfileIsarQueryFilter
    on QueryBuilder<StudentProfileIsar, StudentProfileIsar, QFilterCondition> {
  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      academicYearIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      academicYearIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'academicYearId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      academicYearIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      academicYearIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      admissionNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'admissionNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      admissionNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'admissionNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      admissionNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'admissionNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      admissionNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'admissionNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      admissionNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'admissionNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      admissionNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'admissionNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      admissionNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'admissionNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      admissionNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'admissionNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      admissionNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'admissionNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      admissionNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'admissionNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      campusIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'campusId',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      campusIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'campusId',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      campusIdEqualTo(
    String? value, {
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      campusIdGreaterThan(
    String? value, {
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      campusIdLessThan(
    String? value, {
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      campusIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      campusIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      campusIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'campusId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      campusIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      campusIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      classIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      classIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'classId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      classIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      classIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dateOfBirthEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dateOfBirthGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dateOfBirthLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dateOfBirthBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateOfBirth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      documentsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      documentsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      documentsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      documentsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      documentsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      documentsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      documentsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      documentsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      documentsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      documentsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dormLeadershipDormId',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dormLeadershipDormId',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dormLeadershipDormId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dormLeadershipDormId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dormLeadershipDormId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dormLeadershipDormId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dormLeadershipDormId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dormLeadershipDormId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dormLeadershipDormId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dormLeadershipDormId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dormLeadershipDormId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dormLeadershipDormId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dormLeadershipDormName',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dormLeadershipDormName',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dormLeadershipDormName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dormLeadershipDormName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dormLeadershipDormName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dormLeadershipDormName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dormLeadershipDormName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dormLeadershipDormName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormNameContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dormLeadershipDormName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormNameMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dormLeadershipDormName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dormLeadershipDormName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipDormNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dormLeadershipDormName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipRoleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dormLeadershipRole',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipRoleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dormLeadershipRole',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipRoleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dormLeadershipRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipRoleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dormLeadershipRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipRoleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dormLeadershipRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipRoleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dormLeadershipRole',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipRoleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dormLeadershipRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipRoleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dormLeadershipRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipRoleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dormLeadershipRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipRoleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dormLeadershipRole',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipRoleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dormLeadershipRole',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      dormLeadershipRoleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dormLeadershipRole',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      emergencyContactsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emergencyContactsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      emergencyContactsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emergencyContactsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      emergencyContactsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emergencyContactsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      emergencyContactsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emergencyContactsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      emergencyContactsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'emergencyContactsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      emergencyContactsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'emergencyContactsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      emergencyContactsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'emergencyContactsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      emergencyContactsJsonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'emergencyContactsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      emergencyContactsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emergencyContactsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      emergencyContactsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'emergencyContactsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      genderEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      genderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      genderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      genderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gender',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      genderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      genderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      genderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      genderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gender',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      genderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      genderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      levelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      levelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      levelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      levelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'level',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      levelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      levelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      levelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'level',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      levelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'level',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      levelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'level',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      levelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'level',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      medicalInfoJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'medicalInfoJson',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      medicalInfoJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'medicalInfoJson',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      medicalInfoJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicalInfoJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      medicalInfoJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'medicalInfoJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      medicalInfoJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'medicalInfoJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      medicalInfoJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'medicalInfoJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      medicalInfoJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'medicalInfoJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      medicalInfoJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'medicalInfoJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      medicalInfoJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'medicalInfoJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      medicalInfoJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'medicalInfoJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      medicalInfoJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicalInfoJson',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      medicalInfoJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'medicalInfoJson',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parentIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parentIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parentIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parentIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentIds',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parentIds',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'parentIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'parentIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'parentIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'parentIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'parentIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      parentIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'parentIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      photoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'photoUrl',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      photoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'photoUrl',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      photoUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      photoUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      photoUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      photoUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      photoUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      photoUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      photoUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      photoUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      photoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      photoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      previousSchoolIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'previousSchool',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      previousSchoolIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'previousSchool',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      previousSchoolEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousSchool',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      previousSchoolGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previousSchool',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      previousSchoolLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previousSchool',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      previousSchoolBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previousSchool',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      previousSchoolStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'previousSchool',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      previousSchoolEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'previousSchool',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      previousSchoolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previousSchool',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      previousSchoolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previousSchool',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      previousSchoolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousSchool',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      previousSchoolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previousSchool',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      qrReferenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'qrReference',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      qrReferenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'qrReference',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      qrReferenceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qrReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      qrReferenceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qrReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      qrReferenceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qrReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      qrReferenceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qrReference',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      qrReferenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'qrReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      qrReferenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'qrReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      qrReferenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'qrReference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      qrReferenceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'qrReference',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      qrReferenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qrReference',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      qrReferenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'qrReference',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      streamIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      streamIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      streamIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      streamIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streamId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      streamIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      streamIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      studentCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      studentCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'studentCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      studentCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'studentCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      studentCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'studentCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      studentCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'studentCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      studentCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'studentCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      studentCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'studentCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      studentCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'studentCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      studentCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentCode',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      studentCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'studentCode',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      studentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      studentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'studentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      studentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterFilterCondition>
      studentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'studentId',
        value: '',
      ));
    });
  }
}

extension StudentProfileIsarQueryObject
    on QueryBuilder<StudentProfileIsar, StudentProfileIsar, QFilterCondition> {}

extension StudentProfileIsarQueryLinks
    on QueryBuilder<StudentProfileIsar, StudentProfileIsar, QFilterCondition> {}

extension StudentProfileIsarQuerySortBy
    on QueryBuilder<StudentProfileIsar, StudentProfileIsar, QSortBy> {
  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByAdmissionNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionNumber', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByAdmissionNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionNumber', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByDateOfBirthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByDocumentsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentsJson', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByDocumentsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentsJson', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByDormLeadershipDormId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dormLeadershipDormId', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByDormLeadershipDormIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dormLeadershipDormId', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByDormLeadershipDormName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dormLeadershipDormName', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByDormLeadershipDormNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dormLeadershipDormName', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByDormLeadershipRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dormLeadershipRole', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByDormLeadershipRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dormLeadershipRole', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByEmergencyContactsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactsJson', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByEmergencyContactsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactsJson', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByMedicalInfoJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicalInfoJson', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByMedicalInfoJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicalInfoJson', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByPreviousSchool() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousSchool', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByPreviousSchoolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousSchool', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByQrReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrReference', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByQrReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrReference', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByStudentCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentCode', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByStudentCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentCode', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      sortByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }
}

extension StudentProfileIsarQuerySortThenBy
    on QueryBuilder<StudentProfileIsar, StudentProfileIsar, QSortThenBy> {
  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByAdmissionNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionNumber', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByAdmissionNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionNumber', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByDateOfBirthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByDocumentsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentsJson', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByDocumentsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentsJson', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByDormLeadershipDormId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dormLeadershipDormId', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByDormLeadershipDormIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dormLeadershipDormId', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByDormLeadershipDormName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dormLeadershipDormName', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByDormLeadershipDormNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dormLeadershipDormName', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByDormLeadershipRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dormLeadershipRole', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByDormLeadershipRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dormLeadershipRole', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByEmergencyContactsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactsJson', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByEmergencyContactsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactsJson', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByMedicalInfoJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicalInfoJson', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByMedicalInfoJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'medicalInfoJson', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByPreviousSchool() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousSchool', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByPreviousSchoolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousSchool', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByQrReference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrReference', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByQrReferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrReference', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByStudentCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentCode', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByStudentCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentCode', Sort.desc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QAfterSortBy>
      thenByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }
}

extension StudentProfileIsarQueryWhereDistinct
    on QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct> {
  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByAcademicYearId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'academicYearId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByAdmissionNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'admissionNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByCampusId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'campusId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByClassId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateOfBirth');
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByDocumentsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByDormLeadershipDormId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dormLeadershipDormId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByDormLeadershipDormName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dormLeadershipDormName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByDormLeadershipRole({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dormLeadershipRole',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByEmergencyContactsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emergencyContactsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByGender({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByLevel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'level', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByMedicalInfoJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'medicalInfoJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByParentIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentIds');
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByPhotoUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByPreviousSchool({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousSchool',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByQrReference({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qrReference', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByStreamId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByStudentCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studentCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentProfileIsar, StudentProfileIsar, QDistinct>
      distinctByStudentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studentId', caseSensitive: caseSensitive);
    });
  }
}

extension StudentProfileIsarQueryProperty
    on QueryBuilder<StudentProfileIsar, StudentProfileIsar, QQueryProperty> {
  QueryBuilder<StudentProfileIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StudentProfileIsar, String, QQueryOperations>
      academicYearIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'academicYearId');
    });
  }

  QueryBuilder<StudentProfileIsar, String, QQueryOperations>
      admissionNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'admissionNumber');
    });
  }

  QueryBuilder<StudentProfileIsar, String?, QQueryOperations>
      campusIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campusId');
    });
  }

  QueryBuilder<StudentProfileIsar, String, QQueryOperations> classIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classId');
    });
  }

  QueryBuilder<StudentProfileIsar, DateTime, QQueryOperations>
      dateOfBirthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateOfBirth');
    });
  }

  QueryBuilder<StudentProfileIsar, String, QQueryOperations>
      documentsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentsJson');
    });
  }

  QueryBuilder<StudentProfileIsar, String?, QQueryOperations>
      dormLeadershipDormIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dormLeadershipDormId');
    });
  }

  QueryBuilder<StudentProfileIsar, String?, QQueryOperations>
      dormLeadershipDormNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dormLeadershipDormName');
    });
  }

  QueryBuilder<StudentProfileIsar, String?, QQueryOperations>
      dormLeadershipRoleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dormLeadershipRole');
    });
  }

  QueryBuilder<StudentProfileIsar, String, QQueryOperations>
      emergencyContactsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emergencyContactsJson');
    });
  }

  QueryBuilder<StudentProfileIsar, String, QQueryOperations> genderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gender');
    });
  }

  QueryBuilder<StudentProfileIsar, String, QQueryOperations> levelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'level');
    });
  }

  QueryBuilder<StudentProfileIsar, String?, QQueryOperations>
      medicalInfoJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'medicalInfoJson');
    });
  }

  QueryBuilder<StudentProfileIsar, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<StudentProfileIsar, List<String>, QQueryOperations>
      parentIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentIds');
    });
  }

  QueryBuilder<StudentProfileIsar, String?, QQueryOperations>
      photoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoUrl');
    });
  }

  QueryBuilder<StudentProfileIsar, String?, QQueryOperations>
      previousSchoolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousSchool');
    });
  }

  QueryBuilder<StudentProfileIsar, String?, QQueryOperations>
      qrReferenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qrReference');
    });
  }

  QueryBuilder<StudentProfileIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<StudentProfileIsar, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<StudentProfileIsar, String?, QQueryOperations>
      streamIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamId');
    });
  }

  QueryBuilder<StudentProfileIsar, String, QQueryOperations>
      studentCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studentCode');
    });
  }

  QueryBuilder<StudentProfileIsar, String, QQueryOperations>
      studentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studentId');
    });
  }
}
