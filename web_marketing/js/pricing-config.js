// Termly pricing tiers for School Pulse — single source of truth for the
// marketing site's displayed pricing (homepage, /pricing, /register-school).
//
// Intentionally static, not read live from Firestore: `student_pricing_bands`
// (functions/student_pricing_bands.js) is a *different* feature that prices
// already-active schools' termly renewal by verified enrollment, and it is
// currently unseeded (0 active bands) — reading it here renders an
// empty/broken pricing page. Do not switch this back to a live Firestore
// read without first seeding real bands and re-confirming that registration
// and renewal pricing are meant to share one price list.
window.PRICING_TIERS = [
  { min: 1, max: 300, price: 350000, label: 'Starter' },
  { min: 301, max: 500, price: 450000, label: 'Growth' },
  { min: 501, max: 800, price: 600000, label: 'Standard' },
  { min: 801, max: 1200, price: 800000, label: 'Enterprise' },
  { min: 1201, max: null, price: null, label: 'Custom' },
];

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

// Format a UGX number like "UGX 350,000".
window.formatUGX = function (amount) {
  if (amount === null || amount === undefined) return "Talk to us";
  return "UGX " + Number(amount).toLocaleString("en-UG");
};
