import 'package:flutter/material.dart';
import 'package:school_pulse/features/shared/staff_dashboard/staff_dashboard_widgets.dart';

/// Minimal gate-operations dashboard for supervisor/admin roles
/// (securityHead, receptionist, schoolAdmin, director, headTeacher,
/// deputyHead). Stub for the router/DI wiring commit - built out in a
/// later commit of the gate_ops rebuild.
class GateOpsMinimalDashboardScreen extends StatelessWidget {
  const GateOpsMinimalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: staffDashboardAppBar(context, roleLabel: 'Gate Operations'),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StaffHeroSummaryCard(greetingNameFallback: 'there', kpis: null),
            SizedBox(height: 24),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text('Gate operations dashboard - coming soon'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
