import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/registration_reference_data.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';
import '../registration_theme.dart';
import '../widgets/reg_widgets.dart';

/// Covers: payment instructions, proof upload (preview/replace/invalid/
/// failure/retry), payment submitted (awaiting confirmation), approved, and
/// rejected-with-reason-and-resubmit. Payment methods/numbers come live from
/// getManualPaymentContext (public_functions/payments.js) — never hardcoded
/// — so a change in the SaaS Owner's config is reflected automatically.
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _payerNameController = TextEditingController();
  final _referenceController = TextEditingController();
  final _noteController = TextEditingController();
  final DateTime _paymentDate = DateTime.now();
  String? _pickError;

  @override
  void initState() {
    super.initState();
    context.read<RegistrationBloc>().add(const PaymentContextLoadRequested());
  }

  @override
  void dispose() {
    _payerNameController.dispose();
    _referenceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickProof() async {
    setState(() => _pickError = null);
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single;
    final path = picked.path;
    if (path == null) {
      setState(() => _pickError = 'Could not read the selected file. Please try again.');
      return;
    }
    const maxBytes = 10 * 1024 * 1024;
    if (picked.size > maxBytes) {
      setState(() => _pickError = 'File is too large. Maximum size is 10MB.');
      return;
    }
    if (!mounted) return;
    context.read<RegistrationBloc>().add(PaymentProofSelected(File(path)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        Widget body;
        switch (state.paymentPhase) {
          case PaymentPhase.idle:
          case PaymentPhase.loadingContext:
            body = const Center(child: CircularProgressIndicator());
            break;
          case PaymentPhase.failed:
            if (state.paymentContext == null) {
              body = _buildLoadFailed(context, state);
            } else {
              body = _buildInstructions(context, state);
            }
            break;
          case PaymentPhase.submitted:
            body = _buildSubmitted(context, state);
            break;
          case PaymentPhase.approved:
            body = _buildApproved(context);
            break;
          case PaymentPhase.rejected:
            body = _buildRejected(context, state);
            break;
          case PaymentPhase.contextLoaded:
          case PaymentPhase.uploadingProof:
          case PaymentPhase.submitting:
            if (state.paymentStatus == 'approved') {
              body = _buildApproved(context);
            } else if (state.paymentStatus == 'rejected') {
              body = _buildRejected(context, state);
            } else if (state.paymentStatus == 'awaiting_confirmation' || state.paymentStatus == 'submitted') {
              body = _buildSubmitted(context, state);
            } else {
              body = _buildInstructions(context, state);
            }
            break;
        }
        return Scaffold(
          backgroundColor: RegColors.background,
          appBar: RegTopBar(onBack: () => Navigator.of(context).maybePop()),
          body: SafeArea(
            top: false,
            child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 16), child: body),
          ),
        );
      },
    );
  }

  Widget _buildLoadFailed(BuildContext context, RegistrationState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off_rounded, color: RegColors.textMuted, size: 44),
        const SizedBox(height: 14),
        Text(state.paymentError ?? 'Could not load payment instructions.', style: const TextStyle(color: RegColors.textPrimary, fontSize: 14), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => context.read<RegistrationBloc>().add(const PaymentContextLoadRequested()),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildInstructions(BuildContext context, RegistrationState state) {
    final ctx = state.paymentContext ?? {};
    final plan = ctx['plan'] as Map<String, dynamic>? ?? {};
    final instructions = ctx['instructions'] as Map<String, dynamic>? ?? {};
    final mobileMoney = instructions['mobileMoney'] as Map<String, dynamic>? ?? {};
    final airtel = instructions['airtelMoney'] as Map<String, dynamic>? ?? {};
    final bank = instructions['bank'] as Map<String, dynamic>? ?? {};
    final amount = plan['expectedAmount'] as int?;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Payment instructions', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: RegColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Make payment using any of the options below.', style: TextStyle(fontSize: 12.5, color: RegColors.textMuted)),
          if (amount != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: RegColors.surface, borderRadius: BorderRadius.circular(11), border: Border.all(color: RegColors.border)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount due', style: TextStyle(color: RegColors.textMuted, fontSize: 12.5)),
                  Text(formatUgx(amount), style: const TextStyle(color: RegColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text('Manual payment methods', style: TextStyle(color: RegColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _MethodTile(
            color: const Color(0xFFFFCB05),
            label: 'MTN',
            title: 'MTN Mobile Money',
            subtitle: mobileMoney['number'] != null ? 'Pay to ${mobileMoney['number']}' : 'Pay to your MoMo merchant number.',
            selected: state.paymentMethod == 'mtn',
            onTap: () => _setMethod(context, state, 'mtn'),
          ),
          _MethodTile(
            color: const Color(0xFFED1C24),
            label: 'Airtel',
            title: 'Airtel Money',
            subtitle: airtel['number'] != null ? 'Pay to ${airtel['number']}' : 'Pay to your Airtel Money merchant number.',
            selected: state.paymentMethod == 'airtel',
            onTap: () => _setMethod(context, state, 'airtel'),
          ),
          _MethodTile(
            icon: Icons.account_balance_outlined,
            label: 'Bank',
            title: (bank['accountName'] as String?) ?? 'Bank transfer',
            subtitle: bank['accountNumber'] != null
                ? 'Account ${bank['accountNumber']}'
                : 'Make payment via bank branch or transfer.',
            selected: state.paymentMethod == 'bank',
            onTap: () => _setMethod(context, state, 'bank'),
          ),
          const SizedBox(height: 14),
          const RegInfoBanner('After payment, upload your proof of payment below.'),
          const SizedBox(height: 16),
          const RegFieldLabel('Payer name'),
          TextField(
            controller: _payerNameController,
            style: const TextStyle(color: RegColors.textPrimary),
            onChanged: (_) => _syncDetails(context, state),
            decoration: const InputDecoration(hintText: 'Full name of the person who paid'),
          ),
          const RegFieldLabel('Payment reference'),
          TextField(
            controller: _referenceController,
            style: const TextStyle(color: RegColors.textPrimary),
            onChanged: (_) => _syncDetails(context, state),
            decoration: const InputDecoration(hintText: 'Enter transaction/receipt reference'),
          ),
          const RegFieldLabel('Notes (optional)'),
          TextField(
            controller: _noteController,
            maxLines: 2,
            style: const TextStyle(color: RegColors.textPrimary),
            onChanged: (_) => _syncDetails(context, state),
            decoration: const InputDecoration(hintText: 'Anything else we should know'),
          ),
          const SizedBox(height: 16),
          _buildProofArea(context, state),
          if (_pickError != null) ...[
            const SizedBox(height: 8),
            Text(_pickError!, style: const TextStyle(color: RegColors.red, fontSize: 12)),
          ],
          if (state.paymentError != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(color: RegColors.redSoft, borderRadius: BorderRadius.circular(9), border: Border.all(color: RegColors.red.withValues(alpha: 0.4))),
              child: Text(state.paymentError!, style: const TextStyle(color: RegColors.textPrimary, fontSize: 12)),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (state.paymentPhase == PaymentPhase.uploadingProof || state.paymentPhase == PaymentPhase.submitting)
                  ? null
                  : () => context.read<RegistrationBloc>().add(const PaymentSubmitPressed()),
              child: (state.paymentPhase == PaymentPhase.uploadingProof || state.paymentPhase == PaymentPhase.submitting)
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Submit payment'),
            ),
          ),
        ],
      ),
    );
  }

  void _setMethod(BuildContext context, RegistrationState state, String method) {
    context.read<RegistrationBloc>().add(ManualPaymentDetailsChanged(
          method: method,
          payerName: _payerNameController.text,
          reference: _referenceController.text,
          paymentDate: _paymentDate,
          note: _noteController.text,
        ));
  }

  void _syncDetails(BuildContext context, RegistrationState state) {
    context.read<RegistrationBloc>().add(ManualPaymentDetailsChanged(
          method: state.paymentMethod,
          payerName: _payerNameController.text,
          reference: _referenceController.text,
          paymentDate: _paymentDate,
          note: _noteController.text,
        ));
  }

  Widget _buildProofArea(BuildContext context, RegistrationState state) {
    if (state.proofFile != null) {
      final isImage = RegExp(r'\.(jpg|jpeg|png)$', caseSensitive: false).hasMatch(state.proofFile!.path);
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: RegColors.surface, borderRadius: BorderRadius.circular(11), border: Border.all(color: RegColors.border)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: isImage
                  ? Image.file(state.proofFile!, width: 44, height: 44, fit: BoxFit.cover)
                  : Container(
                      width: 44,
                      height: 44,
                      color: RegColors.surfaceElevated,
                      child: const Icon(Icons.picture_as_pdf_outlined, color: RegColors.red, size: 22),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.proofFile!.path.split('/').last,
                style: const TextStyle(color: RegColors.textPrimary, fontSize: 12.5),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(onPressed: _pickProof, child: const Text('Replace')),
          ],
        ),
      );
    }
    return InkWell(
      onTap: _pickProof,
      borderRadius: BorderRadius.circular(11),
      child: DottedBorderBox(
        child: Column(
          children: const [
            Icon(Icons.upload_file_outlined, color: RegColors.blue, size: 24),
            SizedBox(height: 8),
            Text('Upload proof of payment', style: TextStyle(color: RegColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            SizedBox(height: 3),
            Text('JPG, PNG or PDF (Max 10MB)', style: TextStyle(color: RegColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitted(BuildContext context, RegistrationState state) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Icon(Icons.access_time_rounded, color: RegColors.amber, size: 48),
        const SizedBox(height: 14),
        const Text('Payment submitted', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: RegColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('Your payment is awaiting manual confirmation.', style: TextStyle(fontSize: 13, color: RegColors.textMuted), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        const RegInfoBanner('We will verify your payment and update the status soon.'),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.read<RegistrationBloc>().add(const PaymentStatusCheckRequested()),
            child: const Text('Check payment status'),
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

  Widget _buildApproved(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Icon(Icons.check_circle, color: RegColors.green, size: 48),
        const SizedBox(height: 14),
        const Text('Payment approved!', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: RegColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('Your payment has been confirmed.', style: TextStyle(fontSize: 13, color: RegColors.textMuted)),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Sign in to your school workspace'),
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
        const Text('Payment rejected', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: RegColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('Your payment could not be confirmed.', style: TextStyle(fontSize: 13, color: RegColors.textMuted), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        if (state.paymentRejectionReason != null && state.paymentRejectionReason!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: RegColors.redSoft, borderRadius: BorderRadius.circular(11), border: Border.all(color: RegColors.red.withValues(alpha: 0.4))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reason', style: TextStyle(color: RegColors.red, fontSize: 11.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(state.paymentRejectionReason!, style: const TextStyle(color: RegColors.textPrimary, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.read<RegistrationBloc>().add(const PaymentContextLoadRequested()),
            child: const Text('Resubmit payment'),
          ),
        ),
      ],
    );
  }
}

class _MethodTile extends StatelessWidget {
  final Color? color;
  final IconData? icon;
  final String label;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    this.color,
    this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: RegColors.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: selected ? RegColors.blue : RegColors.border, width: selected ? 1.4 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color ?? RegColors.surfaceElevated, borderRadius: BorderRadius.circular(8)),
              child: icon != null
                  ? Icon(icon, color: RegColors.blue, size: 18)
                  : Text(label, style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: RegColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: RegColors.textMuted, fontSize: 11.5)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: RegColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

/// Dashed-border upload box, matching the reference design.
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: RegColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: RegColors.border, width: 1.4),
      ),
      child: Center(child: child),
    );
  }
}
