import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/security_models.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';

const List<String> kIncidentTypes = [
  'Theft',
  'Fighting',
  'Bullying',
  'Unauthorized Entry',
  'Missing Student',
  'Property Damage',
  'Accident',
  'Suspicious Activity',
  'Safety Concern',
  'Other',
];

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  String _type = kIncidentTypes.first;
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _reportController = TextEditingController();
  final _involvedController = TextEditingController();
  DateTime _timestamp = DateTime.now();
  final List<String> _involvedPersons = [];
  final List<XFile> _photos = [];
  bool _isSaving = false;

  void _addInvolvedPerson() {
    final value = _involvedController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _involvedPersons.add(value);
      _involvedController.clear();
    });
  }

  Future<void> _addPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1200, imageQuality: 80);
    if (picked != null) setState(() => _photos.add(picked));
  }

  Future<List<String>> _uploadPhotos(String incidentId, String schoolId) async {
    final urls = <String>[];
    for (var i = 0; i < _photos.length; i++) {
      final ref = FirebaseStorage.instance.ref('security_incidents/$schoolId/$incidentId/$i.jpg');
      await ref.putFile(File(_photos[i].path));
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  Future<void> _submit() async {
    if (_descriptionController.text.trim().isEmpty || _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description and location are required')),
      );
      return;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final securityBloc = context.read<SecurityBloc>();

    setState(() => _isSaving = true);
    final id = const Uuid().v4();
    final photoUrls = await _uploadPhotos(id, authState.user.schoolId);
    if (!mounted) return;

    final incident = SecurityIncidentModel(
      id: id,
      type: _type,
      description: _descriptionController.text.trim(),
      timestamp: _timestamp,
      location: _locationController.text.trim(),
      involvedPersonIds: _involvedPersons,
      photoUrls: photoUrls,
      reportedByOfficerId: authState.user.id,
      report: _reportController.text.trim(),
      status: 'Pending',
      schoolId: authState.user.schoolId,
    );
    securityBloc.add(ReportIncidentRequested(incident));

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Security Incident')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Incident Type', border: OutlineInputBorder()),
            items: kIncidentTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Date & Time: ${_timestamp.toLocal()}'.split('.').first),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _timestamp,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now(),
              );
              if (date == null || !context.mounted) return;
              final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_timestamp));
              if (time == null) return;
              setState(() => _timestamp = DateTime(date.year, date.month, date.day, time.hour, time.minute));
            },
          ),
          const SizedBox(height: 12),
          Text('People Involved', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _involvedController,
                  decoration: const InputDecoration(labelText: 'Name or ID', border: OutlineInputBorder()),
                  onSubmitted: (_) => _addInvolvedPerson(),
                ),
              ),
              IconButton(icon: const Icon(Icons.add_circle), onPressed: _addInvolvedPerson),
            ],
          ),
          Wrap(
            spacing: 8,
            children: _involvedPersons
                .map((p) => Chip(label: Text(p), onDeleted: () => setState(() => _involvedPersons.remove(p))))
                .toList(),
          ),
          const SizedBox(height: 16),
          Text('Photos / Evidence', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._photos.map((p) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(p.path), width: 72, height: 72, fit: BoxFit.cover),
                  )),
              InkWell(
                onTap: _addPhoto,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.add_a_photo_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reportController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Officer Report', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit Incident Report'),
          ),
        ],
      ),
    );
  }
}
