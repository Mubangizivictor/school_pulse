import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/injection_container.dart' as di;

import '../bloc/subscription_payment_cubit.dart';
import '../widgets/payment_status_card.dart';
import '../widgets/phone_number_entry_field.dart';

class MtnMomoPaymentScreen extends StatelessWidget {
  const MtnMomoPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<SubscriptionPaymentCubit>(),
      child: const _MtnMomoPaymentView(),
    );
  }
}

class _MtnMomoPaymentView extends StatefulWidget {
  const _MtnMomoPaymentView();

  @override
  State<_MtnMomoPaymentView> createState() => _MtnMomoPaymentViewState();
}

class _MtnMomoPaymentViewState extends State<_MtnMomoPaymentView> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(title: const Text('MTN Mobile Money')),
      body: BlocBuilder<SubscriptionPaymentCubit, SubscriptionPaymentState>(
        builder: (context, state) {
          final cubit = context.read<SubscriptionPaymentCubit>();
          final isBusy = state.status == SubscriptionPaymentStatus.initiating;
          final showForm =
              state.status == SubscriptionPaymentStatus.idle ||
              state.status == SubscriptionPaymentStatus.initiating;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.paymentAttempt?.isSandbox ?? false)
                  _buildSandboxBanner(context),
                if (showForm) ...[
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pay your School Pulse subscription',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter the MTN Mobile Money number to receive the payment request on.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 16),
                        PhoneNumberEntryField(
                          controller: _phoneController,
                          enabled: !isBusy,
                        ),
                        if (state.errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            state.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            label: 'Request Payment',
                            icon: Icons.phone_android_rounded,
                            isLoading: isBusy,
                            onPressed: isBusy
                                ? null
                                : () {
                                    final phone = _phoneController.text.trim();
                                    if (phone.isEmpty) return;
                                    cubit.initiatePayment(phone);
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  PaymentStatusCard(
                    status: state.status,
                    paymentAttempt: state.paymentAttempt,
                  ),
                  if (state.status == SubscriptionPaymentStatus.failed ||
                      state.status == SubscriptionPaymentStatus.timedOut) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: SecondaryButton(
                        label: 'Try Again',
                        onPressed: () {
                          _phoneController.clear();
                          cubit.reset();
                        },
                      ),
                    ),
                  ],
                  if (state.status == SubscriptionPaymentStatus.succeeded) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        label: 'Done',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSandboxBanner(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: AlertBanner(
        title: 'Sandbox test mode',
        message:
            'MTN will process a small test charge on your phone, not the real '
            'subscription price shown above. No real money moves in sandbox mode.',
        color: Colors.orange,
        icon: Icons.science_outlined,
      ),
    );
  }
}
