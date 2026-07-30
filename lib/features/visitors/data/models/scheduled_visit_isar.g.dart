// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_visit_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetScheduledVisitIsarCollection on Isar {
  IsarCollection<ScheduledVisitIsar> get scheduledVisitIsars =>
      this.collection();
}

const ScheduledVisitIsarSchema = CollectionSchema(
  name: r'ScheduledVisitIsar',
  id: -5737060595919476704,
  properties: {
    r'fullName': PropertySchema(
      id: 0,
      name: r'fullName',
      type: IsarType.string,
    ),
    r'host': PropertySchema(
      id: 1,
      name: r'host',
      type: IsarType.string,
    ),
    r'hostId': PropertySchema(
      id: 2,
      name: r'hostId',
      type: IsarType.string,
    ),
    r'isApproved': PropertySchema(
      id: 3,
      name: r'isApproved',
      type: IsarType.bool,
    ),
    r'isCheckedIn': PropertySchema(
      id: 4,
      name: r'isCheckedIn',
      type: IsarType.bool,
    ),
    r'isRejected': PropertySchema(
      id: 5,
      name: r'isRejected',
      type: IsarType.bool,
    ),
    r'phone': PropertySchema(
      id: 6,
      name: r'phone',
      type: IsarType.string,
    ),
    r'purpose': PropertySchema(
      id: 7,
      name: r'purpose',
      type: IsarType.string,
    ),
    r'scheduledTime': PropertySchema(
      id: 8,
      name: r'scheduledTime',
      type: IsarType.dateTime,
    ),
    r'scheduledVisitId': PropertySchema(
      id: 9,
      name: r'scheduledVisitId',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 10,
      name: r'schoolId',
      type: IsarType.string,
    )
  },
  estimateSize: _scheduledVisitIsarEstimateSize,
  serialize: _scheduledVisitIsarSerialize,
  deserialize: _scheduledVisitIsarDeserialize,
  deserializeProp: _scheduledVisitIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'scheduledVisitId': IndexSchema(
      id: -3342719759858217623,
      name: r'scheduledVisitId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'scheduledVisitId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _scheduledVisitIsarGetId,
  getLinks: _scheduledVisitIsarGetLinks,
  attach: _scheduledVisitIsarAttach,
  version: '3.1.0+1',
);

int _scheduledVisitIsarEstimateSize(
  ScheduledVisitIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fullName.length * 3;
  bytesCount += 3 + object.host.length * 3;
  bytesCount += 3 + object.hostId.length * 3;
  bytesCount += 3 + object.phone.length * 3;
  bytesCount += 3 + object.purpose.length * 3;
  bytesCount += 3 + object.scheduledVisitId.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  return bytesCount;
}

void _scheduledVisitIsarSerialize(
  ScheduledVisitIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.fullName);
  writer.writeString(offsets[1], object.host);
  writer.writeString(offsets[2], object.hostId);
  writer.writeBool(offsets[3], object.isApproved);
  writer.writeBool(offsets[4], object.isCheckedIn);
  writer.writeBool(offsets[5], object.isRejected);
  writer.writeString(offsets[6], object.phone);
  writer.writeString(offsets[7], object.purpose);
  writer.writeDateTime(offsets[8], object.scheduledTime);
  writer.writeString(offsets[9], object.scheduledVisitId);
  writer.writeString(offsets[10], object.schoolId);
}

ScheduledVisitIsar _scheduledVisitIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ScheduledVisitIsar();
  object.fullName = reader.readString(offsets[0]);
  object.host = reader.readString(offsets[1]);
  object.hostId = reader.readString(offsets[2]);
  object.id = id;
  object.isApproved = reader.readBool(offsets[3]);
  object.isCheckedIn = reader.readBool(offsets[4]);
  object.isRejected = reader.readBool(offsets[5]);
  object.phone = reader.readString(offsets[6]);
  object.purpose = reader.readString(offsets[7]);
  object.scheduledTime = reader.readDateTime(offsets[8]);
  object.scheduledVisitId = reader.readString(offsets[9]);
  object.schoolId = reader.readString(offsets[10]);
  return object;
}

P _scheduledVisitIsarDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _scheduledVisitIsarGetId(ScheduledVisitIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _scheduledVisitIsarGetLinks(
    ScheduledVisitIsar object) {
  return [];
}

void _scheduledVisitIsarAttach(
    IsarCollection<dynamic> col, Id id, ScheduledVisitIsar object) {
  object.id = id;
}

extension ScheduledVisitIsarByIndex on IsarCollection<ScheduledVisitIsar> {
  Future<ScheduledVisitIsar?> getByScheduledVisitId(String scheduledVisitId) {
    return getByIndex(r'scheduledVisitId', [scheduledVisitId]);
  }

  ScheduledVisitIsar? getByScheduledVisitIdSync(String scheduledVisitId) {
    return getByIndexSync(r'scheduledVisitId', [scheduledVisitId]);
  }

  Future<bool> deleteByScheduledVisitId(String scheduledVisitId) {
    return deleteByIndex(r'scheduledVisitId', [scheduledVisitId]);
  }

  bool deleteByScheduledVisitIdSync(String scheduledVisitId) {
    return deleteByIndexSync(r'scheduledVisitId', [scheduledVisitId]);
  }

  Future<List<ScheduledVisitIsar?>> getAllByScheduledVisitId(
      List<String> scheduledVisitIdValues) {
    final values = scheduledVisitIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'scheduledVisitId', values);
  }

  List<ScheduledVisitIsar?> getAllByScheduledVisitIdSync(
      List<String> scheduledVisitIdValues) {
    final values = scheduledVisitIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'scheduledVisitId', values);
  }

  Future<int> deleteAllByScheduledVisitId(List<String> scheduledVisitIdValues) {
    final values = scheduledVisitIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'scheduledVisitId', values);
  }

  int deleteAllByScheduledVisitIdSync(List<String> scheduledVisitIdValues) {
    final values = scheduledVisitIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'scheduledVisitId', values);
  }

  Future<Id> putByScheduledVisitId(ScheduledVisitIsar object) {
    return putByIndex(r'scheduledVisitId', object);
  }

  Id putByScheduledVisitIdSync(ScheduledVisitIsar object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'scheduledVisitId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByScheduledVisitId(List<ScheduledVisitIsar> objects) {
    return putAllByIndex(r'scheduledVisitId', objects);
  }

  List<Id> putAllByScheduledVisitIdSync(List<ScheduledVisitIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'scheduledVisitId', objects,
        saveLinks: saveLinks);
  }
}

extension ScheduledVisitIsarQueryWhereSort
    on QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QWhere> {
  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ScheduledVisitIsarQueryWhere
    on QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QWhereClause> {
  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterWhereClause>
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

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterWhereClause>
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

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterWhereClause>
      scheduledVisitIdEqualTo(String scheduledVisitId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'scheduledVisitId',
        value: [scheduledVisitId],
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterWhereClause>
      scheduledVisitIdNotEqualTo(String scheduledVisitId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledVisitId',
              lower: [],
              upper: [scheduledVisitId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledVisitId',
              lower: [scheduledVisitId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledVisitId',
              lower: [scheduledVisitId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scheduledVisitId',
              lower: [],
              upper: [scheduledVisitId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ScheduledVisitIsarQueryFilter
    on QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QFilterCondition> {
  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      fullNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      fullNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      fullNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      fullNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fullName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      fullNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      fullNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      fullNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      fullNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fullName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'host',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'host',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'host',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'host',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hostId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hostId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hostId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hostId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hostId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hostId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hostId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hostId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hostId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      hostIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hostId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      isApprovedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isApproved',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      isCheckedInEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCheckedIn',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      isRejectedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRejected',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      phoneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      phoneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      phoneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      phoneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      phoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      phoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      phoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      phoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      phoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      phoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      purposeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      purposeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      purposeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      purposeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purpose',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      purposeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      purposeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      purposeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      purposeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'purpose',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      purposeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purpose',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      purposeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'purpose',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      scheduledTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      scheduledTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      scheduledTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      scheduledTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      scheduledVisitIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledVisitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      scheduledVisitIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledVisitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      scheduledVisitIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledVisitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      scheduledVisitIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledVisitId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      scheduledVisitIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scheduledVisitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      scheduledVisitIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scheduledVisitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      scheduledVisitIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scheduledVisitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      scheduledVisitIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scheduledVisitId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      scheduledVisitIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledVisitId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      scheduledVisitIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scheduledVisitId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterFilterCondition>
      schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }
}

extension ScheduledVisitIsarQueryObject
    on QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QFilterCondition> {}

extension ScheduledVisitIsarQueryLinks
    on QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QFilterCondition> {}

extension ScheduledVisitIsarQuerySortBy
    on QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QSortBy> {
  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByHost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByHostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByHostId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostId', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByHostIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostId', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByIsApproved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isApproved', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByIsApprovedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isApproved', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByIsCheckedIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCheckedIn', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByIsCheckedInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCheckedIn', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByIsRejected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRejected', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByIsRejectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRejected', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByScheduledTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByScheduledVisitId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledVisitId', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortByScheduledVisitIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledVisitId', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }
}

extension ScheduledVisitIsarQuerySortThenBy
    on QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QSortThenBy> {
  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByHost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByHostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByHostId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostId', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByHostIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostId', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByIsApproved() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isApproved', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByIsApprovedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isApproved', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByIsCheckedIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCheckedIn', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByIsCheckedInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCheckedIn', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByIsRejected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRejected', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByIsRejectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRejected', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByScheduledTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledTime', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByScheduledVisitId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledVisitId', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenByScheduledVisitIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledVisitId', Sort.desc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }
}

extension ScheduledVisitIsarQueryWhereDistinct
    on QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QDistinct> {
  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QDistinct>
      distinctByFullName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QDistinct>
      distinctByHost({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'host', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QDistinct>
      distinctByHostId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hostId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QDistinct>
      distinctByIsApproved() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isApproved');
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QDistinct>
      distinctByIsCheckedIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCheckedIn');
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QDistinct>
      distinctByIsRejected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRejected');
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QDistinct>
      distinctByPhone({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QDistinct>
      distinctByPurpose({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purpose', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QDistinct>
      distinctByScheduledTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledTime');
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QDistinct>
      distinctByScheduledVisitId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledVisitId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }
}

extension ScheduledVisitIsarQueryProperty
    on QueryBuilder<ScheduledVisitIsar, ScheduledVisitIsar, QQueryProperty> {
  QueryBuilder<ScheduledVisitIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ScheduledVisitIsar, String, QQueryOperations>
      fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }

  QueryBuilder<ScheduledVisitIsar, String, QQueryOperations> hostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'host');
    });
  }

  QueryBuilder<ScheduledVisitIsar, String, QQueryOperations> hostIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hostId');
    });
  }

  QueryBuilder<ScheduledVisitIsar, bool, QQueryOperations>
      isApprovedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isApproved');
    });
  }

  QueryBuilder<ScheduledVisitIsar, bool, QQueryOperations>
      isCheckedInProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCheckedIn');
    });
  }

  QueryBuilder<ScheduledVisitIsar, bool, QQueryOperations>
      isRejectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRejected');
    });
  }

  QueryBuilder<ScheduledVisitIsar, String, QQueryOperations> phoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phone');
    });
  }

  QueryBuilder<ScheduledVisitIsar, String, QQueryOperations> purposeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purpose');
    });
  }

  QueryBuilder<ScheduledVisitIsar, DateTime, QQueryOperations>
      scheduledTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledTime');
    });
  }

  QueryBuilder<ScheduledVisitIsar, String, QQueryOperations>
      scheduledVisitIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledVisitId');
    });
  }

  QueryBuilder<ScheduledVisitIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }
}
