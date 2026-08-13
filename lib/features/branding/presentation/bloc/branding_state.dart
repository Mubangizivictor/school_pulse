import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/branding/domain/entities/school_branding.dart';

abstract class BrandingState extends Equatable {
  const BrandingState();

  @override
  List<Object?> get props => [];
}

class BrandingInitial extends BrandingState {}

/// The only branding state allowed before tenant membership is verified.
class PlatformBranding extends BrandingState {}

class BrandingLoading extends BrandingState {}

class BrandingLoaded extends BrandingState {
  final SchoolBranding? branding;
  const BrandingLoaded(this.branding);

  @override
  List<Object?> get props => [branding];
}

class BrandingError extends BrandingState {
  final String message;
  const BrandingError(this.message);

  @override
  List<Object?> get props => [message];
}
