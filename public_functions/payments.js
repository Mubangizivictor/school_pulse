const { onCall, onRequest, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const crypto = require('crypto');
const { requirePlatformOwner, OwnerAuthorizationError } = require('./vendor/owner-auth');
const { ROOT: PORTAL_ROOT, validSlug: validPortalSlug } = require('./portal_slug');
const { publicDomain: portalPublicDomain } = require('./portal_domains');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const WEBSITE_ORIGIN = 'https://schoolpulseapp.com';
// The Flutter app moved under /app/ (firebase.json's SPA rewrite now only
// covers /app/**) - a bare WEBSITE_ORIGIN link now resolves to the static
// marketing homepage, not the app, so this must include the prefix.
const APP_URL = `${WEBSITE_ORIGIN}/app`;
const CORE_MODULES = ['Students', 'Attendance', 'Academics', 'Administration'];
const MODULE_MAP = {
  Students: 'students',
  Attendance: 'attendance',
  Academics: 'academics',
  Administration: 'administration',
  Finance: 'finance',
  Boarding: 'boarding',
  Health: 'health',
  Library: 'library',
  Transport: 'transport',
  Messaging: 'messaging',
};

// Migration defaults only. Once billingModel=manual_v1 is present, Firestore
// remains the pricing authority and code never resets the owner-edited price.
const PLAN_DEFAULTS = {
  starter: { name: 'Starter', price: 350000, billingCycle: 'termly', termLengthDays: 120 },
  growth: { name: 'Growth', price: 550000, billingCycle: 'termly', termLengthDays: 120 },
  pro: { name: 'Pro', price: 800000, billingCycle: 'termly', termLengthDays: 120 },
  enterprise: { name: 'Enterprise', price: 0, billingCycle: 'termly', termLengthDays: 120, customPricing: true },
};

const DEFAULT_MANUAL_PAYMENT_CONFIG = {
  currency: 'UGX',
  proofMaxBytes: 10 * 1024 * 1024,
  mobileMoney: {
    enabled: false,
    network: 'MTN',
    number: '',
    accountName: '',
  },
  airtelMoney: {
    enabled: false,
    network: 'Airtel',
    number: '',
    accountName: '',
  },
  bank: {
    enabled: false,
    bankName: '',
    branch: '',
    accountName: '',
    accountNumber: '',
  },
  cash: {
    enabled: false,
    instructions: '',
  },
};

function text(value, max = 200) {
  return String(value ?? '').trim().slice(0, max);
}

function cors(req, res) {
  const origin = req.get('origin');
  if (origin === WEBSITE_ORIGIN || origin === 'http://localhost:4321') {
    res.set('Access-Control-Allow-Origin', origin);
  }
  res.set('Vary', 'Origin');
  res.set('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type,Authorization,X-Firebase-AppCheck');
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return true;
  }
  return false;
}

function asIso(value) {
  if (!value) return null;
  if (typeof value.toDate === 'function') return value.toDate().toISOString();
  if (value instanceof Date) return value.toISOString();
  if (typeof value === 'number') return new Date(value).toISOString();
  return null;
}

function normalizedModules(value) {
  const requested = Array.isArray(value) ? value : [];
  const selected = new Set([...CORE_MODULES, ...requested.map((item) => text(item, 50))]);
  return [...selected].map((name) => MODULE_MAP[name]).filter(Boolean);
}

function normalizedPlanId(value) {
  const raw = text(value, 40).toLowerCase();
  if (Object.prototype.hasOwnProperty.call(PLAN_DEFAULTS, raw)) return raw;
  for (const [id, plan] of Object.entries(PLAN_DEFAULTS)) {
    if (plan.name.toLowerCase() === raw) return id;
  }
  return raw;
}

const ALLOWED_PLAN_MODULE_KEYS = [
  'attendance',
  'reports',
  'finance',
  'messaging',
  'health',
  'transport',
  'library',
  'boarding',
];
const PLAN_CODE_RE = /^[a-z][a-z0-9_]{1,39}$/;

function normalizedModuleList(value) {
  const list = Array.isArray(value) ? value : [];
  const set = new Set(
    list
      .map((item) => text(item, 30).toLowerCase())
      .filter((item) => ALLOWED_PLAN_MODULE_KEYS.includes(item)),
  );
  return [...set].slice(0, 8);
}

// Shared field parsing/validation for createSubscriptionPlan and
// updateSubscriptionPlan - keeps the two callables' payloads in lockstep
// instead of duplicating this block. `isArchived` is intentionally excluded:
// only archiveSubscriptionPlan/reactivateSubscriptionPlan may flip it.
function parseAndValidatePlanFields(data, planId) {
  const name = text(data?.name, 60);
  const description = text(data?.description, 220);
  const price = Math.round(Number(data?.price));
  const billingCycle = text(data?.billingCycle || 'termly', 20).toLowerCase();
  const termLengthDays = Math.round(
    Number(data?.termLengthDays === undefined ? 120 : data.termLengthDays),
  );
  const trialDays = Math.round(Number(data?.trialDays || 0));
  const maxStudents = Math.round(Number(data?.maxStudents || 0));
  const maxStaff = Math.round(Number(data?.maxStaff || 0));
  const storageLimitGb = Number(data?.storageLimitGb || 0);
  const smsLimitPerMonth = Math.round(Number(data?.smsLimitPerMonth || 0));
  const includedFeatures = Array.isArray(data?.includedFeatures)
    ? data.includedFeatures.map((item) => text(item, 80)).filter(Boolean).slice(0, 20)
    : [];
  const includedModules = normalizedModuleList(data?.includedModules);
  const isPublic = data?.isPublic !== false;
  const isActive = data?.isActive !== false;
  const isPopular = data?.isPopular === true;
  const displayOrder = Math.round(Number(data?.displayOrder || 0));

  if (!name) throw new HttpsError('invalid-argument', 'Plan name is required.');
  if (!['monthly', 'termly', 'yearly'].includes(billingCycle)) {
    throw new HttpsError('invalid-argument', 'Invalid billing cycle.');
  }
  if (termLengthDays < 1 || termLengthDays > 730) {
    throw new HttpsError('invalid-argument', 'Billing period length must be between 1 and 730 days.');
  }
  if (trialDays < 0 || trialDays > 90) {
    throw new HttpsError('invalid-argument', 'Trial days must be between 0 and 90.');
  }
  if (planId !== 'enterprise' && (!Number.isFinite(price) || price <= 0)) {
    throw new HttpsError('invalid-argument', 'Plan price must be greater than zero.');
  }
  if (planId === 'enterprise' && (!Number.isFinite(price) || price < 0)) {
    throw new HttpsError('invalid-argument', 'Enterprise price cannot be negative.');
  }
  if (maxStudents < 0 || maxStaff < 0 || storageLimitGb < 0) {
    throw new HttpsError('invalid-argument', 'Limits cannot be negative.');
  }
  if (smsLimitPerMonth < 0 || smsLimitPerMonth > 1000000) {
    throw new HttpsError('invalid-argument', 'SMS limit is out of range.');
  }

  return {
    name,
    description,
    price,
    billingCycle,
    termLengthDays,
    trialDays,
    maxStudents,
    maxStaff,
    storageLimitGb,
    smsLimitPerMonth,
    includedFeatures,
    includedModules,
    customPricing: planId === 'enterprise' && price === 0,
    isPublic,
    isActive,
    isPopular,
    displayOrder,
  };
}

function schoolClassification(category) {
  const value = text(category, 80).toLowerCase();
  if (value.includes('kindergarten') || value.includes('nursery')) return 'kindergarten';
  if (value.includes('primary')) return 'primary';
  if (value.includes('secondary')) return 'secondary';
  if (value.includes('vocational')) return 'vocational';
  if (value.includes('college')) return 'college';
  if (value.includes('university')) return 'university';
  return 'other';
}

async function verifiedIdentity(req) {
  const header = text(req.get('authorization'), 5000);
  if (!header.startsWith('Bearer ')) return null;
  try {
    const decoded = await admin.auth().verifyIdToken(header.slice(7));
    if (!decoded.uid || !decoded.email || !decoded.email_verified) return null;
    return decoded;
  } catch (_) {
    return null;
  }
}

// Thin wrapper over the canonical @school-pulse/owner-auth package -
// replaces a previous local implementation that only checked the
// singular `role` field and never cross-checked
// `platform_config/owner_seed.ownerUid`, the actual authorization
// boundary. Gates payments/billing-config/plan-pricing endpoints, so this
// was a real gap: see shared/owner-auth/index.js.
async function requireOwner(request) {
  try {
    return await requirePlatformOwner(request, { db });
  } catch (error) {
    if (error instanceof OwnerAuthorizationError) {
      throw new HttpsError(error.code, error.message);
    }
    throw error;
  }
}

// The canonical seeded platform-owner uid, used to scope owner-feed
// notification documents (super_admin_notifications.ownerId). Read from the
// same single authorization boundary requirePlatformOwner uses. Returns ''
// if the seed is somehow missing rather than throwing - a missing ownerId
// on the doc is treated by the owner-feed callables as "belongs to the
// seeded owner" anyway, so an unscoped write degrades safely.
let _cachedOwnerUid;
async function seededOwnerUid() {
  if (_cachedOwnerUid !== undefined) return _cachedOwnerUid;
  try {
    const snap = await db.collection('platform_config').doc('owner_seed').get();
    const seed = snap.exists ? snap.data() : null;
    _cachedOwnerUid = seed?.seeded ? String(seed.ownerUid || '') : '';
  } catch (_) {
    _cachedOwnerUid = '';
  }
  return _cachedOwnerUid;
}

async function ensureBillingDefaults() {
  const serverTime = admin.firestore.FieldValue.serverTimestamp();
  const configRef = db.collection('platform_billing_config').doc('manual');
  const configSnap = await configRef.get();
  if (!configSnap.exists) {
    await configRef.set({
      ...DEFAULT_MANUAL_PAYMENT_CONFIG,
      createdAt: serverTime,
      updatedAt: serverTime,
    });
  }

  for (const [id, defaults] of Object.entries(PLAN_DEFAULTS)) {
    const ref = db.collection('subscription_plans').doc(id);
    const snap = await ref.get();
    const existing = snap.exists ? snap.data() || {} : {};
    if (!snap.exists || existing.billingModel !== 'manual_v1') {
      await ref.set({
        id,
        name: existing.name || defaults.name,
        description: existing.description || `${defaults.name} School Pulse plan`,
        price: defaults.price,
        billingCycle: defaults.billingCycle,
        termLengthDays: defaults.termLengthDays,
        customPricing: defaults.customPricing === true,
        maxStudents: Number(existing.maxStudents ?? 0),
        maxStaff: Number(existing.maxStaff ?? 0),
        storageLimitGb: Number(existing.storageLimitGb ?? 0),
        includedFeatures: Array.isArray(existing.includedFeatures) ? existing.includedFeatures : [],
        isDefault: existing.isDefault === true,
        billingModel: 'manual_v1',
        updatedAt: serverTime,
      }, { merge: true });
    }
  }
}

async function getPlan(planValue) {
  await ensureBillingDefaults();
  const planId = normalizedPlanId(planValue);
  if (!planId) return null;
  let snap = await db.collection('subscription_plans').doc(planId).get();
  if (!snap.exists) {
    const byName = await db.collection('subscription_plans')
      .where('name', '==', text(planValue, 40))
      .limit(1)
      .get();
    if (!byName.empty) snap = byName.docs[0];
  }
  if (!snap.exists) return null;
  return { id: snap.id, ...(snap.data() || {}) };
}

async function getManualConfig() {
  await ensureBillingDefaults();
  const snap = await db.collection('platform_billing_config').doc('manual').get();
  return snap.exists ? snap.data() : DEFAULT_MANUAL_PAYMENT_CONFIG;
}

async function resolveSubscriber(uid) {
  const applicationRef = db.collection('public_school_applications').doc(uid);
  const applicationSnap = await applicationRef.get();
  const application = applicationSnap.exists ? applicationSnap.data() || {} : null;
  const userRef = db.collection('users').doc(uid);
  const userSnap = await userRef.get();
  const user = userSnap.exists ? userSnap.data() || {} : null;
  const schoolId = text(application?.schoolId || user?.schoolId, 180);
  if (!schoolId) {
    return { applicationRef, applicationSnap, application, userRef, user, schoolRef: null, schoolSnap: null, school: null };
  }
  const schoolRef = db.collection('schools').doc(schoolId);
  const schoolSnap = await schoolRef.get();
  const school = schoolSnap.exists ? schoolSnap.data() || {} : null;
  return { applicationRef, applicationSnap, application, userRef, user, schoolRef, schoolSnap, school };
}

function subscriberCanManagePayment(subscriber, uid) {
  if (subscriber.application?.authUid === uid || subscriber.application?.id === uid) return true;
  return subscriber.user?.role === 'schoolAdmin' && subscriber.user?.schoolId === subscriber.school?.id;
}

async function migrateLegacyApprovedApplication(applicationRef, application) {
  if (!application || application.status !== 'approved' || application.paymentStatus) return application;
  const schoolId = text(application.schoolId, 180);
  const serverTime = admin.firestore.FieldValue.serverTimestamp();
  const nowMs = Date.now();
  const batch = db.batch();
  batch.set(applicationRef, {
    paymentStatus: 'awaiting_payment',
    appReady: false,
    updatedAt: serverTime,
  }, { merge: true });
  if (schoolId) {
    const schoolRef = db.collection('schools').doc(schoolId);
    const schoolSnap = await schoolRef.get();
    if (schoolSnap.exists) {
      const school = schoolSnap.data() || {};
      const metadata = school.metadata && typeof school.metadata === 'object' ? school.metadata : {};
      if (metadata.source === 'public_website_application' && metadata.hasEverActivated !== true) {
        batch.set(schoolRef, {
          status: 'trial',
          subscriptionExpiry: nowMs,
          metadata: {
            ...metadata,
            subscriptionStatus: 'awaiting_payment',
            hasEverActivated: false,
          },
        }, { merge: true });
      }
    }
  }
  await batch.commit();
  return { ...application, paymentStatus: 'awaiting_payment', appReady: false };
}

exports.approveSchoolApplication = onCall(
  { region: 'europe-west1' },
  async (request) => {
    const owner = await requireOwner(request);
    await ensureBillingDefaults();
    const applicationId = text(request.data?.applicationId, 160);
    if (!applicationId) throw new HttpsError('invalid-argument', 'applicationId is required.');

    const applicationRef = db.collection('public_school_applications').doc(applicationId);
    const applicationSnap = await applicationRef.get();
    if (!applicationSnap.exists) throw new HttpsError('not-found', 'School application not found.');

    const application = applicationSnap.data() || {};
    if (application.status === 'approved' && application.schoolId) {
      const migrated = await migrateLegacyApprovedApplication(applicationRef, application);
      return {
        ok: true,
        schoolId: application.schoolId,
        alreadyApproved: true,
        status: 'approved',
        paymentStatus: migrated.paymentStatus || 'awaiting_payment',
        appReady: migrated.appReady === true,
      };
    }
    if (application.status !== 'pending_review') {
      throw new HttpsError('failed-precondition', `Only pending applications can be approved. Current status: ${application.status || 'unknown'}.`);
    }
    if (application.termsAccepted !== true) {
      throw new HttpsError('failed-precondition', 'The applicant has not accepted the School Pulse terms.');
    }

    const applicantUid = text(application.authUid || application.id || applicationId, 160);
    let authUser;
    try {
      authUser = await admin.auth().getUser(applicantUid);
    } catch (_) {
      throw new HttpsError('failed-precondition', 'The applicant Firebase account no longer exists.');
    }
    if (!authUser.emailVerified) throw new HttpsError('failed-precondition', 'The applicant email must be verified before approval.');

    const school = application.school || {};
    const location = application.location || {};
    const administrator = application.administrator || {};
    const schoolName = text(school.name, 160);
    const prefix = text(school.prefix, 12).toUpperCase().replace(/[^A-Z0-9]/g, '');
    const adminEmail = text(administrator.email || authUser.email, 160).toLowerCase();
    if (!schoolName || !prefix || !adminEmail) throw new HttpsError('failed-precondition', 'The application is missing school or administrator identity fields.');
    if ((authUser.email || '').toLowerCase() !== adminEmail) throw new HttpsError('failed-precondition', 'The verified account does not match the submitted administrator email.');

    const plan = await getPlan(application.plan);
    if (!plan) throw new HttpsError('failed-precondition', 'The selected subscription plan no longer exists.');

    const existingPrefix = await db.collection('schools').where('tenantId', '==', prefix).limit(1).get();
    const deterministicSchoolId = application.schoolId || `sch_${prefix.toLowerCase()}_${applicantUid.slice(0, 8)}`;
    if (!existingPrefix.empty && existingPrefix.docs[0].id !== deterministicSchoolId) {
      throw new HttpsError('already-exists', `School prefix ${prefix} is already assigned to another institution.`);
    }

    const schoolId = deterministicSchoolId;
    // The applicant's chosen web address, captured at submission time
    // (index.js:submitSchoolApplication, required there since this session)
    // and re-validated here since this callable is the trust boundary that
    // actually reserves it. A missing/invalid slug means a legacy
    // application submitted before slug was required - that's rejected
    // loudly (not silently approved without a portal) so it surfaces to the
    // owner as something needing manual handling, rather than quietly
    // producing a school with no reachable subdomain.
    const slug = text(school.slug, 63).toLowerCase();
    if (!validPortalSlug(slug)) {
      throw new HttpsError('failed-precondition', 'This application has no valid school web address on file (it may predate that requirement). Ask the applicant to resubmit with a web address before approving.');
    }
    const portalHost = `${slug}.${PORTAL_ROOT}`;
    const slugReservationRef = db.doc(`portal_slug_reservations/${slug}`);
    const enabledFeatures = normalizedModules(application.selectedModules);
    const nowMs = Date.now();
    const administratorName = `${text(administrator.firstName, 100)} ${text(administrator.lastName, 100)}`.trim() || authUser.displayName || 'School Administrator';
    const address = [text(location.address, 240), text(location.district, 100), text(location.region, 40)].filter(Boolean).join(', ');
    const schoolRef = db.collection('schools').doc(schoolId);
    const existingSchool = await schoolRef.get();
    if (existingSchool.exists) {
      const sourceApplicationId = text(existingSchool.data()?.metadata?.applicationId, 160);
      if (sourceApplicationId !== applicationId) {
        throw new HttpsError('already-exists', 'The generated school identity is already used by a different tenant. Review the school prefix before approving.');
      }
    }

    const userRef = db.collection('users').doc(applicantUid);
    const contactRef = db.collection('school_contacts').doc(applicantUid);
    const membershipRef = db.collection('institution_memberships').doc(`${applicantUid}_${schoolId}`);
    const auditRef = db.collection('super_admin_audit_logs').doc();
    const serverTime = admin.firestore.FieldValue.serverTimestamp();

    const schoolData = {
      id: schoolId,
      name: schoolName,
      tenantId: prefix,
      address,
      contactEmail: text(school.email, 160).toLowerCase(),
      contactPhone: text(school.phone, 30),
      status: 'trial',
      subscriptionPlanId: plan.id,
      createdAt: nowMs,
      subscriptionExpiry: nowMs,
      enabledFeatures,
      metadata: {
        source: 'public_website_application',
        applicationId,
        category: text(school.category, 80),
        motto: text(school.motto, 180),
        website: text(location.website, 240),
        region: text(location.region, 40),
        district: text(location.district, 100),
        selectedPlanLabel: text(plan.name || application.plan, 40),
        selectedModules: Array.isArray(application.selectedModules) ? application.selectedModules : CORE_MODULES,
        subscriptionStatus: 'awaiting_payment',
        hasEverActivated: false,
        approvedBy: owner.uid,
        approvedAt: nowMs,
      },
      classification: schoolClassification(school.category),
      classificationOther: null,
      divisions: [],
      displayLabel: text(school.shortName, 40) || schoolName,
      // Mirrors portal_domains.js:createSchoolPortal's school doc shape so
      // both onboarding paths (owner-created portal vs. public application)
      // produce a tenant portal_tenant_resolver.dart can resolve the same way.
      portalSubdomain: portalHost,
      customDomains: [],
      branding: {
        schoolName,
        logoUrl: null,
        primaryColor: null,
        secondaryColor: null,
        address,
        phone: text(school.phone, 30),
        email: text(school.email, 160).toLowerCase(),
      },
    };

    // The slug-reservation check-and-write happens inside this transaction
    // (re-reading slugReservationRef here, not trusting any earlier read)
    // alongside every other write this approval makes, so two concurrent
    // approvals racing for the same slug can't both pass the availability
    // check and silently overwrite each other's reservation/portal_domains
    // docs - Firestore aborts and retries the loser instead.
    await db.runTransaction(async (tx) => {
      const slugReservationSnap = await tx.get(slugReservationRef);
      if (slugReservationSnap.exists && slugReservationSnap.data()?.schoolId !== schoolId) {
        throw new HttpsError('already-exists', 'That school web address is already in use. The applicant must choose another before this can be approved.');
      }
      tx.set(schoolRef, schoolData, { merge: false });
      if (!slugReservationSnap.exists) {
        tx.set(slugReservationRef, { schoolId, slug, createdAt: serverTime });
      }
      // Reuses portal_domains.js's own publicDomain() projection so this
      // path produces the exact same document shape (including
      // address/phone/email) as createSchoolPortal/syncPortalDomainProjection
      // instead of a hand-duplicated, easy-to-drift object literal.
      tx.set(db.doc(`portal_domains/${portalHost}`), portalPublicDomain(schoolId, schoolData, portalHost));
      tx.set(userRef, {
        id: applicantUid,
        name: administratorName,
        email: adminEmail,
        phoneNumber: text(administrator.phone, 30),
        role: 'schoolAdmin',
        roles: ['schoolAdmin'],
        schoolId,
        schoolName,
        studentIds: [],
        mustChangePassword: false,
        mfaEnabled: false,
        isActive: true,
        source: 'public_website_application',
        createdBy: owner.uid,
        createdAt: serverTime,
      }, { merge: true });
      tx.set(contactRef, {
        name: administratorName,
        role: 'schoolAdmin',
        roles: ['schoolAdmin'],
        schoolId,
        isActive: true,
        phone: text(administrator.phone, 30),
      }, { merge: true });
      tx.set(membershipRef, {
        id: `${applicantUid}_${schoolId}`,
        userId: applicantUid,
        institutionId: schoolId,
        schoolId,
        role: 'schoolAdmin',
        roles: ['schoolAdmin'],
        status: 'active',
        createdAt: serverTime,
        createdBy: owner.uid,
      }, { merge: true });
      tx.set(applicationRef, {
        status: 'approved',
        schoolId,
        paymentStatus: 'awaiting_payment',
        appReady: false,
        appUrl: APP_URL,
        reviewedAt: serverTime,
        reviewedBy: owner.uid,
        rejectionReason: admin.firestore.FieldValue.delete(),
        paymentRejectionReason: admin.firestore.FieldValue.delete(),
        updatedAt: serverTime,
      }, { merge: true });
      tx.set(auditRef, {
        id: auditRef.id,
        ownerId: owner.uid,
        action: 'APPROVE_SCHOOL_APPLICATION_AWAITING_PAYMENT',
        schoolId,
        affectedUserId: applicantUid,
        timestamp: serverTime,
        device: 'Platform Dashboard',
        metadata: {
          applicationId,
          schoolName,
          planId: plan.id,
          planPrice: Number(plan.price || 0),
          billingCycle: text(plan.billingCycle, 20),
          enabledFeatures,
        },
      });
    });

    try {
      const existingClaims = authUser.customClaims || {};
      await admin.auth().setCustomUserClaims(applicantUid, {
        ...existingClaims,
        role: 'schoolAdmin',
        roles: ['schoolAdmin'],
        schoolId,
      });
    } catch (error) {
      console.error('School approved but custom claims update failed', error);
    }

    return { ok: true, schoolId, status: 'approved', paymentStatus: 'awaiting_payment', appReady: false, portalUrl: `https://${portalHost}` };
  },
);

exports.getSchoolApplicationStatus = onRequest({ region: 'europe-west1' }, async (req, res) => {
  if (cors(req, res)) return;
  if (!['GET', 'POST'].includes(req.method)) {
    res.status(405).json({ error: 'method_not_allowed' });
    return;
  }
  const identity = await verifiedIdentity(req);
  if (!identity) {
    res.status(401).json({ error: 'verified_auth_required' });
    return;
  }
  const ref = db.collection('public_school_applications').doc(identity.uid);
  const snap = await ref.get();
  if (!snap.exists) {
    res.status(404).json({ error: 'application_not_found' });
    return;
  }
  let data = snap.data() || {};
  data = await migrateLegacyApprovedApplication(ref, data);
  await ref.set({ lastStatusCheckAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  // Lowercased to match submitSchoolApplication's own storage convention -
  // every other slug read path in this codebase lowercases before using it,
  // and a portalUrl built from a mixed-case slug would never resolve
  // (portal_domains keys and DNS hostnames are lowercase-only).
  const slug = text(data.school?.slug, 63).toLowerCase();
  res.status(200).json({
    status: text(data.status, 40),
    paymentStatus: text(data.paymentStatus, 40),
    paymentRejectionReason: text(data.paymentRejectionReason, 500),
    schoolId: text(data.schoolId, 180),
    schoolName: text(data.school?.name, 160),
    plan: text(data.plan, 40),
    appReady: data.appReady === true && data.paymentStatus === 'paid',
    appUrl: text(data.appUrl, 300) || APP_URL,
    paymentUrl: `${WEBSITE_ORIGIN}/payment`,
    rejectionReason: text(data.rejectionReason, 500),
    slug,
    portalUrl: validPortalSlug(slug) ? `https://${slug}.${PORTAL_ROOT}` : null,
  });
});

exports.getManualPaymentContext = onRequest({ region: 'europe-west1' }, async (req, res) => {
  if (cors(req, res)) return;
  if (!['GET', 'POST'].includes(req.method)) {
    res.status(405).json({ error: 'method_not_allowed' });
    return;
  }
  const identity = await verifiedIdentity(req);
  if (!identity) {
    res.status(401).json({ error: 'verified_auth_required' });
    return;
  }
  const subscriber = await resolveSubscriber(identity.uid);
  if (!subscriber.school || !subscriber.schoolRef) {
    res.status(404).json({ error: 'school_not_found', message: 'Your School Pulse school has not been provisioned yet.' });
    return;
  }
  if (!subscriberCanManagePayment(subscriber, identity.uid)) {
    res.status(403).json({ error: 'school_admin_required', message: 'Only the School Administrator can submit subscription payments.' });
    return;
  }
  const plan = await getPlan(subscriber.school.subscriptionPlanId || subscriber.application?.plan);
  if (!plan) {
    res.status(409).json({ error: 'plan_not_configured', message: 'This school does not have a valid subscription plan.' });
    return;
  }
  const config = await getManualConfig();
  const metadata = subscriber.school.metadata && typeof subscriber.school.metadata === 'object' ? subscriber.school.metadata : {};
  const hasEverActivated = metadata.hasEverActivated === true;
  const expectedAmount = Math.round(Number(plan.price || 0));
  res.status(200).json({
    ok: true,
    schoolId: subscriber.school.id || subscriber.schoolRef.id,
    schoolName: text(subscriber.school.name, 160),
    plan: {
      id: plan.id,
      name: text(plan.name, 80),
      expectedAmount,
      currency: text(config.currency || 'UGX', 10),
      billingCycle: text(plan.billingCycle || 'termly', 20),
      termLengthDays: Math.max(1, Number(plan.termLengthDays || 120)),
      pricingUnavailable: expectedAmount <= 0,
      customPricing: plan.customPricing === true,
    },
    paymentType: hasEverActivated ? 'renewal' : 'activation',
    paymentStatus: text(subscriber.application?.paymentStatus || metadata.subscriptionStatus || 'awaiting_payment', 40),
    paymentRejectionReason: text(subscriber.application?.paymentRejectionReason, 500),
    currentSubscriptionExpiry: asIso(subscriber.school.subscriptionExpiry),
    instructions: {
      mobileMoney: config.mobileMoney || DEFAULT_MANUAL_PAYMENT_CONFIG.mobileMoney,
      airtelMoney: config.airtelMoney || DEFAULT_MANUAL_PAYMENT_CONFIG.airtelMoney,
      bank: config.bank || DEFAULT_MANUAL_PAYMENT_CONFIG.bank,
      cash: config.cash || DEFAULT_MANUAL_PAYMENT_CONFIG.cash,
    },
    proofMaxBytes: Number(config.proofMaxBytes || DEFAULT_MANUAL_PAYMENT_CONFIG.proofMaxBytes),
  });
});

exports.submitManualPayment = onRequest({ region: 'europe-west1' }, async (req, res) => {
  if (cors(req, res)) return;
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'method_not_allowed' });
    return;
  }
  const identity = await verifiedIdentity(req);
  if (!identity) {
    res.status(401).json({ error: 'verified_auth_required' });
    return;
  }
  const subscriber = await resolveSubscriber(identity.uid);
  if (!subscriber.school || !subscriber.schoolRef) {
    res.status(404).json({ error: 'school_not_found', message: 'Your School Pulse school has not been provisioned yet.' });
    return;
  }
  if (!subscriberCanManagePayment(subscriber, identity.uid)) {
    res.status(403).json({ error: 'school_admin_required', message: 'Only the School Administrator can submit subscription payments.' });
    return;
  }
  const plan = await getPlan(subscriber.school.subscriptionPlanId || subscriber.application?.plan);
  if (!plan) {
    res.status(409).json({ error: 'plan_not_configured', message: 'This subscription plan is not configured.' });
    return;
  }
  const expectedAmount = Math.round(Number(plan.price || 0));
  if (expectedAmount <= 0) {
    res.status(409).json({ error: 'price_not_configured', message: 'The SaaS Owner must configure a price for this plan before payment can be submitted.' });
    return;
  }
  const submittedAmount = Math.round(Number(req.body?.amount || 0));
  if (submittedAmount !== expectedAmount) {
    res.status(400).json({ error: 'full_payment_required', message: `Full payment of UGX ${expectedAmount} is required. Partial payments are not accepted.` });
    return;
  }
  const method = text(req.body?.method, 20).toLowerCase();
  if (!['mtn', 'airtel', 'bank', 'cash'].includes(method)) {
    res.status(400).json({ error: 'invalid_method', message: 'Choose MTN Mobile Money, Airtel Money, bank transfer or cash.' });
    return;
  }
  const payerName = text(req.body?.payerName, 160);
  // Cash has no transaction reference; the school records the receipt/agent
  // reference the SaaS Owner gave them at hand-off so the payment can still
  // be matched during review.
  const reference = text(req.body?.reference, 120);
  const referenceNormalized = reference.replace(/\s+/g, '').toUpperCase();
  const paymentDate = new Date(text(req.body?.paymentDate, 40));
  const note = text(req.body?.note, 700);
  const proofStoragePath = text(req.body?.proofStoragePath, 500);
  const submissionId = text(req.body?.submissionId, 100);
  if (!payerName || referenceNormalized.length < 3 || Number.isNaN(paymentDate.getTime())) {
    res.status(400).json({ error: 'invalid_payment_details', message: 'Payer name, transaction/receipt reference and payment date are required.' });
    return;
  }
  if (paymentDate.getTime() > Date.now() + 24 * 60 * 60 * 1000) {
    res.status(400).json({ error: 'invalid_payment_date', message: 'Payment date cannot be in the future.' });
    return;
  }
  if (!/^[A-Za-z0-9_-]{8,100}$/.test(submissionId)) {
    res.status(400).json({ error: 'invalid_submission_id', message: 'Invalid payment submission identifier.' });
    return;
  }
  const expectedPrefix = `payment_proofs/${identity.uid}/`;
  if (!proofStoragePath.startsWith(expectedPrefix)) {
    res.status(400).json({ error: 'invalid_proof_path', message: 'Payment proof must belong to the signed-in administrator.' });
    return;
  }

  const config = await getManualConfig();
  const maxBytes = Number(config.proofMaxBytes || DEFAULT_MANUAL_PAYMENT_CONFIG.proofMaxBytes);
  try {
    const [fileMetadata] = await admin.storage().bucket().file(proofStoragePath).getMetadata();
    const size = Number(fileMetadata.size || 0);
    const contentType = text(fileMetadata.contentType, 120).toLowerCase();
    if (size <= 0 || size > maxBytes || !(contentType.startsWith('image/') || contentType === 'application/pdf')) {
      res.status(400).json({ error: 'invalid_proof', message: 'Proof must be an image or PDF within the allowed file size.' });
      return;
    }
  } catch (_) {
    res.status(400).json({ error: 'proof_not_found', message: 'Uploaded payment proof could not be verified.' });
    return;
  }

  const schoolMetadata = subscriber.school.metadata && typeof subscriber.school.metadata === 'object' ? subscriber.school.metadata : {};
  const paymentType = schoolMetadata.hasEverActivated === true ? 'renewal' : 'activation';
  const schoolId = subscriber.school.id || subscriber.schoolRef.id;
  const paymentId = `${identity.uid}_${submissionId}`;
  const paymentRef = db.collection('manual_subscription_payments').doc(paymentId);
  const referenceKey = crypto.createHash('sha256').update(`${schoolId}|${method}|${referenceNormalized}`).digest('hex');
  const referenceRef = db.collection('manual_payment_references').doc(referenceKey);
  const notificationRef = db.collection('super_admin_notifications').doc(`payment_${paymentId}`);
  const notificationOwnerUid = await seededOwnerUid();
  const serverTime = admin.firestore.FieldValue.serverTimestamp();
  const termLengthDays = Math.max(1, Math.round(Number(plan.termLengthDays || 120)));

  try {
    const result = await db.runTransaction(async (tx) => {
      const existingPayment = await tx.get(paymentRef);
      if (existingPayment.exists) {
        const current = existingPayment.data() || {};
        if (current.submittedByUid === identity.uid && current.schoolId === schoolId) {
          return { alreadySubmitted: true, status: current.status || 'pending_verification' };
        }
        throw new HttpsError('already-exists', 'This payment submission already exists.');
      }
      const referenceSnap = await tx.get(referenceRef);
      if (referenceSnap.exists) {
        throw new HttpsError('already-exists', 'This transaction/reference number has already been submitted for this school.');
      }
      tx.set(paymentRef, {
        id: paymentId,
        schoolId,
        schoolName: text(subscriber.school.name, 160),
        applicationId: subscriber.applicationSnap?.exists ? subscriber.applicationRef.id : null,
        planId: plan.id,
        planName: text(plan.name, 80),
        billingCycle: text(plan.billingCycle || 'termly', 20),
        termLengthDays,
        maxStudents: Number(plan.maxStudents || 0),
        maxStaff: Number(plan.maxStaff || 0),
        storageLimitGb: Number(plan.storageLimitGb || 0),
        paymentType,
        expectedAmount,
        submittedAmount,
        currency: text(config.currency || 'UGX', 10),
        method,
        payerName,
        reference,
        referenceNormalized,
        referenceKey,
        paidAt: admin.firestore.Timestamp.fromDate(paymentDate),
        proofStoragePath,
        note,
        status: 'pending_verification',
        submittedByUid: identity.uid,
        submittedByEmail: text(identity.email, 160).toLowerCase(),
        submittedAt: serverTime,
        reviewedByUid: null,
        reviewedAt: null,
        rejectionReason: null,
      });
      tx.set(referenceRef, { paymentId, schoolId, method, referenceNormalized, createdAt: serverTime });
      tx.set(subscriber.schoolRef, {
        metadata: { ...schoolMetadata, subscriptionStatus: 'payment_review' },
      }, { merge: true });
      if (subscriber.applicationSnap?.exists) {
        tx.set(subscriber.applicationRef, {
          paymentStatus: 'under_review',
          paymentRejectionReason: admin.firestore.FieldValue.delete(),
          appReady: false,
          updatedAt: serverTime,
        }, { merge: true });
      }
      tx.set(notificationRef, {
        id: notificationRef.id,
        ownerId: notificationOwnerUid,
        type: 'manual_payment_submitted',
        status: 'unread',
        paymentId,
        schoolId,
        schoolName: text(subscriber.school.name, 160),
        amountUgx: submittedAmount,
        method,
        createdAt: serverTime,
      });
      return { alreadySubmitted: false, status: 'pending_verification' };
    });
    res.status(result.alreadySubmitted ? 200 : 201).json({
      ok: true,
      paymentId,
      status: result.status,
      alreadySubmitted: result.alreadySubmitted,
      message: 'Payment proof received. School Pulse will verify the payment before access is activated.',
    });
  } catch (error) {
    if (error instanceof HttpsError) {
      res.status(error.code === 'already-exists' ? 409 : 400).json({ error: error.code, message: error.message });
      return;
    }
    console.error('Manual payment submission failed', error);
    res.status(500).json({ error: 'submission_failed', message: 'Could not submit payment for verification.' });
  }
});

function paymentForClient(doc) {
  const data = doc.data() || {};
  const result = {
    ...data,
    id: data.id || doc.id,
    paidAt: asIso(data.paidAt),
    submittedAt: asIso(data.submittedAt),
    reviewedAt: asIso(data.reviewedAt),
    hasProof: Boolean(data.proofStoragePath),
  };
  delete result.proofStoragePath;
  delete result.referenceKey;
  return result;
}

// Pure helper (no Firestore call) so the filter-selection logic - which
// where() clauses apply for a given request payload - is unit-testable
// without mocking a live query builder. Returns the filters to apply, not
// a built query; getManualPaymentsForOwner below applies them to `db`.
function paymentsQueryFilters(data) {
  const schoolId = text(data?.schoolId, 160);
  const startDate = Number(data?.startDateMs);
  const endDate = Number(data?.endDateMs);
  return {
    schoolId: schoolId || null,
    startDateMs: Number.isFinite(startDate) ? startDate : null,
    endDateMs: Number.isFinite(endDate) ? endDate : null,
  };
}

// schoolId/startDate/endDate are applied as real Firestore `where` clauses,
// not a client-side filter of an unscoped fetch - the callable itself is the
// tenant boundary here (manual_subscription_payments has no firestore.rules
// block of its own; it is Admin-SDK-only, so this check is the only gate).
exports.getManualPaymentsForOwner = onCall({ region: 'europe-west1' }, async (request) => {
  await requireOwner(request);
  const status = text(request.data?.status, 40);
  const filters = paymentsQueryFilters(request.data);

  let query = db.collection('manual_subscription_payments');
  if (filters.schoolId) query = query.where('schoolId', '==', filters.schoolId);
  if (filters.startDateMs !== null) {
    query = query.where('submittedAt', '>=', admin.firestore.Timestamp.fromMillis(filters.startDateMs));
  }
  if (filters.endDateMs !== null) {
    query = query.where('submittedAt', '<=', admin.firestore.Timestamp.fromMillis(filters.endDateMs));
  }
  const snapshot = await query.orderBy('submittedAt', 'desc').limit(250).get();
  let docs = snapshot.docs;
  if (status && status !== 'all') docs = docs.filter((doc) => text(doc.data()?.status, 40) === status);
  return { payments: docs.map(paymentForClient) };
});

exports.getManualPaymentProofUrl = onCall({ region: 'europe-west1' }, async (request) => {
  await requireOwner(request);
  const paymentId = text(request.data?.paymentId, 220);
  if (!paymentId) throw new HttpsError('invalid-argument', 'paymentId is required.');
  const snap = await db.collection('manual_subscription_payments').doc(paymentId).get();
  if (!snap.exists) throw new HttpsError('not-found', 'Payment not found.');
  const path = text(snap.data()?.proofStoragePath, 500);
  if (!path) throw new HttpsError('not-found', 'This payment has no proof file.');
  try {
    const [url] = await admin.storage().bucket().file(path).getSignedUrl({ action: 'read', expires: Date.now() + 15 * 60 * 1000 });
    return { url, expiresInSeconds: 900 };
  } catch (error) {
    console.error('Unable to sign payment proof URL', error);
    throw new HttpsError('internal', 'Unable to open payment proof right now.');
  }
});

exports.approveManualPayment = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);
  const paymentId = text(request.data?.paymentId, 220);
  if (!paymentId) throw new HttpsError('invalid-argument', 'paymentId is required.');
  const paymentRef = db.collection('manual_subscription_payments').doc(paymentId);
  const serverTime = admin.firestore.FieldValue.serverTimestamp();
  const nowMs = Date.now();

  const result = await db.runTransaction(async (tx) => {
    const paymentSnap = await tx.get(paymentRef);
    if (!paymentSnap.exists) throw new HttpsError('not-found', 'Payment not found.');
    const payment = paymentSnap.data() || {};
    if (payment.status === 'approved') {
      return { schoolId: payment.schoolId, subscriptionExpiry: payment.subscriptionExpiry, alreadyApproved: true };
    }
    if (payment.status !== 'pending_verification') {
      throw new HttpsError('failed-precondition', `Only pending payments can be approved. Current status: ${payment.status || 'unknown'}.`);
    }
    if (Number(payment.submittedAmount) !== Number(payment.expectedAmount) || Number(payment.expectedAmount) <= 0) {
      throw new HttpsError('failed-precondition', 'Payment amount does not match the invoiced subscription amount.');
    }
    const schoolId = text(payment.schoolId, 180);
    const schoolRef = db.collection('schools').doc(schoolId);
    const schoolSnap = await tx.get(schoolRef);
    if (!schoolSnap.exists) throw new HttpsError('failed-precondition', 'The school linked to this payment no longer exists.');
    const school = schoolSnap.data() || {};
    const metadata = school.metadata && typeof school.metadata === 'object' ? school.metadata : {};

    // Phase 2A term-based billing: find the earliest non-terminal
    // subscription_cycles doc for this school (if any) so this payment can
    // also mark it paid. Firestore transactions require ALL reads before any
    // writes, so this query runs here - before the first tx.set below - even
    // though the resulting write happens later in this same transaction.
    // Schools with no subscription_cycles docs (the flat-expiry-only flow)
    // simply get an empty snapshot here and nothing below changes for them.
    //
    // Status list mirrors subscription_cycle_billing.js's own
    // ACTIVE_CYCLE_STATUSES exactly (must include 'upcoming'): a school can
    // pay before its next cycle is even auto-invoiced (e.g. paying early,
    // or approval landing between invoice-lead-day windows), and 'paid' is
    // a terminal status the billing sweep always skips outright regardless
    // of which status it transitioned from - decideCycleAction()'s very
    // first check is `status === 'paid' -> return, no-op` - so marking an
    // 'upcoming' cycle 'paid' directly is safe; omitting 'upcoming' here
    // previously left such a cycle unmatched, so the payment never marked
    // it paid and the sweep would later invoice/suspend a term that had
    // already been paid for.
    const eligibleCycleSnap = await tx.get(
      db.collection('subscription_cycles')
        .where('schoolId', '==', schoolId)
        .where('cycleStatus', 'in', ['upcoming', 'invoiced', 'paymentPending', 'gracePeriod', 'overdue'])
        .orderBy('termStart', 'asc')
        .limit(1)
    );
    const targetCycleRef = eligibleCycleSnap.empty ? null : eligibleCycleSnap.docs[0].ref;
    const termLengthDays = Math.max(1, Math.round(Number(payment.termLengthDays || 120)));
    const existingExpiry = Number(school.subscriptionExpiry || 0);
    const startMs = payment.paymentType === 'renewal' && existingExpiry > nowMs ? existingExpiry : nowMs;
    const expiryMs = startMs + termLengthDays * 24 * 60 * 60 * 1000;

    // Activation snapshot: the commercial agreement as it stood when this
    // payment was submitted (payments.js:submitManualPayment already froze
    // termLengthDays/maxStudents/maxStaff/storageLimitGb there), not a live
    // re-read of subscription_plans - so a later plan price/cap change never
    // retroactively alters an already-paid term.
    tx.set(schoolRef, {
      status: 'active',
      subscriptionPlanId: text(payment.planId, 80),
      subscriptionExpiry: expiryMs,
      accessMode: 'full',
      subscription: {
        planId: text(payment.planId, 80),
        planName: text(payment.planName, 80),
        price: Number(payment.expectedAmount || 0),
        maxStudents: Number(payment.maxStudents || 0),
        maxStaff: Number(payment.maxStaff || 0),
        storageLimitGb: Number(payment.storageLimitGb || 0),
        termLengthDays,
        periodStart: startMs,
        periodEnd: expiryMs,
      },
      metadata: {
        ...metadata,
        subscriptionStatus: 'active',
        hasEverActivated: true,
        lastPaymentId: paymentId,
        lastPaymentApprovedAt: nowMs,
        lastPaymentApprovedBy: owner.uid,
      },
    }, { merge: true });
    tx.set(paymentRef, {
      status: 'approved',
      reviewedByUid: owner.uid,
      reviewedAt: serverTime,
      subscriptionExpiry: expiryMs,
      rejectionReason: null,
    }, { merge: true });

    // Phase 2A: if this school has a subscription_cycles doc awaiting
    // payment, mark the earliest eligible one paid in the same transaction.
    // The schoolRef.set above already unconditionally writes
    // status:'active'/accessMode:'full' regardless of whether a cycle
    // exists (that's the pre-existing flat-expiry semantics, layered under
    // here rather than altered) - so a previously-suspended school (Phase 2A
    // auto-suspend, or an owner-initiated suspend) is restored to full
    // access by that same existing write; this block only adds the cycle
    // doc's own paid marker on top when a cycle is actually present. No-op,
    // no throw, when eligibleCycleSnap was empty (flat-expiry-only school).
    if (targetCycleRef) {
      tx.set(targetCycleRef, {
        cycleStatus: 'paid',
        paymentStatus: 'paid',
        paidPaymentId: paymentId,
        paidAt: serverTime,
        updatedAt: serverTime,
      }, { merge: true });
    }
    const receiptRef = db.collection('subscription_receipts').doc(paymentId);
    tx.set(receiptRef, {
      receiptNumber: paymentId,
      schoolId,
      schoolName: text(payment.schoolName, 160),
      planId: text(payment.planId, 80),
      planName: text(payment.planName, 80),
      periodStart: startMs,
      periodEnd: expiryMs,
      amountUgx: Number(payment.submittedAmount || 0),
      currency: text(payment.currency || 'UGX', 10),
      method: text(payment.method, 20),
      paymentType: text(payment.paymentType, 20),
      approvedBy: owner.uid,
      approvedAt: serverTime,
    });
    if (payment.applicationId) {
      tx.set(db.collection('public_school_applications').doc(text(payment.applicationId, 180)), {
        paymentStatus: 'paid',
        appReady: true,
        activatedAt: serverTime,
        paymentRejectionReason: admin.firestore.FieldValue.delete(),
        updatedAt: serverTime,
      }, { merge: true });
    }
    const providerByMethod = { mtn: 'manual_mtn', airtel: 'manual_airtel', bank: 'manual_bank', cash: 'manual_cash' };
    tx.set(db.collection('payment_transactions').doc(paymentId), {
      id: paymentId,
      schoolId,
      provider: providerByMethod[payment.method] || 'manual_bank',
      phoneNumber: '',
      amountUgx: Number(payment.submittedAmount),
      status: 'success',
      reference: text(payment.reference, 120),
      createdAt: serverTime,
      paymentType: text(payment.paymentType, 20),
      planId: text(payment.planId, 80),
    }, { merge: true });
    const auditRef = db.collection('super_admin_audit_logs').doc();
    tx.set(auditRef, {
      id: auditRef.id,
      ownerId: owner.uid,
      action: payment.paymentType === 'renewal' ? 'APPROVE_SUBSCRIPTION_RENEWAL_PAYMENT' : 'APPROVE_INITIAL_SUBSCRIPTION_PAYMENT',
      schoolId,
      affectedUserId: text(payment.submittedByUid, 180),
      timestamp: serverTime,
      device: 'Platform Dashboard',
      metadata: {
        paymentId,
        amountUgx: Number(payment.submittedAmount),
        method: text(payment.method, 20),
        reference: text(payment.reference, 120),
        planId: text(payment.planId, 80),
        subscriptionExpiry: expiryMs,
      },
    });
    tx.set(db.collection('super_admin_notifications').doc(`payment_${paymentId}`), {
      status: 'resolved',
      resolvedAt: serverTime,
      resolvedBy: owner.uid,
    }, { merge: true });
    return { schoolId, subscriptionExpiry: expiryMs, alreadyApproved: false };
  });
  return { ok: true, status: 'approved', ...result };
});

exports.rejectManualPayment = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);
  const paymentId = text(request.data?.paymentId, 220);
  const reason = text(request.data?.reason, 500);
  if (!paymentId) throw new HttpsError('invalid-argument', 'paymentId is required.');
  if (reason.length < 3) throw new HttpsError('invalid-argument', 'A clear rejection reason is required.');
  const paymentRef = db.collection('manual_subscription_payments').doc(paymentId);
  const serverTime = admin.firestore.FieldValue.serverTimestamp();

  await db.runTransaction(async (tx) => {
    const paymentSnap = await tx.get(paymentRef);
    if (!paymentSnap.exists) throw new HttpsError('not-found', 'Payment not found.');
    const payment = paymentSnap.data() || {};
    if (payment.status !== 'pending_verification') throw new HttpsError('failed-precondition', 'Only pending payments can be rejected.');
    const schoolRef = db.collection('schools').doc(text(payment.schoolId, 180));
    const schoolSnap = await tx.get(schoolRef);
    if (!schoolSnap.exists) throw new HttpsError('failed-precondition', 'The school linked to this payment no longer exists.');
    const school = schoolSnap.data() || {};
    const metadata = school.metadata && typeof school.metadata === 'object' ? school.metadata : {};
    const nextSubscriptionStatus = payment.paymentType === 'renewal' ? 'payment_due' : 'awaiting_payment';
    tx.set(paymentRef, { status: 'rejected', reviewedByUid: owner.uid, reviewedAt: serverTime, rejectionReason: reason }, { merge: true });
    // A renewal rejection leaves the school exactly as it already was
    // (readOnly, set by the prior lifecycle sweep) - only an activation
    // rejection needs an explicit write, keeping the server-authoritative
    // field in sync with what isInitialPaymentRequired already implies.
    const schoolUpdate = { metadata: { ...metadata, subscriptionStatus: nextSubscriptionStatus } };
    if (payment.paymentType !== 'renewal') schoolUpdate.accessMode = 'blocked';
    tx.set(schoolRef, schoolUpdate, { merge: true });
    if (payment.applicationId) {
      tx.set(db.collection('public_school_applications').doc(text(payment.applicationId, 180)), {
        paymentStatus: 'rejected',
        paymentRejectionReason: reason,
        appReady: false,
        updatedAt: serverTime,
      }, { merge: true });
    }
    if (payment.referenceKey) tx.delete(db.collection('manual_payment_references').doc(text(payment.referenceKey, 128)));
    const auditRef = db.collection('super_admin_audit_logs').doc();
    tx.set(auditRef, {
      id: auditRef.id,
      ownerId: owner.uid,
      action: 'REJECT_MANUAL_SUBSCRIPTION_PAYMENT',
      schoolId: text(payment.schoolId, 180),
      affectedUserId: text(payment.submittedByUid, 180),
      timestamp: serverTime,
      device: 'Platform Dashboard',
      reason,
      metadata: { paymentId, amountUgx: Number(payment.submittedAmount || 0), reference: text(payment.reference, 120) },
    });
    tx.set(db.collection('super_admin_notifications').doc(`payment_${paymentId}`), {
      status: 'resolved',
      resolvedAt: serverTime,
      resolvedBy: owner.uid,
    }, { merge: true });
  });
  return { ok: true, status: 'rejected' };
});

exports.updateSubscriptionPlanPricing = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);
  await ensureBillingDefaults();
  const planId = normalizedPlanId(request.data?.planId);
  const price = Math.round(Number(request.data?.price));
  const billingCycle = text(request.data?.billingCycle || 'termly', 20).toLowerCase();
  const termLengthDays = Math.round(Number(request.data?.termLengthDays || 120));
  if (!planId) throw new HttpsError('invalid-argument', 'planId is required.');
  if (!['monthly', 'termly', 'yearly'].includes(billingCycle)) throw new HttpsError('invalid-argument', 'Invalid billing cycle.');
  if (termLengthDays < 1 || termLengthDays > 730) throw new HttpsError('invalid-argument', 'Billing period length must be between 1 and 730 days.');
  if (planId !== 'enterprise' && (!Number.isFinite(price) || price <= 0)) throw new HttpsError('invalid-argument', 'Plan price must be greater than zero.');
  if (planId === 'enterprise' && (!Number.isFinite(price) || price < 0)) throw new HttpsError('invalid-argument', 'Enterprise price cannot be negative.');

  const planRef = db.collection('subscription_plans').doc(planId);
  const snap = await planRef.get();
  if (!snap.exists) throw new HttpsError('not-found', 'Subscription plan not found.');
  const serverTime = admin.firestore.FieldValue.serverTimestamp();
  const auditRef = db.collection('super_admin_audit_logs').doc();
  const batch = db.batch();
  batch.set(planRef, {
    price,
    billingCycle,
    termLengthDays,
    customPricing: planId === 'enterprise' && price === 0,
    billingModel: 'manual_v1',
    updatedAt: serverTime,
    updatedBy: owner.uid,
  }, { merge: true });
  batch.set(auditRef, {
    id: auditRef.id,
    ownerId: owner.uid,
    action: 'UPDATE_SUBSCRIPTION_PLAN_PRICING',
    schoolId: null,
    timestamp: serverTime,
    device: 'Platform Dashboard',
    metadata: { planId, price, billingCycle, termLengthDays },
  });
  await batch.commit();
  return { ok: true, planId, price, billingCycle, termLengthDays };
});

// Full plan editor: name, limits, features and visibility, in addition to
// the pricing/billing fields updateSubscriptionPlanPricing already covers.
exports.updateSubscriptionPlan = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);
  await ensureBillingDefaults();
  const planId = normalizedPlanId(request.data?.planId);
  if (!planId) throw new HttpsError('invalid-argument', 'planId is required.');

  const planRef = db.collection('subscription_plans').doc(planId);
  const snap = await planRef.get();
  if (!snap.exists) throw new HttpsError('not-found', 'Subscription plan not found.');

  const fields = parseAndValidatePlanFields(request.data, planId);
  // An archived plan can only be reactivated via reactivateSubscriptionPlan -
  // the generic editor can't silently un-archive it by passing isActive:true.
  const wasArchived = snap.data()?.isArchived === true;
  if (wasArchived) fields.isActive = false;

  const serverTime = admin.firestore.FieldValue.serverTimestamp();
  const auditRef = db.collection('super_admin_audit_logs').doc();
  const batch = db.batch();
  batch.set(planRef, {
    ...fields,
    billingModel: 'manual_v1',
    updatedAt: serverTime,
    updatedBy: owner.uid,
  }, { merge: true });
  batch.set(auditRef, {
    id: auditRef.id,
    ownerId: owner.uid,
    action: 'UPDATE_SUBSCRIPTION_PLAN',
    schoolId: null,
    timestamp: serverTime,
    device: 'Platform Dashboard',
    metadata: {
      planId,
      price: fields.price,
      billingCycle: fields.billingCycle,
      termLengthDays: fields.termLengthDays,
      isPublic: fields.isPublic,
      isActive: fields.isActive,
      isPopular: fields.isPopular,
      displayOrder: fields.displayOrder,
    },
  });
  await batch.commit();
  return { ok: true, planId };
});

// Creates a new catalog plan. Plan code (the Firestore doc id) is chosen by
// the caller at creation time and is immutable afterwards - there is no
// rename path, matching updateSubscriptionPlan which never touches the id.
exports.createSubscriptionPlan = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);
  await ensureBillingDefaults();

  const planId = text(request.data?.planId, 40).toLowerCase();
  if (!PLAN_CODE_RE.test(planId)) {
    throw new HttpsError(
      'invalid-argument',
      'Plan code must be lowercase letters, numbers, and underscores, 2-40 characters, starting with a letter.',
    );
  }

  const planRef = db.collection('subscription_plans').doc(planId);
  const existing = await planRef.get();
  if (existing.exists) throw new HttpsError('already-exists', 'A plan with this code already exists.');

  const fields = parseAndValidatePlanFields(request.data, planId);
  const serverTime = admin.firestore.FieldValue.serverTimestamp();
  const auditRef = db.collection('super_admin_audit_logs').doc();
  const batch = db.batch();
  batch.set(planRef, {
    ...fields,
    isArchived: false,
    isDefault: false,
    billingModel: 'manual_v1',
    createdAt: serverTime,
    createdBy: owner.uid,
    updatedAt: serverTime,
    updatedBy: owner.uid,
  });
  batch.set(auditRef, {
    id: auditRef.id,
    ownerId: owner.uid,
    action: 'CREATE_SUBSCRIPTION_PLAN',
    schoolId: null,
    timestamp: serverTime,
    device: 'Platform Dashboard',
    metadata: { planId, name: fields.name, price: fields.price },
  });
  await batch.commit();
  return { ok: true, planId };
});

// Archiving is a boolean flip, never a delete: existing school subscriptions
// reference the plan by id/price snapshot independently of the catalog doc
// (see getPlan()'s payment-time snapshot below), so nothing about an already
// subscribed school changes. isActive=false piggybacks on the existing
// isPublic && isActive gate in getPublicSubscriptionPlans, which is the only
// place new-subscription eligibility is enforced today.
exports.archiveSubscriptionPlan = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);
  const planId = normalizedPlanId(request.data?.planId);
  if (!planId) throw new HttpsError('invalid-argument', 'planId is required.');
  const planRef = db.collection('subscription_plans').doc(planId);
  const snap = await planRef.get();
  if (!snap.exists) throw new HttpsError('not-found', 'Subscription plan not found.');

  const serverTime = admin.firestore.FieldValue.serverTimestamp();
  const auditRef = db.collection('super_admin_audit_logs').doc();
  const batch = db.batch();
  batch.set(planRef, {
    isArchived: true,
    isActive: false,
    updatedAt: serverTime,
    updatedBy: owner.uid,
  }, { merge: true });
  batch.set(auditRef, {
    id: auditRef.id,
    ownerId: owner.uid,
    action: 'ARCHIVE_SUBSCRIPTION_PLAN',
    schoolId: null,
    timestamp: serverTime,
    device: 'Platform Dashboard',
    metadata: { planId },
  });
  await batch.commit();
  return { ok: true, planId };
});

exports.reactivateSubscriptionPlan = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);
  const planId = normalizedPlanId(request.data?.planId);
  if (!planId) throw new HttpsError('invalid-argument', 'planId is required.');
  const planRef = db.collection('subscription_plans').doc(planId);
  const snap = await planRef.get();
  if (!snap.exists) throw new HttpsError('not-found', 'Subscription plan not found.');

  const serverTime = admin.firestore.FieldValue.serverTimestamp();
  const auditRef = db.collection('super_admin_audit_logs').doc();
  const batch = db.batch();
  batch.set(planRef, {
    isArchived: false,
    isActive: true,
    updatedAt: serverTime,
    updatedBy: owner.uid,
  }, { merge: true });
  batch.set(auditRef, {
    id: auditRef.id,
    ownerId: owner.uid,
    action: 'REACTIVATE_SUBSCRIPTION_PLAN',
    schoolId: null,
    timestamp: serverTime,
    device: 'Platform Dashboard',
    metadata: { planId },
  });
  await batch.commit();
  return { ok: true, planId };
});

// Owner-scoped read/write for the manual payment method configuration
// (MTN MoMo / bank details schools use to pay). Distinct from
// getManualPaymentContext, which is gated to a school-admin subscriber
// identity and cannot be called by the SaaS owner.
exports.getManualPaymentConfig = onCall({ region: 'europe-west1' }, async (request) => {
  await requireOwner(request);
  const config = await getManualConfig();
  return {
    ok: true,
    currency: text(config.currency || 'UGX', 10),
    mobileMoney: {
      enabled: config.mobileMoney?.enabled !== false,
      network: text(config.mobileMoney?.network || 'MTN', 20),
      number: text(config.mobileMoney?.number, 30),
      accountName: text(config.mobileMoney?.accountName, 120),
    },
    airtelMoney: {
      enabled: config.airtelMoney?.enabled !== false,
      network: text(config.airtelMoney?.network || 'Airtel', 20),
      number: text(config.airtelMoney?.number, 30),
      accountName: text(config.airtelMoney?.accountName, 120),
    },
    bank: {
      enabled: config.bank?.enabled !== false,
      bankName: text(config.bank?.bankName, 120),
      branch: text(config.bank?.branch, 120),
      accountName: text(config.bank?.accountName, 120),
      accountNumber: text(config.bank?.accountNumber, 40),
    },
    cash: {
      enabled: config.cash?.enabled === true,
      instructions: text(config.cash?.instructions, 500),
    },
  };
});

exports.updateManualPaymentConfig = onCall({ region: 'europe-west1' }, async (request) => {
  const owner = await requireOwner(request);
  await ensureBillingDefaults();

  const mobileMoneyNumber = text(request.data?.mobileMoney?.number, 30);
  const mobileMoneyName = text(request.data?.mobileMoney?.accountName, 120);
  const airtelMoneyNumber = text(request.data?.airtelMoney?.number, 30);
  const airtelMoneyName = text(request.data?.airtelMoney?.accountName, 120);
  const bankName = text(request.data?.bank?.bankName, 120);
  const bankBranch = text(request.data?.bank?.branch, 120);
  const bankAccountName = text(request.data?.bank?.accountName, 120);
  const bankAccountNumber = text(request.data?.bank?.accountNumber, 40);
  const cashInstructions = text(request.data?.cash?.instructions, 500);
  const cashRequestedEnabled = request.data?.cash?.enabled === true;

  if ((mobileMoneyNumber || mobileMoneyName) && (!mobileMoneyNumber || !mobileMoneyName)) {
    throw new HttpsError('invalid-argument', 'MTN Mobile Money number and account name are both required.');
  }
  if ((airtelMoneyNumber || airtelMoneyName) && (!airtelMoneyNumber || !airtelMoneyName)) {
    throw new HttpsError('invalid-argument', 'Airtel Money number and account name are both required.');
  }
  if ((bankName || bankAccountName || bankAccountNumber) && (!bankName || !bankAccountName || !bankAccountNumber)) {
    throw new HttpsError('invalid-argument', 'Bank name, account name and account number are all required.');
  }
  if (cashRequestedEnabled && !cashInstructions) {
    throw new HttpsError('invalid-argument', 'Cash payment instructions are required to enable cash payments.');
  }
  if (!mobileMoneyNumber && !airtelMoneyNumber && !bankAccountNumber && !cashRequestedEnabled) {
    throw new HttpsError('invalid-argument', 'At least one payment method must be configured.');
  }

  const configRef = db.collection('platform_billing_config').doc('manual');
  const serverTime = admin.firestore.FieldValue.serverTimestamp();
  const auditRef = db.collection('super_admin_audit_logs').doc();
  const batch = db.batch();
  batch.set(configRef, {
    mobileMoney: {
      enabled: Boolean(mobileMoneyNumber && mobileMoneyName),
      network: 'MTN',
      number: mobileMoneyNumber,
      accountName: mobileMoneyName,
    },
    airtelMoney: {
      enabled: Boolean(airtelMoneyNumber && airtelMoneyName),
      network: 'Airtel',
      number: airtelMoneyNumber,
      accountName: airtelMoneyName,
    },
    bank: {
      enabled: Boolean(bankName && bankAccountName && bankAccountNumber),
      bankName,
      branch: bankBranch,
      accountName: bankAccountName,
      accountNumber: bankAccountNumber,
    },
    cash: {
      enabled: cashRequestedEnabled,
      instructions: cashInstructions,
    },
    updatedAt: serverTime,
    updatedBy: owner.uid,
  }, { merge: true });
  batch.set(auditRef, {
    id: auditRef.id,
    ownerId: owner.uid,
    action: 'UPDATE_MANUAL_PAYMENT_CONFIG',
    schoolId: null,
    timestamp: serverTime,
    device: 'Platform Dashboard',
    metadata: {
      mtnEnabled: Boolean(mobileMoneyNumber && mobileMoneyName),
      airtelEnabled: Boolean(airtelMoneyNumber && airtelMoneyName),
      bankEnabled: Boolean(bankName && bankAccountName && bankAccountNumber),
      cashEnabled: cashRequestedEnabled,
    },
  });
  await batch.commit();
  return { ok: true };
});

async function schoolAdminEmail(schoolId) {
  const snap = await db.collection('users')
    .where('schoolId', '==', schoolId)
    .where('role', '==', 'schoolAdmin')
    .limit(1)
    .get();
  if (snap.empty) return '';
  return text(snap.docs[0].data()?.email, 200);
}

// Additive escape hatch: lets other modules in this codebase (e.g.
// mtn_momo.js) reuse tenant-resolution/formatting helpers instead of
// forking a second copy. Does not change any existing export above.
module.exports.__internal = {
  text,
  asIso,
  resolveSubscriber,
  subscriberCanManagePayment,
  schoolAdminEmail,
  getPlan,
  normalizedModuleList,
  parseAndValidatePlanFields,
  PLAN_CODE_RE,
  ALLOWED_PLAN_MODULE_KEYS,
  paymentsQueryFilters,
};
