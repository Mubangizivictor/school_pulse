class SpaceRules {
  static const teachingTypes = {
    'Classroom',
    'Science lab',
    'Computer lab',
    'Library',
    'Hall',
  };

  static bool defaultSchedulable(String type) => teachingTypes.contains(type);

  static String normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static String? validate({
    required String name,
    required String type,
    String capacity = '',
  }) {
    if (name.trim().isEmpty) return 'Enter a space name.';
    if (type.trim().isEmpty) return 'Select a space type.';
    if (capacity.trim().isNotEmpty &&
        (int.tryParse(capacity) == null || int.parse(capacity) <= 0)) {
      return 'Capacity must be a positive whole number.';
    }
    return null;
  }

  static String? validateMode({
    required bool roomSchedulingEnabled,
    required int schedulableTeachingSpaces,
  }) => roomSchedulingEnabled && schedulableTeachingSpaces == 0
      ? 'Add at least one teaching space that can be used in the timetable.'
      : null;
}
