const admin = require('firebase-admin');
const { defineSecret } = require('firebase-functions/params');
const { Resend } = require('resend');
const { getTemplate, isValidTemplateId } = require('./template_registry');
const { renderBaseTemplate, renderPlainText } = require('./base_template');
const { resolveBranding, SENDER, SUPPORT_EMAIL } = require('./branding');
const { text, sanitizeHeaderValue } = require('./email_helpers');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const RESEND_API_KEY = defineSecret('RESEND_API_KEY');

/**
 * Send a School Pulse transactional email from a registered template.
 *
 * This is the ONLY way email should be sent from the backend: callers pass a
 * templateId and structured data, never raw HTML, sender, or subject — those
 * are always derived from the template registry and branding module. This
 * keeps every outbound email visually consistent and prevents callers
 * (including anything ever exposed to Flutter) from injecting arbitrary
 * markup into an email.
 *
 * Idempotent per eventId — safe to call multiple times for the same event
 * (e.g. a Firestore trigger re-running on retry).
 *
 * @param {object} params
 * @param {string} params.eventId - unique id for idempotency (delivery log doc id)
 * @param {string} params.templateId - a registered template id
 * @param {string} params.to - recipient email address
 * @param {object} [params.data] - template-specific data (will be escaped where rendered)
 * @param {object} [params.schoolBranding] - optional display branding override
 */
async function sendTemplatedEmail({ eventId, templateId, to, data = {}, schoolBranding = null }) {
  if (!eventId) throw new Error('sendTemplatedEmail: eventId is required.');
  if (!isValidTemplateId(templateId)) throw new Error(`sendTemplatedEmail: unknown templateId "${templateId}".`);

  const deliveryRef = db.collection('email_deliveries').doc(eventId);
  const existing = await deliveryRef.get();
  if (existing.exists && existing.data()?.completed === true) return existing.data();

  const recipient = text(to, 200).toLowerCase();
  const renderer = getTemplate(templateId);
  const rendered = renderer(data || {});
  rendered.subject = sanitizeHeaderValue(rendered.subject, 200) || 'School Pulse notification';
  const branding = resolveBranding(schoolBranding);

  const startedAt = admin.firestore.FieldValue.serverTimestamp();

  if (!recipient) {
    const result = {
      eventId, templateId, status: 'no_recipient', completed: true,
      startedAt, completedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    await deliveryRef.set(result, { merge: true });
    logResult({ eventId, templateId, recipient: '', status: 'no_recipient' });
    return result;
  }

  const base = {
    eventId,
    templateId,
    to: recipient,
    subject: rendered.subject,
    startedAt,
    completed: false,
  };
  await deliveryRef.set(base, { merge: true });

  const html = renderBaseTemplate({ ...rendered, branding });
  const plainTextBody = renderPlainText({ ...rendered, supportEmail: branding.supportEmail || SUPPORT_EMAIL });

  let outcome;
  try {
    const resend = new Resend(RESEND_API_KEY.value());
    const { data: sendResult, error } = await resend.emails.send({
      from: SENDER,
      to: [recipient],
      subject: rendered.subject,
      html,
      text: plainTextBody,
    });
    if (error) {
      outcome = { status: 'failed', error: text(error?.message || error, 600) };
    } else {
      outcome = { status: 'sent', resendId: text(sendResult?.id, 200) };
    }
  } catch (error) {
    outcome = { status: 'failed', error: text(error?.message || error, 600) };
  }

  const completed = {
    ...outcome,
    completed: true,
    completedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  await deliveryRef.set(completed, { merge: true });
  logResult({ eventId, templateId, recipient, status: outcome.status, resendId: outcome.resendId, error: outcome.error });
  return { ...base, ...completed };
}

/**
 * Structured log line for observability. Deliberately excludes rendered
 * subject/body/HTML — only identifiers, status, and error text are logged.
 */
function logResult({ eventId, templateId, recipient, status, resendId, error }) {
  console.log('EMAIL_SEND_RESULT', JSON.stringify({
    eventId,
    templateId,
    recipient,
    resendId: resendId || null,
    status,
    error: error || null,
    timestamp: new Date().toISOString(),
  }));
}

module.exports = {
  sendTemplatedEmail,
  RESEND_API_KEY,
};
