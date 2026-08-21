import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/teacher_student_detail_ui.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:url_launcher/url_launcher.dart';

class TeacherStudentDocumentsScreen extends StatefulWidget {
  final String studentId;
  const TeacherStudentDocumentsScreen({super.key, required this.studentId});

  @override
  State<TeacherStudentDocumentsScreen> createState() =>
      _TeacherStudentDocumentsScreenState();
}

class _TeacherStudentDocumentsScreenState
    extends State<TeacherStudentDocumentsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, String> _documents = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await di.sl<StudentRepository>().getStudentById(
      widget.studentId,
    );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _errorMessage = failure.message;
        _isLoading = false;
      }),
      (Student student) => setState(() {
        _documents = student.documents;
        _isLoading = false;
      }),
    );
  }

  Future<void> _openDocument(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not open this document.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const TeacherStudentDetailAppBar(title: 'Documents'),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
        ),
      );
    }

    if (_documents.isEmpty) {
      return const TeacherStudentDetailEmptyState(
        icon: Icons.description_outlined,
        title: 'No documents yet',
        message:
            'Documents uploaded for this student during admission will '
            'appear here.',
      );
    }

    final entries = _documents.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return TeacherStudentDetailTile(
          icon: Icons.insert_drive_file_outlined,
          label: entry.key,
          trailingIcon: Icons.open_in_new,
          onTap: () => _openDocument(entry.value),
        );
      },
    );
  }
}
