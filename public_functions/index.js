const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const WEBSITE_ORIGIN = "https://schoolpulseapp.com";
const APP_URL = `${WEBSITE_ORIGIN}/application-status`;
const ALLOWED_PLANS = ["Starter", "Growth", "Pro", "Enterprise"];
const ALLOWED_MODULES = ["Students","Attendance","Academics","Administration","Finance","Boarding","Health","Library","Transport","Messaging"];
const CORE_MODULES = ["Students", "Attendance", "Academics", "Administration"];
const RESERVED_STATUSES = new Set(["pending_review", "approved"]);

function cors(req, res) {
  const origin = req.get("origin");
  if (origin === WEBSITE_ORIGIN || origin === "http://localhost:4321") res.set("Access-Control-Allow-Origin", origin);
  res.set("Vary", "Origin");
  res.set("Access-Control-Allow-Methods", "GET,POST,OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type,Authorization,X-Firebase-AppCheck");
  if (req.method === "OPTIONS") { res.status(204).send(""); return true; }
  return false;
}

function text(value, max = 200) { return String(value ?? "").trim().slice(0, max); }
function normalizePhone(value) {
  const digits = String(value ?? "").replace(/\D/g, "");
  if (/^07\d{8}$/.test(digits)) return `256${digits.slice(1)}`;
  if (/^2567\d{8}$/.test(digits)) return digits;
  return null;
}
function sanitizeModules(value) {
  const requested = Array.isArray(value) ? value : [];
  const modules = new Set(CORE_MODULES);
  for (const module of requested) { const cleaned = text(module, 50); if (ALLOWED_MODULES.includes(cleaned)) modules.add(cleaned); }
  return [...modules];
}
async function rateLimit(req, bucket, limit = 5) {
  const ip = text(req.ip || req.get("x-forwarded-for") || "unknown", 80);
  const hour = new Date().toISOString().slice(0, 13);
  const key = `${bucket}_${Buffer.from(ip).toString("hex").slice(0, 80)}_${hour}`;
  const ref = db.collection("_public_rate_limits").doc(key);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref); const count = snap.exists ? Number(snap.data()?.count ?? 0) : 0;
    if (count >= limit) return false;
    tx.set(ref, { count: count + 1, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    return true;
  });
}
async function verifiedIdentity(req) {
  const header = text(req.get("authorization"), 5000);
  if (!header.startsWith("Bearer ")) return null;
  try { const decoded = await admin.auth().verifyIdToken(header.slice(7)); if (!decoded.uid || !decoded.email || !decoded.email_verified) return null; return decoded; } catch (_) { return null; }
}
async function usedByOtherActiveApplication(field, value, currentUid) {
  if (!value) return false;
  const snap = await db.collection("public_school_applications").where(field, "==", value).limit(10).get();
  return snap.docs.some((doc) => doc.id !== currentUid && RESERVED_STATUSES.has(String(doc.data()?.status || "")));
}

// Recomputed server-side rather than trusted from the client's submitted
// boolean - this flag gates a human review workflow, and a client value
// could be forged to skip that review. "Largest public plan" means the
// biggest maxStudents cap among the currently public/active plans (Pro
// today, but this deliberately doesn't hardcode 'pro' as the plan id).
async function requiresCapacityReview(studentCapacity) {
  if (studentCapacity <= 0) return false;
  const snapshot = await db.collection("subscription_plans")
    .where("isPublic", "==", true)
    .where("isActive", "==", true)
    .get();
  const caps = snapshot.docs
    .map((doc) => Number(doc.data()?.maxStudents || 0))
    .filter((n) => n > 0);
  if (!caps.length) return false;
  return studentCapacity > Math.max(...caps);
}

// Pure so it can be unit-tested without mocking Firestore/Auth. Field names
// mirror the request body shape (e.g. "location.address") for safe internal
// logging - never expose this list to the client response.
function validateSchoolApplicationFields({ school, location, administrator, plan, termsAccepted, schoolName, schoolEmail, schoolPhone, prefix, studentCapacity, adminEmail, adminPhone, identityEmail }) {
  const invalidFields = [];
  if (!schoolName || schoolName.length < 3) invalidFields.push("school.name");
  if (!schoolEmail) invalidFields.push("school.email");
  if (!schoolPhone) invalidFields.push("school.phone");
  if (!prefix || prefix.length < 2) invalidFields.push("school.prefix");
  if (!text(school.category, 80)) invalidFields.push("school.category");
  if (studentCapacity < 1) invalidFields.push("school.studentCapacity");
  if (!text(location.region, 40)) invalidFields.push("location.region");
  if (!text(location.district, 100)) invalidFields.push("location.district");
  if (!text(location.address, 240)) invalidFields.push("location.address");
  if (!text(administrator.firstName, 100)) invalidFields.push("administrator.firstName");
  if (!text(administrator.lastName, 100)) invalidFields.push("administrator.lastName");
  if (!adminPhone) invalidFields.push("administrator.phone");
  if (adminEmail !== String(identityEmail).toLowerCase()) invalidFields.push("administrator.email");
  if (!ALLOWED_PLANS.includes(plan)) invalidFields.push("plan");
  if (termsAccepted !== true) invalidFields.push("termsAccepted");
  return invalidFields;
}

// Test-only convenience: derives the same fields the handler derives from a
// raw request body, so tests exercise the real validation without mocking
// Firestore/Auth.
function validateSchoolApplicationBody(body, identityEmail) {
  const school = body?.school ?? {}, location = body?.location ?? {}, administrator = body?.administrator ?? {};
  const plan = text(body?.plan, 40);
  const schoolName = text(school.name, 160), schoolEmail = text(school.email, 160).toLowerCase(), schoolPhone = normalizePhone(school.phone);
  const prefix = text(school.prefix, 12).toUpperCase().replace(/[^A-Z0-9]/g, "");
  const studentCapacity = Math.max(0, Math.min(1000000, Math.round(Number(school.studentCapacity || 0))));
  const adminEmail = text(administrator.email, 160).toLowerCase(), adminPhone = normalizePhone(administrator.phone);
  return validateSchoolApplicationFields({ school, location, administrator, plan, termsAccepted: body?.termsAccepted, schoolName, schoolEmail, schoolPhone, prefix, studentCapacity, adminEmail, adminPhone, identityEmail });
}

exports.submitSchoolApplication = onRequest({ region: "europe-west1" }, async (req, res) => {
  if (cors(req, res)) return;
  if (req.method !== "POST") { res.status(405).json({ error: "method_not_allowed" }); return; }
  if (!(await rateLimit(req, "school_application", 5))) { res.status(429).json({ error: "too_many_requests", message: "Too many registration attempts. Please try again later." }); return; }

  const identity = await verifiedIdentity(req);
  if (!identity) { res.status(401).json({ error: "verified_auth_required", message: "A verified School Pulse email account is required." }); return; }

  const school = req.body?.school ?? {}, location = req.body?.location ?? {}, administrator = req.body?.administrator ?? {};
  const plan = text(req.body?.plan, 40), selectedModules = sanitizeModules(req.body?.selectedModules);
  const schoolName = text(school.name, 160), schoolEmail = text(school.email, 160).toLowerCase(), schoolPhone = normalizePhone(school.phone);
  const prefix = text(school.prefix, 12).toUpperCase().replace(/[^A-Z0-9]/g, "");
  const studentCapacity = Math.max(0, Math.min(1000000, Math.round(Number(school.studentCapacity || 0))));
  const adminEmail = text(administrator.email, 160).toLowerCase(), adminPhone = normalizePhone(administrator.phone);

  const invalidFields = validateSchoolApplicationFields({ school, location, administrator, plan, termsAccepted: req.body?.termsAccepted, schoolName, schoolEmail, schoolPhone, prefix, studentCapacity, adminEmail, adminPhone, identityEmail: identity.email });

  if (invalidFields.length) {
    console.warn("Invalid school application payload", { uid: identity.uid, invalidFields });
    res.status(400).json({ error: "invalid_application", message: "Required registration information is missing or invalid." }); return;
  }

  const ref = db.collection("public_school_applications").doc(identity.uid);
  const existing = await ref.get(); const existingStatus = String(existing.data()?.status ?? "");
  if (existing.exists && ["approved", "pending_review"].includes(existingStatus)) { res.status(409).json({ error: "application_exists", message: "A school application already exists for this account." }); return; }

  const [prefixUsed, schoolPhoneUsed, adminPhoneUsedAsSchool, adminPhoneUsedAsAdmin, schoolEmailUsed] = await Promise.all([
    usedByOtherActiveApplication("school.prefix", prefix, identity.uid),
    usedByOtherActiveApplication("school.phone", schoolPhone, identity.uid),
    usedByOtherActiveApplication("school.phone", adminPhone, identity.uid),
    usedByOtherActiveApplication("administrator.phone", adminPhone, identity.uid),
    usedByOtherActiveApplication("school.email", schoolEmail, identity.uid),
  ]);
  if (prefixUsed) { res.status(409).json({ error: "prefix_in_use", message: "Those school initials are already in use. Choose another." }); return; }
  if (schoolPhoneUsed) { res.status(409).json({ error: "school_phone_in_use", message: "That school phone number is already linked to another School Pulse application." }); return; }
  if (adminPhoneUsedAsSchool || adminPhoneUsedAsAdmin) { res.status(409).json({ error: "admin_phone_in_use", message: "That administrator phone number is already linked to another School Pulse school." }); return; }
  if (schoolEmailUsed) { res.status(409).json({ error: "school_email_in_use", message: "That school email is already linked to another School Pulse application." }); return; }

  const capacityReview = await requiresCapacityReview(studentCapacity);
  const now = admin.firestore.FieldValue.serverTimestamp();
  await ref.set({
    id: identity.uid, authUid: identity.uid, status: "pending_review", source: "public_website", plan, selectedModules,
    requiresCapacityReview: capacityReview,
    school: { name: schoolName, shortName: text(school.shortName, 40), email: schoolEmail, phone: schoolPhone, category: text(school.category, 80), poBox: "", prefix, motto: "", studentCapacity },
    location: { region: text(location.region, 40), district: text(location.district, 100), address: text(location.address, 240), country: "Uganda", website: "", locationName: text(location.locationName, 140), latitude: "", longitude: "" },
    administrator: { firstName: text(administrator.firstName, 100), lastName: text(administrator.lastName, 100), gender: text(administrator.gender, 40), phone: adminPhone, email: adminEmail, username: text(administrator.username, 120), emailVerified: true },
    marketingOptIn: req.body?.marketingOptIn === true, termsAccepted: true, termsAcceptedAt: now,
    createdAt: existing.exists ? (existing.data()?.createdAt ?? now) : now, updatedAt: now, reviewedAt: null, reviewedBy: null,
  }, { merge: true });

  res.status(201).json({ ok: true, applicationId: identity.uid, status: "pending_review", schoolName, requiresCapacityReview: capacityReview });
});

exports.getSchoolApplicationStatus = onRequest({ region: "europe-west1" }, async (req, res) => {
  if (cors(req, res)) return;
  if (!["GET", "POST"].includes(req.method)) { res.status(405).json({ error: "method_not_allowed" }); return; }
  const identity = await verifiedIdentity(req);
  if (!identity) { res.status(401).json({ error: "verified_auth_required" }); return; }
  const ref = db.collection("public_school_applications").doc(identity.uid); const snap = await ref.get();
  if (!snap.exists) { res.status(404).json({ error: "application_not_found" }); return; }
  const data = snap.data(); await ref.set({ lastStatusCheckAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  res.status(200).json({ status: text(data.status, 40), schoolName: text(data.school?.name, 160), plan: text(data.plan, 40), appReady: data.appReady === true, appUrl: APP_URL, rejectionReason: text(data.rejectionReason, 500) });
});

exports.__test__ = { validateSchoolApplicationBody };
