/// SaaS-owner-facing support/contact configuration.
///
/// These values are configured-but-not-backend-driven: there is no remote
/// config or CMS in this codebase yet, so they live here as a single,
/// clearly-labeled source instead of being scattered as magic strings across
/// the Contact & About screen.
///
/// Terms of Service is intentionally left without an externally-hosted URL:
/// no such URL exists yet, and unlike the Privacy Policy, no draft was
/// requested, so the row remains omitted from the About screen rather than
/// fabricated.
class SupportContact {
  const SupportContact._();

  static const String companyName = 'School Pulse';

  static const String supportEmail = 'mubangizivic@gmail.com';

  /// Local (Uganda) display format.
  static const String supportPhone = '0793128137';

  /// International format (+256) for `tel:` / `https://wa.me/` URIs.
  static const String supportPhoneInternational = '+256793128137';

  /// Same number as [supportPhone], in the digits-only international format
  /// `wa.me` links require (no leading `+`).
  static const String whatsappNumber = '256793128137';

  static const String websiteUrl = 'https://schoolpulseapp.com/';

  /// No externally-hosted Terms of Service URL exists anywhere in this
  /// codebase - the only "Terms of Service" screen
  /// (`lib/features/profile/presentation/screens/terms_of_service_screen.dart`,
  /// routed at `/staff/more/terms-of-service`) renders local static text for
  /// staff, not a real published URL suitable for url_launcher. No draft was
  /// requested for this row (unlike Privacy Policy), so it stays omitted.
  static const String? termsOfServiceUrl = null;

  /// No externally-hosted Privacy Policy URL exists yet. Instead, a local
  /// in-app placeholder draft is rendered by [PrivacyPolicyScreen]
  /// (`lib/features/super_admin/presentation/pages/privacy_policy_screen.dart`).
  static const String? privacyPolicyUrl = null;
}
