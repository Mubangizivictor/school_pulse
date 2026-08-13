import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/app_components.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import '../../../library/domain/entities/library_policy.dart';
import '../../../library/presentation/bloc/library_bloc.dart';
import '../../../library/presentation/bloc/library_event.dart';
import '../../../library/presentation/bloc/library_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class LibrarySettingsScreen extends StatefulWidget {
  const LibrarySettingsScreen({super.key});

  @override
  State<LibrarySettingsScreen> createState() => _LibrarySettingsScreenState();
}

class _LibrarySettingsScreenState extends State<LibrarySettingsScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<LibraryBloc>().add(
        WatchPoliciesRequested(authState.user.schoolId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Library Policies'),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryPoliciesLoaded) {
            final policies = state.policies.cast<LibraryPolicy>();

            if (policies.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No policies defined yet.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showPolicyDialog(context),
                      child: const Text('Add Initial Policy'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: policies.length,
              itemBuilder: (context, index) {
                final policy = policies[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      policy.borrowerType.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Max: ${policy.maxBooks} books | ${policy.borrowDurationDays} days | UGX ${policy.finePerDay}/day',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showPolicyDialog(context, policy: policy),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: SchoolPulseLoader());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPolicyDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showPolicyDialog(BuildContext context, {LibraryPolicy? policy}) {
    showDialog(
      context: context,
      builder: (context) => _PolicyEditDialog(policy: policy),
    );
  }
}

class _PolicyEditDialog extends StatefulWidget {
  final LibraryPolicy? policy;
  const _PolicyEditDialog({this.policy});

  @override
  State<_PolicyEditDialog> createState() => _PolicyEditDialogState();
}

class _PolicyEditDialogState extends State<_PolicyEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _borrowerType;
  late int _maxBooks;
  late int _duration;
  late double _fine;

  @override
  void initState() {
    super.initState();
    _borrowerType = widget.policy?.borrowerType ?? 'student';
    _maxBooks = widget.policy?.maxBooks ?? 3;
    _duration = widget.policy?.borrowDurationDays ?? 14;
    _fine = widget.policy?.finePerDay ?? 500.0;
  }

  @override
  Widget build(BuildContext context) {
    // Note: LibraryPolicy entity has finePerDay
    return AlertDialog(
      title: Text(widget.policy == null ? 'New Policy' : 'Edit Policy'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _borrowerType,
                decoration: const InputDecoration(labelText: 'Borrower Type'),
                items: ['student', 'teacher', 'staff', 'parent']
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _borrowerType = val!),
              ),
              TextFormField(
                initialValue: _maxBooks.toString(),
                decoration: const InputDecoration(labelText: 'Max Books'),
                keyboardType: TextInputType.number,
                onSaved: (val) => _maxBooks = int.parse(val!),
              ),
              TextFormField(
                initialValue: _duration.toString(),
                decoration: const InputDecoration(labelText: 'Duration (Days)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => _duration = int.parse(val!),
              ),
              TextFormField(
                initialValue: widget.policy?.finePerDay.toString() ?? '500.0',
                decoration: const InputDecoration(
                  labelText: 'Fine Per Day (UGX)',
                ),
                keyboardType: TextInputType.number,
                onSaved: (val) => _fine = double.parse(val!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final authState =
                  context.read<AuthBloc>().state as AuthAuthenticated;
              final newPolicy = LibraryPolicy(
                id: widget.policy?.id ?? '',
                schoolId: authState.user.schoolId,
                borrowerType: _borrowerType,
                maxBooks: _maxBooks,
                borrowDurationDays: _duration,
                finePerDay: _fine,
                renewalLimit: widget.policy?.renewalLimit ?? 2,
                gracePeriodDays: widget.policy?.gracePeriodDays ?? 1,
                lostBookChargeMultiplier:
                    widget.policy?.lostBookChargeMultiplier ?? 1.5,
                canReserve: widget.policy?.canReserve ?? true,
              );
              context.read<LibraryBloc>().add(UpdatePolicyRequested(newPolicy));
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
