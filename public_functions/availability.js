const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();
const WEBSITE_ORIGIN = 'https://schoolpulseapp.com';
const ACTIVE_APPLICATION_STATUSES = new Set(['pending_review', 'approved']);

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

function clean(value, max = 180) {
  return String(value ?? '').trim().slice(0, max);
}

function normalizePhone(value) {
  const digits = clean(value, 40).replace(/\D/g, '');
  if (/^07\d{8}$/.test(digits)) return `256${digits.slice(1)}`;
  if (/^2567\d{8}$/.test(digits)) return digits;
  return null;
}

async function hasActiveMatch(field, value) {
  const snap = await db.collection('public_school_applications').where(field, '==', value).limit(8).get();
  return snap.docs.some((doc) => ACTIVE_APPLICATION_STATUSES.has(String(doc.data()?.status || '')));
}

exports.checkRegistrationAvailability = onRequest(
  { region: 'europe-west1' },
  async (req, res) => {
    if (cors(req, res)) return;
    if (req.method !== 'GET') {
      res.status(405).json({ error: 'method_not_allowed' });
      return;
    }

    const kind = clean(req.query.kind, 30).toLowerCase();
    const raw = clean(req.query.value, 180);
    if (!raw) {
      res.status(400).json({ error: 'missing_value', available: false, message: 'Enter a value first.' });
      return;
    }

    try {
      if (kind === 'phone') {
        const phone = normalizePhone(raw);
        if (!phone) {
          res.status(200).json({ available: false, message: 'Enter a valid Uganda mobile number.' });
          return;
        }
        const [schoolUsed, adminUsed] = await Promise.all([
          hasActiveMatch('school.phone', phone),
          hasActiveMatch('administrator.phone', phone),
        ]);
        const available = !(schoolUsed || adminUsed);
        res.status(200).json({ available, message: available ? 'Number is available.' : 'This phone number is already linked to another School Pulse school application.' });
        return;
      }

      if (kind === 'prefix') {
        const prefix = raw.toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 12);
        if (prefix.length < 2) {
          res.status(200).json({ available: false, message: 'Use at least 2 letters or numbers.' });
          return;
        }
        const used = await hasActiveMatch('school.prefix', prefix);
        res.status(200).json({ available: !used, message: used ? 'These school initials are already in use.' : 'School initials are available.' });
        return;
      }

      if (kind === 'email') {
        const email = raw.toLowerCase();
        const [schoolUsed, adminUsed] = await Promise.all([
          hasActiveMatch('school.email', email),
          hasActiveMatch('administrator.email', email),
        ]);
        const available = !(schoolUsed || adminUsed);
        res.status(200).json({ available, message: available ? 'Email is available.' : 'This email is already linked to another School Pulse school application.' });
        return;
      }

      res.status(400).json({ error: 'unsupported_kind', available: false, message: 'Unsupported availability check.' });
    } catch (error) {
      console.error('checkRegistrationAvailability failed', error);
      res.status(500).json({ error: 'availability_check_failed', available: false, message: 'Could not verify this value right now.' });
    }
  },
);
