const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const WEBSITE_ORIGIN = 'https://schoolpulseapp.com';
const NOMINATIM_BASE = 'https://nominatim.openstreetmap.org';
const USER_AGENT = 'SchoolPulse-Registration/1.0 (contact: support@schoolpulse.victorbee.com)';
const CACHE_COLLECTION = '_public_geocode_cache';
const CACHE_TTL_MS = 30 * 24 * 60 * 60 * 1000; // 30 days — Uganda place names don't move.
const UGANDA_REGION_BY_DISTRICT = require('./uganda_regions.json');

// Nominatim sometimes reports a municipality/town as its own admin boundary
// (e.g. "Kira City", "Entebbe City") even though it sits inside a larger
// district for School Pulse's purposes. Map those town names to the parent
// district before the region lookup.
const DISTRICT_ALIASES = {
  kira: 'Wakiso',
  entebbe: 'Wakiso',
  nansana: 'Wakiso',
  makindye: 'Kampala',
  nakawa: 'Kampala',
  rubaga: 'Kampala',
  kawempe: 'Kampala',
  kololo: 'Kampala',
  ntinda: 'Kampala',
  'fort portal': 'Kabarole',
};

function cors(req, res, methods = 'GET,OPTIONS') {
  const origin = req.get('origin');
  if (origin === WEBSITE_ORIGIN || origin === 'http://localhost:4321') {
    res.set('Access-Control-Allow-Origin', origin);
  }
  res.set('Vary', 'Origin');
  res.set('Access-Control-Allow-Methods', methods);
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

async function rateLimit(req, bucket, limit) {
  const ip = text(req.ip || req.get('x-forwarded-for') || 'unknown', 80);
  const hour = new Date().toISOString().slice(0, 13);
  const key = `${bucket}_${Buffer.from(ip).toString('hex').slice(0, 80)}_${hour}`;
  const ref = db.collection('_public_rate_limits').doc(key);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const count = snap.exists ? Number(snap.data()?.count ?? 0) : 0;
    if (count >= limit) return false;
    tx.set(ref, { count: count + 1, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    return true;
  });
}

function regionForDistrict(district) {
  if (!district) return '';
  const key = district.trim().toLowerCase();
  return UGANDA_REGION_BY_DISTRICT[key] || '';
}

// Nominatim's Uganda address payload doesn't have a single stable "district"
// key across place types (city/town/village/county all show up differently),
// so pick the first present in priority order.
function extractDistrict(address) {
  const raw = text(
    address.county ||
      address.state_district ||
      address.district ||
      address.city ||
      address.town ||
      address.state ||
      '',
    100,
  );
  // Nominatim names Uganda's city-tier admin boundaries "X City" or
  // "X Capital City" (Kampala, Mbarara, Gulu, ...) instead of "X District",
  // and bare district-boundary results carry the name only in `state`.
  const cleaned = raw.replace(/\s+(Capital\s+)?City$/i, '').replace(/\s+District$/i, '');
  const alias = DISTRICT_ALIASES[cleaned.toLowerCase()];
  return alias || cleaned;
}

function extractArea(address, fallbackName) {
  return text(
    address.suburb ||
      address.neighbourhood ||
      address.village ||
      address.town ||
      address.city_district ||
      address.city ||
      fallbackName ||
      '',
    140,
  );
}

function normalizeNominatimResult(raw) {
  const address = raw.address || {};
  const countryCode = text(address.country_code, 5).toLowerCase();
  if (countryCode !== 'ug') return null;

  const district = extractDistrict(address);
  const area = extractArea(address, raw.display_name?.split(',')[0]);
  const region = regionForDistrict(district);
  const lat = Number(raw.lat);
  const lon = Number(raw.lon);
  if (!area || !Number.isFinite(lat) || !Number.isFinite(lon)) return null;

  const fullAddress = text(raw.display_name, 240);

  return {
    placeId: text(raw.place_id, 60),
    locationName: area,
    formattedAddress: fullAddress,
    address: fullAddress,
    area,
    town: text(address.town || address.city || '', 140),
    city: text(address.city || '', 140),
    district: district || 'Uganda',
    region: region || 'Uganda',
    country: 'Uganda',
    countryCode: 'UG',
    latitude: lat,
    longitude: lon,
  };
}

async function fetchNominatim(path, params) {
  const url = new URL(`${NOMINATIM_BASE}${path}`);
  Object.entries(params).forEach(([k, v]) => url.searchParams.set(k, v));
  const response = await fetch(url, { headers: { 'User-Agent': USER_AGENT, Accept: 'application/json' } });
  if (!response.ok) throw new Error(`nominatim_${response.status}`);
  return response.json();
}

async function cacheGet(key) {
  const ref = db.collection(CACHE_COLLECTION).doc(key);
  const snap = await ref.get();
  if (!snap.exists) return null;
  const data = snap.data();
  const cachedAt = data?.cachedAt?.toMillis ? data.cachedAt.toMillis() : 0;
  if (Date.now() - cachedAt > CACHE_TTL_MS) return null;
  return data.results;
}

async function cacheSet(key, results) {
  await db.collection(CACHE_COLLECTION).doc(key).set(
    { results, cachedAt: admin.firestore.FieldValue.serverTimestamp() },
    { merge: true },
  );
}

function cacheKey(prefix, raw) {
  return `${prefix}_${Buffer.from(raw.toLowerCase().trim()).toString('hex').slice(0, 120)}`;
}

exports.searchUgandaLocations = onRequest({ region: 'europe-west1' }, async (req, res) => {
  if (cors(req, res)) return;
  if (req.method !== 'GET') { res.status(405).json({ error: 'method_not_allowed' }); return; }

  const query = text(req.query.q, 140);
  if (query.length < 2) { res.status(200).json({ results: [] }); return; }

  if (!(await rateLimit(req, 'geocode_search', 60))) {
    res.status(429).json({ error: 'too_many_requests', message: 'Too many location searches. Please slow down.' });
    return;
  }

  const key = cacheKey('search', query);
  try {
    const cached = await cacheGet(key);
    if (cached) { res.status(200).json({ results: cached, cached: true }); return; }

    const raw = await fetchNominatim('/search', {
      q: query,
      countrycodes: 'ug',
      format: 'jsonv2',
      addressdetails: '1',
      limit: '10',
    });

    const seen = new Set();
    const results = [];
    for (const item of Array.isArray(raw) ? raw : []) {
      const normalized = normalizeNominatimResult(item);
      if (!normalized) continue;
      const dedupeKey = `${normalized.locationName}|${normalized.district}`.toLowerCase();
      if (seen.has(dedupeKey)) continue;
      seen.add(dedupeKey);
      results.push(normalized);
      if (results.length >= 7) break;
    }

    await cacheSet(key, results);
    res.status(200).json({ results });
  } catch (error) {
    console.error('searchUgandaLocations failed', error);
    res.status(502).json({ error: 'geocode_unavailable', message: 'Location search is temporarily unavailable.' });
  }
});

exports.reverseGeocodeUgandaLocation = onRequest({ region: 'europe-west1' }, async (req, res) => {
  if (cors(req, res)) return;
  if (req.method !== 'GET') { res.status(405).json({ error: 'method_not_allowed' }); return; }

  const lat = Number(req.query.lat);
  const lon = Number(req.query.lon);
  if (!Number.isFinite(lat) || !Number.isFinite(lon) || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
    res.status(400).json({ error: 'invalid_coordinates' });
    return;
  }

  if (!(await rateLimit(req, 'geocode_reverse', 20))) {
    res.status(429).json({ error: 'too_many_requests', message: 'Too many location lookups. Please slow down.' });
    return;
  }

  const key = cacheKey('reverse', `${lat.toFixed(4)},${lon.toFixed(4)}`);
  try {
    const cached = await cacheGet(key);
    if (cached) { res.status(200).json({ result: cached[0] || null, cached: true }); return; }

    const raw = await fetchNominatim('/reverse', {
      lat: String(lat),
      lon: String(lon),
      format: 'jsonv2',
      addressdetails: '1',
      zoom: '16',
    });

    const normalized = raw && !raw.error ? normalizeNominatimResult(raw) : null;
    if (!normalized) {
      res.status(200).json({
        result: null,
        message: 'We could not confirm this location is in Uganda. Search manually instead.',
      });
      return;
    }

    await cacheSet(key, [normalized]);
    res.status(200).json({ result: normalized });
  } catch (error) {
    console.error('reverseGeocodeUgandaLocation failed', error);
    res.status(502).json({ error: 'geocode_unavailable', message: 'Current location lookup is temporarily unavailable.' });
  }
});

exports.__test__ = { normalizeNominatimResult };
