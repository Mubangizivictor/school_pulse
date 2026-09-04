/// Static reference data mirrored from the marketing site's registration
/// wizard: web_marketing/js/pricing-config.js (pricing tiers) and
/// web_marketing/js/register-submit.js (districts-by-region, tier-to-plan
/// map). Intentionally static, not read live from Firestore — see the
/// comment atop pricing-config.js for why.
library;

class PricingTier {
  final int min;
  final int? max;
  final int? price;
  final String label;

  const PricingTier({
    required this.min,
    required this.max,
    required this.price,
    required this.label,
  });
}

const List<PricingTier> kPricingTiers = [
  PricingTier(min: 1, max: 300, price: 350000, label: 'Starter'),
  PricingTier(min: 301, max: 500, price: 450000, label: 'Growth'),
  PricingTier(min: 501, max: 800, price: 600000, label: 'Standard'),
  PricingTier(min: 801, max: 1200, price: 800000, label: 'Enterprise'),
  PricingTier(min: 1201, max: null, price: null, label: 'Custom'),
];

PricingTier tierForCount(int count) {
  for (final t in kPricingTiers) {
    if (count >= t.min && (t.max == null || count <= t.max!)) return t;
  }
  return kPricingTiers.last;
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

/// Marketing tier label -> backend `plan` enum value. "Custom" has no
/// backend plan (no fixed price) and must be blocked before submit.
const Map<String, String> kTierLabelToPlan = {
  'Starter': 'Starter',
  'Growth': 'Growth',
  'Standard': 'Pro',
  'Enterprise': 'Enterprise',
};

const Map<String, List<String>> kDistrictsByRegion = {
  'Central': [
    'Buikwe', 'Bukomansimbi', 'Butambala', 'Buvuma', 'Gomba', 'Kalangala',
    'Kalungu', 'Kampala', 'Kayunga', 'Kiboga', 'Kyankwanzi', 'Kyotera',
    'Luwero', 'Lyantonde', 'Masaka', 'Mityana', 'Mpigi', 'Mubende',
    'Mukono', 'Nakaseke', 'Nakasongola', 'Rakai', 'Sembabule', 'Wakiso',
  ],
  'Eastern': [
    'Amuria', 'Budaka', 'Bududa', 'Bugiri', 'Bukwo', 'Bulambuli', 'Busia',
    'Butaleja', 'Buyende', 'Iganga', 'Jinja', 'Kaberamaido', 'Kalaki',
    'Kaliro', 'Kamuli', 'Kapchorwa', 'Katakwi', 'Kibuku', 'Kween', 'Luuka',
    'Manafwa', 'Mayuge', 'Mbale', 'Namayingo', 'Namisindwa', 'Namutumba',
    'Ngora', 'Pallisa', 'Serere', 'Sironko', 'Soroti', 'Tororo',
  ],
  'Northern': [
    'Abim', 'Adjumani', 'Agago', 'Alebtong', 'Amolatar', 'Amudat', 'Amuru',
    'Apac', 'Arua', 'Dokolo', 'Gulu', 'Kaabong', 'Kitgum', 'Koboko', 'Kole',
    'Kotido', 'Lamwo', 'Lira', 'Madi-Okollo', 'Maracha', 'Moroto', 'Moyo',
    'Nakapiripirit', 'Napak', 'Nebbi', 'Nwoya', 'Obongi', 'Omoro', 'Otuke',
    'Oyam', 'Pader', 'Pakwach', 'Terego', 'Yumbe', 'Zombo',
  ],
  'Western': [
    'Buhweju', 'Buliisa', 'Bundibugyo', 'Bunyangabu', 'Bushenyi',
    'Fort Portal', 'Hoima', 'Ibanda', 'Isingiro', 'Kabale', 'Kabarole',
    'Kagadi', 'Kakumiro', 'Kamwenge', 'Kanungu', 'Kasese', 'Kibaale',
    'Kikuube', 'Kiruhura', 'Kisoro', 'Kyegegwa', 'Kyenjojo', 'Masindi',
    'Mbarara', 'Mitooma', 'Ntoroko', 'Ntungamo', 'Rubirizi', 'Rukiga',
    'Rukungiri', 'Rwampara', 'Sheema',
  ],
};

const List<String> kSchoolTypes = [
  'Nursery',
  'Primary',
  'Secondary',
  'International',
];
