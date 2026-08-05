import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddLessonNoteScreen extends StatelessWidget {
  final String lessonId;
  const AddLessonNoteScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Add Lesson Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLessonHeader(colorScheme),
            const SizedBox(height: 24),
            Text(
              'Title',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(hintText: 'Enter note title'),
            ),
            const SizedBox(height: 24),
            Text(
              'Note Content',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Write your note here...',
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Attachments (Optional)',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.attach_file,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add File',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.book,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Linear Equations',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Grade 10A (Science) • Section A',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Mon, 20 May 2025 • 10:00 AM - 10:45 AM',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
