// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_assessment_mark.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetIsarAssessmentMarkCollection on Isar {
  IsarCollection<IsarAssessmentMark> get isarAssessmentMarks =>
      this.collection();
}

const IsarAssessmentMarkSchema = CollectionSchema(
  name: r'IsarAssessmentMark',
  id: 1458822850900258835,
  properties: {
    r'approvedBy': PropertySchema(
      id: 0,
      name: r'approvedBy',
      type: IsarType.string,
    ),
    r'assessmentTypeId': PropertySchema(
      id: 1,
      name: r'assessmentTypeId',
      type: IsarType.string,
    ),
    r'competencyLevel': PropertySchema(
      id: 2,
      name: r'competencyLevel',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isSynced': PropertySchema(id: 4, name: r'isSynced', type: IsarType.bool),
    r'moderatedBy': PropertySchema(
      id: 5,
      name: r'moderatedBy',
      type: IsarType.string,
    ),
    r'remoteId': PropertySchema(
      id: 6,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'score': PropertySchema(id: 7, name: r'score', type: IsarType.double),
    r'status': PropertySchema(id: 8, name: r'status', type: IsarType.string),
    r'studentId': PropertySchema(
      id: 9,
      name: r'studentId',
      type: IsarType.string,
    ),
    r'subjectId': PropertySchema(
      id: 10,
      name: r'subjectId',
      type: IsarType.string,
    ),
    r'teacherComment': PropertySchema(
      id: 11,
      name: r'teacherComment',
      type: IsarType.string,
    ),
    r'teacherId': PropertySchema(
      id: 12,
      name: r'teacherId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 13,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _isarAssessmentMarkEstimateSize,
  serialize: _isarAssessmentMarkSerialize,
  deserialize: _isarAssessmentMarkDeserialize,
  deserializeProp: _isarAssessmentMarkDeserializeProp,
  idName: r'id',
  indexes: {
    r'remoteId': IndexSchema(
      id: 6301175856541681032,
      name: r'remoteId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'remoteId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _isarAssessmentMarkGetId,
  getLinks: _isarAssessmentMarkGetLinks,
  attach: _isarAssessmentMarkAttach,
  version: '3.1.0+1',
);

int _isarAssessmentMarkEstimateSize(
  IsarAssessmentMark object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.approvedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.assessmentTypeId.length * 3;
  {
    final value = object.competencyLevel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.moderatedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.remoteId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.studentId.length * 3;
  bytesCount += 3 + object.subjectId.length * 3;
  {
    final value = object.teacherComment;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.teacherId.length * 3;
  return bytesCount;
}

void _isarAssessmentMarkSerialize(
  IsarAssessmentMark object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.approvedBy);
  writer.writeString(offsets[1], object.assessmentTypeId);
  writer.writeString(offsets[2], object.competencyLevel);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeBool(offsets[4], object.isSynced);
  writer.writeString(offsets[5], object.moderatedBy);
  writer.writeString(offsets[6], object.remoteId);
  writer.writeDouble(offsets[7], object.score);
  writer.writeString(offsets[8], object.status);
  writer.writeString(offsets[9], object.studentId);
  writer.writeString(offsets[10], object.subjectId);
  writer.writeString(offsets[11], object.teacherComment);
  writer.writeString(offsets[12], object.teacherId);
  writer.writeDateTime(offsets[13], object.updatedAt);
}

IsarAssessmentMark _isarAssessmentMarkDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarAssessmentMark();
  object.approvedBy = reader.readStringOrNull(offsets[0]);
  object.assessmentTypeId = reader.readString(offsets[1]);
  object.competencyLevel = reader.readStringOrNull(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[4]);
  object.moderatedBy = reader.readStringOrNull(offsets[5]);
  object.remoteId = reader.readString(offsets[6]);
  object.score = reader.readDoubleOrNull(offsets[7]);
  object.status = reader.readString(offsets[8]);
  object.studentId = reader.readString(offsets[9]);
  object.subjectId = reader.readString(offsets[10]);
  object.teacherComment = reader.readStringOrNull(offsets[11]);
  object.teacherId = reader.readString(offsets[12]);
  object.updatedAt = reader.readDateTime(offsets[13]);
  return object;
}

P _isarAssessmentMarkDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
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
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarAssessmentMarkGetId(IsarAssessmentMark object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarAssessmentMarkGetLinks(
  IsarAssessmentMark object,
) {
  return [];
}

void _isarAssessmentMarkAttach(
  IsarCollection<dynamic> col,
  Id id,
  IsarAssessmentMark object,
) {
  object.id = id;
}

extension IsarAssessmentMarkByIndex on IsarCollection<IsarAssessmentMark> {
  Future<IsarAssessmentMark?> getByRemoteId(String remoteId) {
    return getByIndex(r'remoteId', [remoteId]);
  }

  IsarAssessmentMark? getByRemoteIdSync(String remoteId) {
    return getByIndexSync(r'remoteId', [remoteId]);
  }

  Future<bool> deleteByRemoteId(String remoteId) {
    return deleteByIndex(r'remoteId', [remoteId]);
  }

  bool deleteByRemoteIdSync(String remoteId) {
    return deleteByIndexSync(r'remoteId', [remoteId]);
  }

  Future<List<IsarAssessmentMark?>> getAllByRemoteId(
    List<String> remoteIdValues,
  ) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'remoteId', values);
  }

  List<IsarAssessmentMark?> getAllByRemoteIdSync(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'remoteId', values);
  }

  Future<int> deleteAllByRemoteId(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'remoteId', values);
  }

  int deleteAllByRemoteIdSync(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'remoteId', values);
  }

  Future<Id> putByRemoteId(IsarAssessmentMark object) {
    return putByIndex(r'remoteId', object);
  }

  Id putByRemoteIdSync(IsarAssessmentMark object, {bool saveLinks = true}) {
    return putByIndexSync(r'remoteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRemoteId(List<IsarAssessmentMark> objects) {
    return putAllByIndex(r'remoteId', objects);
  }

  List<Id> putAllByRemoteIdSync(
    List<IsarAssessmentMark> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'remoteId', objects, saveLinks: saveLinks);
  }
}

extension IsarAssessmentMarkQueryWhereSort
    on QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QWhere> {
  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension IsarAssessmentMarkQueryWhere
    on QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QWhereClause> {
  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterWhereClause>
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

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterWhereClause>
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

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterWhereClause>
  remoteIdEqualTo(String remoteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'remoteId', value: [remoteId]),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterWhereClause>
  remoteIdNotEqualTo(String remoteId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [],
                upper: [remoteId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [remoteId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [remoteId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [],
                upper: [remoteId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension IsarAssessmentMarkQueryFilter
    on QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QFilterCondition> {
  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  approvedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'approvedBy'),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  approvedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'approvedBy'),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  approvedByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'approvedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  approvedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'approvedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  approvedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'approvedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  approvedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'approvedBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  approvedByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'approvedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  approvedByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'approvedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  approvedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'approvedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  approvedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'approvedBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  approvedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'approvedBy', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  approvedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'approvedBy', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  assessmentTypeIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'assessmentTypeId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  assessmentTypeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'assessmentTypeId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  assessmentTypeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'assessmentTypeId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  assessmentTypeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'assessmentTypeId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  assessmentTypeIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'assessmentTypeId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  assessmentTypeIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'assessmentTypeId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  assessmentTypeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'assessmentTypeId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  assessmentTypeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'assessmentTypeId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  assessmentTypeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'assessmentTypeId', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  assessmentTypeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'assessmentTypeId', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  competencyLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'competencyLevel'),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  competencyLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'competencyLevel'),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  competencyLevelEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'competencyLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  competencyLevelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'competencyLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  competencyLevelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'competencyLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  competencyLevelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'competencyLevel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  competencyLevelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'competencyLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  competencyLevelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'competencyLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  competencyLevelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'competencyLevel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  competencyLevelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'competencyLevel',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  competencyLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'competencyLevel', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  competencyLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'competencyLevel', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
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

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
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

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
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

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
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

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
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

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
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

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isSynced', value: value),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  moderatedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'moderatedBy'),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  moderatedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'moderatedBy'),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  moderatedByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'moderatedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  moderatedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'moderatedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  moderatedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'moderatedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  moderatedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'moderatedBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  moderatedByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'moderatedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  moderatedByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'moderatedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  moderatedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'moderatedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  moderatedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'moderatedBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  moderatedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'moderatedBy', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  moderatedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'moderatedBy', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  remoteIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  remoteIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  remoteIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  remoteIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remoteId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  remoteIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  remoteIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  remoteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  remoteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'remoteId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  scoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'score'),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  scoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'score'),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  scoreEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'score',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  scoreGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'score',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  scoreLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'score',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  scoreBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'score',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  statusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  studentIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'studentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  studentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'studentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  studentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'studentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  studentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'studentId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  studentIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'studentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  studentIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'studentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  studentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'studentId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  studentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'studentId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  studentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'studentId', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  studentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'studentId', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  subjectIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'subjectId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  subjectIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'subjectId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  subjectIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'subjectId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  subjectIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'subjectId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  subjectIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'subjectId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  subjectIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'subjectId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  subjectIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'subjectId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  subjectIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'subjectId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  subjectIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'subjectId', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  subjectIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'subjectId', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherCommentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'teacherComment'),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherCommentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'teacherComment'),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherCommentEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'teacherComment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherCommentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'teacherComment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherCommentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'teacherComment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherCommentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'teacherComment',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherCommentStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'teacherComment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherCommentEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'teacherComment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherCommentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'teacherComment',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherCommentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'teacherComment',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherCommentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'teacherComment', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherCommentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'teacherComment', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'teacherId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'teacherId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'teacherId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'teacherId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'teacherId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'teacherId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'teacherId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'teacherId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'teacherId', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  teacherIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'teacherId', value: ''),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension IsarAssessmentMarkQueryObject
    on QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QFilterCondition> {}

extension IsarAssessmentMarkQueryLinks
    on QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QFilterCondition> {}

extension IsarAssessmentMarkQuerySortBy
    on QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QSortBy> {
  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByApprovedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByApprovedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByAssessmentTypeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assessmentTypeId', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByAssessmentTypeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assessmentTypeId', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByCompetencyLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'competencyLevel', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByCompetencyLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'competencyLevel', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByModeratedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moderatedBy', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByModeratedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moderatedBy', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByTeacherComment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacherComment', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByTeacherCommentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacherComment', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByTeacherId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacherId', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByTeacherIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacherId', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension IsarAssessmentMarkQuerySortThenBy
    on QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QSortThenBy> {
  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByApprovedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByApprovedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvedBy', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByAssessmentTypeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assessmentTypeId', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByAssessmentTypeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assessmentTypeId', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByCompetencyLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'competencyLevel', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByCompetencyLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'competencyLevel', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByModeratedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moderatedBy', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByModeratedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moderatedBy', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByTeacherComment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacherComment', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByTeacherCommentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacherComment', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByTeacherId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacherId', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByTeacherIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teacherId', Sort.desc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension IsarAssessmentMarkQueryWhereDistinct
    on QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct> {
  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct>
  distinctByApprovedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct>
  distinctByAssessmentTypeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'assessmentTypeId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct>
  distinctByCompetencyLevel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'competencyLevel',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct>
  distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct>
  distinctByModeratedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moderatedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct>
  distinctByRemoteId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct>
  distinctByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'score');
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct>
  distinctByStudentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct>
  distinctBySubjectId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct>
  distinctByTeacherComment({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'teacherComment',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct>
  distinctByTeacherId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'teacherId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension IsarAssessmentMarkQueryProperty
    on QueryBuilder<IsarAssessmentMark, IsarAssessmentMark, QQueryProperty> {
  QueryBuilder<IsarAssessmentMark, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<IsarAssessmentMark, String?, QQueryOperations>
  approvedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvedBy');
    });
  }

  QueryBuilder<IsarAssessmentMark, String, QQueryOperations>
  assessmentTypeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assessmentTypeId');
    });
  }

  QueryBuilder<IsarAssessmentMark, String?, QQueryOperations>
  competencyLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'competencyLevel');
    });
  }

  QueryBuilder<IsarAssessmentMark, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<IsarAssessmentMark, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<IsarAssessmentMark, String?, QQueryOperations>
  moderatedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moderatedBy');
    });
  }

  QueryBuilder<IsarAssessmentMark, String, QQueryOperations>
  remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<IsarAssessmentMark, double?, QQueryOperations> scoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'score');
    });
  }

  QueryBuilder<IsarAssessmentMark, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<IsarAssessmentMark, String, QQueryOperations>
  studentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studentId');
    });
  }

  QueryBuilder<IsarAssessmentMark, String, QQueryOperations>
  subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectId');
    });
  }

  QueryBuilder<IsarAssessmentMark, String?, QQueryOperations>
  teacherCommentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'teacherComment');
    });
  }

  QueryBuilder<IsarAssessmentMark, String, QQueryOperations>
  teacherIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'teacherId');
    });
  }

  QueryBuilder<IsarAssessmentMark, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
