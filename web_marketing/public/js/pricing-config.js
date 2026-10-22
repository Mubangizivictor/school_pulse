// Termly pricing tiers for School Pulse — single source of truth for the
// marketing site's displayed pricing (homepage, /pricing, /register-school).
//
// Prices match the backend plan defaults in public_functions/payments.js
// and billing_public.js (Starter 350k / Growth 550k / Pro 800k per term;
// Enterprise is a custom quote). Decided 2026-10-22, see ROADMAP.md Step A1.
// `plan` is the backend plan enum the register wizard submits; Enterprise has
// none because it has no fixed price and can't be self-serve submitted.
//
// Intentionally static, not read live from Firestore: `student_pricing_bands`
// (functions/student_pricing_bands.js) is a *different* feature that prices
// already-active schools' termly renewal by verified enrollment, and it is
// currently unseeded (0 active bands) — reading it here renders an
// empty/broken pricing page. Do not switch this back to a live Firestore
// read without first seeding real bands and re-confirming that registration
// and renewal pricing are meant to share one price list.
window.PRICING_TIERS = [
  {
    min: 1, max: 300, price: 350000, label: 'Starter', plan: 'Starter',
    support: 'WhatsApp, normal hours',
    includes: ['Setup wizard', 'Students and staff', 'Parents app', 'Attendance', 'Announcements', 'Timetable'],
  },
  {
    min: 301, max: 700, price: 550000, label: 'Growth', plan: 'Growth',
    support: 'WhatsApp, priority',
    includes: ['Everything in Starter', 'Fees and Bursar', 'Receipts', 'Mobile money payments', 'Report cards', 'Exams'],
  },
  {
    min: 701, max: 1500, price: 800000, label: 'Pro', plan: 'Pro',
    support: 'Phone + WhatsApp, priority',
    includes: ['Everything in Growth', 'Director and Dean dashboards', 'Analytics', 'NFC/QR student IDs', 'Financial clearance'],
  },
  {
    min: 1501, max: null, price: null, label: 'Enterprise', plan: null,
    support: 'Dedicated contact',
    includes: ['Everything in Pro', 'Multiple campuses', 'Dedicated support person', 'Custom features', 'On-site training'],
  },
];

// The tier marked "Most popular" on the homepage and /pricing.
window.POPULAR_TIER = 'Growth';

// Paying 3 terms upfront gets about this much off.
window.YEARLY_DISCOUNT = 0.10;

// Free trial: all Pro features, no payment needed.
window.TRIAL_DAYS = 30;

// Return the tier object matching a given learner count.
window.getTierForCount = function (count) {
  var n = Number(count) || 0;
  var tiers = window.PRICING_TIERS;
  for (var i = 0; i < tiers.length; i++) {
    var t = tiers[i];
    if (n >= t.min && (t.max === null || n <= t.max)) return t;
  }
  return tiers[tiers.length - 1];
};

// Yearly price (3 terms, discounted), rounded to the nearest 5,000 UGX.
window.yearlyPrice = function (tier) {
  if (!tier || tier.price === null) return null;
  return Math.round((tier.price * 3 * (1 - window.YEARLY_DISCOUNT)) / 5000) * 5000;
};

// Format a UGX number like "UGX 350,000".
window.formatUGX = function (amount) {
  if (amount === null || amount === undefined) return "Talk to us";
  return "UGX " + Number(amount).toLocaleString("en-UG");
};
