import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_dashboard_summary.dart';

/// Icon for a [ClassActivityEntry.action], shared between the dashboard's
/// capped preview and the full activities list so both stay in sync.
IconData iconForClassActivity(String action) {
  if (action.startsWith('attendance')) return Icons.how_to_reg;
  if (action.startsWith('homework')) return Icons.assignment_outlined;
  if (action.startsWith('behaviour')) return Icons.flag_outlined;
  if (action.startsWith('achievement')) return Icons.emoji_events_outlined;
  if (action.startsWith('announcement')) return Icons.campaign_outlined;
  if (action.startsWith('message')) return Icons.chat_bubble_outline;
  if (action.startsWith('report') ||
      action.startsWith('competency') ||
      action.startsWith('conduct') ||
      action.startsWith('comment')) {
    return Icons.description_outlined;
  }
  if (action.startsWith('task')) return Icons.checklist_outlined;
  if (action.startsWith('resource')) return Icons.folder_open;
  return Icons.history;
}

/// Sends the user to wherever a [ClassActivityEntry] came from. Routed by
/// the action prefix, since that's the only thing every activity type is
/// guaranteed to have - not every entry carries a resolvable entityId.
void navigateToClassActivity(
  BuildContext context,
  ClassActivityEntry activity,
) {
  final action = activity.action;
  if (action.startsWith('attendance')) {
    context.push('/staff/roll-call/history');
    return;
  }
  if (action.startsWith('homework')) {
    context.push('/staff/resources');
    return;
  }
  if (action.startsWith('behaviour')) {
    context.push('/staff/more/reports');
    return;
  }
  if (action.startsWith('achievement')) {
    context.push('/staff/more/reports');
    return;
  }
  if (action.startsWith('announcement')) {
    context.push('/staff/more/announcements');
    return;
  }
  if (action.startsWith('message')) {
    context.push('/staff/messages');
    return;
  }
  if (action.startsWith('report') ||
      action.startsWith('competency') ||
      action.startsWith('conduct') ||
      action.startsWith('comment')) {
    context.push('/staff/more/reports');
    return;
  }
  if (action.startsWith('task')) {
    context.push('/staff/tasks');
    return;
  }
  if (action.startsWith('resource')) {
    context.push('/staff/resources');
    return;
  }
  // Unknown action type: nothing sensible to navigate to.
}
