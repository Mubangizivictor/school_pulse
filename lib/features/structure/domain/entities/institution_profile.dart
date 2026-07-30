import 'package:equatable/equatable.dart';

/// The full institutional identity/profile for the school - a singleton
/// document (like FeatureToggles), not a list. Deliberately overlaps some
/// fields already on admin's SystemConfig (name, motto, logo, colors) -
/// this is Structure's own richer copy per spec; SystemConfig is untouched.
class InstitutionProfile extends Equatable {
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
  final String email;
  final String website;
  final Map<String, String> socialMedia;
  final String timeZone;
  final String currency;
  final String language;
  final String dateFormat;
  final String timeFormat;

  const InstitutionProfile({
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
    this.email = '',
    this.website = '',
    this.socialMedia = const {},
    this.timeZone = '',
    this.currency = '',
    this.language = '',
    this.dateFormat = '',
    this.timeFormat = '',
  });

  InstitutionProfile copyWith({
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
    String? email,
    String? website,
    Map<String, String>? socialMedia,
    String? timeZone,
    String? currency,
    String? language,
    String? dateFormat,
    String? timeFormat,
  }) {
    return InstitutionProfile(
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
      ministryRegistrationNumber: ministryRegistrationNumber ?? this.ministryRegistrationNumber,
      taxNumber: taxNumber ?? this.taxNumber,
      country: country ?? this.country,
      district: district ?? this.district,
      city: city ?? this.city,
      address: address ?? this.address,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLng: gpsLng ?? this.gpsLng,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      socialMedia: socialMedia ?? this.socialMedia,
      timeZone: timeZone ?? this.timeZone,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
    );
  }

  @override
  List<Object?> get props => [
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
        email,
        website,
        socialMedia,
        timeZone,
        currency,
        language,
        dateFormat,
        timeFormat,
      ];
}
