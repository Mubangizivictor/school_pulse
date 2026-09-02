const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
const dns = require('node:dns').promises;
const { requirePlatformOwner, OwnerAuthorizationError } = require('./vendor/owner-auth');
if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();
const ROOT = 'schoolpulse.ug', TARGET = 'ghs.googlehosted.com';
const TRIAL_DAYS = 14;
const LIFECYCLE_STATUSES = new Set(['active', 'suspended', 'archived', 'trial']);
const RESERVED = new Set(['admin', 'api', 'www', 'support', 'schoolpulse', 'app', 'mail', 'status', 'portal']);
const clean = v => String(v || '').trim().toLowerCase();
const validSlug = v => /^[a-z0-9](?:[a-z0-9-]{1,61}[a-z0-9])?$/.test(v) && !RESERVED.has(v);
const validHost = v => /^[a-z0-9](?:[a-z0-9.-]{0,251}[a-z0-9])?$/.test(v) && v.includes('.') && !v.endsWith(`.${ROOT}`);
async function owner(request) { try { return await requirePlatformOwner(request, { db }); } catch (e) { if (e instanceof OwnerAuthorizationError) throw new HttpsError(e.code, e.message); throw e; } }
async function schoolAdmin(request) { if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required.'); const u = (await db.doc(`users/${request.auth.uid}`).get()).data(); if (!u || u.role !== 'schoolAdmin' || !u.schoolId) throw new HttpsError('permission-denied', 'School administrator access required.'); return { uid: request.auth.uid, schoolId: u.schoolId }; }
function publicDomain(schoolId, school, host) { const b = school.branding || {}; return { schoolId, slug: school.slug, hostname: host, status: 'active', schoolName: b.schoolName || school.name, logoUrl: b.logoUrl || null, primaryColor: b.primaryColor || null, secondaryColor: b.secondaryColor || null, updatedAt: admin.firestore.FieldValue.serverTimestamp() }; }
exports.checkPortalSlug = onCall({ region: 'europe-west1' }, async r => { const slug = clean(r.data?.slug); if (!validSlug(slug)) return { available: false, reason: 'invalid_or_reserved' }; return { available: !(await db.doc(`portal_slug_reservations/${slug}`).get()).exists, slug, url: `https://${slug}.${ROOT}` }; });
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
exports.setSchoolLifecycleStatus = onCall({ region: 'europe-west1' }, async r => {
  const actor = await owner(r), d = r.data || {};
  const schoolId = String(d.schoolId || '').trim();
  const status = String(d.status || '').trim();
  const reason = d.reason != null ? String(d.reason).trim() : null;
  if (!schoolId || !LIFECYCLE_STATUSES.has(status)) {
    throw new HttpsError('invalid-argument', 'A school ID and a valid status are required.');
  }
  const ref = db.doc(`schools/${schoolId}`);
  await db.runTransaction(async tx => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError('not-found', 'School not found.');
    const before = snap.data();
    if (before.status === status) return;
    const metadataPatch = {};
    if (status === 'suspended') metadataPatch.suspensionReason = reason || 'No reason provided';
    if (status === 'archived') metadataPatch.archivedReason = reason || 'No reason provided';
    tx.update(ref, {
      status,
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
  });
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
exports.__test__ = { validSlug, validHost, RESERVED, LIFECYCLE_STATUSES, TRIAL_DAYS };
