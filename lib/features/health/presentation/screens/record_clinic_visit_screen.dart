import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/nurse/presentation/clinic_ui.dart';

class RecordClinicVisitScreen extends StatefulWidget {
  const RecordClinicVisitScreen({super.key, required this.studentId});
  final String studentId;
  @override
  State<RecordClinicVisitScreen> createState() =>
      _RecordClinicVisitScreenState();
}

class _RecordClinicVisitScreenState extends State<RecordClinicVisitScreen> {
  final _form = GlobalKey<FormState>();
  final _concern = TextEditingController();
  final _notes = TextEditingController();
  final _temp = TextEditingController();
  final _hr = TextEditingController();
  final _bp = TextEditingController();
  final _spo2 = TextEditingController();
  bool _followUp = false;

  @override
  void dispose() {
    for (final c in [_concern, _notes, _temp, _hr, _bp, _spo2]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _number(String? value, double min, double max) {
    if (value == null || value.isEmpty) return null;
    final n = double.tryParse(value);
    return n == null || n < min || n > max ? 'Enter $min–$max' : null;
  }

  void _complete() {
    if (!(_form.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    context.read<HealthBloc>().add(
      RecordNewClinicVisit(
        ClinicVisit(
          id: const Uuid().v4(),
          studentId: widget.studentId,
          dateTime: DateTime.now(),
          reason: _concern.text.trim(),
          symptoms: _notes.text.trim(),
          temperature: double.tryParse(_temp.text),
          pulseRate: int.tryParse(_hr.text),
          bloodPressure: _bp.text.trim().isEmpty ? null : _bp.text.trim(),
          oxygenSaturation: int.tryParse(_spo2.text),
          treatmentProvided: _notes.text.trim().isEmpty
              ? null
              : _notes.text.trim(),
          followUpRequired: _followUp,
          outcome: VisitOutcome.sentBackToClass,
          recordedBy: auth.user.id,
          schoolId: auth.user.schoolId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HealthBloc, HealthState>(
      listener: (context, state) {
        if (state is HealthActionSuccess) {
          context.pop();
        }
        if (state is HealthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: ClinicPage(
        appBar: AppBar(
          backgroundColor: ClinicUi.background(context),
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: context.pop,
            icon: Icon(Icons.arrow_back, color: ClinicUi.foreground(context)),
          ),
          title: Text(
            'Record clinic visit',
            style: TextStyle(
              color: ClinicUi.foreground(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _label(context, 'Learner'),
              _readonly(widget.studentId),
              const SizedBox(height: 14),
              _label(context, 'Presenting concern'),
              _field(_concern, 'Select or enter concern', required: true),
              const SizedBox(height: 14),
              _label(context, 'Vitals'),
              Container(
                decoration: ClinicUi.outlinedCard(context),
                child: Column(
                  children: [
                    _vital('Temp (°C)', _temp, (v) => _number(v, 30, 45)),
                    _vital('HR (bpm)', _hr, (v) => _number(v, 30, 250)),
                    _vital(
                      'BP (mmHg)',
                      _bp,
                      (v) =>
                          v == null ||
                              v.isEmpty ||
                              RegExp(r'^\d{2,3}/\d{2,3}$').hasMatch(v)
                          ? null
                          : 'Use 110/70',
                    ),
                    _vital('SpO₂ (%)', _spo2, (v) => _number(v, 50, 100)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _label(context, 'Assessment / notes'),
              _field(
                _notes,
                'Enter brief, factual notes (no diagnosis)',
                lines: 4,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Follow-up required',
                  style: TextStyle(fontSize: 13),
                ),
                value: _followUp,
                onChanged: (value) => setState(() => _followUp = value),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Drafts stay local until authorised secure sync is available.',
                          ),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        side: const BorderSide(color: ClinicUi.black),
                      ),
                      child: const Text('Save draft'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _complete,
                      style: FilledButton.styleFrom(
                        backgroundColor: ClinicUi.black,
                        minimumSize: const Size(0, 50),
                      ),
                      child: const Text('Complete visit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: ClinicUi.foreground(context),
      ),
    ),
  );
  Widget _readonly(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    margin: const EdgeInsets.only(bottom: 14),
    decoration: ClinicUi.outlinedCard(context),
    child: Text(text, style: const TextStyle(fontSize: 12)),
  );
  Widget _field(
    TextEditingController c,
    String hint, {
    int lines = 1,
    bool required = false,
  }) => TextFormField(
    controller: c,
    maxLines: lines,
    validator: required
        ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
        : null,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: ClinicUi.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
  );
  Widget _vital(
    String label,
    TextEditingController c,
    String? Function(String?) validator,
  ) => TextFormField(
    controller: c,
    validator: validator,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: ClinicUi.line),
      ),
    ),
  );
}
