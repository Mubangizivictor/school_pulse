#!/usr/bin/env node
/**
 * QA-only, ADDITIVE seed for the Super Admin "Enrolled School" workspace.
 *
 * Target: LOCAL FIREBASE EMULATOR ONLY (project school-pulse-qa). This
 * script refuses to run unless FIRESTORE_EMULATOR_HOST and
 * FIREBASE_AUTH_EMULATOR_HOST are both set, as a hard safety guard against
 * ever touching the real school-pulse-3d95b project.
 *
 * Schemas used here were confirmed by grepping the real app/functions
 * source before writing this file - see the QA report for citations:
 *   - schools/{id}                              (existing seed script's shape)
 *   - schools/{id}/module_configuration/{key}    (ModuleControlRepository)
 *   - schools/{id}/module_policy_audit           (ModuleControlRepository.setModuleEnabled)
 *   - institutions/{id}/support_access_requests  (SupportAccessService)
 *   - school_admin_invitations                   (SchoolAdminManagementService.inviteAdmin)
 *   - manual_subscription_payments                (existing seed script; ManualPaymentStatus)
 *   - super_admin_audit_logs                      (public_functions/*.js lifecycle/module/admin actions)
 *   - users/{uid} + institution_memberships/{uid}_{schoolId}
 *
 * Safe to re-run: every school is looked up by slug first and skipped if
 * already seeded (same pattern as functions/scripts/seed_demo_schools_for_workspace_review.js).
 *
 * Run (from repo root), with the emulator suite already running:
 *   FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 \
 *   FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 \
 *   GCLOUD_PROJECT=school-pulse-qa \
 *   node qa_artifacts/seed_qa_enrolled_school_dataset.js
 */
const admin = require('firebase-admin');
const { randomUUID } = require('crypto');

const PROJECT_ID = 'school-pulse-qa';

if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) {
  console.error(
    'Refusing to run: FIRESTORE_EMULATOR_HOST and FIREBASE_AUTH_EMULATOR_HOST must both be set ' +
    'to point this script at the local emulator. This script must never run against a real project.'
  );
  process.exit(1);
}

admin.initializeApp({ projectId: PROJECT_ID });
const db = admin.firestore();
const auth = admin.auth();

const SEED_MARKER = 'qa-enrolled-school-review';
const now = Date.now();
const DAY = 24 * 60 * 60 * 1000;
const ts = admin.firestore.Timestamp.fromMillis;

const MODULE_KEYS_ENTITLED = ['students', 'staff', 'parents', 'structure', 'attendance', 'finance', 'assessments', 'reports', 'messaging', 'appointments', 'library'];

async function findBySlug(slug) {
  const snap = await db.collection('schools').where('slug', '==', slug).limit(1).get();
  return snap.empty ? null : snap.docs[0];
}

async function ensureAuthUser(email, password, displayName) {
  try {
    const rec = await auth.getUserByEmail(email);
    return rec.uid;
  } catch (e) {
    if (e.code !== 'auth/user-not-found') throw e;
  }
  const rec = await auth.createUser({ email, password, displayName, emailVerified: true });
  return rec.uid;
}

async function seedOwnerB() {
  const email = 'owner-b.qa@schoolpulse.invalid';
  const uid = await ensureAuthUser(email, 'Test@123', 'QA Owner B');
  await auth.setCustomUserClaims(uid, { role: 'superAdmin' });
  await db.collection('users').doc(uid).set({
    name: 'QA Owner B',
    email,
    role: 'superAdmin',
    roles: ['superAdmin'],
    schoolId: null,
    studentIds: [],
    mustChangePassword: false,
    metadata: { seedMarker: SEED_MARKER },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
  console.log(`  + Owner B: ${email} (uid=${uid}) - use for owner-isolation checks`);
  return uid;
}

async function seedModules(schoolId, actorId, opts) {
  const { allEntitled = true, disabledKeys = [] } = opts;
  for (const key of MODULE_KEYS_ENTITLED) {
    const entitled = allEntitled;
    const enabled = entitled && !disabledKeys.includes(key);
    await db.collection('schools').doc(schoolId).collection('module_configuration').doc(key).set({
      institutionId: schoolId,
      moduleKey: key,
      entitled,
      enabled,
      setupStatus: enabled ? 'completed' : 'notStarted',
      configurationVersion: 1,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedBy: actorId,
      reason: 'QA seed initial configuration',
      metadata: { seedMarker: SEED_MARKER },
    }, { merge: true });
  }
  // A couple of audit entries showing real lifecycle (enable then disable) for one module.
  const auditCol = db.collection('schools').doc(schoolId).collection('module_policy_audit');
  await auditCol.add({
    action: 'module_enabled',
    moduleKey: 'finance',
    actorId,
    reason: 'QA seed: initial enablement',
    previousValue: false,
    newValue: true,
    timestamp: ts(now - 20 * DAY),
    metadata: { seedMarker: SEED_MARKER },
  });
  if (disabledKeys.includes('library')) {
    await auditCol.add({
      action: 'module_disabled',
      moduleKey: 'library',
      actorId,
      reason: 'QA seed: disabled for review',
      previousValue: true,
      newValue: false,
      timestamp: ts(now - 5 * DAY),
      metadata: { seedMarker: SEED_MARKER },
    });
  }
}

async function seedSupportRequests(schoolId, ownerUid) {
  const col = db.collection('institutions').doc(schoolId).collection('support_access_requests');
  const fixtures = [
    { status: 'pending', reason: 'Investigating parent-reported grade sync issue', ageDays: 1 },
    { status: 'active', reason: 'Assisting with subscription renewal', ageDays: 0, expiresInHours: 4 },
    { status: 'expired', reason: 'Prior investigation, session lapsed', ageDays: 10, expiredDaysAgo: 9 },
    { status: 'revoked', reason: 'Support session ended early by owner', ageDays: 7 },
    { status: 'rejected', reason: 'School admin declined access', ageDays: 3 },
  ];
  for (const f of fixtures) {
    const ref = col.doc();
    await ref.set({
      institutionId: schoolId,
      status: f.status,
      reason: f.reason,
      requestedByPlatformUser: ownerUid,
      createdAt: ts(now - f.ageDays * DAY),
      expiresAt: f.expiresInHours
        ? ts(now + f.expiresInHours * 60 * 60 * 1000)
        : f.expiredDaysAgo
          ? ts(now - f.expiredDaysAgo * DAY)
          : null,
      metadata: { seedMarker: SEED_MARKER },
    });
  }
  console.log(`    + ${fixtures.length} support_access_requests (pending/active/expired/revoked/rejected)`);
}

async function seedAdminInvitation(schoolId, tenantId, email) {
  await db.collection('school_admin_invitations').add({
    email,
    schoolId,
    tenantId,
    tempPassword: randomUUID().slice(0, 14),
    status: 'pending',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    metadata: { seedMarker: SEED_MARKER },
  });
  console.log(`    + school_admin_invitations pending: ${email}`);
}

async function seedAuditLogs(schoolId, ownerUid, schoolName) {
  const col = db.collection('super_admin_audit_logs');
  const entries = [
    { action: 'SCHOOL_SUSPENDED', daysAgo: 15 },
    { action: 'SCHOOL_REACTIVATED', daysAgo: 14 },
    { action: 'MANAGE_SCHOOL_ADMIN_SET_PRIMARY', daysAgo: 8 },
    { action: 'PAYMENT_APPROVED', daysAgo: 30 },
  ];
  for (const e of entries) {
    await col.add({
      action: e.action,
      schoolId,
      schoolName,
      ownerId: ownerUid,
      timestamp: ts(now - e.daysAgo * DAY),
      metadata: { seedMarker: SEED_MARKER },
    });
  }
  console.log(`    + ${entries.length} super_admin_audit_logs entries`);
}

async function seedTenant(spec, ownerUid) {
  const existing = await findBySlug(spec.slug);
  let schoolId;
  if (existing) {
    schoolId = existing.id;
    console.log(`  = ${spec.name} already seeded (schools/${schoolId}), reusing for sub-collections.`);
  } else {
    const ref = db.collection('schools').doc();
    schoolId = ref.id;
    await ref.set({
      id: schoolId,
      name: spec.name,
      tenantId: spec.tenantId,
      slug: spec.slug,
      address: spec.address,
      contactEmail: spec.contactEmail,
      contactPhone: spec.contactPhone,
      status: spec.status,
      subscriptionPlanId: spec.subscriptionPlanId,
      createdAt: now - 200 * DAY,
      subscriptionExpiry: now + spec.subscriptionExpiryOffsetDays * DAY,
      enabledFeatures: [],
      metadata: { seedMarker: SEED_MARKER, studentCount: spec.students, staffCount: spec.staff },
      classification: 'secondary',
      divisions: [],
      portalSubdomain: '',
      customDomains: [],
      branding: {},
      domainStatus: 'pending',
    });
    console.log(`  + schools/${schoolId}  ${spec.name} (${spec.status})`);
  }

  if (spec.students > 0) {
    const sample = Math.min(spec.students, 12);
    for (let i = 0; i < sample; i += 1) {
      await db.collection('students').doc().set({
        schoolId,
        status: i % 5 === 0 ? 'inactive' : 'active',
        name: `QA Student ${i + 1} (${spec.tenantId})`,
        metadata: { seedMarker: SEED_MARKER },
      });
    }
  }
  if (spec.staff > 0) {
    const sample = Math.min(spec.staff, 6);
    for (let i = 0; i < sample; i += 1) {
      await db.collection('users').doc().set({
        name: `QA Teacher ${i + 1} (${spec.tenantId})`,
        email: `qa.teacher${i + 1}.${spec.slug}@example.invalid`,
        role: 'classTeacher',
        roles: ['classTeacher'],
        schoolId,
        isActive: i % 4 !== 0,
        metadata: { seedMarker: SEED_MARKER },
      });
    }
  }

  for (const a of spec.admins || []) {
    const adminRef = db.collection('users').doc();
    await adminRef.set({
      name: a.name,
      email: a.email,
      role: 'schoolAdmin',
      roles: ['schoolAdmin'],
      schoolId,
      isActive: a.isActive !== false,
      isPrimaryAdmin: a.primary,
      mfaEnabled: !!a.mfaEnabled,
      lastSignInAt: ts(now - 3 * DAY),
      metadata: { seedMarker: SEED_MARKER },
    });
    await db.doc(`institution_memberships/${adminRef.id}_${schoolId}`).set({
      userId: adminRef.id,
      institutionId: schoolId,
      isPrimaryAdmin: a.primary,
      status: a.isActive === false ? 'disabled' : 'active',
      roles: ['schoolAdmin'],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`    + admin ${a.name} <${a.email}> primary=${a.primary}`);
  }

  for (const p of spec.payments || []) {
    const ref = db.collection('manual_subscription_payments').doc();
    await ref.set({
      id: ref.id,
      schoolId,
      schoolName: spec.name,
      planId: spec.subscriptionPlanId,
      planName: spec.subscriptionPlanId,
      paymentType: 'renewal',
      expectedAmount: p.amount,
      submittedAmount: p.amount,
      currency: 'UGX',
      method: 'mtn',
      payerName: spec.admins?.[0]?.name || spec.name,
      reference: `QA-${randomUUID().slice(0, 8).toUpperCase()}`,
      paidAt: ts(now - p.daysAgo * DAY),
      submittedAt: ts(now - p.daysAgo * DAY),
      status: p.status, // real ManualPaymentStatus wire values only
      hasProof: false,
      metadata: { seedMarker: SEED_MARKER },
    });
    console.log(`    + payment ${p.amount} UGX (${p.status})`);
  }

  if (spec.seedModules) {
    await seedModules(schoolId, ownerUid, spec.moduleOpts || {});
    console.log('    + module_configuration + module_policy_audit seeded');
  }
  if (spec.seedSupport) {
    await seedSupportRequests(schoolId, ownerUid);
  }
  if (spec.seedInvitation) {
    await seedAdminInvitation(schoolId, spec.tenantId, spec.invitationEmail);
  }
  if (spec.seedAuditLogs) {
    await seedAuditLogs(schoolId, ownerUid, spec.name);
  }

  return schoolId;
}

const TENANTS = [
  {
    slug: 'greenhill-academy-qa',
    name: 'Greenhill Academy',
    tenantId: 'GREENQA',
    address: 'Kampala, Uganda',
    contactEmail: 'admin@greenhillacademy-qa.invalid',
    contactPhone: '+256700111222',
    status: 'active',
    subscriptionPlanId: 'enterprise',
    subscriptionExpiryOffsetDays: 210,
    students: 1240,
    staff: 68,
    admins: [
      { name: 'Sarah Nakato', email: 'sarah.nakato@greenhillacademy-qa.invalid', primary: true, mfaEnabled: true },
      { name: 'James Okello', email: 'james.okello@greenhillacademy-qa.invalid', primary: false, mfaEnabled: false },
    ],
    payments: [
      { amount: 350000, status: 'approved', daysAgo: 30 },
      { amount: 350000, status: 'pending_verification', daysAgo: 2 },
      { amount: 350000, status: 'rejected', daysAgo: 60 },
    ],
    seedModules: true,
    moduleOpts: { allEntitled: true, disabledKeys: ['library'] },
    seedSupport: true,
    seedInvitation: true,
    invitationEmail: 'new.admin@greenhillacademy-qa.invalid',
    seedAuditLogs: true,
  },
  {
    slug: 'lakeside-high-qa',
    name: 'Lakeside High',
    tenantId: 'LAKEQA',
    address: 'Entebbe, Uganda',
    contactEmail: 'admin@lakesidehigh-qa.invalid',
    contactPhone: '+256700999888',
    status: 'active',
    subscriptionPlanId: 'growth',
    subscriptionExpiryOffsetDays: 45,
    students: 560,
    staff: 34,
    admins: [
      { name: 'Alice Namuli', email: 'alice.namuli@lakesidehigh-qa.invalid', primary: true, mfaEnabled: false },
    ],
    payments: [
      { amount: 220000, status: 'approved', daysAgo: 15 },
    ],
    seedModules: true,
    moduleOpts: { allEntitled: true, disabledKeys: [] },
    seedSupport: true,
    seedInvitation: false,
    seedAuditLogs: true,
  },
  {
    slug: 'suspended-school-qa',
    name: 'Kololo Junior School (Suspended, QA)',
    tenantId: 'SUSPQA',
    address: 'Kampala, Uganda',
    contactEmail: 'admin@kolojunior-qa.invalid',
    contactPhone: '+256700222333',
    status: 'suspended',
    subscriptionPlanId: 'starter',
    subscriptionExpiryOffsetDays: -20,
    students: 210,
    staff: 14,
    admins: [
      { name: 'Peter Mugisha', email: 'peter.mugisha@kolojunior-qa.invalid', primary: true, mfaEnabled: true },
    ],
    payments: [
      { amount: 90000, status: 'approved', daysAgo: 90 },
    ],
    seedModules: true,
    moduleOpts: { allEntitled: true, disabledKeys: [] },
    seedSupport: false,
    seedInvitation: false,
    seedAuditLogs: true,
  },
  {
    slug: 'archived-school-qa',
    name: 'Old Mbarara Academy (Archived, QA)',
    tenantId: 'ARCHQA',
    address: 'Mbarara, Uganda',
    contactEmail: 'admin@oldmbarara-qa.invalid',
    contactPhone: '+256700444555',
    status: 'archived',
    subscriptionPlanId: 'starter',
    subscriptionExpiryOffsetDays: -400,
    students: 0,
    staff: 0,
    admins: [],
    payments: [],
    seedModules: false,
    seedSupport: false,
    seedInvitation: false,
    seedAuditLogs: true,
  },
  {
    slug: 'no-payments-school-qa',
    name: 'Fresh Onboard School (No Payments, QA)',
    tenantId: 'FRESHQA',
    address: 'Gulu, Uganda',
    contactEmail: 'admin@freshonboard-qa.invalid',
    contactPhone: '+256700666777',
    status: 'trial',
    subscriptionPlanId: 'starter',
    subscriptionExpiryOffsetDays: 12,
    students: 40,
    staff: 4,
    admins: [
      { name: 'Grace Achieng', email: 'grace.achieng@freshonboard-qa.invalid', primary: true, mfaEnabled: false },
    ],
    payments: [],
    seedModules: true,
    moduleOpts: { allEntitled: false, disabledKeys: [] }, // no plan entitlements yet
    seedSupport: false,
    seedInvitation: false,
    seedAuditLogs: false,
  },
  {
    slug: 'missing-counts-school-qa',
    name: 'No Metadata Counts School (QA)',
    tenantId: 'NOCOUNTQA',
    address: 'Unknown',
    contactEmail: 'admin@nocounts-qa.invalid',
    contactPhone: '+256700000000',
    status: 'active',
    subscriptionPlanId: 'starter',
    subscriptionExpiryOffsetDays: 100,
    students: 0, // intentionally no student docs seeded -> counts query returns 0/empty
    staff: 0,
    admins: [
      { name: 'Unnamed Admin', email: 'admin@nocounts-qa.invalid', primary: true, mfaEnabled: false },
    ],
    payments: [],
    seedModules: false,
    seedSupport: false,
    seedInvitation: false,
    seedAuditLogs: false,
  },
];

async function main() {
  console.log(`Seeding QA "Enrolled School" workspace dataset into ${PROJECT_ID} (emulator)...\n`);
  const ownerBUid = await seedOwnerB();
  const ids = {};
  for (const spec of TENANTS) {
    ids[spec.slug] = await seedTenant(spec, ownerBUid);
  }
  console.log('\nDone. School ids:');
  console.log(JSON.stringify(ids, null, 2));
  console.log(`\nOwner B uid: ${ownerBUid} (email owner-b.qa@schoolpulse.invalid / password Test@123)`);
}

main().catch((err) => {
  console.error('QA seed failed:', err);
  process.exit(1);
});
