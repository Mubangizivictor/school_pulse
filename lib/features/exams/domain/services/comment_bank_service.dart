import '../entities/comment_bank.dart';

class CommentBankService {
  /// Processes a comment template by replacing placeholders with actual values.
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
      bool matchLevel =
          performanceLevel == null || t.performanceLevel == performanceLevel;
      return matchCategory && matchLevel;
    }).toList();
  }
}
