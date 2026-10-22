import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/services/space_rules.dart';

void main() {
  test('requires valid space details and positive whole-number capacity', () {
    expect(SpaceRules.validate(name: '', type: 'Classroom'), isNotNull);
    expect(
      SpaceRules.validate(name: 'Lab 1', type: '', capacity: '20'),
      isNotNull,
    );
    expect(
      SpaceRules.validate(name: 'Lab 1', type: 'Science lab', capacity: '0'),
      isNotNull,
    );
    expect(
      SpaceRules.validate(name: 'Lab 1', type: 'Science lab', capacity: '24'),
      isNull,
    );
  });

  test('named-room scheduling needs a schedulable teaching space', () {
    expect(
      SpaceRules.validateMode(
        roomSchedulingEnabled: false,
        schedulableTeachingSpaces: 0,
      ),
      isNull,
    );
    expect(
      SpaceRules.validateMode(
        roomSchedulingEnabled: true,
        schedulableTeachingSpaces: 0,
      ),
      isNotNull,
    );
    expect(
      SpaceRules.validateMode(
        roomSchedulingEnabled: true,
        schedulableTeachingSpaces: 1,
      ),
      isNull,
    );
  });

  test('timetable default follows type instead of a geographic policy', () {
    expect(SpaceRules.defaultSchedulable('Classroom'), isTrue);
    expect(SpaceRules.defaultSchedulable('Library'), isTrue);
    expect(SpaceRules.defaultSchedulable('Dormitory'), isFalse);
    expect(SpaceRules.normalize('  Main   Hall '), 'main hall');
  });
}
