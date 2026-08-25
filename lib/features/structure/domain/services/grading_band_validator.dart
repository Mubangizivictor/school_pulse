import '../entities/assessment_grading_entities.dart';

/// Policy-neutral validation for a numeric, inclusive mark scale.
/// The institution supplies both maximum mark and every grade label/range.
class GradingBandValidator {
  static String? validate({
    required double maximumMark,
    required List<GradeBand> bands,
  }) {
    if (maximumMark <= 0) return 'Maximum mark must be greater than zero.';
    if (bands.isEmpty) return 'Add at least one grade band.';
    final labels = <String>{};
    final ordered = [...bands]
      ..sort((a, b) => a.minScore.compareTo(b.minScore));
    for (final band in ordered) {
      if (band.grade.trim().isEmpty) return 'Every grade band needs a label.';
      if (!labels.add(band.grade.trim().toLowerCase())) {
        return 'Grade labels must be unique.';
      }
      if (band.minScore < 0 || band.maxScore > maximumMark) {
        return '${band.grade} must fall within 0–$maximumMark.';
      }
      if (band.minScore > band.maxScore) {
        return '${band.grade}: minimum cannot exceed maximum.';
      }
    }
    if (ordered.first.minScore != 0 || ordered.last.maxScore != maximumMark) {
      return 'Grade bands must cover the complete range from 0 to $maximumMark.';
    }
    for (var i = 1; i < ordered.length; i++) {
      if (ordered[i].minScore <= ordered[i - 1].maxScore) {
        return 'Grade bands must not overlap.';
      }
      if (ordered[i].minScore != ordered[i - 1].maxScore + 1) {
        return 'Grade bands must cover every mark exactly once.';
      }
    }
    return null;
  }
}
