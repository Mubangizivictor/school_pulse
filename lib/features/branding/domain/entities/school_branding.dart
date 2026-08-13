import 'package:equatable/equatable.dart';

class SchoolBranding extends Equatable {
  final String schoolId;
  final String schoolName;

  /// Structure-provided initials, or a deterministic name-derived fallback.
  final String schoolInitials;
  final String schoolMotto;
  final String? schoolType;
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
    this.schoolInitials = '',
    required this.schoolMotto,
    this.schoolType,
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

  String get effectiveInitials {
    if (schoolInitials.trim().isNotEmpty) return schoolInitials.trim();
    return schoolName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(3)
        .map((part) => part[0].toUpperCase())
        .join();
  }

  @override
  List<Object?> get props => [
    schoolId,
    schoolName,
    schoolInitials,
    schoolMotto,
    schoolType,
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
    String? schoolInitials,
    String? schoolMotto,
    String? schoolType,
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
      schoolInitials: schoolInitials ?? this.schoolInitials,
      schoolMotto: schoolMotto ?? this.schoolMotto,
      schoolType: schoolType ?? this.schoolType,
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
