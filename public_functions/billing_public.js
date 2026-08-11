const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const WEBSITE_ORIGIN = 'https://schoolpulse.victorbee.com';
const PLAN_ORDER = ['starter', 'growth', 'pro', 'enterprise'];
const FALLBACKS = {
  starter: { name: 'Starter', price: 350000, billingCycle: 'termly' },
  growth: { name: 'Growth', price: 550000, billingCycle: 'termly' },
  pro: { name: 'Pro', price: 800000, billingCycle: 'termly' },
  enterprise: { name: 'Enterprise', price: 0, billingCycle: 'termly', customPricing: true },
};

function cors(req, res) {
  const origin = req.get('origin');
  if (origin === WEBSITE_ORIGIN || origin === 'http://localhost:4321') {
    res.set('Access-Control-Allow-Origin', origin);
  }
  res.set('Vary', 'Origin');
  res.set('Access-Control-Allow-Methods', 'GET,OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return true;
  }
  return false;
}

function clean(value, max = 160) {
  return String(value ?? '').trim().slice(0, max);
}

exports.getPublicSubscriptionPlans = onRequest(
  { region: 'europe-west1' },
  async (req, res) => {
    if (cors(req, res)) return;
    if (req.method !== 'GET') {
      res.status(405).json({ error: 'method_not_allowed' });
      return;
    }

    const snapshot = await db.collection('subscription_plans').get();
    const byId = new Map(snapshot.docs.map((doc) => [doc.id.toLowerCase(), { id: doc.id, ...(doc.data() || {}) }]));

    const plans = PLAN_ORDER.map((id) => {
      const stored = byId.get(id) || {};
      const fallback = FALLBACKS[id];
      const maxStudents = Math.max(0, Number(stored.maxStudents || 0));
      const maxStaff = Math.max(0, Number(stored.maxStaff || 0));
      const price = Math.max(0, Math.round(Number(stored.price ?? fallback.price ?? 0)));
      return {
        id,
        name: clean(stored.name || fallback.name, 60),
        description: clean(stored.description || `${fallback.name} School Pulse plan`, 220),
        price,
        currency: 'UGX',
        billingCycle: clean(stored.billingCycle || fallback.billingCycle || 'termly', 30),
        termLengthDays: Math.max(1, Number(stored.termLengthDays || 120)),
        customPricing: stored.customPricing === true || fallback.customPricing === true,
        maxStudents,
        maxStaff,
        includedFeatures: Array.isArray(stored.includedFeatures)
          ? stored.includedFeatures.map((item) => clean(item, 80)).filter(Boolean).slice(0, 12)
          : [],
        isDefault: stored.isDefault === true,
        isPopular: stored.isPopular === true,
        isPublic: stored.isPublic !== false,
        isActive: stored.isActive !== false,
        displayOrder: Math.round(Number(stored.displayOrder || 0)),
      };
    })
      .filter((plan) => plan.isPublic && plan.isActive)
      .sort((a, b) => a.displayOrder - b.displayOrder)
      .map(({ isPublic, isActive, ...publicFields }) => publicFields);

    res.set('Cache-Control', 'public, max-age=300, s-maxage=300');
    res.status(200).json({ ok: true, plans });
  },
);
