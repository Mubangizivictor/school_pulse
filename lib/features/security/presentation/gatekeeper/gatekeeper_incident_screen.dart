import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/gatekeeper_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/security/data/models/security_models.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_bloc.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_event.dart';
import 'package:school_pulse/features/security/presentation/screens/report_incident_screen.dart' show kIncidentTypes;

const Map<String, IconData> _incidentIcons = {
  'Theft': Icons.money_off,
  'Fighting': Icons.sports_kabaddi,
  'Bullying': Icons.report_off_outlined,
  'Unauthorized Entry': Icons.no_encryption_outlined,
  'Missing Student': Icons.person_search_outlined,
  'Property Damage': Icons.broken_image_outlined,
  'Accident': Icons.healing_outlined,
  'Suspicious Activity': Icons.visibility_outlined,
  'Safety Concern': Icons.shield_outlined,
  'Other': Icons.more_horiz,
};

/// Gatekeeper Simple Mode quick incident report: tap a type -> optional
/// photo -> optional short note -> SUBMIT. Reuses SecurityBloc's
/// ReportIncidentRequested event and the same kIncidentTypes categories as
/// the detailed ReportIncidentScreen (Reception mode), which stays
/// untouched as the fuller editor (people involved, witnesses, resolution).
/// Location defaults to the gate name so the guard never has to type it.
class GatekeeperIncidentScreen extends StatefulWidget {
  const GatekeeperIncidentScreen({super.key});

  @override
  State<GatekeeperIncidentScreen> createState() => _GatekeeperIncidentScreenState();
}

class _GatekeeperIncidentScreenState extends State<GatekeeperIncidentScreen> {
  String? _type;
  XFile? _photo;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1200, imageQuality: 80);
    if (picked != null) setState(() => _photo = picked);
  }

  Future<void> _submit() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || _type == null) return;
    setState(() => _isSubmitting = true);

    final id = const Uuid().v4();
    final photoUrls = <String>[];
    if (_photo != null) {
      try {
        final ref = FirebaseStorage.instance.ref('security_incidents/${authState.user.schoolId}/$id/0.jpg');
        await ref.putFile(File(_photo!.path));
        photoUrls.add(await ref.getDownloadURL());
      } catch (_) {
        // Offline or upload failed - submit the report anyway; the photo is
        // simply omitted rather than blocking the incident report.
      }
    }
    if (!mounted) return;

    final incident = SecurityIncidentModel(
      id: id,
      type: _type!,
      description: _noteController.text.trim().isEmpty ? _type! : _noteController.text.trim(),
      timestamp: DateTime.now(),
      location: 'Gate',
      involvedPersonIds: const [],
      photoUrls: photoUrls,
      reportedByOfficerId: authState.user.id,
      report: '',
      status: 'Pending',
      schoolId: authState.user.schoolId,
    );
    context.read<SecurityBloc>().add(ReportIncidentRequested(incident));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Incident')),
      body: _type == null ? _buildTypeGrid(context) : _buildDetails(context),
    );
  }

  Widget _buildTypeGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What happened?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: kIncidentTypes.map((type) {
                return GatekeeperActionTile(
                  label: type,
                  icon: _incidentIcons[type] ?? Icons.report_outlined,
                  color: Theme.of(context).colorScheme.error,
                  onTap: () => setState(() => _type = type),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatusBadge(label: _type!, color: Theme.of(context).colorScheme.error, icon: _incidentIcons[_type] ?? Icons.report_outlined),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: _addPhoto,
              child: CircleAvatar(
                radius: 48,
                backgroundImage: _photo != null ? FileImage(File(_photo!.path)) : null,
                child: _photo == null ? const Icon(Icons.add_a_photo_outlined, size: 32) : null,
              ),
            ),
          ),
          Center(child: TextButton(onPressed: _addPhoto, child: Text(_photo == null ? 'Add Photo (optional)' : 'Retake Photo'))),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(labelText: 'Short note (optional)', hintText: 'e.g. Near the main gate, two boys'),
          ),
          const Spacer(),
          GatekeeperPrimaryButton(
            label: 'SUBMIT',
            icon: Icons.send,
            tone: GatekeeperButtonTone.danger,
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _isSubmitting ? null : () => setState(() => _type = null),
            child: const Text('Not this type — go back'),
          ),
        ],
      ),
    );
  }
}
