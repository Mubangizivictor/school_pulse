import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../data/models/system_config.dart';

abstract class SystemConfigEvent extends Equatable {
  const SystemConfigEvent();

  @override
  List<Object?> get props => [];
}

class LoadSystemConfig extends SystemConfigEvent {}

class UpdateSystemConfig extends SystemConfigEvent {
  final SystemConfig config;

  const UpdateSystemConfig(this.config);

  @override
  List<Object?> get props => [config];
}

class WatchSystemConfig extends SystemConfigEvent {}

class UploadSchoolLogo extends SystemConfigEvent {
  final File imageFile;

  const UploadSchoolLogo(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}
