import 'package:isar/isar.dart';
import '../domain/entities/school_branding.dart';
import 'models/school_branding_isar.dart';
import 'branding_local_cache.dart';

BrandingLocalCache create({dynamic isar}) =>
    BrandingLocalCacheMobile(isar as Isar);

class BrandingLocalCacheMobile implements BrandingLocalCache {
  final Isar isar;

  BrandingLocalCacheMobile(this.isar);

  @override
  Future<SchoolBranding?> get() async {
    final cached = await isar.schoolBrandingIsars.where().findFirst();
    if (cached == null) return null;
    return SchoolBranding(
      schoolId: cached.schoolId,
      schoolName: cached.schoolName,
      schoolMotto: cached.schoolMotto,
      logoUrl: cached.logoUrl,
      badgeUrl: cached.badgeUrl,
      primaryColor: cached.primaryColor,
      secondaryColor: cached.secondaryColor,
      accentColor: cached.accentColor,
      welcomeMessage: cached.welcomeMessage,
      dashboardBannerUrl: cached.dashboardBannerUrl,
      loginBackgroundUrl: cached.loginBackgroundUrl,
      version: cached.version,
    );
  }

  @override
  Future<void> save(SchoolBranding branding) async {
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

  @override
  Future<void> clear() async {
    await isar.writeTxn(() async {
      await isar.schoolBrandingIsars.clear();
    });
  }
}
