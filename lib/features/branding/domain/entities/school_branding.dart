import 'package:equatable/equatable.dart';

class SchoolBranding extends Equatable {
  final String schoolId;
  final String schoolName;
  final String schoolMotto;
  final String? logoUrl;
  final String? badgeUrl;
  final String? primaryColor;
  final String? secondaryColor;
  final String? accentColor;
  final String? welcomeMessage;
  final String? dashboardBannerUrl;
  final String? loginBackgroundUrl;
  final int version;

  const SchoolBranding({
    required this.schoolId,
    required this.schoolName,
    required this.schoolMotto,
    this.logoUrl,
    this.badgeUrl,
    this.primaryColor,
    this.secondaryColor,
    this.accentColor,
    this.welcomeMessage,
    this.dashboardBannerUrl,
    this.loginBackgroundUrl,
    this.version = 1,
  });

  @override
  List<Object?> get props => [
    schoolId,
    schoolName,
    schoolMotto,
    logoUrl,
    badgeUrl,
    primaryColor,
    secondaryColor,
    accentColor,
    welcomeMessage,
    dashboardBannerUrl,
    loginBackgroundUrl,
    version,
  ];

  SchoolBranding copyWith({
    String? schoolName,
    String? schoolMotto,
    String? logoUrl,
    String? badgeUrl,
    String? primaryColor,
    String? secondaryColor,
    String? accentColor,
    String? welcomeMessage,
    String? dashboardBannerUrl,
    String? loginBackgroundUrl,
    int? version,
  }) {
    return SchoolBranding(
      schoolId: schoolId,
      schoolName: schoolName ?? this.schoolName,
      schoolMotto: schoolMotto ?? this.schoolMotto,
      logoUrl: logoUrl ?? this.logoUrl,
      badgeUrl: badgeUrl ?? this.badgeUrl,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      dashboardBannerUrl: dashboardBannerUrl ?? this.dashboardBannerUrl,
      loginBackgroundUrl: loginBackgroundUrl ?? this.loginBackgroundUrl,
      version: version ?? this.version,
    );
  }
}
