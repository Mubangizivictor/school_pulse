import 'package:isar/isar.dart';

part 'school_branding_isar.g.dart';

@collection
class SchoolBrandingIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String schoolId;
  
  late String schoolName;
  late String schoolMotto;
  String? logoUrl;
  String? badgeUrl;
  String? primaryColor;
  String? secondaryColor;
  String? accentColor;
  String? welcomeMessage;
  String? dashboardBannerUrl;
  String? loginBackgroundUrl;
  late int version;
}
