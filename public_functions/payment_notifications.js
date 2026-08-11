const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');
const { notifyOwners } = require('./owner_notification_engine');
const { RESEND_API_KEY } = require('./email/email_service');
const { enqueueTemplatedEmail } = require('./email/transactional_queue');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

function text(value, max = 180) {
  return String(value ?? '').trim().slice(0, max);
}

const EMAIL_SECRETS = [
  'SMTP_HOST',
  'SMTP_PORT',
  'SMTP_USER',
  'SMTP_PASS',
  'SMTP_FROM',
  'OWNER_NOTIFICATION_EMAIL',
  RESEND_API_KEY,
];

function reviewable(payment) {
  const status = String(payment?.status || '').toLowerCase();
  const proof = text(
    payment?.proofUrl || payment?.paymentProofUrl || payment?.proofPath ||
      payment?.proofStoragePath || payment?.receiptUrl,
    1000,
  );
  return ['pending', 'under_review', 'pending_review', 'pending_verification'].includes(status) && Boolean(proof);
}

async function applicantEmailFor(payment) {
  const uid = text(payment?.submittedByUid, 180);
  if (!uid) return '';
  try {
    const userSnap = await db.collection('users').doc(uid).get();
    return text(userSnap.data()?.email, 200);
  } catch (error) {
    console.error('Manual payment applicant email lookup failed', uid, error);
    return '';
  }
}

function amountLabel(payment) {
  const amount = Math.max(0, Math.round(Number(payment?.submittedAmount || payment?.amount || 0)));
  return `UGX ${amount.toLocaleString('en-US')}`;
}

function methodLabel(payment) {
  const method = String(payment?.method || '').toLowerCase();
  if (method === 'bank') return 'Centenary Bank';
  if (method === 'airtel') return 'Airtel Money';
  if (method === 'cash') return 'Cash';
  return 'MTN Mobile Money';
}

/** Notify the SaaS Owner exactly once when a payment becomes reviewable. */
exports.notifyOwnerOfManualPayment = onDocumentWritten(
  {
    region: 'europe-west1',
    document: 'manual_subscription_payments/{paymentId}',
    secrets: EMAIL_SECRETS,
  },
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;

    const payment = after.data() || {};
    const before = event.data?.before?.exists ? (event.data.before.data() || {}) : {};
    const paymentId = event.params.paymentId;
    const schoolName = text(payment.schoolName, 160) || 'A school';
    const afterStatus = String(payment.status || '').toLowerCase();
    const beforeStatus = String(before.status || '').toLowerCase();

    if (reviewable(payment) && !reviewable(before)) {
      const amount = Math.max(0, Math.round(Number(payment.submittedAmount || payment.amount || 0)));
      const method = String(payment.method || '').toLowerCase() === 'bank' ? 'bank' : 'mtn';
      const ownerMethodLabel = method === 'bank' ? 'Centenary Bank' : 'MTN Mobile Money';
      const ownerAmountLabel = `UGX ${amount.toLocaleString('en-US')}`;

      await notifyOwners({
        // payments.js already creates payment_<id> in the owner feed. Reusing
        // that id makes the durable in-app record and push/email delivery one
        // event instead of two nearly identical notification cards.
        eventId: `payment_${paymentId}`,
        eventType: 'Payment proof submitted',
        title: 'Payment verification required',
        body: `${schoolName} submitted ${ownerAmountLabel} via ${ownerMethodLabel}. Confirm the money was received before activating access.`,
        schoolName,
        data: {
          type: 'manual_subscription_payment',
          notificationType: 'custom',
          priority: 'high',
          sourceModule: 'super_admin',
          sourceEntityId: paymentId,
          paymentId,
          schoolId: text(payment.schoolId, 180),
          schoolName,
          amount: String(amount),
          amountUgx: String(amount),
          method,
        },
      });

      await enqueueTemplatedEmail({
        eventId: `payment_proof_received_${paymentId}`,
        templateId: 'payment_proof_received',
        to: await applicantEmailFor(payment),
        data: { schoolName, paymentId, amountLabel: amountLabel(payment), methodLabel: methodLabel(payment) },
      });

      await notifyOwners({
        eventId: `billing_action_required_${paymentId}`,
        eventType: 'Billing action required',
        title: 'Billing action required',
        body: `${schoolName} submitted ${ownerAmountLabel} via ${ownerMethodLabel}. Verify the payment to activate or renew access.`,
        schoolName,
        data: {
          type: 'billing_action_required',
          notificationType: 'custom',
          priority: 'high',
          sourceModule: 'super_admin',
          sourceEntityId: paymentId,
          paymentId,
          schoolId: text(payment.schoolId, 180),
          schoolName,
          amountUgx: String(amount),
          method,
        },
      }).catch((error) => console.error('Owner billing_action_required notice failed', paymentId, error));
      return;
    }

    if (afterStatus === 'approved' && beforeStatus !== 'approved') {
      const expiryMs = Number(payment.subscriptionExpiry || 0);
      const expiryLabel = expiryMs > 0 ? new Date(expiryMs).toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' }) : '';
      const recipient = await applicantEmailFor(payment);
      const paymentType = String(payment.paymentType || '').toLowerCase();

      await enqueueTemplatedEmail({
        eventId: `manual_payment_approved_${paymentId}`,
        templateId: 'manual_payment_approved',
        to: recipient,
        data: {
          schoolName,
          paymentId,
          amountLabel: amountLabel(payment),
          planLabel: text(payment.planId, 60),
          expiryLabel,
        },
      });

      await enqueueTemplatedEmail({
        eventId: `payment_receipt_${paymentId}`,
        templateId: 'payment_receipt',
        to: recipient,
        data: {
          schoolName,
          paymentId,
          amountLabel: amountLabel(payment),
          methodLabel: methodLabel(payment),
          dateLabel: new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' }),
        },
      });

      // subscription_activated on first-ever activation, subscription_renewed
      // on every payment after that — matches the activation/renewal
      // distinction submitManualPayment and approveManualPayment already
      // compute (payment.paymentType), so this doesn't invent new state.
      await enqueueTemplatedEmail({
        eventId: `${paymentType === 'renewal' ? 'subscription_renewed' : 'subscription_activated'}_${paymentId}`,
        templateId: paymentType === 'renewal' ? 'subscription_renewed' : 'subscription_activated',
        to: recipient,
        data: {
          schoolName,
          amountLabel: amountLabel(payment),
          planLabel: text(payment.planId, 60),
          expiryLabel,
        },
      });
      return;
    }

    if (afterStatus === 'rejected' && beforeStatus !== 'rejected') {
      await enqueueTemplatedEmail({
        eventId: `manual_payment_rejected_${paymentId}`,
        templateId: 'manual_payment_rejected',
        to: await applicantEmailFor(payment),
        data: { schoolName, paymentId, amountLabel: amountLabel(payment), reason: text(payment.rejectionReason, 500) },
      });
    }
  },
);
