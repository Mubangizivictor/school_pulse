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
    // A cache is only a presentation optimisation after membership has been
    // checked.  Never paint an arbitrary previous tenant at platform start.
    emit(PlatformBranding());
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
    emit(BrandingLoading());
    final cached = await localCache.get();
    final result = await getSchoolBranding(event.schoolId);
    await result.fold(
      (failure) async {
        // Offline fallback is deliberately tenant-bound. A cache for School A
        // must never be used while bootstrapping School B.
        if (cached != null && cached.schoolId == event.schoolId) {
          emit(BrandingLoaded(cached));
        } else {
          emit(BrandingError(failure.message));
        }
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
    emit(PlatformBranding());
  }
}
