// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_message_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPendingMessageIsarCollection on Isar {
  IsarCollection<PendingMessageIsar> get pendingMessageIsars =>
      this.collection();
}

const PendingMessageIsarSchema = CollectionSchema(
  name: r'PendingMessageIsar',
  id: 63032984793338065,
  properties: {
    r'attemptCount': PropertySchema(
      id: 0,
      name: r'attemptCount',
      type: IsarType.long,
    ),
    r'audioDurationMs': PropertySchema(
      id: 1,
      name: r'audioDurationMs',
      type: IsarType.long,
    ),
    r'clientMessageId': PropertySchema(
      id: 2,
      name: r'clientMessageId',
      type: IsarType.string,
    ),
    r'content': PropertySchema(
      id: 3,
      name: r'content',
      type: IsarType.string,
    ),
    r'conversationId': PropertySchema(
      id: 4,
      name: r'conversationId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'eventLocation': PropertySchema(
      id: 6,
      name: r'eventLocation',
      type: IsarType.string,
    ),
    r'eventStart': PropertySchema(
      id: 7,
      name: r'eventStart',
      type: IsarType.dateTime,
    ),
    r'fileName': PropertySchema(
      id: 8,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'fileSize': PropertySchema(
      id: 9,
      name: r'fileSize',
      type: IsarType.string,
    ),
    r'lastAttemptAt': PropertySchema(
      id: 10,
      name: r'lastAttemptAt',
      type: IsarType.dateTime,
    ),
    r'lastError': PropertySchema(
      id: 11,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'latitude': PropertySchema(
      id: 12,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'localFilePath': PropertySchema(
      id: 13,
      name: r'localFilePath',
      type: IsarType.string,
    ),
    r'longitude': PropertySchema(
      id: 14,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'mediaUrl': PropertySchema(
      id: 15,
      name: r'mediaUrl',
      type: IsarType.string,
    ),
    r'pollOptions': PropertySchema(
      id: 16,
      name: r'pollOptions',
      type: IsarType.stringList,
    ),
    r'replyToContent': PropertySchema(
      id: 17,
      name: r'replyToContent',
      type: IsarType.string,
    ),
    r'replyToId': PropertySchema(
      id: 18,
      name: r'replyToId',
      type: IsarType.string,
    ),
    r'replyToSender': PropertySchema(
      id: 19,
      name: r'replyToSender',
      type: IsarType.string,
    ),
    r'senderAvatar': PropertySchema(
      id: 20,
      name: r'senderAvatar',
      type: IsarType.string,
    ),
    r'senderEmail': PropertySchema(
      id: 21,
      name: r'senderEmail',
      type: IsarType.string,
    ),
    r'senderId': PropertySchema(
      id: 22,
      name: r'senderId',
      type: IsarType.string,
    ),
    r'senderName': PropertySchema(
      id: 23,
      name: r'senderName',
      type: IsarType.string,
    ),
    r'senderRoleNames': PropertySchema(
      id: 24,
      name: r'senderRoleNames',
      type: IsarType.stringList,
    ),
    r'senderSchoolId': PropertySchema(
      id: 25,
      name: r'senderSchoolId',
      type: IsarType.string,
    ),
    r'sharedContactId': PropertySchema(
      id: 26,
      name: r'sharedContactId',
      type: IsarType.string,
    ),
    r'sharedContactRole': PropertySchema(
      id: 27,
      name: r'sharedContactRole',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 28,
      name: r'status',
      type: IsarType.byte,
      enumMap: _PendingMessageIsarstatusEnumValueMap,
    ),
    r'type': PropertySchema(
      id: 29,
      name: r'type',
      type: IsarType.byte,
      enumMap: _PendingMessageIsartypeEnumValueMap,
    )
  },
  estimateSize: _pendingMessageIsarEstimateSize,
  serialize: _pendingMessageIsarSerialize,
  deserialize: _pendingMessageIsarDeserialize,
  deserializeProp: _pendingMessageIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'clientMessageId': IndexSchema(
      id: -5446652790308646705,
      name: r'clientMessageId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'clientMessageId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'conversationId_createdAt': IndexSchema(
      id: -6415830084913696883,
      name: r'conversationId_createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'conversationId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
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
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pendingMessageIsarGetId,
  getLinks: _pendingMessageIsarGetLinks,
  attach: _pendingMessageIsarAttach,
  version: '3.1.0+1',
);

int _pendingMessageIsarEstimateSize(
  PendingMessageIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.clientMessageId.length * 3;
  bytesCount += 3 + object.content.length * 3;
  bytesCount += 3 + object.conversationId.length * 3;
  {
    final value = object.eventLocation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fileName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fileSize;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.localFilePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.mediaUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.pollOptions;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.replyToContent;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.replyToId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.replyToSender;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.senderAvatar;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.senderEmail.length * 3;
  bytesCount += 3 + object.senderId.length * 3;
  bytesCount += 3 + object.senderName.length * 3;
  bytesCount += 3 + object.senderRoleNames.length * 3;
  {
    for (var i = 0; i < object.senderRoleNames.length; i++) {
      final value = object.senderRoleNames[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.senderSchoolId.length * 3;
  {
    final value = object.sharedContactId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sharedContactRole;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _pendingMessageIsarSerialize(
  PendingMessageIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.attemptCount);
  writer.writeLong(offsets[1], object.audioDurationMs);
  writer.writeString(offsets[2], object.clientMessageId);
  writer.writeString(offsets[3], object.content);
  writer.writeString(offsets[4], object.conversationId);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeString(offsets[6], object.eventLocation);
  writer.writeDateTime(offsets[7], object.eventStart);
  writer.writeString(offsets[8], object.fileName);
  writer.writeString(offsets[9], object.fileSize);
  writer.writeDateTime(offsets[10], object.lastAttemptAt);
  writer.writeString(offsets[11], object.lastError);
  writer.writeDouble(offsets[12], object.latitude);
  writer.writeString(offsets[13], object.localFilePath);
  writer.writeDouble(offsets[14], object.longitude);
  writer.writeString(offsets[15], object.mediaUrl);
  writer.writeStringList(offsets[16], object.pollOptions);
  writer.writeString(offsets[17], object.replyToContent);
  writer.writeString(offsets[18], object.replyToId);
  writer.writeString(offsets[19], object.replyToSender);
  writer.writeString(offsets[20], object.senderAvatar);
  writer.writeString(offsets[21], object.senderEmail);
  writer.writeString(offsets[22], object.senderId);
  writer.writeString(offsets[23], object.senderName);
  writer.writeStringList(offsets[24], object.senderRoleNames);
  writer.writeString(offsets[25], object.senderSchoolId);
  writer.writeString(offsets[26], object.sharedContactId);
  writer.writeString(offsets[27], object.sharedContactRole);
  writer.writeByte(offsets[28], object.status.index);
  writer.writeByte(offsets[29], object.type.index);
}

PendingMessageIsar _pendingMessageIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PendingMessageIsar();
  object.attemptCount = reader.readLong(offsets[0]);
  object.audioDurationMs = reader.readLongOrNull(offsets[1]);
  object.clientMessageId = reader.readString(offsets[2]);
  object.content = reader.readString(offsets[3]);
  object.conversationId = reader.readString(offsets[4]);
  object.createdAt = reader.readDateTime(offsets[5]);
  object.eventLocation = reader.readStringOrNull(offsets[6]);
  object.eventStart = reader.readDateTimeOrNull(offsets[7]);
  object.fileName = reader.readStringOrNull(offsets[8]);
  object.fileSize = reader.readStringOrNull(offsets[9]);
  object.id = id;
  object.lastAttemptAt = reader.readDateTimeOrNull(offsets[10]);
  object.lastError = reader.readStringOrNull(offsets[11]);
  object.latitude = reader.readDoubleOrNull(offsets[12]);
  object.localFilePath = reader.readStringOrNull(offsets[13]);
  object.longitude = reader.readDoubleOrNull(offsets[14]);
  object.mediaUrl = reader.readStringOrNull(offsets[15]);
  object.pollOptions = reader.readStringList(offsets[16]);
  object.replyToContent = reader.readStringOrNull(offsets[17]);
  object.replyToId = reader.readStringOrNull(offsets[18]);
  object.replyToSender = reader.readStringOrNull(offsets[19]);
  object.senderAvatar = reader.readStringOrNull(offsets[20]);
  object.senderEmail = reader.readString(offsets[21]);
  object.senderId = reader.readString(offsets[22]);
  object.senderName = reader.readString(offsets[23]);
  object.senderRoleNames = reader.readStringList(offsets[24]) ?? [];
  object.senderSchoolId = reader.readString(offsets[25]);
  object.sharedContactId = reader.readStringOrNull(offsets[26]);
  object.sharedContactRole = reader.readStringOrNull(offsets[27]);
  object.status = _PendingMessageIsarstatusValueEnumMap[
          reader.readByteOrNull(offsets[28])] ??
      PendingMessageStatus.queued;
  object.type =
      _PendingMessageIsartypeValueEnumMap[reader.readByteOrNull(offsets[29])] ??
          MessageType.text;
  return object;
}

P _pendingMessageIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readDoubleOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringList(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readString(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    case 24:
      return (reader.readStringList(offset) ?? []) as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (_PendingMessageIsarstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          PendingMessageStatus.queued) as P;
    case 29:
      return (_PendingMessageIsartypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          MessageType.text) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PendingMessageIsarstatusEnumValueMap = {
  'queued': 0,
  'sending': 1,
  'sent': 2,
  'failed': 3,
};
const _PendingMessageIsarstatusValueEnumMap = {
  0: PendingMessageStatus.queued,
  1: PendingMessageStatus.sending,
  2: PendingMessageStatus.sent,
  3: PendingMessageStatus.failed,
};
const _PendingMessageIsartypeEnumValueMap = {
  'text': 0,
  'image': 1,
  'video': 2,
  'file': 3,
  'audio': 4,
  'location': 5,
  'contact': 6,
  'poll': 7,
  'event': 8,
};
const _PendingMessageIsartypeValueEnumMap = {
  0: MessageType.text,
  1: MessageType.image,
  2: MessageType.video,
  3: MessageType.file,
  4: MessageType.audio,
  5: MessageType.location,
  6: MessageType.contact,
  7: MessageType.poll,
  8: MessageType.event,
};

Id _pendingMessageIsarGetId(PendingMessageIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pendingMessageIsarGetLinks(
    PendingMessageIsar object) {
  return [];
}

void _pendingMessageIsarAttach(
    IsarCollection<dynamic> col, Id id, PendingMessageIsar object) {
  object.id = id;
}

extension PendingMessageIsarByIndex on IsarCollection<PendingMessageIsar> {
  Future<PendingMessageIsar?> getByClientMessageId(String clientMessageId) {
    return getByIndex(r'clientMessageId', [clientMessageId]);
  }

  PendingMessageIsar? getByClientMessageIdSync(String clientMessageId) {
    return getByIndexSync(r'clientMessageId', [clientMessageId]);
  }

  Future<bool> deleteByClientMessageId(String clientMessageId) {
    return deleteByIndex(r'clientMessageId', [clientMessageId]);
  }

  bool deleteByClientMessageIdSync(String clientMessageId) {
    return deleteByIndexSync(r'clientMessageId', [clientMessageId]);
  }

  Future<List<PendingMessageIsar?>> getAllByClientMessageId(
      List<String> clientMessageIdValues) {
    final values = clientMessageIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'clientMessageId', values);
  }

  List<PendingMessageIsar?> getAllByClientMessageIdSync(
      List<String> clientMessageIdValues) {
    final values = clientMessageIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'clientMessageId', values);
  }

  Future<int> deleteAllByClientMessageId(List<String> clientMessageIdValues) {
    final values = clientMessageIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'clientMessageId', values);
  }

  int deleteAllByClientMessageIdSync(List<String> clientMessageIdValues) {
    final values = clientMessageIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'clientMessageId', values);
  }

  Future<Id> putByClientMessageId(PendingMessageIsar object) {
    return putByIndex(r'clientMessageId', object);
  }

  Id putByClientMessageIdSync(PendingMessageIsar object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'clientMessageId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByClientMessageId(List<PendingMessageIsar> objects) {
    return putAllByIndex(r'clientMessageId', objects);
  }

  List<Id> putAllByClientMessageIdSync(List<PendingMessageIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'clientMessageId', objects, saveLinks: saveLinks);
  }
}

extension PendingMessageIsarQueryWhereSort
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QWhere> {
  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhere>
      anyStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'status'),
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhere>
      anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension PendingMessageIsarQueryWhere
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QWhereClause> {
  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      clientMessageIdEqualTo(String clientMessageId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'clientMessageId',
        value: [clientMessageId],
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      clientMessageIdNotEqualTo(String clientMessageId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clientMessageId',
              lower: [],
              upper: [clientMessageId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clientMessageId',
              lower: [clientMessageId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clientMessageId',
              lower: [clientMessageId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'clientMessageId',
              lower: [],
              upper: [clientMessageId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      conversationIdEqualToAnyCreatedAt(String conversationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'conversationId_createdAt',
        value: [conversationId],
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      conversationIdNotEqualToAnyCreatedAt(String conversationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [],
              upper: [conversationId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [conversationId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [conversationId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [],
              upper: [conversationId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      conversationIdCreatedAtEqualTo(
          String conversationId, DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'conversationId_createdAt',
        value: [conversationId, createdAt],
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      conversationIdEqualToCreatedAtNotEqualTo(
          String conversationId, DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [conversationId],
              upper: [conversationId, createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [conversationId, createdAt],
              includeLower: false,
              upper: [conversationId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [conversationId, createdAt],
              includeLower: false,
              upper: [conversationId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId_createdAt',
              lower: [conversationId],
              upper: [conversationId, createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      conversationIdEqualToCreatedAtGreaterThan(
    String conversationId,
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conversationId_createdAt',
        lower: [conversationId, createdAt],
        includeLower: include,
        upper: [conversationId],
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      conversationIdEqualToCreatedAtLessThan(
    String conversationId,
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conversationId_createdAt',
        lower: [conversationId],
        upper: [conversationId, createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      conversationIdEqualToCreatedAtBetween(
    String conversationId,
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'conversationId_createdAt',
        lower: [conversationId, lowerCreatedAt],
        includeLower: includeLower,
        upper: [conversationId, upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      statusEqualTo(PendingMessageStatus status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      statusNotEqualTo(PendingMessageStatus status) {
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      statusGreaterThan(
    PendingMessageStatus status, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'status',
        lower: [status],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      statusLessThan(
    PendingMessageStatus status, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'status',
        lower: [],
        upper: [status],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      statusBetween(
    PendingMessageStatus lowerStatus,
    PendingMessageStatus upperStatus, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'status',
        lower: [lowerStatus],
        includeLower: includeLower,
        upper: [upperStatus],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [createdAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [],
        upper: [createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterWhereClause>
      createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [lowerCreatedAt],
        includeLower: includeLower,
        upper: [upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PendingMessageIsarQueryFilter
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QFilterCondition> {
  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      attemptCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      attemptCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      attemptCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attemptCount',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      attemptCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attemptCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      audioDurationMsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'audioDurationMs',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      audioDurationMsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'audioDurationMs',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      audioDurationMsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'audioDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      audioDurationMsGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'audioDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      audioDurationMsLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'audioDurationMs',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      audioDurationMsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'audioDurationMs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      clientMessageIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clientMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      clientMessageIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clientMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      clientMessageIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clientMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      clientMessageIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clientMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      clientMessageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clientMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      clientMessageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clientMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      clientMessageIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clientMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      clientMessageIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clientMessageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      clientMessageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clientMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      clientMessageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clientMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      contentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      contentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      conversationIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      conversationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      conversationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      conversationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conversationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      conversationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      conversationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      conversationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      conversationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'conversationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      conversationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      conversationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventLocationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'eventLocation',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventLocationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'eventLocation',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventLocationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventLocationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eventLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventLocationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eventLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventLocationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eventLocation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventLocationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eventLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventLocationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eventLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventLocationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eventLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventLocationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eventLocation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventLocationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventLocation',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventLocationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eventLocation',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'eventStart',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'eventStart',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventStartEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventStart',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventStartGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eventStart',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventStartLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eventStart',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      eventStartBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eventStart',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fileName',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fileName',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileSizeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fileSize',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileSizeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fileSize',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileSizeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileSizeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileSizeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileSizeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileSizeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileSizeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileSizeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileSizeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileSize',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileSizeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileSize',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      fileSizeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileSize',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastAttemptAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastAttemptAt',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastAttemptAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastAttemptAt',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastAttemptAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAttemptAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastAttemptAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastAttemptAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastAttemptAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastAttemptAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastAttemptAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastAttemptAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      latitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'latitude',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      latitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'latitude',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      latitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      latitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      latitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      latitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      localFilePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localFilePath',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      localFilePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localFilePath',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
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

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      localFilePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      localFilePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localFilePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      localFilePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      localFilePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      longitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'longitude',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      longitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'longitude',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      longitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      longitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      longitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      longitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      mediaUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mediaUrl',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      mediaUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mediaUrl',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      mediaUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      mediaUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mediaUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      mediaUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mediaUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      mediaUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mediaUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      mediaUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mediaUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      mediaUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mediaUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      mediaUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mediaUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      mediaUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mediaUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      mediaUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      mediaUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mediaUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pollOptions',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pollOptions',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pollOptions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pollOptions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pollOptions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pollOptions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pollOptions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pollOptions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pollOptions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pollOptions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pollOptions',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pollOptions',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pollOptions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pollOptions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pollOptions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pollOptions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pollOptions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      pollOptionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pollOptions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToContentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'replyToContent',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToContentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'replyToContent',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToContentEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'replyToContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToContentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'replyToContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToContentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'replyToContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToContentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'replyToContent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToContentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'replyToContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToContentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'replyToContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'replyToContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'replyToContent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'replyToContent',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'replyToContent',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'replyToId',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'replyToId',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'replyToId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'replyToId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'replyToId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'replyToId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'replyToId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'replyToId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'replyToId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'replyToId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'replyToId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'replyToId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToSenderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'replyToSender',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToSenderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'replyToSender',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToSenderEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'replyToSender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToSenderGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'replyToSender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToSenderLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'replyToSender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToSenderBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'replyToSender',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToSenderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'replyToSender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToSenderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'replyToSender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToSenderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'replyToSender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToSenderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'replyToSender',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToSenderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'replyToSender',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      replyToSenderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'replyToSender',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderAvatarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'senderAvatar',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderAvatarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'senderAvatar',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderAvatarEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderAvatarGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderAvatarLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderAvatarBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderAvatar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderAvatarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderAvatarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderAvatarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderAvatarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderAvatar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderAvatarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderAvatar',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderAvatarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderAvatar',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderEmailEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderEmailGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderEmailLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderEmailBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderEmail',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderEmailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderEmailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderEmailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderEmail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderEmailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderEmail',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderEmailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderEmail',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderEmailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderEmail',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderName',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderName',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderRoleNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderRoleNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderRoleNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderRoleNames',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderRoleNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderRoleNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderRoleNames',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderRoleNames',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderRoleNames',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderRoleNames',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'senderRoleNames',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'senderRoleNames',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'senderRoleNames',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'senderRoleNames',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'senderRoleNames',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderRoleNamesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'senderRoleNames',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderSchoolIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderSchoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderSchoolIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderSchoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderSchoolIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderSchoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderSchoolIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderSchoolId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderSchoolIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderSchoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderSchoolIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderSchoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderSchoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderSchoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderSchoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderSchoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderSchoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderSchoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      senderSchoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderSchoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedContactId',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedContactId',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedContactId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sharedContactId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sharedContactId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sharedContactId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sharedContactId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sharedContactId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sharedContactId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sharedContactId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedContactId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sharedContactId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactRoleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sharedContactRole',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactRoleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sharedContactRole',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactRoleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedContactRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactRoleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sharedContactRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactRoleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sharedContactRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactRoleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sharedContactRole',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactRoleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sharedContactRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactRoleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sharedContactRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactRoleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sharedContactRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactRoleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sharedContactRole',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactRoleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharedContactRole',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      sharedContactRoleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sharedContactRole',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      statusEqualTo(PendingMessageStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      statusGreaterThan(
    PendingMessageStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      statusLessThan(
    PendingMessageStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      statusBetween(
    PendingMessageStatus lower,
    PendingMessageStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      typeEqualTo(MessageType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      typeGreaterThan(
    MessageType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      typeLessThan(
    MessageType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterFilterCondition>
      typeBetween(
    MessageType lower,
    MessageType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PendingMessageIsarQueryObject
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QFilterCondition> {}

extension PendingMessageIsarQueryLinks
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QFilterCondition> {}

extension PendingMessageIsarQuerySortBy
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QSortBy> {
  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByAttemptCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByAudioDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioDurationMs', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByAudioDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioDurationMs', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByClientMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientMessageId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByClientMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientMessageId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByEventLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventLocation', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByEventLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventLocation', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByEventStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventStart', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByEventStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventStart', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByFileSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByLastAttemptAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttemptAt', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByLastAttemptAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttemptAt', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByLocalFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFilePath', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByLocalFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFilePath', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByMediaUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaUrl', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByMediaUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaUrl', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByReplyToContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToContent', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByReplyToContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToContent', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByReplyToId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByReplyToIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByReplyToSender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToSender', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByReplyToSenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToSender', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortBySenderAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAvatar', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortBySenderAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAvatar', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortBySenderEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderEmail', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortBySenderEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderEmail', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortBySenderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortBySenderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortBySenderSchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderSchoolId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortBySenderSchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderSchoolId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortBySharedContactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedContactId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortBySharedContactIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedContactId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortBySharedContactRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedContactRole', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortBySharedContactRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedContactRole', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension PendingMessageIsarQuerySortThenBy
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QSortThenBy> {
  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByAttemptCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attemptCount', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByAudioDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioDurationMs', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByAudioDurationMsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'audioDurationMs', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByClientMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientMessageId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByClientMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clientMessageId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByEventLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventLocation', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByEventLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventLocation', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByEventStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventStart', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByEventStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventStart', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByFileSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByLastAttemptAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttemptAt', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByLastAttemptAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttemptAt', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByLocalFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFilePath', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByLocalFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localFilePath', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByMediaUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaUrl', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByMediaUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaUrl', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByReplyToContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToContent', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByReplyToContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToContent', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByReplyToId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByReplyToIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByReplyToSender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToSender', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByReplyToSenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'replyToSender', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenBySenderAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAvatar', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenBySenderAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAvatar', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenBySenderEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderEmail', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenBySenderEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderEmail', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenBySenderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenBySenderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenBySenderSchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderSchoolId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenBySenderSchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderSchoolId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenBySharedContactId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedContactId', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenBySharedContactIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedContactId', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenBySharedContactRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedContactRole', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenBySharedContactRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharedContactRole', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension PendingMessageIsarQueryWhereDistinct
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct> {
  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByAttemptCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attemptCount');
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByAudioDurationMs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'audioDurationMs');
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByClientMessageId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clientMessageId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByConversationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conversationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByEventLocation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventLocation',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByEventStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventStart');
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByFileName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByFileSize({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileSize', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByLastAttemptAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAttemptAt');
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByLastError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByLocalFilePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localFilePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByMediaUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByPollOptions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pollOptions');
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByReplyToContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'replyToContent',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByReplyToId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'replyToId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByReplyToSender({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'replyToSender',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctBySenderAvatar({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderAvatar', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctBySenderEmail({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderEmail', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctBySenderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctBySenderName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctBySenderRoleNames() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderRoleNames');
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctBySenderSchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderSchoolId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctBySharedContactId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedContactId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctBySharedContactRole({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharedContactRole',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageIsar, QDistinct>
      distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension PendingMessageIsarQueryProperty
    on QueryBuilder<PendingMessageIsar, PendingMessageIsar, QQueryProperty> {
  QueryBuilder<PendingMessageIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PendingMessageIsar, int, QQueryOperations>
      attemptCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attemptCount');
    });
  }

  QueryBuilder<PendingMessageIsar, int?, QQueryOperations>
      audioDurationMsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'audioDurationMs');
    });
  }

  QueryBuilder<PendingMessageIsar, String, QQueryOperations>
      clientMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clientMessageId');
    });
  }

  QueryBuilder<PendingMessageIsar, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<PendingMessageIsar, String, QQueryOperations>
      conversationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conversationId');
    });
  }

  QueryBuilder<PendingMessageIsar, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PendingMessageIsar, String?, QQueryOperations>
      eventLocationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventLocation');
    });
  }

  QueryBuilder<PendingMessageIsar, DateTime?, QQueryOperations>
      eventStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventStart');
    });
  }

  QueryBuilder<PendingMessageIsar, String?, QQueryOperations>
      fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<PendingMessageIsar, String?, QQueryOperations>
      fileSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileSize');
    });
  }

  QueryBuilder<PendingMessageIsar, DateTime?, QQueryOperations>
      lastAttemptAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAttemptAt');
    });
  }

  QueryBuilder<PendingMessageIsar, String?, QQueryOperations>
      lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<PendingMessageIsar, double?, QQueryOperations>
      latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<PendingMessageIsar, String?, QQueryOperations>
      localFilePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localFilePath');
    });
  }

  QueryBuilder<PendingMessageIsar, double?, QQueryOperations>
      longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<PendingMessageIsar, String?, QQueryOperations>
      mediaUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaUrl');
    });
  }

  QueryBuilder<PendingMessageIsar, List<String>?, QQueryOperations>
      pollOptionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pollOptions');
    });
  }

  QueryBuilder<PendingMessageIsar, String?, QQueryOperations>
      replyToContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'replyToContent');
    });
  }

  QueryBuilder<PendingMessageIsar, String?, QQueryOperations>
      replyToIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'replyToId');
    });
  }

  QueryBuilder<PendingMessageIsar, String?, QQueryOperations>
      replyToSenderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'replyToSender');
    });
  }

  QueryBuilder<PendingMessageIsar, String?, QQueryOperations>
      senderAvatarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderAvatar');
    });
  }

  QueryBuilder<PendingMessageIsar, String, QQueryOperations>
      senderEmailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderEmail');
    });
  }

  QueryBuilder<PendingMessageIsar, String, QQueryOperations>
      senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }

  QueryBuilder<PendingMessageIsar, String, QQueryOperations>
      senderNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderName');
    });
  }

  QueryBuilder<PendingMessageIsar, List<String>, QQueryOperations>
      senderRoleNamesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderRoleNames');
    });
  }

  QueryBuilder<PendingMessageIsar, String, QQueryOperations>
      senderSchoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderSchoolId');
    });
  }

  QueryBuilder<PendingMessageIsar, String?, QQueryOperations>
      sharedContactIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedContactId');
    });
  }

  QueryBuilder<PendingMessageIsar, String?, QQueryOperations>
      sharedContactRoleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharedContactRole');
    });
  }

  QueryBuilder<PendingMessageIsar, PendingMessageStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PendingMessageIsar, MessageType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
