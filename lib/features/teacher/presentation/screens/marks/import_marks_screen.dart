import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_assessment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/marks/marks_bloc.dart';

/// Imports marks from a two-column CSV (admission number, mark), matched
/// against the real roster and component the teacher already selected.
/// Unmatched admission numbers are reported rather than silently dropped.
class ImportMarksScreen extends StatefulWidget {
  const ImportMarksScreen({super.key});

  @override
  State<ImportMarksScreen> createState() => _ImportMarksScreenState();
}

class _ImportMarksScreenState extends State<ImportMarksScreen> {
  String? _fileName;
  int _matched = 0;
  List<String> _unmatched = [];
  Map<String, double> _parsedByAdmission = {};

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    final file = result?.files.singleOrNull;
    if (file?.bytes == null) return;

    final content = utf8.decode(file!.bytes!, allowMalformed: true);
    final parsed = <String, double>{};
    for (final line in const LineSplitter().convert(content)) {
      final parts = line.split(',');
      if (parts.length < 2) continue;
      final admission = parts[0].trim();
      final mark = double.tryParse(parts[1].trim());
      if (admission.isEmpty || mark == null) continue;
      parsed[admission] = mark;
    }

    if (!mounted) return;

    final roster = context.read<MarksBloc>().state.students;
    final byAdmission = {for (final s in roster) s.admissionNumber: s};
    final matched = parsed.keys.where(byAdmission.containsKey).length;
    final unmatched = parsed.keys.where((k) => !byAdmission.containsKey(k)).toList();

    setState(() {
      _fileName = file.name;
      _parsedByAdmission = parsed;
      _matched = matched;
      _unmatched = unmatched;
    });
  }

  void _import(BuildContext context, AssessmentComponent component) {
    final bloc = context.read<MarksBloc>();
    final roster = bloc.state.students;
    final byAdmission = {for (final s in roster) s.admissionNumber: s};

    for (final entry in _parsedByAdmission.entries) {
      final student = byAdmission[entry.key];
      if (student == null) continue;
      bloc.add(
        MarksEntryChanged(
          studentId: student.studentId,
          score: entry.value,
          status: MarkEntryStatus.scored,
        ),
      );
    }
    bloc.add(const MarksDraftSaved());
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarksBloc, MarksState>(
      builder: (context, state) {
        final component = state.selectedComponent;

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: AppColors.textPrimary(context),
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Import Marks',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (component == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Select an assessment and component first, then come '
                      'back here to import.',
                      style: TextStyle(color: AppColors.warning(context)),
                    ),
                  ),
                InkWell(
                  onTap: _pickFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border(context).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.success(
                              context,
                            ).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.description,
                            color: AppColors.success(context),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _fileName ?? 'Upload CSV File',
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _fileName == null
                              ? 'Tap to browse'
                              : '$_matched matched, ${_unmatched.length} not on your roster',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Format Guide',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildGuideItem(context, 'One row per student, no header row'),
                _buildGuideItem(context, 'Column 1: Admission Number'),
                _buildGuideItem(context, 'Column 2: Mark'),
                if (_unmatched.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Not matched to your roster: ${_unmatched.join(', ')}',
                    style: TextStyle(color: AppColors.danger(context), fontSize: 12),
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: component == null || _matched == 0
                        ? null
                        : () => _import(context, component),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Import $_matched Marks',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuideItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, color: AppColors.primary(context), size: 6),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
