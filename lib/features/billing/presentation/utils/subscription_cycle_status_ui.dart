import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/billing/domain/entities/subscription_cycle.dart';

/// Shared status → label/color mapping for [SubscriptionCycleStatus], so the
/// Super Admin billing screens and the School Admin calendar screen render
/// identical badges for the same status instead of drifting independently.
///
/// Mapping (per spec): upcoming/invoiced -> information, paymentPending/
/// gracePeriod -> warning, paid -> success, overdue/suspended/cancelled/
/// expired -> danger.
String cycleStatusLabel(SubscriptionCycleStatus status) => switch (status) {
  SubscriptionCycleStatus.upcoming => 'Upcoming',
  SubscriptionCycleStatus.invoiced => 'Invoiced',
  SubscriptionCycleStatus.paymentPending => 'Payment pending',
  SubscriptionCycleStatus.paid => 'Paid',
  SubscriptionCycleStatus.gracePeriod => 'Grace period',
  SubscriptionCycleStatus.overdue => 'Overdue',
  SubscriptionCycleStatus.suspended => 'Suspended',
  SubscriptionCycleStatus.cancelled => 'Cancelled',
  SubscriptionCycleStatus.expired => 'Expired',
};

Color cycleStatusColor(BuildContext context, SubscriptionCycleStatus status) =>
    switch (status) {
      SubscriptionCycleStatus.upcoming ||
      SubscriptionCycleStatus.invoiced => AppColors.information(context),
      SubscriptionCycleStatus.paymentPending ||
      SubscriptionCycleStatus.gracePeriod => AppColors.warning(context),
      SubscriptionCycleStatus.paid => AppColors.success(context),
      SubscriptionCycleStatus.overdue ||
      SubscriptionCycleStatus.suspended ||
      SubscriptionCycleStatus.cancelled ||
      SubscriptionCycleStatus.expired => AppColors.danger(context),
    };
