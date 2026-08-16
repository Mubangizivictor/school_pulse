const admin = require('firebase-admin');
const { defineSecret } = require('firebase-functions/params');
const { Resend } = require('resend');
const { getTemplate, isValidTemplateId } = require('./template_registry');
const { getHostedTemplate } = require('./hosted_templates');
const { renderBaseTemplate, renderPlainText } = require('./base_template');
const { resolveBranding, senderForTemplate, SENDER, SUPPORT_EMAIL } = require('./branding');
const { text, sanitizeHeaderValue } = require('./email_helpers');
const { classifyResendError } = require('./resend_error_classifier');

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
async function sendTemplatedEmail({ eventId, templateId, to, data = {}, schoolBranding = null, attachments = [] }) {
  if (!eventId) throw new Error('sendTemplatedEmail: eventId is required.');
  if (!isValidTemplateId(templateId)) throw new Error(`sendTemplatedEmail: unknown templateId "${templateId}".`);

  const deliveryRef = db.collection('email_deliveries').doc(eventId);
  const existing = await deliveryRef.get();
  if (existing.exists && existing.data()?.completed === true) return existing.data();

  const recipient = text(to, 200).toLowerCase();
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

  // Prefer the published Resend hosted template when one is mapped for this
  // templateId; otherwise use the local HTML template directly. Both share
  // the exact same idempotency envelope (deliveryRef above), queue, retry,
  // and audit-log shape — only how the subject/body/from are produced
  // differs.
  const hosted = getHostedTemplate(templateId);
  const provider = hosted ? 'HOSTED_RESEND_TEMPLATE' : 'LOCAL_TEMPLATE_FALLBACK';

  const sendPayload = hosted
    ? buildHostedPayload(templateId, hosted, data, recipient)
    : buildLocalPayload(templateId, data, recipient, schoolBranding);
  const resolvedAttachments = await resolveAttachments(attachments);
  applyAttachments(sendPayload, resolvedAttachments);

  const base = {
    eventId,
    templateId,
    to: recipient,
    subject: sendPayload.subject || null,
    provider,
    hostedTemplateAlias: hosted ? hosted.alias : null,
    attachments: resolvedAttachments.map((attachment) => ({ filename: attachment.filename, contentType: attachment.contentType })),
    startedAt,
    completed: false,
  };
  await deliveryRef.set(base, { merge: true });

  let outcome = await attemptSend(sendPayload);

  // A hosted-template send that fails for a CONFIGURATION reason (bad
  // alias, unpublished template, variable mismatch) is not something a
  // retry can ever fix, and must not silently leave the recipient with no
  // email at all: fall back to the local template in this same invocation.
  // Both the hosted failure and the fallback's own outcome are recorded, so
  // the broken mapping stays visible in the audit trail even though the
  // recipient still receives an email.
  let fallback = null;
  if (hosted && outcome.status === 'failed' && outcome.retryable === false) {
    const hostedFailure = {
      hostedFailureClass: outcome.errorClass || null,
      hostedFailureProviderErrorName: outcome.providerErrorName || null,
      hostedFailureMessage: outcome.error || null,
    };
    console.error('RESEND_HOSTED_TEMPLATE_CONFIGURATION_ERROR', JSON.stringify({
      eventId,
      templateId,
      hostedTemplateAlias: hosted.alias,
      recipient,
      errorClass: outcome.errorClass,
      providerErrorName: outcome.providerErrorName,
      providerErrorMessage: outcome.error,
      retryable: false,
      timestamp: new Date().toISOString(),
    }));

    const localPayload = buildLocalPayload(templateId, data, recipient, schoolBranding);
    applyAttachments(localPayload, resolvedAttachments);
    const fallbackOutcome = await attemptSend(localPayload);
    fallback = {
      ...hostedFailure,
      fallbackUsed: true,
      fallbackProvider: 'LOCAL_TEMPLATE',
      fallbackStatus: fallbackOutcome.status,
      fallbackError: fallbackOutcome.status === 'failed' ? fallbackOutcome.error : null,
    };
    // The fallback's outcome (sent or failed) becomes the delivery's final
    // outcome — the hosted failure is preserved separately in `fallback`.
    outcome = fallbackOutcome;
  }

  const completed = {
    ...outcome,
    ...(fallback || { fallbackUsed: false }),
    finalDeliveryStatus: outcome.status,
    completed: true,
    completedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  await deliveryRef.set(completed, { merge: true });
  logResult({
    eventId, templateId, recipient, provider: fallback ? 'LOCAL_TEMPLATE (fallback)' : provider,
    status: outcome.status, resendId: outcome.resendId, error: outcome.error,
  });
  return { ...base, ...completed };
}

async function resolveAttachments(attachments) {
  if (!Array.isArray(attachments) || !attachments.length) return [];
  const result = [];
  for (const attachment of attachments) {
    const storagePath = text(attachment?.storagePath, 800);
    const filename = text(attachment?.filename, 180);
    if (!storagePath || !filename || !storagePath.startsWith('official_documents/')) {
      throw new Error('Invalid server-generated attachment descriptor.');
    }
    const [content] = await admin.storage().bucket().file(storagePath).download();
    result.push({ filename, content, contentType: text(attachment?.contentType, 80) || 'application/pdf' });
  }
  return result;
}

function applyAttachments(payload, attachments) {
  if (Array.isArray(attachments) && attachments.length) payload.attachments = attachments;
  return payload;
}

function buildHostedPayload(templateId, hosted, data, recipient) {
  const variables = hosted.variables(data || {});
  return {
    from: senderForTemplate(templateId),
    to: [recipient],
    template: { id: hosted.alias, variables },
    subject: null, // subject is owned by the hosted template in Resend
  };
}

function buildLocalPayload(templateId, data, recipient, schoolBranding) {
  const renderer = getTemplate(templateId);
  const rendered = renderer(data || {});
  const subject = sanitizeHeaderValue(rendered.subject, 200) || 'School Pulse notification';
  const branding = resolveBranding(schoolBranding);
  const html = renderBaseTemplate({ ...rendered, branding });
  const plainTextBody = renderPlainText({ ...rendered, supportEmail: branding.supportEmail || SUPPORT_EMAIL });
  return {
    from: senderForTemplate(templateId),
    to: [recipient],
    subject,
    html,
    text: plainTextBody,
  };
}

/**
 * Sends via the Resend SDK and classifies any failure. `retryable` on the
 * returned outcome tells the caller (and the transactional queue) whether a
 * later retry could plausibly succeed.
 */
async function attemptSend(sendPayload) {
  try {
    const resend = new Resend(RESEND_API_KEY.value());
    // A hosted-template payload sets subject: null (Resend owns the subject
    // for a published template) — omit the key entirely rather than send a
    // literal null. A local-render payload always has a real subject string
    // and must keep it; the SDK requires it for the non-template send shape.
    const payload = { ...sendPayload };
    if (payload.subject === null) delete payload.subject;
    const { data: sendResult, error } = await resend.emails.send(payload);
    if (error) {
      const classified = classifyResendError(error);
      return {
        status: 'failed',
        error: classified.providerErrorMessage,
        errorClass: classified.errorClass,
        providerErrorName: classified.providerErrorName,
        retryable: classified.retryable,
      };
    }
    return { status: 'sent', resendId: text(sendResult?.id, 200) };
  } catch (error) {
    const classified = classifyResendError(error);
    return {
      status: 'failed',
      error: classified.providerErrorMessage,
      errorClass: classified.errorClass,
      providerErrorName: classified.providerErrorName,
      retryable: classified.retryable,
    };
  }
}

/**
 * Structured log line for observability. Deliberately excludes rendered
 * subject/body/HTML — only identifiers, status, and error text are logged.
 */
function logResult({ eventId, templateId, recipient, provider, status, resendId, error }) {
  console.log('EMAIL_SEND_RESULT', JSON.stringify({
    eventId,
    templateId,
    recipient,
    provider: provider || null,
    resendId: resendId || null,
    status,
    error: error || null,
    timestamp: new Date().toISOString(),
  }));
}

module.exports = {
  sendTemplatedEmail,
  RESEND_API_KEY,
  __test__: { buildHostedPayload, buildLocalPayload, attemptSend, resolveAttachments, applyAttachments },
};
