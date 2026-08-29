/*
 * Financial Entitlements is deliberately a server-only policy decision point.
 * It consumes the existing bill, scholarship, report-card and credential
 * records; it never copies balances or card UIDs into a terminal response.
 */
const { createHash, createHmac, randomBytes } = require('crypto');

module.exports = ({ admin, onCall, HttpsError }) => {
  const db = admin.firestore();
  const { FieldValue, Timestamp } = require("firebase-admin/firestore");
  const FINANCE = new Set(['bursar', 'schoolAdmin']);
  const LEADERSHIP = new Set(['director', 'headTeacher', 'schoolAdmin']);
  const SERVICE_STAFF = {
    dining: ['cateringManager'], boarding: ['boardingMatron', 'boardingPatron'],
    transport: ['transportCoordinator'], library: ['librarian'], ict: ['storeInventory'],
    internalExams: ['deanOfStudies', 'headTeacher'], reportCards: ['bursar'],
    practicals: ['storeInventory'], activities: ['gamesMaster'], trips: ['gamesMaster'],
    remedial: ['deanOfStudies'], certificates: ['registrar'],
  };
  const SAFE_SERVICES = new Set(['nationalExams', 'emergencyHealthcare', 'water', 'sanitation', 'safeguarding', 'classroomLearning', 'attendance', 'guardianRelease']);
  const hash = (value) => createHash('sha256').update(String(value)).digest('hex');
  const roles = (u) => Array.from(new Set([u?.role, ...(u?.roles || [])].filter(Boolean)));
  const hasRole = (u, allowed) => roles(u).some((r) => allowed.includes(r));
  const text = (value, max = 160) => typeof value === 'string' ? value.trim().slice(0, max) : '';
  const millis = (value) => value?.toMillis ? value.toMillis() : Number(value || 0);
  // Kept in function configuration, never Firestore. Production deploys
  // must set this to a 32+ byte random value; absence is fail-closed.
  const cardTokenKey = process.env.ENTITLEMENT_CARD_TOKEN_KEY;
  function signCardPayload(payload) {
    if (!cardTokenKey || cardTokenKey.length < 32) throw new HttpsError('failed-precondition', 'Terminal card signing is not configured.');
    return createHmac('sha256', cardTokenKey).update(payload).digest('base64url');
  }
  function readCardToken(token) {
    const [payload, signature] = String(token).split('.');
    if (!payload || !signature || signature !== signCardPayload(payload)) throw new HttpsError('permission-denied', 'Credential denied.');
    let data; try { data = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8')); } catch (_) { throw new HttpsError('permission-denied', 'Credential denied.'); }
    if (!data?.credentialId || !Number.isFinite(data.exp) || data.exp <= Date.now()) throw new HttpsError('permission-denied', 'Credential denied.');
    return data;
  }

  async function caller(request, schoolId) {
    if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in is required.');
    const snap = await db.doc(`users/${request.auth.uid}`).get(); const user = snap.data();
    if (!user || user.schoolId !== schoolId || user.isActive === false) throw new HttpsError('permission-denied', 'No active membership for this school.');
    return { ...user, uid: request.auth.uid };
  }
  async function audit(schoolId, action, actorId, entityId, details = {}) {
    await db.collection(`schools/${schoolId}/financial_entitlement_audit`).add({ action, actorId, entityId, details, at: FieldValue.serverTimestamp() });
  }
  function policyStatus(policy, financial) {
    if (!policy?.enabled) return { status: 'notApplicable', reasonCode: 'POLICY_DISABLED', source: 'feePolicy' };
    const pct = Number(financial?.paymentPercentage ?? financial?.percentagePaid ?? 0);
    const balance = Number(financial?.balance ?? financial?.balanceDue ?? 0);
    if (pct >= Number(policy.minimumPaymentPercentage || 100) && balance <= Number(policy.maximumBalance || 0)) return { status: 'allowed', reasonCode: 'POLICY_MET', source: 'feePolicy' };
    return { status: 'blocked', reasonCode: 'POLICY_NOT_MET', source: 'feePolicy' };
  }
  async function compute({ schoolId, studentId, service, now = Date.now() }) {
    if (SAFE_SERVICES.has(service)) return { status: 'allowed', reasonCode: 'SAFETY_SERVICE', source: 'system', expiresAt: null };
    const [policySnap, financialSnap, overrides] = await Promise.all([
      db.doc(`schools/${schoolId}/financial_entitlement_policy/current`).get(),
      db.doc(`schools/${schoolId}/student_financials/${studentId}`).get(),
      db.collection(`schools/${schoolId}/financial_entitlement_overrides`).where('studentId', '==', studentId).where('service', '==', service).where('status', '==', 'active').get(),
    ]);
    const policy = policySnap.data()?.services?.[service];
    let result = policyStatus(policy, financialSnap.data());
    const active = overrides.docs.map((d) => ({ id: d.id, ...d.data() })).filter((o) => !o.expiresAt || millis(o.expiresAt) > now).sort((a, b) => millis(b.createdAt) - millis(a.createdAt))[0];
    if (active) result = { status: active.decision === 'allow' ? 'overrideActive' : 'suspended', reasonCode: active.reasonCode || 'OVERRIDE', source: active.source || 'bursarTemporaryOverride', expiresAt: active.expiresAt || null, overrideId: active.id };
    return result;
  }

  // Assigned onto by index.js's Object.assign(exports, require(...)()).
  // Must be a real object we mutate and return — assigning onto the bare
  // `exports` identifier here resolves to this file's own module exports,
  // not what the caller receives (see the note atop student_fee_billing.js).
  const api = { compute, policyStatus, SAFE_SERVICES };

  api.saveFinancialEntitlementPolicy = onCall(async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId);
    const user = await caller(request, schoolId);
    if (!FINANCE.has(user.role) && !hasRole(user, [...FINANCE])) throw new HttpsError('permission-denied', 'Only finance may propose entitlement policies.');
    const services = d.services || {};
    for (const [service, rule] of Object.entries(services)) {
      if (SAFE_SERVICES.has(service)) throw new HttpsError('invalid-argument', 'Safety services cannot be fee-gated.');
      if (typeof rule !== 'object' || Array.isArray(rule)) throw new HttpsError('invalid-argument', 'Invalid service policy.');
    }
    const requiresApproval = Boolean(d.requireLeadershipApproval);
    if (requiresApproval && !hasRole(user, [...LEADERSHIP])) {
      const proposal = await db.collection(`schools/${schoolId}/financial_entitlement_policy_proposals`).add({ services, status: 'pendingApproval', proposedBy: user.uid, createdAt: FieldValue.serverTimestamp() });
      await audit(schoolId, 'policy.proposed', user.uid, proposal.id); return { status: 'pendingApproval', proposalId: proposal.id };
    }
    await db.doc(`schools/${schoolId}/financial_entitlement_policy/current`).set({ services, updatedBy: user.uid, effectiveAt: FieldValue.serverTimestamp(), version: FieldValue.increment(1) }, { merge: true });
    await audit(schoolId, 'policy.updated', user.uid, 'current'); return { status: 'active' };
  });

  api.setFinancialEntitlementOverride = onCall(async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId); const studentId = text(d.studentId); const service = text(d.service);
    const user = await caller(request, schoolId);
    if (!hasRole(user, [...FINANCE, ...LEADERSHIP])) throw new HttpsError('permission-denied', 'Only authorised finance or leadership may override an entitlement.');
    if (!studentId || !service || SAFE_SERVICES.has(service) || !['allow', 'deny'].includes(d.decision)) throw new HttpsError('invalid-argument', 'A non-safety service, learner and allow/deny decision are required.');
    const expiresAt = Number(d.expiresAt || 0); if (d.decision === 'allow' && (!expiresAt || expiresAt <= Date.now())) throw new HttpsError('invalid-argument', 'Temporary access must have a future expiry.');
    const ref = db.collection(`schools/${schoolId}/financial_entitlement_overrides`).doc();
    await ref.set({ studentId, service, decision: d.decision, reasonCode: text(d.reasonCode, 80) || 'MANUAL_REVIEW', note: text(d.note, 500), source: d.source === 'serviceAdministratorOverride' ? d.source : 'bursarTemporaryOverride', status: 'active', expiresAt: expiresAt ? Timestamp.fromMillis(expiresAt) : null, createdBy: user.uid, createdAt: FieldValue.serverTimestamp() });
    await audit(schoolId, 'override.created', user.uid, ref.id, { service, studentId, decision: d.decision }); return { overrideId: ref.id, status: 'active' };
  });

  // A terminal must be pre-registered by finance. Its random secret is returned once;
  // only its hash is retained. Terminal calls are therefore independent of staff UI auth.
  api.registerEntitlementTerminal = onCall(async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId); const user = await caller(request, schoolId);
    if (!hasRole(user, [...FINANCE])) throw new HttpsError('permission-denied', 'Only finance may register terminals.');
    const service = text(d.service); if (!SERVICE_STAFF[service]) throw new HttpsError('invalid-argument', 'Unsupported terminal service.');
    const id = randomBytes(12).toString('hex'); const secret = randomBytes(32).toString('base64url');
    await db.doc(`schools/${schoolId}/entitlement_terminals/${id}`).set({ service, label: text(d.label) || service, secretHash: hash(secret), status: 'active', createdBy: user.uid, createdAt: FieldValue.serverTimestamp(), nonceVersion: 1 });
    await audit(schoolId, 'terminal.registered', user.uid, id, { service }); return { terminalId: id, terminalSecret: secret };
  });

  // A short-lived, signed opaque token is the only card value accepted by
  // terminals. The canonical credential remains server-side and can be
  // revoked/replaced using the existing student credential lifecycle.
  api.mintEntitlementCardToken = onCall({ secrets: ["ENTITLEMENT_CARD_TOKEN_KEY"] }, async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId); const credentialId = text(d.credentialId, 512);
    const user = await caller(request, schoolId);
    if (!hasRole(user, [...FINANCE, ...LEADERSHIP, ...Object.values(SERVICE_STAFF).flat()])) throw new HttpsError('permission-denied', 'Not authorised to issue a service token.');
    const credential = await db.doc(`schools/${schoolId}/credentials/${credentialId}`).get();
    if (!credential.exists || credential.data().status !== 'active' || credential.data().identityType !== 'student') throw new HttpsError('not-found', 'Active credential not found.');
    const payload = Buffer.from(JSON.stringify({ credentialId, exp: Date.now() + Math.min(Math.max(Number(d.ttlMs) || 300000, 60000), 900000), nonce: randomBytes(12).toString('base64url') })).toString('base64url');
    return { cardToken: `${payload}.${signCardPayload(payload)}`, expiresAt: JSON.parse(Buffer.from(payload, 'base64url').toString('utf8')).exp };
  });

  api.checkServiceEntitlement = onCall({ secrets: ["ENTITLEMENT_CARD_TOKEN_KEY"] }, async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId); const terminalId = text(d.terminalId); const token = text(d.cardToken, 1024); const nonce = text(d.nonce, 128); const timestamp = Number(d.timestamp);
    if (!schoolId || !terminalId || !token || !nonce || !Number.isFinite(timestamp) || Math.abs(Date.now() - timestamp) > 120000) throw new HttpsError('invalid-argument', 'Invalid terminal request.');
    const terminal = (await db.doc(`schools/${schoolId}/entitlement_terminals/${terminalId}`).get()).data();
    if (!terminal || terminal.status !== 'active') throw new HttpsError('permission-denied', 'Terminal is not active.');
    // The raw terminal secret is supplied only over authenticated TLS and is
    // compared against a retained SHA-256 hash.  It is intentionally never
    // logged or returned after registration.  Nonce + timestamp make a
    // captured request non-replayable.
    const terminalSecret = text(d.terminalSecret, 256);
    if (!terminalSecret || hash(terminalSecret) !== terminal.secretHash) throw new HttpsError('permission-denied', 'Terminal authentication failed.');
    const nonceRef = db.doc(`schools/${schoolId}/entitlement_terminal_nonces/${terminalId}_${hash(nonce)}`);
    const card = readCardToken(token);
    const credential = await db.doc(`schools/${schoolId}/credentials/${card.credentialId}`).get();
    if (!credential.exists || credential.data().status !== 'active' || credential.data().identityType !== 'student') throw new HttpsError('permission-denied', 'Credential denied.');
    const studentId = credential.data().identityId; const outcome = await db.runTransaction(async (tx) => { if ((await tx.get(nonceRef)).exists) throw new HttpsError('permission-denied', 'Replay denied.'); tx.set(nonceRef, { expiresAt: Timestamp.fromMillis(Date.now() + 300000), createdAt: FieldValue.serverTimestamp() }); return compute({ schoolId, studentId, service: terminal.service }); });
    const decision = ['allowed', 'overrideActive'].includes(outcome.status) ? 'allow' : outcome.status === 'blocked' ? 'deny' : 'needsStaffReview';
    await db.collection(`schools/${schoolId}/entitlement_taps`).add({ studentId, service: terminal.service, terminalId, decision, reasonCode: outcome.reasonCode, source: outcome.source, overrideId: outcome.overrideId || null, at: FieldValue.serverTimestamp(), syncStatus: 'online' });
    return { decision, service: terminal.service, reasonCode: outcome.reasonCode, expiry: outcome.expiresAt ? millis(outcome.expiresAt) : null };
  });
  return api;
};
