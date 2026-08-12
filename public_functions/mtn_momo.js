const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { getMtnConfig, MTN_MOMO_SECRETS } = require('./mtn_config');
const { normalizeUgandaMsisdn, maskMsisdn } = require('./phone_utils');
const { mtnRequestToPay, mtnGetStatus, mapMtnStatus, newReferenceId } = require('./mtn_client');
const { notifyOwners } = require('./owner_notification_engine');
const { enqueueTemplatedEmail } = require('./email/transactional_queue');
const { RESEND_API_KEY } = require('./email/email_service');
const { text, resolveSubscriber, schoolAdminEmail } = require('./payments').__internal;

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

// Same precedent list as functions/index.js's BILLING_ROLES - duplicated
// here (not imported) since functions/ and public_functions/ are separate
// deployable codebases that cannot share code directly.
const BILLING_ROLES = ['director', 'headTeacher', 'schoolAdmin', 'bursar'];

const PAYMENT_ATTEMPT_STALE_MS = 10 * 60 * 1000; // 10 minutes
const ALL_SECRETS = [...MTN_MOMO_SECRETS, RESEND_API_KEY];

async function requireBillingRole(request) {
  if (!request.auth?.uid) {
    throw new HttpsError('unauthenticated', 'You must be signed in to make a subscription payment.');
  }
  const userSnap = await db.collection('users').doc(request.auth.uid).get();
  const user = userSnap.exists ? userSnap.data() || {} : null;
  const schoolId = text(user?.schoolId, 180);
  const role = text(user?.role, 40);
  if (!user || !schoolId || !BILLING_ROLES.includes(role)) {
    throw new HttpsError('permission-denied', 'You are not authorized to make subscription payments for this school.');
  }
  return { uid: request.auth.uid, schoolId, role };
}

async function writeAudit(tx, { action, schoolId, paymentId, actorUserId, metadata = {} }) {
  const auditRef = db.collection('super_admin_audit_logs').doc();
  const entry = {
    id: auditRef.id,
    tenantId: schoolId,
    schoolId,
    paymentId,
    invoiceId: null,
    actorUserId: actorUserId || null,
    provider: 'mtn_momo',
    action,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    device: 'School Pulse App',
    metadata,
  };
  if (tx) tx.set(auditRef, entry);
  else await auditRef.set(entry);
}

/**
 * exports.initiateMtnPayment - creates a payments/{paymentId} record and
 * pushes an MTN Request to Pay prompt to the school admin's phone. Never
 * trusts an amount from the client: the plan price is always re-read from
 * subscription_plans server-side.
 */
exports.initiateMtnPayment = onCall({ region: 'europe-west1', secrets: ALL_SECRETS }, async (request) => {
  const caller = await requireBillingRole(request);

  const rawPhone = request.data?.phoneNumber;
  let msisdn;
  try {
    msisdn = normalizeUgandaMsisdn(rawPhone);
  } catch (_) {
    throw new HttpsError('invalid-argument', 'Enter a valid Uganda MTN Mobile Money number.');
  }

  const schoolRef = db.collection('schools').doc(caller.schoolId);
  const schoolSnap = await schoolRef.get();
  if (!schoolSnap.exists) throw new HttpsError('failed-precondition', 'Your school could not be found.');
  const school = schoolSnap.data() || {};
  const planId = text(school.subscriptionPlanId, 80);
  if (!planId) throw new HttpsError('failed-precondition', 'This school does not have a subscription plan configured.');

  const planSnap = await db.collection('subscription_plans').doc(planId).get();
  if (!planSnap.exists) throw new HttpsError('failed-precondition', 'This subscription plan is no longer available.');
  const plan = planSnap.data() || {};
  const realPlanPriceUgx = Math.round(Number(plan.price || 0));
  if (realPlanPriceUgx <= 0) {
    throw new HttpsError('failed-precondition', 'The SaaS Owner must configure a price for this plan before payment can be made.');
  }

  const metadata = school.metadata && typeof school.metadata === 'object' ? school.metadata : {};
  const paymentType = metadata.hasEverActivated === true ? 'renewal' : 'activation';
  const termLengthDays = Math.max(1, Math.round(Number(plan.termLengthDays || 120)));
  const nowMs = Date.now();

  const paymentsCollection = db.collection('mtn_payments');
  const config = getMtnConfig();
  const serverTime = admin.firestore.FieldValue.serverTimestamp();

  // Single atomic transaction for the whole check-and-create sequence.
  // Splitting the "is there already a pending attempt" query and the "create
  // a new one" write into two separate transactions would leave a race
  // window: two concurrent taps could each observe no pending attempt in
  // their own read, then both proceed to create a doc and both call MTN.
  // Firestore's transaction conflict detection only protects a query +
  // write pair when they happen inside the same transaction.
  const { paymentId, reused, reusedStatus } = await db.runTransaction(async (tx) => {
    const pendingSnap = await tx.get(
      paymentsCollection
        .where('schoolId', '==', caller.schoolId)
        .where('status', 'in', ['CREATED', 'PENDING'])
        .limit(1),
    );

    if (!pendingSnap.empty) {
      const existingDoc = pendingSnap.docs[0];
      const existing = existingDoc.data() || {};
      const createdAtMs = existing.createdAt?.toMillis ? existing.createdAt.toMillis() : 0;
      const isFresh = createdAtMs > 0 && nowMs - createdAtMs < PAYMENT_ATTEMPT_STALE_MS;
      if (isFresh) {
        return { paymentId: existingDoc.id, reused: true, reusedStatus: existing.status };
      }
      // Stale - mark expired so a new attempt can be created below, in the
      // same transaction that creates it.
      tx.set(existingDoc.ref, { status: 'EXPIRED', updatedAt: serverTime }, { merge: true });
    }

    const newPaymentId = newReferenceId();
    const newPaymentRef = paymentsCollection.doc(newPaymentId);
    tx.set(newPaymentRef, {
      id: newPaymentId,
      schoolId: caller.schoolId,
      schoolName: text(school.name, 160),
      planId,
      planName: text(plan.name, 80),
      paymentType,
      provider: 'mtn_momo',
      status: 'CREATED',
      amount: config.currency === 'EUR' ? config.sandboxTestAmount : String(realPlanPriceUgx),
      currency: config.currency,
      realPlanPriceUgx,
      termLengthDays,
      maxStudents: Number(plan.maxStudents || 0),
      maxStaff: Number(plan.maxStaff || 0),
      storageLimitGb: Number(plan.storageLimitGb || 0),
      phoneNumberMasked: maskMsisdn(msisdn),
      targetEnvironment: config.targetEnvironment,
      actorUserId: caller.uid,
      createdAt: serverTime,
      updatedAt: serverTime,
      mtnReferenceId: newPaymentId,
      mtnFinancialTransactionId: null,
      failureReason: null,
      settledAt: null,
      subscriptionExpiry: null,
    });
    await writeAudit(tx, {
      action: 'MTN_PAYMENT_CREATED',
      schoolId: caller.schoolId,
      paymentId: newPaymentId,
      actorUserId: caller.uid,
      metadata: { planId, amount: realPlanPriceUgx, currency: 'UGX', paymentType },
    });
    return { paymentId: newPaymentId, reused: false, reusedStatus: null };
  });

  if (reused) {
    return { ok: true, paymentId, status: reusedStatus, reused: true };
  }

  const paymentRef = paymentsCollection.doc(paymentId);

  // Sandbox never charges the real user number - a fixed sandbox test MSISDN
  // is sent to MTN instead, while the real number stays only as a masked
  // field on the payment doc.
  const payerMsisdn = config.targetEnvironment === 'sandbox' ? config.sandboxTestMsisdn : msisdn;

  const result = await mtnRequestToPay({
    referenceId: paymentId,
    amount: config.currency === 'EUR' ? config.sandboxTestAmount : String(realPlanPriceUgx),
    currency: config.currency,
    payerMsisdn,
    payerMessage: 'School Pulse subscription payment',
    payeeNote: 'School Pulse',
  });

  if (result.ok) {
    await paymentRef.set({ status: 'PENDING', updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    await writeAudit(null, {
      action: 'MTN_PAYMENT_SUBMITTED',
      schoolId: caller.schoolId,
      paymentId,
      actorUserId: caller.uid,
      metadata: { targetEnvironment: config.targetEnvironment },
    });
    return { ok: true, paymentId, status: 'PENDING' };
  }

  await paymentRef.set({
    status: 'FAILED',
    failureReason: result.safeError,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
  await writeAudit(null, {
    action: 'MTN_PAYMENT_FAILED',
    schoolId: caller.schoolId,
    paymentId,
    actorUserId: caller.uid,
    metadata: { httpStatus: result.httpStatus || null },
  });
  return { ok: true, paymentId, status: 'FAILED' };
});

/**
 * Pure settlement math - identical formula to approveManualPayment's
 * activation-period calculation, extracted here so it's unit-testable
 * without a Firestore emulator. Renewal extends from the existing expiry
 * only if that expiry is still in the future; otherwise (activation, or a
 * renewal paid after the term already lapsed) the new period starts now.
 */
function computeSettlement(payment, school, nowMs) {
  const termLengthDays = Math.max(1, Math.round(Number(payment.termLengthDays || 120)));
  const existingExpiry = Number(school.subscriptionExpiry || 0);
  const startMs = payment.paymentType === 'renewal' && existingExpiry > nowMs ? existingExpiry : nowMs;
  const expiryMs = startMs + termLengthDays * 24 * 60 * 60 * 1000;
  return { termLengthDays, startMs, expiryMs };
}

/**
 * Idempotent settlement: safe to call any number of times for the same
 * paymentId once MTN has confirmed SUCCESSFUL. Activates/renews the
 * school's subscription using the exact same math approveManualPayment
 * already uses for manual payments, so the two payment paths stay
 * consistent.
 */
async function checkAndSettle(paymentId) {
  const paymentRef = db.collection('mtn_payments').doc(paymentId);
  const nowMs = Date.now();
  const serverTime = admin.firestore.FieldValue.serverTimestamp();

  const settlement = await db.runTransaction(async (tx) => {
    const paymentSnap = await tx.get(paymentRef);
    if (!paymentSnap.exists) throw new HttpsError('not-found', 'Payment not found.');
    const payment = paymentSnap.data() || {};

    if (payment.status === 'SUCCESSFUL') {
      return { alreadySettled: true, payment };
    }

    const schoolId = text(payment.schoolId, 180);
    const schoolRef = db.collection('schools').doc(schoolId);
    const schoolSnap = await tx.get(schoolRef);
    if (!schoolSnap.exists) throw new HttpsError('failed-precondition', 'The school linked to this payment no longer exists.');
    const school = schoolSnap.data() || {};
    const metadata = school.metadata && typeof school.metadata === 'object' ? school.metadata : {};

    const { termLengthDays, startMs, expiryMs } = computeSettlement(payment, school, nowMs);

    tx.set(schoolRef, {
      status: 'active',
      subscriptionPlanId: text(payment.planId, 80),
      subscriptionExpiry: expiryMs,
      accessMode: 'full',
      subscription: {
        planId: text(payment.planId, 80),
        planName: text(payment.planName, 80),
        price: Number(payment.realPlanPriceUgx || 0),
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
        lastPaymentMethod: 'mtn_momo_auto',
      },
    }, { merge: true });

    tx.set(paymentRef, {
      status: 'SUCCESSFUL',
      settledAt: serverTime,
      updatedAt: serverTime,
      subscriptionExpiry: expiryMs,
    }, { merge: true });

    tx.set(db.collection('payment_transactions').doc(paymentId), {
      id: paymentId,
      schoolId,
      provider: 'mtn_momo_auto',
      phoneNumber: text(payment.phoneNumberMasked, 30),
      amountUgx: Number(payment.realPlanPriceUgx || 0),
      status: 'success',
      reference: text(payment.mtnFinancialTransactionId || paymentId, 120),
      createdAt: serverTime,
      paymentType: text(payment.paymentType, 20),
      planId: text(payment.planId, 80),
    }, { merge: true });

    await writeAudit(tx, {
      action: 'SUBSCRIPTION_ACTIVATED_FROM_PAYMENT',
      schoolId,
      paymentId,
      actorUserId: payment.actorUserId,
      metadata: { amount: Number(payment.realPlanPriceUgx || 0), currency: 'UGX', subscriptionExpiry: expiryMs },
    });
    await writeAudit(tx, {
      action: 'MTN_PAYMENT_SUCCESSFUL',
      schoolId,
      paymentId,
      actorUserId: payment.actorUserId,
      metadata: { amount: Number(payment.realPlanPriceUgx || 0), currency: 'UGX' },
    });

    return { alreadySettled: false, schoolId, expiryMs, startMs, payment };
  });

  if (settlement.alreadySettled) return settlement;

  // Notifications are network calls that must not hold the Firestore
  // transaction open - fired after commit, best-effort.
  const { schoolId, expiryMs, startMs, payment } = settlement;
  const amountLabel = `UGX ${Number(payment.realPlanPriceUgx || 0).toLocaleString('en-US')}`;
  const expiryLabel = new Date(expiryMs).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
  const startLabel = new Date(startMs).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });
  try {
    await notifyOwners({
      eventId: `mtn_payment_successful_${paymentId}`,
      eventType: 'MTN Mobile Money payment received',
      title: 'MTN Mobile Money payment received',
      body: `${text(payment.schoolName, 160)} paid ${amountLabel} via MTN Mobile Money. Subscription activated automatically.`,
      schoolName: text(payment.schoolName, 160),
      data: {
        type: 'mtn_momo_payment',
        notificationType: 'custom',
        priority: 'normal',
        sourceModule: 'super_admin',
        sourceEntityId: paymentId,
        paymentId,
        schoolId,
        schoolName: text(payment.schoolName, 160),
        amountUgx: String(Number(payment.realPlanPriceUgx || 0)),
        method: 'mtn_momo_auto',
      },
    });
  } catch (error) {
    console.error('MTN payment owner notification failed', paymentId, error);
  }

  try {
    const recipient = await schoolAdminEmail(schoolId);
    await enqueueTemplatedEmail({
      eventId: `mobile_money_payment_success_${paymentId}`,
      templateId: 'mobile_money_payment_success',
      to: recipient,
      data: {
        schoolName: text(payment.schoolName, 160),
        paymentId,
        amountLabel,
        amount: amountLabel,
        planLabel: text(payment.planName, 80),
        startLabel,
        expiryLabel,
      },
    });
  } catch (error) {
    console.error('MTN payment success email failed', paymentId, error);
  }

  return { alreadySettled: false, schoolId, subscriptionExpiry: expiryMs };
}

async function handleFailedPayment(paymentRef, payment, mappedStatus) {
  const serverTime = admin.firestore.FieldValue.serverTimestamp();
  const failureReason = `mtn_status_${mappedStatus.toLowerCase()}`;
  await paymentRef.set({ status: mappedStatus, failureReason, updatedAt: serverTime }, { merge: true });
  await writeAudit(null, {
    action: 'MTN_PAYMENT_FAILED',
    schoolId: payment.schoolId,
    paymentId: payment.id,
    actorUserId: payment.actorUserId,
    metadata: { mappedStatus },
  });

  const amountLabel = `UGX ${Number(payment.realPlanPriceUgx || 0).toLocaleString('en-US')}`;
  try {
    const recipient = await schoolAdminEmail(payment.schoolId);
    await enqueueTemplatedEmail({
      eventId: `mobile_money_payment_failed_${payment.id}`,
      templateId: 'mobile_money_payment_failed',
      to: recipient,
      data: {
        schoolName: text(payment.schoolName, 160),
        paymentId: payment.id,
        amountLabel,
        amount: amountLabel,
        reason: mappedStatus === 'EXPIRED' ? 'The payment request expired before it was approved.' : 'The payment was not completed.',
      },
    });
  } catch (error) {
    console.error('MTN payment failure email failed', payment.id, error);
  }
}

const TERMINAL_STATUSES = new Set(['SUCCESSFUL', 'FAILED', 'EXPIRED', 'CANCELLED']);

/**
 * exports.checkMtnPaymentStatus - client-driven polling endpoint. The
 * Flutter bloc calls this on a bounded backoff schedule; each call performs
 * at most one MTN status GET, so the function stays short-lived.
 */
exports.checkMtnPaymentStatus = onCall({ region: 'europe-west1', secrets: ALL_SECRETS }, async (request) => {
  const caller = await requireBillingRole(request);
  const paymentId = text(request.data?.paymentId, 120);
  if (!paymentId) throw new HttpsError('invalid-argument', 'paymentId is required.');

  const paymentRef = db.collection('mtn_payments').doc(paymentId);
  const paymentSnap = await paymentRef.get();
  if (!paymentSnap.exists) throw new HttpsError('not-found', 'Payment not found.');
  const payment = { id: paymentId, ...(paymentSnap.data() || {}) };

  if (payment.schoolId !== caller.schoolId) {
    throw new HttpsError('permission-denied', 'This payment does not belong to your school.');
  }

  if (TERMINAL_STATUSES.has(payment.status)) {
    return payment;
  }

  const mtnResponse = await mtnGetStatus({ referenceId: paymentId });
  if (!mtnResponse) {
    // Transport/HTTP failure talking to MTN - leave status as-is, client will retry.
    return payment;
  }

  const mappedStatus = mapMtnStatus(mtnResponse.status);
  if (mappedStatus !== payment.status) {
    await writeAudit(null, {
      action: 'MTN_PAYMENT_STATUS_CHECKED',
      schoolId: caller.schoolId,
      paymentId,
      actorUserId: caller.uid,
      metadata: { mappedStatus },
    });
  }

  if (mtnResponse.financialTransactionId && !payment.mtnFinancialTransactionId) {
    await paymentRef.set({
      mtnFinancialTransactionId: text(mtnResponse.financialTransactionId, 80),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    payment.mtnFinancialTransactionId = text(mtnResponse.financialTransactionId, 80);
  }

  if (mappedStatus === 'SUCCESSFUL' && payment.status !== 'SUCCESSFUL') {
    await checkAndSettle(paymentId);
  } else if (['FAILED', 'EXPIRED', 'CANCELLED'].includes(mappedStatus) && !TERMINAL_STATUSES.has(payment.status)) {
    await handleFailedPayment(paymentRef, payment, mappedStatus);
  }

  const finalSnap = await paymentRef.get();
  return { id: paymentId, ...(finalSnap.data() || {}) };
});

exports.__test__ = { checkAndSettle, computeSettlement, requireBillingRole, PAYMENT_ATTEMPT_STALE_MS };
