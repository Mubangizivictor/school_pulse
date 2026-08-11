// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_isar_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLibraryResourceIsarCollection on Isar {
  IsarCollection<LibraryResourceIsar> get libraryResourceIsars =>
      this.collection();
}

const LibraryResourceIsarSchema = CollectionSchema(
  name: r'LibraryResourceIsar',
  id: -2066900725510387107,
  properties: {
    r'author': PropertySchema(id: 0, name: r'author', type: IsarType.string),
    r'availableCopies': PropertySchema(
      id: 1,
      name: r'availableCopies',
      type: IsarType.long,
    ),
    r'barcode': PropertySchema(id: 2, name: r'barcode', type: IsarType.string),
    r'category': PropertySchema(
      id: 3,
      name: r'category',
      type: IsarType.string,
    ),
    r'condition': PropertySchema(
      id: 4,
      name: r'condition',
      type: IsarType.string,
    ),
    r'coverImageUrl': PropertySchema(
      id: 5,
      name: r'coverImageUrl',
      type: IsarType.string,
    ),
    r'digitalAttachmentUrl': PropertySchema(
      id: 6,
      name: r'digitalAttachmentUrl',
      type: IsarType.string,
    ),
    r'edition': PropertySchema(id: 7, name: r'edition', type: IsarType.string),
    r'isbn': PropertySchema(id: 8, name: r'isbn', type: IsarType.string),
    r'libraryId': PropertySchema(
      id: 9,
      name: r'libraryId',
      type: IsarType.string,
    ),
    r'publisher': PropertySchema(
      id: 10,
      name: r'publisher',
      type: IsarType.string,
    ),
    r'purchaseCost': PropertySchema(
      id: 11,
      name: r'purchaseCost',
      type: IsarType.double,
    ),
    r'purchaseDate': PropertySchema(
      id: 12,
      name: r'purchaseDate',
      type: IsarType.dateTime,
    ),
    r'qrCode': PropertySchema(id: 13, name: r'qrCode', type: IsarType.string),
    r'rack': PropertySchema(id: 14, name: r'rack', type: IsarType.string),
    r'remoteId': PropertySchema(
      id: 15,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 16,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'shelf': PropertySchema(id: 17, name: r'shelf', type: IsarType.string),
    r'status': PropertySchema(id: 18, name: r'status', type: IsarType.string),
    r'subject': PropertySchema(id: 19, name: r'subject', type: IsarType.string),
    r'supplier': PropertySchema(
      id: 20,
      name: r'supplier',
      type: IsarType.string,
    ),
    r'title': PropertySchema(id: 21, name: r'title', type: IsarType.string),
    r'totalQuantity': PropertySchema(
      id: 22,
      name: r'totalQuantity',
      type: IsarType.long,
    ),
    r'type': PropertySchema(id: 23, name: r'type', type: IsarType.string),
  },
  estimateSize: _libraryResourceIsarEstimateSize,
  serialize: _libraryResourceIsarSerialize,
  deserialize: _libraryResourceIsarDeserialize,
  deserializeProp: _libraryResourceIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'remoteId': IndexSchema(
      id: 6301175856541681032,
      name: r'remoteId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'remoteId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _libraryResourceIsarGetId,
  getLinks: _libraryResourceIsarGetLinks,
  attach: _libraryResourceIsarAttach,
  version: '3.1.0+1',
);

int _libraryResourceIsarEstimateSize(
  LibraryResourceIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.author.length * 3;
  bytesCount += 3 + object.barcode.length * 3;
  bytesCount += 3 + object.category.length * 3;
  bytesCount += 3 + object.condition.length * 3;
  {
    final value = object.coverImageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.digitalAttachmentUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.edition;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.isbn;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.libraryId.length * 3;
  {
    final value = object.publisher;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.qrCode.length * 3;
  bytesCount += 3 + object.rack.length * 3;
  bytesCount += 3 + object.remoteId.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.shelf.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.subject.length * 3;
  {
    final value = object.supplier;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _libraryResourceIsarSerialize(
  LibraryResourceIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.author);
  writer.writeLong(offsets[1], object.availableCopies);
  writer.writeString(offsets[2], object.barcode);
  writer.writeString(offsets[3], object.category);
  writer.writeString(offsets[4], object.condition);
  writer.writeString(offsets[5], object.coverImageUrl);
  writer.writeString(offsets[6], object.digitalAttachmentUrl);
  writer.writeString(offsets[7], object.edition);
  writer.writeString(offsets[8], object.isbn);
  writer.writeString(offsets[9], object.libraryId);
  writer.writeString(offsets[10], object.publisher);
  writer.writeDouble(offsets[11], object.purchaseCost);
  writer.writeDateTime(offsets[12], object.purchaseDate);
  writer.writeString(offsets[13], object.qrCode);
  writer.writeString(offsets[14], object.rack);
  writer.writeString(offsets[15], object.remoteId);
  writer.writeString(offsets[16], object.schoolId);
  writer.writeString(offsets[17], object.shelf);
  writer.writeString(offsets[18], object.status);
  writer.writeString(offsets[19], object.subject);
  writer.writeString(offsets[20], object.supplier);
  writer.writeString(offsets[21], object.title);
  writer.writeLong(offsets[22], object.totalQuantity);
  writer.writeString(offsets[23], object.type);
}

LibraryResourceIsar _libraryResourceIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LibraryResourceIsar();
  object.author = reader.readString(offsets[0]);
  object.availableCopies = reader.readLong(offsets[1]);
  object.barcode = reader.readString(offsets[2]);
  object.category = reader.readString(offsets[3]);
  object.condition = reader.readString(offsets[4]);
  object.coverImageUrl = reader.readStringOrNull(offsets[5]);
  object.digitalAttachmentUrl = reader.readStringOrNull(offsets[6]);
  object.edition = reader.readStringOrNull(offsets[7]);
  object.id = id;
  object.isbn = reader.readStringOrNull(offsets[8]);
  object.libraryId = reader.readString(offsets[9]);
  object.publisher = reader.readStringOrNull(offsets[10]);
  object.purchaseCost = reader.readDoubleOrNull(offsets[11]);
  object.purchaseDate = reader.readDateTimeOrNull(offsets[12]);
  object.qrCode = reader.readString(offsets[13]);
  object.rack = reader.readString(offsets[14]);
  object.remoteId = reader.readString(offsets[15]);
  object.schoolId = reader.readString(offsets[16]);
  object.shelf = reader.readString(offsets[17]);
  object.status = reader.readString(offsets[18]);
  object.subject = reader.readString(offsets[19]);
  object.supplier = reader.readStringOrNull(offsets[20]);
  object.title = reader.readString(offsets[21]);
  object.totalQuantity = reader.readLong(offsets[22]);
  object.type = reader.readString(offsets[23]);
  return object;
}

P _libraryResourceIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDoubleOrNull(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readLong(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _libraryResourceIsarGetId(LibraryResourceIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _libraryResourceIsarGetLinks(
  LibraryResourceIsar object,
) {
  return [];
}

void _libraryResourceIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  LibraryResourceIsar object,
) {
  object.id = id;
}

extension LibraryResourceIsarByIndex on IsarCollection<LibraryResourceIsar> {
  Future<LibraryResourceIsar?> getByRemoteId(String remoteId) {
    return getByIndex(r'remoteId', [remoteId]);
  }

  LibraryResourceIsar? getByRemoteIdSync(String remoteId) {
    return getByIndexSync(r'remoteId', [remoteId]);
  }

  Future<bool> deleteByRemoteId(String remoteId) {
    return deleteByIndex(r'remoteId', [remoteId]);
  }

  bool deleteByRemoteIdSync(String remoteId) {
    return deleteByIndexSync(r'remoteId', [remoteId]);
  }

  Future<List<LibraryResourceIsar?>> getAllByRemoteId(
    List<String> remoteIdValues,
  ) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'remoteId', values);
  }

  List<LibraryResourceIsar?> getAllByRemoteIdSync(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'remoteId', values);
  }

  Future<int> deleteAllByRemoteId(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'remoteId', values);
  }

  int deleteAllByRemoteIdSync(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'remoteId', values);
  }

  Future<Id> putByRemoteId(LibraryResourceIsar object) {
    return putByIndex(r'remoteId', object);
  }

  Id putByRemoteIdSync(LibraryResourceIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'remoteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRemoteId(List<LibraryResourceIsar> objects) {
    return putAllByIndex(r'remoteId', objects);
  }

  List<Id> putAllByRemoteIdSync(
    List<LibraryResourceIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'remoteId', objects, saveLinks: saveLinks);
  }
}

extension LibraryResourceIsarQueryWhereSort
    on QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QWhere> {
  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LibraryResourceIsarQueryWhere
    on QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QWhereClause> {
  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterWhereClause>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterWhereClause>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterWhereClause>
  remoteIdEqualTo(String remoteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'remoteId', value: [remoteId]),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterWhereClause>
  remoteIdNotEqualTo(String remoteId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [],
                upper: [remoteId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [remoteId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [remoteId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [],
                upper: [remoteId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension LibraryResourceIsarQueryFilter
    on
        QueryBuilder<
          LibraryResourceIsar,
          LibraryResourceIsar,
          QFilterCondition
        > {
  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  authorEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  authorGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  authorLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  authorBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'author',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  authorStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  authorEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  authorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'author',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  authorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'author',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  authorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'author', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  authorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'author', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  availableCopiesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'availableCopies', value: value),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  availableCopiesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'availableCopies',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  availableCopiesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'availableCopies',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  availableCopiesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'availableCopies',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  barcodeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'barcode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  barcodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'barcode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  barcodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'barcode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  barcodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'barcode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  barcodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'barcode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  barcodeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'barcode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  barcodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'barcode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  barcodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'barcode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  barcodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'barcode', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  barcodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'barcode', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  categoryEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'category',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  categoryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  categoryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'category',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  conditionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'condition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  conditionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'condition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  conditionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'condition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  conditionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'condition',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  conditionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'condition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  conditionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'condition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  conditionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'condition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  conditionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'condition',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  conditionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'condition', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  conditionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'condition', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  coverImageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'coverImageUrl'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  coverImageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'coverImageUrl'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  coverImageUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'coverImageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  coverImageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'coverImageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  coverImageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'coverImageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  coverImageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'coverImageUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  coverImageUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'coverImageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  coverImageUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'coverImageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  coverImageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'coverImageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  coverImageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'coverImageUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  coverImageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'coverImageUrl', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  coverImageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'coverImageUrl', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  digitalAttachmentUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'digitalAttachmentUrl'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  digitalAttachmentUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'digitalAttachmentUrl'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  digitalAttachmentUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'digitalAttachmentUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  digitalAttachmentUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'digitalAttachmentUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  digitalAttachmentUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'digitalAttachmentUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  digitalAttachmentUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'digitalAttachmentUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  digitalAttachmentUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'digitalAttachmentUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  digitalAttachmentUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'digitalAttachmentUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  digitalAttachmentUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'digitalAttachmentUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  digitalAttachmentUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'digitalAttachmentUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  digitalAttachmentUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'digitalAttachmentUrl', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  digitalAttachmentUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'digitalAttachmentUrl',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  editionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'edition'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  editionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'edition'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  editionEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'edition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  editionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'edition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  editionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'edition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  editionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'edition',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  editionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'edition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  editionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'edition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  editionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'edition',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  editionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'edition',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  editionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'edition', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  editionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'edition', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  isbnIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'isbn'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  isbnIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'isbn'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  isbnEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'isbn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  isbnGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'isbn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  isbnLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'isbn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  isbnBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'isbn',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  isbnStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'isbn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  isbnEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'isbn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  isbnContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'isbn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  isbnMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'isbn',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  isbnIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isbn', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  isbnIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'isbn', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  libraryIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'libraryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  libraryIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'libraryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  libraryIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'libraryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  libraryIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'libraryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  libraryIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'libraryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  libraryIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'libraryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  libraryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'libraryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  libraryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'libraryId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  libraryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'libraryId', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  libraryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'libraryId', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  publisherIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'publisher'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  publisherIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'publisher'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  publisherEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'publisher',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  publisherGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'publisher',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  publisherLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'publisher',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  publisherBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'publisher',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  publisherStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'publisher',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  publisherEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'publisher',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  publisherContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'publisher',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  publisherMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'publisher',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  publisherIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'publisher', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  publisherIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'publisher', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  purchaseCostIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'purchaseCost'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  purchaseCostIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'purchaseCost'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  purchaseCostEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'purchaseCost',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  purchaseCostGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'purchaseCost',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  purchaseCostLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'purchaseCost',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  purchaseCostBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'purchaseCost',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  purchaseDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'purchaseDate'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  purchaseDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'purchaseDate'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  purchaseDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'purchaseDate', value: value),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  purchaseDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'purchaseDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  purchaseDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'purchaseDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  purchaseDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'purchaseDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  qrCodeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'qrCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  qrCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'qrCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  qrCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'qrCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  qrCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'qrCode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  qrCodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'qrCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  qrCodeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'qrCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  qrCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'qrCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  qrCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'qrCode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  qrCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'qrCode', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  qrCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'qrCode', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  rackEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rack',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  rackGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rack',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  rackLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rack',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  rackBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rack',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  rackStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rack',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  rackEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rack',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  rackContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rack',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  rackMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rack',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  rackIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rack', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  rackIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rack', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  remoteIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  remoteIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  remoteIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  remoteIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remoteId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  remoteIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  remoteIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  remoteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  remoteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'remoteId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  shelfEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'shelf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  shelfGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'shelf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  shelfLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'shelf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  shelfBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'shelf',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  shelfStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'shelf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  shelfEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'shelf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  shelfContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'shelf',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  shelfMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'shelf',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  shelfIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'shelf', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  shelfIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'shelf', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
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

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  subjectEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'subject',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  subjectGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'subject',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  subjectLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'subject',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  subjectBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'subject',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  subjectStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'subject',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  subjectEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'subject',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  subjectContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'subject',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  subjectMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'subject',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  subjectIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'subject', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  subjectIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'subject', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  supplierIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'supplier'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  supplierIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'supplier'),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  supplierEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  supplierGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  supplierLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  supplierBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'supplier',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  supplierStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  supplierEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  supplierContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'supplier',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  supplierMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'supplier',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  supplierIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'supplier', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  supplierIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'supplier', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  totalQuantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalQuantity', value: value),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  totalQuantityGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalQuantity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  totalQuantityLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalQuantity',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  totalQuantityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalQuantity',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  typeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  typeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  typeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterFilterCondition>
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }
}

extension LibraryResourceIsarQueryObject
    on
        QueryBuilder<
          LibraryResourceIsar,
          LibraryResourceIsar,
          QFilterCondition
        > {}

extension LibraryResourceIsarQueryLinks
    on
        QueryBuilder<
          LibraryResourceIsar,
          LibraryResourceIsar,
          QFilterCondition
        > {}

extension LibraryResourceIsarQuerySortBy
    on QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QSortBy> {
  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByAvailableCopies() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableCopies', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByAvailableCopiesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableCopies', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByBarcode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'barcode', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByBarcodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'barcode', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByCondition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'condition', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByConditionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'condition', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByCoverImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverImageUrl', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByCoverImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverImageUrl', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByDigitalAttachmentUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'digitalAttachmentUrl', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByDigitalAttachmentUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'digitalAttachmentUrl', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByEdition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'edition', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByEditionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'edition', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByIsbn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isbn', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByIsbnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isbn', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByLibraryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'libraryId', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByLibraryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'libraryId', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByPublisher() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByPublisherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByPurchaseCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseCost', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByPurchaseCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseCost', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByPurchaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByQrCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCode', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByQrCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCode', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByRack() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rack', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByRackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rack', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByShelf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shelf', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByShelfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shelf', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortBySupplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortBySupplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByTotalQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuantity', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByTotalQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuantity', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension LibraryResourceIsarQuerySortThenBy
    on QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QSortThenBy> {
  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByAuthor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByAuthorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'author', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByAvailableCopies() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableCopies', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByAvailableCopiesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableCopies', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByBarcode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'barcode', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByBarcodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'barcode', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByCondition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'condition', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByConditionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'condition', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByCoverImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverImageUrl', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByCoverImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coverImageUrl', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByDigitalAttachmentUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'digitalAttachmentUrl', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByDigitalAttachmentUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'digitalAttachmentUrl', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByEdition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'edition', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByEditionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'edition', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByIsbn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isbn', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByIsbnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isbn', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByLibraryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'libraryId', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByLibraryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'libraryId', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByPublisher() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByPublisherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'publisher', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByPurchaseCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseCost', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByPurchaseCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseCost', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByPurchaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByQrCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCode', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByQrCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrCode', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByRack() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rack', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByRackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rack', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByShelf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shelf', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByShelfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shelf', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenBySupplier() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenBySupplierDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplier', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByTotalQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuantity', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByTotalQuantityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalQuantity', Sort.desc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QAfterSortBy>
  thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension LibraryResourceIsarQueryWhereDistinct
    on QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct> {
  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByAuthor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'author', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByAvailableCopies() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'availableCopies');
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByBarcode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'barcode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByCondition({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'condition', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByCoverImageUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'coverImageUrl',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByDigitalAttachmentUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'digitalAttachmentUrl',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByEdition({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'edition', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByIsbn({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isbn', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByLibraryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'libraryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByPublisher({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'publisher', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByPurchaseCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchaseCost');
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchaseDate');
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByQrCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qrCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByRack({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rack', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByRemoteId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByShelf({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shelf', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctBySubject({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subject', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctBySupplier({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supplier', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByTotalQuantity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalQuantity');
    });
  }

  QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QDistinct>
  distinctByType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension LibraryResourceIsarQueryProperty
    on QueryBuilder<LibraryResourceIsar, LibraryResourceIsar, QQueryProperty> {
  QueryBuilder<LibraryResourceIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LibraryResourceIsar, String, QQueryOperations> authorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'author');
    });
  }

  QueryBuilder<LibraryResourceIsar, int, QQueryOperations>
  availableCopiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'availableCopies');
    });
  }

  QueryBuilder<LibraryResourceIsar, String, QQueryOperations>
  barcodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'barcode');
    });
  }

  QueryBuilder<LibraryResourceIsar, String, QQueryOperations>
  categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<LibraryResourceIsar, String, QQueryOperations>
  conditionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'condition');
    });
  }

  QueryBuilder<LibraryResourceIsar, String?, QQueryOperations>
  coverImageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coverImageUrl');
    });
  }

  QueryBuilder<LibraryResourceIsar, String?, QQueryOperations>
  digitalAttachmentUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'digitalAttachmentUrl');
    });
  }

  QueryBuilder<LibraryResourceIsar, String?, QQueryOperations>
  editionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'edition');
    });
  }

  QueryBuilder<LibraryResourceIsar, String?, QQueryOperations> isbnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isbn');
    });
  }

  QueryBuilder<LibraryResourceIsar, String, QQueryOperations>
  libraryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'libraryId');
    });
  }

  QueryBuilder<LibraryResourceIsar, String?, QQueryOperations>
  publisherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'publisher');
    });
  }

  QueryBuilder<LibraryResourceIsar, double?, QQueryOperations>
  purchaseCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchaseCost');
    });
  }

  QueryBuilder<LibraryResourceIsar, DateTime?, QQueryOperations>
  purchaseDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchaseDate');
    });
  }

  QueryBuilder<LibraryResourceIsar, String, QQueryOperations> qrCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qrCode');
    });
  }

  QueryBuilder<LibraryResourceIsar, String, QQueryOperations> rackProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rack');
    });
  }

  QueryBuilder<LibraryResourceIsar, String, QQueryOperations>
  remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<LibraryResourceIsar, String, QQueryOperations>
  schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<LibraryResourceIsar, String, QQueryOperations> shelfProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shelf');
    });
  }

  QueryBuilder<LibraryResourceIsar, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<LibraryResourceIsar, String, QQueryOperations>
  subjectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subject');
    });
  }

  QueryBuilder<LibraryResourceIsar, String?, QQueryOperations>
  supplierProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supplier');
    });
  }

  QueryBuilder<LibraryResourceIsar, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<LibraryResourceIsar, int, QQueryOperations>
  totalQuantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalQuantity');
    });
  }

  QueryBuilder<LibraryResourceIsar, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLibraryBorrowingIsarCollection on Isar {
  IsarCollection<LibraryBorrowingIsar> get libraryBorrowingIsars =>
      this.collection();
}

const LibraryBorrowingIsarSchema = CollectionSchema(
  name: r'LibraryBorrowingIsar',
  id: 8299383903049990985,
  properties: {
    r'borrowDate': PropertySchema(
      id: 0,
      name: r'borrowDate',
      type: IsarType.dateTime,
    ),
    r'borrowerId': PropertySchema(
      id: 1,
      name: r'borrowerId',
      type: IsarType.string,
    ),
    r'borrowerName': PropertySchema(
      id: 2,
      name: r'borrowerName',
      type: IsarType.string,
    ),
    r'borrowerType': PropertySchema(
      id: 3,
      name: r'borrowerType',
      type: IsarType.string,
    ),
    r'dueDate': PropertySchema(
      id: 4,
      name: r'dueDate',
      type: IsarType.dateTime,
    ),
    r'fineAmount': PropertySchema(
      id: 5,
      name: r'fineAmount',
      type: IsarType.double,
    ),
    r'finePaid': PropertySchema(id: 6, name: r'finePaid', type: IsarType.bool),
    r'issuedBy': PropertySchema(
      id: 7,
      name: r'issuedBy',
      type: IsarType.string,
    ),
    r'receivedBy': PropertySchema(
      id: 8,
      name: r'receivedBy',
      type: IsarType.string,
    ),
    r'remoteId': PropertySchema(
      id: 9,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'resourceId': PropertySchema(
      id: 10,
      name: r'resourceId',
      type: IsarType.string,
    ),
    r'resourceTitle': PropertySchema(
      id: 11,
      name: r'resourceTitle',
      type: IsarType.string,
    ),
    r'returnDate': PropertySchema(
      id: 12,
      name: r'returnDate',
      type: IsarType.dateTime,
    ),
    r'schoolId': PropertySchema(
      id: 13,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(id: 14, name: r'status', type: IsarType.string),
  },
  estimateSize: _libraryBorrowingIsarEstimateSize,
  serialize: _libraryBorrowingIsarSerialize,
  deserialize: _libraryBorrowingIsarDeserialize,
  deserializeProp: _libraryBorrowingIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'remoteId': IndexSchema(
      id: 6301175856541681032,
      name: r'remoteId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'remoteId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _libraryBorrowingIsarGetId,
  getLinks: _libraryBorrowingIsarGetLinks,
  attach: _libraryBorrowingIsarAttach,
  version: '3.1.0+1',
);

int _libraryBorrowingIsarEstimateSize(
  LibraryBorrowingIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.borrowerId.length * 3;
  bytesCount += 3 + object.borrowerName.length * 3;
  bytesCount += 3 + object.borrowerType.length * 3;
  bytesCount += 3 + object.issuedBy.length * 3;
  {
    final value = object.receivedBy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.remoteId.length * 3;
  bytesCount += 3 + object.resourceId.length * 3;
  bytesCount += 3 + object.resourceTitle.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _libraryBorrowingIsarSerialize(
  LibraryBorrowingIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.borrowDate);
  writer.writeString(offsets[1], object.borrowerId);
  writer.writeString(offsets[2], object.borrowerName);
  writer.writeString(offsets[3], object.borrowerType);
  writer.writeDateTime(offsets[4], object.dueDate);
  writer.writeDouble(offsets[5], object.fineAmount);
  writer.writeBool(offsets[6], object.finePaid);
  writer.writeString(offsets[7], object.issuedBy);
  writer.writeString(offsets[8], object.receivedBy);
  writer.writeString(offsets[9], object.remoteId);
  writer.writeString(offsets[10], object.resourceId);
  writer.writeString(offsets[11], object.resourceTitle);
  writer.writeDateTime(offsets[12], object.returnDate);
  writer.writeString(offsets[13], object.schoolId);
  writer.writeString(offsets[14], object.status);
}

LibraryBorrowingIsar _libraryBorrowingIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LibraryBorrowingIsar();
  object.borrowDate = reader.readDateTime(offsets[0]);
  object.borrowerId = reader.readString(offsets[1]);
  object.borrowerName = reader.readString(offsets[2]);
  object.borrowerType = reader.readString(offsets[3]);
  object.dueDate = reader.readDateTime(offsets[4]);
  object.fineAmount = reader.readDouble(offsets[5]);
  object.finePaid = reader.readBool(offsets[6]);
  object.id = id;
  object.issuedBy = reader.readString(offsets[7]);
  object.receivedBy = reader.readStringOrNull(offsets[8]);
  object.remoteId = reader.readString(offsets[9]);
  object.resourceId = reader.readString(offsets[10]);
  object.resourceTitle = reader.readString(offsets[11]);
  object.returnDate = reader.readDateTimeOrNull(offsets[12]);
  object.schoolId = reader.readString(offsets[13]);
  object.status = reader.readString(offsets[14]);
  return object;
}

P _libraryBorrowingIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _libraryBorrowingIsarGetId(LibraryBorrowingIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _libraryBorrowingIsarGetLinks(
  LibraryBorrowingIsar object,
) {
  return [];
}

void _libraryBorrowingIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  LibraryBorrowingIsar object,
) {
  object.id = id;
}

extension LibraryBorrowingIsarByIndex on IsarCollection<LibraryBorrowingIsar> {
  Future<LibraryBorrowingIsar?> getByRemoteId(String remoteId) {
    return getByIndex(r'remoteId', [remoteId]);
  }

  LibraryBorrowingIsar? getByRemoteIdSync(String remoteId) {
    return getByIndexSync(r'remoteId', [remoteId]);
  }

  Future<bool> deleteByRemoteId(String remoteId) {
    return deleteByIndex(r'remoteId', [remoteId]);
  }

  bool deleteByRemoteIdSync(String remoteId) {
    return deleteByIndexSync(r'remoteId', [remoteId]);
  }

  Future<List<LibraryBorrowingIsar?>> getAllByRemoteId(
    List<String> remoteIdValues,
  ) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'remoteId', values);
  }

  List<LibraryBorrowingIsar?> getAllByRemoteIdSync(
    List<String> remoteIdValues,
  ) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'remoteId', values);
  }

  Future<int> deleteAllByRemoteId(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'remoteId', values);
  }

  int deleteAllByRemoteIdSync(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'remoteId', values);
  }

  Future<Id> putByRemoteId(LibraryBorrowingIsar object) {
    return putByIndex(r'remoteId', object);
  }

  Id putByRemoteIdSync(LibraryBorrowingIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'remoteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRemoteId(List<LibraryBorrowingIsar> objects) {
    return putAllByIndex(r'remoteId', objects);
  }

  List<Id> putAllByRemoteIdSync(
    List<LibraryBorrowingIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'remoteId', objects, saveLinks: saveLinks);
  }
}

extension LibraryBorrowingIsarQueryWhereSort
    on QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QWhere> {
  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LibraryBorrowingIsarQueryWhere
    on QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QWhereClause> {
  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterWhereClause>
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

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterWhereClause>
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

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterWhereClause>
  remoteIdEqualTo(String remoteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'remoteId', value: [remoteId]),
      );
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterWhereClause>
  remoteIdNotEqualTo(String remoteId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [],
                upper: [remoteId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [remoteId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [remoteId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [],
                upper: [remoteId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension LibraryBorrowingIsarQueryFilter
    on
        QueryBuilder<
          LibraryBorrowingIsar,
          LibraryBorrowingIsar,
          QFilterCondition
        > {
  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'borrowDate', value: value),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'borrowDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'borrowDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'borrowDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'borrowerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'borrowerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'borrowerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'borrowerId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'borrowerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'borrowerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'borrowerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'borrowerId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'borrowerId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'borrowerId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'borrowerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'borrowerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'borrowerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'borrowerName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'borrowerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'borrowerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'borrowerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'borrowerName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'borrowerName', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'borrowerName', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'borrowerType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'borrowerType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'borrowerType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'borrowerType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'borrowerType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'borrowerType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'borrowerType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'borrowerType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'borrowerType', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  borrowerTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'borrowerType', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  dueDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dueDate', value: value),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  dueDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dueDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  dueDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dueDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  dueDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dueDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  fineAmountEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fineAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  fineAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fineAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  fineAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fineAmount',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  fineAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fineAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  finePaidEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'finePaid', value: value),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  issuedByEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'issuedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  issuedByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'issuedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  issuedByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'issuedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  issuedByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'issuedBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  issuedByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'issuedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  issuedByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'issuedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  issuedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'issuedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  issuedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'issuedBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  issuedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'issuedBy', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  issuedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'issuedBy', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  receivedByIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'receivedBy'),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  receivedByIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'receivedBy'),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  receivedByEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'receivedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  receivedByGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'receivedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  receivedByLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'receivedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  receivedByBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'receivedBy',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  receivedByStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'receivedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  receivedByEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'receivedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  receivedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'receivedBy',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  receivedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'receivedBy',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  receivedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'receivedBy', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  receivedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'receivedBy', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  remoteIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  remoteIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  remoteIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  remoteIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remoteId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  remoteIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  remoteIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  remoteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  remoteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'remoteId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'resourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'resourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'resourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'resourceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'resourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'resourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'resourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'resourceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'resourceId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'resourceId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceTitleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'resourceTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'resourceTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'resourceTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'resourceTitle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceTitleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'resourceTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceTitleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'resourceTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'resourceTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'resourceTitle',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'resourceTitle', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  resourceTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'resourceTitle', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  returnDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'returnDate'),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  returnDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'returnDate'),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  returnDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'returnDate', value: value),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  returnDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'returnDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  returnDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'returnDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  returnDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'returnDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryBorrowingIsar,
    LibraryBorrowingIsar,
    QAfterFilterCondition
  >
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }
}

extension LibraryBorrowingIsarQueryObject
    on
        QueryBuilder<
          LibraryBorrowingIsar,
          LibraryBorrowingIsar,
          QFilterCondition
        > {}

extension LibraryBorrowingIsarQueryLinks
    on
        QueryBuilder<
          LibraryBorrowingIsar,
          LibraryBorrowingIsar,
          QFilterCondition
        > {}

extension LibraryBorrowingIsarQuerySortBy
    on QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QSortBy> {
  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByBorrowDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowDate', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByBorrowDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowDate', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByBorrowerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerId', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByBorrowerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerId', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByBorrowerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerName', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByBorrowerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerName', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByBorrowerType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerType', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByBorrowerTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerType', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByFineAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fineAmount', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByFineAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fineAmount', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByFinePaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finePaid', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByFinePaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finePaid', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByIssuedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuedBy', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByIssuedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuedBy', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByReceivedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedBy', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByReceivedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedBy', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByResourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceId', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByResourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceId', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByResourceTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceTitle', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByResourceTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceTitle', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByReturnDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnDate', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByReturnDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnDate', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension LibraryBorrowingIsarQuerySortThenBy
    on QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QSortThenBy> {
  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByBorrowDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowDate', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByBorrowDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowDate', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByBorrowerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerId', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByBorrowerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerId', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByBorrowerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerName', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByBorrowerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerName', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByBorrowerType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerType', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByBorrowerTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerType', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByFineAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fineAmount', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByFineAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fineAmount', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByFinePaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finePaid', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByFinePaidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finePaid', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByIssuedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuedBy', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByIssuedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'issuedBy', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByReceivedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedBy', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByReceivedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receivedBy', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByResourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceId', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByResourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceId', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByResourceTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceTitle', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByResourceTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceTitle', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByReturnDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnDate', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByReturnDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'returnDate', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension LibraryBorrowingIsarQueryWhereDistinct
    on QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct> {
  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctByBorrowDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'borrowDate');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctByBorrowerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'borrowerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctByBorrowerName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'borrowerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctByBorrowerType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'borrowerType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueDate');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctByFineAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fineAmount');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctByFinePaid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finePaid');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctByIssuedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'issuedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctByReceivedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receivedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctByRemoteId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctByResourceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resourceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctByResourceTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'resourceTitle',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctByReturnDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'returnDate');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryBorrowingIsar, LibraryBorrowingIsar, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension LibraryBorrowingIsarQueryProperty
    on
        QueryBuilder<
          LibraryBorrowingIsar,
          LibraryBorrowingIsar,
          QQueryProperty
        > {
  QueryBuilder<LibraryBorrowingIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, DateTime, QQueryOperations>
  borrowDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'borrowDate');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, String, QQueryOperations>
  borrowerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'borrowerId');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, String, QQueryOperations>
  borrowerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'borrowerName');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, String, QQueryOperations>
  borrowerTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'borrowerType');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, DateTime, QQueryOperations>
  dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueDate');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, double, QQueryOperations>
  fineAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fineAmount');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, bool, QQueryOperations>
  finePaidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finePaid');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, String, QQueryOperations>
  issuedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'issuedBy');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, String?, QQueryOperations>
  receivedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receivedBy');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, String, QQueryOperations>
  remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, String, QQueryOperations>
  resourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resourceId');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, String, QQueryOperations>
  resourceTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resourceTitle');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, DateTime?, QQueryOperations>
  returnDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'returnDate');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, String, QQueryOperations>
  schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<LibraryBorrowingIsar, String, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLibraryReservationIsarCollection on Isar {
  IsarCollection<LibraryReservationIsar> get libraryReservationIsars =>
      this.collection();
}

const LibraryReservationIsarSchema = CollectionSchema(
  name: r'LibraryReservationIsar',
  id: 696668058310029868,
  properties: {
    r'borrowerId': PropertySchema(
      id: 0,
      name: r'borrowerId',
      type: IsarType.string,
    ),
    r'borrowerName': PropertySchema(
      id: 1,
      name: r'borrowerName',
      type: IsarType.string,
    ),
    r'borrowerType': PropertySchema(
      id: 2,
      name: r'borrowerType',
      type: IsarType.string,
    ),
    r'expiryDate': PropertySchema(
      id: 3,
      name: r'expiryDate',
      type: IsarType.dateTime,
    ),
    r'queuePosition': PropertySchema(
      id: 4,
      name: r'queuePosition',
      type: IsarType.long,
    ),
    r'remoteId': PropertySchema(
      id: 5,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'reservationDate': PropertySchema(
      id: 6,
      name: r'reservationDate',
      type: IsarType.dateTime,
    ),
    r'resourceId': PropertySchema(
      id: 7,
      name: r'resourceId',
      type: IsarType.string,
    ),
    r'resourceTitle': PropertySchema(
      id: 8,
      name: r'resourceTitle',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 9,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(id: 10, name: r'status', type: IsarType.string),
  },
  estimateSize: _libraryReservationIsarEstimateSize,
  serialize: _libraryReservationIsarSerialize,
  deserialize: _libraryReservationIsarDeserialize,
  deserializeProp: _libraryReservationIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'remoteId': IndexSchema(
      id: 6301175856541681032,
      name: r'remoteId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'remoteId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _libraryReservationIsarGetId,
  getLinks: _libraryReservationIsarGetLinks,
  attach: _libraryReservationIsarAttach,
  version: '3.1.0+1',
);

int _libraryReservationIsarEstimateSize(
  LibraryReservationIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.borrowerId.length * 3;
  bytesCount += 3 + object.borrowerName.length * 3;
  bytesCount += 3 + object.borrowerType.length * 3;
  bytesCount += 3 + object.remoteId.length * 3;
  bytesCount += 3 + object.resourceId.length * 3;
  bytesCount += 3 + object.resourceTitle.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _libraryReservationIsarSerialize(
  LibraryReservationIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.borrowerId);
  writer.writeString(offsets[1], object.borrowerName);
  writer.writeString(offsets[2], object.borrowerType);
  writer.writeDateTime(offsets[3], object.expiryDate);
  writer.writeLong(offsets[4], object.queuePosition);
  writer.writeString(offsets[5], object.remoteId);
  writer.writeDateTime(offsets[6], object.reservationDate);
  writer.writeString(offsets[7], object.resourceId);
  writer.writeString(offsets[8], object.resourceTitle);
  writer.writeString(offsets[9], object.schoolId);
  writer.writeString(offsets[10], object.status);
}

LibraryReservationIsar _libraryReservationIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LibraryReservationIsar();
  object.borrowerId = reader.readString(offsets[0]);
  object.borrowerName = reader.readString(offsets[1]);
  object.borrowerType = reader.readString(offsets[2]);
  object.expiryDate = reader.readDateTimeOrNull(offsets[3]);
  object.id = id;
  object.queuePosition = reader.readLong(offsets[4]);
  object.remoteId = reader.readString(offsets[5]);
  object.reservationDate = reader.readDateTime(offsets[6]);
  object.resourceId = reader.readString(offsets[7]);
  object.resourceTitle = reader.readString(offsets[8]);
  object.schoolId = reader.readString(offsets[9]);
  object.status = reader.readString(offsets[10]);
  return object;
}

P _libraryReservationIsarDeserializeProp<P>(
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
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _libraryReservationIsarGetId(LibraryReservationIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _libraryReservationIsarGetLinks(
  LibraryReservationIsar object,
) {
  return [];
}

void _libraryReservationIsarAttach(
  IsarCollection<dynamic> col,
  Id id,
  LibraryReservationIsar object,
) {
  object.id = id;
}

extension LibraryReservationIsarByIndex
    on IsarCollection<LibraryReservationIsar> {
  Future<LibraryReservationIsar?> getByRemoteId(String remoteId) {
    return getByIndex(r'remoteId', [remoteId]);
  }

  LibraryReservationIsar? getByRemoteIdSync(String remoteId) {
    return getByIndexSync(r'remoteId', [remoteId]);
  }

  Future<bool> deleteByRemoteId(String remoteId) {
    return deleteByIndex(r'remoteId', [remoteId]);
  }

  bool deleteByRemoteIdSync(String remoteId) {
    return deleteByIndexSync(r'remoteId', [remoteId]);
  }

  Future<List<LibraryReservationIsar?>> getAllByRemoteId(
    List<String> remoteIdValues,
  ) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'remoteId', values);
  }

  List<LibraryReservationIsar?> getAllByRemoteIdSync(
    List<String> remoteIdValues,
  ) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'remoteId', values);
  }

  Future<int> deleteAllByRemoteId(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'remoteId', values);
  }

  int deleteAllByRemoteIdSync(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'remoteId', values);
  }

  Future<Id> putByRemoteId(LibraryReservationIsar object) {
    return putByIndex(r'remoteId', object);
  }

  Id putByRemoteIdSync(LibraryReservationIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'remoteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRemoteId(List<LibraryReservationIsar> objects) {
    return putAllByIndex(r'remoteId', objects);
  }

  List<Id> putAllByRemoteIdSync(
    List<LibraryReservationIsar> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'remoteId', objects, saveLinks: saveLinks);
  }
}

extension LibraryReservationIsarQueryWhereSort
    on QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QWhere> {
  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LibraryReservationIsarQueryWhere
    on
        QueryBuilder<
          LibraryReservationIsar,
          LibraryReservationIsar,
          QWhereClause
        > {
  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterWhereClause
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterWhereClause
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterWhereClause
  >
  remoteIdEqualTo(String remoteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'remoteId', value: [remoteId]),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterWhereClause
  >
  remoteIdNotEqualTo(String remoteId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [],
                upper: [remoteId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [remoteId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [remoteId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'remoteId',
                lower: [],
                upper: [remoteId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension LibraryReservationIsarQueryFilter
    on
        QueryBuilder<
          LibraryReservationIsar,
          LibraryReservationIsar,
          QFilterCondition
        > {
  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'borrowerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'borrowerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'borrowerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'borrowerId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'borrowerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'borrowerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'borrowerId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'borrowerId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'borrowerId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'borrowerId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'borrowerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'borrowerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'borrowerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'borrowerName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'borrowerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'borrowerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'borrowerName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'borrowerName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'borrowerName', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'borrowerName', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'borrowerType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'borrowerType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'borrowerType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'borrowerType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'borrowerType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'borrowerType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'borrowerType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'borrowerType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'borrowerType', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  borrowerTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'borrowerType', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  expiryDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'expiryDate'),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  expiryDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'expiryDate'),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  expiryDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expiryDate', value: value),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  expiryDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expiryDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  expiryDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expiryDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  expiryDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expiryDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  queuePositionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'queuePosition', value: value),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  queuePositionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'queuePosition',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  queuePositionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'queuePosition',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  queuePositionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'queuePosition',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  remoteIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  remoteIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  remoteIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  remoteIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'remoteId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  remoteIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  remoteIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  remoteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'remoteId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  remoteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'remoteId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'remoteId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  reservationDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reservationDate', value: value),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  reservationDateGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reservationDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  reservationDateLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reservationDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  reservationDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reservationDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'resourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'resourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'resourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'resourceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'resourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'resourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'resourceId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'resourceId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'resourceId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'resourceId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceTitleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'resourceTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'resourceTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'resourceTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'resourceTitle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceTitleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'resourceTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceTitleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'resourceTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'resourceTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'resourceTitle',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'resourceTitle', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  resourceTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'resourceTitle', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'schoolId', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
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

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<
    LibraryReservationIsar,
    LibraryReservationIsar,
    QAfterFilterCondition
  >
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }
}

extension LibraryReservationIsarQueryObject
    on
        QueryBuilder<
          LibraryReservationIsar,
          LibraryReservationIsar,
          QFilterCondition
        > {}

extension LibraryReservationIsarQueryLinks
    on
        QueryBuilder<
          LibraryReservationIsar,
          LibraryReservationIsar,
          QFilterCondition
        > {}

extension LibraryReservationIsarQuerySortBy
    on QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QSortBy> {
  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByBorrowerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerId', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByBorrowerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerId', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByBorrowerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerName', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByBorrowerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerName', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByBorrowerType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerType', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByBorrowerTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerType', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryDate', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryDate', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByQueuePosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuePosition', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByQueuePositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuePosition', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByReservationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reservationDate', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByReservationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reservationDate', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByResourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceId', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByResourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceId', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByResourceTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceTitle', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByResourceTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceTitle', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension LibraryReservationIsarQuerySortThenBy
    on
        QueryBuilder<
          LibraryReservationIsar,
          LibraryReservationIsar,
          QSortThenBy
        > {
  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByBorrowerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerId', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByBorrowerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerId', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByBorrowerName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerName', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByBorrowerNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerName', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByBorrowerType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerType', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByBorrowerTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'borrowerType', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryDate', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiryDate', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByQueuePosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuePosition', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByQueuePositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuePosition', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByReservationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reservationDate', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByReservationDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reservationDate', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByResourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceId', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByResourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceId', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByResourceTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceTitle', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByResourceTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resourceTitle', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension LibraryReservationIsarQueryWhereDistinct
    on QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QDistinct> {
  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QDistinct>
  distinctByBorrowerId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'borrowerId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QDistinct>
  distinctByBorrowerName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'borrowerName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QDistinct>
  distinctByBorrowerType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'borrowerType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QDistinct>
  distinctByExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiryDate');
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QDistinct>
  distinctByQueuePosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'queuePosition');
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QDistinct>
  distinctByRemoteId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QDistinct>
  distinctByReservationDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reservationDate');
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QDistinct>
  distinctByResourceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resourceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QDistinct>
  distinctByResourceTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'resourceTitle',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QDistinct>
  distinctBySchoolId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LibraryReservationIsar, LibraryReservationIsar, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension LibraryReservationIsarQueryProperty
    on
        QueryBuilder<
          LibraryReservationIsar,
          LibraryReservationIsar,
          QQueryProperty
        > {
  QueryBuilder<LibraryReservationIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LibraryReservationIsar, String, QQueryOperations>
  borrowerIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'borrowerId');
    });
  }

  QueryBuilder<LibraryReservationIsar, String, QQueryOperations>
  borrowerNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'borrowerName');
    });
  }

  QueryBuilder<LibraryReservationIsar, String, QQueryOperations>
  borrowerTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'borrowerType');
    });
  }

  QueryBuilder<LibraryReservationIsar, DateTime?, QQueryOperations>
  expiryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiryDate');
    });
  }

  QueryBuilder<LibraryReservationIsar, int, QQueryOperations>
  queuePositionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'queuePosition');
    });
  }

  QueryBuilder<LibraryReservationIsar, String, QQueryOperations>
  remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<LibraryReservationIsar, DateTime, QQueryOperations>
  reservationDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reservationDate');
    });
  }

  QueryBuilder<LibraryReservationIsar, String, QQueryOperations>
  resourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resourceId');
    });
  }

  QueryBuilder<LibraryReservationIsar, String, QQueryOperations>
  resourceTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resourceTitle');
    });
  }

  QueryBuilder<LibraryReservationIsar, String, QQueryOperations>
  schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<LibraryReservationIsar, String, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
