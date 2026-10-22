import 'package:flutter/material.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_payroll_screen.dart';

/// HR and Finance intentionally share the same payroll workspace.  Keeping
/// this compatibility entry point prevents a second client-side calculator
/// or mutable `/payroll` implementation from resurfacing through HR routes.
class PayrollManagementScreen extends StatelessWidget {
  const PayrollManagementScreen({super.key});

  @override
  Widget build(BuildContext context) => const BursarPayrollScreen();
}
