import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:school_pulse/features/branding/data/models/school_branding_isar.dart';
import 'package:school_pulse/features/branding/domain/entities/school_branding.dart';
import 'package:school_pulse/features/branding/domain/usecases/get_school_branding.dart';
import 'branding_event.dart';
import 'branding_state.dart';

class BrandingBloc extends Bloc<BrandingEvent, BrandingState> {
  final Isar isar;
  final GetSchoolBranding getSchoolBranding;

  BrandingBloc({required this.isar, required this.getSchoolBranding})
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
    final cached = await isar.schoolBrandingIsars.where().findFirst();
    if (cached != null) {
      emit(BrandingLoaded(_fromIsar(cached)));
    } else {
      emit(const BrandingLoaded(null));
    }
  }

  Future<void> _onBrandingUpdateRequested(
    BrandingUpdateRequested event,
    Emitter<BrandingState> emit,
  ) async {
    await _saveToIsar(event.branding);
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
        await _saveToIsar(branding);
        emit(BrandingLoaded(branding));
      },
    );
  }

  Future<void> _onClearBranding(
    ClearBranding event,
    Emitter<BrandingState> emit,
  ) async {
    await isar.writeTxn(() async {
      await isar.schoolBrandingIsars.clear();
    });
    emit(const BrandingLoaded(null));
  }

  Future<void> _saveToIsar(SchoolBranding branding) async {
    await isar.writeTxn(() async {
      final isarModel = SchoolBrandingIsar()
        ..schoolId = branding.schoolId
        ..schoolName = branding.schoolName
        ..schoolMotto = branding.schoolMotto
        ..logoUrl = branding.logoUrl
        ..badgeUrl = branding.badgeUrl
        ..primaryColor = branding.primaryColor
        ..secondaryColor = branding.secondaryColor
        ..accentColor = branding.accentColor
        ..welcomeMessage = branding.welcomeMessage
        ..dashboardBannerUrl = branding.dashboardBannerUrl
        ..loginBackgroundUrl = branding.loginBackgroundUrl
        ..version = branding.version;

      await isar.schoolBrandingIsars.put(isarModel);
    });
  }

  SchoolBranding _fromIsar(SchoolBrandingIsar isarModel) {
    return SchoolBranding(
      schoolId: isarModel.schoolId,
      schoolName: isarModel.schoolName,
      schoolMotto: isarModel.schoolMotto,
      logoUrl: isarModel.logoUrl,
      badgeUrl: isarModel.badgeUrl,
      primaryColor: isarModel.primaryColor,
      secondaryColor: isarModel.secondaryColor,
      accentColor: isarModel.accentColor,
      welcomeMessage: isarModel.welcomeMessage,
      dashboardBannerUrl: isarModel.dashboardBannerUrl,
      loginBackgroundUrl: isarModel.loginBackgroundUrl,
      version: isarModel.version,
    );
  }
}
