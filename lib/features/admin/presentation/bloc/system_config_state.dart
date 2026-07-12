import 'package:equatable/equatable.dart';
import '../../data/models/system_config.dart';

abstract class SystemConfigState extends Equatable {
  const SystemConfigState();
  
  @override
  List<Object?> get props => [];
}

class SystemConfigInitial extends SystemConfigState {}

class SystemConfigLoading extends SystemConfigState {}

class SystemConfigLoaded extends SystemConfigState {
  final SystemConfig config;

  const SystemConfigLoaded(this.config);

  @override
  List<Object?> get props => [config];
}

class SystemConfigError extends SystemConfigState {
  final String message;
  final SystemConfig? config;

  const SystemConfigError(this.message, {this.config});

  @override
  List<Object?> get props => [message, config];
}

class SystemConfigUpdated extends SystemConfigState {
  final SystemConfig config;

  const SystemConfigUpdated(this.config);

  @override
  List<Object?> get props => [config];
}

class SystemConfigLogoUploading extends SystemConfigState {
  final SystemConfig config;

  const SystemConfigLogoUploading(this.config);

  @override
  List<Object?> get props => [config];
}
