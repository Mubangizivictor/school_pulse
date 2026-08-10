const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

// Use the Firebase Hosting URL as the reliable app fallback. Once the
// app.schoolpulse.victorbee.com custom domain is verified on this same
// Hosting site, we can switch this constant without changing tenant data.
const APP_URL = 'https://school-pulse-3d95b.web.app';
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
const ALLOWED_PLANS = new Set(['Starter', 'Growth', 'Pro', 'Enterprise']);

function text(value, max = 200) {
  return String(value ?? '').trim().slice(0, max);
}

function asIso(value) {
  if (!value) return null;
  if (typeof value.toDate === 'function') return value.toDate().toISOString();
  if (value instanceof Date) return value.toISOString();
  return null;
}

function normalizedModules(value) {
  const requested = Array.isArray(value) ? value : [];
  const selected = new Set([...CORE_MODULES, ...requested.map((item) => text(item, 50))]);
  return [...selected]
    .map((name) => MODULE_MAP[name])
    .filter(Boolean);
}

function normalizedPlan(value) {
  const plan = text(value, 40);
  if (!ALLOWED_PLANS.has(plan)) return 'starter';
  return plan.toLowerCase();
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

async function requireOwner(request) {
  if (!request.auth?.uid) {
    throw new HttpsError('unauthenticated', 'You must be signed in as the School Pulse owner.');
  }
  const ownerDoc = await db.collection('users').doc(request.auth.uid).get();
  const owner = ownerDoc.exists ? ownerDoc.data() : null;
  if (!owner || owner.role !== 'superAdmin' || owner.isActive === false) {
    throw new HttpsError('permission-denied', 'Only the seeded School Pulse platform owner can review school applications.');
  }
  return { uid: request.auth.uid, profile: owner };
}

function applicationForClient(doc) {
  const data = doc.data() || {};
  return {
    ...data,
    id: data.id || doc.id,
    createdAt: asIso(data.createdAt),
    updatedAt: asIso(data.updatedAt),
    reviewedAt: asIso(data.reviewedAt),
    termsAcceptedAt: asIso(data.termsAcceptedAt),
    lastStatusCheckAt: asIso(data.lastStatusCheckAt),
  };
}

exports.getSchoolApplicationsForOwner = onCall(
  { region: 'europe-west1' },
  async (request) => {
    await requireOwner(request);
    const snapshot = await db
      .collection('public_school_applications')
      .orderBy('createdAt', 'desc')
      .limit(250)
      .get();
    return {
      applications: snapshot.docs.map(applicationForClient),
    };
  },
);

exports.approveSchoolApplication = onCall(
  { region: 'europe-west1' },
  async (request) => {
    const owner = await requireOwner(request);
    const applicationId = text(request.data?.applicationId, 160);
    if (!applicationId) {
      throw new HttpsError('invalid-argument', 'applicationId is required.');
    }

    const applicationRef = db.collection('public_school_applications').doc(applicationId);
    const applicationSnap = await applicationRef.get();
    if (!applicationSnap.exists) {
      throw new HttpsError('not-found', 'School application not found.');
    }

    const application = applicationSnap.data() || {};
    if (application.status === 'approved' && application.schoolId) {
      return { ok: true, schoolId: application.schoolId, alreadyApproved: true };
    }
    if (application.status !== 'pending_review') {
      throw new HttpsError(
        'failed-precondition',
        `Only pending applications can be approved. Current status: ${application.status || 'unknown'}.`,
      );
    }
    if (application.termsAccepted !== true) {
      throw new HttpsError('failed-precondition', 'The applicant has not accepted the School Pulse terms.');
    }

    const applicantUid = text(application.authUid || application.id || applicationId, 160);
    let authUser;
    try {
      authUser = await admin.auth().getUser(applicantUid);
    } catch (error) {
      throw new HttpsError('failed-precondition', 'The applicant Firebase account no longer exists.');
    }
    if (!authUser.emailVerified) {
      throw new HttpsError('failed-precondition', 'The applicant email must be verified before approval.');
    }

    const school = application.school || {};
    const location = application.location || {};
    const administrator = application.administrator || {};
    const schoolName = text(school.name, 160);
    const prefix = text(school.prefix, 12).toUpperCase().replace(/[^A-Z0-9]/g, '');
    const adminEmail = text(administrator.email || authUser.email, 160).toLowerCase();
    if (!schoolName || !prefix || !adminEmail) {
      throw new HttpsError('failed-precondition', 'The application is missing school or administrator identity fields.');
    }
    if ((authUser.email || '').toLowerCase() !== adminEmail) {
      throw new HttpsError('failed-precondition', 'The verified account does not match the submitted administrator email.');
    }

    const existingPrefix = await db
      .collection('schools')
      .where('tenantId', '==', prefix)
      .limit(1)
      .get();
    const deterministicSchoolId = application.schoolId || `sch_${prefix.toLowerCase()}_${applicantUid.slice(0, 8)}`;
    if (!existingPrefix.empty && existingPrefix.docs[0].id !== deterministicSchoolId) {
      throw new HttpsError('already-exists', `School prefix ${prefix} is already assigned to another institution.`);
    }

    const nowMs = Date.now();
    const expiryMs = nowMs + 365 * 24 * 60 * 60 * 1000;
    const enabledFeatures = normalizedModules(application.selectedModules);
    const subscriptionPlanId = normalizedPlan(application.plan);
    const schoolId = deterministicSchoolId;
    const administratorName = `${text(administrator.firstName, 100)} ${text(administrator.lastName, 100)}`.trim() || authUser.displayName || 'School Administrator';
    const schoolPhone = text(school.phone, 30);
    const schoolEmail = text(school.email, 160).toLowerCase();
    const address = [text(location.address, 240), text(location.district, 100), text(location.region, 40)]
      .filter(Boolean)
      .join(', ');

    const schoolRef = db.collection('schools').doc(schoolId);
    const existingSchool = await schoolRef.get();
    if (existingSchool.exists) {
      const sourceApplicationId = text(existingSchool.data()?.metadata?.applicationId, 160);
      if (sourceApplicationId !== applicationId) {
        throw new HttpsError(
          'already-exists',
          'The generated school identity is already used by a different tenant. Review the school prefix before approving.',
        );
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
      contactEmail: schoolEmail,
      contactPhone: schoolPhone,
      status: 'active',
      subscriptionPlanId,
      createdAt: nowMs,
      subscriptionExpiry: expiryMs,
      enabledFeatures,
      metadata: {
        source: 'public_website_application',
        applicationId,
        category: text(school.category, 80),
        motto: text(school.motto, 180),
        website: text(location.website, 240),
        region: text(location.region, 40),
        district: text(location.district, 100),
        selectedPlanLabel: text(application.plan, 40),
        selectedModules: Array.isArray(application.selectedModules) ? application.selectedModules : CORE_MODULES,
        subscriptionStatus: 'active',
        approvedBy: owner.uid,
        approvedAt: nowMs,
      },
      classification: schoolClassification(school.category),
      classificationOther: null,
      divisions: [],
      displayLabel: text(school.shortName, 40) || schoolName,
    };

    const batch = db.batch();
    batch.set(schoolRef, schoolData, { merge: false });
    batch.set(
      userRef,
      {
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
      },
      { merge: true },
    );
    batch.set(
      contactRef,
      {
        name: administratorName,
        role: 'schoolAdmin',
        roles: ['schoolAdmin'],
        schoolId,
        isActive: true,
        phone: text(administrator.phone, 30),
      },
      { merge: true },
    );
    batch.set(
      membershipRef,
      {
        id: `${applicantUid}_${schoolId}`,
        userId: applicantUid,
        institutionId: schoolId,
        schoolId,
        role: 'schoolAdmin',
        roles: ['schoolAdmin'],
        status: 'active',
        createdAt: serverTime,
        createdBy: owner.uid,
      },
      { merge: true },
    );
    batch.set(
      applicationRef,
      {
        status: 'approved',
        schoolId,
        appReady: true,
        appUrl: APP_URL,
        reviewedAt: serverTime,
        reviewedBy: owner.uid,
        rejectionReason: admin.firestore.FieldValue.delete(),
        updatedAt: serverTime,
      },
      { merge: true },
    );
    batch.set(auditRef, {
      id: auditRef.id,
      ownerId: owner.uid,
      action: 'APPROVE_SCHOOL_APPLICATION',
      schoolId,
      affectedUserId: applicantUid,
      timestamp: serverTime,
      device: 'Platform Dashboard',
      metadata: {
        applicationId,
        schoolName,
        planId: subscriptionPlanId,
        enabledFeatures,
      },
    });

    await batch.commit();

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

    return { ok: true, schoolId, status: 'approved' };
  },
);

exports.rejectSchoolApplication = onCall(
  { region: 'europe-west1' },
  async (request) => {
    const owner = await requireOwner(request);
    const applicationId = text(request.data?.applicationId, 160);
    const reason = text(request.data?.reason, 500);
    if (!applicationId) {
      throw new HttpsError('invalid-argument', 'applicationId is required.');
    }
    if (reason.length < 3) {
      throw new HttpsError('invalid-argument', 'A clear rejection reason is required.');
    }

    const applicationRef = db.collection('public_school_applications').doc(applicationId);
    const applicationSnap = await applicationRef.get();
    if (!applicationSnap.exists) {
      throw new HttpsError('not-found', 'School application not found.');
    }
    const application = applicationSnap.data() || {};
    if (application.status !== 'pending_review') {
      throw new HttpsError('failed-precondition', 'Only pending applications can be rejected.');
    }

    const auditRef = db.collection('super_admin_audit_logs').doc();
    const serverTime = admin.firestore.FieldValue.serverTimestamp();
    const batch = db.batch();
    batch.set(
      applicationRef,
      {
        status: 'rejected',
        appReady: false,
        reviewedAt: serverTime,
        reviewedBy: owner.uid,
        rejectionReason: reason,
        updatedAt: serverTime,
      },
      { merge: true },
    );
    batch.set(auditRef, {
      id: auditRef.id,
      ownerId: owner.uid,
      action: 'REJECT_SCHOOL_APPLICATION',
      schoolId: null,
      affectedUserId: text(application.authUid || application.id || applicationId, 160),
      timestamp: serverTime,
      device: 'Platform Dashboard',
      reason,
      metadata: {
        applicationId,
        schoolName: text(application.school?.name, 160),
      },
    });
    await batch.commit();
    return { ok: true, status: 'rejected' };
  },
);
