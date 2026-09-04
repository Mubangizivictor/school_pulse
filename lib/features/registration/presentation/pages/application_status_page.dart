import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';
import '../registration_theme.dart';
import '../widgets/reg_widgets.dart';
import 'payment_page.dart';

/// Covers: Registration submitted (awaiting review), approved, and rejected
/// (with reason + edit-and-resubmit), matching the reference status screens.
class ApplicationStatusPage extends StatefulWidget {
  const ApplicationStatusPage({super.key});

  @override
  State<ApplicationStatusPage> createState() => _ApplicationStatusPageState();
}

class _ApplicationStatusPageState extends State<ApplicationStatusPage> {
  @override
  void initState() {
    super.initState();
    context.read<RegistrationBloc>().add(const ApplicationStatusCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        final status = state.applicationStatus;
        return Scaffold(
          backgroundColor: RegColors.background,
          appBar: const RegTopBar(),
          body: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: status == ApplicationStatus.rejected
                  ? _buildRejected(context, state)
                  : status == ApplicationStatus.approved
                      ? _buildApproved(context, state)
                      : _buildPendingReview(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingReview(BuildContext context, RegistrationState state) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Icon(Icons.access_time_rounded, color: RegColors.amber, size: 48),
        const SizedBox(height: 14),
        const Text('Registration submitted', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: RegColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('Your registration is awaiting platform review.', style: TextStyle(fontSize: 13, color: RegColors.textMuted), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        if (state.applicationId != null) _ReferenceCard(state.applicationId!),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: RegColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: RegColors.border)),
          child: const RegStatusTimeline(
            labels: ['Submitted', 'Under review', 'Approved', 'Payment'],
            currentIndex: 1,
          ),
        ),
        const SizedBox(height: 16),
        const RegInfoBanner('You will be notified by SMS and email once there is an update.'),
        if (state.statusError != null) ...[
          const SizedBox(height: 10),
          Text(state.statusError!, style: const TextStyle(color: RegColors.red, fontSize: 12)),
        ],
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: state.statusLoading
                ? null
                : () => context.read<RegistrationBloc>().add(const ApplicationStatusCheckRequested()),
            child: state.statusLoading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Check registration status'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => showRegHelpSheet(context),
            icon: const Icon(Icons.headset_mic_outlined, size: 17),
            label: const Text('Need help? Contact support'),
          ),
        ),
      ],
    );
  }

  Widget _buildApproved(BuildContext context, RegistrationState state) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Icon(Icons.check_circle, color: RegColors.green, size: 48),
        const SizedBox(height: 14),
        const Text('Registration approved', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: RegColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('Your school has been approved.', style: TextStyle(fontSize: 13, color: RegColors.textMuted)),
        const SizedBox(height: 20),
        if (state.applicationId != null) _ReferenceCard(state.applicationId!),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: RegColors.greenSoft, borderRadius: BorderRadius.circular(11), border: Border.all(color: RegColors.green.withValues(alpha: 0.4))),
          child: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: RegColors.green, size: 18),
              SizedBox(width: 10),
              Expanded(child: Text('You can now proceed to make payment using the instructions provided.', style: TextStyle(color: RegColors.textPrimary, fontSize: 12.5))),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PaymentPage()),
            ),
            child: const Text('Continue to payment instructions'),
          ),
        ),
      ],
    );
  }

  Widget _buildRejected(BuildContext context, RegistrationState state) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Icon(Icons.cancel, color: RegColors.red, size: 48),
        const SizedBox(height: 14),
        const Text('Registration not approved', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: RegColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('Your registration needs changes before it can be approved.', style: TextStyle(fontSize: 13, color: RegColors.textMuted), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        if (state.rejectionReason != null && state.rejectionReason!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: RegColors.redSoft, borderRadius: BorderRadius.circular(11), border: Border.all(color: RegColors.red.withValues(alpha: 0.4))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reason', style: TextStyle(color: RegColors.red, fontSize: 11.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(state.rejectionReason!, style: const TextStyle(color: RegColors.textPrimary, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Edit and resubmit'),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => showRegHelpSheet(context),
            icon: const Icon(Icons.headset_mic_outlined, size: 17),
            label: const Text('Need help? Contact support'),
          ),
        ),
      ],
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  final String reference;
  const _ReferenceCard(this.reference);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: RegColors.surface, borderRadius: BorderRadius.circular(11), border: Border.all(color: RegColors.border)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reference ID', style: TextStyle(color: RegColors.textMuted, fontSize: 11.5)),
                const SizedBox(height: 4),
                Text(reference, style: const TextStyle(color: RegColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 17, color: RegColors.textMuted),
            onPressed: () => Clipboard.setData(ClipboardData(text: reference)),
          ),
        ],
      ),
    );
  }
}
