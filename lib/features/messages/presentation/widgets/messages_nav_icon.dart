import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/messages/presentation/bloc/messaging_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// The Messages nav-bar icon with a live unread-count badge, so "Messages
/// (7)" reflects what MessagingBloc's inbox subscription actually holds
/// rather than a locally-incremented guess. Reads the same session-wide
/// MessagingBloc singleton every other messaging screen uses, so the badge
/// stays in sync with the inbox without a separate subscription per shell.
class MessagesNavIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;

  const MessagesNavIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagingBloc, MessagingState>(
      bloc: di.sl<MessagingBloc>(),
      buildWhen: (previous, current) =>
          previous.totalUnreadCount != current.totalUnreadCount,
      builder: (context, state) {
        final count = state.totalUnreadCount;
        return Badge(
          backgroundColor: AppColors.danger(context),
          textColor: AppColors.white,
          isLabelVisible: count > 0,
          label: Text(count > 99 ? '99+' : '$count'),
          child: Icon(icon, size: size, color: color),
        );
      },
    );
  }
}
