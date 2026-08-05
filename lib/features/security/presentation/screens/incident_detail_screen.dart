import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/security_entities.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';

const List<String> kIncidentStatuses = ['Pending', 'Investigating', 'Resolved'];

class IncidentDetailScreen extends StatefulWidget {
  final SecurityIncident incident;
  const IncidentDetailScreen({super.key, required this.incident});

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  late String _status;
  final _resolutionController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.incident.status;
    _resolutionController.text = widget.incident.report;
  }

  Future<void> _save() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    setState(() => _isSaving = true);
    context.read<SecurityBloc>().add(
      UpdateIncidentStatusRequested(
        authState.user.schoolId,
        widget.incident.id,
        _status,
        _resolutionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incident = widget.incident;
    return BlocListener<SecurityBloc, SecurityState>(
      listenWhen: (previous, current) =>
          !identical(previous.feedback, current.feedback) &&
          current.feedback != null,
      listener: (context, state) {
        setState(() => _isSaving = false);
        final feedback = state.feedback!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(feedback.message),
            backgroundColor: feedback.isError ? Colors.red : null,
          ),
        );
        if (!feedback.isError) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(incident.type)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(incident.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: incident.location,
            ),
            _InfoRow(
              icon: Icons.access_time,
              label: incident.timestamp.toLocal().toString().split('.').first,
            ),
            if (incident.involvedPersonIds.isNotEmpty)
              _InfoRow(
                icon: Icons.people_outline,
                label: incident.involvedPersonIds.join(', '),
              ),
            if (incident.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: incident.photoUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      incident.photoUrls[index],
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: kIncidentStatuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _resolutionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Officer Report / Resolution',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Update'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
