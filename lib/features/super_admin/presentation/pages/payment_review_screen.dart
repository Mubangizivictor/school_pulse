import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/super_admin/domain/entities/manual_subscription_payment.dart';

import 'payment_inspector.dart';

/// Mobile / pushed-route payment-review surface. Hosts [PaymentInspector] with
/// every proof and Approve/Reject control.
///
/// Two entry points, both preserved from the previous implementation:
///  * [PaymentReviewScreen.open] — opens a bottom sheet, syncs the browser URL
///    to `/super-admin/payments/:id` while it is up and back on close
///    (address-bar/history signalling only), and resolves to `true` when the
///    payment was approved or rejected.
///  * `PaymentReviewScreen(payment: …)` as a widget on a [MaterialPageRoute] —
///    a full-page Scaffold that pops `true` on a successful decision.
class PaymentReviewScreen extends StatelessWidget {
  const PaymentReviewScreen({super.key, required this.payment});

  final ManualSubscriptionPayment payment;

  static Future<bool?> open(
    BuildContext context,
    ManualSubscriptionPayment payment,
  ) async {
    const sectionUrl = '/super-admin/payments';
    final detailUrl = '$sectionUrl/${payment.id}';

    var mutated = false;
    final future = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.border(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: PaymentInspector(
                      payment: payment,
                      scrollable: false,
                      onClose: () => Navigator.pop(sheetContext),
                      onMutated: () {
                        mutated = true;
                        Navigator.pop(sheetContext);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    if (context.mounted) context.go(detailUrl);
    await future;
    if (context.mounted) context.go(sectionUrl);
    return mutated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment review'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: PaymentInspector(
        payment: payment,
        onMutated: () => Navigator.pop(context, true),
      ),
    );
  }
}
