import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/messages/domain/repositories/messages_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Messaging is one of the few features every role shares, so rather than a
/// per-role bloc the screens read the signed-in user straight off [AuthBloc]
/// and stream from [MessagesRepository]. Everything the screens show is a
/// live Firestore query with no derived state worth holding, so a bloc layer
/// would only forward streams.
extension MessagingContext on BuildContext {
  /// The signed-in user, or null while auth is still resolving.
  UserEntity? get messagingUser {
    final state = read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user : null;
  }

  MessagesRepository get messages => di.sl<MessagesRepository>();

  void showMessagingSnack(String text) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(text)));
  }
}

/// Renders [builder] once the signed-in user is known, and a spinner (or a
/// sign-in prompt) otherwise - saves every messaging screen repeating the
/// same null check on [AuthBloc].
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
        return builder(context, state.user);
      },
    );
  }
}
