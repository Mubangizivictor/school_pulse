import 'package:equatable/equatable.dart';

/// The full institutional identity/profile for the school - a singleton
/// document (like FeatureToggles), not a list. Deliberately overlaps some
/// fields already on admin's SystemConfig (name, motto, logo, colors) -
/// this is Structure's own richer copy per spec; SystemConfig is untouched.
class InstitutionProfile extends Equatable {
  /// Tenant identity is deliberately kept with the editable profile, rather
  /// than duplicated in feature-specific configuration documents.
  final String institutionId;
  final String displayName;
  final String displayLabel;
  final String initials;
  final String name;
  final String shortName;
  final String motto;
  final String vision;
  final String mission;
  final String logoUrl;
  final String badgeUrl;
  final List<String> colors;
  final String schoolType;
  final String schoolCategory;
  final String registrationNumber;
  final String ministryRegistrationNumber;
  final String taxNumber;
  final String country;
  final String district;
  final String city;
  final String address;
  final double? gpsLat;
  final double? gpsLng;
  final String phone;
  final String secondaryPhone;
  final String whatsappNumber;
  final String email;
  final String supportEmail;
  final String website;
  final Map<String, String> socialMedia;
  final String timeZone;
  final String currency;
  final String language;
  final String dateFormat;
  final String timeFormat;
  final String postalAddress;
  final String legalEntityName;
  final String ownershipType;
  final int? foundingYear;
  final int brandingVersion;
  final int version;

  const InstitutionProfile({
    this.institutionId = '',
    this.displayName = '',
    this.displayLabel = '',
    this.initials = '',
    this.name = '',
    this.shortName = '',
    this.motto = '',
    this.vision = '',
    this.mission = '',
    this.logoUrl = '',
    this.badgeUrl = '',
    this.colors = const [],
    this.schoolType = '',
    this.schoolCategory = '',
    this.registrationNumber = '',
    this.ministryRegistrationNumber = '',
    this.taxNumber = '',
    this.country = '',
    this.district = '',
    this.city = '',
    this.address = '',
    this.gpsLat,
    this.gpsLng,
    this.phone = '',
    this.secondaryPhone = '',
    this.whatsappNumber = '',
    this.email = '',
    this.supportEmail = '',
    this.website = '',
    this.socialMedia = const {},
    this.timeZone = '',
    this.currency = '',
    this.language = '',
    this.dateFormat = '',
    this.timeFormat = '',
    this.postalAddress = '',
    this.legalEntityName = '',
    this.ownershipType = '',
    this.foundingYear,
    this.brandingVersion = 1,
    this.version = 1,
  });

  InstitutionProfile copyWith({
    String? institutionId,
    String? displayName,
    String? displayLabel,
    String? initials,
    String? name,
    String? shortName,
    String? motto,
    String? vision,
    String? mission,
    String? logoUrl,
    String? badgeUrl,
    List<String>? colors,
    String? schoolType,
    String? schoolCategory,
    String? registrationNumber,
    String? ministryRegistrationNumber,
    String? taxNumber,
    String? country,
    String? district,
    String? city,
    String? address,
    double? gpsLat,
    double? gpsLng,
    String? phone,
    String? secondaryPhone,
    String? whatsappNumber,
    String? email,
    String? supportEmail,
    String? website,
    Map<String, String>? socialMedia,
    String? timeZone,
    String? currency,
    String? language,
    String? dateFormat,
    String? timeFormat,
    String? postalAddress,
    String? legalEntityName,
    String? ownershipType,
    int? foundingYear,
    int? brandingVersion,
    int? version,
  }) {
    return InstitutionProfile(
      institutionId: institutionId ?? this.institutionId,
      displayName: displayName ?? this.displayName,
      displayLabel: displayLabel ?? this.displayLabel,
      initials: initials ?? this.initials,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      motto: motto ?? this.motto,
      vision: vision ?? this.vision,
      mission: mission ?? this.mission,
      logoUrl: logoUrl ?? this.logoUrl,
      badgeUrl: badgeUrl ?? this.badgeUrl,
      colors: colors ?? this.colors,
      schoolType: schoolType ?? this.schoolType,
      schoolCategory: schoolCategory ?? this.schoolCategory,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      ministryRegistrationNumber:
          ministryRegistrationNumber ?? this.ministryRegistrationNumber,
      taxNumber: taxNumber ?? this.taxNumber,
      country: country ?? this.country,
      district: district ?? this.district,
      city: city ?? this.city,
      address: address ?? this.address,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      phone: phone ?? this.phone,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      email: email ?? this.email,
      supportEmail: supportEmail ?? this.supportEmail,
      website: website ?? this.website,
      socialMedia: socialMedia ?? this.socialMedia,
      timeZone: timeZone ?? this.timeZone,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      postalAddress: postalAddress ?? this.postalAddress,
      legalEntityName: legalEntityName ?? this.legalEntityName,
      ownershipType: ownershipType ?? this.ownershipType,
      foundingYear: foundingYear ?? this.foundingYear,
      brandingVersion: brandingVersion ?? this.brandingVersion,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
    institutionId,
    displayName,
    displayLabel,
    initials,
    name,
    shortName,
    motto,
    vision,
    mission,
    logoUrl,
    badgeUrl,
    colors,
    schoolType,
    schoolCategory,
    registrationNumber,
    ministryRegistrationNumber,
    taxNumber,
    country,
    district,
    city,
    address,
    gpsLat,
    gpsLng,
    phone,
    secondaryPhone,
    whatsappNumber,
    email,
    supportEmail,
    website,
    socialMedia,
    timeZone,
    currency,
    language,
    dateFormat,
    timeFormat,
    postalAddress,
    legalEntityName,
    ownershipType,
    foundingYear,
    brandingVersion,
    version,
  ];
}
