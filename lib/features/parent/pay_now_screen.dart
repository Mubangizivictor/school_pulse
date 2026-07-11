import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';

import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

class PayNowScreen extends StatefulWidget {
  const PayNowScreen({super.key});

  @override
  State<PayNowScreen> createState() => _PayNowScreenState();
}

class _PayNowScreenState extends State<PayNowScreen> {
  int _currentStep = 0;
  final _amountController = TextEditingController(text: '250000');
  String? _selectedProvider;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentAppBar(title: 'Make Payment'),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep++);
          } else {
            Navigator.pop(context);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.pop(context);
          }
        },
        controlsBuilder: (context, details) {
          if (_currentStep == 3) {
            return Padding(
              padding: const EdgeInsets.only(top: 24),
              child: PrimaryButton(
                label: 'Back to Fees',
                onPressed: details.onStepContinue,
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: _currentStep == 2 ? 'Confirm Payment' : 'Continue',
                    onPressed: details.onStepContinue,
                  ),
                ),
                if (_currentStep < 3) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: SecondaryButton(
                      label: 'Cancel',
                      onPressed: details.onStepCancel,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Amount'),
            isActive: _currentStep >= 0,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter amount to pay (UGX)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixText: 'UGX ',
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Provider'),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                _buildProviderOption(context, 'MTN MoMo', Colors.yellow[700]!),
                const SizedBox(height: 12),
                _buildProviderOption(context, 'Airtel Money', Colors.red[700]!),
              ],
            ),
          ),
          Step(
            title: const Text('Confirm'),
            isActive: _currentStep >= 2,
            content: BlocBuilder<SelectedStudentBloc, SelectedStudentState>(
              builder: (context, state) {
                final studentName = state is SelectedStudentLoaded ? state.student.name : 'Unknown';

                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildConfirmRow('Amount', CurrencyFormatter.format(double.tryParse(_amountController.text) ?? 0)),
                      const Divider(),
                      _buildConfirmRow('Provider', _selectedProvider ?? 'Not selected'),
                      const Divider(),
                      _buildConfirmRow(
                        'Student', 
                        studentName
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Step(
            title: const Text('Success'),
            isActive: _currentStep >= 3,
            content: Column(
              children: [
                Icon(Icons.check_circle, color: Theme.of(context).extension<SemanticColors>()!.success, size: 64),
                const SizedBox(height: 16),
                Text('Payment Successful!', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('Your receipt reference is TXN82736412'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderOption(BuildContext context, String name, Color color) {
    final isSelected = _selectedProvider == name;
    return AppCard(
      onTap: () => setState(() => _selectedProvider = name),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(width: 16),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
