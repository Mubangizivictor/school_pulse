import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/branding/domain/entities/school_branding.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_bloc.dart';
import 'package:school_pulse/features/branding/presentation/bloc/branding_event.dart';
import '../../data/models/system_config.dart';
import '../../data/repositories/system_config_repository.dart';
import 'system_config_event.dart';
import 'system_config_state.dart';

class SystemConfigBloc extends Bloc<SystemConfigEvent, SystemConfigState> {
  final SystemConfigRepository repository;
  final BrandingBloc brandingBloc;

  SystemConfigBloc({
    required this.repository,
    required this.brandingBloc,
  }) : super(SystemConfigInitial()) {
    on<LoadSystemConfig>((event, emit) async {
      emit(SystemConfigLoading());
      try {
        final config = await repository.getConfig();
        _updateBrandingFromConfig(config);
        emit(SystemConfigLoaded(config));
      } catch (e) {
        emit(SystemConfigError(e.toString()));
      }
    });

    on<UpdateSystemConfig>((event, emit) async {
      final currentConfig = _getCurrentConfig();
      try {
        await repository.updateConfig(event.config);
        _updateBrandingFromConfig(event.config);
        emit(SystemConfigUpdated(event.config));
        emit(SystemConfigLoaded(event.config));
      } catch (e) {
        emit(SystemConfigError(e.toString(), config: currentConfig));
      }
    });

    on<WatchSystemConfig>((event, emit) async {
      await emit.forEach(
        repository.watchConfig(),
        onData: (config) {
          _updateBrandingFromConfig(config);
          return SystemConfigLoaded(config);
        },
        onError: (e, stackTrace) => SystemConfigError(e.toString(), config: _getCurrentConfig()),
      );
    });

    on<UploadSchoolLogo>((event, emit) async {
      final currentConfig = _getCurrentConfig();
      if (currentConfig != null) {
        emit(SystemConfigLogoUploading(currentConfig));
      }
      
      try {
        final logoUrl = await repository.uploadLogo(event.imageFile);
        final latestConfig = await repository.getConfig();
        final newConfig = latestConfig.copyWith(schoolLogoUrl: logoUrl);
        await repository.updateConfig(newConfig);
        _updateBrandingFromConfig(newConfig);
        emit(SystemConfigLoaded(newConfig));
      } catch (e) {
        emit(SystemConfigError(e.toString(), config: currentConfig));
      }
    });
  }

  void _updateBrandingFromConfig(SystemConfig config) {
    brandingBloc.add(BrandingUpdateRequested(SchoolBranding(
      schoolId: 'system', // Consistent with the collection('config').doc('system') logic
      schoolName: config.schoolName,
      schoolMotto: config.schoolMotto,
      logoUrl: config.schoolLogoUrl,
      primaryColor: config.primaryColor,
      secondaryColor: config.secondaryColor,
      version: 1,
    )));
  }

  SystemConfig? _getCurrentConfig() {
    if (state is SystemConfigLoaded) {
      return (state as SystemConfigLoaded).config;
    } else if (state is SystemConfigUpdated) {
      return (state as SystemConfigUpdated).config;
    } else if (state is SystemConfigError) {
      return (state as SystemConfigError).config;
    }
    return null;
  }
}
