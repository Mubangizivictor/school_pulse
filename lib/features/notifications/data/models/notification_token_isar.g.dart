// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_token_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNotificationTokenIsarCollection on Isar {
  IsarCollection<NotificationTokenIsar> get notificationTokenIsars =>
      this.collection();
}

const NotificationTokenIsarSchema = CollectionSchema(
  name: r'NotificationTokenIsar',
  id: 813754230056205198,
  properties: {
    r'lastSeenAt': PropertySchema(
      id: 0,
      name: r'lastSeenAt',
      type: IsarType.dateTime,
    ),
    r'needsPublishing': PropertySchema(
      id: 1,
      name: r'needsPublishing',
      type: IsarType.bool,
    ),
    r'pendingRevocation': PropertySchema(
      id: 2,
      name: r'pendingRevocation',
      type: IsarType.bool,
    ),
    r'platform': PropertySchema(
      id: 3,
      name: r'platform',
      type: IsarType.string,
    ),
    r'publishedAt': PropertySchema(
      id: 4,
      name: r'publishedAt',
      type: IsarType.dateTime,
    ),
    r'schoolId': PropertySchema(
      id: 5,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'subscribedTopics': PropertySchema(
      id: 6,
      name: r'subscribedTopics',
      type: IsarType.stringList,
    ),
    r'token': PropertySchema(
      id: 7,
      name: r'token',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 8,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _notificationTokenIsarEstimateSize,
  serialize: _notificationTokenIsarSerialize,
  deserialize: _notificationTokenIsarDeserialize,
  deserializeProp: _notificationTokenIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'token_userId': IndexSchema(
      id: -3111860103964789526,
      name: r'token_userId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'token',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _notificationTokenIsarGetId,
  getLinks: _notificationTokenIsarGetLinks,
  attach: _notificationTokenIsarAttach,
  version: '3.1.0+1',
);

int _notificationTokenIsarEstimateSize(
  NotificationTokenIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.platform.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.subscribedTopics.length * 3;
  {
    for (var i = 0; i < object.subscribedTopics.length; i++) {
      final value = object.subscribedTopics[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.token.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _notificationTokenIsarSerialize(
  NotificationTokenIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastSeenAt);
  writer.writeBool(offsets[1], object.needsPublishing);
  writer.writeBool(offsets[2], object.pendingRevocation);
  writer.writeString(offsets[3], object.platform);
  writer.writeDateTime(offsets[4], object.publishedAt);
  writer.writeString(offsets[5], object.schoolId);
  writer.writeStringList(offsets[6], object.subscribedTopics);
  writer.writeString(offsets[7], object.token);
  writer.writeString(offsets[8], object.userId);
}

NotificationTokenIsar _notificationTokenIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NotificationTokenIsar();
  object.id = id;
  object.lastSeenAt = reader.readDateTimeOrNull(offsets[0]);
  object.pendingRevocation = reader.readBool(offsets[2]);
  object.platform = reader.readString(offsets[3]);
  object.publishedAt = reader.readDateTimeOrNull(offsets[4]);
  object.schoolId = reader.readString(offsets[5]);
  object.subscribedTopics = reader.readStringList(offsets[6]) ?? [];
  object.token = reader.readString(offsets[7]);
  object.userId = reader.readString(offsets[8]);
  return object;
}

P _notificationTokenIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _notificationTokenIsarGetId(NotificationTokenIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _notificationTokenIsarGetLinks(
    NotificationTokenIsar object) {
  return [];
}

void _notificationTokenIsarAttach(
    IsarCollection<dynamic> col, Id id, NotificationTokenIsar object) {
  object.id = id;
}

extension NotificationTokenIsarByIndex
    on IsarCollection<NotificationTokenIsar> {
  Future<NotificationTokenIsar?> getByTokenUserId(String token, String userId) {
    return getByIndex(r'token_userId', [token, userId]);
  }

  NotificationTokenIsar? getByTokenUserIdSync(String token, String userId) {
    return getByIndexSync(r'token_userId', [token, userId]);
  }

  Future<bool> deleteByTokenUserId(String token, String userId) {
    return deleteByIndex(r'token_userId', [token, userId]);
  }

  bool deleteByTokenUserIdSync(String token, String userId) {
    return deleteByIndexSync(r'token_userId', [token, userId]);
  }

  Future<List<NotificationTokenIsar?>> getAllByTokenUserId(
      List<String> tokenValues, List<String> userIdValues) {
    final len = tokenValues.length;
    assert(userIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([tokenValues[i], userIdValues[i]]);
    }

    return getAllByIndex(r'token_userId', values);
  }

  List<NotificationTokenIsar?> getAllByTokenUserIdSync(
      List<String> tokenValues, List<String> userIdValues) {
    final len = tokenValues.length;
    assert(userIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([tokenValues[i], userIdValues[i]]);
    }

    return getAllByIndexSync(r'token_userId', values);
  }

  Future<int> deleteAllByTokenUserId(
      List<String> tokenValues, List<String> userIdValues) {
    final len = tokenValues.length;
    assert(userIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([tokenValues[i], userIdValues[i]]);
    }

    return deleteAllByIndex(r'token_userId', values);
  }

  int deleteAllByTokenUserIdSync(
      List<String> tokenValues, List<String> userIdValues) {
    final len = tokenValues.length;
    assert(userIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([tokenValues[i], userIdValues[i]]);
    }

    return deleteAllByIndexSync(r'token_userId', values);
  }

  Future<Id> putByTokenUserId(NotificationTokenIsar object) {
    return putByIndex(r'token_userId', object);
  }

  Id putByTokenUserIdSync(NotificationTokenIsar object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'token_userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTokenUserId(List<NotificationTokenIsar> objects) {
    return putAllByIndex(r'token_userId', objects);
  }

  List<Id> putAllByTokenUserIdSync(List<NotificationTokenIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'token_userId', objects, saveLinks: saveLinks);
  }
}

extension NotificationTokenIsarQueryWhereSort
    on QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QWhere> {
  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NotificationTokenIsarQueryWhere on QueryBuilder<NotificationTokenIsar,
    NotificationTokenIsar, QWhereClause> {
  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterWhereClause>
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterWhereClause>
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterWhereClause>
      tokenEqualToAnyUserId(String token) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'token_userId',
        value: [token],
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterWhereClause>
      tokenNotEqualToAnyUserId(String token) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'token_userId',
              lower: [],
              upper: [token],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'token_userId',
              lower: [token],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'token_userId',
              lower: [token],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'token_userId',
              lower: [],
              upper: [token],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterWhereClause>
      tokenUserIdEqualTo(String token, String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'token_userId',
        value: [token, userId],
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterWhereClause>
      tokenEqualToUserIdNotEqualTo(String token, String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'token_userId',
              lower: [token],
              upper: [token, userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'token_userId',
              lower: [token, userId],
              includeLower: false,
              upper: [token],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'token_userId',
              lower: [token, userId],
              includeLower: false,
              upper: [token],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'token_userId',
              lower: [token],
              upper: [token, userId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension NotificationTokenIsarQueryFilter on QueryBuilder<
    NotificationTokenIsar, NotificationTokenIsar, QFilterCondition> {
  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> lastSeenAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSeenAt',
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> lastSeenAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSeenAt',
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> lastSeenAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> lastSeenAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> lastSeenAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSeenAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> lastSeenAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSeenAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> needsPublishingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needsPublishing',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> pendingRevocationEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendingRevocation',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> platformEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'platform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> platformGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'platform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> platformLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'platform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> platformBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'platform',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> platformStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'platform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> platformEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'platform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
          QAfterFilterCondition>
      platformContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'platform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
          QAfterFilterCondition>
      platformMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'platform',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> platformIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'platform',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> platformIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'platform',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> publishedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'publishedAt',
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> publishedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'publishedAt',
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> publishedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'publishedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> publishedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'publishedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> publishedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'publishedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> publishedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'publishedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> subscribedTopicsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subscribedTopics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> subscribedTopicsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subscribedTopics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> subscribedTopicsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subscribedTopics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> subscribedTopicsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subscribedTopics',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> subscribedTopicsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subscribedTopics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> subscribedTopicsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subscribedTopics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
          QAfterFilterCondition>
      subscribedTopicsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subscribedTopics',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
          QAfterFilterCondition>
      subscribedTopicsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subscribedTopics',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> subscribedTopicsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subscribedTopics',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> subscribedTopicsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subscribedTopics',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> subscribedTopicsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subscribedTopics',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> subscribedTopicsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subscribedTopics',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> subscribedTopicsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subscribedTopics',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> subscribedTopicsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subscribedTopics',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> subscribedTopicsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subscribedTopics',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> subscribedTopicsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'subscribedTopics',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> tokenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> tokenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> tokenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> tokenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'token',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> tokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> tokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
          QAfterFilterCondition>
      tokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'token',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
          QAfterFilterCondition>
      tokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'token',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> tokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'token',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> tokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'token',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
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

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar,
      QAfterFilterCondition> userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension NotificationTokenIsarQueryObject on QueryBuilder<
    NotificationTokenIsar, NotificationTokenIsar, QFilterCondition> {}

extension NotificationTokenIsarQueryLinks on QueryBuilder<NotificationTokenIsar,
    NotificationTokenIsar, QFilterCondition> {}

extension NotificationTokenIsarQuerySortBy
    on QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QSortBy> {
  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortByLastSeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortByNeedsPublishing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsPublishing', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortByNeedsPublishingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsPublishing', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortByPendingRevocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingRevocation', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortByPendingRevocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingRevocation', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortByPlatform() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortByPlatformDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortByPublishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortByPublishedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension NotificationTokenIsarQuerySortThenBy
    on QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QSortThenBy> {
  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByLastSeenAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSeenAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByNeedsPublishing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsPublishing', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByNeedsPublishingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsPublishing', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByPendingRevocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingRevocation', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByPendingRevocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingRevocation', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByPlatform() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByPlatformDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'platform', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByPublishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByPublishedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publishedAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'token', Sort.desc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QAfterSortBy>
      thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension NotificationTokenIsarQueryWhereDistinct
    on QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QDistinct> {
  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QDistinct>
      distinctByLastSeenAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSeenAt');
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QDistinct>
      distinctByNeedsPublishing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needsPublishing');
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QDistinct>
      distinctByPendingRevocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingRevocation');
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QDistinct>
      distinctByPlatform({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'platform', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QDistinct>
      distinctByPublishedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publishedAt');
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QDistinct>
      distinctBySubscribedTopics() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subscribedTopics');
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QDistinct>
      distinctByToken({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'token', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationTokenIsar, NotificationTokenIsar, QDistinct>
      distinctByUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension NotificationTokenIsarQueryProperty on QueryBuilder<
    NotificationTokenIsar, NotificationTokenIsar, QQueryProperty> {
  QueryBuilder<NotificationTokenIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NotificationTokenIsar, DateTime?, QQueryOperations>
      lastSeenAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSeenAt');
    });
  }

  QueryBuilder<NotificationTokenIsar, bool, QQueryOperations>
      needsPublishingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needsPublishing');
    });
  }

  QueryBuilder<NotificationTokenIsar, bool, QQueryOperations>
      pendingRevocationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingRevocation');
    });
  }

  QueryBuilder<NotificationTokenIsar, String, QQueryOperations>
      platformProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'platform');
    });
  }

  QueryBuilder<NotificationTokenIsar, DateTime?, QQueryOperations>
      publishedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publishedAt');
    });
  }

  QueryBuilder<NotificationTokenIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<NotificationTokenIsar, List<String>, QQueryOperations>
      subscribedTopicsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subscribedTopics');
    });
  }

  QueryBuilder<NotificationTokenIsar, String, QQueryOperations>
      tokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'token');
    });
  }

  QueryBuilder<NotificationTokenIsar, String, QQueryOperations>
      userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
