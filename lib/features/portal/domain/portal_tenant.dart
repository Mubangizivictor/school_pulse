import 'package:school_pulse/features/branding/domain/entities/school_branding.dart';

/// Allowlisted public data used to select a tenant before sign-in.
class PortalTenant {
  const PortalTenant({
    required this.schoolId,
    required this.hostname,
    required this.slug,
    required this.schoolName,
    this.logoUrl,
    this.primaryColor,
    this.secondaryColor,
  });
  final String schoolId, hostname, slug, schoolName;
  final String? logoUrl, primaryColor, secondaryColor;
  SchoolBranding get branding => SchoolBranding(
    schoolId: schoolId,
    schoolName: schoolName,
    schoolMotto: '',
    logoUrl: logoUrl,
    primaryColor: primaryColor,
    secondaryColor: secondaryColor,
  );
  factory PortalTenant.fromMap(String host, Map<String, dynamic> data) =>
      PortalTenant(
        schoolId: data['schoolId'] as String,
        hostname: host,
        slug: data['slug'] as String? ?? '',
        schoolName: data['schoolName'] as String? ?? 'School Portal',
        logoUrl: data['logoUrl'] as String?,
        primaryColor: data['primaryColor'] as String?,
        secondaryColor: data['secondaryColor'] as String?,
      );
}
