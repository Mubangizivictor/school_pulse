import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/nurse/presentation/clinic_ui.dart';

/// Compact service directory matching the clinic reference. Each destination
/// stays within the existing nurse module; it does not duplicate data views.
class NurseMoreScreen extends StatelessWidget {
  const NurseMoreScreen({super.key});
  @override
  Widget build(BuildContext context) => ClinicPage(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      children: [
        Text(
          'More',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: ClinicUi.foreground(context),
          ),
        ),
        const SizedBox(height: 18),
        _Group(
          rows: [
            _Row(
              Icons.calendar_month_outlined,
              'Appointments',
              () => context.push('/staff/nurse/visits'),
            ),
            _Row(
              Icons.output_outlined,
              'Referrals',
              () => context.push('/staff/nurse/visits'),
            ),
            _Row(
              Icons.vaccines_outlined,
              'Immunisations',
              () => context.push('/staff/nurse/lookup'),
            ),
            _Row(
              Icons.description_outlined,
              'Health reports',
              () => context.push('/staff/nurse/records'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Group(
          rows: [
            _Row(
              Icons.history_outlined,
              'Clinic activity',
              () => context.push('/staff/nurse/history'),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: ClinicUi.outlinedCard(context),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restricted data',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'This information is confidential and access is limited to authorised school staff only.',
                      style: TextStyle(fontSize: 11, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.rows});
  final List<_Row> rows;
  @override
  Widget build(BuildContext context) => Container(
    decoration: ClinicUi.outlinedCard(context),
    child: Column(children: rows),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.title, this.onTap);
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: ClinicUi.foreground(context)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: ClinicUi.foreground(context),
              ),
            ),
          ),
          const Icon(Icons.chevron_right, size: 20, color: ClinicUi.muted),
        ],
      ),
    ),
  );
}
