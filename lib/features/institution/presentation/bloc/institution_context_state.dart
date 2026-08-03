import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/institution/domain/entities/institution_context.dart';

abstract class InstitutionContextState extends Equatable {
  const InstitutionContextState();

  @override
  List<Object?> get props => [];
}

class InstitutionContextInitial extends InstitutionContextState {
  const InstitutionContextInitial();
}

class InstitutionContextLoading extends InstitutionContextState {
  const InstitutionContextLoading();
}

class InstitutionContextLoaded extends InstitutionContextState {
  final InstitutionContext context;

  const InstitutionContextLoaded(this.context);

  @override
  List<Object?> get props => [context];
}

/// Institution status is suspended/archived - the router redirects
/// institution-scoped routes away, but data must not be treated as gone.
class InstitutionContextSuspended extends InstitutionContextState {
  final InstitutionContext context;

  const InstitutionContextSuspended(this.context);

  @override
  List<Object?> get props => [context];
}

class InstitutionContextError extends InstitutionContextState {
  final String message;

  const InstitutionContextError(this.message);

  @override
  List<Object?> get props => [message];
}
