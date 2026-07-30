// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitor_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVisitorIsarCollection on Isar {
  IsarCollection<VisitorIsar> get visitorIsars => this.collection();
}

const VisitorIsarSchema = CollectionSchema(
  name: r'VisitorIsar',
  id: 6376953885469084797,
  properties: {
    r'agreementAccepted': PropertySchema(
      id: 0,
      name: r'agreementAccepted',
      type: IsarType.bool,
    ),
    r'approvalStatus': PropertySchema(
      id: 1,
      name: r'approvalStatus',
      type: IsarType.byte,
      enumMap: _VisitorIsarapprovalStatusEnumValueMap,
    ),
    r'arrivalTime': PropertySchema(
      id: 2,
      name: r'arrivalTime',
      type: IsarType.dateTime,
    ),
    r'badgeNumber': PropertySchema(
      id: 3,
      name: r'badgeNumber',
      type: IsarType.string,
    ),
    r'badgeReplacementCount': PropertySchema(
      id: 4,
      name: r'badgeReplacementCount',
      type: IsarType.long,
    ),
    r'category': PropertySchema(
      id: 5,
      name: r'category',
      type: IsarType.byte,
      enumMap: _VisitorIsarcategoryEnumValueMap,
    ),
    r'company': PropertySchema(
      id: 6,
      name: r'company',
      type: IsarType.string,
    ),
    r'department': PropertySchema(
      id: 7,
      name: r'department',
      type: IsarType.string,
    ),
    r'departureTime': PropertySchema(
      id: 8,
      name: r'departureTime',
      type: IsarType.dateTime,
    ),
    r'deviceId': PropertySchema(
      id: 9,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'expectedDepartureTime': PropertySchema(
      id: 10,
      name: r'expectedDepartureTime',
      type: IsarType.dateTime,
    ),
    r'expectedDuration': PropertySchema(
      id: 11,
      name: r'expectedDuration',
      type: IsarType.string,
    ),
    r'fullName': PropertySchema(
      id: 12,
      name: r'fullName',
      type: IsarType.string,
    ),
    r'gateId': PropertySchema(
      id: 13,
      name: r'gateId',
      type: IsarType.string,
    ),
    r'gender': PropertySchema(
      id: 14,
      name: r'gender',
      type: IsarType.string,
    ),
    r'host': PropertySchema(
      id: 15,
      name: r'host',
      type: IsarType.string,
    ),
    r'hostId': PropertySchema(
      id: 16,
      name: r'hostId',
      type: IsarType.string,
    ),
    r'idImageLocalPath': PropertySchema(
      id: 17,
      name: r'idImageLocalPath',
      type: IsarType.string,
    ),
    r'idImageUrl': PropertySchema(
      id: 18,
      name: r'idImageUrl',
      type: IsarType.string,
    ),
    r'isBlacklisted': PropertySchema(
      id: 19,
      name: r'isBlacklisted',
      type: IsarType.bool,
    ),
    r'isSynced': PropertySchema(
      id: 20,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'itemsCarried': PropertySchema(
      id: 21,
      name: r'itemsCarried',
      type: IsarType.string,
    ),
    r'nationalId': PropertySchema(
      id: 22,
      name: r'nationalId',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 23,
      name: r'notes',
      type: IsarType.string,
    ),
    r'parkingSlot': PropertySchema(
      id: 24,
      name: r'parkingSlot',
      type: IsarType.string,
    ),
    r'phone': PropertySchema(
      id: 25,
      name: r'phone',
      type: IsarType.string,
    ),
    r'photoLocalPath': PropertySchema(
      id: 26,
      name: r'photoLocalPath',
      type: IsarType.string,
    ),
    r'photoUrl': PropertySchema(
      id: 27,
      name: r'photoUrl',
      type: IsarType.string,
    ),
    r'purpose': PropertySchema(
      id: 28,
      name: r'purpose',
      type: IsarType.string,
    ),
    r'scheduledVisitId': PropertySchema(
      id: 29,
      name: r'scheduledVisitId',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 30,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'signatureLocalPath': PropertySchema(
      id: 31,
      name: r'signatureLocalPath',
      type: IsarType.string,
    ),
    r'signatureUrl': PropertySchema(
      id: 32,
      name: r'signatureUrl',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 33,
      name: r'status',
      type: IsarType.byte,
      enumMap: _VisitorIsarstatusEnumValueMap,
    ),
    r'studentId': PropertySchema(
      id: 34,
      name: r'studentId',
      type: IsarType.string,
    ),
    r'vehicleNumber': PropertySchema(
      id: 35,
      name: r'vehicleNumber',
      type: IsarType.string,
    ),
    r'visitorId': PropertySchema(
      id: 36,
      name: r'visitorId',
      type: IsarType.string,
    )
  },
  estimateSize: _visitorIsarEstimateSize,
  serialize: _visitorIsarSerialize,
  deserialize: _visitorIsarDeserialize,
  deserializeProp: _visitorIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'visitorId': IndexSchema(
      id: -7466299045397464900,
      name: r'visitorId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'visitorId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _visitorIsarGetId,
  getLinks: _visitorIsarGetLinks,
  attach: _visitorIsarAttach,
  version: '3.1.0+1',
);

int _visitorIsarEstimateSize(
  VisitorIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.badgeNumber.length * 3;
  {
    final value = object.company;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.department.length * 3;
  bytesCount += 3 + object.deviceId.length * 3;
  {
    final value = object.expectedDuration;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.fullName.length * 3;
  {
    final value = object.gateId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.gender;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.host.length * 3;
  {
    final value = object.hostId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.idImageLocalPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.idImageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.itemsCarried;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.nationalId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.parkingSlot;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.phone.length * 3;
  {
    final value = object.photoLocalPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.photoUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.purpose.length * 3;
  {
    final value = object.scheduledVisitId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolId.length * 3;
  {
    final value = object.signatureLocalPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.signatureUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.studentId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.vehicleNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.visitorId.length * 3;
  return bytesCount;
}

void _visitorIsarSerialize(
  VisitorIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.agreementAccepted);
  writer.writeByte(offsets[1], object.approvalStatus.index);
  writer.writeDateTime(offsets[2], object.arrivalTime);
  writer.writeString(offsets[3], object.badgeNumber);
  writer.writeLong(offsets[4], object.badgeReplacementCount);
  writer.writeByte(offsets[5], object.category.index);
  writer.writeString(offsets[6], object.company);
  writer.writeString(offsets[7], object.department);
  writer.writeDateTime(offsets[8], object.departureTime);
  writer.writeString(offsets[9], object.deviceId);
  writer.writeDateTime(offsets[10], object.expectedDepartureTime);
  writer.writeString(offsets[11], object.expectedDuration);
  writer.writeString(offsets[12], object.fullName);
  writer.writeString(offsets[13], object.gateId);
  writer.writeString(offsets[14], object.gender);
  writer.writeString(offsets[15], object.host);
  writer.writeString(offsets[16], object.hostId);
  writer.writeString(offsets[17], object.idImageLocalPath);
  writer.writeString(offsets[18], object.idImageUrl);
  writer.writeBool(offsets[19], object.isBlacklisted);
  writer.writeBool(offsets[20], object.isSynced);
  writer.writeString(offsets[21], object.itemsCarried);
  writer.writeString(offsets[22], object.nationalId);
  writer.writeString(offsets[23], object.notes);
  writer.writeString(offsets[24], object.parkingSlot);
  writer.writeString(offsets[25], object.phone);
  writer.writeString(offsets[26], object.photoLocalPath);
  writer.writeString(offsets[27], object.photoUrl);
  writer.writeString(offsets[28], object.purpose);
  writer.writeString(offsets[29], object.scheduledVisitId);
  writer.writeString(offsets[30], object.schoolId);
  writer.writeString(offsets[31], object.signatureLocalPath);
  writer.writeString(offsets[32], object.signatureUrl);
  writer.writeByte(offsets[33], object.status.index);
  writer.writeString(offsets[34], object.studentId);
  writer.writeString(offsets[35], object.vehicleNumber);
  writer.writeString(offsets[36], object.visitorId);
}

VisitorIsar _visitorIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VisitorIsar();
  object.agreementAccepted = reader.readBool(offsets[0]);
  object.approvalStatus = _VisitorIsarapprovalStatusValueEnumMap[
          reader.readByteOrNull(offsets[1])] ??
      ApprovalStatus.pending;
  object.arrivalTime = reader.readDateTime(offsets[2]);
  object.badgeNumber = reader.readString(offsets[3]);
  object.badgeReplacementCount = reader.readLong(offsets[4]);
  object.category =
      _VisitorIsarcategoryValueEnumMap[reader.readByteOrNull(offsets[5])] ??
          VisitorCategory.parent;
  object.company = reader.readStringOrNull(offsets[6]);
  object.department = reader.readString(offsets[7]);
  object.departureTime = reader.readDateTimeOrNull(offsets[8]);
  object.deviceId = reader.readString(offsets[9]);
  object.expectedDepartureTime = reader.readDateTimeOrNull(offsets[10]);
  object.expectedDuration = reader.readStringOrNull(offsets[11]);
  object.fullName = reader.readString(offsets[12]);
  object.gateId = reader.readStringOrNull(offsets[13]);
  object.gender = reader.readStringOrNull(offsets[14]);
  object.host = reader.readString(offsets[15]);
  object.hostId = reader.readStringOrNull(offsets[16]);
  object.id = id;
  object.idImageLocalPath = reader.readStringOrNull(offsets[17]);
  object.idImageUrl = reader.readStringOrNull(offsets[18]);
  object.isBlacklisted = reader.readBool(offsets[19]);
  object.isSynced = reader.readBool(offsets[20]);
  object.itemsCarried = reader.readStringOrNull(offsets[21]);
  object.nationalId = reader.readStringOrNull(offsets[22]);
  object.notes = reader.readStringOrNull(offsets[23]);
  object.parkingSlot = reader.readStringOrNull(offsets[24]);
  object.phone = reader.readString(offsets[25]);
  object.photoLocalPath = reader.readStringOrNull(offsets[26]);
  object.photoUrl = reader.readStringOrNull(offsets[27]);
  object.purpose = reader.readString(offsets[28]);
  object.scheduledVisitId = reader.readStringOrNull(offsets[29]);
  object.schoolId = reader.readString(offsets[30]);
  object.signatureLocalPath = reader.readStringOrNull(offsets[31]);
  object.signatureUrl = reader.readStringOrNull(offsets[32]);
  object.status =
      _VisitorIsarstatusValueEnumMap[reader.readByteOrNull(offsets[33])] ??
          VisitorStatus.checkedIn;
  object.studentId = reader.readStringOrNull(offsets[34]);
  object.vehicleNumber = reader.readStringOrNull(offsets[35]);
  object.visitorId = reader.readString(offsets[36]);
  return object;
}

P _visitorIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (_VisitorIsarapprovalStatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ApprovalStatus.pending) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (_VisitorIsarcategoryValueEnumMap[reader.readByteOrNull(offset)] ??
          VisitorCategory.parent) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    case 30:
      return (reader.readString(offset)) as P;
    case 31:
      return (reader.readStringOrNull(offset)) as P;
    case 32:
      return (reader.readStringOrNull(offset)) as P;
    case 33:
      return (_VisitorIsarstatusValueEnumMap[reader.readByteOrNull(offset)] ??
          VisitorStatus.checkedIn) as P;
    case 34:
      return (reader.readStringOrNull(offset)) as P;
    case 35:
      return (reader.readStringOrNull(offset)) as P;
    case 36:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _VisitorIsarapprovalStatusEnumValueMap = {
  'pending': 0,
  'approved': 1,
  'rejected': 2,
  'notRequired': 3,
};
const _VisitorIsarapprovalStatusValueEnumMap = {
  0: ApprovalStatus.pending,
  1: ApprovalStatus.approved,
  2: ApprovalStatus.rejected,
  3: ApprovalStatus.notRequired,
};
const _VisitorIsarcategoryEnumValueMap = {
  'parent': 0,
  'vendor': 1,
  'official': 2,
  'contractor': 3,
  'personal': 4,
  'other': 5,
};
const _VisitorIsarcategoryValueEnumMap = {
  0: VisitorCategory.parent,
  1: VisitorCategory.vendor,
  2: VisitorCategory.official,
  3: VisitorCategory.contractor,
  4: VisitorCategory.personal,
  5: VisitorCategory.other,
};
const _VisitorIsarstatusEnumValueMap = {
  'checkedIn': 0,
  'checkedOut': 1,
};
const _VisitorIsarstatusValueEnumMap = {
  0: VisitorStatus.checkedIn,
  1: VisitorStatus.checkedOut,
};

Id _visitorIsarGetId(VisitorIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _visitorIsarGetLinks(VisitorIsar object) {
  return [];
}

void _visitorIsarAttach(
    IsarCollection<dynamic> col, Id id, VisitorIsar object) {
  object.id = id;
}

extension VisitorIsarByIndex on IsarCollection<VisitorIsar> {
  Future<VisitorIsar?> getByVisitorId(String visitorId) {
    return getByIndex(r'visitorId', [visitorId]);
  }

  VisitorIsar? getByVisitorIdSync(String visitorId) {
    return getByIndexSync(r'visitorId', [visitorId]);
  }

  Future<bool> deleteByVisitorId(String visitorId) {
    return deleteByIndex(r'visitorId', [visitorId]);
  }

  bool deleteByVisitorIdSync(String visitorId) {
    return deleteByIndexSync(r'visitorId', [visitorId]);
  }

  Future<List<VisitorIsar?>> getAllByVisitorId(List<String> visitorIdValues) {
    final values = visitorIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'visitorId', values);
  }

  List<VisitorIsar?> getAllByVisitorIdSync(List<String> visitorIdValues) {
    final values = visitorIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'visitorId', values);
  }

  Future<int> deleteAllByVisitorId(List<String> visitorIdValues) {
    final values = visitorIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'visitorId', values);
  }

  int deleteAllByVisitorIdSync(List<String> visitorIdValues) {
    final values = visitorIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'visitorId', values);
  }

  Future<Id> putByVisitorId(VisitorIsar object) {
    return putByIndex(r'visitorId', object);
  }

  Id putByVisitorIdSync(VisitorIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'visitorId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByVisitorId(List<VisitorIsar> objects) {
    return putAllByIndex(r'visitorId', objects);
  }

  List<Id> putAllByVisitorIdSync(List<VisitorIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'visitorId', objects, saveLinks: saveLinks);
  }
}

extension VisitorIsarQueryWhereSort
    on QueryBuilder<VisitorIsar, VisitorIsar, QWhere> {
  QueryBuilder<VisitorIsar, VisitorIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VisitorIsarQueryWhere
    on QueryBuilder<VisitorIsar, VisitorIsar, QWhereClause> {
  QueryBuilder<VisitorIsar, VisitorIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterWhereClause> visitorIdEqualTo(
      String visitorId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'visitorId',
        value: [visitorId],
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterWhereClause> visitorIdNotEqualTo(
      String visitorId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visitorId',
              lower: [],
              upper: [visitorId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visitorId',
              lower: [visitorId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visitorId',
              lower: [visitorId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visitorId',
              lower: [],
              upper: [visitorId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension VisitorIsarQueryFilter
    on QueryBuilder<VisitorIsar, VisitorIsar, QFilterCondition> {
  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      agreementAcceptedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'agreementAccepted',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      approvalStatusEqualTo(ApprovalStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'approvalStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      approvalStatusGreaterThan(
    ApprovalStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'approvalStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      approvalStatusLessThan(
    ApprovalStatus value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'approvalStatus',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      approvalStatusBetween(
    ApprovalStatus lower,
    ApprovalStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'approvalStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      arrivalTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'arrivalTime',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      arrivalTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'arrivalTime',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      arrivalTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'arrivalTime',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      arrivalTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'arrivalTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      badgeNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'badgeNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      badgeNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'badgeNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      badgeNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'badgeNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      badgeNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'badgeNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      badgeNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'badgeNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      badgeNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'badgeNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      badgeNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'badgeNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      badgeNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'badgeNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      badgeNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'badgeNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      badgeNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'badgeNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      badgeReplacementCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'badgeReplacementCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      badgeReplacementCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'badgeReplacementCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      badgeReplacementCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'badgeReplacementCount',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      badgeReplacementCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'badgeReplacementCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> categoryEqualTo(
      VisitorCategory value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      categoryGreaterThan(
    VisitorCategory value, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      categoryLessThan(
    VisitorCategory value, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> categoryBetween(
    VisitorCategory lower,
    VisitorCategory upper, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      companyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'company',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      companyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'company',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> companyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'company',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      companyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'company',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> companyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'company',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> companyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'company',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      companyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'company',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> companyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'company',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> companyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'company',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> companyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'company',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      companyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'company',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      companyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'company',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departmentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departmentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departmentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departmentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'department',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departmentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departmentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departmentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departmentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'department',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'department',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'department',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departureTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'departureTime',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departureTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'departureTime',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departureTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departureTime',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departureTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'departureTime',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departureTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'departureTime',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      departureTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'departureTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> deviceIdEqualTo(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      deviceIdGreaterThan(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      deviceIdLessThan(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> deviceIdBetween(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      deviceIdStartsWith(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      deviceIdEndsWith(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> deviceIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDepartureTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expectedDepartureTime',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDepartureTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expectedDepartureTime',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDepartureTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedDepartureTime',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDepartureTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedDepartureTime',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDepartureTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedDepartureTime',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDepartureTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedDepartureTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDurationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expectedDuration',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDurationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expectedDuration',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDurationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDurationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDurationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDurationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDurationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'expectedDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDurationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'expectedDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDurationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'expectedDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDurationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'expectedDuration',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDurationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedDuration',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      expectedDurationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'expectedDuration',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> fullNameEqualTo(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> fullNameBetween(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      fullNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> fullNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fullName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> gateIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gateId',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      gateIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gateId',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> gateIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      gateIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> gateIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> gateIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gateId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      gateIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> gateIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> gateIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gateId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> gateIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gateId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      gateIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gateId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      gateIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gateId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> genderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gender',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      genderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gender',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> genderEqualTo(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> genderLessThan(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> genderBetween(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> genderEndsWith(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> genderContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> genderMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gender',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      genderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      genderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostEqualTo(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostGreaterThan(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostLessThan(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostBetween(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostStartsWith(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostEndsWith(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'host',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'host',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'host',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      hostIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'host',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hostId',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      hostIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hostId',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostIdEqualTo(
    String? value, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      hostIdGreaterThan(
    String? value, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostIdLessThan(
    String? value, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostIdEndsWith(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hostId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> hostIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hostId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      hostIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hostId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      hostIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hostId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageLocalPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idImageLocalPath',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageLocalPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idImageLocalPath',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageLocalPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageLocalPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageLocalPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageLocalPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idImageLocalPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageLocalPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'idImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageLocalPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'idImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageLocalPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'idImageLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageLocalPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'idImageLocalPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageLocalPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idImageLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageLocalPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'idImageLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idImageUrl',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idImageUrl',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idImageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'idImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'idImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'idImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'idImageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      idImageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'idImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      isBlacklistedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBlacklisted',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> isSyncedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      itemsCarriedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'itemsCarried',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      itemsCarriedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'itemsCarried',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      itemsCarriedEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemsCarried',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      itemsCarriedGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemsCarried',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      itemsCarriedLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemsCarried',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      itemsCarriedBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemsCarried',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      itemsCarriedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemsCarried',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      itemsCarriedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemsCarried',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      itemsCarriedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemsCarried',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      itemsCarriedMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemsCarried',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      itemsCarriedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemsCarried',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      itemsCarriedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemsCarried',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      nationalIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nationalId',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      nationalIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nationalId',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      nationalIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nationalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      nationalIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nationalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      nationalIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nationalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      nationalIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nationalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      nationalIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nationalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      nationalIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nationalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      nationalIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nationalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      nationalIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nationalId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      nationalIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nationalId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      nationalIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nationalId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      parkingSlotIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parkingSlot',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      parkingSlotIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parkingSlot',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      parkingSlotEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parkingSlot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      parkingSlotGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parkingSlot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      parkingSlotLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parkingSlot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      parkingSlotBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parkingSlot',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      parkingSlotStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parkingSlot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      parkingSlotEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parkingSlot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      parkingSlotContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parkingSlot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      parkingSlotMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parkingSlot',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      parkingSlotIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parkingSlot',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      parkingSlotIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parkingSlot',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> phoneEqualTo(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> phoneLessThan(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> phoneBetween(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> phoneStartsWith(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> phoneEndsWith(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> phoneContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> phoneMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> phoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      phoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoLocalPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'photoLocalPath',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoLocalPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'photoLocalPath',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoLocalPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoLocalPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoLocalPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoLocalPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoLocalPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoLocalPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photoLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoLocalPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photoLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoLocalPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoLocalPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoLocalPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoLocalPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoLocalPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'photoUrl',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'photoUrl',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> photoUrlEqualTo(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> photoUrlBetween(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> photoUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      photoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> purposeEqualTo(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> purposeLessThan(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> purposeBetween(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> purposeEndsWith(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> purposeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'purpose',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> purposeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'purpose',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      purposeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purpose',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      purposeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'purpose',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      scheduledVisitIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'scheduledVisitId',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      scheduledVisitIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'scheduledVisitId',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      scheduledVisitIdEqualTo(
    String? value, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      scheduledVisitIdGreaterThan(
    String? value, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      scheduledVisitIdLessThan(
    String? value, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      scheduledVisitIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      scheduledVisitIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scheduledVisitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      scheduledVisitIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scheduledVisitId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      scheduledVisitIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scheduledVisitId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      scheduledVisitIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scheduledVisitId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> schoolIdEqualTo(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> schoolIdBetween(
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> schoolIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureLocalPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'signatureLocalPath',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureLocalPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'signatureLocalPath',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureLocalPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signatureLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureLocalPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'signatureLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureLocalPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'signatureLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureLocalPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'signatureLocalPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureLocalPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'signatureLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureLocalPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'signatureLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureLocalPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'signatureLocalPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureLocalPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'signatureLocalPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureLocalPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signatureLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureLocalPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'signatureLocalPath',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'signatureUrl',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'signatureUrl',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signatureUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'signatureUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'signatureUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'signatureUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'signatureUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'signatureUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'signatureUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'signatureUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'signatureUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      signatureUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'signatureUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> statusEqualTo(
      VisitorStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      statusGreaterThan(
    VisitorStatus value, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> statusLessThan(
    VisitorStatus value, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition> statusBetween(
    VisitorStatus lower,
    VisitorStatus upper, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      studentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'studentId',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      studentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'studentId',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      studentIdEqualTo(
    String? value, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      studentIdGreaterThan(
    String? value, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      studentIdLessThan(
    String? value, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      studentIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
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

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      studentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      studentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'studentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      studentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      studentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      vehicleNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'vehicleNumber',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      vehicleNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'vehicleNumber',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      vehicleNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      vehicleNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      vehicleNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      vehicleNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vehicleNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      vehicleNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      vehicleNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      vehicleNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vehicleNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      vehicleNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vehicleNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      vehicleNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vehicleNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      vehicleNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vehicleNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      visitorIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      visitorIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      visitorIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      visitorIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'visitorId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      visitorIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      visitorIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      visitorIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visitorId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      visitorIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visitorId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      visitorIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visitorId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterFilterCondition>
      visitorIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visitorId',
        value: '',
      ));
    });
  }
}

extension VisitorIsarQueryObject
    on QueryBuilder<VisitorIsar, VisitorIsar, QFilterCondition> {}

extension VisitorIsarQueryLinks
    on QueryBuilder<VisitorIsar, VisitorIsar, QFilterCondition> {}

extension VisitorIsarQuerySortBy
    on QueryBuilder<VisitorIsar, VisitorIsar, QSortBy> {
  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByAgreementAccepted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'agreementAccepted', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByAgreementAcceptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'agreementAccepted', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByApprovalStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvalStatus', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByApprovalStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvalStatus', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByArrivalTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arrivalTime', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByArrivalTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arrivalTime', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByBadgeNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeNumber', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByBadgeNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeNumber', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByBadgeReplacementCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeReplacementCount', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByBadgeReplacementCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeReplacementCount', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByCompany() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'company', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByCompanyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'company', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByDepartmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByDepartureTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departureTime', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByDepartureTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departureTime', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByExpectedDepartureTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDepartureTime', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByExpectedDepartureTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDepartureTime', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByExpectedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDuration', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByExpectedDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDuration', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByGateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByGateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByHost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByHostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByHostId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByHostIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostId', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByIdImageLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idImageLocalPath', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByIdImageLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idImageLocalPath', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByIdImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idImageUrl', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByIdImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idImageUrl', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByIsBlacklisted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBlacklisted', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByIsBlacklistedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBlacklisted', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByItemsCarried() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsCarried', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByItemsCarriedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsCarried', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByNationalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nationalId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByNationalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nationalId', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByParkingSlot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parkingSlot', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByParkingSlotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parkingSlot', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByPhotoLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoLocalPath', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByPhotoLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoLocalPath', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByScheduledVisitId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledVisitId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByScheduledVisitIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledVisitId', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortBySignatureLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureLocalPath', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortBySignatureLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureLocalPath', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortBySignatureUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureUrl', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortBySignatureUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureUrl', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByVehicleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      sortByVehicleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByVisitorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> sortByVisitorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorId', Sort.desc);
    });
  }
}

extension VisitorIsarQuerySortThenBy
    on QueryBuilder<VisitorIsar, VisitorIsar, QSortThenBy> {
  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByAgreementAccepted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'agreementAccepted', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByAgreementAcceptedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'agreementAccepted', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByApprovalStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvalStatus', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByApprovalStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'approvalStatus', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByArrivalTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arrivalTime', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByArrivalTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arrivalTime', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByBadgeNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeNumber', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByBadgeNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeNumber', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByBadgeReplacementCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeReplacementCount', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByBadgeReplacementCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'badgeReplacementCount', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByCompany() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'company', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByCompanyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'company', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByDepartmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByDepartureTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departureTime', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByDepartureTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departureTime', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByExpectedDepartureTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDepartureTime', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByExpectedDepartureTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDepartureTime', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByExpectedDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDuration', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByExpectedDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDuration', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByGateId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByGateIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gateId', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByHost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByHostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'host', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByHostId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByHostIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hostId', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByIdImageLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idImageLocalPath', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByIdImageLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idImageLocalPath', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByIdImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idImageUrl', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByIdImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idImageUrl', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByIsBlacklisted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBlacklisted', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByIsBlacklistedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBlacklisted', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByItemsCarried() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsCarried', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByItemsCarriedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsCarried', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByNationalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nationalId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByNationalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nationalId', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByParkingSlot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parkingSlot', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByParkingSlotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parkingSlot', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByPhotoLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoLocalPath', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByPhotoLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoLocalPath', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByPhotoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByPhotoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoUrl', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByPurpose() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByPurposeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purpose', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByScheduledVisitId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledVisitId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByScheduledVisitIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scheduledVisitId', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenBySignatureLocalPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureLocalPath', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenBySignatureLocalPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureLocalPath', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenBySignatureUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureUrl', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenBySignatureUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'signatureUrl', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByVehicleNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy>
      thenByVehicleNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vehicleNumber', Sort.desc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByVisitorId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorId', Sort.asc);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QAfterSortBy> thenByVisitorIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitorId', Sort.desc);
    });
  }
}

extension VisitorIsarQueryWhereDistinct
    on QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> {
  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct>
      distinctByAgreementAccepted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'agreementAccepted');
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByApprovalStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'approvalStatus');
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByArrivalTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'arrivalTime');
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByBadgeNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'badgeNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct>
      distinctByBadgeReplacementCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'badgeReplacementCount');
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category');
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByCompany(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'company', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByDepartment(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'department', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByDepartureTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'departureTime');
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct>
      distinctByExpectedDepartureTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedDepartureTime');
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByExpectedDuration(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedDuration',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByFullName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByGateId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gateId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByGender(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByHost(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'host', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByHostId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hostId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByIdImageLocalPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idImageLocalPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByIdImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idImageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByIsBlacklisted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBlacklisted');
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByItemsCarried(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemsCarried', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByNationalId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nationalId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByParkingSlot(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parkingSlot', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByPhone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByPhotoLocalPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoLocalPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByPhotoUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByPurpose(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purpose', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByScheduledVisitId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scheduledVisitId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctBySchoolId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct>
      distinctBySignatureLocalPath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signatureLocalPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctBySignatureUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'signatureUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByStudentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByVehicleNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vehicleNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisitorIsar, VisitorIsar, QDistinct> distinctByVisitorId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visitorId', caseSensitive: caseSensitive);
    });
  }
}

extension VisitorIsarQueryProperty
    on QueryBuilder<VisitorIsar, VisitorIsar, QQueryProperty> {
  QueryBuilder<VisitorIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VisitorIsar, bool, QQueryOperations>
      agreementAcceptedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'agreementAccepted');
    });
  }

  QueryBuilder<VisitorIsar, ApprovalStatus, QQueryOperations>
      approvalStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'approvalStatus');
    });
  }

  QueryBuilder<VisitorIsar, DateTime, QQueryOperations> arrivalTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'arrivalTime');
    });
  }

  QueryBuilder<VisitorIsar, String, QQueryOperations> badgeNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'badgeNumber');
    });
  }

  QueryBuilder<VisitorIsar, int, QQueryOperations>
      badgeReplacementCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'badgeReplacementCount');
    });
  }

  QueryBuilder<VisitorIsar, VisitorCategory, QQueryOperations>
      categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations> companyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'company');
    });
  }

  QueryBuilder<VisitorIsar, String, QQueryOperations> departmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'department');
    });
  }

  QueryBuilder<VisitorIsar, DateTime?, QQueryOperations>
      departureTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'departureTime');
    });
  }

  QueryBuilder<VisitorIsar, String, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<VisitorIsar, DateTime?, QQueryOperations>
      expectedDepartureTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedDepartureTime');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations>
      expectedDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedDuration');
    });
  }

  QueryBuilder<VisitorIsar, String, QQueryOperations> fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations> gateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gateId');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations> genderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gender');
    });
  }

  QueryBuilder<VisitorIsar, String, QQueryOperations> hostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'host');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations> hostIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hostId');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations>
      idImageLocalPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idImageLocalPath');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations> idImageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idImageUrl');
    });
  }

  QueryBuilder<VisitorIsar, bool, QQueryOperations> isBlacklistedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBlacklisted');
    });
  }

  QueryBuilder<VisitorIsar, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations> itemsCarriedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemsCarried');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations> nationalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nationalId');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations> parkingSlotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parkingSlot');
    });
  }

  QueryBuilder<VisitorIsar, String, QQueryOperations> phoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phone');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations>
      photoLocalPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoLocalPath');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations> photoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoUrl');
    });
  }

  QueryBuilder<VisitorIsar, String, QQueryOperations> purposeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purpose');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations>
      scheduledVisitIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scheduledVisitId');
    });
  }

  QueryBuilder<VisitorIsar, String, QQueryOperations> schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations>
      signatureLocalPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signatureLocalPath');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations> signatureUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'signatureUrl');
    });
  }

  QueryBuilder<VisitorIsar, VisitorStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations> studentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studentId');
    });
  }

  QueryBuilder<VisitorIsar, String?, QQueryOperations> vehicleNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vehicleNumber');
    });
  }

  QueryBuilder<VisitorIsar, String, QQueryOperations> visitorIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visitorId');
    });
  }
}
