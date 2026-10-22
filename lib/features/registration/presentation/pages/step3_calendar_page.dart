import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../registration_theme.dart';
import '../widgets/reg_widgets.dart';

class Step3CalendarPage extends StatefulWidget {
  const Step3CalendarPage({super.key});

  @override
  State<Step3CalendarPage> createState() => _Step3CalendarPageState();
}

class _Step3CalendarPageState extends State<Step3CalendarPage> {
  late String _year;
  late String _term;
  DateTime? _start;
  DateTime? _end;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = context.read<RegistrationBloc>().state;
    _year = s.schoolYear.isEmpty ? '2026' : s.schoolYear;
    _term = s.term.isEmpty ? 'Term 1' : s.term;
    _start = s.termStart;
    _end = s.termEnd;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _start : _end) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'Select date';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  void _continue() {
    if (_start == null || _end == null) {
      setState(() => _error = 'Select both a term start and end date');
      return;
    }
    if (!_end!.isAfter(_start!)) {
      setState(() => _error = 'Term end date must be after the start date');
      return;
    }
    context.read<RegistrationBloc>().add(CalendarSubmitted(
          schoolYear: _year,
          term: _term,
          termStart: _start!,
          termEnd: _end!,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return RegStepScaffold(
      step: 3,
      title: 'School year & term',
      onBack: () => context.read<RegistrationBloc>().add(const RegistrationStepBack()),
      onContinue: _continue,
      infoBanner: const RegInfoBanner('You can adjust term dates later in school settings.'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RegFieldLabel('Academic year'),
          DropdownButtonFormField<String>(
            initialValue: _year,
            items: const [
              DropdownMenuItem(value: '2025', child: Text('2025')),
              DropdownMenuItem(value: '2026', child: Text('2026')),
              DropdownMenuItem(value: '2027', child: Text('2027')),
            ],
            dropdownColor: RegColors.surfaceElevated,
            style: const TextStyle(color: RegColors.textPrimary, fontSize: 14),
            onChanged: (v) => setState(() => _year = v ?? _year),
          ),
          const RegFieldLabel('Select current term'),
          Row(
            children: [
              for (final t in const ['Term 1', 'Term 2', 'Term 3'])
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: t == 'Term 3' ? 0 : 8),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _term == t ? RegColors.blue : Colors.transparent,
                        side: BorderSide(color: _term == t ? RegColors.blue : RegColors.border),
                        minimumSize: const Size.fromHeight(44),
                      ),
                      onPressed: () => setState(() => _term = t),
                      child: Text(t, style: TextStyle(color: _term == t ? Colors.white : RegColors.textPrimary, fontSize: 13.5)),
                    ),
                  ),
                ),
            ],
          ),
          const RegFieldLabel('Term start date'),
          _DateField(label: _fmt(_start), onTap: () => _pickDate(isStart: true)),
          const RegFieldLabel('Term end date'),
          _DateField(label: _fmt(_end), onTap: () => _pickDate(isStart: false)),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: RegColors.red, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: RegColors.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: RegColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: RegColors.textMuted),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: RegColors.textPrimary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
