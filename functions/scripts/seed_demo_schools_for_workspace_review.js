/**
 * One-off, additive seed: creates 3 demo schools (varying status/plan) plus
 * a few students, staff, schoolAdmins, and manual payments for each, so the
 * new Enrolled School Detail workspace (Overview/Subscription/Payments/
 * Modules/School Admins screens) has real data to show mubangizivic@gmail.com
 * (the already-seeded platform owner) in the Super Admin app.
 *
 * Only CREATES new documents with fresh ids under a "demo-workspace-review"
 * marker in each school's metadata - never touches the owner account, any
 * existing school, or any other collection. Safe to re-run: skips creation
 * if a school with the same slug already exists.
 *
 * Run: node scripts/seed_demo_schools_for_workspace_review.js   (from functions/)
 */
const admin = require('firebase-admin');
const { randomUUID } = require('crypto');

admin.initializeApp({ projectId: 'school-pulse-3d95b' });
const db = admin.firestore();

const SEED_MARKER = 'demo-workspace-review';
const now = Date.now();
const DAY = 24 * 60 * 60 * 1000;

const SCHOOLS = [
  {
    slug: 'greenhill-academy-demo',
    name: 'Greenhill Academy',
    tenantId: 'GREEN',
    address: 'Kampala, Uganda',
    contactEmail: 'admin@greenhillacademy.ug',
    contactPhone: '+256700111222',
    status: 'active',
    subscriptionPlanId: 'enterprise',
    subscriptionExpiryOffsetDays: 199,
    students: 1240,
    staff: 68,
    admins: [
      { name: 'Sarah Nakato', email: 'sarah.nakato@greenhillacademy.ug', primary: true, mfaEnabled: true },
      { name: 'James Okello', email: 'james.okello@greenhillacademy.ug', primary: false, mfaEnabled: false },
    ],
    payments: [
      { amount: 350000, status: 'approved', daysAgo: 30 },
      { amount: 350000, status: 'pending_verification', daysAgo: 2 },
    ],
  },
  {
    slug: 'riverside-primary-demo',
    name: 'Riverside Primary School',
    tenantId: 'RIVER',
    address: 'Jinja, Uganda',
    contactEmail: 'office@riversideprimary.ug',
    contactPhone: '+256700333444',
    status: 'trial',
    subscriptionPlanId: 'starter',
    subscriptionExpiryOffsetDays: 9,
    students: 340,
    staff: 22,
    admins: [
      { name: 'Grace Achieng', email: 'grace.achieng@riversideprimary.ug', primary: true, mfaEnabled: false },
    ],
    payments: [
      { amount: 150000, status: 'rejected', daysAgo: 5 },
    ],
  },
  {
    slug: 'st-augustine-college-demo',
    name: "St. Augustine's College",
    tenantId: 'AUGCOL',
    address: 'Mbarara, Uganda',
    contactEmail: 'registrar@staugustinecollege.ug',
    contactPhone: '+256700555666',
    status: 'suspended',
    subscriptionPlanId: 'growth',
    subscriptionExpiryOffsetDays: -14,
    students: 812,
    staff: 51,
    admins: [
      { name: 'Peter Mugisha', email: 'peter.mugisha@staugustinecollege.ug', primary: true, mfaEnabled: true },
    ],
    payments: [
      { amount: 220000, status: 'approved', daysAgo: 60 },
    ],
  },
];

async function alreadySeeded(slug) {
  const snap = await db.collection('schools').where('slug', '==', slug).limit(1).get();
  return snap.empty ? null : snap.docs[0];
}

async function seedSchool(spec) {
  const existing = await alreadySeeded(spec.slug);
  if (existing) {
    console.log(`  = ${spec.name} already seeded (schools/${existing.id}), skipping.`);
    return existing.id;
  }

  const schoolRef = db.collection('schools').doc();
  await schoolRef.set({
    id: schoolRef.id,
    name: spec.name,
    tenantId: spec.tenantId,
    slug: spec.slug,
    address: spec.address,
    contactEmail: spec.contactEmail,
    contactPhone: spec.contactPhone,
    status: spec.status,
    subscriptionPlanId: spec.subscriptionPlanId,
    createdAt: now - 120 * DAY,
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
  console.log(`  + schools/${schoolRef.id}  ${spec.name}`);

  // Students: enough active/enrolled docs to make getSchoolCounts return a
  // real, non-trivial number without seeding a full thousand-row dataset.
  const studentSampleSize = Math.min(spec.students, 12);
  for (let i = 0; i < studentSampleSize; i += 1) {
    await db.collection('students').doc().set({
      schoolId: schoolRef.id,
      status: i % 4 === 0 ? 'enrolled' : 'active',
      name: `Demo Student ${i + 1}`,
      metadata: { seedMarker: SEED_MARKER },
    });
  }

  // Staff (non-admin), plus the schoolAdmin accounts below.
  const staffSampleSize = Math.min(spec.staff, 6);
  for (let i = 0; i < staffSampleSize; i += 1) {
    await db.collection('users').doc().set({
      name: `Demo Teacher ${i + 1}`,
      email: `demo.teacher${i + 1}.${spec.slug}@example.invalid`,
      role: 'classTeacher',
      roles: ['classTeacher'],
      schoolId: schoolRef.id,
      isActive: true,
      metadata: { seedMarker: SEED_MARKER },
    });
  }

  for (const admin_ of spec.admins) {
    const adminRef = db.collection('users').doc();
    await adminRef.set({
      name: admin_.name,
      email: admin_.email,
      role: 'schoolAdmin',
      roles: ['schoolAdmin'],
      schoolId: schoolRef.id,
      isActive: true,
      isPrimaryAdmin: admin_.primary,
      mfaEnabled: admin_.mfaEnabled,
      lastSignInAt: admin.firestore.Timestamp.fromMillis(now - 3 * DAY),
      metadata: { seedMarker: SEED_MARKER },
    });
    await db.doc(`institution_memberships/${adminRef.id}_${schoolRef.id}`).set({
      userId: adminRef.id,
      institutionId: schoolRef.id,
      isPrimaryAdmin: admin_.primary,
      status: 'active',
      roles: ['schoolAdmin'],
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`    + admin ${admin_.name} <${admin_.email}>`);
  }

  for (const payment of spec.payments) {
    const paymentRef = db.collection('manual_subscription_payments').doc();
    await paymentRef.set({
      id: paymentRef.id,
      schoolId: schoolRef.id,
      schoolName: spec.name,
      planId: spec.subscriptionPlanId,
      planName: spec.subscriptionPlanId,
      paymentType: 'renewal',
      expectedAmount: payment.amount,
      submittedAmount: payment.amount,
      currency: 'UGX',
      method: 'mtn',
      payerName: spec.admins[0]?.name || spec.name,
      reference: `DEMO-${randomUUID().slice(0, 8).toUpperCase()}`,
      paidAt: admin.firestore.Timestamp.fromMillis(now - payment.daysAgo * DAY),
      submittedAt: admin.firestore.Timestamp.fromMillis(now - payment.daysAgo * DAY),
      status: payment.status,
      hasProof: false,
      metadata: { seedMarker: SEED_MARKER },
    });
    console.log(`    + payment ${payment.amount} UGX (${payment.status})`);
  }

  return schoolRef.id;
}

async function main() {
  console.log(`Seeding ${SCHOOLS.length} demo schools into school-pulse-3d95b for workspace review...\n`);
  for (const spec of SCHOOLS) {
    await seedSchool(spec);
  }
  console.log('\nDone. Open the Super Admin app as mubangizivic@gmail.com and check Schools.');
}

main().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
