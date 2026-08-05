import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/security_models.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';

class PatrolLogScreen extends StatefulWidget {
  const PatrolLogScreen({super.key});

  @override
  State<PatrolLogScreen> createState() => _PatrolLogScreenState();
}

class _PatrolLogScreenState extends State<PatrolLogScreen> {
  String get _schoolId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  @override
  void initState() {
    super.initState();
    context.read<SecurityBloc>().add(WatchPatrolsRequested(_schoolId));
  }

  void _openRecordForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _RecordPatrolSheet(schoolId: _schoolId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Security Patrols')),
      body: BlocConsumer<SecurityBloc, SecurityState>(
        listenWhen: (previous, current) =>
            !identical(previous.feedback, current.feedback) &&
            current.feedback != null,
        listener: (context, state) {
          final feedback = state.feedback!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(feedback.message),
              backgroundColor: feedback.isError ? Colors.red : null,
            ),
          );
        },
        builder: (context, state) {
          if (state.patrols.isEmpty) {
            return const EmptyState(
              icon: Icons.shield_outlined,
              title: 'No Patrol Logs',
              message:
                  'Security patrols help keep the campus safe. Start a new patrol to log your activities.',
            );
          }

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: GridView.builder(
                padding: EdgeInsets.all(isLargeScreen ? 24 : 12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 1100
                      ? 3
                      : (isLargeScreen ? 2 : 1),
                  mainAxisExtent: 140,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: state.patrols.length,
                itemBuilder: (context, index) {
                  final patrol = state.patrols[index];
                  final hasIssues = patrol.issuesFound.isNotEmpty;
                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: hasIssues
                            ? Colors.orange.shade50
                            : Colors.green.shade50,
                        child: Icon(
                          hasIssues
                              ? Icons.report_problem_outlined
                              : Icons.check_circle_outline,
                          color: hasIssues ? Colors.orange : Colors.green,
                        ),
                      ),
                      title: Text(
                        patrol.location,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${patrol.timestamp.toLocal().toString().split('.').first}\n'
                          '${patrol.observations}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRecordForm,
        icon: const Icon(Icons.add),
        label: const Text('Record Patrol'),
      ),
    );
  }
}

class _RecordPatrolSheet extends StatefulWidget {
  final String schoolId;
  const _RecordPatrolSheet({required this.schoolId});

  @override
  State<_RecordPatrolSheet> createState() => _RecordPatrolSheetState();
}

class _RecordPatrolSheetState extends State<_RecordPatrolSheet> {
  final _locationController = TextEditingController();
  final _observationsController = TextEditingController();
  final _issueController = TextEditingController();
  final List<String> _issues = [];
  final List<XFile> _photos = [];
  bool _isSaving = false;

  void _addIssue() {
    final value = _issueController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _issues.add(value);
      _issueController.clear();
    });
  }

  Future<void> _addPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _photos.add(picked));
  }

  Future<void> _save() async {
    if (_locationController.text.trim().isEmpty) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final securityBloc = context.read<SecurityBloc>();

    setState(() => _isSaving = true);
    final id = const Uuid().v4();
    final photoUrls = <String>[];
    for (var i = 0; i < _photos.length; i++) {
      final ref = FirebaseStorage.instance.ref(
        'security_patrols/${widget.schoolId}/$id/$i.jpg',
      );
      await ref.putFile(File(_photos[i].path));
      photoUrls.add(await ref.getDownloadURL());
    }
    if (!mounted) return;

    final patrol = SecurityPatrolModel(
      id: id,
      officerId: authState.user.id,
      location: _locationController.text.trim(),
      timestamp: DateTime.now(),
      observations: _observationsController.text.trim(),
      photoUrls: photoUrls,
      issuesFound: _issues,
      schoolId: widget.schoolId,
    );
    securityBloc.add(RecordPatrolRequested(patrol));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Record Patrol',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Patrol Location',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _observationsController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Observations',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _issueController,
                  decoration: const InputDecoration(
                    labelText: 'Issue found (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addIssue(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: _addIssue,
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: _issues
                .map(
                  (i) => Chip(
                    label: Text(i),
                    onDeleted: () => setState(() => _issues.remove(i)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _addPhoto,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(
              _photos.isEmpty
                  ? 'Add Photo'
                  : '${_photos.length} photo(s) added',
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Patrol Log'),
          ),
        ],
      ),
    );
  }
}
