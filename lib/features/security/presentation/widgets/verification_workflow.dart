import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../../data/models/security_models.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';

class VerificationWorkflow extends StatefulWidget {
  const VerificationWorkflow({super.key});

  @override
  State<VerificationWorkflow> createState() => _VerificationWorkflowState();
}

class _VerificationWorkflowState extends State<VerificationWorkflow> {
  String _currentStep = 'method'; // method, scanning, details, confirm
  String _selectedMethod = '';
  String? _scannedId;
  
  void _setStep(String step) => setState(() => _currentStep = step);

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case 'method':
        return _buildMethodSelection();
      case 'scanning':
        return _buildScanningMock();
      case 'details':
        return _buildDetailsEntry();
      default:
        return _buildMethodSelection();
    }
  }

  Widget _buildMethodSelection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Select Verification Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _MethodCard(
              icon: Icons.qr_code_scanner,
              label: 'QR Code',
              onTap: () {
                setState(() => _selectedMethod = 'QR');
                _setStep('scanning');
              },
            ),
            _MethodCard(
              icon: Icons.fingerprint,
              label: 'Fingerprint',
              onTap: () {
                setState(() => _selectedMethod = 'Fingerprint');
                _setStep('scanning');
              },
            ),
            _MethodCard(
              icon: Icons.badge_outlined,
              label: 'ID Card',
              onTap: () {
                setState(() => _selectedMethod = 'ID Card');
                _setStep('details');
              },
            ),
            _MethodCard(
              icon: Icons.search,
              label: 'Manual',
              onTap: () {
                setState(() => _selectedMethod = 'Manual');
                _setStep('details');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScanningMock() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Scanning $_selectedMethod...", style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 30),
        const CircularProgressIndicator(),
        const SizedBox(height: 30),
        TextButton(onPressed: () {
          setState(() => _scannedId = 'STU12345');
          _setStep('details');
        }, child: const Text("Simulate Successful Scan"))
      ],
    );
  }

  Widget _buildDetailsEntry() {
    final nameController = TextEditingController(text: _scannedId != null ? 'John Doe' : '');
    final classController = TextEditingController(text: _scannedId != null ? 'Primary 5' : '');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Verify Details ($_selectedMethod)", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: classController, decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder())),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: () => _setStep('method'), child: const Text("Back")),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => _recordMovement(nameController.text, classController.text),
              child: const Text("Confirm In"),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => _recordMovement(nameController.text, classController.text, direction: 'Out'),
              style: FilledButton.styleFrom(backgroundColor: Colors.blueGrey),
              child: const Text("Confirm Out"),
            ),
          ],
        )
      ],
    );
  }

  void _recordMovement(String name, String className, {String direction = 'In'}) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final movement = StudentMovementModel(
      id: '',
      studentId: _scannedId ?? 'MANUAL',
      studentName: name,
      className: className,
      timestamp: DateTime.now(),
      gateId: 'MAIN_GATE',
      direction: direction,
      movementType: 'Normal',
      verificationMethod: _selectedMethod,
      officerId: authState.user.id,
      deviceId: 'DEVICE_01',
      schoolId: authState.user.schoolId,
    );

    context.read<SecurityBloc>().add(RecordStudentMovementRequested(movement));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Movement recorded: $name ($direction)')),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MethodCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 80,
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
