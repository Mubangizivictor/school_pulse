// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNotificationIsarCollection on Isar {
  IsarCollection<NotificationIsar> get notificationIsars => this.collection();
}

const NotificationIsarSchema = CollectionSchema(
  name: r'NotificationIsar',
  id: -398646555982393860,
  properties: {
    r'acknowledgedAt': PropertySchema(
      id: 0,
      name: r'acknowledgedAt',
      type: IsarType.dateTime,
    ),
    r'actions': PropertySchema(
      id: 1,
      name: r'actions',
      type: IsarType.objectList,
      target: r'NotificationActionIsar',
    ),
    r'attachments': PropertySchema(
      id: 2,
      name: r'attachments',
      type: IsarType.objectList,
      target: r'NotificationAttachmentIsar',
    ),
    r'bannerImageUrl': PropertySchema(
      id: 3,
      name: r'bannerImageUrl',
      type: IsarType.string,
    ),
    r'campusId': PropertySchema(
      id: 4,
      name: r'campusId',
      type: IsarType.string,
    ),
    r'category': PropertySchema(
      id: 5,
      name: r'category',
      type: IsarType.byte,
      enumMap: _NotificationIsarcategoryEnumValueMap,
    ),
    r'deepLinkParamKeys': PropertySchema(
      id: 6,
      name: r'deepLinkParamKeys',
      type: IsarType.stringList,
    ),
    r'deepLinkParamValues': PropertySchema(
      id: 7,
      name: r'deepLinkParamValues',
      type: IsarType.stringList,
    ),
    r'deepLinkRoute': PropertySchema(
      id: 8,
      name: r'deepLinkRoute',
      type: IsarType.string,
    ),
    r'deliveredAt': PropertySchema(
      id: 9,
      name: r'deliveredAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 10,
      name: r'description',
      type: IsarType.string,
    ),
    r'expiresAt': PropertySchema(
      id: 11,
      name: r'expiresAt',
      type: IsarType.dateTime,
    ),
    r'failureReason': PropertySchema(
      id: 12,
      name: r'failureReason',
      type: IsarType.string,
    ),
    r'hasPendingStateChange': PropertySchema(
      id: 13,
      name: r'hasPendingStateChange',
      type: IsarType.bool,
    ),
    r'isArchived': PropertySchema(
      id: 14,
      name: r'isArchived',
      type: IsarType.bool,
    ),
    r'localDeliveryStatus': PropertySchema(
      id: 15,
      name: r'localDeliveryStatus',
      type: IsarType.byte,
      enumMap: _NotificationIsarlocalDeliveryStatusEnumValueMap,
    ),
    r'localImagePath': PropertySchema(
      id: 16,
      name: r'localImagePath',
      type: IsarType.string,
    ),
    r'longMessage': PropertySchema(
      id: 17,
      name: r'longMessage',
      type: IsarType.string,
    ),
    r'metadataKeys': PropertySchema(
      id: 18,
      name: r'metadataKeys',
      type: IsarType.stringList,
    ),
    r'metadataValues': PropertySchema(
      id: 19,
      name: r'metadataValues',
      type: IsarType.stringList,
    ),
    r'notificationId': PropertySchema(
      id: 20,
      name: r'notificationId',
      type: IsarType.string,
    ),
    r'openedAt': PropertySchema(
      id: 21,
      name: r'openedAt',
      type: IsarType.dateTime,
    ),
    r'pendingFields': PropertySchema(
      id: 22,
      name: r'pendingFields',
      type: IsarType.stringList,
    ),
    r'persistence': PropertySchema(
      id: 23,
      name: r'persistence',
      type: IsarType.byte,
      enumMap: _NotificationIsarpersistenceEnumValueMap,
    ),
    r'priority': PropertySchema(
      id: 24,
      name: r'priority',
      type: IsarType.byte,
      enumMap: _NotificationIsarpriorityEnumValueMap,
    ),
    r'pushDeliveryStatus': PropertySchema(
      id: 25,
      name: r'pushDeliveryStatus',
      type: IsarType.byte,
      enumMap: _NotificationIsarpushDeliveryStatusEnumValueMap,
    ),
    r'readAt': PropertySchema(
      id: 26,
      name: r'readAt',
      type: IsarType.dateTime,
    ),
    r'recipientRole': PropertySchema(
      id: 27,
      name: r'recipientRole',
      type: IsarType.string,
    ),
    r'recipientUserId': PropertySchema(
      id: 28,
      name: r'recipientUserId',
      type: IsarType.string,
    ),
    r'relatedClassName': PropertySchema(
      id: 29,
      name: r'relatedClassName',
      type: IsarType.string,
    ),
    r'relatedConversationId': PropertySchema(
      id: 30,
      name: r'relatedConversationId',
      type: IsarType.string,
    ),
    r'relatedParentId': PropertySchema(
      id: 31,
      name: r'relatedParentId',
      type: IsarType.string,
    ),
    r'relatedStaffId': PropertySchema(
      id: 32,
      name: r'relatedStaffId',
      type: IsarType.string,
    ),
    r'relatedStudentId': PropertySchema(
      id: 33,
      name: r'relatedStudentId',
      type: IsarType.string,
    ),
    r'relatedStudentName': PropertySchema(
      id: 34,
      name: r'relatedStudentName',
      type: IsarType.string,
    ),
    r'requiresAcknowledgment': PropertySchema(
      id: 35,
      name: r'requiresAcknowledgment',
      type: IsarType.bool,
    ),
    r'scheduledAt': PropertySchema(
      id: 36,
      name: r'scheduledAt',
      type: IsarType.dateTime,
    ),
    r'schoolId': PropertySchema(
      id: 37,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'senderAvatar': PropertySchema(
      id: 38,
      name: r'senderAvatar',
      type: IsarType.string,
    ),
    r'senderDepartment': PropertySchema(
      id: 39,
      name: r'senderDepartment',
      type: IsarType.string,
    ),
    r'senderId': PropertySchema(
      id: 40,
      name: r'senderId',
      type: IsarType.string,
    ),
    r'senderKind': PropertySchema(
      id: 41,
      name: r'senderKind',
      type: IsarType.byte,
      enumMap: _NotificationIsarsenderKindEnumValueMap,
    ),
    r'senderLocalPhotoPath': PropertySchema(
      id: 42,
      name: r'senderLocalPhotoPath',
      type: IsarType.string,
    ),
    r'senderName': PropertySchema(
      id: 43,
      name: r'senderName',
      type: IsarType.string,
    ),
    r'senderRole': PropertySchema(
      id: 44,
      name: r'senderRole',
      type: IsarType.string,
    ),
    r'sentAt': PropertySchema(
      id: 45,
      name: r'sentAt',
      type: IsarType.dateTime,
    ),
    r'sourceEntityId': PropertySchema(
      id: 46,
      name: r'sourceEntityId',
      type: IsarType.string,
    ),
    r'sourceModule': PropertySchema(
      id: 47,
      name: r'sourceModule',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 48,
      name: r'status',
      type: IsarType.byte,
      enumMap: _NotificationIsarstatusEnumValueMap,
    ),
    r'syncedAt': PropertySchema(
      id: 49,
      name: r'syncedAt',
      type: IsarType.dateTime,
    ),
    r'thumbnailUrl': PropertySchema(
      id: 50,
      name: r'thumbnailUrl',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 51,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(
      id: 52,
      name: r'title',
      type: IsarType.string,
    ),
    r'triggerReason': PropertySchema(
      id: 53,
      name: r'triggerReason',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 54,
      name: r'type',
      type: IsarType.byte,
      enumMap: _NotificationIsartypeEnumValueMap,
    )
  },
  estimateSize: _notificationIsarEstimateSize,
  serialize: _notificationIsarSerialize,
  deserialize: _notificationIsarDeserialize,
  deserializeProp: _notificationIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'notificationId': IndexSchema(
      id: 1533036797414670656,
      name: r'notificationId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'notificationId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'schoolId_recipientUserId': IndexSchema(
      id: -8111451985348414766,
      name: r'schoolId_recipientUserId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'schoolId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'recipientUserId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isArchived': IndexSchema(
      id: 655844772568347876,
      name: r'isArchived',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isArchived',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'hasPendingStateChange': IndexSchema(
      id: -3881356021884867890,
      name: r'hasPendingStateChange',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'hasPendingStateChange',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'NotificationActionIsar': NotificationActionIsarSchema,
    r'NotificationAttachmentIsar': NotificationAttachmentIsarSchema
  },
  getId: _notificationIsarGetId,
  getLinks: _notificationIsarGetLinks,
  attach: _notificationIsarAttach,
  version: '3.1.0+1',
);

int _notificationIsarEstimateSize(
  NotificationIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.actions.length * 3;
  {
    final offsets = allOffsets[NotificationActionIsar]!;
    for (var i = 0; i < object.actions.length; i++) {
      final value = object.actions[i];
      bytesCount +=
          NotificationActionIsarSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.attachments.length * 3;
  {
    final offsets = allOffsets[NotificationAttachmentIsar]!;
    for (var i = 0; i < object.attachments.length; i++) {
      final value = object.attachments[i];
      bytesCount += NotificationAttachmentIsarSchema.estimateSize(
          value, offsets, allOffsets);
    }
  }
  {
    final value = object.bannerImageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.campusId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.deepLinkParamKeys.length * 3;
  {
    for (var i = 0; i < object.deepLinkParamKeys.length; i++) {
      final value = object.deepLinkParamKeys[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.deepLinkParamValues.length * 3;
  {
    for (var i = 0; i < object.deepLinkParamValues.length; i++) {
      final value = object.deepLinkParamValues[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.deepLinkRoute;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.description.length * 3;
  {
    final value = object.failureReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.localImagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.longMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.metadataKeys.length * 3;
  {
    for (var i = 0; i < object.metadataKeys.length; i++) {
      final value = object.metadataKeys[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.metadataValues.length * 3;
  {
    for (var i = 0; i < object.metadataValues.length; i++) {
      final value = object.metadataValues[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.notificationId.length * 3;
  bytesCount += 3 + object.pendingFields.length * 3;
  {
    for (var i = 0; i < object.pendingFields.length; i++) {
      final value = object.pendingFields[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.recipientRole;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.recipientUserId.length * 3;
  {
    final value = object.relatedClassName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.relatedConversationId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.relatedParentId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.relatedStaffId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.relatedStudentId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.relatedStudentName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolId.length * 3;
  {
    final value = object.senderAvatar;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.senderDepartment;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.senderId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.senderLocalPhotoPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.senderName.length * 3;
  bytesCount += 3 + object.senderRole.length * 3;
  {
    final value = object.sourceEntityId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sourceModule;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.thumbnailUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  {
    final value = object.triggerReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _notificationIsarSerialize(
  NotificationIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.acknowledgedAt);
  writer.writeObjectList<NotificationActionIsar>(
    offsets[1],
    allOffsets,
    NotificationActionIsarSchema.serialize,
    object.actions,
  );
  writer.writeObjectList<NotificationAttachmentIsar>(
    offsets[2],
    allOffsets,
    NotificationAttachmentIsarSchema.serialize,
    object.attachments,
  );
  writer.writeString(offsets[3], object.bannerImageUrl);
  writer.writeString(offsets[4], object.campusId);
  writer.writeByte(offsets[5], object.category.index);
  writer.writeStringList(offsets[6], object.deepLinkParamKeys);
  writer.writeStringList(offsets[7], object.deepLinkParamValues);
  writer.writeString(offsets[8], object.deepLinkRoute);
  writer.writeDateTime(offsets[9], object.deliveredAt);
  writer.writeString(offsets[10], object.description);
  writer.writeDateTime(offsets[11], object.expiresAt);
  writer.writeString(offsets[12], object.failureReason);
  writer.writeBool(offsets[13], object.hasPendingStateChange);
  writer.writeBool(offsets[14], object.isArchived);
  writer.writeByte(offsets[15], object.localDeliveryStatus.index);
  writer.writeString(offsets[16], object.localImagePath);
  writer.writeString(offsets[17], object.longMessage);
  writer.writeStringList(offsets[18], object.metadataKeys);
  writer.writeStringList(offsets[19], object.metadataValues);
  writer.writeString(offsets[20], object.notificationId);
  writer.writeDateTime(offsets[21], object.openedAt);
  writer.writeStringList(offsets[22], object.pendingFields);
  writer.writeByte(offsets[23], object.persistence.index);
  writer.writeByte(offsets[24], object.priority.index);
  writer.writeByte(offsets[25], object.pushDeliveryStatus.index);
  writer.writeDateTime(offsets[26], object.readAt);
  writer.writeString(offsets[27], object.recipientRole);
  writer.writeString(offsets[28], object.recipientUserId);
  writer.writeString(offsets[29], object.relatedClassName);
  writer.writeString(offsets[30], object.relatedConversationId);
  writer.writeString(offsets[31], object.relatedParentId);
  writer.writeString(offsets[32], object.relatedStaffId);
  writer.writeString(offsets[33], object.relatedStudentId);
  writer.writeString(offsets[34], object.relatedStudentName);
  writer.writeBool(offsets[35], object.requiresAcknowledgment);
  writer.writeDateTime(offsets[36], object.scheduledAt);
  writer.writeString(offsets[37], object.schoolId);
  writer.writeString(offsets[38], object.senderAvatar);
  writer.writeString(offsets[39], object.senderDepartment);
  writer.writeString(offsets[40], object.senderId);
  writer.writeByte(offsets[41], object.senderKind.index);
  writer.writeString(offsets[42], object.senderLocalPhotoPath);
  writer.writeString(offsets[43], object.senderName);
  writer.writeString(offsets[44], object.senderRole);
  writer.writeDateTime(offsets[45], object.sentAt);
  writer.writeString(offsets[46], object.sourceEntityId);
  writer.writeString(offsets[47], object.sourceModule);
  writer.writeByte(offsets[48], object.status.index);
  writer.writeDateTime(offsets[49], object.syncedAt);
  writer.writeString(offsets[50], object.thumbnailUrl);
  writer.writeDateTime(offsets[51], object.timestamp);
  writer.writeString(offsets[52], object.title);
  writer.writeString(offsets[53], object.triggerReason);
  writer.writeByte(offsets[54], object.type.index);
}

NotificationIsar _notificationIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NotificationIsar();
  object.acknowledgedAt = reader.readDateTimeOrNull(offsets[0]);
  object.actions = reader.readObjectList<NotificationActionIsar>(
        offsets[1],
        NotificationActionIsarSchema.deserialize,
        allOffsets,
        NotificationActionIsar(),
      ) ??
      [];
  object.attachments = reader.readObjectList<NotificationAttachmentIsar>(
        offsets[2],
        NotificationAttachmentIsarSchema.deserialize,
        allOffsets,
        NotificationAttachmentIsar(),
      ) ??
      [];
  object.bannerImageUrl = reader.readStringOrNull(offsets[3]);
  object.campusId = reader.readStringOrNull(offsets[4]);
  object.category = _NotificationIsarcategoryValueEnumMap[
          reader.readByteOrNull(offsets[5])] ??
      NotificationCategory.announcements;
  object.deepLinkParamKeys = reader.readStringList(offsets[6]) ?? [];
  object.deepLinkParamValues = reader.readStringList(offsets[7]) ?? [];
  object.deepLinkRoute = reader.readStringOrNull(offsets[8]);
  object.deliveredAt = reader.readDateTimeOrNull(offsets[9]);
  object.description = reader.readString(offsets[10]);
  object.expiresAt = reader.readDateTimeOrNull(offsets[11]);
  object.failureReason = reader.readStringOrNull(offsets[12]);
  object.hasPendingStateChange = reader.readBool(offsets[13]);
  object.id = id;
  object.isArchived = reader.readBool(offsets[14]);
  object.localDeliveryStatus = _NotificationIsarlocalDeliveryStatusValueEnumMap[
          reader.readByteOrNull(offsets[15])] ??
      NotificationDeliveryStatus.pending;
  object.localImagePath = reader.readStringOrNull(offsets[16]);
  object.longMessage = reader.readStringOrNull(offsets[17]);
  object.metadataKeys = reader.readStringList(offsets[18]) ?? [];
  object.metadataValues = reader.readStringList(offsets[19]) ?? [];
  object.notificationId = reader.readString(offsets[20]);
  object.openedAt = reader.readDateTimeOrNull(offsets[21]);
  object.pendingFields = reader.readStringList(offsets[22]) ?? [];
  object.persistence = _NotificationIsarpersistenceValueEnumMap[
          reader.readByteOrNull(offsets[23])] ??
      NotificationPersistence.transient;
  object.priority = _NotificationIsarpriorityValueEnumMap[
          reader.readByteOrNull(offsets[24])] ??
      NotificationPriority.low;
  object.pushDeliveryStatus = _NotificationIsarpushDeliveryStatusValueEnumMap[
          reader.readByteOrNull(offsets[25])] ??
      NotificationDeliveryStatus.pending;
  object.readAt = reader.readDateTimeOrNull(offsets[26]);
  object.recipientRole = reader.readStringOrNull(offsets[27]);
  object.recipientUserId = reader.readString(offsets[28]);
  object.relatedClassName = reader.readStringOrNull(offsets[29]);
  object.relatedConversationId = reader.readStringOrNull(offsets[30]);
  object.relatedParentId = reader.readStringOrNull(offsets[31]);
  object.relatedStaffId = reader.readStringOrNull(offsets[32]);
  object.relatedStudentId = reader.readStringOrNull(offsets[33]);
  object.relatedStudentName = reader.readStringOrNull(offsets[34]);
  object.requiresAcknowledgment = reader.readBool(offsets[35]);
  object.scheduledAt = reader.readDateTimeOrNull(offsets[36]);
  object.schoolId = reader.readString(offsets[37]);
  object.senderAvatar = reader.readStringOrNull(offsets[38]);
  object.senderDepartment = reader.readStringOrNull(offsets[39]);
  object.senderId = reader.readStringOrNull(offsets[40]);
  object.senderKind = _NotificationIsarsenderKindValueEnumMap[
          reader.readByteOrNull(offsets[41])] ??
      NotificationSourceKind.human;
  object.senderLocalPhotoPath = reader.readStringOrNull(offsets[42]);
  object.senderName = reader.readString(offsets[43]);
  object.senderRole = reader.readString(offsets[44]);
  object.sentAt = reader.readDateTimeOrNull(offsets[45]);
  object.sourceEntityId = reader.readStringOrNull(offsets[46]);
  object.sourceModule = reader.readStringOrNull(offsets[47]);
  object.status =
      _NotificationIsarstatusValueEnumMap[reader.readByteOrNull(offsets[48])] ??
          NotificationStatus.unread;
  object.syncedAt = reader.readDateTimeOrNull(offsets[49]);
  object.thumbnailUrl = reader.readStringOrNull(offsets[50]);
  object.timestamp = reader.readDateTime(offsets[51]);
  object.title = reader.readString(offsets[52]);
  object.triggerReason = reader.readStringOrNull(offsets[53]);
  object.type =
      _NotificationIsartypeValueEnumMap[reader.readByteOrNull(offsets[54])] ??
          NotificationType.newMessage;
  return object;
}

P _notificationIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readObjectList<NotificationActionIsar>(
            offset,
            NotificationActionIsarSchema.deserialize,
            allOffsets,
            NotificationActionIsar(),
          ) ??
          []) as P;
    case 2:
      return (reader.readObjectList<NotificationAttachmentIsar>(
            offset,
            NotificationAttachmentIsarSchema.deserialize,
            allOffsets,
            NotificationAttachmentIsar(),
          ) ??
          []) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (_NotificationIsarcategoryValueEnumMap[
              reader.readByteOrNull(offset)] ??
          NotificationCategory.announcements) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readStringList(offset) ?? []) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (_NotificationIsarlocalDeliveryStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          NotificationDeliveryStatus.pending) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readStringList(offset) ?? []) as P;
    case 19:
      return (reader.readStringList(offset) ?? []) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 22:
      return (reader.readStringList(offset) ?? []) as P;
    case 23:
      return (_NotificationIsarpersistenceValueEnumMap[
              reader.readByteOrNull(offset)] ??
          NotificationPersistence.transient) as P;
    case 24:
      return (_NotificationIsarpriorityValueEnumMap[
              reader.readByteOrNull(offset)] ??
          NotificationPriority.low) as P;
    case 25:
      return (_NotificationIsarpushDeliveryStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          NotificationDeliveryStatus.pending) as P;
    case 26:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    case 30:
      return (reader.readStringOrNull(offset)) as P;
    case 31:
      return (reader.readStringOrNull(offset)) as P;
    case 32:
      return (reader.readStringOrNull(offset)) as P;
    case 33:
      return (reader.readStringOrNull(offset)) as P;
    case 34:
      return (reader.readStringOrNull(offset)) as P;
    case 35:
      return (reader.readBool(offset)) as P;
    case 36:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 37:
      return (reader.readString(offset)) as P;
    case 38:
      return (reader.readStringOrNull(offset)) as P;
    case 39:
      return (reader.readStringOrNull(offset)) as P;
    case 40:
      return (reader.readStringOrNull(offset)) as P;
    case 41:
      return (_NotificationIsarsenderKindValueEnumMap[
              reader.readByteOrNull(offset)] ??
          NotificationSourceKind.human) as P;
    case 42:
      return (reader.readStringOrNull(offset)) as P;
    case 43:
      return (reader.readString(offset)) as P;
    case 44:
      return (reader.readString(offset)) as P;
    case 45:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 46:
      return (reader.readStringOrNull(offset)) as P;
    case 47:
      return (reader.readStringOrNull(offset)) as P;
    case 48:
      return (_NotificationIsarstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          NotificationStatus.unread) as P;
    case 49:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 50:
      return (reader.readStringOrNull(offset)) as P;
    case 51:
      return (reader.readDateTime(offset)) as P;
    case 52:
      return (reader.readString(offset)) as P;
    case 53:
      return (reader.readStringOrNull(offset)) as P;
    case 54:
      return (_NotificationIsartypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          NotificationType.newMessage) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _NotificationIsarcategoryEnumValueMap = {
  'announcements': 0,
  'attendance': 1,
  'finance': 2,
  'transport': 3,
  'messages': 4,
  'homework': 5,
  'library': 6,
  'others': 7,
  'gate': 8,
  'results': 9,
  'examinations': 10,
  'timetable': 11,
  'medical': 12,
  'appointments': 13,
  'visitors': 14,
  'security': 15,
  'discipline': 16,
  'counselling': 17,
  'clubs': 18,
  'sports': 19,
  'catering': 20,
  'hostel': 21,
  'events': 22,
  'emergency': 23,
  'billing': 24,
  'system': 25,
  'support': 26,
  'platform': 27,
};
const _NotificationIsarcategoryValueEnumMap = {
  0: NotificationCategory.announcements,
  1: NotificationCategory.attendance,
  2: NotificationCategory.finance,
  3: NotificationCategory.transport,
  4: NotificationCategory.messages,
  5: NotificationCategory.homework,
  6: NotificationCategory.library,
  7: NotificationCategory.others,
  8: NotificationCategory.gate,
  9: NotificationCategory.results,
  10: NotificationCategory.examinations,
  11: NotificationCategory.timetable,
  12: NotificationCategory.medical,
  13: NotificationCategory.appointments,
  14: NotificationCategory.visitors,
  15: NotificationCategory.security,
  16: NotificationCategory.discipline,
  17: NotificationCategory.counselling,
  18: NotificationCategory.clubs,
  19: NotificationCategory.sports,
  20: NotificationCategory.catering,
  21: NotificationCategory.hostel,
  22: NotificationCategory.events,
  23: NotificationCategory.emergency,
  24: NotificationCategory.billing,
  25: NotificationCategory.system,
  26: NotificationCategory.support,
  27: NotificationCategory.platform,
};
const _NotificationIsarlocalDeliveryStatusEnumValueMap = {
  'pending': 0,
  'sent': 1,
  'delivered': 2,
  'failed': 3,
  'expired': 4,
  'suppressed': 5,
  'notApplicable': 6,
};
const _NotificationIsarlocalDeliveryStatusValueEnumMap = {
  0: NotificationDeliveryStatus.pending,
  1: NotificationDeliveryStatus.sent,
  2: NotificationDeliveryStatus.delivered,
  3: NotificationDeliveryStatus.failed,
  4: NotificationDeliveryStatus.expired,
  5: NotificationDeliveryStatus.suppressed,
  6: NotificationDeliveryStatus.notApplicable,
};
const _NotificationIsarpersistenceEnumValueMap = {
  'transient': 0,
  'permanent': 1,
};
const _NotificationIsarpersistenceValueEnumMap = {
  0: NotificationPersistence.transient,
  1: NotificationPersistence.permanent,
};
const _NotificationIsarpriorityEnumValueMap = {
  'low': 0,
  'medium': 1,
  'high': 2,
  'urgent': 3,
};
const _NotificationIsarpriorityValueEnumMap = {
  0: NotificationPriority.low,
  1: NotificationPriority.medium,
  2: NotificationPriority.high,
  3: NotificationPriority.urgent,
};
const _NotificationIsarpushDeliveryStatusEnumValueMap = {
  'pending': 0,
  'sent': 1,
  'delivered': 2,
  'failed': 3,
  'expired': 4,
  'suppressed': 5,
  'notApplicable': 6,
};
const _NotificationIsarpushDeliveryStatusValueEnumMap = {
  0: NotificationDeliveryStatus.pending,
  1: NotificationDeliveryStatus.sent,
  2: NotificationDeliveryStatus.delivered,
  3: NotificationDeliveryStatus.failed,
  4: NotificationDeliveryStatus.expired,
  5: NotificationDeliveryStatus.suppressed,
  6: NotificationDeliveryStatus.notApplicable,
};
const _NotificationIsarsenderKindEnumValueMap = {
  'human': 0,
  'automated': 1,
  'platform': 2,
};
const _NotificationIsarsenderKindValueEnumMap = {
  0: NotificationSourceKind.human,
  1: NotificationSourceKind.automated,
  2: NotificationSourceKind.platform,
};
const _NotificationIsarstatusEnumValueMap = {
  'unread': 0,
  'read': 1,
  'pinned': 2,
  'archived': 3,
};
const _NotificationIsarstatusValueEnumMap = {
  0: NotificationStatus.unread,
  1: NotificationStatus.read,
  2: NotificationStatus.pinned,
  3: NotificationStatus.archived,
};
const _NotificationIsartypeEnumValueMap = {
  'newMessage': 0,
  'groupMessage': 1,
  'messageRequest': 2,
  'gateEntry': 3,
  'gateExit': 4,
  'lateArrival': 5,
  'studentAbsent': 6,
  'subjectAttendance': 7,
  'boardingRollCall': 8,
  'busBoarded': 9,
  'busDropOff': 10,
  'busDelayed': 11,
  'transportIncident': 12,
  'paymentReceived': 13,
  'paymentFailed': 14,
  'feeReminder': 15,
  'receiptGenerated': 16,
  'reportCardPublished': 17,
  'resultsPublished': 18,
  'homeworkAssigned': 19,
  'assignmentDue': 20,
  'examScheduled': 21,
  'timetableUpdated': 22,
  'bookOverdue': 23,
  'bookDueSoon': 24,
  'nurseAlert': 25,
  'medicalAlert': 26,
  'appointmentApproved': 27,
  'appointmentChanged': 28,
  'appointmentReminder': 29,
  'visitorArrived': 30,
  'disciplineCase': 31,
  'counsellingNote': 32,
  'announcement': 33,
  'eventNotice': 34,
  'clubNotice': 35,
  'sportsNotice': 36,
  'mealEligibility': 37,
  'hostelNotice': 38,
  'emergencyAlert': 39,
  'securityAlert': 40,
  'subscriptionNotice': 41,
  'systemMaintenance': 42,
  'supportTicketUpdate': 43,
  'platformAnnouncement': 44,
  'custom': 45,
};
const _NotificationIsartypeValueEnumMap = {
  0: NotificationType.newMessage,
  1: NotificationType.groupMessage,
  2: NotificationType.messageRequest,
  3: NotificationType.gateEntry,
  4: NotificationType.gateExit,
  5: NotificationType.lateArrival,
  6: NotificationType.studentAbsent,
  7: NotificationType.subjectAttendance,
  8: NotificationType.boardingRollCall,
  9: NotificationType.busBoarded,
  10: NotificationType.busDropOff,
  11: NotificationType.busDelayed,
  12: NotificationType.transportIncident,
  13: NotificationType.paymentReceived,
  14: NotificationType.paymentFailed,
  15: NotificationType.feeReminder,
  16: NotificationType.receiptGenerated,
  17: NotificationType.reportCardPublished,
  18: NotificationType.resultsPublished,
  19: NotificationType.homeworkAssigned,
  20: NotificationType.assignmentDue,
  21: NotificationType.examScheduled,
  22: NotificationType.timetableUpdated,
  23: NotificationType.bookOverdue,
  24: NotificationType.bookDueSoon,
  25: NotificationType.nurseAlert,
  26: NotificationType.medicalAlert,
  27: NotificationType.appointmentApproved,
  28: NotificationType.appointmentChanged,
  29: NotificationType.appointmentReminder,
  30: NotificationType.visitorArrived,
  31: NotificationType.disciplineCase,
  32: NotificationType.counsellingNote,
  33: NotificationType.announcement,
  34: NotificationType.eventNotice,
  35: NotificationType.clubNotice,
  36: NotificationType.sportsNotice,
  37: NotificationType.mealEligibility,
  38: NotificationType.hostelNotice,
  39: NotificationType.emergencyAlert,
  40: NotificationType.securityAlert,
  41: NotificationType.subscriptionNotice,
  42: NotificationType.systemMaintenance,
  43: NotificationType.supportTicketUpdate,
  44: NotificationType.platformAnnouncement,
  45: NotificationType.custom,
};

Id _notificationIsarGetId(NotificationIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _notificationIsarGetLinks(NotificationIsar object) {
  return [];
}

void _notificationIsarAttach(
    IsarCollection<dynamic> col, Id id, NotificationIsar object) {
  object.id = id;
}

extension NotificationIsarByIndex on IsarCollection<NotificationIsar> {
  Future<NotificationIsar?> getByNotificationId(String notificationId) {
    return getByIndex(r'notificationId', [notificationId]);
  }

  NotificationIsar? getByNotificationIdSync(String notificationId) {
    return getByIndexSync(r'notificationId', [notificationId]);
  }

  Future<bool> deleteByNotificationId(String notificationId) {
    return deleteByIndex(r'notificationId', [notificationId]);
  }

  bool deleteByNotificationIdSync(String notificationId) {
    return deleteByIndexSync(r'notificationId', [notificationId]);
  }

  Future<List<NotificationIsar?>> getAllByNotificationId(
      List<String> notificationIdValues) {
    final values = notificationIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'notificationId', values);
  }

  List<NotificationIsar?> getAllByNotificationIdSync(
      List<String> notificationIdValues) {
    final values = notificationIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'notificationId', values);
  }

  Future<int> deleteAllByNotificationId(List<String> notificationIdValues) {
    final values = notificationIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'notificationId', values);
  }

  int deleteAllByNotificationIdSync(List<String> notificationIdValues) {
    final values = notificationIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'notificationId', values);
  }

  Future<Id> putByNotificationId(NotificationIsar object) {
    return putByIndex(r'notificationId', object);
  }

  Id putByNotificationIdSync(NotificationIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'notificationId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNotificationId(List<NotificationIsar> objects) {
    return putAllByIndex(r'notificationId', objects);
  }

  List<Id> putAllByNotificationIdSync(List<NotificationIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'notificationId', objects, saveLinks: saveLinks);
  }
}

extension NotificationIsarQueryWhereSort
    on QueryBuilder<NotificationIsar, NotificationIsar, QWhere> {
  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhere> anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhere>
      anyIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isArchived'),
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhere>
      anyHasPendingStateChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'hasPendingStateChange'),
      );
    });
  }
}

extension NotificationIsarQueryWhere
    on QueryBuilder<NotificationIsar, NotificationIsar, QWhereClause> {
  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      notificationIdEqualTo(String notificationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'notificationId',
        value: [notificationId],
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      notificationIdNotEqualTo(String notificationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'notificationId',
              lower: [],
              upper: [notificationId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'notificationId',
              lower: [notificationId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'notificationId',
              lower: [notificationId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'notificationId',
              lower: [],
              upper: [notificationId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      schoolIdEqualToAnyRecipientUserId(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId_recipientUserId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      schoolIdNotEqualToAnyRecipientUserId(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schoolId_recipientUserId',
              lower: [],
              upper: [schoolId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schoolId_recipientUserId',
              lower: [schoolId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schoolId_recipientUserId',
              lower: [schoolId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schoolId_recipientUserId',
              lower: [],
              upper: [schoolId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      schoolIdRecipientUserIdEqualTo(String schoolId, String recipientUserId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId_recipientUserId',
        value: [schoolId, recipientUserId],
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      schoolIdEqualToRecipientUserIdNotEqualTo(
          String schoolId, String recipientUserId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schoolId_recipientUserId',
              lower: [schoolId],
              upper: [schoolId, recipientUserId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schoolId_recipientUserId',
              lower: [schoolId, recipientUserId],
              includeLower: false,
              upper: [schoolId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schoolId_recipientUserId',
              lower: [schoolId, recipientUserId],
              includeLower: false,
              upper: [schoolId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'schoolId_recipientUserId',
              lower: [schoolId],
              upper: [schoolId, recipientUserId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      isArchivedEqualTo(bool isArchived) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isArchived',
        value: [isArchived],
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      isArchivedNotEqualTo(bool isArchived) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [],
              upper: [isArchived],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [isArchived],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [isArchived],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isArchived',
              lower: [],
              upper: [isArchived],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      hasPendingStateChangeEqualTo(bool hasPendingStateChange) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'hasPendingStateChange',
        value: [hasPendingStateChange],
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterWhereClause>
      hasPendingStateChangeNotEqualTo(bool hasPendingStateChange) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hasPendingStateChange',
              lower: [],
              upper: [hasPendingStateChange],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hasPendingStateChange',
              lower: [hasPendingStateChange],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hasPendingStateChange',
              lower: [hasPendingStateChange],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'hasPendingStateChange',
              lower: [],
              upper: [hasPendingStateChange],
              includeUpper: false,
            ));
      }
    });
  }
}

extension NotificationIsarQueryFilter
    on QueryBuilder<NotificationIsar, NotificationIsar, QFilterCondition> {
  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      acknowledgedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'acknowledgedAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      acknowledgedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'acknowledgedAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      acknowledgedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'acknowledgedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      acknowledgedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'acknowledgedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      acknowledgedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'acknowledgedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      acknowledgedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'acknowledgedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      actionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      actionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      actionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      actionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      actionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      actionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'actions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      attachmentsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachments',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      attachmentsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachments',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      attachmentsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachments',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      attachmentsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachments',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      attachmentsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachments',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      attachmentsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'attachments',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      bannerImageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bannerImageUrl',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      bannerImageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bannerImageUrl',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      bannerImageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bannerImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      bannerImageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bannerImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      bannerImageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bannerImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      bannerImageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bannerImageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      bannerImageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bannerImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      bannerImageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bannerImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      bannerImageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bannerImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      bannerImageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bannerImageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      bannerImageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bannerImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      bannerImageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bannerImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      campusIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'campusId',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      campusIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'campusId',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      campusIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'campusId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      campusIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'campusId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      campusIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      campusIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'campusId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      categoryEqualTo(NotificationCategory value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      categoryGreaterThan(
    NotificationCategory value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      categoryLessThan(
    NotificationCategory value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      categoryBetween(
    NotificationCategory lower,
    NotificationCategory upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deepLinkParamKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deepLinkParamKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deepLinkParamKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deepLinkParamKeys',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deepLinkParamKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deepLinkParamKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deepLinkParamKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deepLinkParamKeys',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deepLinkParamKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deepLinkParamKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'deepLinkParamKeys',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'deepLinkParamKeys',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'deepLinkParamKeys',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'deepLinkParamKeys',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'deepLinkParamKeys',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamKeysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'deepLinkParamKeys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deepLinkParamValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deepLinkParamValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deepLinkParamValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deepLinkParamValues',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deepLinkParamValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deepLinkParamValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deepLinkParamValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deepLinkParamValues',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deepLinkParamValues',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deepLinkParamValues',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'deepLinkParamValues',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'deepLinkParamValues',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'deepLinkParamValues',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'deepLinkParamValues',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'deepLinkParamValues',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkParamValuesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'deepLinkParamValues',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkRouteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deepLinkRoute',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkRouteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deepLinkRoute',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkRouteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deepLinkRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkRouteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deepLinkRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkRouteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deepLinkRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkRouteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deepLinkRoute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkRouteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deepLinkRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkRouteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deepLinkRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkRouteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deepLinkRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkRouteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deepLinkRoute',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkRouteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deepLinkRoute',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deepLinkRouteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deepLinkRoute',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deliveredAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deliveredAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deliveredAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deliveredAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deliveredAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deliveredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deliveredAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deliveredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deliveredAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deliveredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      deliveredAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deliveredAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      expiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expiresAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      expiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expiresAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      expiresAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      expiresAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      expiresAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expiresAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      expiresAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expiresAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      failureReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'failureReason',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      failureReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'failureReason',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      failureReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'failureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      failureReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'failureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      failureReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'failureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      failureReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'failureReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      failureReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'failureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      failureReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'failureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      failureReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'failureReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      failureReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'failureReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      failureReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'failureReason',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      failureReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'failureReason',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      hasPendingStateChangeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasPendingStateChange',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      isArchivedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isArchived',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localDeliveryStatusEqualTo(NotificationDeliveryStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localDeliveryStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localDeliveryStatusGreaterThan(
    NotificationDeliveryStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localDeliveryStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localDeliveryStatusLessThan(
    NotificationDeliveryStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localDeliveryStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localDeliveryStatusBetween(
    NotificationDeliveryStatus lower,
    NotificationDeliveryStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localDeliveryStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localImagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localImagePath',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localImagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localImagePath',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localImagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localImagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localImagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localImagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      localImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      longMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'longMessage',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      longMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'longMessage',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      longMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      longMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      longMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      longMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      longMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'longMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      longMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'longMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      longMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'longMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      longMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'longMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      longMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      longMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'longMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metadataKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metadataKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metadataKeys',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metadataKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metadataKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metadataKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metadataKeys',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metadataKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metadataKeys',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metadataKeys',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metadataKeys',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metadataKeys',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metadataKeys',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataKeysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metadataKeys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metadataValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metadataValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metadataValues',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metadataValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metadataValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metadataValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metadataValues',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataValues',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metadataValues',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metadataValues',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metadataValues',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metadataValues',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metadataValues',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metadataValues',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      metadataValuesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'metadataValues',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      notificationIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      notificationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notificationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      notificationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notificationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      notificationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notificationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      notificationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notificationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      notificationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notificationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      notificationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notificationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      notificationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notificationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      notificationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      notificationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notificationId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      openedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'openedAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      openedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'openedAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      openedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'openedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      openedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'openedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      openedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'openedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      openedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'openedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendingFields',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pendingFields',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pendingFields',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pendingFields',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pendingFields',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pendingFields',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pendingFields',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pendingFields',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendingFields',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pendingFields',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pendingFields',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pendingFields',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pendingFields',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pendingFields',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pendingFields',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pendingFieldsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'pendingFields',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      persistenceEqualTo(NotificationPersistence value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'persistence',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      persistenceGreaterThan(
    NotificationPersistence value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'persistence',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      persistenceLessThan(
    NotificationPersistence value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'persistence',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      persistenceBetween(
    NotificationPersistence lower,
    NotificationPersistence upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'persistence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      priorityEqualTo(NotificationPriority value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      priorityGreaterThan(
    NotificationPriority value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      priorityLessThan(
    NotificationPriority value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      priorityBetween(
    NotificationPriority lower,
    NotificationPriority upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pushDeliveryStatusEqualTo(NotificationDeliveryStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pushDeliveryStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pushDeliveryStatusGreaterThan(
    NotificationDeliveryStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pushDeliveryStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pushDeliveryStatusLessThan(
    NotificationDeliveryStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pushDeliveryStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      pushDeliveryStatusBetween(
    NotificationDeliveryStatus lower,
    NotificationDeliveryStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pushDeliveryStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      readAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'readAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      readAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'readAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      readAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'readAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      readAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'readAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      readAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'readAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      readAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'readAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientRoleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recipientRole',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientRoleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recipientRole',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientRoleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipientRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientRoleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recipientRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientRoleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recipientRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientRoleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recipientRole',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientRoleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recipientRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientRoleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recipientRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientRoleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recipientRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientRoleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recipientRole',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientRoleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipientRole',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientRoleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recipientRole',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientUserIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipientUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientUserIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recipientUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientUserIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recipientUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientUserIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recipientUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientUserIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recipientUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientUserIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recipientUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientUserIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recipientUserId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientUserIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recipientUserId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientUserIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipientUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      recipientUserIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recipientUserId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedClassNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'relatedClassName',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedClassNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'relatedClassName',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedClassNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedClassName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedClassNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relatedClassName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedClassNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relatedClassName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedClassNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relatedClassName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedClassNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relatedClassName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedClassNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relatedClassName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedClassNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relatedClassName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedClassNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relatedClassName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedClassNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedClassName',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedClassNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relatedClassName',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedConversationIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'relatedConversationId',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedConversationIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'relatedConversationId',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedConversationIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedConversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedConversationIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relatedConversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedConversationIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relatedConversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedConversationIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relatedConversationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedConversationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relatedConversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedConversationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relatedConversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedConversationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relatedConversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedConversationIdMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relatedConversationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedConversationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedConversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedConversationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relatedConversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedParentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'relatedParentId',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedParentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'relatedParentId',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedParentIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedParentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedParentIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relatedParentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedParentIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relatedParentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedParentIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relatedParentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedParentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relatedParentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedParentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relatedParentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedParentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relatedParentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedParentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relatedParentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedParentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedParentId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedParentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relatedParentId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStaffIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'relatedStaffId',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStaffIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'relatedStaffId',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStaffIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStaffIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relatedStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStaffIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relatedStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStaffIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relatedStaffId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStaffIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relatedStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStaffIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relatedStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStaffIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relatedStaffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStaffIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relatedStaffId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStaffIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedStaffId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStaffIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relatedStaffId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'relatedStudentId',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'relatedStudentId',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedStudentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relatedStudentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relatedStudentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relatedStudentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relatedStudentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relatedStudentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relatedStudentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relatedStudentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedStudentId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relatedStudentId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'relatedStudentName',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'relatedStudentName',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedStudentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relatedStudentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relatedStudentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relatedStudentName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relatedStudentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relatedStudentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relatedStudentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relatedStudentName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relatedStudentName',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      relatedStudentNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relatedStudentName',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      requiresAcknowledgmentEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requiresAcknowledgment',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      scheduledAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'scheduledAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      scheduledAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'scheduledAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      scheduledAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      scheduledAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scheduledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      scheduledAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scheduledAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      scheduledAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scheduledAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderAvatarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'senderAvatar',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderAvatarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'senderAvatar',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderAvatarContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderAvatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderAvatarMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderAvatar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderAvatarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderAvatar',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderAvatarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderAvatar',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderDepartmentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'senderDepartment',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderDepartmentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'senderDepartment',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderDepartmentEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderDepartment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderDepartmentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderDepartment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderDepartmentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderDepartment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderDepartmentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderDepartment',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderDepartmentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderDepartment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderDepartmentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderDepartment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderDepartmentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderDepartment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderDepartmentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderDepartment',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderDepartmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderDepartment',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderDepartmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderDepartment',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'senderId',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'senderId',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderIdEqualTo(
    String? value, {
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderIdGreaterThan(
    String? value, {
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderIdLessThan(
    String? value, {
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderKindEqualTo(NotificationSourceKind value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderKind',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderKindGreaterThan(
    NotificationSourceKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderKind',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderKindLessThan(
    NotificationSourceKind value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderKind',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderKindBetween(
    NotificationSourceKind lower,
    NotificationSourceKind upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderKind',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderLocalPhotoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'senderLocalPhotoPath',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderLocalPhotoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'senderLocalPhotoPath',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderLocalPhotoPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderLocalPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderLocalPhotoPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderLocalPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderLocalPhotoPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderLocalPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderLocalPhotoPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderLocalPhotoPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderLocalPhotoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderLocalPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderLocalPhotoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderLocalPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderLocalPhotoPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderLocalPhotoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderLocalPhotoPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderLocalPhotoPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderLocalPhotoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderLocalPhotoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderLocalPhotoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderLocalPhotoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderName',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderName',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderRoleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderRoleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'senderRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderRoleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'senderRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderRoleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'senderRole',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderRoleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'senderRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderRoleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'senderRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderRoleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'senderRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderRoleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'senderRole',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderRoleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'senderRole',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      senderRoleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'senderRole',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sentAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sentAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sentAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sentAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sentAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sentAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sentAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sentAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sentAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sentAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sentAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sentAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceEntityIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceEntityId',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceEntityIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceEntityId',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceEntityIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceEntityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceEntityIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceEntityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceEntityIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceEntityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceEntityIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceEntityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceEntityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceEntityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceEntityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceEntityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceEntityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceEntityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceEntityIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceEntityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceEntityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceEntityId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceEntityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceEntityId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceModuleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceModule',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceModuleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceModule',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceModuleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceModule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceModuleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceModule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceModuleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceModule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceModuleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceModule',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceModuleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceModule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceModuleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceModule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceModuleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceModule',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceModuleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceModule',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceModuleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceModule',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      sourceModuleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceModule',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      statusEqualTo(NotificationStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      statusGreaterThan(
    NotificationStatus value, {
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      statusLessThan(
    NotificationStatus value, {
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      statusBetween(
    NotificationStatus lower,
    NotificationStatus upper, {
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      syncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      syncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      syncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      syncedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      syncedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      syncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      thumbnailUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'thumbnailUrl',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      thumbnailUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'thumbnailUrl',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      thumbnailUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      thumbnailUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      thumbnailUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      thumbnailUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'thumbnailUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      thumbnailUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      thumbnailUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      thumbnailUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'thumbnailUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      thumbnailUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'thumbnailUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      thumbnailUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'thumbnailUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      thumbnailUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'thumbnailUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      triggerReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'triggerReason',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      triggerReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'triggerReason',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      triggerReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      triggerReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'triggerReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      triggerReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'triggerReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      triggerReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'triggerReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      triggerReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'triggerReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      triggerReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'triggerReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      triggerReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'triggerReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      triggerReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'triggerReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      triggerReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerReason',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      triggerReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'triggerReason',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      typeEqualTo(NotificationType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      typeGreaterThan(
    NotificationType value, {
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      typeLessThan(
    NotificationType value, {
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

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      typeBetween(
    NotificationType lower,
    NotificationType upper, {
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

extension NotificationIsarQueryObject
    on QueryBuilder<NotificationIsar, NotificationIsar, QFilterCondition> {
  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      actionsElement(FilterQuery<NotificationActionIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'actions');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterFilterCondition>
      attachmentsElement(FilterQuery<NotificationAttachmentIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'attachments');
    });
  }
}

extension NotificationIsarQueryLinks
    on QueryBuilder<NotificationIsar, NotificationIsar, QFilterCondition> {}

extension NotificationIsarQuerySortBy
    on QueryBuilder<NotificationIsar, NotificationIsar, QSortBy> {
  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByAcknowledgedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acknowledgedAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByAcknowledgedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acknowledgedAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByBannerImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bannerImageUrl', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByBannerImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bannerImageUrl', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByDeepLinkRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepLinkRoute', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByDeepLinkRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepLinkRoute', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByDeliveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveredAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByDeliveredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveredAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByFailureReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureReason', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByFailureReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureReason', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByHasPendingStateChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPendingStateChange', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByHasPendingStateChangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPendingStateChange', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByLocalDeliveryStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localDeliveryStatus', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByLocalDeliveryStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localDeliveryStatus', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByLocalImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localImagePath', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByLocalImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localImagePath', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByLongMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longMessage', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByLongMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longMessage', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByNotificationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByNotificationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openedAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByOpenedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openedAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByPersistence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'persistence', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByPersistenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'persistence', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByPushDeliveryStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pushDeliveryStatus', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByPushDeliveryStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pushDeliveryStatus', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByReadAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRecipientRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientRole', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRecipientRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientRole', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRecipientUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientUserId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRecipientUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientUserId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRelatedClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedClassName', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRelatedClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedClassName', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRelatedConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedConversationId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRelatedConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedConversationId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRelatedParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedParentId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRelatedParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedParentId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRelatedStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedStaffId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRelatedStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedStaffId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRelatedStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedStudentId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRelatedStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedStudentId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRelatedStudentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedStudentName', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRelatedStudentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedStudentName', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRequiresAcknowledgment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresAcknowledgment', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByRequiresAcknowledgmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresAcknowledgment', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByScheduledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByScheduledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySenderAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAvatar', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySenderAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAvatar', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySenderDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderDepartment', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySenderDepartmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderDepartment', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySenderKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderKind', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySenderKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderKind', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySenderLocalPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderLocalPhotoPath', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySenderLocalPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderLocalPhotoPath', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySenderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySenderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySenderRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderRole', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySenderRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderRole', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySentAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySentAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySourceEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceEntityId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySourceEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceEntityId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySourceModule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceModule', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySourceModuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceModule', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByTriggerReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerReason', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByTriggerReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerReason', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension NotificationIsarQuerySortThenBy
    on QueryBuilder<NotificationIsar, NotificationIsar, QSortThenBy> {
  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByAcknowledgedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acknowledgedAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByAcknowledgedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'acknowledgedAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByBannerImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bannerImageUrl', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByBannerImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bannerImageUrl', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByCampusId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByCampusIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campusId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByDeepLinkRoute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepLinkRoute', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByDeepLinkRouteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deepLinkRoute', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByDeliveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveredAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByDeliveredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveredAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByFailureReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureReason', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByFailureReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failureReason', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByHasPendingStateChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPendingStateChange', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByHasPendingStateChangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPendingStateChange', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByIsArchivedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isArchived', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByLocalDeliveryStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localDeliveryStatus', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByLocalDeliveryStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localDeliveryStatus', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByLocalImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localImagePath', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByLocalImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localImagePath', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByLongMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longMessage', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByLongMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longMessage', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByNotificationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByNotificationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openedAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByOpenedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'openedAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByPersistence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'persistence', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByPersistenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'persistence', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByPushDeliveryStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pushDeliveryStatus', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByPushDeliveryStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pushDeliveryStatus', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByReadAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'readAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRecipientRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientRole', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRecipientRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientRole', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRecipientUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientUserId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRecipientUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientUserId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRelatedClassName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedClassName', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRelatedClassNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedClassName', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRelatedConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedConversationId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRelatedConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedConversationId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRelatedParentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedParentId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRelatedParentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedParentId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRelatedStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedStaffId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRelatedStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedStaffId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRelatedStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedStudentId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRelatedStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedStudentId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRelatedStudentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedStudentName', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRelatedStudentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relatedStudentName', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRequiresAcknowledgment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresAcknowledgment', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByRequiresAcknowledgmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiresAcknowledgment', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByScheduledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByScheduledAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySenderAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAvatar', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySenderAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderAvatar', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySenderDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderDepartment', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySenderDepartmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderDepartment', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySenderKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderKind', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySenderKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderKind', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySenderLocalPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderLocalPhotoPath', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySenderLocalPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderLocalPhotoPath', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySenderName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySenderNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderName', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySenderRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderRole', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySenderRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderRole', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySentAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySentAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sentAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySourceEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceEntityId', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySourceEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceEntityId', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySourceModule() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceModule', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySourceModuleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceModule', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByTriggerReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerReason', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByTriggerReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerReason', Sort.desc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension NotificationIsarQueryWhereDistinct
    on QueryBuilder<NotificationIsar, NotificationIsar, QDistinct> {
  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByAcknowledgedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'acknowledgedAt');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByBannerImageUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bannerImageUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByCampusId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'campusId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByDeepLinkParamKeys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deepLinkParamKeys');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByDeepLinkParamValues() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deepLinkParamValues');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByDeepLinkRoute({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deepLinkRoute',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByDeliveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deliveredAt');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresAt');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByFailureReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failureReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByHasPendingStateChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasPendingStateChange');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByIsArchived() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isArchived');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByLocalDeliveryStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localDeliveryStatus');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByLocalImagePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByLongMessage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longMessage', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByMetadataKeys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metadataKeys');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByMetadataValues() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metadataValues');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByNotificationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByOpenedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'openedAt');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByPendingFields() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingFields');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByPersistence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'persistence');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByPushDeliveryStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pushDeliveryStatus');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'readAt');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByRecipientRole({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recipientRole',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByRecipientUserId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recipientUserId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByRelatedClassName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relatedClassName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByRelatedConversationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relatedConversationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByRelatedParentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relatedParentId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByRelatedStaffId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relatedStaffId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByRelatedStudentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relatedStudentId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByRelatedStudentName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relatedStudentName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByRequiresAcknowledgment() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requiresAcknowledgment');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByScheduledAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledAt');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctBySenderAvatar({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderAvatar', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctBySenderDepartment({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderDepartment',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctBySenderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctBySenderKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderKind');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctBySenderLocalPhotoPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderLocalPhotoPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctBySenderName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctBySenderRole({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderRole', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctBySentAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sentAt');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctBySourceEntityId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceEntityId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctBySourceModule({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceModule', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedAt');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByThumbnailUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnailUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct>
      distinctByTriggerReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggerReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NotificationIsar, NotificationIsar, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension NotificationIsarQueryProperty
    on QueryBuilder<NotificationIsar, NotificationIsar, QQueryProperty> {
  QueryBuilder<NotificationIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NotificationIsar, DateTime?, QQueryOperations>
      acknowledgedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'acknowledgedAt');
    });
  }

  QueryBuilder<NotificationIsar, List<NotificationActionIsar>, QQueryOperations>
      actionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actions');
    });
  }

  QueryBuilder<NotificationIsar, List<NotificationAttachmentIsar>,
      QQueryOperations> attachmentsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attachments');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      bannerImageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bannerImageUrl');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations> campusIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campusId');
    });
  }

  QueryBuilder<NotificationIsar, NotificationCategory, QQueryOperations>
      categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<NotificationIsar, List<String>, QQueryOperations>
      deepLinkParamKeysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deepLinkParamKeys');
    });
  }

  QueryBuilder<NotificationIsar, List<String>, QQueryOperations>
      deepLinkParamValuesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deepLinkParamValues');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      deepLinkRouteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deepLinkRoute');
    });
  }

  QueryBuilder<NotificationIsar, DateTime?, QQueryOperations>
      deliveredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deliveredAt');
    });
  }

  QueryBuilder<NotificationIsar, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<NotificationIsar, DateTime?, QQueryOperations>
      expiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresAt');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      failureReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failureReason');
    });
  }

  QueryBuilder<NotificationIsar, bool, QQueryOperations>
      hasPendingStateChangeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasPendingStateChange');
    });
  }

  QueryBuilder<NotificationIsar, bool, QQueryOperations> isArchivedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isArchived');
    });
  }

  QueryBuilder<NotificationIsar, NotificationDeliveryStatus, QQueryOperations>
      localDeliveryStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localDeliveryStatus');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      localImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localImagePath');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      longMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longMessage');
    });
  }

  QueryBuilder<NotificationIsar, List<String>, QQueryOperations>
      metadataKeysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadataKeys');
    });
  }

  QueryBuilder<NotificationIsar, List<String>, QQueryOperations>
      metadataValuesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadataValues');
    });
  }

  QueryBuilder<NotificationIsar, String, QQueryOperations>
      notificationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationId');
    });
  }

  QueryBuilder<NotificationIsar, DateTime?, QQueryOperations>
      openedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'openedAt');
    });
  }

  QueryBuilder<NotificationIsar, List<String>, QQueryOperations>
      pendingFieldsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingFields');
    });
  }

  QueryBuilder<NotificationIsar, NotificationPersistence, QQueryOperations>
      persistenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'persistence');
    });
  }

  QueryBuilder<NotificationIsar, NotificationPriority, QQueryOperations>
      priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<NotificationIsar, NotificationDeliveryStatus, QQueryOperations>
      pushDeliveryStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pushDeliveryStatus');
    });
  }

  QueryBuilder<NotificationIsar, DateTime?, QQueryOperations> readAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'readAt');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      recipientRoleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recipientRole');
    });
  }

  QueryBuilder<NotificationIsar, String, QQueryOperations>
      recipientUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recipientUserId');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      relatedClassNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relatedClassName');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      relatedConversationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relatedConversationId');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      relatedParentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relatedParentId');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      relatedStaffIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relatedStaffId');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      relatedStudentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relatedStudentId');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      relatedStudentNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relatedStudentName');
    });
  }

  QueryBuilder<NotificationIsar, bool, QQueryOperations>
      requiresAcknowledgmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requiresAcknowledgment');
    });
  }

  QueryBuilder<NotificationIsar, DateTime?, QQueryOperations>
      scheduledAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledAt');
    });
  }

  QueryBuilder<NotificationIsar, String, QQueryOperations> schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      senderAvatarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderAvatar');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      senderDepartmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderDepartment');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations> senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }

  QueryBuilder<NotificationIsar, NotificationSourceKind, QQueryOperations>
      senderKindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderKind');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      senderLocalPhotoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderLocalPhotoPath');
    });
  }

  QueryBuilder<NotificationIsar, String, QQueryOperations>
      senderNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderName');
    });
  }

  QueryBuilder<NotificationIsar, String, QQueryOperations>
      senderRoleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderRole');
    });
  }

  QueryBuilder<NotificationIsar, DateTime?, QQueryOperations> sentAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sentAt');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      sourceEntityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceEntityId');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      sourceModuleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceModule');
    });
  }

  QueryBuilder<NotificationIsar, NotificationStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<NotificationIsar, DateTime?, QQueryOperations>
      syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedAt');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      thumbnailUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnailUrl');
    });
  }

  QueryBuilder<NotificationIsar, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<NotificationIsar, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<NotificationIsar, String?, QQueryOperations>
      triggerReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggerReason');
    });
  }

  QueryBuilder<NotificationIsar, NotificationType, QQueryOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const NotificationActionIsarSchema = Schema(
  name: r'NotificationActionIsar',
  id: -1870485809819929681,
  properties: {
    r'actionId': PropertySchema(
      id: 0,
      name: r'actionId',
      type: IsarType.string,
    ),
    r'deepLinkRoute': PropertySchema(
      id: 1,
      name: r'deepLinkRoute',
      type: IsarType.string,
    ),
    r'isAcknowledgement': PropertySchema(
      id: 2,
      name: r'isAcknowledgement',
      type: IsarType.bool,
    ),
    r'label': PropertySchema(
      id: 3,
      name: r'label',
      type: IsarType.string,
    ),
    r'paramKeys': PropertySchema(
      id: 4,
      name: r'paramKeys',
      type: IsarType.stringList,
    ),
    r'paramValues': PropertySchema(
      id: 5,
      name: r'paramValues',
      type: IsarType.stringList,
    ),
    r'requiredPermission': PropertySchema(
      id: 6,
      name: r'requiredPermission',
      type: IsarType.string,
    )
  },
  estimateSize: _notificationActionIsarEstimateSize,
  serialize: _notificationActionIsarSerialize,
  deserialize: _notificationActionIsarDeserialize,
  deserializeProp: _notificationActionIsarDeserializeProp,
);

int _notificationActionIsarEstimateSize(
  NotificationActionIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.actionId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.deepLinkRoute;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.label;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.paramKeys.length * 3;
  {
    for (var i = 0; i < object.paramKeys.length; i++) {
      final value = object.paramKeys[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.paramValues.length * 3;
  {
    for (var i = 0; i < object.paramValues.length; i++) {
      final value = object.paramValues[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.requiredPermission;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _notificationActionIsarSerialize(
  NotificationActionIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.actionId);
  writer.writeString(offsets[1], object.deepLinkRoute);
  writer.writeBool(offsets[2], object.isAcknowledgement);
  writer.writeString(offsets[3], object.label);
  writer.writeStringList(offsets[4], object.paramKeys);
  writer.writeStringList(offsets[5], object.paramValues);
  writer.writeString(offsets[6], object.requiredPermission);
}

NotificationActionIsar _notificationActionIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NotificationActionIsar();
  object.actionId = reader.readStringOrNull(offsets[0]);
  object.deepLinkRoute = reader.readStringOrNull(offsets[1]);
  object.isAcknowledgement = reader.readBool(offsets[2]);
  object.label = reader.readStringOrNull(offsets[3]);
  object.paramKeys = reader.readStringList(offsets[4]) ?? [];
  object.paramValues = reader.readStringList(offsets[5]) ?? [];
  object.requiredPermission = reader.readStringOrNull(offsets[6]);
  return object;
}

P _notificationActionIsarDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension NotificationActionIsarQueryFilter on QueryBuilder<
    NotificationActionIsar, NotificationActionIsar, QFilterCondition> {
  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> actionIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actionId',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> actionIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actionId',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> actionIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> actionIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> actionIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> actionIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> actionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> actionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
          QAfterFilterCondition>
      actionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
          QAfterFilterCondition>
      actionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> actionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> actionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actionId',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> deepLinkRouteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deepLinkRoute',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> deepLinkRouteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deepLinkRoute',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> deepLinkRouteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deepLinkRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> deepLinkRouteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deepLinkRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> deepLinkRouteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deepLinkRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> deepLinkRouteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deepLinkRoute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> deepLinkRouteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deepLinkRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> deepLinkRouteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deepLinkRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
          QAfterFilterCondition>
      deepLinkRouteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deepLinkRoute',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
          QAfterFilterCondition>
      deepLinkRouteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deepLinkRoute',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> deepLinkRouteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deepLinkRoute',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> deepLinkRouteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deepLinkRoute',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> isAcknowledgementEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAcknowledgement',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> labelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'label',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> labelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'label',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> labelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> labelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> labelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> labelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
          QAfterFilterCondition>
      labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
          QAfterFilterCondition>
      labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramKeysElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paramKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramKeysElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paramKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramKeysElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paramKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramKeysElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paramKeys',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramKeysElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paramKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramKeysElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paramKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
          QAfterFilterCondition>
      paramKeysElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paramKeys',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
          QAfterFilterCondition>
      paramKeysElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paramKeys',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramKeysElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paramKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramKeysElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paramKeys',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramKeysLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paramKeys',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramKeysIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paramKeys',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramKeysIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paramKeys',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramKeysLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paramKeys',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramKeysLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paramKeys',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramKeysLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paramKeys',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramValuesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paramValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramValuesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paramValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramValuesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paramValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramValuesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paramValues',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramValuesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paramValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramValuesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paramValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
          QAfterFilterCondition>
      paramValuesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paramValues',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
          QAfterFilterCondition>
      paramValuesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paramValues',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramValuesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paramValues',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramValuesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paramValues',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramValuesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paramValues',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramValuesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paramValues',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramValuesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paramValues',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramValuesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paramValues',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramValuesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paramValues',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> paramValuesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'paramValues',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> requiredPermissionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'requiredPermission',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> requiredPermissionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'requiredPermission',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> requiredPermissionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requiredPermission',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> requiredPermissionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requiredPermission',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> requiredPermissionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requiredPermission',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> requiredPermissionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requiredPermission',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> requiredPermissionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requiredPermission',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> requiredPermissionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requiredPermission',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
          QAfterFilterCondition>
      requiredPermissionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requiredPermission',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
          QAfterFilterCondition>
      requiredPermissionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requiredPermission',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> requiredPermissionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requiredPermission',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationActionIsar, NotificationActionIsar,
      QAfterFilterCondition> requiredPermissionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requiredPermission',
        value: '',
      ));
    });
  }
}

extension NotificationActionIsarQueryObject on QueryBuilder<
    NotificationActionIsar, NotificationActionIsar, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const NotificationAttachmentIsarSchema = Schema(
  name: r'NotificationAttachmentIsar',
  id: -2850841612303332976,
  properties: {
    r'localPath': PropertySchema(
      id: 0,
      name: r'localPath',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    ),
    r'size': PropertySchema(
      id: 2,
      name: r'size',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 3,
      name: r'type',
      type: IsarType.string,
    ),
    r'url': PropertySchema(
      id: 4,
      name: r'url',
      type: IsarType.string,
    )
  },
  estimateSize: _notificationAttachmentIsarEstimateSize,
  serialize: _notificationAttachmentIsarSerialize,
  deserialize: _notificationAttachmentIsarDeserialize,
  deserializeProp: _notificationAttachmentIsarDeserializeProp,
);

int _notificationAttachmentIsarEstimateSize(
  NotificationAttachmentIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.localPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.size;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.type;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.url;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _notificationAttachmentIsarSerialize(
  NotificationAttachmentIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.localPath);
  writer.writeString(offsets[1], object.name);
  writer.writeString(offsets[2], object.size);
  writer.writeString(offsets[3], object.type);
  writer.writeString(offsets[4], object.url);
}

NotificationAttachmentIsar _notificationAttachmentIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NotificationAttachmentIsar();
  object.localPath = reader.readStringOrNull(offsets[0]);
  object.name = reader.readStringOrNull(offsets[1]);
  object.size = reader.readStringOrNull(offsets[2]);
  object.type = reader.readStringOrNull(offsets[3]);
  object.url = reader.readStringOrNull(offsets[4]);
  return object;
}

P _notificationAttachmentIsarDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension NotificationAttachmentIsarQueryFilter on QueryBuilder<
    NotificationAttachmentIsar, NotificationAttachmentIsar, QFilterCondition> {
  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> localPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localPath',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> localPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localPath',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> localPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> localPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> localPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> localPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> localPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> localPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
          QAfterFilterCondition>
      localPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
          QAfterFilterCondition>
      localPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> localPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localPath',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> localPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localPath',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> nameEqualTo(
    String? value, {
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

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> nameGreaterThan(
    String? value, {
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

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> nameLessThan(
    String? value, {
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

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
          QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
          QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> sizeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'size',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> sizeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'size',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> sizeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'size',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> sizeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'size',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> sizeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'size',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> sizeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'size',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> sizeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'size',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> sizeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'size',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
          QAfterFilterCondition>
      sizeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'size',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
          QAfterFilterCondition>
      sizeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'size',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> sizeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'size',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> sizeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'size',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> typeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'type',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> typeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'type',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> typeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> typeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> typeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> typeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
          QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
          QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> urlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'url',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> urlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'url',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> urlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> urlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> urlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> urlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
          QAfterFilterCondition>
      urlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
          QAfterFilterCondition>
      urlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<NotificationAttachmentIsar, NotificationAttachmentIsar,
      QAfterFilterCondition> urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }
}

extension NotificationAttachmentIsarQueryObject on QueryBuilder<
    NotificationAttachmentIsar, NotificationAttachmentIsar, QFilterCondition> {}
