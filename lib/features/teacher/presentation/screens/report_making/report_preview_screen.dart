import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme.dart';

class ReportPreviewScreen extends StatelessWidget {
  const ReportPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Card Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const _ReportCardPreviewHeader(),
                  const SizedBox(height: 16),
                  _buildPreviewSection(
                    title: 'Student Information',
                    content: const _StudentInfoTable(),
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewSection(
                    title: 'Academic Performance',
                    content: const _AcademicPerformanceTable(),
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewSection(
                    title: 'Competencies & Skills',
                    content: const _SkillsGrid(),
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewSection(
                    title: 'Attendance & Conduct',
                    content: const _AttendanceConductSummary(),
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewSection(
                    title: 'Teacher\'s Remarks',
                    content: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Amara is a bright and enthusiastic learner. She participates actively in class discussions and shows strong potential. She should continue to work on her problem-solving skills in Mathematics.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              label: 'Proceed to Generate',
              onPressed: () => context.push('/teacher/reports/generate'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: content,
        ),
      ],
    );
  }
}

class _ReportCardPreviewHeader extends StatelessWidget {
  const _ReportCardPreviewHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: SemanticColors.primary.withOpacity(0.1),
          child: const Icon(Icons.school, color: SemanticColors.primary, size: 30),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LITTLE SAINTS INTERNATIONAL SCHOOL',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                '2023/2024 Academic Session - First Term',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentInfoTable extends StatelessWidget {
  const _StudentInfoTable();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _infoRow('Name:', 'Amara Okoro'),
          const Divider(),
          _infoRow('Class:', 'Primary 2 Gold'),
          const Divider(),
          _infoRow('Admission No:', 'LSIS/2021/042'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AcademicPerformanceTable extends StatelessWidget {
  const _AcademicPerformanceTable();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.all(8),
          child: const Row(
            children: [
              Expanded(flex: 3, child: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text('CA', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text('Exam', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text('Total', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text('Grade', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        _subjectRow('Mathematics', '35', '55', '90', 'A+'),
        _subjectRow('English Language', '30', '52', '82', 'A'),
        _subjectRow('Science', '28', '48', '76', 'B+'),
        _subjectRow('Social Studies', '32', '50', '82', 'A'),
      ],
    );
  }

  Widget _subjectRow(String name, String ca, String exam, String total, String grade) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name)),
          Expanded(child: Text(ca, textAlign: TextAlign.center)),
          Expanded(child: Text(exam, textAlign: TextAlign.center)),
          Expanded(child: Text(total, textAlign: TextAlign.center)),
          Expanded(child: Text(grade, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _SkillsGrid extends StatelessWidget {
  const _SkillsGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _skillRow('Punctuality', 5),
          _skillRow('Creativity', 4),
          _skillRow('Neatness', 5),
          _skillRow('Self-Confidence', 4),
        ],
      ),
    );
  }

  Widget _skillRow(String name, int rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Row(
            children: List.generate(5, (index) => Icon(
              index < rating ? Icons.star : Icons.star_border,
              size: 16,
              color: Colors.amber,
            )),
          ),
        ],
      ),
    );
  }
}

class _AttendanceConductSummary extends StatelessWidget {
  const _AttendanceConductSummary();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Attendance', '95%'),
          _summaryItem('Conduct', 'Excellent'),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
