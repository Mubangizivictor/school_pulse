import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/nurse/presentation/clinic_ui.dart';

class NurseClinicVisitsScreen extends StatefulWidget {
  const NurseClinicVisitsScreen({super.key});
  @override
  State<NurseClinicVisitsScreen> createState() =>
      _NurseClinicVisitsScreenState();
}

class _NurseClinicVisitsScreenState extends State<NurseClinicVisitsScreen> {
  String _query = '';
  bool _followUpOnly = false;
  String get _schoolId {
    final a = context.read<AuthBloc>().state;
    return a is AuthAuthenticated ? a.user.schoolId : '';
  }

  @override
  void initState() {
    super.initState();
    if (_schoolId.isNotEmpty) {
      context.read<HealthBloc>().add(FetchClinicVisits(schoolId: _schoolId));
    }
  }

  @override
  Widget build(BuildContext context) => ClinicPage(
    floatingActionButton: FloatingActionButton(
      backgroundColor: ClinicUi.black,
      foregroundColor: Colors.white,
      onPressed: () => context.push('/staff/nurse/lookup'),
      child: const Icon(Icons.add),
    ),
    child: BlocBuilder<HealthBloc, HealthState>(
      builder: (_, state) {
        final all = state is ClinicVisitsLoaded
            ? state.visits
            : const <ClinicVisit>[];
        final visits = all
            .where(
              (v) =>
                  (!_followUpOnly || v.followUpRequired) &&
                  (_query.isEmpty ||
                      v.studentId.toLowerCase().contains(
                        _query.toLowerCase(),
                      ) ||
                      v.reason.toLowerCase().contains(_query.toLowerCase())),
            )
            .toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Clinic visits',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                        color: ClinicUi.foreground(context),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => _followUpOnly = !_followUpOnly),
                    icon: Icon(
                      Icons.filter_alt_outlined,
                      color: _followUpOnly
                          ? ClinicUi.red
                          : ClinicUi.foreground(context),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search visits',
                        filled: true,
                        fillColor: ClinicUi.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () =>
                        setState(() => _followUpOnly = !_followUpOnly),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(64, 48),
                      side: const BorderSide(color: ClinicUi.line),
                    ),
                    child: const Text('Filter'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 7),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Today',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Expanded(
              child: state is HealthLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: ClinicUi.black),
                    )
                  : visits.isEmpty
                  ? const ClinicEmptyState(
                      title: 'No matching visits',
                      message:
                          'Try another search or record a new clinic visit.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                      itemCount: visits.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _VisitCard(visit: visits[i]),
                    ),
            ),
          ],
        );
      },
    ),
  );
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit});
  final ClinicVisit visit;
  @override
  Widget build(BuildContext context) {
    final needsReview = visit.followUpRequired;
    return InkWell(
      onTap: () => context.push('/staff/nurse/profile/${visit.studentId}'),
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: ClinicUi.outlinedCard(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 58,
              child: Text(
                DateFormat('h:mm a').format(visit.dateTime),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              needsReview ? Icons.radio_button_checked : Icons.check_circle,
              size: 17,
              color: needsReview ? ClinicUi.red : ClinicUi.green,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          visit.studentId,
                          style: TextStyle(
                            color: ClinicUi.foreground(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ClinicUi.pill(
                        needsReview ? 'Follow-up' : 'Completed',
                        color: needsReview ? ClinicUi.red : ClinicUi.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Reason for visit',
                    style: const TextStyle(fontSize: 10, color: ClinicUi.muted),
                  ),
                  Text(
                    visit.reason,
                    style: TextStyle(
                      color: ClinicUi.foreground(context),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    visit.followUpRequired
                        ? 'Follow-up required'
                        : 'Routine clinical note',
                    style: TextStyle(
                      fontSize: 11,
                      color: needsReview ? ClinicUi.red : ClinicUi.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: ClinicUi.muted),
          ],
        ),
      ),
    );
  }
}
