import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectAssessmentScreen extends StatelessWidget {
  const SelectAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFF0F172A);
    final surfaceColor = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Select Assessment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTabs(surfaceColor),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildAssessmentCard(
                  context,
                  'Mid Term Test',
                  'Test • 40 Marks',
                  '20 May 2025',
                  'Completed',
                  Colors.green,
                  surfaceColor,
                ),
                _buildAssessmentCard(
                  context,
                  'End Term Test',
                  'Test • 60 Marks',
                  '15 Jan 2025',
                  'Upcoming',
                  Colors.blue,
                  surfaceColor,
                ),
                _buildAssessmentCard(
                  context,
                  'Chapter 3 Test',
                  'Test • 20 Marks',
                  'Not scheduled',
                  'Draft',
                  Colors.grey,
                  surfaceColor,
                ),
                _buildAssessmentCard(
                  context,
                  'Chapter 5 Test',
                  'Test • 20 Marks',
                  'Not scheduled',
                  'Draft',
                  Colors.grey,
                  surfaceColor,
                ),
                _buildAssessmentCard(
                  context,
                  'Surprise Test',
                  'Test • 10 Marks',
                  'Not scheduled',
                  'Draft',
                  Colors.grey,
                  surfaceColor,
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Create New Assessment',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF4338CA)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(Color surfaceColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _buildTab('All', true),
          _buildTab('Tests', false),
          _buildTab('Quizzes', false),
          _buildTab('Assignments', false),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF312E81) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.white10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAssessmentCard(
    BuildContext context,
    String title,
    String subtitle,
    String date,
    String status,
    Color statusColor,
    Color surfaceColor,
  ) {
    return InkWell(
      onTap: () => context.push('/staff/marks/select-component'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
