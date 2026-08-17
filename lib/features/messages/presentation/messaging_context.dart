import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/messages/domain/repositories/messages_repository.dart';
import 'package:school_pulse/features/messages/presentation/bloc/messaging_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// [MessagingBloc] is registered as a lazySingleton (see
/// injection_container.dart), so every messaging screen shares the one
/// instance without a BlocProvider ancestor - matching the lightweight
/// [messages] repository accessor below rather than requiring the whole
/// app router to be wrapped in a provider for one feature.
extension MessagingContext on BuildContext {
  /// The signed-in user, or null while auth is still resolving.
  UserEntity? get messagingUser {
    final state = read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user : null;
  }

  MessagesRepository get messages => di.sl<MessagesRepository>();

  MessagingBloc get messagingBloc => di.sl<MessagingBloc>();

  void showMessagingSnack(String text) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Dispatches [event] to [MessagingBloc] and awaits the one outcome that
  /// follows it (idle/submitting -> success/failure), rather than staying
  /// subscribed - for the common "fire a gated action, then navigate or show
  /// why it was refused" flow used by every new-conversation/broadcast/group
  /// screen. Not reentrant-safe against a second gated action firing on the
  /// same bloc before this one resolves (the bloc is a session-wide
  /// singleton), which is fine since these are all explicit, one-shot user
  /// button presses.
  Future<MessagingState> dispatchMessagingAction(MessagingEvent event) {
    final bloc = messagingBloc;
    final resultReady = bloc.stream.firstWhere(
      (state) => state.actionStatus != MessagingActionStatus.submitting,
    );
    bloc.add(event);
    return resultReady.timeout(
      const Duration(seconds: 10),
      onTimeout: () => bloc.state,
    );
  }
}

/// Renders [builder] once the signed-in user is known, and a spinner (or a
/// sign-in prompt) otherwise - saves every messaging screen repeating the
/// same null check on [AuthBloc]. Also the single place [MessagingStarted]
/// is dispatched, so every messaging screen entered through this wrapper
/// gets the bloc's inbox subscription for free without dispatching it
/// itself (MessagingBloc.add is idempotent per user id - see
/// MessagingBloc._onStarted).
class MessagingUserBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, UserEntity user) builder;

  const MessagingUserBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          current is AuthAuthenticated || current is AuthUnauthenticated,
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Center(child: SchoolPulseLoader());
        }
        context.messagingBloc.add(MessagingStarted(state.user));
        return builder(context, state.user);
      },
    );
  }
}
