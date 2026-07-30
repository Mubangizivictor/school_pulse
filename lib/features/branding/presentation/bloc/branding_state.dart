import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/branding/domain/entities/school_branding.dart';

abstract class BrandingState extends Equatable {
  const BrandingState();

  @override
  List<Object?> get props => [];
}

class BrandingInitial extends BrandingState {}

class BrandingLoading extends BrandingState {}

class BrandingLoaded extends BrandingState {
  final SchoolBranding? branding;
  const BrandingLoaded(this.branding);

  @override
  List<Object?> get props => [branding];
}
