import '../entities/institution_profile.dart';
import '../entities/structure_entities.dart';

/// Resolves setup suggestions from school-owned configuration only.
///
/// There is intentionally no national/curriculum class list in this class.
/// An administrator may put a comma or newline separated list after
/// `Classes:` in an education level's description (for example
/// `Classes: Year 1, Year 2`). This makes a school's established catalogue
/// reusable without imposing a policy on schools that use another system.
class ClassSuggestionResolver {
  const ClassSuggestionResolver();

  List<String> resolve({
    required EducationalLevel level,
    required InstitutionProfile profile,
    required List<SchoolClass> classes,
  }) {
    // Reading schoolType is intentional: profile configuration is the source
    // of context, but it is never used to silently invent a curriculum.
    final schoolType = profile.schoolType.trim();
    final description = level.description.trim();
    final prefix = RegExp(r'^classes\s*:', caseSensitive: false);
    final configured = prefix.hasMatch(description)
        ? description.replaceFirst(prefix, '')
        : '';
    final names = configured
        .split(RegExp(r'[,\n]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (names.isEmpty)
      names.addAll(_rangeFromConfiguredDescription(description));
    // A configured school type is a useful dependency for future catalogue
    // sources; retaining the read also documents that no hard-coded mapping
    // is being applied here.
    if (schoolType.isEmpty && names.isEmpty) return const [];
    final existing = classes
        .where((item) => item.levelId == level.id)
        .map((item) => item.name.trim().toLowerCase())
        .toSet();
    final unique = <String>{};
    return names
        .where((name) => !existing.contains(name.toLowerCase()))
        .where((name) => unique.add(name.toLowerCase()))
        .toList(growable: false);
  }

  List<String> _rangeFromConfiguredDescription(String description) {
    // This intentionally only expands a range explicitly stored on the
    // configured level (e.g. "Primary 1 to Primary 7"). It does not choose a
    // range for a school or infer a national curriculum.
    final match = RegExp(
      r'^(.+?)(\d+)\s+to\s+(.+?)(\d+)$',
      caseSensitive: false,
    ).firstMatch(description.trim());
    if (match == null) return const [];
    final rawFirstPrefix = match.group(1)!;
    final firstPrefix = rawFirstPrefix.trim();
    final lastPrefix = match.group(3)!.trim();
    final first = int.tryParse(match.group(2)!);
    final last = int.tryParse(match.group(4)!);
    if (first == null ||
        last == null ||
        first > last ||
        last - first > 100 ||
        firstPrefix.toLowerCase() != lastPrefix.toLowerCase()) {
      return const [];
    }
    final separator = RegExp(r'\s$').hasMatch(rawFirstPrefix) ? ' ' : '';
    return [
      for (var value = first; value <= last; value++)
        '$firstPrefix$separator$value',
    ];
  }
}
