import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';

class ExamSeatingScreen extends StatefulWidget {
  final String sittingId;
  const ExamSeatingScreen({super.key, required this.sittingId});

  @override
  State<ExamSeatingScreen> createState() => _ExamSeatingScreenState();
}

class _ExamSeatingScreenState extends State<ExamSeatingScreen> {
  final _studentIdController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _seatNumberController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _studentIdController.dispose();
    _studentNameController.dispose();
    _seatNumberController.dispose();
    super.dispose();
  }

  Future<void> _assign(ExamFactoryCubit cubit) async {
    if (_studentIdController.text.trim().isEmpty ||
        _seatNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a candidate ID and seat number.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await cubit.assignSeat(
        sittingId: widget.sittingId,
        studentId: _studentIdController.text.trim(),
        studentName: _studentNameController.text.trim(),
        seatNumber: _seatNumberController.text.trim(),
      );
      if (!mounted) return;
      _studentIdController.clear();
      _studentNameController.clear();
      _seatNumberController.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.error ?? 'Could not assign this seat.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Seating & candidates',
      backFallback:
          '/staff/dean/exam-factory/exam-day?sittingId=${widget.sittingId}',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          100,
        ),
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _studentIdController,
                  decoration: const InputDecoration(labelText: 'Candidate ID'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _seatNumberController,
                  decoration: const InputDecoration(labelText: 'Seat'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _studentNameController,
            decoration: const InputDecoration(labelText: 'Candidate name'),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _saving ? null : () => _assign(cubit),
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.event_seat_outlined),
            label: Text(_saving ? 'Assigning…' : 'Assign seat'),
          ),
          const SizedBox(height: 24),
          Text('Seating plan', style: AppTypography.titleSmall),
          const SizedBox(height: 8),
          StreamBuilder<List<ExamSeatAssignment>>(
            stream: cubit.watchSeating(sittingId: widget.sittingId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final seats = snap.data ?? const <ExamSeatAssignment>[];
              if (seats.isEmpty) {
                return const Text('No seats assigned yet.');
              }
              return Column(
                children: seats
                    .map(
                      (s) => Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text(s.seatNumber)),
                          title: Text(
                            s.studentName.isEmpty ? s.studentId : s.studentName,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => cubit.removeSeat(s.id),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
