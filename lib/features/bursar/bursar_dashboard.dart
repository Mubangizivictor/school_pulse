import 'package:flutter/material.dart';
import 'package:school_pulse/features/finance/presentation/screens/finance_dashboard_screen.dart';

/// Staff entry point for the school's financial management system.
///
/// Enrollment and school-wide configuration deliberately remain outside this
/// module. The finance feature consumes the financial account created by the
/// admissions service and scopes every operational query to the signed-in
/// user's school.
class BursarDashboardScreen extends StatelessWidget {
  const BursarDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => const FinanceDashboardScreen();
}
