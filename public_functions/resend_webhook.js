const { onRequest } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const { Resend } = require('resend');
const { RESEND_API_KEY } = require('./email/email_service');

// Same secret-management convention as email/email_service.js's
// RESEND_API_KEY - Firebase Functions v2 params, not raw process.env, so
// the value is pulled from Secret Manager at runtime and never needs to be
// baked into deploy-time config.
const RESEND_WEBHOOK_SECRET = defineSecret('RESEND_WEBHOOK_SECRET');

/**
 * Resend webhook receiver, reachable at https://schoolpulseapp.com/api/webhooks/resend
 * via the firebase.json Hosting rewrite (see hosting.rewrites) - Resend
 * itself is configured (in the Resend dashboard) to POST events to that
 * URL.
 *
 * Verification uses Resend's Svix-based signing (resend.webhooks.verify),
 * which requires the *raw* request body bytes exactly as sent - not a
 * re-serialized JSON.parse/JSON.stringify round trip, since that can
 * change whitespace/key order and invalidate the signature. Firebase
 * Functions' HTTP trigger already buffers the raw body for us on `req.rawBody`
 * before any body-parser touches it, so we read that instead of `req.body`.
 */
exports.resendWebhook = onRequest(
  { region: 'europe-west1', secrets: [RESEND_WEBHOOK_SECRET, RESEND_API_KEY] },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).set('Allow', 'POST').send('Method Not Allowed');
      return;
    }

    const payload = req.rawBody ? req.rawBody.toString('utf8') : '';
    const svixId = req.get('svix-id');
    const svixTimestamp = req.get('svix-timestamp');
    const svixSignature = req.get('svix-signature');

    let event;
    try {
      // The API key itself is never used by webhooks.verify() (only
      // webhookSecret signs/validates the payload) - reusing the shared
      // RESEND_API_KEY secret here just satisfies the SDK's constructor,
      // which throws if constructed with no key at all.
      const resend = new Resend(RESEND_API_KEY.value());
      event = resend.webhooks.verify({
        payload,
        headers: {
          id: svixId,
          timestamp: svixTimestamp,
          signature: svixSignature,
        },
        webhookSecret: RESEND_WEBHOOK_SECRET.value(),
      });
    } catch (error) {
      console.error('RESEND_WEBHOOK_VERIFICATION_FAILED', error);
      res.status(400).send('Invalid signature');
      return;
    }

    if (event?.type === 'email.received') {
      console.log('RESEND_EMAIL_RECEIVED', JSON.stringify(event.data));
      // TODO: process the received email - e.g. store it in Firestore
      // (a new `inbound_emails` collection keyed by event.data.email_id)
      // and/or notify the relevant school/staff member.
    }

    res.status(200).send('OK');
  }
);
