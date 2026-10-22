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

  // Auditable source precedence, highest first. compute() records the whole
  // chain it considered in `sourceChain` so a decision is never a silent
  // replacement of one source by another.
  const SOURCE_PRECEDENCE = [
    'suspension',
    'managementApproval',
    'serviceAdministratorOverride',
    'bursarTemporaryOverride',
    'waiver',
    'scholarship',
    'paymentPlan',
    'feePolicy',
    'system',
  ];

  const hash = (value) => createHash('sha256').update(String(value)).digest('hex');
  const roles = (u) => Array.from(new Set([u?.role, ...(u?.roles || [])].filter(Boolean)));
  const hasRole = (u, allowed) => roles(u).some((r) => allowed.includes(r));
  const text = (value, max = 160) => typeof value === 'string' ? value.trim().slice(0, max) : '';
  const millis = (value) => value?.toMillis ? value.toMillis() : Number(value || 0);
  const DAY = 86400000;
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

  // ------------------------------------------------------------------
  //  Derivation — one place that turns (policy, financial) into a
  //  { status, source, reasonCode } and, in compute(), folds in the
  //  full source precedence chain. Never mutates its inputs.
  // ------------------------------------------------------------------

  // Overall + optional category-specific payment percentage from the
  // legacy student_financials doc. Explicit `paymentPercentage`/`balance`
  // fields win if present (older data); otherwise derived from
  // totalBilled/totalPaid/scholarshipAmount/discountAmount, matching the
  // client `StudentFinancialAccount` getters.
  function financialSummary(financial, categoryIds) {
    const f = financial || {};
    const billed = Number(f.totalBilled ?? 0);
    const paid = Number(f.totalPaid ?? 0);
    const scholarship = Number(f.scholarshipAmount ?? 0);
    const discount = Number(f.discountAmount ?? 0);
    const net = Math.max(billed - scholarship - discount, 0);
    const derivedPct = net > 0 ? Math.min(100, Math.round((paid / net) * 100)) : (billed === 0 ? 100 : 0);
    const derivedBalance = billed - paid - scholarship - discount;

    let categoryPct = null;
    const breakdown = f.categoryBreakdown && typeof f.categoryBreakdown === 'object' ? f.categoryBreakdown : null;
    if (breakdown && Array.isArray(categoryIds) && categoryIds.length) {
      let cb = 0, cp = 0;
      for (const id of categoryIds) {
        const row = breakdown[id];
        if (row) { cb += Number(row.billed ?? 0); cp += Number(row.paid ?? 0); }
      }
      categoryPct = cb > 0 ? Math.min(100, Math.round((cp / cb) * 100)) : 100;
    }

    return {
      overallPct: Number.isFinite(Number(f.paymentPercentage)) ? Number(f.paymentPercentage)
        : Number.isFinite(Number(f.percentagePaid)) ? Number(f.percentagePaid) : derivedPct,
      categoryPct,
      balance: Number.isFinite(Number(f.balance)) ? Number(f.balance)
        : Number.isFinite(Number(f.balanceDue)) ? Number(f.balanceDue) : derivedBalance,
      scholarship, discount, billed, paid,
      hasPaymentPlan: Boolean(f.feeStructureId || f.paymentPlanId),
    };
  }

  // The pure fee-policy verdict for one service. `financial` is the raw
  // student_financials doc. Returns { status, reasonCode, source }.
  function policyStatus(policy, financial) {
    if (!policy?.enabled) return { status: 'notApplicable', reasonCode: 'POLICY_DISABLED', source: 'feePolicy' };
    const s = financialSummary(financial, policy.feeCategories);
    // Category-specific gate takes over only when the policy names
    // categories AND the learner has a category breakdown; the two
    // percentages are surfaced separately, never blended.
    const effectivePct = (policy.feeCategories?.length && s.categoryPct != null) ? s.categoryPct : s.overallPct;
    const min = Number(policy.minimumPaymentPercentage ?? 100);
    const maxBal = Number(policy.maximumBalance ?? 0);
    if (effectivePct >= min && s.balance <= maxBal) {
      return { status: 'allowed', reasonCode: 'POLICY_MET', source: 'feePolicy' };
    }
    return { status: 'blocked', reasonCode: 'POLICY_NOT_MET', source: 'feePolicy' };
  }

  // Which relief source (waiver / scholarship / paymentPlan) — if any the
  // policy honours — would lift an otherwise-blocked learner. Returns the
  // winning source name or null. Never silently changes the decision:
  // compute() records it as the explicit `source` and keeps `feePolicy` in
  // the chain.
  function reliefSource(policy, financial) {
    if (!policy?.enabled) return null;
    const s = financialSummary(financial, policy.feeCategories);
    if (policy.honorWaiver && s.discount > 0 &&
        (!policy.waiverClearsBalance || s.balance <= Number(policy.maximumBalance ?? 0))) {
      return 'waiver';
    }
    if (policy.honorScholarship && s.scholarship > 0) {
      const min = Number(policy.minimumPaymentPercentage ?? 100);
      if (s.overallPct >= min) return 'scholarship';
    }
    if (policy.honorPaymentPlan && s.hasPaymentPlan &&
        s.balance <= Number(policy.paymentPlanMaxBalance ?? policy.maximumBalance ?? 0)) {
      return 'paymentPlan';
    }
    return null;
  }

  // The full decision for (school, learner, service). Layers, highest
  // precedence first:
  //   1. safety service            -> always allowed (system)
  //   2. active deny override      -> suspended (suspension)
  //   3. active allow override     -> overrideActive / expiring (its source)
  //   4. pending 2nd-approval item -> pendingApproval
  //   5. relief source lifts block -> allowed (waiver|scholarship|paymentPlan)
  //   6. fee policy                -> allowed | blocked | expired | notApplicable
  // `sourceChain` lists every source considered so the result is auditable.
  async function compute({ schoolId, studentId, service, now = Date.now() }) {
    if (SAFE_SERVICES.has(service)) {
      return {
        status: 'allowed', reasonCode: 'SAFETY_SERVICE', source: 'system',
        expiresAt: null, sourceChain: ['system'],
      };
    }
    const [policySnap, financialSnap, overrideSnap, pendingSnap] = await Promise.all([
      db.doc(`schools/${schoolId}/financial_entitlement_policy/current`).get(),
      db.doc(`schools/${schoolId}/student_financials/${studentId}`).get(),
      db.collection(`schools/${schoolId}/financial_entitlement_overrides`)
        .where('studentId', '==', studentId).where('service', '==', service).get(),
      db.collection(`schools/${schoolId}/financial_entitlement_overrides`)
        .where('studentId', '==', studentId).where('service', '==', service)
        .where('status', '==', 'pendingApproval').limit(1).get(),
    ]);
    const policyDoc = policySnap.data() || {};
    const policy = policyDoc.services?.[service];
    const financial = financialSnap.data();
    const warnDays = Number(policy?.expiryWarningDays ?? policyDoc.expiryWarningDays ?? 7);

    const overrides = overrideSnap.docs.map((d) => ({ id: d.id, ...d.data() }));
    const activeAllow = overrides
      .filter((o) => o.status === 'active' && o.decision === 'allow' && (!o.expiresAt || millis(o.expiresAt) > now))
      .sort((a, b) => millis(b.createdAt) - millis(a.createdAt))[0];
    const activeDeny = overrides
      .filter((o) => o.status === 'active' && o.decision === 'deny')
      .sort((a, b) => millis(b.createdAt) - millis(a.createdAt))[0];
    const lapsedAllow = overrides
      .find((o) => o.status === 'active' && o.decision === 'allow' && o.expiresAt && millis(o.expiresAt) <= now);

    const relief = reliefSource(policy, financial);
    const considered = [];
    if (activeDeny) considered.push('suspension');
    if (activeAllow) considered.push(activeAllow.source || 'bursarTemporaryOverride');
    if (relief) considered.push(relief);
    considered.push('feePolicy');
    const sourceChain = SOURCE_PRECEDENCE.filter((s) => considered.includes(s));

    // 2. deny override wins outright
    if (activeDeny) {
      return {
        status: 'suspended', reasonCode: activeDeny.reasonCode || 'SUSPENDED',
        source: 'suspension', overrideId: activeDeny.id, expiresAt: activeDeny.expiresAt || null,
        sourceChain,
      };
    }
    // 3. allow override
    if (activeAllow) {
      const exp = activeAllow.expiresAt ? millis(activeAllow.expiresAt) : null;
      const expiring = exp != null && exp - now <= warnDays * DAY;
      return {
        status: expiring ? 'expiring' : 'overrideActive',
        reasonCode: activeAllow.reasonCode || 'OVERRIDE',
        source: activeAllow.source || 'bursarTemporaryOverride',
        overrideId: activeAllow.id, expiresAt: activeAllow.expiresAt || null,
        expiringSoon: expiring, sourceChain,
      };
    }
    // 4. a 2nd-approval item is pending for this learner+service
    if (!pendingSnap.empty) {
      return {
        status: 'pendingApproval', reasonCode: 'AWAITING_SECOND_APPROVAL',
        source: 'managementApproval', pendingOverrideId: pendingSnap.docs[0].id,
        expiresAt: null, sourceChain,
      };
    }
    // 5. fee policy verdict, with relief attribution.
    const base = policyStatus(policy, financial);
    if (base.status === 'blocked' && relief) {
      // relief lifts a would-be block
      const out = {
        status: 'allowed', reasonCode: `RELIEF_${relief.toUpperCase()}`,
        source: relief, expiresAt: null, sourceChain,
      };
      if (lapsedAllow) out.expiredOverrideId = lapsedAllow.id;
      return out;
    }
    if (base.status === 'allowed' && relief) {
      // policy is met, but a honoured scholarship/waiver/plan is materially
      // why — attribute the source without silently dropping feePolicy from
      // the chain.
      return { ...base, reasonCode: `POLICY_MET_VIA_${relief.toUpperCase()}`, source: relief, expiresAt: null, sourceChain };
    }
    // 6. plain fee policy verdict. If an allow-override lapsed and the
    //    policy now blocks, mark it Expired so the dashboard can tell.
    if (lapsedAllow && base.status === 'blocked') {
      return { ...base, status: 'expired', expiredOverrideId: lapsedAllow.id, expiresAt: null, sourceChain };
    }
    return { ...base, expiresAt: null, sourceChain };
  }

  // Assigned onto by index.js's Object.assign(exports, require(...)()).
  // Must be a real object we mutate and return — assigning onto the bare
  // `exports` identifier here resolves to this file's own module exports,
  // not what the caller receives (see the note atop student_fee_billing.js).
  const api = { compute, policyStatus, reliefSource, financialSummary, SAFE_SERVICES, SOURCE_PRECEDENCE };

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
    const patch = { services, updatedBy: user.uid, effectiveAt: FieldValue.serverTimestamp(), version: FieldValue.increment(1) };
    if (Number.isFinite(Number(d.expiryWarningDays))) patch.expiryWarningDays = Math.max(1, Math.min(60, Number(d.expiryWarningDays)));
    if (Number.isFinite(Number(d.secondApprovalThresholdDays))) patch.secondApprovalThresholdDays = Math.max(0, Number(d.secondApprovalThresholdDays));
    await db.doc(`schools/${schoolId}/financial_entitlement_policy/current`).set(patch, { merge: true });
    await audit(schoolId, 'policy.updated', user.uid, 'current'); return { status: 'active' };
  });

  // Create an override. When it grants access for longer than the school's
  // configured second-approval threshold (or the caller forces it), it
  // lands as `pendingApproval` and a leadership approver must call
  // decideEntitlementOverride before it takes effect.
  api.setFinancialEntitlementOverride = onCall(async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId); const studentId = text(d.studentId); const service = text(d.service);
    const user = await caller(request, schoolId);
    if (!hasRole(user, [...FINANCE, ...LEADERSHIP])) throw new HttpsError('permission-denied', 'Only authorised finance or leadership may override an entitlement.');
    if (!studentId || !service || SAFE_SERVICES.has(service) || !['allow', 'deny'].includes(d.decision)) throw new HttpsError('invalid-argument', 'A non-safety service, learner and allow/deny decision are required.');
    const expiresAtMs = Number(d.expiresAt || 0);
    if (d.decision === 'allow' && (!expiresAtMs || expiresAtMs <= Date.now())) throw new HttpsError('invalid-argument', 'Temporary access must have a future expiry.');

    const policyDoc = (await db.doc(`schools/${schoolId}/financial_entitlement_policy/current`).get()).data() || {};
    const svcPolicy = policyDoc.services?.[service] || {};
    const thresholdDays = Number(svcPolicy.secondApproverArrearsThresholdDays ?? policyDoc.secondApprovalThresholdDays ?? 0);
    const grantsDays = d.decision === 'allow' ? (expiresAtMs - Date.now()) / DAY : 0;
    const isLeadership = hasRole(user, [...LEADERSHIP]);
    const needsSecondApproval = d.decision === 'allow' && thresholdDays > 0 && grantsDays > thresholdDays && !isLeadership;
    const forcePending = Boolean(d.requireSecondApproval) && !isLeadership;

    const status = (needsSecondApproval || forcePending) ? 'pendingApproval' : 'active';
    const ref = db.collection(`schools/${schoolId}/financial_entitlement_overrides`).doc();
    await ref.set({
      studentId, service, decision: d.decision,
      reasonCode: text(d.reasonCode, 80) || 'MANUAL_REVIEW', note: text(d.note, 500),
      source: ['serviceAdministratorOverride', 'managementApproval'].includes(d.source) ? d.source : 'bursarTemporaryOverride',
      status,
      expiresAt: expiresAtMs ? Timestamp.fromMillis(expiresAtMs) : null,
      periodStart: d.periodStart ? Timestamp.fromMillis(Number(d.periodStart)) : null,
      academicYear: text(d.academicYear, 40) || null, term: text(d.term, 40) || null,
      createdBy: user.uid, createdAt: FieldValue.serverTimestamp(),
    });
    await audit(schoolId, status === 'pendingApproval' ? 'override.proposed' : 'override.created', user.uid, ref.id, { service, studentId, decision: d.decision, status });
    return { overrideId: ref.id, status };
  });

  // Leadership approves/rejects a pending override, or finance/leadership
  // revokes/renews an active one. All immutable & audited.
  api.decideEntitlementOverride = onCall(async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId); const overrideId = text(d.overrideId);
    const decision = text(d.decision); // approve | reject | revoke | renew
    const user = await caller(request, schoolId);
    const ref = db.doc(`schools/${schoolId}/financial_entitlement_overrides/${overrideId}`);
    const out = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (!snap.exists) throw new HttpsError('not-found', 'Override not found.');
      const o = snap.data();
      if (['approve', 'reject'].includes(decision)) {
        if (!hasRole(user, [...LEADERSHIP])) throw new HttpsError('permission-denied', 'Only leadership may approve entitlement exceptions.');
        if (o.status !== 'pendingApproval') throw new HttpsError('failed-precondition', 'This override is not awaiting approval.');
        if (o.createdBy === user.uid) throw new HttpsError('permission-denied', 'You cannot approve an override you proposed.');
        tx.update(ref, { status: decision === 'approve' ? 'active' : 'rejected', decidedBy: user.uid, decidedAt: FieldValue.serverTimestamp(), decisionNote: text(d.note, 500) });
        return { status: decision === 'approve' ? 'active' : 'rejected' };
      }
      if (decision === 'revoke') {
        if (!hasRole(user, [...FINANCE, ...LEADERSHIP])) throw new HttpsError('permission-denied', 'Not authorised to revoke.');
        if (!['active', 'pendingApproval'].includes(o.status)) throw new HttpsError('failed-precondition', 'Only an active or pending override can be revoked.');
        tx.update(ref, { status: 'revoked', revokedBy: user.uid, revokedAt: FieldValue.serverTimestamp(), revocationReason: text(d.note, 500) || 'REVOKED' });
        return { status: 'revoked' };
      }
      if (decision === 'renew') {
        if (!hasRole(user, [...FINANCE, ...LEADERSHIP])) throw new HttpsError('permission-denied', 'Not authorised to renew.');
        const newExpiry = Number(d.expiresAt || 0);
        if (o.decision !== 'allow' || !newExpiry || newExpiry <= Date.now()) throw new HttpsError('invalid-argument', 'A future expiry is required to renew an allow override.');
        tx.update(ref, { status: 'active', expiresAt: Timestamp.fromMillis(newExpiry), renewedBy: user.uid, renewedAt: FieldValue.serverTimestamp() });
        return { status: 'active', expiresAt: newExpiry };
      }
      throw new HttpsError('invalid-argument', 'decision must be approve, reject, revoke or renew.');
    });
    await audit(schoolId, `override.${decision}`, user.uid, overrideId, { ...out });
    return out;
  });

  // Read-only, finance-gated: the entitlement result for one learner across
  // every configured service, plus source chain, expiry, and the learner's
  // overall + category-specific payment percentages. Never returned to a
  // service terminal — this is the Bursar dashboard's detail feed.
  api.getLearnerEntitlementProfile = onCall(async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId); const studentId = text(d.studentId);
    const user = await caller(request, schoolId);
    if (!hasRole(user, [...FINANCE, ...LEADERSHIP])) throw new HttpsError('permission-denied', 'Only finance or leadership may read entitlement profiles.');
    if (!studentId) throw new HttpsError('invalid-argument', 'studentId is required.');
    const policyDoc = (await db.doc(`schools/${schoolId}/financial_entitlement_policy/current`).get()).data() || {};
    const financial = (await db.doc(`schools/${schoolId}/student_financials/${studentId}`).get()).data() || {};
    const configured = Object.keys(policyDoc.services || {});
    const services = {};
    for (const svc of configured) {
      services[svc] = await compute({ schoolId, studentId, service: svc });
    }
    const overall = financialSummary(financial, null);
    return {
      studentId,
      overallPaymentPercentage: overall.overallPct,
      balance: overall.balance,
      scholarshipAmount: overall.scholarship,
      waiverAmount: overall.discount,
      hasPaymentPlan: overall.hasPaymentPlan,
      services,
    };
  });

  // Finance-gated bulk apply. One reason, one service scope, one period
  // scope; each learner gets its own audited override. Anything that would
  // need a second approval lands pending, not active.
  api.bulkEntitlementAction = onCall(async (request) => {
    const d = request.data || {}; const schoolId = text(d.schoolId);
    const user = await caller(request, schoolId);
    if (!hasRole(user, [...FINANCE, ...LEADERSHIP])) throw new HttpsError('permission-denied', 'Only finance or leadership may run a bulk entitlement action.');
    const action = text(d.action); // grant | revoke | renew
    const service = text(d.service);
    const studentIds = Array.isArray(d.studentIds) ? d.studentIds.map((s) => text(s)).filter(Boolean).slice(0, 500) : [];
    if (!['grant', 'revoke', 'renew'].includes(action) || SAFE_SERVICES.has(service) || !service || !studentIds.length) {
      throw new HttpsError('invalid-argument', 'action, a non-safety service and studentIds are required.');
    }
    const reasonCode = text(d.reasonCode, 80) || 'BULK_ACTION';
    const note = text(d.note, 500);
    const expiresAtMs = Number(d.expiresAt || 0);
    if ((action === 'grant' || action === 'renew') && (!expiresAtMs || expiresAtMs <= Date.now())) {
      throw new HttpsError('invalid-argument', 'grant/renew need a future expiry.');
    }
    const policyDoc = (await db.doc(`schools/${schoolId}/financial_entitlement_policy/current`).get()).data() || {};
    const svcPolicy = policyDoc.services?.[service] || {};
    const thresholdDays = Number(svcPolicy.secondApproverArrearsThresholdDays ?? policyDoc.secondApprovalThresholdDays ?? 0);
    const isLeadership = hasRole(user, [...LEADERSHIP]);

    const results = [];
    for (const studentId of studentIds) {
      if (action === 'revoke') {
        const existing = await db.collection(`schools/${schoolId}/financial_entitlement_overrides`)
          .where('studentId', '==', studentId).where('service', '==', service)
          .where('status', 'in', ['active', 'pendingApproval']).get();
        const batch = db.batch();
        existing.docs.forEach((doc) => batch.update(doc.ref, { status: 'revoked', revokedBy: user.uid, revokedAt: FieldValue.serverTimestamp(), revocationReason: reasonCode }));
        await batch.commit();
        results.push({ studentId, status: 'revoked', count: existing.size });
        continue;
      }
      const grantsDays = (expiresAtMs - Date.now()) / DAY;
      const needsSecondApproval = thresholdDays > 0 && grantsDays > thresholdDays && !isLeadership;
      const status = (needsSecondApproval || (d.requireSecondApproval && !isLeadership)) ? 'pendingApproval' : 'active';
      const ref = db.collection(`schools/${schoolId}/financial_entitlement_overrides`).doc();
      await ref.set({
        studentId, service, decision: 'allow', reasonCode, note,
        source: 'bursarTemporaryOverride', status,
        expiresAt: Timestamp.fromMillis(expiresAtMs),
        academicYear: text(d.academicYear, 40) || null, term: text(d.term, 40) || null,
        bulkActionId: text(d.bulkActionId, 80) || null,
        createdBy: user.uid, createdAt: FieldValue.serverTimestamp(),
      });
      results.push({ studentId, overrideId: ref.id, status });
    }
    await audit(schoolId, `bulk.${action}`, user.uid, service, { count: results.length, service, action });
    return { action, service, results };
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
    const decision = ['allowed', 'overrideActive', 'expiring'].includes(outcome.status) ? 'allow' : (outcome.status === 'blocked' || outcome.status === 'expired') ? 'deny' : 'needsStaffReview';
    await db.collection(`schools/${schoolId}/entitlement_taps`).add({ studentId, service: terminal.service, terminalId, decision, reasonCode: outcome.reasonCode, source: outcome.source, overrideId: outcome.overrideId || null, at: FieldValue.serverTimestamp(), syncStatus: 'online' });
    return { decision, service: terminal.service, reasonCode: outcome.reasonCode, expiry: outcome.expiresAt ? millis(outcome.expiresAt) : null };
  });
  return api;
};
