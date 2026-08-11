const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { notifyOwners } = require('./owner_notification_engine');

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
];

/**
 * A manual SaaS subscription payment becomes reviewable when the payment
 * submission has been persisted with a supported review status and a proof
 * file. Keep this aligned with payments.js, which currently writes
 * status=pending_verification and proofStoragePath.
 */
function reviewable(payment) {
  const status = String(payment?.status || '').trim().toLowerCase();
  const proof = text(
    payment?.proofStoragePath ||
      payment?.proofUrl ||
      payment?.paymentProofUrl ||
      payment?.proofPath ||
      payment?.receiptUrl,
    1000,
  );
  return [
    'pending_verification',
    'pending',
    'under_review',
    'pending_review',
  ].includes(status) && Boolean(proof);
}

function paymentMethod(value) {
  const method = String(value || '').trim().toLowerCase();
  if (method === 'airtel') return { id: 'airtel', label: 'Airtel Money' };
  if (method === 'bank') return { id: 'bank', label: 'Bank transfer' };
  if (method === 'cash') return { id: 'cash', label: 'Cash' };
  return { id: 'mtn', label: 'MTN Mobile Money' };
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
    if (!reviewable(payment) || reviewable(before)) return;

    const paymentId = event.params.paymentId;
    const schoolName = text(payment.schoolName, 160) || 'A school';
    const amount = Math.max(
      0,
      Math.round(Number(payment.submittedAmount || payment.amount || 0)),
    );
    const method = paymentMethod(payment.method);
    const amountLabel = `UGX ${amount.toLocaleString('en-US')}`;
    const planName = text(payment.planName, 80);
    const reference = text(payment.reference, 120);

    await notifyOwners({
      // payments.js creates payment_<id> in the owner feed during the same
      // submission transaction. Reusing that deterministic id makes the
      // in-app card and the push/email delivery one durable event.
      eventId: `payment_${paymentId}`,
      eventType: 'Payment proof submitted',
      title: 'Payment verification required',
      body: `${schoolName} submitted ${amountLabel} via ${method.label}${planName ? ` for ${planName}` : ''}. Confirm the money was received before activating access.`,
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
        method: method.id,
        planName,
        reference,
      },
    });
  },
);
