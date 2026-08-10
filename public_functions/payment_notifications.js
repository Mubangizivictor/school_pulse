const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

function text(value, max = 180) {
  return String(value ?? '').trim().slice(0, max);
}

/**
 * Push/in-app alert for the SaaS Owner when payment proof arrives.
 *
 * Payment submission itself never depends on FCM. If a device has no token
 * (for example an iOS simulator) the manual payment remains safely stored and
 * visible in Payments & Billing; notification delivery is best-effort only.
 */
exports.notifyOwnerOfManualPayment = onDocumentCreated(
  {
    region: 'europe-west1',
    document: 'manual_subscription_payments/{paymentId}',
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const payment = snapshot.data() || {};
    const paymentId = event.params.paymentId;
    const schoolName = text(payment.schoolName, 160) || 'A school';
    const amount = Math.round(Number(payment.submittedAmount || 0));
    const method = payment.method === 'bank' ? 'Centenary Bank' : 'MTN Mobile Money';
    const amountLabel = `UGX ${amount.toLocaleString('en-US')}`;

    const owners = await db.collection('users').where('role', '==', 'superAdmin').get();
    if (owners.empty) {
      console.warn('Manual payment submitted but no superAdmin user document was found.', paymentId);
      return;
    }

    await Promise.all(
      owners.docs.map(async (ownerDoc) => {
        const owner = ownerDoc.data() || {};
        if (owner.isActive === false) return;

        const alertRef = db.collection('alerts').doc(`manual_payment_${paymentId}_${ownerDoc.id}`);
        await alertRef.set(
          {
            userId: ownerDoc.id,
            title: 'Subscription payment awaiting verification',
            body: `${schoolName} submitted ${amountLabel} via ${method}. Open Payments & Billing to verify the money received.`,
            data: {
              type: 'manual_subscription_payment',
              paymentId,
              schoolId: text(payment.schoolId, 180),
            },
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            readBy: [],
            type: 'Direct',
          },
          { merge: true },
        );

        const tokensSnapshot = await ownerDoc.ref.collection('tokens').get();
        const tokens = tokensSnapshot.docs
          .map((doc) => text(doc.data()?.token || doc.id, 4096))
          .filter(Boolean);
        if (tokens.length === 0) return;

        try {
          const response = await admin.messaging().sendEachForMulticast({
            tokens: tokens.slice(0, 500),
            notification: {
              title: 'Payment awaiting verification',
              body: `${schoolName} • ${amountLabel} • ${method}`,
            },
            data: {
              type: 'manual_subscription_payment',
              paymentId,
              schoolId: text(payment.schoolId, 180),
            },
          });

          // Clean up tokens that Firebase definitively reports as invalid or
          // unregistered; transient delivery failures are left intact.
          const removals = [];
          response.responses.forEach((result, index) => {
            if (result.success) return;
            const code = result.error?.code || '';
            if (
              code === 'messaging/registration-token-not-registered' ||
              code === 'messaging/invalid-registration-token'
            ) {
              const token = tokens[index];
              if (token) removals.push(ownerDoc.ref.collection('tokens').doc(token).delete());
            }
          });
          await Promise.all(removals);
        } catch (error) {
          // Notification delivery must never roll back or corrupt the payment.
          console.error('Failed to push manual payment alert', paymentId, error);
        }
      }),
    );
  },
);
