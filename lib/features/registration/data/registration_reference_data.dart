/// Static reference data mirrored from the marketing site's registration
/// wizard: web_marketing/public/js/pricing-config.js (pricing tiers) and
/// web_marketing/public/js/register-submit.js (districts-by-region).
/// Intentionally static, not read live from Firestore — see the comment atop
/// pricing-config.js for why.
library;

class PricingTier {
  final int min;
  final int? max;
  final int? price;
  final String label;

  /// Backend `plan` enum submitted by the wizard. Null for Enterprise, which
  /// has no fixed price and must be blocked before submit.
  final String? plan;
  final List<String> includes;

  const PricingTier({
    required this.min,
    required this.max,
    required this.price,
    required this.label,
    required this.plan,
    required this.includes,
  });
}

// Matches web_marketing/public/js/pricing-config.js and the backend plan
// defaults in public_functions/payments.js (ROADMAP.md Step A1). The price is
// a flat amount per term for the whole school, not per student.
const List<PricingTier> kPricingTiers = [
  PricingTier(
    min: 1,
    max: 300,
    price: 350000,
    label: 'Starter',
    plan: 'Starter',
    includes: [
      'Setup wizard',
      'Students and staff',
      'Parents app',
      'Attendance',
      'Announcements',
      'Timetable',
    ],
  ),
  PricingTier(
    min: 301,
    max: 700,
    price: 550000,
    label: 'Growth',
    plan: 'Growth',
    includes: [
      'Everything in Starter',
      'Fees and Bursar',
      'Receipts',
      'Mobile money payments',
      'Report cards',
      'Exams',
    ],
  ),
  PricingTier(
    min: 701,
    max: 1500,
    price: 800000,
    label: 'Pro',
    plan: 'Pro',
    includes: [
      'Everything in Growth',
      'Director and Dean dashboards',
      'Analytics',
      'NFC/QR student IDs',
      'Financial clearance',
    ],
  ),
  PricingTier(
    min: 1501,
    max: null,
    price: null,
    label: 'Enterprise',
    plan: null,
    includes: [
      'Everything in Pro',
      'Multiple campuses',
      'Dedicated support person',
      'Custom features',
      'On-site training',
    ],
  ),
];

/// Paying 3 terms upfront gets about this much off.
const double kYearlyDiscount = 0.10;

/// Free trial: all Pro features, no payment needed.
const int kTrialDays = 30;

PricingTier tierForCount(int count) {
  for (final t in kPricingTiers) {
    if (count >= t.min && (t.max == null || count <= t.max!)) return t;
  }
  return kPricingTiers.last;
}

/// Yearly price (3 terms, discounted), rounded to the nearest 5,000 UGX.
int? yearlyPrice(PricingTier tier) {
  final price = tier.price;
  if (price == null) return null;
  return ((price * 3 * (1 - kYearlyDiscount)) / 5000).round() * 5000;
}

String formatUgx(int? amount) {
  if (amount == null) return 'Talk to us';
  final s = amount.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return 'UGX $buf';
}

const Map<String, List<String>> kDistrictsByRegion = {
  'Central': [
    'Buikwe',
    'Bukomansimbi',
    'Butambala',
    'Buvuma',
    'Gomba',
    'Kalangala',
    'Kalungu',
    'Kampala',
    'Kayunga',
    'Kiboga',
    'Kyankwanzi',
    'Kyotera',
    'Luwero',
    'Lyantonde',
    'Masaka',
    'Mityana',
    'Mpigi',
    'Mubende',
    'Mukono',
    'Nakaseke',
    'Nakasongola',
    'Rakai',
    'Sembabule',
    'Wakiso',
  ],
  'Eastern': [
    'Amuria',
    'Budaka',
    'Bududa',
    'Bugiri',
    'Bukwo',
    'Bulambuli',
    'Busia',
    'Butaleja',
    'Buyende',
    'Iganga',
    'Jinja',
    'Kaberamaido',
    'Kalaki',
    'Kaliro',
    'Kamuli',
    'Kapchorwa',
    'Katakwi',
    'Kibuku',
    'Kween',
    'Luuka',
    'Manafwa',
    'Mayuge',
    'Mbale',
    'Namayingo',
    'Namisindwa',
    'Namutumba',
    'Ngora',
    'Pallisa',
    'Serere',
    'Sironko',
    'Soroti',
    'Tororo',
  ],
  'Northern': [
    'Abim',
    'Adjumani',
    'Agago',
    'Alebtong',
    'Amolatar',
    'Amudat',
    'Amuru',
    'Apac',
    'Arua',
    'Dokolo',
    'Gulu',
    'Kaabong',
    'Kitgum',
    'Koboko',
    'Kole',
    'Kotido',
    'Lamwo',
    'Lira',
    'Madi-Okollo',
    'Maracha',
    'Moroto',
    'Moyo',
    'Nakapiripirit',
    'Napak',
    'Nebbi',
    'Nwoya',
    'Obongi',
    'Omoro',
    'Otuke',
    'Oyam',
    'Pader',
    'Pakwach',
    'Terego',
    'Yumbe',
    'Zombo',
  ],
  'Western': [
    'Buhweju',
    'Buliisa',
    'Bundibugyo',
    'Bunyangabu',
    'Bushenyi',
    'Fort Portal',
    'Hoima',
    'Ibanda',
    'Isingiro',
    'Kabale',
    'Kabarole',
    'Kagadi',
    'Kakumiro',
    'Kamwenge',
    'Kanungu',
    'Kasese',
    'Kibaale',
    'Kikuube',
    'Kiruhura',
    'Kisoro',
    'Kyegegwa',
    'Kyenjojo',
    'Masindi',
    'Mbarara',
    'Mitooma',
    'Ntoroko',
    'Ntungamo',
    'Rubirizi',
    'Rukiga',
    'Rukungiri',
    'Rwampara',
    'Sheema',
  ],
};

const List<String> kSchoolTypes = [
  'Nursery',
  'Primary',
  'Secondary',
  'International',
];
