import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';

class TeacherCommentScreen extends StatelessWidget {
  const TeacherCommentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher\'s Comment'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionHeader(title: 'Comment for Student (General)'),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextFormField(
                        maxLines: 6,
                        initialValue: 'Amara is a bright and enthusiastic learner. She participates actively in class discussions and shows strong potential. She should continue to work on her problem-solving skills in Mathematics.',
                        decoration: const InputDecoration(
                          hintText: 'Enter student comment...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('160/500', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Next Steps / Recommendations'),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    children: [
                      _RecommendationItem(text: 'Read more storybooks to improve comprehension.'),
                      const Divider(),
                      _RecommendationItem(text: 'Practice Mathematics problems regularly.'),
                      const Divider(),
                      _RecommendationItem(text: 'Maintain good attendance and punctuality.'),
                      const SizedBox(height: 12),
                      SecondaryButton(
                        label: 'Add Recommendation',
                        icon: Icons.add,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              label: 'Save & Next',
              onPressed: () => context.push('/teacher/reports/preview'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final String text;

  const _RecommendationItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
