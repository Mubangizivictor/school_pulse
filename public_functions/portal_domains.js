const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
const dns = require('node:dns').promises;
const { requirePlatformOwner, OwnerAuthorizationError } = require('./vendor/owner-auth');
const { ROOT, RESERVED, validSlug } = require('./portal_slug');
if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();
const TARGET = 'ghs.googlehosted.com';
const TRIAL_DAYS = 14;
const LIFECYCLE_STATUSES = new Set(['active', 'suspended', 'archived', 'trial']);
const clean = v => String(v || '').trim().toLowerCase();
const validHost = v => /^[a-z0-9](?:[a-z0-9.-]{0,251}[a-z0-9])?$/.test(v) && v.includes('.') && !v.endsWith(`.${ROOT}`);
async function owner(request) { try { return await requirePlatformOwner(request, { db }); } catch (e) { if (e instanceof OwnerAuthorizationError) throw new HttpsError(e.code, e.message); throw e; } }
async function schoolAdmin(request) { if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required.'); const u = (await db.doc(`users/${request.auth.uid}`).get()).data(); if (!u || u.role !== 'schoolAdmin' || !u.schoolId) throw new HttpsError('permission-denied', 'School administrator access required.'); return { uid: request.auth.uid, schoolId: u.schoolId }; }
// address/phone/email were added alongside getPublicSchoolProfile below —
// school.branding already carried them (see createSchoolPortal), but this
// projection previously dropped them, so the public school page had no
// contact block to show. Still nothing beyond branding-level contact info:
// no student/staff/financial data ever flows into this public doc.
function publicDomain(schoolId, school, host) { const b = school.branding || {}; return { schoolId, slug: school.slug, hostname: host, status: 'active', schoolName: b.schoolName || school.name, logoUrl: b.logoUrl || null, primaryColor: b.primaryColor || null, secondaryColor: b.secondaryColor || null, address: b.address || null, phone: b.phone || null, email: b.email || null, updatedAt: admin.firestore.FieldValue.serverTimestamp() }; }
exports.checkPortalSlug = onCall({ region: 'europe-west1' }, async r => { const slug = clean(r.data?.slug); if (!validSlug(slug)) return { available: false, reason: 'invalid_or_reserved' }; return { available: !(await db.doc(`portal_slug_reservations/${slug}`).get()).exists, slug, url: `https://${slug}.${ROOT}` }; });
// Public, unauthenticated read of a school's brandable public-facing
// fields only — for the v1 branded school page (web_marketing/school.html).
// Deliberately projects a smaller field set than publicDomain()/
// portal_domains/{host} itself: address/phone/email are exposed here (a
// prospective parent visiting the school's own page reasonably expects a
// contact block) but nothing else on the school doc — no student/staff/
// financial data, no internal ids beyond the slug needed to look the page
// up again, no domainStatus/customDomains/subscription info. Looked up by
// slug (matches checkPortalSlug's input shape) or by hostname, since the
// caller may only know one or the other. A suspended/archived/unknown
// school returns { found: false } rather than leaking status detail.
exports.getPublicSchoolProfile = onCall({ region: 'europe-west1' }, async r => {
  const slug = clean(r.data?.slug);
  const hostInput = clean(r.data?.hostname);
  if (!slug && !hostInput) return { found: false };
  // validHost() deliberately excludes *.ROOT hosts (it's meant to gate
  // genuine custom-domain requests elsewhere) - a bare platform subdomain
  // passed as `hostname` (e.g. "greenhill.schoolpulseapp.com", the exact
  // shape createSchoolPortal's own portalUrl returns) would otherwise fail
  // both validHost() and validSlug(''), always resolving to not-found. So a
  // *.ROOT hostname is reduced to its slug and validated as one; anything
  // else is validated as a genuine external custom domain via validHost().
  let host;
  if (hostInput && hostInput.endsWith(`.${ROOT}`)) {
    const derivedSlug = hostInput.slice(0, -1 - ROOT.length);
    if (!validSlug(derivedSlug)) return { found: false };
    host = hostInput;
  } else if (hostInput) {
    if (!validHost(hostInput)) return { found: false };
    host = hostInput;
  } else {
    if (!validSlug(slug)) return { found: false };
    host = `${slug}.${ROOT}`;
  }
  const snap = await db.doc(`portal_domains/${host}`).get();
  if (!snap.exists) return { found: false };
  const d = snap.data() || {};
  if (d.status !== 'active') return { found: false };
  return {
    found: true,
    slug: d.slug || null,
    schoolName: d.schoolName || null,
    logoUrl: d.logoUrl || null,
    primaryColor: d.primaryColor || null,
    secondaryColor: d.secondaryColor || null,
    address: d.address || null,
    phone: d.phone || null,
    email: d.email || null,
  };
});
exports.createSchoolPortal = onCall({ region: 'europe-west1' }, async r => {
  const actor = await owner(r), d = r.data || {}, slug = clean(d.slug), name = String(d.schoolName || '').trim(), email = clean(d.adminEmail);
  if (!validSlug(slug) || name.length < 3 || !/^\S+@\S+\.\S+$/.test(email)) throw new HttpsError('invalid-argument', 'A valid name, slug, and administrator email are required.');
  let account; try { account = await admin.auth().getUserByEmail(email); } catch (_) { account = await admin.auth().createUser({ email, displayName: String(d.adminName || '').trim() }); }
  const school = db.collection('schools').doc(), host = `${slug}.${ROOT}`, reserve = db.doc(`portal_slug_reservations/${slug}`), branding = d.branding && typeof d.branding === 'object' ? d.branding : {};
  await db.runTransaction(async tx => { if ((await tx.get(reserve)).exists) throw new HttpsError('already-exists', 'That portal slug is already in use.'); const now = admin.firestore.FieldValue.serverTimestamp(); const data = { id: school.id, name, tenantId: slug.toUpperCase(), slug, portalSubdomain: host, customDomains: [], branding: { schoolName: name, logoUrl: branding.logoUrl || null, primaryColor: branding.primaryColor || null, secondaryColor: branding.secondaryColor || null, address: branding.address || '', phone: branding.phone || '', email: branding.email || email }, domainStatus: 'active', status: 'trial', subscriptionPlanId: String(d.planId || 'starter'), createdAt: Date.now(), subscriptionExpiry: Date.now() + TRIAL_DAYS * 24 * 60 * 60 * 1000, enabledFeatures: [], metadata: { source: 'platform_onboarding', createdBy: actor.uid } }; tx.set(reserve, { schoolId: school.id, slug, createdAt: now }); tx.set(school, data); tx.set(db.doc(`portal_domains/${host}`), publicDomain(school.id, data, host)); tx.set(db.doc(`users/${account.uid}`), { uid: account.uid, name: String(d.adminName || '').trim(), email, phoneNumber: String(d.adminPhone || '').trim(), role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: school.id, mustChangePassword: true, isActive: true }, { merge: true }); tx.set(db.doc(`institution_memberships/${account.uid}_${school.id}`), { userId: account.uid, institutionId: school.id, status: 'active', role: 'schoolAdmin', createdAt: now }); tx.set(db.collection('super_admin_audit_logs').doc(), { action: 'CREATE_SCHOOL_PORTAL', schoolId: school.id, ownerId: actor.uid, slug, timestamp: now }); });
  return { schoolId: school.id, portalUrl: `https://${host}` };
});
// Suspend/reactivate/archive a tenant, or change its subscription plan and
// expiry. Previously the owner console did a client-side read-then-write of
// schools/{id} (SuperAdminRemoteDataSource.updateSchool) - rules-enforced
// (isSuperAdmin() only) but not atomic and not guaranteed to be audited if
// the client crashed between the write and the separate audit-log write.
// This callable makes the status/subscription change and its audit entry
// one Admin-SDK transaction, matching createSchoolPortal's pattern.
// Suspend/archive must have real impact, not just a UI redirect: they now
// also set accessMode ('blocked'), the field firestore.rules'
// schoolCanWrite()/schoolAccessMode() actually check server-side (previously
// only payment approval/rejection and the hourly lifecycle sweep wrote this
// field - a suspended-by-owner school's writes were never rules-denied).
// Reactivating restores accessMode:'full'. Never touches students/users/
// payments/any other collection - suspension is reversible and data-safe by
// design, matching deleteSchoolDialog's comment in the Flutter client.
const ACCESS_MODE_FOR_STATUS = { suspended: 'blocked', archived: 'blocked', active: 'full', trial: 'full' };

// Shared suspend transaction body, extracted so both the owner-invoked
// setSchoolLifecycleStatus callable below and the Phase 2A hourly
// subscription_cycle_billing sweep (public_functions/subscription_cycle_billing.js)
// suspend a school through exactly one code path - never two independent
// writers of schools/{id}.status='suspended' that could drift apart.
//
// `actionTag` lets the caller distinguish an owner-initiated suspension
// ('UPDATE_SCHOOL_STATUS', the pre-existing audit action name kept as-is for
// setSchoolLifecycleStatus below) from the scheduled job's automatic one
// ('AUTO_SUSPEND_UNPAID_CYCLE') in super_admin_audit_logs, without adding a
// second collection or changing the existing action string for the owner
// path. `actorId` is the owner's uid for the manual path, or a fixed
// system-actor id (e.g. 'system:subscription_cycle_billing') for the
// scheduled job - never a real end-user uid for an automated action.
//
// Idempotent: if the school is already 'suspended', this is a no-op (no
// duplicate write, no duplicate audit log, no re-revocation of refresh
// tokens) - callers can call it unconditionally without their own
// already-suspended guard.
exports.suspendSchoolCore = async (db, schoolId, reason, actorId, actionTag = 'UPDATE_SCHOOL_STATUS') => {
  const ref = db.doc(`schools/${schoolId}`);
  const previousStatus = await db.runTransaction(async tx => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError('not-found', 'School not found.');
    const before = snap.data();
    if (before.status === 'suspended') return before.status;
    tx.update(ref, {
      status: 'suspended',
      accessMode: ACCESS_MODE_FOR_STATUS.suspended,
      metadata: { ...(before.metadata || {}), suspensionReason: reason || 'No reason provided' },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.set(db.collection('super_admin_audit_logs').doc(), {
      action: actionTag,
      schoolId,
      ownerId: actorId,
      reason,
      metadata: { previousStatus: before.status, newStatus: 'suspended' },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    return before.status;
  });

  // Immediate session invalidation on suspend - see setSchoolLifecycleStatus's
  // original comment: revoking refresh tokens forces every active session at
  // this school to re-authenticate, at which point the router guard and the
  // rules write-lock (accessMode) apply. Skipped when already suspended.
  if (previousStatus !== 'suspended') {
    const staffSnap = await db.collection('users').where('schoolId', '==', schoolId).get();
    await Promise.allSettled(
      staffSnap.docs.map(doc => admin.auth().revokeRefreshTokens(doc.id).catch(() => {}))
    );
  }

  return { schoolId, status: 'suspended', alreadySuspended: previousStatus === 'suspended' };
};

exports.setSchoolLifecycleStatus = onCall({ region: 'europe-west1' }, async r => {
  const actor = await owner(r), d = r.data || {};
  const schoolId = String(d.schoolId || '').trim();
  const status = String(d.status || '').trim();
  const reason = d.reason != null ? String(d.reason).trim() : null;
  if (!schoolId || !LIFECYCLE_STATUSES.has(status)) {
    throw new HttpsError('invalid-argument', 'A school ID and a valid status are required.');
  }

  // Suspension now routes through the shared suspendSchoolCore so the owner
  // path and the automated Phase 2A billing sweep can never diverge in
  // behavior. Every other status transition (active/trial/archived) keeps
  // its original inline transaction below, unchanged.
  if (status === 'suspended') {
    const result = await exports.suspendSchoolCore(db, schoolId, reason, actor.uid, 'UPDATE_SCHOOL_STATUS');
    return { schoolId, status: result.status };
  }

  const ref = db.doc(`schools/${schoolId}`);
  const previousStatus = await db.runTransaction(async tx => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError('not-found', 'School not found.');
    const before = snap.data();
    if (before.status === status) return before.status;
    const metadataPatch = {};
    if (status === 'archived') metadataPatch.archivedReason = reason || 'No reason provided';
    tx.update(ref, {
      status,
      accessMode: ACCESS_MODE_FOR_STATUS[status] || 'full',
      metadata: { ...(before.metadata || {}), ...metadataPatch },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.set(db.collection('super_admin_audit_logs').doc(), {
      action: 'UPDATE_SCHOOL_STATUS',
      schoolId,
      ownerId: actor.uid,
      reason,
      metadata: { previousStatus: before.status, newStatus: status },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    return before.status;
  });

  // Immediate session invalidation on archive - see suspendSchoolCore's
  // comment above for the suspend case, now handled there. Archive keeps its
  // own copy here since it's not part of the shared helper.
  if (status === 'archived' && previousStatus !== status) {
    const staffSnap = await db.collection('users').where('schoolId', '==', schoolId).get();
    await Promise.allSettled(
      staffSnap.docs.map(doc => admin.auth().revokeRefreshTokens(doc.id).catch(() => {}))
    );
  }

  return { schoolId, status };
});
exports.updateSchoolSubscriptionPlan = onCall({ region: 'europe-west1' }, async r => {
  const actor = await owner(r), d = r.data || {};
  const schoolId = String(d.schoolId || '').trim();
  const planId = String(d.planId || '').trim();
  const expiry = Number(d.expiry);
  if (!schoolId || !planId || !Number.isFinite(expiry)) {
    throw new HttpsError('invalid-argument', 'A school ID, plan ID, and expiry are required.');
  }
  const ref = db.doc(`schools/${schoolId}`);
  await db.runTransaction(async tx => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError('not-found', 'School not found.');
    const before = snap.data();
    tx.update(ref, {
      subscriptionPlanId: planId,
      subscriptionExpiry: expiry,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    tx.set(db.collection('super_admin_audit_logs').doc(), {
      action: 'UPDATE_SUBSCRIPTION',
      schoolId,
      ownerId: actor.uid,
      metadata: {
        previousPlanId: before.subscriptionPlanId || null,
        planId,
        expiry,
      },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
  return { schoolId, planId, expiry };
});
exports.requestCustomPortalDomain = onCall({ region: 'europe-west1' }, async r => { const actor = await schoolAdmin(r), host = clean(r.data?.hostname); if (!validHost(host)) throw new HttpsError('invalid-argument', 'Enter a valid custom hostname.'); const ref = db.doc(`portal_domain_requests/${host}`); await db.runTransaction(async tx => { const old = await tx.get(ref); if (old.exists && old.data().schoolId !== actor.schoolId) throw new HttpsError('already-exists', 'This domain is already requested.'); tx.set(ref, { hostname: host, schoolId: actor.schoolId, status: 'pending', cnameTarget: TARGET, requestedBy: actor.uid, requestedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true }); }); return { hostname: host, cnameTarget: TARGET, status: 'pending' }; });
// Owner-initiated support access session (School Details > School admins >
// Open support session). There was previously no callable that could create
// an institutions/{id}/support_access_requests doc as the platform owner -
// decideSupportAccess (functions/support_audit.js) only approves/revokes an
// existing one, and its actor check requires institution membership, which
// an owner never has. This mirrors that collection's shape (status,
// expiresAt, requestedByPlatformUser, durationMinutes) so decideSupportAccess
// and expireSupportAccess keep working on rows created here, and writes via
// Admin SDK since firestore.rules blocks client writes to this collection
// entirely (write: if false).
const SUPPORT_ACCESS_MAX_MINUTES = 30;
// Owner-initiated School Admin lifecycle actions (School Details > School
// admins > Manage admins). institution_memberships and the role-bearing
// fields on users/{uid} both deny ALL client writes (firestore.rules:2455
// `allow write: if false` on institution_memberships; the users/{uid}
// update rule at firestore.rules:217-249 has no isSuperAdmin() branch and
// explicitly never lets schoolAdmin be granted/altered client-side even by
// another schoolAdmin) - every action here needs the Admin SDK.
//
// "Promote/demote" from the product spec has no literal target in this
// app's role model: schoolAdmin is already the top school-scoped role (see
// ADMIN_ROLES in functions/index.js), so there is nothing to promote a
// schoolAdmin *to*. What the spec's promote/demote and primary-transfer
// language maps onto concretely is: setPrimary (transfer primary-admin
// standing) and disable/enable/remove (access lifecycle) - implemented
// below as the 4 real actions this system supports, rather than inventing
// a role tier that doesn't exist.
const ADMIN_ACTIONS = new Set(['setPrimary', 'disable', 'enable', 'remove']);
exports.manageSchoolAdmin = onCall({ region: 'europe-west1' }, async r => {
  const actor = await owner(r), d = r.data || {};
  const schoolId = String(d.schoolId || '').trim();
  const targetUid = String(d.targetUid || '').trim();
  const action = String(d.action || '').trim();
  const reason = d.reason != null ? String(d.reason).trim().slice(0, 500) : null;
  const replacementUid = d.replacementUid != null ? String(d.replacementUid).trim() : null;
  if (!schoolId || !targetUid || !ADMIN_ACTIONS.has(action)) {
    throw new HttpsError('invalid-argument', 'A school ID, target admin, and valid action are required.');
  }
  if ((action === 'disable' || action === 'remove') && (!reason || reason.length < 3)) {
    throw new HttpsError('invalid-argument', 'A reason of at least 3 characters is required.');
  }

  const schoolSnap = await db.doc(`schools/${schoolId}`).get();
  if (!schoolSnap.exists) throw new HttpsError('not-found', 'School not found.');
  // Defense in depth: the client already hides these actions when the
  // school isn't active, but a stale client screen must not be able to
  // bypass that - re-check server-side before mutating anything.
  if (schoolSnap.data().status !== 'active') {
    throw new HttpsError('failed-precondition', 'This school is not active; admin access changes are unavailable.');
  }

  const membershipRef = db.doc(`institution_memberships/${targetUid}_${schoolId}`);
  const userRef = db.doc(`users/${targetUid}`);

  await db.runTransaction(async tx => {
    const [membershipSnap, userSnap] = await Promise.all([tx.get(membershipRef), tx.get(userRef)]);
    if (!membershipSnap.exists || !userSnap.exists) throw new HttpsError('not-found', 'This admin is not a member of this school.');
    const membership = membershipSnap.data();
    const user = userSnap.data();
    if (user.schoolId !== schoolId && membership.institutionId !== schoolId) {
      throw new HttpsError('permission-denied', 'This admin does not belong to the specified school.');
    }
    const roles = Array.isArray(user.roles) ? user.roles : [];
    if (!roles.includes('schoolAdmin')) throw new HttpsError('failed-precondition', 'Target is not a School Admin.');

    // Last-admin protection: disable/remove on the only remaining active
    // schoolAdmin is rejected unless a replacementUid is supplied and is
    // itself a currently-active admin of this same school - promoted to
    // primary in the same transaction so the school is never left with
    // zero admins between the two writes.
    //
    // remainingWithoutTarget must exclude the replacement candidate too,
    // not just the target: a valid replacement is REQUIRED to already be
    // an active schoolAdmin at this school (see the validation below), so
    // without this exclusion the query would always count them as one of
    // the "remaining" admins and remainingWithoutTarget.length would never
    // reach 0 - making the replacement-promotion branch below unreachable
    // even in the exact case it exists to handle. Caught by
    // public_functions/test/school_workspace_callables.emulator.test.cjs's
    // last-admin-with-replacement case.
    if (action === 'disable' || action === 'remove') {
      const activeAdmins = await tx.get(
        db.collection('users')
          .where('schoolId', '==', schoolId)
          .where('roles', 'array-contains', 'schoolAdmin')
          .where('isActive', '==', true)
      );
      const remainingWithoutTarget = activeAdmins.docs.filter(
        doc => doc.id !== targetUid && doc.id !== replacementUid
      );
      if (remainingWithoutTarget.length === 0) {
        if (!replacementUid) {
          throw new HttpsError('failed-precondition', 'Cannot remove the last active School Admin without naming a replacement.');
        }
        const replacementRef = db.doc(`users/${replacementUid}`);
        const replacementSnap = await tx.get(replacementRef);
        const replacementUser = replacementSnap.exists ? replacementSnap.data() : null;
        if (!replacementUser || replacementUser.schoolId !== schoolId || !(replacementUser.roles || []).includes('schoolAdmin') || replacementUser.isActive === false) {
          throw new HttpsError('failed-precondition', 'The replacement must be an active School Admin at this school.');
        }
        tx.update(replacementRef, { isPrimaryAdmin: true });
        tx.set(db.doc(`institution_memberships/${replacementUid}_${schoolId}`), { isPrimaryAdmin: true, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
      }
    }

    if (action === 'setPrimary') {
      tx.update(userRef, { isPrimaryAdmin: true });
      tx.set(membershipRef, { isPrimaryAdmin: true, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    } else if (action === 'disable') {
      tx.update(userRef, { isActive: false, deactivationReason: reason });
      tx.set(membershipRef, { status: 'suspended', updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    } else if (action === 'enable') {
      tx.update(userRef, { isActive: true, deactivationReason: admin.firestore.FieldValue.delete() });
      tx.set(membershipRef, { status: 'active', updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    } else if (action === 'remove') {
      tx.update(userRef, { isActive: false, deactivationReason: reason, isPrimaryAdmin: false });
      tx.set(membershipRef, { status: 'removed', updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    }

    tx.set(db.collection('super_admin_audit_logs').doc(), {
      action: `SCHOOL_ADMIN_${action.toUpperCase()}`,
      schoolId,
      ownerId: actor.uid,
      affectedUserId: targetUid,
      reason,
      metadata: { replacementUid: replacementUid || null },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  // Immediate access invalidation for disable/remove - revoking refresh
  // tokens forces any live session for this account to re-authenticate
  // (and fail, since isActive is now false and the app's own auth gate
  // checks it), rather than staying signed in until the token naturally
  // expires. No existing staff-session-revocation function covers this
  // case, so it belongs here alongside the write that disables the account.
  if (action === 'disable' || action === 'remove') {
    try {
      await admin.auth().revokeRefreshTokens(targetUid);
    } catch (_) {
      // Best-effort: the Firestore state change above is the actual
      // authorization boundary (app-level auth gate reads isActive), so a
      // revocation failure (e.g. already-deleted Auth user) must not roll
      // back or fail the whole action.
    }
  }

  return { schoolId, targetUid, action };
});

exports.requestSupportAccess = onCall({ region: 'europe-west1' }, async r => {
  const actor = await owner(r), d = r.data || {};
  const schoolId = String(d.schoolId || '').trim();
  const reason = String(d.reason || '').trim();
  if (!schoolId) throw new HttpsError('invalid-argument', 'A school ID is required.');
  if (reason.length < 3) throw new HttpsError('invalid-argument', 'A reason of at least 3 characters is required.');
  const school = await db.doc(`schools/${schoolId}`).get();
  if (!school.exists) throw new HttpsError('not-found', 'School not found.');
  const ref = db.collection(`institutions/${schoolId}/support_access_requests`).doc();
  const expiresAt = admin.firestore.Timestamp.fromMillis(Date.now() + SUPPORT_ACCESS_MAX_MINUTES * 60000);
  await ref.set({
    id: ref.id,
    institutionId: schoolId,
    status: 'pending',
    reason: reason.slice(0, 500),
    requestedByPlatformUser: actor.uid,
    requestedScope: ['support'],
    durationMinutes: SUPPORT_ACCESS_MAX_MINUTES,
    expiresAt,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  await db.collection(`institutions/${schoolId}/audit_events`).doc().create({
    auditEventId: ref.id,
    institutionId: schoolId,
    status: 'success',
    sensitivity: 'normal',
    source: 'cloud_function',
    moduleKey: 'support',
    eventType: 'Support Access',
    action: 'support_access_requested',
    actorId: actor.uid,
    targetType: 'support_access',
    targetId: ref.id,
    supportAccessSessionId: ref.id,
    metadataSafe: { reason: reason.slice(0, 500) },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  return { supportAccessRequestId: ref.id, status: 'pending', expiresAt: expiresAt.toMillis() };
});
exports.verifyAndActivateCustomPortalDomain = onCall({ region: 'europe-west1' }, async r => { const actor = await owner(r), host = clean(r.data?.hostname); if (!validHost(host)) throw new HttpsError('invalid-argument', 'Invalid hostname.'); const ref = db.doc(`portal_domain_requests/${host}`), request = await ref.get(); if (!request.exists) throw new HttpsError('not-found', 'Domain request not found.'); let cnames = []; try { cnames = await dns.resolveCname(host); } catch (_) {} if (!cnames.some(v => v.toLowerCase().replace(/\.$/, '') === TARGET)) { await ref.set({ status: 'verification_failed', lastError: `CNAME must point to ${TARGET}`, checkedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true }); throw new HttpsError('failed-precondition', `CNAME must point to ${TARGET}.`); } const school = await db.doc(`schools/${request.data().schoolId}`).get(); if (!school.exists) throw new HttpsError('not-found', 'School not found.'); await db.runTransaction(async tx => { tx.set(db.doc(`portal_domains/${host}`), publicDomain(school.id, school.data(), host)); tx.update(ref, { status: 'active', approvedBy: actor.uid, approvedAt: admin.firestore.FieldValue.serverTimestamp(), lastError: null }); tx.update(school.ref, { customDomains: admin.firestore.FieldValue.arrayUnion(host) }); tx.set(db.collection('super_admin_audit_logs').doc(), { action: 'ACTIVATE_CUSTOM_PORTAL_DOMAIN', schoolId: school.id, hostname: host, ownerId: actor.uid, timestamp: admin.firestore.FieldValue.serverTimestamp() }); }); return { hostname: host, status: 'active' }; });
// Owner re-runs the CNAME check for a request without activating it - used
// by the "Recheck" action so a failed/pending request can be re-evaluated
// after the school fixes their DNS, and the owner sees a fresh
// lastChecked/lastError without any change to portal_domains.
exports.recheckCustomPortalDomain = onCall({ region: 'europe-west1' }, async r => {
  const actor = await owner(r), host = clean(r.data?.hostname);
  if (!validHost(host)) throw new HttpsError('invalid-argument', 'Invalid hostname.');
  const ref = db.doc(`portal_domain_requests/${host}`), request = await ref.get();
  if (!request.exists) throw new HttpsError('not-found', 'Domain request not found.');
  const current = request.data() || {};
  if (current.status === 'active') return { hostname: host, status: 'active', cnameOk: true };
  let cnames = [];
  try { cnames = await dns.resolveCname(host); } catch (_) {}
  const cnameOk = cnames.some(v => v.toLowerCase().replace(/\.$/, '') === TARGET);
  await ref.set({
    status: cnameOk ? 'verified' : 'verification_failed',
    lastError: cnameOk ? null : `CNAME must point to ${TARGET}`,
    checkedAt: admin.firestore.FieldValue.serverTimestamp(),
    checkedBy: actor.uid,
  }, { merge: true });
  return { hostname: host, status: cnameOk ? 'verified' : 'verification_failed', cnameOk };
});
// Owner rejects or removes a custom-domain request. A rejected/removed
// request stops appearing as actionable in the console; if the domain was
// already active its public projection is torn down and it is dropped from
// the school's customDomains array. Always writes an audit entry, matching
// verifyAndActivateCustomPortalDomain.
exports.rejectCustomPortalDomain = onCall({ region: 'europe-west1' }, async r => {
  const actor = await owner(r), host = clean(r.data?.hostname);
  const reason = String(r.data?.reason || '').trim().slice(0, 500);
  if (!validHost(host)) throw new HttpsError('invalid-argument', 'Invalid hostname.');
  const ref = db.doc(`portal_domain_requests/${host}`), request = await ref.get();
  if (!request.exists) throw new HttpsError('not-found', 'Domain request not found.');
  const data = request.data() || {};
  await db.runTransaction(async tx => {
    tx.set(ref, {
      status: 'rejected',
      rejectionReason: reason || 'No reason provided',
      rejectedBy: actor.uid,
      rejectedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    if (data.status === 'active' && data.schoolId) {
      tx.delete(db.doc(`portal_domains/${host}`));
      tx.update(db.doc(`schools/${data.schoolId}`), {
        customDomains: admin.firestore.FieldValue.arrayRemove(host),
      });
    }
    tx.set(db.collection('super_admin_audit_logs').doc(), {
      action: 'REJECT_CUSTOM_PORTAL_DOMAIN',
      schoolId: data.schoolId || null,
      hostname: host,
      ownerId: actor.uid,
      reason: reason || null,
      metadata: { previousStatus: data.status || 'unknown' },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
  return { hostname: host, status: 'rejected' };
});
// A school admin can ask to change their platform subdomain
// (<slug>.ROOT, assigned at onboarding) after the fact - distinct from
// requestCustomPortalDomain above, which is for a school bringing an
// external vanity domain. This only reserves the *request*; the slug
// itself isn't reserved in portal_slug_reservations until the owner
// approves it below, so an unapproved request can't squat on a slug
// another school might want. One pending request per school at a time
// (doc id = schoolId) - a second call just overwrites the pending one.
exports.requestPortalSubdomainChange = onCall({ region: 'europe-west1' }, async r => {
  const actor = await schoolAdmin(r);
  const requestedSlug = clean(r.data?.slug);
  if (!validSlug(requestedSlug)) throw new HttpsError('invalid-argument', 'Enter a valid subdomain.');
  const school = await db.doc(`schools/${actor.schoolId}`).get();
  if (!school.exists) throw new HttpsError('not-found', 'School not found.');
  const currentSlug = school.data().slug || null;
  if (requestedSlug === currentSlug) throw new HttpsError('invalid-argument', 'That is already this school\'s subdomain.');
  const ref = db.doc(`portal_subdomain_change_requests/${actor.schoolId}`);
  await db.runTransaction(async tx => {
    const reservation = await tx.get(db.doc(`portal_slug_reservations/${requestedSlug}`));
    if (reservation.exists && reservation.data().schoolId !== actor.schoolId) {
      throw new HttpsError('already-exists', 'That subdomain is already in use.');
    }
    tx.set(ref, {
      schoolId: actor.schoolId,
      currentSlug,
      requestedSlug,
      status: 'pending',
      requestedBy: actor.uid,
      requestedAt: admin.firestore.FieldValue.serverTimestamp(),
      reviewedBy: null,
      reviewedAt: null,
      rejectionReason: null,
    });
  });
  return { schoolId: actor.schoolId, requestedSlug, status: 'pending' };
});
// Owner approves a pending subdomain-change request: re-checks the target
// slug is still free, moves the reservation from the old slug to the new
// one, updates schools/{id}.slug/.portalSubdomain, and replaces the
// portal_domains/{host} projection - old host removed, new host created via
// the same publicDomain() shape every other projection uses. Mirrors
// verifyAndActivateCustomPortalDomain's transaction/audit-log pattern.
exports.approvePortalSubdomainChange = onCall({ region: 'europe-west1' }, async r => {
  const actor = await owner(r);
  const schoolId = String(r.data?.schoolId || '').trim();
  if (!schoolId) throw new HttpsError('invalid-argument', 'A school ID is required.');
  const ref = db.doc(`portal_subdomain_change_requests/${schoolId}`);
  const request = await ref.get();
  if (!request.exists) throw new HttpsError('not-found', 'Subdomain change request not found.');
  const data = request.data();
  if (data.status !== 'pending') throw new HttpsError('failed-precondition', 'This request has already been reviewed.');
  const { requestedSlug, currentSlug } = data;
  const schoolRef = db.doc(`schools/${schoolId}`);
  await db.runTransaction(async tx => {
    const [schoolSnap, reservationSnap] = await Promise.all([
      tx.get(schoolRef),
      tx.get(db.doc(`portal_slug_reservations/${requestedSlug}`)),
    ]);
    if (!schoolSnap.exists) throw new HttpsError('not-found', 'School not found.');
    if (reservationSnap.exists && reservationSnap.data().schoolId !== schoolId) {
      throw new HttpsError('already-exists', 'That subdomain was claimed by another school in the meantime.');
    }
    const school = schoolSnap.data();
    const oldHost = `${currentSlug}.${ROOT}`, newHost = `${requestedSlug}.${ROOT}`;
    const now = admin.firestore.FieldValue.serverTimestamp();
    if (currentSlug) tx.delete(db.doc(`portal_slug_reservations/${currentSlug}`));
    tx.set(db.doc(`portal_slug_reservations/${requestedSlug}`), { schoolId, slug: requestedSlug, createdAt: now });
    tx.update(schoolRef, { slug: requestedSlug, portalSubdomain: newHost, updatedAt: now });
    if (currentSlug) tx.delete(db.doc(`portal_domains/${oldHost}`));
    tx.set(db.doc(`portal_domains/${newHost}`), publicDomain(schoolId, { ...school, slug: requestedSlug }, newHost));
    tx.update(ref, { status: 'approved', reviewedBy: actor.uid, reviewedAt: now });
    tx.set(db.collection('super_admin_audit_logs').doc(), {
      action: 'APPROVE_PORTAL_SUBDOMAIN_CHANGE',
      schoolId,
      ownerId: actor.uid,
      metadata: { previousSlug: currentSlug, newSlug: requestedSlug },
      timestamp: now,
    });
  });
  return { schoolId, slug: requestedSlug, status: 'approved' };
});
// Owner rejects a pending subdomain-change request - no slug/domain writes,
// just marks the request so it stops appearing as actionable. Mirrors
// rejectCustomPortalDomain's shape.
exports.rejectPortalSubdomainChange = onCall({ region: 'europe-west1' }, async r => {
  const actor = await owner(r);
  const schoolId = String(r.data?.schoolId || '').trim();
  const reason = String(r.data?.reason || '').trim().slice(0, 500);
  if (!schoolId) throw new HttpsError('invalid-argument', 'A school ID is required.');
  const ref = db.doc(`portal_subdomain_change_requests/${schoolId}`);
  const request = await ref.get();
  if (!request.exists) throw new HttpsError('not-found', 'Subdomain change request not found.');
  if (request.data().status !== 'pending') throw new HttpsError('failed-precondition', 'This request has already been reviewed.');
  const now = admin.firestore.FieldValue.serverTimestamp();
  await db.runTransaction(async tx => {
    tx.update(ref, {
      status: 'rejected',
      rejectionReason: reason || 'No reason provided',
      reviewedBy: actor.uid,
      reviewedAt: now,
    });
    tx.set(db.collection('super_admin_audit_logs').doc(), {
      action: 'REJECT_PORTAL_SUBDOMAIN_CHANGE',
      schoolId,
      ownerId: actor.uid,
      reason: reason || null,
      timestamp: now,
    });
  });
  return { schoolId, status: 'rejected' };
});
// Keep the public projection in sync when the owner changes branding or
// suspends a tenant. This is deliberately a one-way projection: no public
// directory write can ever modify schools/{id}.
exports.syncPortalDomainProjection = onDocumentWritten({ region: 'europe-west1', document: 'schools/{schoolId}' }, async event => {
  const after = event.data?.after;
  if (!after?.exists) return;
  const school = after.data(), suspended = school.domainStatus === 'suspended' || school.status === 'suspended';
  const hosts = [school.portalSubdomain, ...(Array.isArray(school.customDomains) ? school.customDomains : [])].filter(Boolean);
  await Promise.all(hosts.map(host => db.doc(`portal_domains/${clean(host)}`).set({ ...publicDomain(after.id, school, clean(host)), status: suspended ? 'suspended' : 'active' }, { merge: true })));
});
// Exported for reuse by other onboarding paths that write a portal_domains
// projection outside this file's own triggers/callables (currently
// payments.js:approveSchoolApplication) - keeps the projected field set
// (schoolName/logoUrl/colors/address/phone/email) defined in exactly one
// place instead of hand-duplicated per caller.
exports.publicDomain = publicDomain;
exports.__test__ = { validSlug, validHost, RESERVED, LIFECYCLE_STATUSES, TRIAL_DAYS, SUPPORT_ACCESS_MAX_MINUTES, ADMIN_ACTIONS, ACCESS_MODE_FOR_STATUS };
