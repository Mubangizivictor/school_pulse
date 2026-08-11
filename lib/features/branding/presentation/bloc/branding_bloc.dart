import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/branding/data/branding_local_cache.dart';
import 'package:school_pulse/features/branding/domain/usecases/get_school_branding.dart';
import 'branding_event.dart';
import 'branding_state.dart';

class BrandingBloc extends Bloc<BrandingEvent, BrandingState> {
  final BrandingLocalCache localCache;
  final GetSchoolBranding getSchoolBranding;

  BrandingBloc({required this.localCache, required this.getSchoolBranding})
    : super(BrandingInitial()) {
    on<InitializeBranding>(_onInitializeBranding);
    on<BrandingUpdateRequested>(_onBrandingUpdateRequested);
    on<FetchBrandingForSchool>(_onFetchBrandingForSchool);
    on<ClearBranding>(_onClearBranding);
  }

  Future<void> _onInitializeBranding(
    InitializeBranding event,
    Emitter<BrandingState> emit,
  ) async {
    final cached = await localCache.get();
    emit(BrandingLoaded(cached));
  }

  Future<void> _onBrandingUpdateRequested(
    BrandingUpdateRequested event,
    Emitter<BrandingState> emit,
  ) async {
    await localCache.save(event.branding);
    emit(BrandingLoaded(event.branding));
  }

  Future<void> _onFetchBrandingForSchool(
    FetchBrandingForSchool event,
    Emitter<BrandingState> emit,
  ) async {
    final result = await getSchoolBranding(event.schoolId);
    await result.fold(
      (failure) async {
        // Handle failure if needed, maybe keep current state
      },
      (branding) async {
        await localCache.save(branding);
        emit(BrandingLoaded(branding));
      },
    );
  }

  Future<void> _onClearBranding(
    ClearBranding event,
    Emitter<BrandingState> emit,
  ) async {
    await localCache.clear();
    emit(const BrandingLoaded(null));
  }
}
