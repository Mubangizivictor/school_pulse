import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/qr_scanner/presentation/screens/qr_scanner_screen.dart';
import 'package:school_pulse/features/qr_scanner/domain/entities/scanner_mode.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';

class StudentEligibilityScreen extends StatefulWidget {
  const StudentEligibilityScreen({super.key});

  @override
  State<StudentEligibilityScreen> createState() =>
      _StudentEligibilityScreenState();
}

class _StudentEligibilityScreenState extends State<StudentEligibilityScreen> {
  String _selectedService = 'EXAM';
  final List<String> _services = ['EXAM', 'MEAL', 'TRIP', 'GRADUATION'];

  @override
  Widget build(BuildContext context) {
    return BlocListener<FinanceBloc, FinanceState>(
      listener: (context, state) {
        if (state is EligibilityChecked) {
          _showResultDialog(context, state);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Access Eligibility')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Verify student eligibility for specific school services based on their financial standing.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 40),
              const Text(
                'Select Service Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _services.map((service) {
                  final isSelected = _selectedService == service;
                  return ChoiceChip(
                    label: Text(service),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedService = service);
                    },
                  );
                }).toList(),
              ),
              const Spacer(),
              AppCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      size: 80,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Scan Student ID Card',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Point the camera at the student\'s QR code to verify their status.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => _startScan(context),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Start Scanner'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _startScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScannerScreen(
          mode: ScannerMode.verification,
          onScan: (studentId) {
            final authState =
                context.read<AuthBloc>().state as AuthAuthenticated;
            context.read<FinanceBloc>().add(
              CheckStudentEligibility(
                studentId: studentId,
                schoolId: authState.user.schoolId,
                serviceType: _selectedService,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, EligibilityChecked state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          state.isEligible ? Icons.check_circle : Icons.cancel,
          color: state.isEligible ? Colors.black : Colors.black,
          size: 64,
        ),
        title: Text(state.isEligible ? 'Access Granted' : 'Access Denied'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Service: ${state.serviceType}'),
            const SizedBox(height: 8),
            Text(
              state.isEligible
                  ? 'Student is cleared for this service.'
                  : state.reason ?? 'Student has outstanding arrears.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
