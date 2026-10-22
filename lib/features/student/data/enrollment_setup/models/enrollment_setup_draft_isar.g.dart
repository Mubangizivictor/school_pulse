// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrollment_setup_draft_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEnrollmentSetupDraftIsarCollection on Isar {
  IsarCollection<EnrollmentSetupDraftIsar> get enrollmentSetupDraftIsars =>
      this.collection();
}

const EnrollmentSetupDraftIsarSchema = CollectionSchema(
  name: r'EnrollmentSetupDraftIsar',
  id: 2091975085555588178,
  properties: {
    r'applicationId': PropertySchema(
      id: 0,
      name: r'applicationId',
      type: IsarType.string,
    ),
    r'completedStepCount': PropertySchema(
      id: 1,
      name: r'completedStepCount',
      type: IsarType.long,
    ),
    r'completedStepsMask': PropertySchema(
      id: 2,
      name: r'completedStepsMask',
      type: IsarType.long,
    ),
    r'currentStep': PropertySchema(
      id: 3,
      name: r'currentStep',
      type: IsarType.long,
    ),
    r'schoolId': PropertySchema(
      id: 4,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'stateJson': PropertySchema(
      id: 5,
      name: r'stateJson',
      type: IsarType.string,
    ),
    r'studentId': PropertySchema(
      id: 6,
      name: r'studentId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 7,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _enrollmentSetupDraftIsarEstimateSize,
  serialize: _enrollmentSetupDraftIsarSerialize,
  deserialize: _enrollmentSetupDraftIsarDeserialize,
  deserializeProp: _enrollmentSetupDraftIsarDeserializeProp,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _enrollmentSetupDraftIsarGetId,
  getLinks: _enrollmentSetupDraftIsarGetLinks,
  attach: _enrollmentSetupDraftIsarAttach,
  version: '3.1.0+1',
);

int _enrollmentSetupDraftIsarEstimateSize(
  EnrollmentSetupDraftIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.applicationId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.stateJson.length * 3;
  bytesCount += 3 + object.studentId.length * 3;
  return bytesCount;
}

void _enrollmentSetupDraftIsarSerialize(
  EnrollmentSetupDraftIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.applicationId);
  writer.writeLong(offsets[1], object.completedStepCount);
  writer.writeLong(offsets[2], object.completedStepsMask);
  writer.writeLong(offsets[3], object.currentStep);
  writer.writeString(offsets[4], object.schoolId);
  writer.writeString(offsets[5], object.stateJson);
  writer.writeString(offsets[6], object.studentId);
  writer.writeDateTime(offsets[7], object.updatedAt);
}

EnrollmentSetupDraftIsar _enrollmentSetupDraftIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EnrollmentSetupDraftIsar();
  object.applicationId = reader.readStringOrNull(offsets[0]);
  object.completedStepsMask = reader.readLong(offsets[2]);
  object.currentStep = reader.readLong(offsets[3]);
  object.schoolId = reader.readString(offsets[4]);
  object.stateJson = reader.readString(offsets[5]);
  object.studentId = reader.readString(offsets[6]);
  object.updatedAt = reader.readDateTime(offsets[7]);
  return object;
}

P _enrollmentSetupDraftIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _enrollmentSetupDraftIsarGetId(EnrollmentSetupDraftIsar object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _enrollmentSetupDraftIsarGetLinks(
    EnrollmentSetupDraftIsar object) {
  return [];
}

void _enrollmentSetupDraftIsarAttach(
    IsarCollection<dynamic> col, Id id, EnrollmentSetupDraftIsar object) {}

extension EnrollmentSetupDraftIsarByIndex
    on IsarCollection<EnrollmentSetupDraftIsar> {
  Future<EnrollmentSetupDraftIsar?> getByStudentId(String studentId) {
    return getByIndex(r'studentId', [studentId]);
  }

  EnrollmentSetupDraftIsar? getByStudentIdSync(String studentId) {
    return getByIndexSync(r'studentId', [studentId]);
  }

  Future<bool> deleteByStudentId(String studentId) {
    return deleteByIndex(r'studentId', [studentId]);
  }

  bool deleteByStudentIdSync(String studentId) {
    return deleteByIndexSync(r'studentId', [studentId]);
  }

  Future<List<EnrollmentSetupDraftIsar?>> getAllByStudentId(
      List<String> studentIdValues) {
    final values = studentIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'studentId', values);
  }

  List<EnrollmentSetupDraftIsar?> getAllByStudentIdSync(
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

  Future<Id> putByStudentId(EnrollmentSetupDraftIsar object) {
    return putByIndex(r'studentId', object);
  }

  Id putByStudentIdSync(EnrollmentSetupDraftIsar object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'studentId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStudentId(List<EnrollmentSetupDraftIsar> objects) {
    return putAllByIndex(r'studentId', objects);
  }

  List<Id> putAllByStudentIdSync(List<EnrollmentSetupDraftIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'studentId', objects, saveLinks: saveLinks);
  }
}

extension EnrollmentSetupDraftIsarQueryWhereSort on QueryBuilder<
    EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QWhere> {
  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterWhere>
      anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension EnrollmentSetupDraftIsarQueryWhere on QueryBuilder<
    EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QWhereClause> {
  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterWhereClause> isarIdGreaterThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterWhereClause> isarIdLessThan(Id isarId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterWhereClause> studentIdEqualTo(String studentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'studentId',
        value: [studentId],
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterWhereClause> studentIdNotEqualTo(String studentId) {
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterWhereClause> schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

extension EnrollmentSetupDraftIsarQueryFilter on QueryBuilder<
    EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QFilterCondition> {
  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> applicationIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'applicationId',
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> applicationIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'applicationId',
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> applicationIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'applicationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> applicationIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'applicationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> applicationIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'applicationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> applicationIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'applicationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> applicationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'applicationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> applicationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'applicationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
          QAfterFilterCondition>
      applicationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'applicationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
          QAfterFilterCondition>
      applicationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'applicationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> applicationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'applicationId',
        value: '',
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> applicationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'applicationId',
        value: '',
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> completedStepCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedStepCount',
        value: value,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> completedStepCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedStepCount',
        value: value,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> completedStepCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedStepCount',
        value: value,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> completedStepCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedStepCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> completedStepsMaskEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedStepsMask',
        value: value,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> completedStepsMaskGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedStepsMask',
        value: value,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> completedStepsMaskLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedStepsMask',
        value: value,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> completedStepsMaskBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedStepsMask',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> currentStepEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentStep',
        value: value,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> currentStepGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentStep',
        value: value,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> currentStepLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentStep',
        value: value,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> currentStepBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentStep',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> stateJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> stateJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> stateJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> stateJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stateJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> stateJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> stateJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
          QAfterFilterCondition>
      stateJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stateJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
          QAfterFilterCondition>
      stateJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stateJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> stateJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stateJson',
        value: '',
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> stateJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stateJson',
        value: '',
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> studentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> studentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar,
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

extension EnrollmentSetupDraftIsarQueryObject on QueryBuilder<
    EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QFilterCondition> {}

extension EnrollmentSetupDraftIsarQueryLinks on QueryBuilder<
    EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QFilterCondition> {}

extension EnrollmentSetupDraftIsarQuerySortBy on QueryBuilder<
    EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QSortBy> {
  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortByApplicationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applicationId', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortByApplicationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applicationId', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortByCompletedStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStepCount', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortByCompletedStepCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStepCount', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortByCompletedStepsMask() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStepsMask', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortByCompletedStepsMaskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStepsMask', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortByCurrentStep() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStep', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortByCurrentStepDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStep', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortByStateJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateJson', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortByStateJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateJson', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension EnrollmentSetupDraftIsarQuerySortThenBy on QueryBuilder<
    EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QSortThenBy> {
  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByApplicationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applicationId', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByApplicationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applicationId', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByCompletedStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStepCount', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByCompletedStepCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStepCount', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByCompletedStepsMask() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStepsMask', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByCompletedStepsMaskDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedStepsMask', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByCurrentStep() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStep', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByCurrentStepDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStep', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByStateJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateJson', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByStateJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stateJson', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension EnrollmentSetupDraftIsarQueryWhereDistinct on QueryBuilder<
    EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QDistinct> {
  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QDistinct>
      distinctByApplicationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'applicationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QDistinct>
      distinctByCompletedStepCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedStepCount');
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QDistinct>
      distinctByCompletedStepsMask() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedStepsMask');
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QDistinct>
      distinctByCurrentStep() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStep');
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QDistinct>
      distinctByStateJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stateJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QDistinct>
      distinctByStudentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension EnrollmentSetupDraftIsarQueryProperty on QueryBuilder<
    EnrollmentSetupDraftIsar, EnrollmentSetupDraftIsar, QQueryProperty> {
  QueryBuilder<EnrollmentSetupDraftIsar, int, QQueryOperations>
      isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, String?, QQueryOperations>
      applicationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'applicationId');
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, int, QQueryOperations>
      completedStepCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedStepCount');
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, int, QQueryOperations>
      completedStepsMaskProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedStepsMask');
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, int, QQueryOperations>
      currentStepProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStep');
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, String, QQueryOperations>
      stateJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stateJson');
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, String, QQueryOperations>
      studentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studentId');
    });
  }

  QueryBuilder<EnrollmentSetupDraftIsar, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
