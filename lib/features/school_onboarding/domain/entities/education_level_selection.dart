import 'package:equatable/equatable.dart';

/// The broad category a [SelectableLevel] belongs to. Kept as a closed,
/// small set - combination (Kindergarten+Primary, Primary+Secondary,
/// international alongside local levels, etc.) is expressed purely by which
/// categories/instances are present in a school's selection, never as a
/// combinatorial enum of "school types".
enum LevelCategory { earlyChildhood, primary, secondary, international, custom }

/// One education level (or stage-group) an admin has selected for their
/// school during setup. This is a setup-time selection, distinct from the
/// persisted `EducationalLevel` Structure entity - it carries template/UI
/// metadata (`isCustom`, `internationalProgrammeName`, free-text `stages`)
/// that Structure's entity doesn't need once provisioned.
class SelectableLevel extends Equatable {
  final String id;
  final LevelCategory category;
  final String name;
  final String code;
  final int order;

  /// Free-text stage names, e.g. ['P1', ..., 'P7'] for Primary, or
  /// admin-entered stage labels for an international programme. Never
  /// hardcode a curriculum here.
  final List<String> stages;
  final bool isCustom;

  /// Only meaningful when [category] is [LevelCategory.international].
  final String? internationalProgrammeName;

  const SelectableLevel({
    required this.id,
    required this.category,
    required this.name,
    this.code = '',
    this.order = 0,
    this.stages = const [],
    this.isCustom = false,
    this.internationalProgrammeName,
  });

  SelectableLevel copyWith({
    String? id,
    LevelCategory? category,
    String? name,
    String? code,
    int? order,
    List<String>? stages,
    bool? isCustom,
    String? internationalProgrammeName,
  }) {
    return SelectableLevel(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      code: code ?? this.code,
      order: order ?? this.order,
      stages: stages ?? this.stages,
      isCustom: isCustom ?? this.isCustom,
      internationalProgrammeName:
          internationalProgrammeName ?? this.internationalProgrammeName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    category,
    name,
    code,
    order,
    stages,
    isCustom,
    internationalProgrammeName,
  ];
}

/// A suggested starting point offered to the admin as an editable, selectable
/// card. Choosing a template preselects its [presetCategories] as levels, but
/// never locks the school into that path - every level stays fully editable.
class LevelTemplate extends Equatable {
  final String id;
  final String label;
  final String description;
  final List<LevelCategory> presetCategories;

  const LevelTemplate({
    required this.id,
    required this.label,
    required this.description,
    required this.presetCategories,
  });

  @override
  List<Object?> get props => [id, label, description, presetCategories];
}

/// Built-in templates shown as selectable cards. "Build my own" intentionally
/// has no preset categories - picking it just clears the current template so
/// the admin starts from an empty, fully custom selection.
const List<LevelTemplate> kBuiltInTemplates = [
  LevelTemplate(
    id: 'kindergarten',
    label: 'Kindergarten / Early years',
    description: 'Early years only',
    presetCategories: [LevelCategory.earlyChildhood],
  ),
  LevelTemplate(
    id: 'primary',
    label: 'Primary',
    description: 'Primary 1 – 7',
    presetCategories: [LevelCategory.primary],
  ),
  LevelTemplate(
    id: 'secondary',
    label: 'Secondary',
    description: 'Secondary 1 – 6',
    presetCategories: [LevelCategory.secondary],
  ),
  LevelTemplate(
    id: 'combined',
    label: 'Combined school',
    description: 'Early years, Primary and Secondary',
    presetCategories: [
      LevelCategory.earlyChildhood,
      LevelCategory.primary,
      LevelCategory.secondary,
    ],
  ),
  LevelTemplate(
    id: 'international',
    label: 'International / Custom',
    description: 'International or custom levels',
    presetCategories: [LevelCategory.international],
  ),
  LevelTemplate(
    id: 'build-your-own',
    label: 'Build my own',
    description: 'Start empty and add exactly what you offer',
    presetCategories: [],
  ),
];

/// The 3 fixed Uganda education-level tiers offered as always-visible
/// selectable cards (not templates - individually toggleable).
const List<SelectableLevel> kUgandaLevelOptions = [
  SelectableLevel(
    id: 'ug-early-years',
    category: LevelCategory.earlyChildhood,
    name: 'Early years',
    code: 'EY',
    order: 0,
    stages: ['Baby class', 'Middle class', 'Top class'],
  ),
  SelectableLevel(
    id: 'ug-primary',
    category: LevelCategory.primary,
    name: 'Primary',
    code: 'PRI',
    order: 1,
    stages: ['P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7'],
  ),
  SelectableLevel(
    id: 'ug-secondary',
    category: LevelCategory.secondary,
    name: 'Secondary',
    code: 'SEC',
    order: 2,
    stages: ['S1', 'S2', 'S3', 'S4', 'S5', 'S6'],
  ),
];
