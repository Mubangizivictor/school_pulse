// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'procurement_request_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProcurementRequestIsarCollection on Isar {
  IsarCollection<ProcurementRequestIsar> get procurementRequestIsars =>
      this.collection();
}

const ProcurementRequestIsarSchema = CollectionSchema(
  name: r'ProcurementRequestIsar',
  id: 4456355643297365998,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'directorNote': PropertySchema(
      id: 1,
      name: r'directorNote',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 2,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'itemName': PropertySchema(
      id: 3,
      name: r'itemName',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 4,
      name: r'quantity',
      type: IsarType.long,
    ),
    r'reason': PropertySchema(
      id: 5,
      name: r'reason',
      type: IsarType.string,
    ),
    r'requestId': PropertySchema(
      id: 6,
      name: r'requestId',
      type: IsarType.string,
    ),
    r'requesterId': PropertySchema(
      id: 7,
      name: r'requesterId',
      type: IsarType.string,
    ),
    r'requesterName': PropertySchema(
      id: 8,
      name: r'requesterName',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 9,
      name: r'status',
      type: IsarType.byte,
      enumMap: _ProcurementRequestIsarstatusEnumValueMap,
    )
  },
  estimateSize: _procurementRequestIsarEstimateSize,
  serialize: _procurementRequestIsarSerialize,
  deserialize: _procurementRequestIsarDeserialize,
  deserializeProp: _procurementRequestIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'requestId': IndexSchema(
      id: 938047444593699237,
      name: r'requestId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'requestId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _procurementRequestIsarGetId,
  getLinks: _procurementRequestIsarGetLinks,
  attach: _procurementRequestIsarAttach,
  version: '3.1.0+1',
);

int _procurementRequestIsarEstimateSize(
  ProcurementRequestIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.directorNote;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.itemName.length * 3;
  bytesCount += 3 + object.reason.length * 3;
  bytesCount += 3 + object.requestId.length * 3;
  bytesCount += 3 + object.requesterId.length * 3;
  bytesCount += 3 + object.requesterName.length * 3;
  return bytesCount;
}

void _procurementRequestIsarSerialize(
  ProcurementRequestIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeString(offsets[1], object.directorNote);
  writer.writeBool(offsets[2], object.isSynced);
  writer.writeString(offsets[3], object.itemName);
  writer.writeLong(offsets[4], object.quantity);
  writer.writeString(offsets[5], object.reason);
  writer.writeString(offsets[6], object.requestId);
  writer.writeString(offsets[7], object.requesterId);
  writer.writeString(offsets[8], object.requesterName);
  writer.writeByte(offsets[9], object.status.index);
}

ProcurementRequestIsar _procurementRequestIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProcurementRequestIsar();
  object.date = reader.readDateTime(offsets[0]);
  object.directorNote = reader.readStringOrNull(offsets[1]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[2]);
  object.itemName = reader.readString(offsets[3]);
  object.quantity = reader.readLong(offsets[4]);
  object.reason = reader.readString(offsets[5]);
  object.requestId = reader.readString(offsets[6]);
  object.requesterId = reader.readString(offsets[7]);
  object.requesterName = reader.readString(offsets[8]);
  object.status = _ProcurementRequestIsarstatusValueEnumMap[
          reader.readByteOrNull(offsets[9])] ??
      ProcurementStatus.pending;
  return object;
}

P _procurementRequestIsarDeserializeProp<P>(
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
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (_ProcurementRequestIsarstatusValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ProcurementStatus.pending) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ProcurementRequestIsarstatusEnumValueMap = {
  'pending': 0,
  'approved': 1,
  'rejected': 2,
  'completed': 3,
};
const _ProcurementRequestIsarstatusValueEnumMap = {
  0: ProcurementStatus.pending,
  1: ProcurementStatus.approved,
  2: ProcurementStatus.rejected,
  3: ProcurementStatus.completed,
};

Id _procurementRequestIsarGetId(ProcurementRequestIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _procurementRequestIsarGetLinks(
    ProcurementRequestIsar object) {
  return [];
}

void _procurementRequestIsarAttach(
    IsarCollection<dynamic> col, Id id, ProcurementRequestIsar object) {
  object.id = id;
}

extension ProcurementRequestIsarByIndex
    on IsarCollection<ProcurementRequestIsar> {
  Future<ProcurementRequestIsar?> getByRequestId(String requestId) {
    return getByIndex(r'requestId', [requestId]);
  }

  ProcurementRequestIsar? getByRequestIdSync(String requestId) {
    return getByIndexSync(r'requestId', [requestId]);
  }

  Future<bool> deleteByRequestId(String requestId) {
    return deleteByIndex(r'requestId', [requestId]);
  }

  bool deleteByRequestIdSync(String requestId) {
    return deleteByIndexSync(r'requestId', [requestId]);
  }

  Future<List<ProcurementRequestIsar?>> getAllByRequestId(
      List<String> requestIdValues) {
    final values = requestIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'requestId', values);
  }

  List<ProcurementRequestIsar?> getAllByRequestIdSync(
      List<String> requestIdValues) {
    final values = requestIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'requestId', values);
  }

  Future<int> deleteAllByRequestId(List<String> requestIdValues) {
    final values = requestIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'requestId', values);
  }

  int deleteAllByRequestIdSync(List<String> requestIdValues) {
    final values = requestIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'requestId', values);
  }

  Future<Id> putByRequestId(ProcurementRequestIsar object) {
    return putByIndex(r'requestId', object);
  }

  Id putByRequestIdSync(ProcurementRequestIsar object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'requestId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRequestId(List<ProcurementRequestIsar> objects) {
    return putAllByIndex(r'requestId', objects);
  }

  List<Id> putAllByRequestIdSync(List<ProcurementRequestIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'requestId', objects, saveLinks: saveLinks);
  }
}

extension ProcurementRequestIsarQueryWhereSort
    on QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QWhere> {
  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProcurementRequestIsarQueryWhere on QueryBuilder<
    ProcurementRequestIsar, ProcurementRequestIsar, QWhereClause> {
  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterWhereClause> requestIdEqualTo(String requestId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'requestId',
        value: [requestId],
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterWhereClause> requestIdNotEqualTo(String requestId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'requestId',
              lower: [],
              upper: [requestId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'requestId',
              lower: [requestId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'requestId',
              lower: [requestId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'requestId',
              lower: [],
              upper: [requestId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProcurementRequestIsarQueryFilter on QueryBuilder<
    ProcurementRequestIsar, ProcurementRequestIsar, QFilterCondition> {
  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> directorNoteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'directorNote',
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> directorNoteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'directorNote',
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> directorNoteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'directorNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> directorNoteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'directorNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> directorNoteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'directorNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> directorNoteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'directorNote',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> directorNoteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'directorNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> directorNoteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'directorNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
          QAfterFilterCondition>
      directorNoteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'directorNote',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
          QAfterFilterCondition>
      directorNoteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'directorNote',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> directorNoteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'directorNote',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> directorNoteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'directorNote',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
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

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
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

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
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

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> itemNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> itemNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> itemNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> itemNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> itemNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> itemNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
          QAfterFilterCondition>
      itemNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
          QAfterFilterCondition>
      itemNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> itemNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemName',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> itemNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemName',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> quantityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> quantityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> quantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> reasonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> reasonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> reasonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> reasonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> reasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
          QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
          QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requestIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requestIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requestIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requestIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requestId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requestIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requestIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
          QAfterFilterCondition>
      requestIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requestId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
          QAfterFilterCondition>
      requestIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requestId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requestIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requestId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requestIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requestId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requesterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requesterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requesterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requesterId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requesterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requesterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
          QAfterFilterCondition>
      requesterIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requesterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
          QAfterFilterCondition>
      requesterIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requesterId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requesterId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requesterId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requesterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'requesterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'requesterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'requesterName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'requesterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'requesterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
          QAfterFilterCondition>
      requesterNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'requesterName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
          QAfterFilterCondition>
      requesterNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'requesterName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requesterName',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> requesterNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'requesterName',
        value: '',
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> statusEqualTo(ProcurementStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> statusGreaterThan(
    ProcurementStatus value, {
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

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> statusLessThan(
    ProcurementStatus value, {
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

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar,
      QAfterFilterCondition> statusBetween(
    ProcurementStatus lower,
    ProcurementStatus upper, {
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
}

extension ProcurementRequestIsarQueryObject on QueryBuilder<
    ProcurementRequestIsar, ProcurementRequestIsar, QFilterCondition> {}

extension ProcurementRequestIsarQueryLinks on QueryBuilder<
    ProcurementRequestIsar, ProcurementRequestIsar, QFilterCondition> {}

extension ProcurementRequestIsarQuerySortBy
    on QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QSortBy> {
  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByDirectorNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'directorNote', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByDirectorNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'directorNote', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByItemName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemName', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByItemNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemName', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByRequestId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByRequestIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByRequesterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requesterId', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByRequesterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requesterId', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByRequesterName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requesterName', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByRequesterNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requesterName', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension ProcurementRequestIsarQuerySortThenBy on QueryBuilder<
    ProcurementRequestIsar, ProcurementRequestIsar, QSortThenBy> {
  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByDirectorNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'directorNote', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByDirectorNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'directorNote', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByItemName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemName', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByItemNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemName', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantity', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByRequestId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByRequestIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requestId', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByRequesterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requesterId', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByRequesterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requesterId', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByRequesterName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requesterName', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByRequesterNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requesterName', Sort.desc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension ProcurementRequestIsarQueryWhereDistinct
    on QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QDistinct> {
  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QDistinct>
      distinctByDirectorNote({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'directorNote', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QDistinct>
      distinctByItemName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QDistinct>
      distinctByQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantity');
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QDistinct>
      distinctByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QDistinct>
      distinctByRequestId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requestId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QDistinct>
      distinctByRequesterId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requesterId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QDistinct>
      distinctByRequesterName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requesterName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementRequestIsar, QDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }
}

extension ProcurementRequestIsarQueryProperty on QueryBuilder<
    ProcurementRequestIsar, ProcurementRequestIsar, QQueryProperty> {
  QueryBuilder<ProcurementRequestIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProcurementRequestIsar, DateTime, QQueryOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<ProcurementRequestIsar, String?, QQueryOperations>
      directorNoteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'directorNote');
    });
  }

  QueryBuilder<ProcurementRequestIsar, bool, QQueryOperations>
      isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<ProcurementRequestIsar, String, QQueryOperations>
      itemNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemName');
    });
  }

  QueryBuilder<ProcurementRequestIsar, int, QQueryOperations>
      quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantity');
    });
  }

  QueryBuilder<ProcurementRequestIsar, String, QQueryOperations>
      reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<ProcurementRequestIsar, String, QQueryOperations>
      requestIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requestId');
    });
  }

  QueryBuilder<ProcurementRequestIsar, String, QQueryOperations>
      requesterIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requesterId');
    });
  }

  QueryBuilder<ProcurementRequestIsar, String, QQueryOperations>
      requesterNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requesterName');
    });
  }

  QueryBuilder<ProcurementRequestIsar, ProcurementStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
