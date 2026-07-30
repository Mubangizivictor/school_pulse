import 'package:equatable/equatable.dart';
import 'package:school_pulse/features/branding/domain/entities/school_branding.dart';

abstract class BrandingEvent extends Equatable {
  const BrandingEvent();

  @override
  List<Object?> get props => [];
}

class InitializeBranding extends BrandingEvent {}

class BrandingUpdateRequested extends BrandingEvent {
  final SchoolBranding branding;
  const BrandingUpdateRequested(this.branding);

  @override
  List<Object?> get props => [branding];
}

class FetchBrandingForSchool extends BrandingEvent {
  final String schoolId;
  const FetchBrandingForSchool(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class ClearBranding extends BrandingEvent {}
