// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinic_visit_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetClinicVisitIsarCollection on Isar {
  IsarCollection<ClinicVisitIsar> get clinicVisitIsars => this.collection();
}

const ClinicVisitIsarSchema = CollectionSchema(
  name: r'ClinicVisitIsar',
  id: 8750360573780631684,
  properties: {
    r'bloodPressure': PropertySchema(
      id: 0,
      name: r'bloodPressure',
      type: IsarType.string,
    ),
    r'dateTime': PropertySchema(
      id: 1,
      name: r'dateTime',
      type: IsarType.dateTime,
    ),
    r'diagnosis': PropertySchema(
      id: 2,
      name: r'diagnosis',
      type: IsarType.string,
    ),
    r'followUpRequired': PropertySchema(
      id: 3,
      name: r'followUpRequired',
      type: IsarType.bool,
    ),
    r'medicationsGiven': PropertySchema(
      id: 4,
      name: r'medicationsGiven',
      type: IsarType.objectList,
      target: r'AdministeredMedicationIsar',
    ),
    r'observationNotes': PropertySchema(
      id: 5,
      name: r'observationNotes',
      type: IsarType.string,
    ),
    r'outcome': PropertySchema(
      id: 6,
      name: r'outcome',
      type: IsarType.string,
    ),
    r'oxygenSaturation': PropertySchema(
      id: 7,
      name: r'oxygenSaturation',
      type: IsarType.long,
    ),
    r'pulseRate': PropertySchema(
      id: 8,
      name: r'pulseRate',
      type: IsarType.long,
    ),
    r'reason': PropertySchema(
      id: 9,
      name: r'reason',
      type: IsarType.string,
    ),
    r'recordedBy': PropertySchema(
      id: 10,
      name: r'recordedBy',
      type: IsarType.string,
    ),
    r'schoolId': PropertySchema(
      id: 11,
      name: r'schoolId',
      type: IsarType.string,
    ),
    r'staffId': PropertySchema(
      id: 12,
      name: r'staffId',
      type: IsarType.string,
    ),
    r'studentId': PropertySchema(
      id: 13,
      name: r'studentId',
      type: IsarType.string,
    ),
    r'symptoms': PropertySchema(
      id: 14,
      name: r'symptoms',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 15,
      name: r'syncStatus',
      type: IsarType.string,
    ),
    r'temperature': PropertySchema(
      id: 16,
      name: r'temperature',
      type: IsarType.double,
    ),
    r'treatmentProvided': PropertySchema(
      id: 17,
      name: r'treatmentProvided',
      type: IsarType.string,
    ),
    r'visitId': PropertySchema(
      id: 18,
      name: r'visitId',
      type: IsarType.string,
    ),
    r'weight': PropertySchema(
      id: 19,
      name: r'weight',
      type: IsarType.double,
    )
  },
  estimateSize: _clinicVisitIsarEstimateSize,
  serialize: _clinicVisitIsarSerialize,
  deserialize: _clinicVisitIsarDeserialize,
  deserializeProp: _clinicVisitIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'visitId': IndexSchema(
      id: -214845532434906064,
      name: r'visitId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'visitId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'schoolId': IndexSchema(
      id: 6631843591736686975,
      name: r'schoolId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'schoolId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'studentId': IndexSchema(
      id: -6791323312898281473,
      name: r'studentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'studentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'dateTime': IndexSchema(
      id: -138851979697481250,
      name: r'dateTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dateTime',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'syncStatus': IndexSchema(
      id: 8239539375045684509,
      name: r'syncStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'syncStatus',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'AdministeredMedicationIsar': AdministeredMedicationIsarSchema
  },
  getId: _clinicVisitIsarGetId,
  getLinks: _clinicVisitIsarGetLinks,
  attach: _clinicVisitIsarAttach,
  version: '3.1.0+1',
);

int _clinicVisitIsarEstimateSize(
  ClinicVisitIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.bloodPressure;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.diagnosis;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.medicationsGiven.length * 3;
  {
    final offsets = allOffsets[AdministeredMedicationIsar]!;
    for (var i = 0; i < object.medicationsGiven.length; i++) {
      final value = object.medicationsGiven[i];
      bytesCount += AdministeredMedicationIsarSchema.estimateSize(
          value, offsets, allOffsets);
    }
  }
  {
    final value = object.observationNotes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.outcome.length * 3;
  bytesCount += 3 + object.reason.length * 3;
  bytesCount += 3 + object.recordedBy.length * 3;
  bytesCount += 3 + object.schoolId.length * 3;
  {
    final value = object.staffId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.studentId.length * 3;
  bytesCount += 3 + object.symptoms.length * 3;
  bytesCount += 3 + object.syncStatus.length * 3;
  {
    final value = object.treatmentProvided;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.visitId.length * 3;
  return bytesCount;
}

void _clinicVisitIsarSerialize(
  ClinicVisitIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bloodPressure);
  writer.writeDateTime(offsets[1], object.dateTime);
  writer.writeString(offsets[2], object.diagnosis);
  writer.writeBool(offsets[3], object.followUpRequired);
  writer.writeObjectList<AdministeredMedicationIsar>(
    offsets[4],
    allOffsets,
    AdministeredMedicationIsarSchema.serialize,
    object.medicationsGiven,
  );
  writer.writeString(offsets[5], object.observationNotes);
  writer.writeString(offsets[6], object.outcome);
  writer.writeLong(offsets[7], object.oxygenSaturation);
  writer.writeLong(offsets[8], object.pulseRate);
  writer.writeString(offsets[9], object.reason);
  writer.writeString(offsets[10], object.recordedBy);
  writer.writeString(offsets[11], object.schoolId);
  writer.writeString(offsets[12], object.staffId);
  writer.writeString(offsets[13], object.studentId);
  writer.writeString(offsets[14], object.symptoms);
  writer.writeString(offsets[15], object.syncStatus);
  writer.writeDouble(offsets[16], object.temperature);
  writer.writeString(offsets[17], object.treatmentProvided);
  writer.writeString(offsets[18], object.visitId);
  writer.writeDouble(offsets[19], object.weight);
}

ClinicVisitIsar _clinicVisitIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ClinicVisitIsar();
  object.bloodPressure = reader.readStringOrNull(offsets[0]);
  object.dateTime = reader.readDateTime(offsets[1]);
  object.diagnosis = reader.readStringOrNull(offsets[2]);
  object.followUpRequired = reader.readBool(offsets[3]);
  object.id = id;
  object.medicationsGiven = reader.readObjectList<AdministeredMedicationIsar>(
        offsets[4],
        AdministeredMedicationIsarSchema.deserialize,
        allOffsets,
        AdministeredMedicationIsar(),
      ) ??
      [];
  object.observationNotes = reader.readStringOrNull(offsets[5]);
  object.outcome = reader.readString(offsets[6]);
  object.oxygenSaturation = reader.readLongOrNull(offsets[7]);
  object.pulseRate = reader.readLongOrNull(offsets[8]);
  object.reason = reader.readString(offsets[9]);
  object.recordedBy = reader.readString(offsets[10]);
  object.schoolId = reader.readString(offsets[11]);
  object.staffId = reader.readStringOrNull(offsets[12]);
  object.studentId = reader.readString(offsets[13]);
  object.symptoms = reader.readString(offsets[14]);
  object.syncStatus = reader.readString(offsets[15]);
  object.temperature = reader.readDoubleOrNull(offsets[16]);
  object.treatmentProvided = reader.readStringOrNull(offsets[17]);
  object.visitId = reader.readString(offsets[18]);
  object.weight = reader.readDoubleOrNull(offsets[19]);
  return object;
}

P _clinicVisitIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readObjectList<AdministeredMedicationIsar>(
            offset,
            AdministeredMedicationIsarSchema.deserialize,
            allOffsets,
            AdministeredMedicationIsar(),
          ) ??
          []) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readDoubleOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _clinicVisitIsarGetId(ClinicVisitIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _clinicVisitIsarGetLinks(ClinicVisitIsar object) {
  return [];
}

void _clinicVisitIsarAttach(
    IsarCollection<dynamic> col, Id id, ClinicVisitIsar object) {
  object.id = id;
}

extension ClinicVisitIsarByIndex on IsarCollection<ClinicVisitIsar> {
  Future<ClinicVisitIsar?> getByVisitId(String visitId) {
    return getByIndex(r'visitId', [visitId]);
  }

  ClinicVisitIsar? getByVisitIdSync(String visitId) {
    return getByIndexSync(r'visitId', [visitId]);
  }

  Future<bool> deleteByVisitId(String visitId) {
    return deleteByIndex(r'visitId', [visitId]);
  }

  bool deleteByVisitIdSync(String visitId) {
    return deleteByIndexSync(r'visitId', [visitId]);
  }

  Future<List<ClinicVisitIsar?>> getAllByVisitId(List<String> visitIdValues) {
    final values = visitIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'visitId', values);
  }

  List<ClinicVisitIsar?> getAllByVisitIdSync(List<String> visitIdValues) {
    final values = visitIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'visitId', values);
  }

  Future<int> deleteAllByVisitId(List<String> visitIdValues) {
    final values = visitIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'visitId', values);
  }

  int deleteAllByVisitIdSync(List<String> visitIdValues) {
    final values = visitIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'visitId', values);
  }

  Future<Id> putByVisitId(ClinicVisitIsar object) {
    return putByIndex(r'visitId', object);
  }

  Id putByVisitIdSync(ClinicVisitIsar object, {bool saveLinks = true}) {
    return putByIndexSync(r'visitId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByVisitId(List<ClinicVisitIsar> objects) {
    return putAllByIndex(r'visitId', objects);
  }

  List<Id> putAllByVisitIdSync(List<ClinicVisitIsar> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'visitId', objects, saveLinks: saveLinks);
  }
}

extension ClinicVisitIsarQueryWhereSort
    on QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QWhere> {
  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhere> anyDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dateTime'),
      );
    });
  }
}

extension ClinicVisitIsarQueryWhere
    on QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QWhereClause> {
  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause> idBetween(
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
      visitIdEqualTo(String visitId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'visitId',
        value: [visitId],
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
      visitIdNotEqualTo(String visitId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visitId',
              lower: [],
              upper: [visitId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visitId',
              lower: [visitId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visitId',
              lower: [visitId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'visitId',
              lower: [],
              upper: [visitId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
      schoolIdEqualTo(String schoolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'schoolId',
        value: [schoolId],
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
      studentIdEqualTo(String studentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'studentId',
        value: [studentId],
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
      studentIdNotEqualTo(String studentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studentId',
              lower: [],
              upper: [studentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studentId',
              lower: [studentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studentId',
              lower: [studentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'studentId',
              lower: [],
              upper: [studentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
      dateTimeEqualTo(DateTime dateTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dateTime',
        value: [dateTime],
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
      dateTimeNotEqualTo(DateTime dateTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateTime',
              lower: [],
              upper: [dateTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateTime',
              lower: [dateTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateTime',
              lower: [dateTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateTime',
              lower: [],
              upper: [dateTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
      dateTimeGreaterThan(
    DateTime dateTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateTime',
        lower: [dateTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
      dateTimeLessThan(
    DateTime dateTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateTime',
        lower: [],
        upper: [dateTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
      dateTimeBetween(
    DateTime lowerDateTime,
    DateTime upperDateTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateTime',
        lower: [lowerDateTime],
        includeLower: includeLower,
        upper: [upperDateTime],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
      syncStatusEqualTo(String syncStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'syncStatus',
        value: [syncStatus],
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterWhereClause>
      syncStatusNotEqualTo(String syncStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [],
              upper: [syncStatus],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [syncStatus],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [syncStatus],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'syncStatus',
              lower: [],
              upper: [syncStatus],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ClinicVisitIsarQueryFilter
    on QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QFilterCondition> {
  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      bloodPressureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bloodPressure',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      bloodPressureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bloodPressure',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      bloodPressureEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloodPressure',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      bloodPressureGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bloodPressure',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      bloodPressureLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bloodPressure',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      bloodPressureBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bloodPressure',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      bloodPressureStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bloodPressure',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      bloodPressureEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bloodPressure',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      bloodPressureContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bloodPressure',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      bloodPressureMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bloodPressure',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      bloodPressureIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloodPressure',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      bloodPressureIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bloodPressure',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      dateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      dateTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      dateTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      dateTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      diagnosisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'diagnosis',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      diagnosisIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'diagnosis',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      diagnosisEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'diagnosis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      diagnosisGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'diagnosis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      diagnosisLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'diagnosis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      diagnosisBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'diagnosis',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      diagnosisStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'diagnosis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      diagnosisEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'diagnosis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      diagnosisContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'diagnosis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      diagnosisMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'diagnosis',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      diagnosisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'diagnosis',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      diagnosisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'diagnosis',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      followUpRequiredEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'followUpRequired',
        value: value,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      medicationsGivenLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicationsGiven',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      medicationsGivenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicationsGiven',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      medicationsGivenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicationsGiven',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      medicationsGivenLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicationsGiven',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      medicationsGivenLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicationsGiven',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      medicationsGivenLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'medicationsGiven',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      observationNotesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'observationNotes',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      observationNotesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'observationNotes',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      observationNotesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'observationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      observationNotesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'observationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      observationNotesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'observationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      observationNotesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'observationNotes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      observationNotesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'observationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      observationNotesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'observationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      observationNotesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'observationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      observationNotesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'observationNotes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      observationNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'observationNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      observationNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'observationNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      outcomeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outcome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      outcomeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'outcome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      outcomeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'outcome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      outcomeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'outcome',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      outcomeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'outcome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      outcomeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'outcome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      outcomeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'outcome',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      outcomeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'outcome',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      outcomeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'outcome',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      outcomeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'outcome',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      oxygenSaturationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'oxygenSaturation',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      oxygenSaturationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'oxygenSaturation',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      oxygenSaturationEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oxygenSaturation',
        value: value,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      oxygenSaturationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'oxygenSaturation',
        value: value,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      oxygenSaturationLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'oxygenSaturation',
        value: value,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      oxygenSaturationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'oxygenSaturation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      pulseRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pulseRate',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      pulseRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pulseRate',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      pulseRateEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pulseRate',
        value: value,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      pulseRateGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pulseRate',
        value: value,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      pulseRateLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pulseRate',
        value: value,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      pulseRateBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pulseRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      reasonEqualTo(
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      reasonGreaterThan(
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      reasonLessThan(
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      reasonBetween(
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      reasonStartsWith(
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      reasonEndsWith(
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      recordedByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      recordedByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      recordedByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      recordedByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      recordedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recordedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      recordedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recordedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      recordedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recordedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      recordedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recordedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      recordedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      recordedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recordedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      schoolIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      schoolIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      schoolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      schoolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      staffIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'staffId',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      staffIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'staffId',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      staffIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'staffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      staffIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'staffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      staffIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'staffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      staffIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'staffId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      staffIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'staffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      staffIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'staffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      staffIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'staffId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      staffIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'staffId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      staffIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'staffId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      staffIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'staffId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      studentIdEqualTo(
    String value, {
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      studentIdGreaterThan(
    String value, {
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      studentIdLessThan(
    String value, {
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      studentIdBetween(
    String lower,
    String upper, {
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
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

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      studentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'studentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      studentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'studentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      studentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      studentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'studentId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      symptomsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symptoms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      symptomsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'symptoms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      symptomsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'symptoms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      symptomsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'symptoms',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      symptomsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'symptoms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      symptomsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'symptoms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      symptomsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'symptoms',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      symptomsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'symptoms',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      symptomsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symptoms',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      symptomsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'symptoms',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      syncStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      syncStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      syncStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      syncStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      syncStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      syncStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      temperatureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'temperature',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      temperatureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'temperature',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      temperatureEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      temperatureGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      temperatureLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      temperatureBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'temperature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      treatmentProvidedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'treatmentProvided',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      treatmentProvidedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'treatmentProvided',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      treatmentProvidedEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'treatmentProvided',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      treatmentProvidedGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'treatmentProvided',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      treatmentProvidedLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'treatmentProvided',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      treatmentProvidedBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'treatmentProvided',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      treatmentProvidedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'treatmentProvided',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      treatmentProvidedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'treatmentProvided',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      treatmentProvidedContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'treatmentProvided',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      treatmentProvidedMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'treatmentProvided',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      treatmentProvidedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'treatmentProvided',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      treatmentProvidedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'treatmentProvided',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      visitIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      visitIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'visitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      visitIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'visitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      visitIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'visitId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      visitIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'visitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      visitIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'visitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      visitIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'visitId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      visitIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'visitId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      visitIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visitId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      visitIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'visitId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      weightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weight',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      weightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weight',
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      weightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      weightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      weightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      weightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension ClinicVisitIsarQueryObject
    on QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QFilterCondition> {
  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterFilterCondition>
      medicationsGivenElement(FilterQuery<AdministeredMedicationIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'medicationsGiven');
    });
  }
}

extension ClinicVisitIsarQueryLinks
    on QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QFilterCondition> {}

extension ClinicVisitIsarQuerySortBy
    on QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QSortBy> {
  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByBloodPressure() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodPressure', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByBloodPressureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodPressure', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByDiagnosis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diagnosis', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByDiagnosisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diagnosis', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByFollowUpRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpRequired', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByFollowUpRequiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpRequired', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByObservationNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observationNotes', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByObservationNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observationNotes', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy> sortByOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByOutcomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByOxygenSaturation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oxygenSaturation', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByOxygenSaturationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oxygenSaturation', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByPulseRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pulseRate', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByPulseRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pulseRate', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy> sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByRecordedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedBy', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByRecordedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedBy', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy> sortByStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortBySymptoms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptoms', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortBySymptomsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptoms', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByTreatmentProvided() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'treatmentProvided', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByTreatmentProvidedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'treatmentProvided', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy> sortByVisitId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitId', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByVisitIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitId', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy> sortByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      sortByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension ClinicVisitIsarQuerySortThenBy
    on QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QSortThenBy> {
  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByBloodPressure() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodPressure', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByBloodPressureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodPressure', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByDiagnosis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diagnosis', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByDiagnosisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diagnosis', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByFollowUpRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpRequired', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByFollowUpRequiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpRequired', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByObservationNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observationNotes', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByObservationNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observationNotes', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy> thenByOutcome() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByOutcomeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'outcome', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByOxygenSaturation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oxygenSaturation', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByOxygenSaturationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oxygenSaturation', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByPulseRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pulseRate', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByPulseRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pulseRate', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy> thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByRecordedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedBy', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByRecordedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedBy', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenBySchoolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenBySchoolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolId', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy> thenByStaffId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByStaffIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'staffId', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByStudentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByStudentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'studentId', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenBySymptoms() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptoms', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenBySymptomsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptoms', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByTreatmentProvided() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'treatmentProvided', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByTreatmentProvidedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'treatmentProvided', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy> thenByVisitId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitId', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByVisitIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visitId', Sort.desc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy> thenByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QAfterSortBy>
      thenByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension ClinicVisitIsarQueryWhereDistinct
    on QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct> {
  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct>
      distinctByBloodPressure({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bloodPressure',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct>
      distinctByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTime');
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct> distinctByDiagnosis(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'diagnosis', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct>
      distinctByFollowUpRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'followUpRequired');
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct>
      distinctByObservationNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'observationNotes',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct> distinctByOutcome(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'outcome', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct>
      distinctByOxygenSaturation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'oxygenSaturation');
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct>
      distinctByPulseRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pulseRate');
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct> distinctByReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct>
      distinctByRecordedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct> distinctBySchoolId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct> distinctByStaffId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'staffId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct> distinctByStudentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'studentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct> distinctBySymptoms(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'symptoms', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct>
      distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct>
      distinctByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'temperature');
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct>
      distinctByTreatmentProvided({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'treatmentProvided',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct> distinctByVisitId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visitId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QDistinct> distinctByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weight');
    });
  }
}

extension ClinicVisitIsarQueryProperty
    on QueryBuilder<ClinicVisitIsar, ClinicVisitIsar, QQueryProperty> {
  QueryBuilder<ClinicVisitIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ClinicVisitIsar, String?, QQueryOperations>
      bloodPressureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bloodPressure');
    });
  }

  QueryBuilder<ClinicVisitIsar, DateTime, QQueryOperations> dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTime');
    });
  }

  QueryBuilder<ClinicVisitIsar, String?, QQueryOperations> diagnosisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diagnosis');
    });
  }

  QueryBuilder<ClinicVisitIsar, bool, QQueryOperations>
      followUpRequiredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'followUpRequired');
    });
  }

  QueryBuilder<ClinicVisitIsar, List<AdministeredMedicationIsar>,
      QQueryOperations> medicationsGivenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'medicationsGiven');
    });
  }

  QueryBuilder<ClinicVisitIsar, String?, QQueryOperations>
      observationNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'observationNotes');
    });
  }

  QueryBuilder<ClinicVisitIsar, String, QQueryOperations> outcomeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'outcome');
    });
  }

  QueryBuilder<ClinicVisitIsar, int?, QQueryOperations>
      oxygenSaturationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'oxygenSaturation');
    });
  }

  QueryBuilder<ClinicVisitIsar, int?, QQueryOperations> pulseRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pulseRate');
    });
  }

  QueryBuilder<ClinicVisitIsar, String, QQueryOperations> reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<ClinicVisitIsar, String, QQueryOperations> recordedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordedBy');
    });
  }

  QueryBuilder<ClinicVisitIsar, String, QQueryOperations> schoolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolId');
    });
  }

  QueryBuilder<ClinicVisitIsar, String?, QQueryOperations> staffIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'staffId');
    });
  }

  QueryBuilder<ClinicVisitIsar, String, QQueryOperations> studentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studentId');
    });
  }

  QueryBuilder<ClinicVisitIsar, String, QQueryOperations> symptomsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'symptoms');
    });
  }

  QueryBuilder<ClinicVisitIsar, String, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<ClinicVisitIsar, double?, QQueryOperations>
      temperatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'temperature');
    });
  }

  QueryBuilder<ClinicVisitIsar, String?, QQueryOperations>
      treatmentProvidedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'treatmentProvided');
    });
  }

  QueryBuilder<ClinicVisitIsar, String, QQueryOperations> visitIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visitId');
    });
  }

  QueryBuilder<ClinicVisitIsar, double?, QQueryOperations> weightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weight');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const AdministeredMedicationIsarSchema = Schema(
  name: r'AdministeredMedicationIsar',
  id: -5245695555380723291,
  properties: {
    r'administeredBy': PropertySchema(
      id: 0,
      name: r'administeredBy',
      type: IsarType.string,
    ),
    r'dosage': PropertySchema(
      id: 1,
      name: r'dosage',
      type: IsarType.string,
    ),
    r'medicationId': PropertySchema(
      id: 2,
      name: r'medicationId',
      type: IsarType.string,
    ),
    r'medicationName': PropertySchema(
      id: 3,
      name: r'medicationName',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 4,
      name: r'notes',
      type: IsarType.string,
    ),
    r'quantity': PropertySchema(
      id: 5,
      name: r'quantity',
      type: IsarType.long,
    ),
    r'timeAdministered': PropertySchema(
      id: 6,
      name: r'timeAdministered',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _administeredMedicationIsarEstimateSize,
  serialize: _administeredMedicationIsarSerialize,
  deserialize: _administeredMedicationIsarDeserialize,
  deserializeProp: _administeredMedicationIsarDeserializeProp,
);

int _administeredMedicationIsarEstimateSize(
  AdministeredMedicationIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.administeredBy.length * 3;
  bytesCount += 3 + object.dosage.length * 3;
  bytesCount += 3 + object.medicationId.length * 3;
  bytesCount += 3 + object.medicationName.length * 3;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _administeredMedicationIsarSerialize(
  AdministeredMedicationIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.administeredBy);
  writer.writeString(offsets[1], object.dosage);
  writer.writeString(offsets[2], object.medicationId);
  writer.writeString(offsets[3], object.medicationName);
  writer.writeString(offsets[4], object.notes);
  writer.writeLong(offsets[5], object.quantity);
  writer.writeDateTime(offsets[6], object.timeAdministered);
}

AdministeredMedicationIsar _administeredMedicationIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AdministeredMedicationIsar();
  object.administeredBy = reader.readString(offsets[0]);
  object.dosage = reader.readString(offsets[1]);
  object.medicationId = reader.readString(offsets[2]);
  object.medicationName = reader.readString(offsets[3]);
  object.notes = reader.readStringOrNull(offsets[4]);
  object.quantity = reader.readLong(offsets[5]);
  object.timeAdministered = reader.readDateTimeOrNull(offsets[6]);
  return object;
}

P _administeredMedicationIsarDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension AdministeredMedicationIsarQueryFilter on QueryBuilder<
    AdministeredMedicationIsar, AdministeredMedicationIsar, QFilterCondition> {
  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> administeredByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'administeredBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> administeredByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'administeredBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> administeredByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'administeredBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> administeredByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'administeredBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> administeredByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'administeredBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> administeredByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'administeredBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
          QAfterFilterCondition>
      administeredByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'administeredBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
          QAfterFilterCondition>
      administeredByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'administeredBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> administeredByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'administeredBy',
        value: '',
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> administeredByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'administeredBy',
        value: '',
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> dosageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> dosageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> dosageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> dosageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dosage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> dosageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> dosageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
          QAfterFilterCondition>
      dosageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dosage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
          QAfterFilterCondition>
      dosageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dosage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> dosageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dosage',
        value: '',
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> dosageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dosage',
        value: '',
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'medicationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'medicationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'medicationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'medicationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'medicationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
          QAfterFilterCondition>
      medicationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'medicationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
          QAfterFilterCondition>
      medicationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'medicationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicationId',
        value: '',
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'medicationId',
        value: '',
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'medicationName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
          QAfterFilterCondition>
      medicationNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'medicationName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
          QAfterFilterCondition>
      medicationNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'medicationName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'medicationName',
        value: '',
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> medicationNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'medicationName',
        value: '',
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> notesEqualTo(
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

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> notesGreaterThan(
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

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> notesLessThan(
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

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> notesBetween(
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

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> notesStartsWith(
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

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> notesEndsWith(
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

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
          QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
          QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> quantityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantity',
        value: value,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
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

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
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

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
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

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> timeAdministeredIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'timeAdministered',
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> timeAdministeredIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'timeAdministered',
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> timeAdministeredEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeAdministered',
        value: value,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> timeAdministeredGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeAdministered',
        value: value,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> timeAdministeredLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeAdministered',
        value: value,
      ));
    });
  }

  QueryBuilder<AdministeredMedicationIsar, AdministeredMedicationIsar,
      QAfterFilterCondition> timeAdministeredBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeAdministered',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AdministeredMedicationIsarQueryObject on QueryBuilder<
    AdministeredMedicationIsar, AdministeredMedicationIsar, QFilterCondition> {}
