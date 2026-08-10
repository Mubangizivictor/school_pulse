import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_event.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_state.dart';

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(const WatchLeaveRequests());
  }

  String _currentUserName(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.name : 'Matron';
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('Leave Management')),
      body: BlocConsumer<MatronBloc, MatronState>(
        listener: (context, state) {
          if (state is MatronActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is MatronError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: semanticColors.error,
              ),
            );
          }
        },
        buildWhen: (previous, current) =>
            current is LeaveRequestsLoaded || current is MatronLoading,
        builder: (context, state) {
          if (state is! LeaveRequestsLoaded) {
            return const Center(child: SchoolPulseLoader());
          }
          if (state.requests.isEmpty) {
            return const EmptyState(
              icon: Icons.exit_to_app,
              title: 'No Leave Requests',
              message: 'Tap + to record a new leave request.',
            );
          }
          final sorted = [...state.requests]
            ..sort((a, b) {
              final aOverdue = a.isOverdue ? 0 : 1;
              final bOverdue = b.isOverdue ? 0 : 1;
              return aOverdue.compareTo(bOverdue);
            });
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, index) => _LeaveCard(
              request: sorted[index],
              currentUserName: _currentUserName(context),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRequestSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }

  void _showRequestSheet(BuildContext context) {
    final bloc = context.read<MatronBloc>();
    final requestedBy = _currentUserName(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: bloc,
        child: _RequestLeaveSheet(requestedBy: requestedBy),
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveRequest request;
  final String currentUserName;

  const _LeaveCard({required this.request, required this.currentUserName});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    final isOverdue = request.isOverdue;
    final statusColor = isOverdue
        ? semanticColors.error
        : switch (request.status) {
            'Approved' || 'Out' => semanticColors.warning,
            'Returned' => semanticColors.success,
            'Rejected' => semanticColors.error,
            _ => Colors.grey,
          };

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              StatusBadge(
                label: isOverdue ? 'Overdue' : request.status,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(request.reason, style: Theme.of(context).textTheme.bodyMedium),
          if (request.destination != null)
            Text(
              'Destination: ${request.destination}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 4),
          Text(
            'Depart ${DateFormat('MMM d').format(request.departureDate)} - '
            'Return by ${DateFormat('MMM d').format(request.expectedReturnDate)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              if (request.status == 'Pending') ...[
                TextButton(
                  onPressed: () => context.read<MatronBloc>().add(
                    UpdateLeaveStatusEvent(
                      request.id,
                      'Rejected',
                      approvedBy: currentUserName,
                    ),
                  ),
                  child: Text(
                    'Reject',
                    style: TextStyle(color: semanticColors.error),
                  ),
                ),
                FilledButton(
                  onPressed: () => context.read<MatronBloc>().add(
                    UpdateLeaveStatusEvent(
                      request.id,
                      'Out',
                      approvedBy: currentUserName,
                    ),
                  ),
                  child: const Text('Approve & Depart'),
                ),
              ],
              if (request.status == 'Out' || isOverdue)
                FilledButton(
                  onPressed: () => context.read<MatronBloc>().add(
                    UpdateLeaveStatusEvent(
                      request.id,
                      'Returned',
                      approvedBy: currentUserName,
                      actualReturnDate: DateTime.now(),
                    ),
                  ),
                  child: const Text('Mark Returned'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestLeaveSheet extends StatefulWidget {
  final String requestedBy;
  const _RequestLeaveSheet({required this.requestedBy});

  @override
  State<_RequestLeaveSheet> createState() => _RequestLeaveSheetState();
}

class _RequestLeaveSheetState extends State<_RequestLeaveSheet> {
  String? _selectedStudentId;
  String? _selectedStudentName;
  final _reasonController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime _departureDate = DateTime.now();
  DateTime _expectedReturnDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(WatchBoardingStudents());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: BlocConsumer<MatronBloc, MatronState>(
        listener: (context, state) {
          if (state is MatronActionSuccess) Navigator.pop(context);
        },
        builder: (context, state) {
          final students = state is BoardingStudentsLoaded
              ? state.students
              : <BoardingStudent>[];
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Leave Request',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Student',
                    border: OutlineInputBorder(),
                  ),
                  items: students
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() {
                    _selectedStudentId = val;
                    _selectedStudentName = students
                        .firstWhere((s) => s.id == val)
                        .name;
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destination (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          'Depart: ${DateFormat('MMM d').format(_departureDate)}',
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _departureDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 1),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 90),
                            ),
                          );
                          if (date != null) {
                            setState(() => _departureDate = date);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.event_available),
                        label: Text(
                          'Return: ${DateFormat('MMM d').format(_expectedReturnDate)}',
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _expectedReturnDate,
                            firstDate: _departureDate,
                            lastDate: DateTime.now().add(
                              const Duration(days: 120),
                            ),
                          );
                          if (date != null) {
                            setState(() => _expectedReturnDate = date);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _selectedStudentId == null
                        ? null
                        : () {
                            context.read<MatronBloc>().add(
                              RequestLeaveEvent(
                                LeaveRequest(
                                  id: '',
                                  studentId: _selectedStudentId!,
                                  studentName: _selectedStudentName ?? '',
                                  dormitoryId: '',
                                  reason: _reasonController.text.trim(),
                                  destination:
                                      _destinationController.text.trim().isEmpty
                                      ? null
                                      : _destinationController.text.trim(),
                                  requestedBy: widget.requestedBy,
                                  departureDate: _departureDate,
                                  expectedReturnDate: _expectedReturnDate,
                                ),
                              ),
                            );
                          },
                    child: const Text('Submit Request'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
