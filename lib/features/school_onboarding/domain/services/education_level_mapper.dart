import 'package:uuid/uuid.dart';

import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import '../entities/education_level_selection.dart';

/// Maps setup-time [SelectableLevel]s to real Structure [EducationalLevel]
/// entities. Pure - no I/O. Preserves `order`/`name`/`code`.
///
/// `existingIds` should be the previously-provisioned Structure doc ids
/// keyed by [SelectableLevel.id] (from `SchoolSetupDraft.provisionedLevelIds`
/// matched up by the caller) so that re-provisioning after an edit reuses the
/// same Structure doc id rather than creating a duplicate - `saveLevelsBatch`
/// upserts by id, so a stable id is required for edits to behave as updates.
List<EducationalLevel> toEducationalLevels({
  required String schoolId,
  required List<SelectableLevel> selected,
  Map<String, String> existingIds = const {},
}) {
  const uuid = Uuid();
  return selected
      .map(
        (level) => EducationalLevel(
          id: existingIds[level.id] ?? uuid.v4(),
          schoolId: schoolId,
          name: level.name,
          code: level.code,
          order: level.order,
          description: level.internationalProgrammeName ?? '',
          isActive: true,
        ),
      )
      .toList();
}
