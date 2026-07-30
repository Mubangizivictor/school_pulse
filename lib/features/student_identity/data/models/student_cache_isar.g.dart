// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_cache_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStudentCacheIsarCollection on Isar {
  IsarCollection<StudentCacheIsar> get studentCacheIsars => this.collection();
}

const StudentCacheIsarSchema = CollectionSchema(
  name: r'StudentCacheIsar',
  id: 78590377147248338,
  properties: {
    r'className': PropertySchema(
      id: 0,
      name: r'className',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    ),
    r'photoUrl': PropertySchema(
      id: 2,
      name: r'photoUrl',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 3,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'schoolStudentId': PropertySchema(
      id: 4,
      name: r'schoolStudentId',
      type: IsarType.string,
    ),
    r'stream': PropertySchema(
      id: 5,
      name: r'stream',
      type: IsarType.string,
    ),
    r'studentId': PropertySchema(
      id: 6,
      name: r'studentId',
      type: IsarType.string,
    ),
    r'uniqueSystemId': PropertySchema(
      id: 7,
      name: r'uniqueSystemId',
      type: IsarType.string,
    )
  },
  estimateSize: _studentCacheIsarEstimateSize,
  serialize: _studentCacheIsarSerialize,
  deserialize: _studentCacheIsarDeserialize,
  deserializeProp: _studentCacheIsarDeserializeProp,
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
    r'uniqueSystemId': IndexSchema(
      id: 5532902650132902515,
      name: r'uniqueSystemId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uniqueSystemId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _studentCacheIsarGetId,
  getLinks: _studentCacheIsarGetLinks,
  attach: _studentCacheIsarAttach,
  version: '3.1.0+1',
);

int _studentCacheIsarEstimateSize(
  StudentCacheIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.className.length * 3;
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.photoUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.schoolStudentId.length * 3;
  {
    final value = object.stream;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.studentId.length * 3;
  bytesCount += 3 + object.uniqueSystemId.length * 3;
  return bytesCount;
}

void _studentCacheIsarSerialize(
  StudentCacheIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.className);
  writer.writeString(offsets[1], object.name);
  writer.writeString(offsets[2], object.photoUrl);
  writer.writeString(offsets[3], object.schoolId);
  writer.writeString(offsets[4], object.schoolStudentId);
  writer.writeString(offsets[5], object.stream);
  writer.writeString(offsets[6], object.studentId);
  writer.writeString(offsets[7], object.uniqueSystemId);
}

StudentCacheIsar _studentCacheIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StudentCacheIsar();
  object.className = reader.readString(offsets[0]);
  object.id = id;
  object.name = reader.readString(offsets[1]);
  object.photoUrl = reader.readStringOrNull(offsets[2]);
  object.schoolId = reader.readString(offsets[3]);
  object.schoolStudentId = reader.readString(offsets[4]);
  object.stream = reader.readStringOrNull(offsets[5]);
  object.studentId = reader.readString(offsets[6]);
  object.uniqueSystemId = reader.readString(offsets[7]);
  return object;
}

P _studentCacheIsarDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _studentCacheIsarGetId(StudentCacheIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _studentCacheIsarGetLinks(StudentCacheIsar object) {
  return [];
}

void _studentCacheIsarAttach(
    IsarCollection<dynamic> col, Id id, StudentCacheIsar object) {
  object.id = id;
}

extension StudentCacheIsarByIndex on IsarCollection<StudentCacheIsar> {
  Future<StudentCacheIsar?> getByStudentId(String studentId) {
    return getByIndex(r'studentId', [studentId]);
  }

  StudentCacheIsar? getByStudentIdSync(String studentId) {
    return getByIndexSync(r'studentId', [studentId]);
  }

  Future<bool> deleteByStudentId(String studentId) {
    return deleteByIndex(r'studentId', [studentId]);
  }

  bool deleteByStudentIdSync(String studentId) {
    return deleteByIndexSync(r'studentId', [studentId]);
  }

  Future<List<StudentCacheIsar?>> getAllByStudentId(
      List<String> studentIdValues) {
    final values = studentIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'studentId', values);
  }

  List<StudentCacheIsar?> getAllByStudentIdSync(List<String> studentIdValues) {
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

  Future<Id> putByStudentId(StudentCacheIsar object) {
    return putByIndex(r'studentId', object);
  }

  Id putByStudentIdSync(StudentCacheIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'studentId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByStudentId(List<StudentCacheIsar> objects) {
    return putAllByIndex(r'studentId', objects);
  }

  List<Id> putAllByStudentIdSync(List<StudentCacheIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'studentId', objects, saveLinks: saveLinks);
  }

  Future<StudentCacheIsar?> getByUniqueSystemId(String uniqueSystemId) {
    return getByIndex(r'uniqueSystemId', [uniqueSystemId]);
  }

  StudentCacheIsar? getByUniqueSystemIdSync(String uniqueSystemId) {
    return getByIndexSync(r'uniqueSystemId', [uniqueSystemId]);
  }

  Future<bool> deleteByUniqueSystemId(String uniqueSystemId) {
    return deleteByIndex(r'uniqueSystemId', [uniqueSystemId]);
  }

  bool deleteByUniqueSystemIdSync(String uniqueSystemId) {
    return deleteByIndexSync(r'uniqueSystemId', [uniqueSystemId]);
  }

  Future<List<StudentCacheIsar?>> getAllByUniqueSystemId(
      List<String> uniqueSystemIdValues) {
    final values = uniqueSystemIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'uniqueSystemId', values);
  }

  List<StudentCacheIsar?> getAllByUniqueSystemIdSync(
      List<String> uniqueSystemIdValues) {
    final values = uniqueSystemIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uniqueSystemId', values);
  }

  Future<int> deleteAllByUniqueSystemId(List<String> uniqueSystemIdValues) {
    final values = uniqueSystemIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uniqueSystemId', values);
  }

  int deleteAllByUniqueSystemIdSync(List<String> uniqueSystemIdValues) {
    final values = uniqueSystemIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uniqueSystemId', values);
  }

  Future<Id> putByUniqueSystemId(StudentCacheIsar object) {
    return putByIndex(r'uniqueSystemId', object);
  }

  Id putByUniqueSystemIdSync(StudentCacheIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'uniqueSystemId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUniqueSystemId(List<StudentCacheIsar> objects) {
    return putAllByIndex(r'uniqueSystemId', objects);
  }

  List<Id> putAllByUniqueSystemIdSync(List<StudentCacheIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uniqueSystemId', objects, saveLinks: saveLinks);
  }
}

extension StudentCacheIsarQueryWhereSort
    on QueryBuilder<StudentCacheIsar, StudentCacheIsar, QWhere> {
  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StudentCacheIsarQueryWhere
    on QueryBuilder<StudentCacheIsar, StudentCacheIsar, QWhereClause> {
  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterWhereClause>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterWhereClause>
      studentIdEqualTo(String studentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'studentId',
        value: [studentId],
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterWhereClause>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterWhereClause>
      uniqueSystemIdEqualTo(String uniqueSystemId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uniqueSystemId',
        value: [uniqueSystemId],
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterWhereClause>
      uniqueSystemIdNotEqualTo(String uniqueSystemId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueSystemId',
              lower: [],
              upper: [uniqueSystemId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueSystemId',
              lower: [uniqueSystemId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueSystemId',
              lower: [uniqueSystemId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueSystemId',
              lower: [],
              upper: [uniqueSystemId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension StudentCacheIsarQueryFilter
    on QueryBuilder<StudentCacheIsar, StudentCacheIsar, QFilterCondition> {
  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      classNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'className',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      classNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'className',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      classNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'className',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      classNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'className',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      photoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'photoUrl',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      photoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'photoUrl',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      photoUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      photoUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      photoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      photoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      schoolStudentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolStudentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      schoolStudentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schoolStudentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      schoolStudentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schoolStudentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      schoolStudentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schoolStudentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      schoolStudentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schoolStudentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      schoolStudentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schoolStudentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      schoolStudentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolStudentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      schoolStudentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolStudentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      schoolStudentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolStudentId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      schoolStudentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolStudentId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      streamIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stream',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      streamIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stream',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      streamEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stream',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      streamGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stream',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      streamLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stream',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      streamBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stream',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      streamStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stream',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      streamEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stream',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      streamContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stream',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      streamMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stream',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      streamIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stream',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      streamIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stream',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
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

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      studentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      studentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'studentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      studentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      studentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      uniqueSystemIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      uniqueSystemIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uniqueSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      uniqueSystemIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uniqueSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      uniqueSystemIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uniqueSystemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      uniqueSystemIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uniqueSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      uniqueSystemIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uniqueSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      uniqueSystemIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uniqueSystemId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      uniqueSystemIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uniqueSystemId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      uniqueSystemIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueSystemId',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterFilterCondition>
      uniqueSystemIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uniqueSystemId',
        value: '',
      ));
    });
  }
}

extension StudentCacheIsarQueryObject
    on QueryBuilder<StudentCacheIsar, StudentCacheIsar, QFilterCondition> {}

extension StudentCacheIsarQueryLinks
    on QueryBuilder<StudentCacheIsar, StudentCacheIsar, QFilterCondition> {}

extension StudentCacheIsarQuerySortBy
    on QueryBuilder<StudentCacheIsar, StudentCacheIsar, QSortBy> {
  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortByPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortByPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortBySchoolStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolStudentId', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortBySchoolStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolStudentId', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortByStream() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stream', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortByStreamDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stream', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortByUniqueSystemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueSystemId', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      sortByUniqueSystemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueSystemId', Sort.desc);
    });
  }
}

extension StudentCacheIsarQuerySortThenBy
    on QueryBuilder<StudentCacheIsar, StudentCacheIsar, QSortThenBy> {
  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenByPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenByPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenBySchoolStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolStudentId', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenBySchoolStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolStudentId', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenByStream() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stream', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenByStreamDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stream', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenByUniqueSystemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueSystemId', Sort.asc);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QAfterSortBy>
      thenByUniqueSystemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueSystemId', Sort.desc);
    });
  }
}

extension StudentCacheIsarQueryWhereDistinct
    on QueryBuilder<StudentCacheIsar, StudentCacheIsar, QDistinct> {
  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QDistinct>
      distinctByClassName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'className', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QDistinct>
      distinctByPhotoUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QDistinct>
      distinctBySchoolStudentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolStudentId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QDistinct> distinctByStream(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stream', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QDistinct>
      distinctByStudentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentCacheIsar, StudentCacheIsar, QDistinct>
      distinctByUniqueSystemId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uniqueSystemId',
          caseSensitive: caseSensitive);
    });
  }
}

extension StudentCacheIsarQueryProperty
    on QueryBuilder<StudentCacheIsar, StudentCacheIsar, QQueryProperty> {
  QueryBuilder<StudentCacheIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StudentCacheIsar, String, QQueryOperations> classNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'className');
    });
  }

  QueryBuilder<StudentCacheIsar, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<StudentCacheIsar, String?, QQueryOperations> photoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoUrl');
    });
  }

  QueryBuilder<StudentCacheIsar, String, QQueryOperations> schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<StudentCacheIsar, String, QQueryOperations>
      schoolStudentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolStudentId');
    });
  }

  QueryBuilder<StudentCacheIsar, String?, QQueryOperations> streamProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stream');
    });
  }

  QueryBuilder<StudentCacheIsar, String, QQueryOperations> studentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studentId');
    });
  }

  QueryBuilder<StudentCacheIsar, String, QQueryOperations>
      uniqueSystemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uniqueSystemId');
    });
  }
}
