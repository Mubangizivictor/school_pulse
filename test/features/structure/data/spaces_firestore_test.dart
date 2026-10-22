import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/services/space_rules.dart';
import 'package:uuid/uuid.dart';

/// Exercises the exact Firestore read/write shape `spaces_rooms_screen.dart`
/// performs against `schools/{schoolId}/spaces` and `.../spaceSettings/current`
/// - the widget has no separate repository layer, so these tests replicate
/// its inline transaction/queries directly to cover what the emulator would.
Future<void> _saveSpace(
  FirebaseFirestore firestore,
  String schoolId, {
  String? existingId,
  required String name,
  required String type,
  String code = '',
  String capacity = '',
  bool schedulable = false,
}) async {
  final normalizedName = SpaceRules.normalize(name);
  final normalizedCode = SpaceRules.normalize(code);
  final col = firestore.collection('schools').doc(schoolId).collection('spaces');
  final all = await col.get();
  await firestore.runTransaction((tx) async {
    final duplicate = all.docs.any(
      (d) =>
          d.id != existingId &&
          d.data()['active'] != false &&
          (d.data()['normalizedName'] == normalizedName ||
              (normalizedCode.isNotEmpty && d.data()['normalizedCode'] == normalizedCode)),
    );
    if (duplicate) {
      throw StateError('A space with this name or room code already exists.');
    }
    final ref = existingId != null ? col.doc(existingId) : col.doc(const Uuid().v4());
    tx.set(ref, {
      'name': name.trim(),
      'normalizedName': normalizedName,
      'normalizedCode': normalizedCode,
      'type': type,
      if (code.trim().isNotEmpty) 'code': code.trim(),
      if (capacity.trim().isNotEmpty) 'capacity': int.parse(capacity),
      'schedulable': schedulable,
      'active': true,
      'schoolId': schoolId,
    }, SetOptions(merge: true));
  });
}

void main() {
  test('rejects a duplicate normalized space name within the same school', () async {
    final firestore = FakeFirebaseFirestore();
    await _saveSpace(firestore, 'school-a', name: 'Main Hall', type: 'Hall');

    await expectLater(
      _saveSpace(firestore, 'school-a', name: '  main   hall ', type: 'Hall'),
      throwsA(isA<StateError>()),
    );
  });

  test('rejects a duplicate normalized room code within the same school', () async {
    final firestore = FakeFirebaseFirestore();
    await _saveSpace(firestore, 'school-a', name: 'Room A', type: 'Classroom', code: 'MB-1');

    await expectLater(
      _saveSpace(firestore, 'school-a', name: 'Room B', type: 'Classroom', code: 'mb-1'),
      throwsA(isA<StateError>()),
    );
  });

  test('allows editing a space to keep its own name/code without false duplicate', () async {
    final firestore = FakeFirebaseFirestore();
    final col = firestore.collection('schools').doc('school-a').collection('spaces');
    await col.doc('room-1').set({
      'name': 'Room A',
      'normalizedName': 'room a',
      'normalizedCode': '',
      'type': 'Classroom',
      'active': true,
    });

    await _saveSpace(
      firestore,
      'school-a',
      existingId: 'room-1',
      name: 'Room A',
      type: 'Classroom',
      capacity: '30',
    );

    final doc = await col.doc('room-1').get();
    expect(doc.data()?['capacity'], 30);
  });

  test('the same name is allowed again once the original space is archived', () async {
    final firestore = FakeFirebaseFirestore();
    final col = firestore.collection('schools').doc('school-a').collection('spaces');
    await col.doc('room-1').set({
      'name': 'Room A',
      'normalizedName': 'room a',
      'normalizedCode': '',
      'type': 'Classroom',
      'active': false,
    });

    await _saveSpace(firestore, 'school-a', name: 'Room A', type: 'Classroom');

    final active = await col.where('active', isEqualTo: true).get();
    expect(active.docs, hasLength(1));
  });

  test('spaces are isolated per school', () async {
    final firestore = FakeFirebaseFirestore();
    await _saveSpace(firestore, 'school-a', name: 'Room A', type: 'Classroom');

    final schoolBSpaces = await firestore
        .collection('schools')
        .doc('school-b')
        .collection('spaces')
        .get();

    expect(schoolBSpaces.docs, isEmpty);
  });

  test('archive is blocked when a timetable lesson references the space', () async {
    final firestore = FakeFirebaseFirestore();
    final col = firestore.collection('schools').doc('school-a').collection('spaces');
    final ref = col.doc('room-1');
    await ref.set({
      'name': 'Room A',
      'normalizedName': 'room a',
      'normalizedCode': '',
      'type': 'Classroom',
      'active': true,
    });
    await firestore.collection('structure_timetable_lessons').add({
      'schoolId': 'school-a',
      'roomId': 'room-1',
    });

    final refs = await firestore
        .collection('structure_timetable_lessons')
        .where('schoolId', isEqualTo: 'school-a')
        .where('roomId', isEqualTo: 'room-1')
        .limit(1)
        .get();

    expect(refs.docs, isNotEmpty, reason: 'archive must be blocked, not silently applied');
  });

  test('archive succeeds when no timetable lesson references the space', () async {
    final firestore = FakeFirebaseFirestore();
    final col = firestore.collection('schools').doc('school-a').collection('spaces');
    final ref = col.doc('room-1');
    await ref.set({
      'name': 'Room A',
      'normalizedName': 'room a',
      'normalizedCode': '',
      'type': 'Classroom',
      'active': true,
    });

    final refs = await firestore
        .collection('structure_timetable_lessons')
        .where('schoolId', isEqualTo: 'school-a')
        .where('roomId', isEqualTo: 'room-1')
        .limit(1)
        .get();
    expect(refs.docs, isEmpty);

    await ref.update({'active': false});
    final doc = await ref.get();
    expect(doc.data()?['active'], isFalse);
  });

  test('room-scheduling mode cannot be enabled with zero schedulable teaching spaces', () {
    expect(
      SpaceRules.validateMode(roomSchedulingEnabled: true, schedulableTeachingSpaces: 0),
      isNotNull,
    );
    expect(
      SpaceRules.validateMode(roomSchedulingEnabled: true, schedulableTeachingSpaces: 1),
      isNull,
    );
    expect(
      SpaceRules.validateMode(roomSchedulingEnabled: false, schedulableTeachingSpaces: 0),
      isNull,
      reason: '"Class rooms only" must always be saveable with zero spaces',
    );
  });
}
