import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';

class MarksDashboardScreen extends StatelessWidget {
  const MarksDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = const Color(0xFF0F172A); // Deep navy from design
    final surfaceColor = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildClassSelector(surfaceColor),
              const SizedBox(height: 16),
              _buildSubjectCard(theme, surfaceColor),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildQuickActions(context, surfaceColor),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Assessments',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => context.push('/staff/marks/history'),
                    child: const Text('View All', style: TextStyle(color: Color(0xFF818CF8))),
                  ),
                ],
              ),
              _buildRecentAssessments(context, surfaceColor),
              const SizedBox(height: 100), // Bottom nav space
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const AvatarInitials(name: 'MJ', size: 48, backgroundColor: Color(0xFF312E81)),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Good Afternoon,', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              Text('Mr. Okot John', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Subject Teacher • Mathematics', style: TextStyle(color: Color(0xFF818CF8), fontSize: 12)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          onPressed: () {},
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {},
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassSelector(Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('Class: ', style: TextStyle(color: Color(0xFF94A3B8))),
              const Text('Grade 10A (Science)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(ThemeData theme, Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF312E81),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.functions, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mathematics', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Term 2, 2024/2025', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('5', 'Assessments'),
              _buildMetric('18', 'Marks Entered'),
              _buildMetric('84%', 'Average Score', valueColor: Colors.yellow),
              _buildMetric('2', 'Pending', valueColor: Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String label, {Color valueColor = Colors.white}) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, Color surfaceColor) {
    return Row(
      children: [
        _buildActionItem(context, 'Enter Marks', Icons.edit_note, '/staff/marks/select-assessment', surfaceColor),
        const SizedBox(width: 12),
        _buildActionItem(context, 'Import Marks', Icons.file_upload_outlined, '/staff/marks/import', surfaceColor),
        const SizedBox(width: 12),
        _buildActionItem(context, 'Mark Analytics', Icons.bar_chart, '/staff/marks/analytics', surfaceColor),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String label, IconData icon, String route, Color surfaceColor) {
    return Expanded(
      child: InkWell(
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF818CF8)),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAssessments(BuildContext context, Color surfaceColor) {
    return Column(
      children: [
        _buildAssessmentItem(context, 'Mid Term Test', 'Test', 'Completed', Colors.green, surfaceColor),
        _buildAssessmentItem(context, 'Assignment 2', 'Assignment', 'Pending', Colors.orange, surfaceColor),
        _buildAssessmentItem(context, 'Quiz 1', 'Quiz', 'Completed', Colors.green, surfaceColor),
      ],
    );
  }

  Widget _buildAssessmentItem(BuildContext context, String title, String type, String status, Color statusColor, Color surfaceColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(type, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 16),
        ],
      ),
    );
  }
}
