const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { isAllowedOrigin } = require('./allowed_origins');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const WEBSITE_ORIGIN = 'https://schoolpulseapp.com';
const CORE_MODULES = ['Students', 'Attendance', 'Academics', 'Administration'];
const ALLOWED_MODULES = new Set([
  ...CORE_MODULES,
  'Finance',
  'Boarding',
  'Health',
  'Library',
  'Transport',
  'Messaging',
]);
const ALLOWED_PLANS = new Set(['Starter', 'Growth', 'Pro', 'Enterprise']);

function cors(req, res) {
  const origin = req.get('origin');
  if (isAllowedOrigin(origin)) {
    res.set('Access-Control-Allow-Origin', origin);
  }
  res.set('Vary', 'Origin');
  res.set('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type,Authorization');
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return true;
  }
  return false;
}

function text(value, max = 200) {
  return String(value ?? '').trim().slice(0, max);
}

async function identity(req) {
  const header = text(req.get('authorization'), 5000);
  if (!header.startsWith('Bearer ')) return null;
  try {
    return await admin.auth().verifyIdToken(header.slice(7));
  } catch (_) {
    return null;
  }
}

function selectedModules(value) {
  const modules = new Set(CORE_MODULES);
  if (Array.isArray(value)) {
    for (const item of value) {
      const module = text(item, 50);
      if (ALLOWED_MODULES.has(module)) modules.add(module);
    }
  }
  return [...modules];
}

exports.saveSchoolRegistrationDraft = onRequest(
  { region: 'europe-west1' },
  async (req, res) => {
    if (cors(req, res)) return;
    if (req.method !== 'POST') {
      res.status(405).json({ error: 'method_not_allowed' });
      return;
    }

    const user = await identity(req);
    if (!user?.uid || !user?.email) {
      res.status(401).json({ error: 'auth_required' });
      return;
    }

    const school = req.body?.school || {};
    const location = req.body?.location || {};
    const administrator = req.body?.administrator || {};
    const requestedPlan = text(req.body?.plan, 40);
    const plan = ALLOWED_PLANS.has(requestedPlan) ? requestedPlan : 'Starter';
    const modules = selectedModules(req.body?.selectedModules);
    const ref = db.collection('public_school_applications').doc(user.uid);
    const existing = await ref.get();
    const existingData = existing.data() || {};
    const protectedStatuses = new Set(['pending_review', 'approved', 'rejected']);
    const draftStatus = user.email_verified
      ? 'email_verified'
      : 'email_verification_pending';
    const status = protectedStatuses.has(existingData.status)
      ? existingData.status
      : draftStatus;
    const serverTime = admin.firestore.FieldValue.serverTimestamp();

    const data = {
      id: user.uid,
      authUid: user.uid,
      status,
      source: 'public_website',
      plan,
      selectedModules: modules,
      school: {
        name: text(school.name, 160),
        shortName: text(school.shortName, 40),
        email: text(school.email, 160).toLowerCase(),
        phone: text(school.phone, 30),
        category: text(school.category, 80),
        poBox: text(school.poBox, 80),
        prefix: text(school.prefix, 12)
          .toUpperCase()
          .replace(/[^A-Z0-9]/g, ''),
        motto: text(school.motto, 180),
      },
      location: {
        region: text(location.region, 40),
        district: text(location.district, 100),
        address: text(location.address, 240),
        website: text(location.website, 240),
        locationName: text(location.locationName, 140),
        latitude: text(location.latitude, 40),
        longitude: text(location.longitude, 40),
      },
      administrator: {
        firstName: text(administrator.firstName, 100),
        lastName: text(administrator.lastName, 100),
        gender: text(administrator.gender, 40),
        phone: text(administrator.phone, 30),
        email: text(administrator.email, 160).toLowerCase(),
        username: text(administrator.username, 120),
        emailVerified: Boolean(user.email_verified),
      },
      updatedAt: serverTime,
    };

    if (!existing.exists) data.createdAt = serverTime;
    await ref.set(data, { merge: true });

    res.status(200).json({ ok: true, status });
  },
);
