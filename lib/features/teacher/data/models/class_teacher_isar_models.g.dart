// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_teacher_isar_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetClassStudentIsarCollection on Isar {
  IsarCollection<ClassStudentIsar> get classStudentIsars => this.collection();
}

const ClassStudentIsarSchema = CollectionSchema(
  name: r'ClassStudentIsar',
  id: -9036386117148443215,
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
    r'cachedAt': PropertySchema(
      id: 2,
      name: r'cachedAt',
      type: IsarType.dateTime,
    ),
    r'classId': PropertySchema(
      id: 3,
      name: r'classId',
      type: IsarType.string,
    ),
    r'className': PropertySchema(
      id: 4,
      name: r'className',
      type: IsarType.string,
    ),
    r'gender': PropertySchema(
      id: 5,
      name: r'gender',
      type: IsarType.string,
    ),
    r'hasHealthAlert': PropertySchema(
      id: 6,
      name: r'hasHealthAlert',
      type: IsarType.bool,
    ),
    r'houseId': PropertySchema(
      id: 7,
      name: r'houseId',
      type: IsarType.string,
    ),
    r'houseName': PropertySchema(
      id: 8,
      name: r'houseName',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 9,
      name: r'name',
      type: IsarType.string,
    ),
    r'photoUrl': PropertySchema(
      id: 10,
      name: r'photoUrl',
      type: IsarType.string,
    ),
    r'residency': PropertySchema(
      id: 11,
      name: r'residency',
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
    r'streamName': PropertySchema(
      id: 15,
      name: r'streamName',
      type: IsarType.string,
    ),
    r'studentId': PropertySchema(
      id: 16,
      name: r'studentId',
      type: IsarType.string,
    )
  },
  estimateSize: _classStudentIsarEstimateSize,
  serialize: _classStudentIsarSerialize,
  deserialize: _classStudentIsarDeserialize,
  deserializeProp: _classStudentIsarDeserializeProp,
  idName: r'isarId',
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
  getId: _classStudentIsarGetId,
  getLinks: _classStudentIsarGetLinks,
  attach: _classStudentIsarAttach,
  version: '3.1.0+1',
);

int _classStudentIsarEstimateSize(
  ClassStudentIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.academicYearId.length * 3;
  bytesCount += 3 + object.admissionNumber.length * 3;
  bytesCount += 3 + object.classId.length * 3;
  bytesCount += 3 + object.className.length * 3;
  {
    final value = object.gender;
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
  {
    final value = object.houseName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.photoUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.residency.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
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
  bytesCount += 3 + object.studentId.length * 3;
  return bytesCount;
}

void _classStudentIsarSerialize(
  ClassStudentIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.academicYearId);
  writer.writeString(offsets[1], object.admissionNumber);
  writer.writeDateTime(offsets[2], object.cachedAt);
  writer.writeString(offsets[3], object.classId);
  writer.writeString(offsets[4], object.className);
  writer.writeString(offsets[5], object.gender);
  writer.writeBool(offsets[6], object.hasHealthAlert);
  writer.writeString(offsets[7], object.houseId);
  writer.writeString(offsets[8], object.houseName);
  writer.writeString(offsets[9], object.name);
  writer.writeString(offsets[10], object.photoUrl);
  writer.writeString(offsets[11], object.residency);
  writer.writeString(offsets[12], object.schoolId);
  writer.writeString(offsets[13], object.status);
  writer.writeString(offsets[14], object.streamId);
  writer.writeString(offsets[15], object.streamName);
  writer.writeString(offsets[16], object.studentId);
}

ClassStudentIsar _classStudentIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ClassStudentIsar();
  object.academicYearId = reader.readString(offsets[0]);
  object.admissionNumber = reader.readString(offsets[1]);
  object.cachedAt = reader.readDateTime(offsets[2]);
  object.classId = reader.readString(offsets[3]);
  object.className = reader.readString(offsets[4]);
  object.gender = reader.readStringOrNull(offsets[5]);
  object.hasHealthAlert = reader.readBool(offsets[6]);
  object.houseId = reader.readStringOrNull(offsets[7]);
  object.houseName = reader.readStringOrNull(offsets[8]);
  object.name = reader.readString(offsets[9]);
  object.photoUrl = reader.readStringOrNull(offsets[10]);
  object.residency = reader.readString(offsets[11]);
  object.schoolId = reader.readString(offsets[12]);
  object.status = reader.readString(offsets[13]);
  object.streamId = reader.readStringOrNull(offsets[14]);
  object.streamName = reader.readStringOrNull(offsets[15]);
  object.studentId = reader.readString(offsets[16]);
  return object;
}

P _classStudentIsarDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _classStudentIsarGetId(ClassStudentIsar object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _classStudentIsarGetLinks(ClassStudentIsar object) {
  return [];
}

void _classStudentIsarAttach(
    IsarCollection<dynamic> col, Id id, ClassStudentIsar object) {}

extension ClassStudentIsarByIndex on IsarCollection<ClassStudentIsar> {
  Future<ClassStudentIsar?> getByStudentId(String studentId) {
    return getByIndex(r'studentId', [studentId]);
  }

  ClassStudentIsar? getByStudentIdSync(String studentId) {
    return getByIndexSync(r'studentId', [studentId]);
  }

  Future<bool> deleteByStudentId(String studentId) {
    return deleteByIndex(r'studentId', [studentId]);
  }

  bool deleteByStudentIdSync(String studentId) {
    return deleteByIndexSync(r'studentId', [studentId]);
  }

  Future<List<ClassStudentIsar?>> getAllByStudentId(
      List<String> studentIdValues) {
    final values = studentIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'studentId', values);
  }

  List<ClassStudentIsar?> getAllByStudentIdSync(List<String> studentIdValues) {
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

  Future<Id> putByStudentId(ClassStudentIsar object) {
    return putByIndex(r'studentId', object);
  }

  Id putByStudentIdSync(ClassStudentIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'studentId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStudentId(List<ClassStudentIsar> objects) {
    return putAllByIndex(r'studentId', objects);
  }

  List<Id> putAllByStudentIdSync(List<ClassStudentIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'studentId', objects, saveLinks: saveLinks);
  }
}

extension ClassStudentIsarQueryWhereSort
    on QueryBuilder<ClassStudentIsar, ClassStudentIsar, QWhere> {
  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ClassStudentIsarQueryWhere
    on QueryBuilder<ClassStudentIsar, ClassStudentIsar, QWhereClause> {
  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterWhereClause>
      isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterWhereClause>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterWhereClause>
      isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterWhereClause>
      isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterWhereClause>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterWhereClause>
      studentIdEqualTo(String studentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'studentId',
        value: [studentId],
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterWhereClause>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterWhereClause>
      schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterWhereClause>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterWhereClause>
      classIdEqualTo(String classId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'classId',
        value: [classId],
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterWhereClause>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterWhereClause>
      academicYearIdEqualTo(String academicYearId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'academicYearId',
        value: [academicYearId],
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterWhereClause>
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

extension ClassStudentIsarQueryFilter
    on QueryBuilder<ClassStudentIsar, ClassStudentIsar, QFilterCondition> {
  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      academicYearIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'academicYearId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      academicYearIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'academicYearId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      academicYearIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      academicYearIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      admissionNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'admissionNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      admissionNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'admissionNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      admissionNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'admissionNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      admissionNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'admissionNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      cachedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      classIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'classId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      classIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'classId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      classIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      classIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      classNameEqualTo(
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      classNameLessThan(
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      classNameBetween(
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      classNameEndsWith(
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      classNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      classNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'className',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      classNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'className',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      classNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'className',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      genderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gender',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      genderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gender',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      genderEqualTo(
    String? value, {
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      genderGreaterThan(
    String? value, {
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      genderLessThan(
    String? value, {
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      genderBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      genderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      genderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gender',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      genderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      genderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      hasHealthAlertEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasHealthAlert',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'houseId',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'houseId',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseIdEqualTo(
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseIdGreaterThan(
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseIdLessThan(
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseIdBetween(
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseIdStartsWith(
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseIdEndsWith(
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'houseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'houseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'houseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'houseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'houseName',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'houseName',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'houseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'houseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'houseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'houseName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'houseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'houseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'houseName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'houseName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'houseName',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      houseNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'houseName',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      photoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'photoUrl',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      photoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'photoUrl',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      photoUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      photoUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      photoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      photoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      residencyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'residency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      residencyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'residency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      residencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'residency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      residencyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'residency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      residencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'residency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      residencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'residency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      residencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'residency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      residencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'residency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      residencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'residency',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      residencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'residency',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      streamIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      streamIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      streamIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streamId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      streamIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streamId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      streamIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      streamIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      streamNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamName',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      streamNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamName',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      streamNameEqualTo(
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      streamNameBetween(
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      streamNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streamName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      streamNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streamName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      streamNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamName',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      streamNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamName',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
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

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      studentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      studentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'studentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      studentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterFilterCondition>
      studentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'studentId',
        value: '',
      ));
    });
  }
}

extension ClassStudentIsarQueryObject
    on QueryBuilder<ClassStudentIsar, ClassStudentIsar, QFilterCondition> {}

extension ClassStudentIsarQueryLinks
    on QueryBuilder<ClassStudentIsar, ClassStudentIsar, QFilterCondition> {}

extension ClassStudentIsarQuerySortBy
    on QueryBuilder<ClassStudentIsar, ClassStudentIsar, QSortBy> {
  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByAdmissionNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionNumber', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByAdmissionNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionNumber', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByHasHealthAlert() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasHealthAlert', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByHasHealthAlertDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasHealthAlert', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByHouseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'houseId', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByHouseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'houseId', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByHouseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'houseName', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByHouseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'houseName', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByResidency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'residency', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByResidencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'residency', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByStreamName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamName', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByStreamNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamName', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      sortByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }
}

extension ClassStudentIsarQuerySortThenBy
    on QueryBuilder<ClassStudentIsar, ClassStudentIsar, QSortThenBy> {
  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByAdmissionNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionNumber', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByAdmissionNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionNumber', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByHasHealthAlert() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasHealthAlert', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByHasHealthAlertDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasHealthAlert', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByHouseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'houseId', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByHouseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'houseId', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByHouseName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'houseName', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByHouseNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'houseName', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByResidency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'residency', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByResidencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'residency', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByStreamName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamName', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByStreamNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamName', Sort.desc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QAfterSortBy>
      thenByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }
}

extension ClassStudentIsarQueryWhereDistinct
    on QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct> {
  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct>
      distinctByAcademicYearId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'academicYearId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct>
      distinctByAdmissionNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'admissionNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct>
      distinctByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cachedAt');
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct> distinctByClassId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct>
      distinctByClassName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'className', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct> distinctByGender(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct>
      distinctByHasHealthAlert() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasHealthAlert');
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct> distinctByHouseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'houseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct>
      distinctByHouseName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'houseName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct>
      distinctByPhotoUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct>
      distinctByResidency({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'residency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct>
      distinctByStreamId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct>
      distinctByStreamName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassStudentIsar, ClassStudentIsar, QDistinct>
      distinctByStudentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studentId', caseSensitive: caseSensitive);
    });
  }
}

extension ClassStudentIsarQueryProperty
    on QueryBuilder<ClassStudentIsar, ClassStudentIsar, QQueryProperty> {
  QueryBuilder<ClassStudentIsar, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ClassStudentIsar, String, QQueryOperations>
      academicYearIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'academicYearId');
    });
  }

  QueryBuilder<ClassStudentIsar, String, QQueryOperations>
      admissionNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'admissionNumber');
    });
  }

  QueryBuilder<ClassStudentIsar, DateTime, QQueryOperations>
      cachedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cachedAt');
    });
  }

  QueryBuilder<ClassStudentIsar, String, QQueryOperations> classIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classId');
    });
  }

  QueryBuilder<ClassStudentIsar, String, QQueryOperations> classNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'className');
    });
  }

  QueryBuilder<ClassStudentIsar, String?, QQueryOperations> genderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gender');
    });
  }

  QueryBuilder<ClassStudentIsar, bool, QQueryOperations>
      hasHealthAlertProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasHealthAlert');
    });
  }

  QueryBuilder<ClassStudentIsar, String?, QQueryOperations> houseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'houseId');
    });
  }

  QueryBuilder<ClassStudentIsar, String?, QQueryOperations>
      houseNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'houseName');
    });
  }

  QueryBuilder<ClassStudentIsar, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<ClassStudentIsar, String?, QQueryOperations> photoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoUrl');
    });
  }

  QueryBuilder<ClassStudentIsar, String, QQueryOperations> residencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'residency');
    });
  }

  QueryBuilder<ClassStudentIsar, String, QQueryOperations> schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<ClassStudentIsar, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<ClassStudentIsar, String?, QQueryOperations> streamIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamId');
    });
  }

  QueryBuilder<ClassStudentIsar, String?, QQueryOperations>
      streamNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamName');
    });
  }

  QueryBuilder<ClassStudentIsar, String, QQueryOperations> studentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studentId');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetClassDashboardCacheIsarCollection on Isar {
  IsarCollection<ClassDashboardCacheIsar> get classDashboardCacheIsars =>
      this.collection();
}

const ClassDashboardCacheIsarSchema = CollectionSchema(
  name: r'ClassDashboardCacheIsar',
  id: 5759274187941248947,
  properties: {
    r'absentCount': PropertySchema(
      id: 0,
      name: r'absentCount',
      type: IsarType.long,
    ),
    r'academicYearId': PropertySchema(
      id: 1,
      name: r'academicYearId',
      type: IsarType.string,
    ),
    r'cacheKey': PropertySchema(
      id: 2,
      name: r'cacheKey',
      type: IsarType.string,
    ),
    r'cachedAt': PropertySchema(
      id: 3,
      name: r'cachedAt',
      type: IsarType.dateTime,
    ),
    r'classId': PropertySchema(
      id: 4,
      name: r'classId',
      type: IsarType.string,
    ),
    r'excusedCount': PropertySchema(
      id: 5,
      name: r'excusedCount',
      type: IsarType.long,
    ),
    r'hasSession': PropertySchema(
      id: 6,
      name: r'hasSession',
      type: IsarType.bool,
    ),
    r'isSubmitted': PropertySchema(
      id: 7,
      name: r'isSubmitted',
      type: IsarType.bool,
    ),
    r'lateCount': PropertySchema(
      id: 8,
      name: r'lateCount',
      type: IsarType.long,
    ),
    r'pendingAssignments': PropertySchema(
      id: 9,
      name: r'pendingAssignments',
      type: IsarType.long,
    ),
    r'pendingBehaviourFollowUps': PropertySchema(
      id: 10,
      name: r'pendingBehaviourFollowUps',
      type: IsarType.long,
    ),
    r'pendingReports': PropertySchema(
      id: 11,
      name: r'pendingReports',
      type: IsarType.long,
    ),
    r'presentCount': PropertySchema(
      id: 12,
      name: r'presentCount',
      type: IsarType.long,
    ),
    r'schoolId': PropertySchema(
      id: 13,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'streamId': PropertySchema(
      id: 14,
      name: r'streamId',
      type: IsarType.string,
    ),
    r'submittedAt': PropertySchema(
      id: 15,
      name: r'submittedAt',
      type: IsarType.dateTime,
    ),
    r'totalStudents': PropertySchema(
      id: 16,
      name: r'totalStudents',
      type: IsarType.long,
    ),
    r'unreadMessages': PropertySchema(
      id: 17,
      name: r'unreadMessages',
      type: IsarType.long,
    )
  },
  estimateSize: _classDashboardCacheIsarEstimateSize,
  serialize: _classDashboardCacheIsarSerialize,
  deserialize: _classDashboardCacheIsarDeserialize,
  deserializeProp: _classDashboardCacheIsarDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'cacheKey': IndexSchema(
      id: 5885332021012296610,
      name: r'cacheKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'cacheKey',
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
  getId: _classDashboardCacheIsarGetId,
  getLinks: _classDashboardCacheIsarGetLinks,
  attach: _classDashboardCacheIsarAttach,
  version: '3.1.0+1',
);

int _classDashboardCacheIsarEstimateSize(
  ClassDashboardCacheIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.academicYearId.length * 3;
  bytesCount += 3 + object.cacheKey.length * 3;
  bytesCount += 3 + object.classId.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  {
    final value = object.streamId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _classDashboardCacheIsarSerialize(
  ClassDashboardCacheIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.absentCount);
  writer.writeString(offsets[1], object.academicYearId);
  writer.writeString(offsets[2], object.cacheKey);
  writer.writeDateTime(offsets[3], object.cachedAt);
  writer.writeString(offsets[4], object.classId);
  writer.writeLong(offsets[5], object.excusedCount);
  writer.writeBool(offsets[6], object.hasSession);
  writer.writeBool(offsets[7], object.isSubmitted);
  writer.writeLong(offsets[8], object.lateCount);
  writer.writeLong(offsets[9], object.pendingAssignments);
  writer.writeLong(offsets[10], object.pendingBehaviourFollowUps);
  writer.writeLong(offsets[11], object.pendingReports);
  writer.writeLong(offsets[12], object.presentCount);
  writer.writeString(offsets[13], object.schoolId);
  writer.writeString(offsets[14], object.streamId);
  writer.writeDateTime(offsets[15], object.submittedAt);
  writer.writeLong(offsets[16], object.totalStudents);
  writer.writeLong(offsets[17], object.unreadMessages);
}

ClassDashboardCacheIsar _classDashboardCacheIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ClassDashboardCacheIsar();
  object.absentCount = reader.readLong(offsets[0]);
  object.academicYearId = reader.readString(offsets[1]);
  object.cacheKey = reader.readString(offsets[2]);
  object.cachedAt = reader.readDateTime(offsets[3]);
  object.classId = reader.readString(offsets[4]);
  object.excusedCount = reader.readLong(offsets[5]);
  object.hasSession = reader.readBool(offsets[6]);
  object.isSubmitted = reader.readBool(offsets[7]);
  object.lateCount = reader.readLong(offsets[8]);
  object.pendingAssignments = reader.readLong(offsets[9]);
  object.pendingBehaviourFollowUps = reader.readLong(offsets[10]);
  object.pendingReports = reader.readLong(offsets[11]);
  object.presentCount = reader.readLong(offsets[12]);
  object.schoolId = reader.readString(offsets[13]);
  object.streamId = reader.readStringOrNull(offsets[14]);
  object.submittedAt = reader.readDateTimeOrNull(offsets[15]);
  object.totalStudents = reader.readLong(offsets[16]);
  object.unreadMessages = reader.readLong(offsets[17]);
  return object;
}

P _classDashboardCacheIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _classDashboardCacheIsarGetId(ClassDashboardCacheIsar object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _classDashboardCacheIsarGetLinks(
    ClassDashboardCacheIsar object) {
  return [];
}

void _classDashboardCacheIsarAttach(
    IsarCollection<dynamic> col, Id id, ClassDashboardCacheIsar object) {}

extension ClassDashboardCacheIsarByIndex
    on IsarCollection<ClassDashboardCacheIsar> {
  Future<ClassDashboardCacheIsar?> getByCacheKey(String cacheKey) {
    return getByIndex(r'cacheKey', [cacheKey]);
  }

  ClassDashboardCacheIsar? getByCacheKeySync(String cacheKey) {
    return getByIndexSync(r'cacheKey', [cacheKey]);
  }

  Future<bool> deleteByCacheKey(String cacheKey) {
    return deleteByIndex(r'cacheKey', [cacheKey]);
  }

  bool deleteByCacheKeySync(String cacheKey) {
    return deleteByIndexSync(r'cacheKey', [cacheKey]);
  }

  Future<List<ClassDashboardCacheIsar?>> getAllByCacheKey(
      List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'cacheKey', values);
  }

  List<ClassDashboardCacheIsar?> getAllByCacheKeySync(
      List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'cacheKey', values);
  }

  Future<int> deleteAllByCacheKey(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'cacheKey', values);
  }

  int deleteAllByCacheKeySync(List<String> cacheKeyValues) {
    final values = cacheKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'cacheKey', values);
  }

  Future<Id> putByCacheKey(ClassDashboardCacheIsar object) {
    return putByIndex(r'cacheKey', object);
  }

  Id putByCacheKeySync(ClassDashboardCacheIsar object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'cacheKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCacheKey(List<ClassDashboardCacheIsar> objects) {
    return putAllByIndex(r'cacheKey', objects);
  }

  List<Id> putAllByCacheKeySync(List<ClassDashboardCacheIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'cacheKey', objects, saveLinks: saveLinks);
  }
}

extension ClassDashboardCacheIsarQueryWhereSort
    on QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QWhere> {
  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ClassDashboardCacheIsarQueryWhere on QueryBuilder<
    ClassDashboardCacheIsar, ClassDashboardCacheIsar, QWhereClause> {
  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterWhereClause> cacheKeyEqualTo(String cacheKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cacheKey',
        value: [cacheKey],
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterWhereClause> cacheKeyNotEqualTo(String cacheKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [],
              upper: [cacheKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [cacheKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [cacheKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cacheKey',
              lower: [],
              upper: [cacheKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterWhereClause> schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

extension ClassDashboardCacheIsarQueryFilter on QueryBuilder<
    ClassDashboardCacheIsar, ClassDashboardCacheIsar, QFilterCondition> {
  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> absentCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'absentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> absentCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'absentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> absentCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'absentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> absentCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'absentCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> academicYearIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> academicYearIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> cacheKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> cacheKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> cacheKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> cacheKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cacheKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> cacheKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> cacheKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
          QAfterFilterCondition>
      cacheKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cacheKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
          QAfterFilterCondition>
      cacheKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cacheKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> cacheKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cacheKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> cacheKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cacheKey',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> cachedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> classIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> classIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> excusedCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'excusedCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> excusedCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'excusedCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> excusedCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'excusedCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> excusedCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'excusedCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> hasSessionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasSession',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> isSubmittedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSubmitted',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> lateCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lateCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> lateCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lateCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> lateCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lateCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> lateCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lateCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> pendingAssignmentsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendingAssignments',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> pendingAssignmentsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pendingAssignments',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> pendingAssignmentsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pendingAssignments',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> pendingAssignmentsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pendingAssignments',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> pendingBehaviourFollowUpsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendingBehaviourFollowUps',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> pendingBehaviourFollowUpsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pendingBehaviourFollowUps',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> pendingBehaviourFollowUpsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pendingBehaviourFollowUps',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> pendingBehaviourFollowUpsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pendingBehaviourFollowUps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> pendingReportsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendingReports',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> pendingReportsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pendingReports',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> pendingReportsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pendingReports',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> pendingReportsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pendingReports',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> presentCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'presentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> presentCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'presentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> presentCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'presentCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> presentCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'presentCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> streamIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> streamIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> streamIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> streamIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> submittedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'submittedAt',
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> submittedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'submittedAt',
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> submittedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'submittedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
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

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> totalStudentsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalStudents',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> totalStudentsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalStudents',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> totalStudentsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalStudents',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> totalStudentsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalStudents',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> unreadMessagesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unreadMessages',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> unreadMessagesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unreadMessages',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> unreadMessagesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unreadMessages',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar,
      QAfterFilterCondition> unreadMessagesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unreadMessages',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ClassDashboardCacheIsarQueryObject on QueryBuilder<
    ClassDashboardCacheIsar, ClassDashboardCacheIsar, QFilterCondition> {}

extension ClassDashboardCacheIsarQueryLinks on QueryBuilder<
    ClassDashboardCacheIsar, ClassDashboardCacheIsar, QFilterCondition> {}

extension ClassDashboardCacheIsarQuerySortBy
    on QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QSortBy> {
  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByAbsentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'absentCount', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByAbsentCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'absentCount', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByExcusedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'excusedCount', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByExcusedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'excusedCount', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByHasSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSession', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByHasSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSession', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByIsSubmitted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSubmitted', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByIsSubmittedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSubmitted', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByLateCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lateCount', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByLateCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lateCount', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByPendingAssignments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingAssignments', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByPendingAssignmentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingAssignments', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByPendingBehaviourFollowUps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingBehaviourFollowUps', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByPendingBehaviourFollowUpsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingBehaviourFollowUps', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByPendingReports() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingReports', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByPendingReportsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingReports', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByPresentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presentCount', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByPresentCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presentCount', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortBySubmittedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByTotalStudents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudents', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByTotalStudentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudents', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByUnreadMessages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadMessages', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      sortByUnreadMessagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadMessages', Sort.desc);
    });
  }
}

extension ClassDashboardCacheIsarQuerySortThenBy on QueryBuilder<
    ClassDashboardCacheIsar, ClassDashboardCacheIsar, QSortThenBy> {
  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByAbsentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'absentCount', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByAbsentCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'absentCount', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByCacheKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByCacheKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cacheKey', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByExcusedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'excusedCount', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByExcusedCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'excusedCount', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByHasSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSession', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByHasSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasSession', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByIsSubmitted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSubmitted', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByIsSubmittedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSubmitted', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByLateCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lateCount', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByLateCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lateCount', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByPendingAssignments() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingAssignments', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByPendingAssignmentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingAssignments', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByPendingBehaviourFollowUps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingBehaviourFollowUps', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByPendingBehaviourFollowUpsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingBehaviourFollowUps', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByPendingReports() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingReports', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByPendingReportsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingReports', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByPresentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presentCount', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByPresentCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'presentCount', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenBySubmittedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByTotalStudents() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudents', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByTotalStudentsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalStudents', Sort.desc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByUnreadMessages() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadMessages', Sort.asc);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QAfterSortBy>
      thenByUnreadMessagesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadMessages', Sort.desc);
    });
  }
}

extension ClassDashboardCacheIsarQueryWhereDistinct on QueryBuilder<
    ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct> {
  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByAbsentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'absentCount');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByAcademicYearId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'academicYearId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByCacheKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cacheKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cachedAt');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByClassId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByExcusedCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'excusedCount');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByHasSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasSession');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByIsSubmitted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSubmitted');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByLateCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lateCount');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByPendingAssignments() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingAssignments');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByPendingBehaviourFollowUps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingBehaviourFollowUps');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByPendingReports() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingReports');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByPresentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'presentCount');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByStreamId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'submittedAt');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByTotalStudents() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalStudents');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, ClassDashboardCacheIsar, QDistinct>
      distinctByUnreadMessages() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unreadMessages');
    });
  }
}

extension ClassDashboardCacheIsarQueryProperty on QueryBuilder<
    ClassDashboardCacheIsar, ClassDashboardCacheIsar, QQueryProperty> {
  QueryBuilder<ClassDashboardCacheIsar, int, QQueryOperations>
      isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, int, QQueryOperations>
      absentCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'absentCount');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, String, QQueryOperations>
      academicYearIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'academicYearId');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, String, QQueryOperations>
      cacheKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cacheKey');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, DateTime, QQueryOperations>
      cachedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cachedAt');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, String, QQueryOperations>
      classIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classId');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, int, QQueryOperations>
      excusedCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'excusedCount');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, bool, QQueryOperations>
      hasSessionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasSession');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, bool, QQueryOperations>
      isSubmittedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSubmitted');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, int, QQueryOperations>
      lateCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lateCount');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, int, QQueryOperations>
      pendingAssignmentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingAssignments');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, int, QQueryOperations>
      pendingBehaviourFollowUpsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingBehaviourFollowUps');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, int, QQueryOperations>
      pendingReportsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingReports');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, int, QQueryOperations>
      presentCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'presentCount');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, String?, QQueryOperations>
      streamIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamId');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, DateTime?, QQueryOperations>
      submittedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'submittedAt');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, int, QQueryOperations>
      totalStudentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalStudents');
    });
  }

  QueryBuilder<ClassDashboardCacheIsar, int, QQueryOperations>
      unreadMessagesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unreadMessages');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetClassAttendanceDraftIsarCollection on Isar {
  IsarCollection<ClassAttendanceDraftIsar> get classAttendanceDraftIsars =>
      this.collection();
}

const ClassAttendanceDraftIsarSchema = CollectionSchema(
  name: r'ClassAttendanceDraftIsar',
  id: 9022960829521659168,
  properties: {
    r'academicYearId': PropertySchema(
      id: 0,
      name: r'academicYearId',
      type: IsarType.string,
    ),
    r'cachedAt': PropertySchema(
      id: 1,
      name: r'cachedAt',
      type: IsarType.dateTime,
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
    r'className': PropertySchema(
      id: 4,
      name: r'className',
      type: IsarType.string,
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
    r'entriesJson': PropertySchema(
      id: 7,
      name: r'entriesJson',
      type: IsarType.string,
    ),
    r'lastCorrectedAt': PropertySchema(
      id: 8,
      name: r'lastCorrectedAt',
      type: IsarType.dateTime,
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
    r'sessionId': PropertySchema(
      id: 11,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'sessionType': PropertySchema(
      id: 12,
      name: r'sessionType',
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
    r'submittedAt': PropertySchema(
      id: 15,
      name: r'submittedAt',
      type: IsarType.dateTime,
    ),
    r'submittedBy': PropertySchema(
      id: 16,
      name: r'submittedBy',
      type: IsarType.string,
    ),
    r'termId': PropertySchema(
      id: 17,
      name: r'termId',
      type: IsarType.string,
    )
  },
  estimateSize: _classAttendanceDraftIsarEstimateSize,
  serialize: _classAttendanceDraftIsarSerialize,
  deserialize: _classAttendanceDraftIsarDeserialize,
  deserializeProp: _classAttendanceDraftIsarDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
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
  getId: _classAttendanceDraftIsarGetId,
  getLinks: _classAttendanceDraftIsarGetLinks,
  attach: _classAttendanceDraftIsarAttach,
  version: '3.1.0+1',
);

int _classAttendanceDraftIsarEstimateSize(
  ClassAttendanceDraftIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.academicYearId.length * 3;
  bytesCount += 3 + object.campusId.length * 3;
  bytesCount += 3 + object.classId.length * 3;
  bytesCount += 3 + object.className.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  bytesCount += 3 + object.entriesJson.length * 3;
  bytesCount += 3 + object.roleAssignmentId.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.sessionId.length * 3;
  bytesCount += 3 + object.sessionType.length * 3;
  bytesCount += 3 + object.status.length * 3;
  {
    final value = object.streamId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.submittedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.termId.length * 3;
  return bytesCount;
}

void _classAttendanceDraftIsarSerialize(
  ClassAttendanceDraftIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.academicYearId);
  writer.writeDateTime(offsets[1], object.cachedAt);
  writer.writeString(offsets[2], object.campusId);
  writer.writeString(offsets[3], object.classId);
  writer.writeString(offsets[4], object.className);
  writer.writeDateTime(offsets[5], object.date);
  writer.writeString(offsets[6], object.deviceId);
  writer.writeString(offsets[7], object.entriesJson);
  writer.writeDateTime(offsets[8], object.lastCorrectedAt);
  writer.writeString(offsets[9], object.roleAssignmentId);
  writer.writeString(offsets[10], object.schoolId);
  writer.writeString(offsets[11], object.sessionId);
  writer.writeString(offsets[12], object.sessionType);
  writer.writeString(offsets[13], object.status);
  writer.writeString(offsets[14], object.streamId);
  writer.writeDateTime(offsets[15], object.submittedAt);
  writer.writeString(offsets[16], object.submittedBy);
  writer.writeString(offsets[17], object.termId);
}

ClassAttendanceDraftIsar _classAttendanceDraftIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ClassAttendanceDraftIsar();
  object.academicYearId = reader.readString(offsets[0]);
  object.cachedAt = reader.readDateTime(offsets[1]);
  object.campusId = reader.readString(offsets[2]);
  object.classId = reader.readString(offsets[3]);
  object.className = reader.readString(offsets[4]);
  object.date = reader.readDateTime(offsets[5]);
  object.deviceId = reader.readString(offsets[6]);
  object.entriesJson = reader.readString(offsets[7]);
  object.lastCorrectedAt = reader.readDateTimeOrNull(offsets[8]);
  object.roleAssignmentId = reader.readString(offsets[9]);
  object.schoolId = reader.readString(offsets[10]);
  object.sessionId = reader.readString(offsets[11]);
  object.sessionType = reader.readString(offsets[12]);
  object.status = reader.readString(offsets[13]);
  object.streamId = reader.readStringOrNull(offsets[14]);
  object.submittedAt = reader.readDateTimeOrNull(offsets[15]);
  object.submittedBy = reader.readStringOrNull(offsets[16]);
  object.termId = reader.readString(offsets[17]);
  return object;
}

P _classAttendanceDraftIsarDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _classAttendanceDraftIsarGetId(ClassAttendanceDraftIsar object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _classAttendanceDraftIsarGetLinks(
    ClassAttendanceDraftIsar object) {
  return [];
}

void _classAttendanceDraftIsarAttach(
    IsarCollection<dynamic> col, Id id, ClassAttendanceDraftIsar object) {}

extension ClassAttendanceDraftIsarByIndex
    on IsarCollection<ClassAttendanceDraftIsar> {
  Future<ClassAttendanceDraftIsar?> getBySessionId(String sessionId) {
    return getByIndex(r'sessionId', [sessionId]);
  }

  ClassAttendanceDraftIsar? getBySessionIdSync(String sessionId) {
    return getByIndexSync(r'sessionId', [sessionId]);
  }

  Future<bool> deleteBySessionId(String sessionId) {
    return deleteByIndex(r'sessionId', [sessionId]);
  }

  bool deleteBySessionIdSync(String sessionId) {
    return deleteByIndexSync(r'sessionId', [sessionId]);
  }

  Future<List<ClassAttendanceDraftIsar?>> getAllBySessionId(
      List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'sessionId', values);
  }

  List<ClassAttendanceDraftIsar?> getAllBySessionIdSync(
      List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sessionId', values);
  }

  Future<int> deleteAllBySessionId(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sessionId', values);
  }

  int deleteAllBySessionIdSync(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sessionId', values);
  }

  Future<Id> putBySessionId(ClassAttendanceDraftIsar object) {
    return putByIndex(r'sessionId', object);
  }

  Id putBySessionIdSync(ClassAttendanceDraftIsar object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'sessionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySessionId(List<ClassAttendanceDraftIsar> objects) {
    return putAllByIndex(r'sessionId', objects);
  }

  List<Id> putAllBySessionIdSync(List<ClassAttendanceDraftIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'sessionId', objects, saveLinks: saveLinks);
  }
}

extension ClassAttendanceDraftIsarQueryWhereSort on QueryBuilder<
    ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QWhere> {
  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ClassAttendanceDraftIsarQueryWhere on QueryBuilder<
    ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QWhereClause> {
  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterWhereClause> isarIdBetween(
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterWhereClause> sessionIdEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId',
        value: [sessionId],
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterWhereClause> sessionIdNotEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterWhereClause> schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

extension ClassAttendanceDraftIsarQueryFilter on QueryBuilder<
    ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QFilterCondition> {
  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> academicYearIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> academicYearIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'academicYearId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> cachedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cachedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> campusIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> campusIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> classIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> classIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'classId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> classNameEqualTo(
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> classNameGreaterThan(
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> classNameLessThan(
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> classNameBetween(
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> classNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'className',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> classNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'className',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> entriesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entriesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> entriesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entriesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> entriesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entriesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> entriesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entriesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> entriesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entriesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> entriesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entriesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
          QAfterFilterCondition>
      entriesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entriesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
          QAfterFilterCondition>
      entriesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entriesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> entriesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entriesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> entriesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entriesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> isarIdGreaterThan(
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> isarIdLessThan(
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> isarIdBetween(
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> lastCorrectedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCorrectedAt',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> lastCorrectedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCorrectedAt',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> lastCorrectedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCorrectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> lastCorrectedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCorrectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> lastCorrectedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCorrectedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> lastCorrectedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCorrectedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> roleAssignmentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roleAssignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> roleAssignmentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roleAssignmentId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> sessionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> sessionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> sessionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> sessionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> sessionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> sessionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
          QAfterFilterCondition>
      sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
          QAfterFilterCondition>
      sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sessionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> sessionTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionType',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> sessionTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionType',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> streamIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> streamIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamId',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> streamIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> streamIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> submittedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'submittedAt',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> submittedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'submittedAt',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> submittedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'submittedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> submittedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'submittedBy',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> submittedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'submittedBy',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> submittedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'submittedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> submittedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'submittedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> submittedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'submittedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> submittedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'submittedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> submittedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'submittedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> submittedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'submittedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
          QAfterFilterCondition>
      submittedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'submittedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
          QAfterFilterCondition>
      submittedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'submittedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> submittedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'submittedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> submittedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'submittedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
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

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> termIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'termId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar,
      QAfterFilterCondition> termIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'termId',
        value: '',
      ));
    });
  }
}

extension ClassAttendanceDraftIsarQueryObject on QueryBuilder<
    ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QFilterCondition> {}

extension ClassAttendanceDraftIsarQueryLinks on QueryBuilder<
    ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QFilterCondition> {}

extension ClassAttendanceDraftIsarQuerySortBy on QueryBuilder<
    ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QSortBy> {
  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByEntriesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entriesJson', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByEntriesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entriesJson', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByLastCorrectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCorrectedAt', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByLastCorrectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCorrectedAt', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByRoleAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByRoleAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortBySessionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionType', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortBySessionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionType', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortBySubmittedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortBySubmittedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedBy', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortBySubmittedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedBy', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByTermId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      sortByTermIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.desc);
    });
  }
}

extension ClassAttendanceDraftIsarQuerySortThenBy on QueryBuilder<
    ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QSortThenBy> {
  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByAcademicYearId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByAcademicYearIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYearId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByCachedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cachedAt', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByClassId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByClassIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByEntriesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entriesJson', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByEntriesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entriesJson', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByLastCorrectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCorrectedAt', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByLastCorrectedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCorrectedAt', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByRoleAssignmentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByRoleAssignmentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roleAssignmentId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenBySessionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionType', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenBySessionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionType', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByStreamId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByStreamIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamId', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenBySubmittedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenBySubmittedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedBy', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenBySubmittedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedBy', Sort.desc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByTermId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.asc);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QAfterSortBy>
      thenByTermIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'termId', Sort.desc);
    });
  }
}

extension ClassAttendanceDraftIsarQueryWhereDistinct on QueryBuilder<
    ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct> {
  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctByAcademicYearId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'academicYearId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctByCachedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cachedAt');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctByCampusId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'campusId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctByClassId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctByClassName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'className', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctByEntriesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entriesJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctByLastCorrectedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCorrectedAt');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctByRoleAssignmentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roleAssignmentId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctBySessionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctBySessionType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctByStreamId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'submittedAt');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctBySubmittedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'submittedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QDistinct>
      distinctByTermId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'termId', caseSensitive: caseSensitive);
    });
  }
}

extension ClassAttendanceDraftIsarQueryProperty on QueryBuilder<
    ClassAttendanceDraftIsar, ClassAttendanceDraftIsar, QQueryProperty> {
  QueryBuilder<ClassAttendanceDraftIsar, int, QQueryOperations>
      isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, String, QQueryOperations>
      academicYearIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'academicYearId');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, DateTime, QQueryOperations>
      cachedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cachedAt');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, String, QQueryOperations>
      campusIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campusId');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, String, QQueryOperations>
      classIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classId');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, String, QQueryOperations>
      classNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'className');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, DateTime, QQueryOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, String, QQueryOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, String, QQueryOperations>
      entriesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entriesJson');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, DateTime?, QQueryOperations>
      lastCorrectedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCorrectedAt');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, String, QQueryOperations>
      roleAssignmentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roleAssignmentId');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, String, QQueryOperations>
      sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, String, QQueryOperations>
      sessionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionType');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, String, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, String?, QQueryOperations>
      streamIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamId');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, DateTime?, QQueryOperations>
      submittedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'submittedAt');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, String?, QQueryOperations>
      submittedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'submittedBy');
    });
  }

  QueryBuilder<ClassAttendanceDraftIsar, String, QQueryOperations>
      termIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'termId');
    });
  }
}
