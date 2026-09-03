import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/billing/domain/entities/subscription_cycle.dart';
import 'package:school_pulse/features/billing/presentation/utils/subscription_cycle_status_ui.dart';

void main() {
  Widget wrap(WidgetBuilder builder) =>
      MaterialApp(home: Builder(builder: builder));

  group('cycleStatusLabel', () {
    test('gives a distinct human-readable label for every status', () {
      final labels = SubscriptionCycleStatus.values
          .map(cycleStatusLabel)
          .toSet();
      expect(labels.length, SubscriptionCycleStatus.values.length);
      expect(cycleStatusLabel(SubscriptionCycleStatus.upcoming), 'Upcoming');
      expect(
        cycleStatusLabel(SubscriptionCycleStatus.paymentPending),
        'Payment pending',
      );
      expect(
        cycleStatusLabel(SubscriptionCycleStatus.gracePeriod),
        'Grace period',
      );
      expect(cycleStatusLabel(SubscriptionCycleStatus.paid), 'Paid');
    });
  });

  group('cycleStatusColor', () {
    testWidgets('maps every status to the documented semantic color', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap((context) {
          expect(
            cycleStatusColor(context, SubscriptionCycleStatus.upcoming),
            AppColors.information(context),
          );
          expect(
            cycleStatusColor(context, SubscriptionCycleStatus.invoiced),
            AppColors.information(context),
          );
          expect(
            cycleStatusColor(context, SubscriptionCycleStatus.paymentPending),
            AppColors.warning(context),
          );
          expect(
            cycleStatusColor(context, SubscriptionCycleStatus.gracePeriod),
            AppColors.warning(context),
          );
          expect(
            cycleStatusColor(context, SubscriptionCycleStatus.paid),
            AppColors.success(context),
          );
          expect(
            cycleStatusColor(context, SubscriptionCycleStatus.overdue),
            AppColors.danger(context),
          );
          expect(
            cycleStatusColor(context, SubscriptionCycleStatus.suspended),
            AppColors.danger(context),
          );
          expect(
            cycleStatusColor(context, SubscriptionCycleStatus.cancelled),
            AppColors.danger(context),
          );
          expect(
            cycleStatusColor(context, SubscriptionCycleStatus.expired),
            AppColors.danger(context),
          );
          return const SizedBox.shrink();
        }),
      );
    });
  });
}
