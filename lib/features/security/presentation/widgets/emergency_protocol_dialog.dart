import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';
import '../../data/models/security_models.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';

const List<String> kEmergencyTypes = [
  'Fire',
  'Medical Emergency',
  'Security Threat',
  'Missing Student',
  'Intruder Alert',
  'Accident',
];

class EmergencyProtocolDialog extends StatefulWidget {
  const EmergencyProtocolDialog({super.key});

  @override
  State<EmergencyProtocolDialog> createState() => _EmergencyProtocolDialogState();
}

class _EmergencyProtocolDialogState extends State<EmergencyProtocolDialog> {
  String _selectedType = kEmergencyTypes.first;
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SecurityBloc, SecurityState>(
      listenWhen: (previous, current) => !identical(previous.feedback, current.feedback) && current.feedback != null,
      listener: (context, state) {
        final feedback = state.feedback!;
        if (_isSubmitting) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(feedback.isError ? feedback.message : 'EMERGENCY ALERT ACTIVATED'),
              backgroundColor: feedback.isError ? Colors.red : Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text('Trigger Emergency', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will alert all security staff and admin immediately. Select the type of emergency.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Emergency Type',
                  border: OutlineInputBorder(),
                ),
                items: kEmergencyTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Quick Description / Location',
                  hintText: 'e.g., Fire at Block A, Room 202',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isSubmitting ? null : _triggerEmergency,
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('ACTIVATE ALERT'),
          ),
        ],
      ),
    );
  }

  void _triggerEmergency() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isSubmitting = true);

    final event = EmergencyEventModel(
      id: const Uuid().v4(),
      type: _selectedType,
      startTime: DateTime.now(),
      description: _descriptionController.text.trim(),
      responseActions: const [],
      involvedPersonIds: const [],
      status: 'Active',
      schoolId: authState.user.schoolId,
    );

    context.read<SecurityBloc>().add(TriggerEmergencyRequested(event));
  }
}
