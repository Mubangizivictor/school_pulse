import '../entities/comment_bank.dart';

/// Teachers should never have to type the same comment twice - suggests and
/// formats reusable comment templates instead.
class CommentBankService {
  /// Replaces placeholders in a template with actual values.
  /// Example: "Exhibited great improvement in {subject}." -> "Exhibited great improvement in Mathematics."
  static String formatComment(String template, Map<String, String> values) {
    String result = template;
    values.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  /// Filters templates based on performance level and category.
  static List<CommentTemplate> getSuggestedComments({
    required List<CommentTemplate> allTemplates,
    String? categoryId,
    String? performanceLevel,
  }) {
    return allTemplates.where((t) {
      bool matchCategory = categoryId == null || t.categoryId == categoryId;
      bool matchLevel = performanceLevel == null || t.performanceLevel == performanceLevel;
      return matchCategory && matchLevel;
    }).toList();
  }
}
