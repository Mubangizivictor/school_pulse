import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/visitors/presentation/pages/emergency_roll_call_page.dart';
import '../../domain/entities/security_entities.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';

class EmergencyDetailScreen extends StatefulWidget {
  final EmergencyEvent emergency;
  const EmergencyDetailScreen({super.key, required this.emergency});

  @override
  State<EmergencyDetailScreen> createState() => _EmergencyDetailScreenState();
}

class _EmergencyDetailScreenState extends State<EmergencyDetailScreen> {
  late List<String> _actions;
  final _actionController = TextEditingController();
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _actions = [...widget.emergency.responseActions];
  }

  void _addAction() {
    final value = _actionController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _actions.add(value);
      _actionController.clear();
    });
  }

  void _resolve() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    setState(() => _isResolving = true);
    context.read<SecurityBloc>().add(ResolveEmergencyRequested(
          authState.user.schoolId,
          widget.emergency.id,
          DateTime.now(),
          _actions,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final emergency = widget.emergency;
    final isActive = emergency.status == 'Active';

    return BlocListener<SecurityBloc, SecurityState>(
      listenWhen: (previous, current) => !identical(previous.feedback, current.feedback) && current.feedback != null,
      listener: (context, state) {
        setState(() => _isResolving = false);
        final feedback = state.feedback!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(feedback.message), backgroundColor: feedback.isError ? Colors.red : null),
        );
        if (!feedback.isError) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(emergency.type),
          backgroundColor: isActive ? Colors.red : null,
          foregroundColor: isActive ? Colors.white : null,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Chip(
              label: Text(emergency.status),
              backgroundColor: isActive ? Colors.red.shade100 : Colors.green.shade100,
            ),
            const SizedBox(height: 12),
            Text(emergency.description.isEmpty ? 'No description provided' : emergency.description),
            const SizedBox(height: 8),
            Text('Started: ${emergency.startTime.toLocal().toString().split('.').first}', style: Theme.of(context).textTheme.bodySmall),
            if (emergency.endTime != null)
              Text('Resolved: ${emergency.endTime!.toLocal().toString().split('.').first}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EmergencyRollCallPage()),
              ),
              icon: const Icon(Icons.groups_outlined),
              label: const Text('Start Roll Call'),
            ),
            const SizedBox(height: 24),
            Text('Response Actions', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ..._actions.map((a) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle_outline, size: 18),
                  title: Text(a),
                  trailing: isActive
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => setState(() => _actions.remove(a)),
                        )
                      : null,
                )),
            if (isActive)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _actionController,
                      decoration: const InputDecoration(labelText: 'Add response action', border: OutlineInputBorder()),
                      onSubmitted: (_) => _addAction(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.add_circle), onPressed: _addAction),
                ],
              ),
            const SizedBox(height: 24),
            if (isActive)
              FilledButton(
                onPressed: _isResolving ? null : _resolve,
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
                child: _isResolving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Mark Resolved'),
              ),
          ],
        ),
      ),
    );
  }
}
