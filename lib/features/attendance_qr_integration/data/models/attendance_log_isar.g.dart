// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_log_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAttendanceLogIsarCollection on Isar {
  IsarCollection<AttendanceLogIsar> get attendanceLogIsars => this.collection();
}

const AttendanceLogIsarSchema = CollectionSchema(
  name: r'AttendanceLogIsar',
  id: -592391286840993469,
  properties: {
    r'className': PropertySchema(
      id: 0,
      name: r'className',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(id: 1, name: r'isSynced', type: IsarType.bool),
    r'module': PropertySchema(id: 2, name: r'module', type: IsarType.string),
    r'scannedBy': PropertySchema(
      id: 3,
      name: r'scannedBy',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 4,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(id: 5, name: r'status', type: IsarType.string),
    r'studentName': PropertySchema(
      id: 6,
      name: r'studentName',
      type: IsarType.string,
    ),
    r'studentUniqueId': PropertySchema(
      id: 7,
      name: r'studentUniqueId',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 8,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _attendanceLogIsarEstimateSize,
  serialize: _attendanceLogIsarSerialize,
  deserialize: _attendanceLogIsarDeserialize,
  deserializeProp: _attendanceLogIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'isSynced': IndexSchema(
      id: -39763503327887510,
      name: r'isSynced',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isSynced',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _attendanceLogIsarGetId,
  getLinks: _attendanceLogIsarGetLinks,
  attach: _attendanceLogIsarAttach,
  version: '3.1.0+1',
);

int _attendanceLogIsarEstimateSize(
  AttendanceLogIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.className.length * 3;
  bytesCount += 3 + object.module.length * 3;
  bytesCount += 3 + object.scannedBy.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.studentName.length * 3;
  bytesCount += 3 + object.studentUniqueId.length * 3;
  return bytesCount;
}

void _attendanceLogIsarSerialize(
  AttendanceLogIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.className);
  writer.writeBool(offsets[1], object.isSynced);
  writer.writeString(offsets[2], object.module);
  writer.writeString(offsets[3], object.scannedBy);
  writer.writeString(offsets[4], object.schoolId);
  writer.writeString(offsets[5], object.status);
  writer.writeString(offsets[6], object.studentName);
  writer.writeString(offsets[7], object.studentUniqueId);
  writer.writeDateTime(offsets[8], object.timestamp);
}

AttendanceLogIsar _attendanceLogIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AttendanceLogIsar();
  object.className = reader.readString(offsets[0]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[1]);
  object.module = reader.readString(offsets[2]);
  object.scannedBy = reader.readString(offsets[3]);
  object.schoolId = reader.readString(offsets[4]);
  object.status = reader.readString(offsets[5]);
  object.studentName = reader.readString(offsets[6]);
  object.studentUniqueId = reader.readString(offsets[7]);
  object.timestamp = reader.readDateTime(offsets[8]);
  return object;
}

P _attendanceLogIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _attendanceLogIsarGetId(AttendanceLogIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _attendanceLogIsarGetLinks(
  AttendanceLogIsar object,
) {
  return [];
}

void _attendanceLogIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  AttendanceLogIsar object,
) {
  object.id = id;
}

extension AttendanceLogIsarQueryWhereSort
    on QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QWhere> {
  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterWhere>
  anyIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSynced'),
      );
    });
  }
}

extension AttendanceLogIsarQueryWhere
    on QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QWhereClause> {
  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterWhereClause>
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

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterWhereClause>
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

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterWhereClause>
  isSyncedEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'isSynced', value: [isSynced]),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterWhereClause>
  isSyncedNotEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isSynced',
                lower: [],
                upper: [isSynced],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isSynced',
                lower: [isSynced],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isSynced',
                lower: [isSynced],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isSynced',
                lower: [],
                upper: [isSynced],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension AttendanceLogIsarQueryFilter
    on QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QFilterCondition> {
  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  classNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'className',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  classNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'className',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  classNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'className',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  classNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'className',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  classNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'className',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  classNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'className',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  classNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'className',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  classNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'className',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  classNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'className', value: ''),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  classNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'className', value: ''),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
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

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
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

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
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

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isSynced', value: value),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  moduleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'module',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  moduleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'module',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  moduleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'module',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  moduleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'module',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  moduleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'module',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  moduleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'module',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  moduleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'module',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  moduleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'module',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  moduleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'module', value: ''),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  moduleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'module', value: ''),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  scannedByEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'scannedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  scannedByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'scannedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  scannedByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'scannedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  scannedByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'scannedBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  scannedByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'scannedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  scannedByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'scannedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  scannedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'scannedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  scannedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'scannedBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  scannedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'scannedBy', value: ''),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  scannedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'scannedBy', value: ''),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  schoolIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'schoolId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  schoolIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'schoolId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  schoolIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'schoolId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  schoolIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'schoolId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  schoolIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'schoolId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  schoolIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'schoolId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'schoolId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'schoolId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
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

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
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

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
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

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
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

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
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

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
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

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
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

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
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

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'studentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'studentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'studentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'studentName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'studentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'studentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'studentName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'studentName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'studentName', value: ''),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'studentName', value: ''),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentUniqueIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'studentUniqueId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentUniqueIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'studentUniqueId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentUniqueIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'studentUniqueId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentUniqueIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'studentUniqueId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentUniqueIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'studentUniqueId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentUniqueIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'studentUniqueId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentUniqueIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'studentUniqueId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentUniqueIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'studentUniqueId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentUniqueIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'studentUniqueId', value: ''),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  studentUniqueIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'studentUniqueId', value: ''),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  timestampGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  timestampLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterFilterCondition>
  timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension AttendanceLogIsarQueryObject
    on QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QFilterCondition> {}

extension AttendanceLogIsarQueryLinks
    on QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QFilterCondition> {}

extension AttendanceLogIsarQuerySortBy
    on QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QSortBy> {
  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByModule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'module', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByModuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'module', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByScannedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scannedBy', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByScannedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scannedBy', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByStudentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentName', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByStudentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentName', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByStudentUniqueId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentUniqueId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByStudentUniqueIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentUniqueId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension AttendanceLogIsarQuerySortThenBy
    on QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QSortThenBy> {
  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'className', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByModule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'module', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByModuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'module', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByScannedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scannedBy', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByScannedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scannedBy', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByStudentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentName', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByStudentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentName', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByStudentUniqueId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentUniqueId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByStudentUniqueIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentUniqueId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension AttendanceLogIsarQueryWhereDistinct
    on QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QDistinct> {
  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QDistinct>
  distinctByClassName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'className', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QDistinct>
  distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QDistinct>
  distinctByModule({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'module', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QDistinct>
  distinctByScannedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scannedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QDistinct>
  distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QDistinct>
  distinctByStudentName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studentName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QDistinct>
  distinctByStudentUniqueId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'studentUniqueId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension AttendanceLogIsarQueryProperty
    on QueryBuilder<AttendanceLogIsar, AttendanceLogIsar, QQueryProperty> {
  QueryBuilder<AttendanceLogIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AttendanceLogIsar, String, QQueryOperations>
  classNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'className');
    });
  }

  QueryBuilder<AttendanceLogIsar, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<AttendanceLogIsar, String, QQueryOperations> moduleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'module');
    });
  }

  QueryBuilder<AttendanceLogIsar, String, QQueryOperations>
  scannedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scannedBy');
    });
  }

  QueryBuilder<AttendanceLogIsar, String, QQueryOperations> schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<AttendanceLogIsar, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<AttendanceLogIsar, String, QQueryOperations>
  studentNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studentName');
    });
  }

  QueryBuilder<AttendanceLogIsar, String, QQueryOperations>
  studentUniqueIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studentUniqueId');
    });
  }

  QueryBuilder<AttendanceLogIsar, DateTime, QQueryOperations>
  timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
