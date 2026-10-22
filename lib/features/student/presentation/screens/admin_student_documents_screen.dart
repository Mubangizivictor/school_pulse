import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// The fixed set of document types the admin can manage for a student,
/// keyed to match [Student.documents] map keys.
const Map<String, String> _kDocumentTypeLabels = {
  'student_id_card': 'Student ID Card',
  'birth_certificate': 'Birth Certificate',
  'medical_forms': 'Medical Forms',
  'admission_letter': 'Admission Letter',
  'guardian_consent_form': 'Guardian Consent Form',
  'other': 'Other',
};

class AdminStudentDocumentsScreen extends StatelessWidget {
  final Student student;
  final bool canMutate;
  final VoidCallback? onDocumentsChanged;

  const AdminStudentDocumentsScreen({
    super.key,
    required this.student,
    required this.canMutate,
    this.onDocumentsChanged,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Documents')),
    body: StudentDocumentsBody(
      student: student,
      canMutate: canMutate,
      onDocumentsChanged: onDocumentsChanged,
    ),
  );
}

/// The documents list without its own [Scaffold], so the admin student profile
/// can host it as a Documents tab while the standalone route
/// ([AdminStudentDocumentsScreen], still reachable by deep link and from the
/// profile's overflow sheet) keeps working. Upload/delete logic lives here
/// once and is shared by both paths.
class StudentDocumentsBody extends StatefulWidget {
  final Student student;
  final bool canMutate;
  final VoidCallback? onDocumentsChanged;

  const StudentDocumentsBody({
    super.key,
    required this.student,
    required this.canMutate,
    this.onDocumentsChanged,
  });

  @override
  State<StudentDocumentsBody> createState() => _StudentDocumentsBodyState();
}

class _StudentDocumentsBodyState extends State<StudentDocumentsBody> {
  final StudentRepository _repository = di.sl<StudentRepository>();
  late Map<String, String> _documents;
  final Set<String> _busyTypes = {};

  @override
  void initState() {
    super.initState();
    _documents = Map<String, String>.from(widget.student.documents);
  }

  Future<void> _upload(String type) async {
    // TODO: file_picker would allow arbitrary document formats (PDF etc);
    // image_picker is the dependency already present in pubspec.yaml, so
    // uploads here are limited to photographed/scanned images for now.
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _busyTypes.add(type));
    final result = await _repository.uploadStudentDocument(
      widget.student.id,
      type,
      File(picked.path),
    );
    if (!mounted) return;
    setState(() => _busyTypes.remove(type));

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${failure.message}')),
        );
      },
      (url) {
        setState(() => _documents[type] = url);
        widget.onDocumentsChanged?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_kDocumentTypeLabels[type]} uploaded.')),
        );
      },
    );
  }

  Future<void> _delete(String type) async {
    setState(() => _busyTypes.add(type));
    final result = await _repository.deleteStudentDocument(
      widget.student.id,
      type,
    );
    if (!mounted) return;
    setState(() => _busyTypes.remove(type));

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${failure.message}')),
        );
      },
      (_) {
        setState(() => _documents.remove(type));
        widget.onDocumentsChanged?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_kDocumentTypeLabels[type]} removed.')),
        );
      },
    );
  }

  Future<void> _view(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open document.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _kDocumentTypeLabels.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final type = _kDocumentTypeLabels.keys.elementAt(index);
        final label = _kDocumentTypeLabels[type]!;
        final url = _documents[type];
        final isUploaded = url != null && url.isNotEmpty;
        final isBusy = _busyTypes.contains(type);

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    isUploaded ? Icons.description : Icons.description_outlined,
                    color: isUploaded
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isUploaded ? 'Uploaded' : 'Not uploaded',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isUploaded
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isBusy)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (isUploaded) ...[
                    TextButton(
                      onPressed: () => _view(url),
                      child: const Text('View'),
                    ),
                    if (widget.canMutate)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                        onPressed: () => _delete(type),
                      ),
                  ] else if (widget.canMutate)
                    TextButton(
                      onPressed: () => _upload(type),
                      child: const Text('Upload'),
                    )
                  else
                    Text(
                      'No access',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              // Inline preview for uploads that are images. Uploads go
              // through ImagePicker today, so in practice every stored
              // document is an image; a non-image URL (e.g. a PDF added
              // later) simply falls back to the existing "View"/"Open"
              // action rather than rendering a broken box.
              if (isUploaded && _looksLikeImage(url)) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : const SizedBox(
                            height: 160,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                    errorBuilder: (context, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Whether [url] points at something [Image.network] can render. Firebase
  /// Storage download URLs carry the original filename in their path, so the
  /// extension survives the token query string.
  static bool _looksLikeImage(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.gif') ||
        path.endsWith('.webp') ||
        path.endsWith('.heic');
  }
}
