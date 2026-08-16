import 'package:flutter/material.dart';
import 'package:school_pulse/features/communication_center/domain/entities/communication_campaign.dart';

class CampaignStatusChip extends StatelessWidget {
  final CommunicationStatus status;
  const CampaignStatusChip({super.key, required this.status});

  (Color, Color, String) _style(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case CommunicationStatus.draft:
        return (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
          'Draft',
        );
      case CommunicationStatus.pendingApproval:
        return (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
          'Pending approval',
        );
      case CommunicationStatus.approved:
        return (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
          'Approved',
        );
      case CommunicationStatus.scheduled:
        return (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
          'Scheduled',
        );
      case CommunicationStatus.publishing:
        return (
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
          'Publishing',
        );
      case CommunicationStatus.published:
        return (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          'Published',
        );
      case CommunicationStatus.partiallyDelivered:
        return (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
          'Partially delivered',
        );
      case CommunicationStatus.delivered:
        return (
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          'Delivered',
        );
      case CommunicationStatus.failed:
        return (scheme.errorContainer, scheme.onErrorContainer, 'Failed');
      case CommunicationStatus.cancelled:
        return (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
          'Cancelled',
        );
      case CommunicationStatus.expired:
        return (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
          'Expired',
        );
      case CommunicationStatus.archived:
        return (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
          'Archived',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (background, foreground, label) = _style(context);
    return Chip(
      label: Text(label, style: TextStyle(color: foreground, fontSize: 12)),
      backgroundColor: background,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
