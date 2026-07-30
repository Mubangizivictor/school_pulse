// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_branding_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSchoolBrandingIsarCollection on Isar {
  IsarCollection<SchoolBrandingIsar> get schoolBrandingIsars =>
      this.collection();
}

const SchoolBrandingIsarSchema = CollectionSchema(
  name: r'SchoolBrandingIsar',
  id: -7449137803899684423,
  properties: {
    r'accentColor': PropertySchema(
      id: 0,
      name: r'accentColor',
      type: IsarType.string,
    ),
    r'badgeUrl': PropertySchema(
      id: 1,
      name: r'badgeUrl',
      type: IsarType.string,
    ),
    r'dashboardBannerUrl': PropertySchema(
      id: 2,
      name: r'dashboardBannerUrl',
      type: IsarType.string,
    ),
    r'loginBackgroundUrl': PropertySchema(
      id: 3,
      name: r'loginBackgroundUrl',
      type: IsarType.string,
    ),
    r'logoUrl': PropertySchema(
      id: 4,
      name: r'logoUrl',
      type: IsarType.string,
    ),
    r'primaryColor': PropertySchema(
      id: 5,
      name: r'primaryColor',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 6,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'schoolMotto': PropertySchema(
      id: 7,
      name: r'schoolMotto',
      type: IsarType.string,
    ),
    r'schoolName': PropertySchema(
      id: 8,
      name: r'schoolName',
      type: IsarType.string,
    ),
    r'secondaryColor': PropertySchema(
      id: 9,
      name: r'secondaryColor',
      type: IsarType.string,
    ),
    r'version': PropertySchema(
      id: 10,
      name: r'version',
      type: IsarType.long,
    ),
    r'welcomeMessage': PropertySchema(
      id: 11,
      name: r'welcomeMessage',
      type: IsarType.string,
    )
  },
  estimateSize: _schoolBrandingIsarEstimateSize,
  serialize: _schoolBrandingIsarSerialize,
  deserialize: _schoolBrandingIsarDeserialize,
  deserializeProp: _schoolBrandingIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'schoolId': IndexSchema(
      id: 6631843591736686975,
      name: r'schoolId',
      unique: true,
      replace: true,
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
  getId: _schoolBrandingIsarGetId,
  getLinks: _schoolBrandingIsarGetLinks,
  attach: _schoolBrandingIsarAttach,
  version: '3.1.0+1',
);

int _schoolBrandingIsarEstimateSize(
  SchoolBrandingIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.accentColor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.badgeUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dashboardBannerUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.loginBackgroundUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.logoUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.primaryColor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.schoolMotto.length * 3;
  bytesCount += 3 + object.schoolName.length * 3;
  {
    final value = object.secondaryColor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.welcomeMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _schoolBrandingIsarSerialize(
  SchoolBrandingIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accentColor);
  writer.writeString(offsets[1], object.badgeUrl);
  writer.writeString(offsets[2], object.dashboardBannerUrl);
  writer.writeString(offsets[3], object.loginBackgroundUrl);
  writer.writeString(offsets[4], object.logoUrl);
  writer.writeString(offsets[5], object.primaryColor);
  writer.writeString(offsets[6], object.schoolId);
  writer.writeString(offsets[7], object.schoolMotto);
  writer.writeString(offsets[8], object.schoolName);
  writer.writeString(offsets[9], object.secondaryColor);
  writer.writeLong(offsets[10], object.version);
  writer.writeString(offsets[11], object.welcomeMessage);
}

SchoolBrandingIsar _schoolBrandingIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SchoolBrandingIsar();
  object.accentColor = reader.readStringOrNull(offsets[0]);
  object.badgeUrl = reader.readStringOrNull(offsets[1]);
  object.dashboardBannerUrl = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.loginBackgroundUrl = reader.readStringOrNull(offsets[3]);
  object.logoUrl = reader.readStringOrNull(offsets[4]);
  object.primaryColor = reader.readStringOrNull(offsets[5]);
  object.schoolId = reader.readString(offsets[6]);
  object.schoolMotto = reader.readString(offsets[7]);
  object.schoolName = reader.readString(offsets[8]);
  object.secondaryColor = reader.readStringOrNull(offsets[9]);
  object.version = reader.readLong(offsets[10]);
  object.welcomeMessage = reader.readStringOrNull(offsets[11]);
  return object;
}

P _schoolBrandingIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _schoolBrandingIsarGetId(SchoolBrandingIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _schoolBrandingIsarGetLinks(
    SchoolBrandingIsar object) {
  return [];
}

void _schoolBrandingIsarAttach(
    IsarCollection<dynamic> col, Id id, SchoolBrandingIsar object) {
  object.id = id;
}

extension SchoolBrandingIsarByIndex on IsarCollection<SchoolBrandingIsar> {
  Future<SchoolBrandingIsar?> getBySchoolId(String schoolId) {
    return getByIndex(r'schoolId', [schoolId]);
  }

  SchoolBrandingIsar? getBySchoolIdSync(String schoolId) {
    return getByIndexSync(r'schoolId', [schoolId]);
  }

  Future<bool> deleteBySchoolId(String schoolId) {
    return deleteByIndex(r'schoolId', [schoolId]);
  }

  bool deleteBySchoolIdSync(String schoolId) {
    return deleteByIndexSync(r'schoolId', [schoolId]);
  }

  Future<List<SchoolBrandingIsar?>> getAllBySchoolId(
      List<String> schoolIdValues) {
    final values = schoolIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'schoolId', values);
  }

  List<SchoolBrandingIsar?> getAllBySchoolIdSync(List<String> schoolIdValues) {
    final values = schoolIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'schoolId', values);
  }

  Future<int> deleteAllBySchoolId(List<String> schoolIdValues) {
    final values = schoolIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'schoolId', values);
  }

  int deleteAllBySchoolIdSync(List<String> schoolIdValues) {
    final values = schoolIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'schoolId', values);
  }

  Future<Id> putBySchoolId(SchoolBrandingIsar object) {
    return putByIndex(r'schoolId', object);
  }

  Id putBySchoolIdSync(SchoolBrandingIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'schoolId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySchoolId(List<SchoolBrandingIsar> objects) {
    return putAllByIndex(r'schoolId', objects);
  }

  List<Id> putAllBySchoolIdSync(List<SchoolBrandingIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'schoolId', objects, saveLinks: saveLinks);
  }
}

extension SchoolBrandingIsarQueryWhereSort
    on QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QWhere> {
  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SchoolBrandingIsarQueryWhere
    on QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QWhereClause> {
  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterWhereClause>
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

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterWhereClause>
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

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterWhereClause>
      schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterWhereClause>
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
}

extension SchoolBrandingIsarQueryFilter
    on QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QFilterCondition> {
  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      accentColorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'accentColor',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      accentColorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'accentColor',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      accentColorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accentColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      accentColorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accentColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      accentColorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accentColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      accentColorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accentColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      accentColorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accentColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      accentColorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accentColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      accentColorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accentColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      accentColorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accentColor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      accentColorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accentColor',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      accentColorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accentColor',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      badgeUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'badgeUrl',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      badgeUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'badgeUrl',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      badgeUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'badgeUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      badgeUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'badgeUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      badgeUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'badgeUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      badgeUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'badgeUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      badgeUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'badgeUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      badgeUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'badgeUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      badgeUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'badgeUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      badgeUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'badgeUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      badgeUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'badgeUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      badgeUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'badgeUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      dashboardBannerUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dashboardBannerUrl',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      dashboardBannerUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dashboardBannerUrl',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      dashboardBannerUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dashboardBannerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      dashboardBannerUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dashboardBannerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      dashboardBannerUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dashboardBannerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      dashboardBannerUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dashboardBannerUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      dashboardBannerUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dashboardBannerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      dashboardBannerUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dashboardBannerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      dashboardBannerUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dashboardBannerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      dashboardBannerUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dashboardBannerUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      dashboardBannerUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dashboardBannerUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      dashboardBannerUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dashboardBannerUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
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

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
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

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
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

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      loginBackgroundUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'loginBackgroundUrl',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      loginBackgroundUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'loginBackgroundUrl',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      loginBackgroundUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loginBackgroundUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      loginBackgroundUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loginBackgroundUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      loginBackgroundUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loginBackgroundUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      loginBackgroundUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loginBackgroundUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      loginBackgroundUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'loginBackgroundUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      loginBackgroundUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'loginBackgroundUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      loginBackgroundUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'loginBackgroundUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      loginBackgroundUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'loginBackgroundUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      loginBackgroundUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loginBackgroundUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      loginBackgroundUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'loginBackgroundUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      logoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'logoUrl',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      logoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'logoUrl',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      logoUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      logoUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'logoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      logoUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'logoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      logoUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'logoUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      logoUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'logoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      logoUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'logoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      logoUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'logoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      logoUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'logoUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      logoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      logoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'logoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      primaryColorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'primaryColor',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      primaryColorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'primaryColor',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      primaryColorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      primaryColorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'primaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      primaryColorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'primaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      primaryColorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'primaryColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      primaryColorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'primaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      primaryColorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'primaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      primaryColorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'primaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      primaryColorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'primaryColor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      primaryColorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryColor',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      primaryColorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'primaryColor',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
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

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
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

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
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

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
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

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
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

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
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

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolMottoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolMotto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolMottoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schoolMotto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolMottoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schoolMotto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolMottoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schoolMotto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolMottoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schoolMotto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolMottoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schoolMotto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolMottoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolMotto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolMottoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolMotto',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolMottoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolMotto',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolMottoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolMotto',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schoolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schoolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schoolName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schoolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schoolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolName',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      schoolNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolName',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      secondaryColorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'secondaryColor',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      secondaryColorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'secondaryColor',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      secondaryColorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'secondaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      secondaryColorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'secondaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      secondaryColorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'secondaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      secondaryColorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'secondaryColor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      secondaryColorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'secondaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      secondaryColorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'secondaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      secondaryColorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'secondaryColor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      secondaryColorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'secondaryColor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      secondaryColorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'secondaryColor',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      secondaryColorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'secondaryColor',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      versionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      versionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      versionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      versionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      welcomeMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'welcomeMessage',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      welcomeMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'welcomeMessage',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      welcomeMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'welcomeMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      welcomeMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'welcomeMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      welcomeMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'welcomeMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      welcomeMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'welcomeMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      welcomeMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'welcomeMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      welcomeMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'welcomeMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      welcomeMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'welcomeMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      welcomeMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'welcomeMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      welcomeMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'welcomeMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterFilterCondition>
      welcomeMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'welcomeMessage',
        value: '',
      ));
    });
  }
}

extension SchoolBrandingIsarQueryObject
    on QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QFilterCondition> {}

extension SchoolBrandingIsarQueryLinks
    on QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QFilterCondition> {}

extension SchoolBrandingIsarQuerySortBy
    on QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QSortBy> {
  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByBadgeUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeUrl', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByBadgeUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeUrl', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByDashboardBannerUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dashboardBannerUrl', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByDashboardBannerUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dashboardBannerUrl', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByLoginBackgroundUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginBackgroundUrl', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByLoginBackgroundUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginBackgroundUrl', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByLogoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoUrl', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByLogoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoUrl', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByPrimaryColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryColor', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByPrimaryColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryColor', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortBySchoolMotto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolMotto', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortBySchoolMottoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolMotto', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortBySchoolName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolName', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortBySchoolNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolName', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortBySecondaryColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryColor', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortBySecondaryColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryColor', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByWelcomeMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'welcomeMessage', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      sortByWelcomeMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'welcomeMessage', Sort.desc);
    });
  }
}

extension SchoolBrandingIsarQuerySortThenBy
    on QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QSortThenBy> {
  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByAccentColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByAccentColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColor', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByBadgeUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeUrl', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByBadgeUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeUrl', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByDashboardBannerUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dashboardBannerUrl', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByDashboardBannerUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dashboardBannerUrl', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByLoginBackgroundUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginBackgroundUrl', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByLoginBackgroundUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loginBackgroundUrl', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByLogoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoUrl', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByLogoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoUrl', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByPrimaryColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryColor', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByPrimaryColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryColor', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenBySchoolMotto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolMotto', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenBySchoolMottoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolMotto', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenBySchoolName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolName', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenBySchoolNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolName', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenBySecondaryColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryColor', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenBySecondaryColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'secondaryColor', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByWelcomeMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'welcomeMessage', Sort.asc);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QAfterSortBy>
      thenByWelcomeMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'welcomeMessage', Sort.desc);
    });
  }
}

extension SchoolBrandingIsarQueryWhereDistinct
    on QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QDistinct> {
  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QDistinct>
      distinctByAccentColor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accentColor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QDistinct>
      distinctByBadgeUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'badgeUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QDistinct>
      distinctByDashboardBannerUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dashboardBannerUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QDistinct>
      distinctByLoginBackgroundUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loginBackgroundUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QDistinct>
      distinctByLogoUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logoUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QDistinct>
      distinctByPrimaryColor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'primaryColor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QDistinct>
      distinctBySchoolMotto({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolMotto', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QDistinct>
      distinctBySchoolName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QDistinct>
      distinctBySecondaryColor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'secondaryColor',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QDistinct>
      distinctByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version');
    });
  }

  QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QDistinct>
      distinctByWelcomeMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'welcomeMessage',
          caseSensitive: caseSensitive);
    });
  }
}

extension SchoolBrandingIsarQueryProperty
    on QueryBuilder<SchoolBrandingIsar, SchoolBrandingIsar, QQueryProperty> {
  QueryBuilder<SchoolBrandingIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SchoolBrandingIsar, String?, QQueryOperations>
      accentColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accentColor');
    });
  }

  QueryBuilder<SchoolBrandingIsar, String?, QQueryOperations>
      badgeUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'badgeUrl');
    });
  }

  QueryBuilder<SchoolBrandingIsar, String?, QQueryOperations>
      dashboardBannerUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dashboardBannerUrl');
    });
  }

  QueryBuilder<SchoolBrandingIsar, String?, QQueryOperations>
      loginBackgroundUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loginBackgroundUrl');
    });
  }

  QueryBuilder<SchoolBrandingIsar, String?, QQueryOperations>
      logoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logoUrl');
    });
  }

  QueryBuilder<SchoolBrandingIsar, String?, QQueryOperations>
      primaryColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'primaryColor');
    });
  }

  QueryBuilder<SchoolBrandingIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<SchoolBrandingIsar, String, QQueryOperations>
      schoolMottoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolMotto');
    });
  }

  QueryBuilder<SchoolBrandingIsar, String, QQueryOperations>
      schoolNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolName');
    });
  }

  QueryBuilder<SchoolBrandingIsar, String?, QQueryOperations>
      secondaryColorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'secondaryColor');
    });
  }

  QueryBuilder<SchoolBrandingIsar, int, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }

  QueryBuilder<SchoolBrandingIsar, String?, QQueryOperations>
      welcomeMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'welcomeMessage');
    });
  }
}
