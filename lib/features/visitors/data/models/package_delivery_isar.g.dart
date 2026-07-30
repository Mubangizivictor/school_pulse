// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_delivery_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPackageDeliveryIsarCollection on Isar {
  IsarCollection<PackageDeliveryIsar> get packageDeliveryIsars =>
      this.collection();
}

const PackageDeliveryIsarSchema = CollectionSchema(
  name: r'PackageDeliveryIsar',
  id: 5415793237113529997,
  properties: {
    r'arrivalTime': PropertySchema(
      id: 0,
      name: r'arrivalTime',
      type: IsarType.dateTime,
    ),
    r'collectedBy': PropertySchema(
      id: 1,
      name: r'collectedBy',
      type: IsarType.string,
    ),
    r'collectedTime': PropertySchema(
      id: 2,
      name: r'collectedTime',
      type: IsarType.dateTime,
    ),
    r'courierName': PropertySchema(
      id: 3,
      name: r'courierName',
      type: IsarType.string,
    ),
    r'courierPhone': PropertySchema(
      id: 4,
      name: r'courierPhone',
      type: IsarType.string,
    ),
    r'isCollected': PropertySchema(
      id: 5,
      name: r'isCollected',
      type: IsarType.bool,
    ),
    r'packageId': PropertySchema(
      id: 6,
      name: r'packageId',
      type: IsarType.string,
    ),
    r'recipientId': PropertySchema(
      id: 7,
      name: r'recipientId',
      type: IsarType.string,
    ),
    r'recipientName': PropertySchema(
      id: 8,
      name: r'recipientName',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 9,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'trackingNumber': PropertySchema(
      id: 10,
      name: r'trackingNumber',
      type: IsarType.string,
    )
  },
  estimateSize: _packageDeliveryIsarEstimateSize,
  serialize: _packageDeliveryIsarSerialize,
  deserialize: _packageDeliveryIsarDeserialize,
  deserializeProp: _packageDeliveryIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'packageId': IndexSchema(
      id: -6057482687381368049,
      name: r'packageId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'packageId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _packageDeliveryIsarGetId,
  getLinks: _packageDeliveryIsarGetLinks,
  attach: _packageDeliveryIsarAttach,
  version: '3.1.0+1',
);

int _packageDeliveryIsarEstimateSize(
  PackageDeliveryIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.collectedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.courierName.length * 3;
  {
    final value = object.courierPhone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.packageId.length * 3;
  {
    final value = object.recipientId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.recipientName.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  {
    final value = object.trackingNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _packageDeliveryIsarSerialize(
  PackageDeliveryIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.arrivalTime);
  writer.writeString(offsets[1], object.collectedBy);
  writer.writeDateTime(offsets[2], object.collectedTime);
  writer.writeString(offsets[3], object.courierName);
  writer.writeString(offsets[4], object.courierPhone);
  writer.writeBool(offsets[5], object.isCollected);
  writer.writeString(offsets[6], object.packageId);
  writer.writeString(offsets[7], object.recipientId);
  writer.writeString(offsets[8], object.recipientName);
  writer.writeString(offsets[9], object.schoolId);
  writer.writeString(offsets[10], object.trackingNumber);
}

PackageDeliveryIsar _packageDeliveryIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PackageDeliveryIsar();
  object.arrivalTime = reader.readDateTime(offsets[0]);
  object.collectedBy = reader.readStringOrNull(offsets[1]);
  object.collectedTime = reader.readDateTimeOrNull(offsets[2]);
  object.courierName = reader.readString(offsets[3]);
  object.courierPhone = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.isCollected = reader.readBool(offsets[5]);
  object.packageId = reader.readString(offsets[6]);
  object.recipientId = reader.readStringOrNull(offsets[7]);
  object.recipientName = reader.readString(offsets[8]);
  object.schoolId = reader.readString(offsets[9]);
  object.trackingNumber = reader.readStringOrNull(offsets[10]);
  return object;
}

P _packageDeliveryIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _packageDeliveryIsarGetId(PackageDeliveryIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _packageDeliveryIsarGetLinks(
    PackageDeliveryIsar object) {
  return [];
}

void _packageDeliveryIsarAttach(
    IsarCollection<dynamic> col, Id id, PackageDeliveryIsar object) {
  object.id = id;
}

extension PackageDeliveryIsarByIndex on IsarCollection<PackageDeliveryIsar> {
  Future<PackageDeliveryIsar?> getByPackageId(String packageId) {
    return getByIndex(r'packageId', [packageId]);
  }

  PackageDeliveryIsar? getByPackageIdSync(String packageId) {
    return getByIndexSync(r'packageId', [packageId]);
  }

  Future<bool> deleteByPackageId(String packageId) {
    return deleteByIndex(r'packageId', [packageId]);
  }

  bool deleteByPackageIdSync(String packageId) {
    return deleteByIndexSync(r'packageId', [packageId]);
  }

  Future<List<PackageDeliveryIsar?>> getAllByPackageId(
      List<String> packageIdValues) {
    final values = packageIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'packageId', values);
  }

  List<PackageDeliveryIsar?> getAllByPackageIdSync(
      List<String> packageIdValues) {
    final values = packageIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'packageId', values);
  }

  Future<int> deleteAllByPackageId(List<String> packageIdValues) {
    final values = packageIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'packageId', values);
  }

  int deleteAllByPackageIdSync(List<String> packageIdValues) {
    final values = packageIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'packageId', values);
  }

  Future<Id> putByPackageId(PackageDeliveryIsar object) {
    return putByIndex(r'packageId', object);
  }

  Id putByPackageIdSync(PackageDeliveryIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'packageId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPackageId(List<PackageDeliveryIsar> objects) {
    return putAllByIndex(r'packageId', objects);
  }

  List<Id> putAllByPackageIdSync(List<PackageDeliveryIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'packageId', objects, saveLinks: saveLinks);
  }
}

extension PackageDeliveryIsarQueryWhereSort
    on QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QWhere> {
  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PackageDeliveryIsarQueryWhere
    on QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QWhereClause> {
  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterWhereClause>
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

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterWhereClause>
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

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterWhereClause>
      packageIdEqualTo(String packageId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'packageId',
        value: [packageId],
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterWhereClause>
      packageIdNotEqualTo(String packageId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packageId',
              lower: [],
              upper: [packageId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packageId',
              lower: [packageId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packageId',
              lower: [packageId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'packageId',
              lower: [],
              upper: [packageId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PackageDeliveryIsarQueryFilter on QueryBuilder<PackageDeliveryIsar,
    PackageDeliveryIsar, QFilterCondition> {
  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      arrivalTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'arrivalTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
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

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
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

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
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

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'collectedBy',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'collectedBy',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedByEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collectedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collectedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collectedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'collectedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'collectedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'collectedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'collectedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'collectedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'collectedTime',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'collectedTime',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'collectedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'collectedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'collectedTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      collectedTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'collectedTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'courierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'courierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'courierName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'courierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'courierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'courierName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'courierName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courierName',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'courierName',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierPhoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'courierPhone',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierPhoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'courierPhone',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierPhoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courierPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierPhoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'courierPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierPhoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'courierPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierPhoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'courierPhone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierPhoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'courierPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierPhoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'courierPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierPhoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'courierPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierPhoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'courierPhone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierPhoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'courierPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      courierPhoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'courierPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
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

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
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

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
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

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      isCollectedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCollected',
        value: value,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      packageIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      packageIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'packageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      packageIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'packageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      packageIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'packageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      packageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'packageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      packageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'packageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      packageIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'packageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      packageIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'packageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      packageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'packageId',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      packageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'packageId',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'recipientId',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'recipientId',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recipientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recipientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recipientId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recipientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recipientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recipientId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recipientId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipientId',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recipientId',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recipientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recipientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recipientName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recipientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recipientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recipientName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recipientName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recipientName',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      recipientNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recipientName',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
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

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
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

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
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

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
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

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
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

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
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

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      trackingNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'trackingNumber',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      trackingNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'trackingNumber',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      trackingNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackingNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      trackingNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackingNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      trackingNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackingNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      trackingNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackingNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      trackingNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'trackingNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      trackingNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'trackingNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      trackingNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'trackingNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      trackingNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'trackingNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      trackingNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackingNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterFilterCondition>
      trackingNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'trackingNumber',
        value: '',
      ));
    });
  }
}

extension PackageDeliveryIsarQueryObject on QueryBuilder<PackageDeliveryIsar,
    PackageDeliveryIsar, QFilterCondition> {}

extension PackageDeliveryIsarQueryLinks on QueryBuilder<PackageDeliveryIsar,
    PackageDeliveryIsar, QFilterCondition> {}

extension PackageDeliveryIsarQuerySortBy
    on QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QSortBy> {
  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByArrivalTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arrivalTime', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByArrivalTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arrivalTime', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByCollectedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectedBy', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByCollectedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectedBy', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByCollectedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectedTime', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByCollectedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectedTime', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByCourierName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courierName', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByCourierNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courierName', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByCourierPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courierPhone', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByCourierPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courierPhone', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByIsCollected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollected', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByIsCollectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollected', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByPackageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packageId', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByPackageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packageId', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByRecipientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientId', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByRecipientIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientId', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByRecipientName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientName', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByRecipientNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientName', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByTrackingNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackingNumber', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      sortByTrackingNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackingNumber', Sort.desc);
    });
  }
}

extension PackageDeliveryIsarQuerySortThenBy
    on QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QSortThenBy> {
  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByArrivalTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arrivalTime', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByArrivalTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'arrivalTime', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByCollectedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectedBy', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByCollectedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectedBy', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByCollectedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectedTime', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByCollectedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'collectedTime', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByCourierName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courierName', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByCourierNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courierName', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByCourierPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courierPhone', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByCourierPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'courierPhone', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByIsCollected() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollected', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByIsCollectedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCollected', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByPackageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packageId', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByPackageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'packageId', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByRecipientId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientId', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByRecipientIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientId', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByRecipientName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientName', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByRecipientNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recipientName', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByTrackingNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackingNumber', Sort.asc);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QAfterSortBy>
      thenByTrackingNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackingNumber', Sort.desc);
    });
  }
}

extension PackageDeliveryIsarQueryWhereDistinct
    on QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QDistinct> {
  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QDistinct>
      distinctByArrivalTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'arrivalTime');
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QDistinct>
      distinctByCollectedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QDistinct>
      distinctByCollectedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'collectedTime');
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QDistinct>
      distinctByCourierName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'courierName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QDistinct>
      distinctByCourierPhone({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'courierPhone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QDistinct>
      distinctByIsCollected() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCollected');
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QDistinct>
      distinctByPackageId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'packageId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QDistinct>
      distinctByRecipientId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recipientId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QDistinct>
      distinctByRecipientName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recipientName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QDistinct>
      distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QDistinct>
      distinctByTrackingNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackingNumber',
          caseSensitive: caseSensitive);
    });
  }
}

extension PackageDeliveryIsarQueryProperty
    on QueryBuilder<PackageDeliveryIsar, PackageDeliveryIsar, QQueryProperty> {
  QueryBuilder<PackageDeliveryIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PackageDeliveryIsar, DateTime, QQueryOperations>
      arrivalTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'arrivalTime');
    });
  }

  QueryBuilder<PackageDeliveryIsar, String?, QQueryOperations>
      collectedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectedBy');
    });
  }

  QueryBuilder<PackageDeliveryIsar, DateTime?, QQueryOperations>
      collectedTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'collectedTime');
    });
  }

  QueryBuilder<PackageDeliveryIsar, String, QQueryOperations>
      courierNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'courierName');
    });
  }

  QueryBuilder<PackageDeliveryIsar, String?, QQueryOperations>
      courierPhoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'courierPhone');
    });
  }

  QueryBuilder<PackageDeliveryIsar, bool, QQueryOperations>
      isCollectedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCollected');
    });
  }

  QueryBuilder<PackageDeliveryIsar, String, QQueryOperations>
      packageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'packageId');
    });
  }

  QueryBuilder<PackageDeliveryIsar, String?, QQueryOperations>
      recipientIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recipientId');
    });
  }

  QueryBuilder<PackageDeliveryIsar, String, QQueryOperations>
      recipientNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recipientName');
    });
  }

  QueryBuilder<PackageDeliveryIsar, String, QQueryOperations>
      schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<PackageDeliveryIsar, String?, QQueryOperations>
      trackingNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackingNumber');
    });
  }
}
