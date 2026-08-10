const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { notifyOwners } = require('./owner_notification_engine');

function text(value, max = 180) {
  return String(value ?? '').trim().slice(0, max);
}

function reviewable(payment) {
  const status = String(payment?.status || '').toLowerCase();
  const proof = text(
    payment?.proofUrl || payment?.paymentProofUrl || payment?.proofPath || payment?.receiptUrl,
    1000,
  );
  return ['pending', 'under_review', 'pending_review'].includes(status) && Boolean(proof);
}

/**
 * Notify the SaaS Owner when a manual payment becomes ready for review.
 *
 * onDocumentWritten is required because the payment document can be created
 * before the proof upload finishes. We notify on the transition into a
 * reviewable state rather than assuming creation == submission.
 */
exports.notifyOwnerOfManualPayment = onDocumentWritten(
  {
    region: 'europe-west1',
    document: 'manual_subscription_payments/{paymentId}',
    secrets: ['SMTP_HOST', 'SMTP_PORT', 'SMTP_USER', 'SMTP_PASS', 'SMTP_FROM', 'OWNER_NOTIFICATION_EMAIL'],
  },
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;

    const payment = after.data() || {};
    const before = event.data?.before?.exists ? (event.data.before.data() || {}) : {};
    if (!reviewable(payment) || reviewable(before)) return;

    const paymentId = event.params.paymentId;
    const schoolName = text(payment.schoolName, 160) || 'A school';
    const amount = Math.max(0, Math.round(Number(payment.submittedAmount || payment.amount || 0)));
    const method = String(payment.method || '').toLowerCase() === 'bank'
      ? 'Centenary Bank'
      : 'MTN Mobile Money';
    const amountLabel = `UGX ${amount.toLocaleString('en-US')}`;

    await notifyOwners({
      eventId: `manual_payment_${paymentId}_${text(event.id, 120)}`,
      eventType: 'Payment proof submitted',
      title: 'Payment verification required',
      body: `${schoolName} submitted ${amountLabel} via ${method}. Confirm the money was received before activating access.`,
      schoolName,
      data: {
        type: 'manual_subscription_payment',
        paymentId,
        schoolId: text(payment.schoolId, 180),
        schoolName,
        amount: String(amount),
        method: String(payment.method || '').toLowerCase() === 'bank' ? 'bank' : 'mtn',
      },
    });
  },
);
