const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const WEBSITE_ORIGIN = "https://schoolpulse.victorbee.com";
const APP_URL = "https://school-pulse-3d95b.web.app";
const ALLOWED_PLANS = ["Starter", "Growth", "Pro", "Enterprise"];
const ALLOWED_MODULES = [
  "Students",
  "Attendance",
  "Academics",
  "Administration",
  "Finance",
  "Boarding",
  "Health",
  "Library",
  "Transport",
  "Messaging",
];
const CORE_MODULES = ["Students", "Attendance", "Academics", "Administration"];

function cors(req, res) {
  const origin = req.get("origin");
  if (origin === WEBSITE_ORIGIN || origin === "http://localhost:4321") {
    res.set("Access-Control-Allow-Origin", origin);
  }
  res.set("Vary", "Origin");
  res.set("Access-Control-Allow-Methods", "GET,POST,OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type,Authorization,X-Firebase-AppCheck");
  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return true;
  }
  return false;
}

function text(value, max = 200) {
  return String(value ?? "").trim().slice(0, max);
}

function normalizePhone(value) {
  const digits = String(value ?? "").replace(/\D/g, "");
  if (/^07\d{8}$/.test(digits)) return `256${digits.slice(1)}`;
  if (/^2567\d{8}$/.test(digits)) return digits;
  return null;
}

function sanitizeModules(value) {
  const requested = Array.isArray(value) ? value : [];
  const modules = new Set(CORE_MODULES);
  for (const module of requested) {
    const cleaned = text(module, 50);
    if (ALLOWED_MODULES.includes(cleaned)) modules.add(cleaned);
  }
  return [...modules];
}

async function rateLimit(req, bucket, limit = 5) {
  const ip = text(req.ip || req.get("x-forwarded-for") || "unknown", 80);
  const hour = new Date().toISOString().slice(0, 13);
  const key = `${bucket}_${Buffer.from(ip).toString("hex").slice(0, 80)}_${hour}`;
  const ref = db.collection("_public_rate_limits").doc(key);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const count = snap.exists ? Number(snap.data()?.count ?? 0) : 0;
    if (count >= limit) return false;
    tx.set(ref, {
      count: count + 1,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    return true;
  });
}

async function verifiedIdentity(req) {
  const header = text(req.get("authorization"), 5000);
  if (!header.startsWith("Bearer ")) return null;
  try {
    const decoded = await admin.auth().verifyIdToken(header.slice(7));
    if (!decoded.uid || !decoded.email || !decoded.email_verified) return null;
    return decoded;
  } catch (_) {
    return null;
  }
}

exports.submitSchoolApplication = onRequest({ region: "europe-west1" }, async (req, res) => {
  if (cors(req, res)) return;
  if (req.method !== "POST") {
    res.status(405).json({ error: "method_not_allowed" });
    return;
  }
  if (!(await rateLimit(req, "school_application", 5))) {
    res.status(429).json({ error: "too_many_requests", message: "Too many registration attempts. Please try again later." });
    return;
  }

  const identity = await verifiedIdentity(req);
  if (!identity) {
    res.status(401).json({ error: "verified_auth_required", message: "A verified School Pulse email account is required." });
    return;
  }

  const school = req.body?.school ?? {};
  const location = req.body?.location ?? {};
  const administrator = req.body?.administrator ?? {};
  const plan = text(req.body?.plan, 40);
  const selectedModules = sanitizeModules(req.body?.selectedModules);

  const schoolName = text(school.name, 160);
  const schoolEmail = text(school.email, 160).toLowerCase();
  const schoolPhone = normalizePhone(school.phone);
  const prefix = text(school.prefix, 12).toUpperCase().replace(/[^A-Z0-9]/g, "");
  const adminEmail = text(administrator.email, 160).toLowerCase();
  const adminPhone = normalizePhone(administrator.phone);

  if (
    !schoolName ||
    !schoolEmail ||
    !schoolPhone ||
    !prefix ||
    !text(school.category, 80) ||
    !text(location.region, 40) ||
    !text(location.district, 100) ||
    !text(location.address, 240) ||
    !text(administrator.firstName, 100) ||
    !text(administrator.lastName, 100) ||
    !adminPhone ||
    adminEmail !== String(identity.email).toLowerCase() ||
    !ALLOWED_PLANS.includes(plan) ||
    req.body?.termsAccepted !== true
  ) {
    res.status(400).json({ error: "invalid_application", message: "Required registration information is missing or invalid." });
    return;
  }

  const ref = db.collection("public_school_applications").doc(identity.uid);
  const existing = await ref.get();
  const existingStatus = String(existing.data()?.status ?? "");
  if (existing.exists && ["approved", "pending_review"].includes(existingStatus)) {
    res.status(409).json({ error: "application_exists", message: "A school application already exists for this account." });
    return;
  }

  const prefixMatch = await db.collection("public_school_applications")
    .where("school.prefix", "==", prefix)
    .limit(1)
    .get();
  if (!prefixMatch.empty && prefixMatch.docs[0].id !== identity.uid) {
    res.status(409).json({ error: "prefix_in_use", message: "That school prefix is already in use. Choose another." });
    return;
  }

  const now = admin.firestore.FieldValue.serverTimestamp();
  await ref.set({
    id: identity.uid,
    authUid: identity.uid,
    status: "pending_review",
    source: "public_website",
    plan,
    selectedModules,
    school: {
      name: schoolName,
      shortName: text(school.shortName, 40),
      email: schoolEmail,
      phone: schoolPhone,
      category: text(school.category, 80),
      poBox: text(school.poBox, 80),
      prefix,
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
      phone: adminPhone,
      email: adminEmail,
      username: text(administrator.username, 120),
      emailVerified: true,
    },
    marketingOptIn: req.body?.marketingOptIn === true,
    termsAccepted: true,
    termsAcceptedAt: now,
    createdAt: existing.exists ? (existing.data()?.createdAt ?? now) : now,
    updatedAt: now,
    reviewedAt: null,
    reviewedBy: null,
  }, { merge: true });

  res.status(201).json({
    ok: true,
    applicationId: identity.uid,
    status: "pending_review",
    schoolName,
  });
});

exports.getSchoolApplicationStatus = onRequest({ region: "europe-west1" }, async (req, res) => {
  if (cors(req, res)) return;
  if (!["GET", "POST"].includes(req.method)) {
    res.status(405).json({ error: "method_not_allowed" });
    return;
  }

  const identity = await verifiedIdentity(req);
  if (!identity) {
    res.status(401).json({ error: "verified_auth_required" });
    return;
  }

  const ref = db.collection("public_school_applications").doc(identity.uid);
  const snap = await ref.get();
  if (!snap.exists) {
    res.status(404).json({ error: "application_not_found" });
    return;
  }

  const data = snap.data();
  await ref.set({ lastStatusCheckAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  res.status(200).json({
    status: text(data.status, 40),
    schoolName: text(data.school?.name, 160),
    plan: text(data.plan, 40),
    appReady: data.appReady === true,
    appUrl: text(data.appUrl, 300) || APP_URL,
    rejectionReason: text(data.rejectionReason, 500),
  });
});
