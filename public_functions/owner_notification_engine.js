const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const INVALID_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
  'messaging/invalid-argument',
]);

function text(value, max = 500) {
  return String(value ?? '').trim().slice(0, max);
}

function unique(values) {
  return [...new Set(values.filter(Boolean))];
}

function roleValues(data) {
  const roles = Array.isArray(data?.roles) ? data.roles : [];
  return unique([
    text(data?.role, 80),
    text(data?.platformRole, 80),
    ...roles.map((role) => text(role, 80)),
  ]);
}

function isOwnerData(data) {
  const roles = roleValues(data);
  return data?.isSuperAdmin === true ||
    roles.includes('superAdmin') ||
    roles.includes('super_admin') ||
    roles.includes('saasOwner') ||
    roles.includes('saas_owner');
}

async function getOwnerDocs() {
  const owners = new Map();
  const add = (snapshot) => snapshot.docs.forEach((doc) => {
    if (doc.data()?.isActive !== false && isOwnerData(doc.data())) owners.set(doc.id, doc);
  });

  const queries = await Promise.allSettled([
    db.collection('users').where('role', '==', 'superAdmin').get(),
    db.collection('users').where('role', '==', 'super_admin').get(),
    db.collection('users').where('roles', 'array-contains', 'superAdmin').get(),
    db.collection('users').where('roles', 'array-contains', 'super_admin').get(),
    db.collection('users').where('platformRole', '==', 'super_admin').get(),
    db.collection('users').where('isSuperAdmin', '==', true).get(),
  ]);
  for (const result of queries) {
    if (result.status === 'fulfilled') add(result.value);
    else console.error('Owner lookup query failed', result.reason);
  }

  // Recovery path for the seeded owner if its role schema was migrated.
  const fallbackEmail = text(
    process.env.OWNER_NOTIFICATION_EMAIL || process.env.SAAS_OWNER_NOTIFICATION_EMAIL,
    200,
  ).toLowerCase();
  if (fallbackEmail) {
    const emailSnap = await db.collection('users').where('email', '==', fallbackEmail).limit(5).get();
    emailSnap.docs.forEach((doc) => {
      if (doc.data()?.isActive !== false) owners.set(doc.id, doc);
    });
  }

  return [...owners.values()];
}

async function tokenEntriesForOwners(ownerDocs) {
  const entries = new Map();
  const ownerIds = new Set(ownerDocs.map((doc) => doc.id));

  for (const ownerDoc of ownerDocs) {
    try {
      const snapshot = await ownerDoc.ref.collection('tokens').get();
      snapshot.docs.forEach((doc) => {
        const data = doc.data() || {};
        const token = text(data.token || doc.id, 4096);
        if (!token || data.enabled === false) return;
        entries.set(token, {
          token,
          ownerId: ownerDoc.id,
          ref: doc.ref,
          globalRef: null,
          platform: text(data.platform, 40),
        });
      });
    } catch (error) {
      console.error('Owner token subcollection lookup failed', ownerDoc.id, error);
    }
  }

  // Canonical owner-only token registry. This is written by the authenticated
  // registerOwnerNotificationDevice callable using the Admin SDK, so push does
  // not depend on client Firestore rules being perfectly aligned.
  try {
    const global = await db.collection('platform_owner_device_tokens')
      .where('enabled', '==', true)
      .get();
    global.docs.forEach((doc) => {
      const data = doc.data() || {};
      const token = text(data.token, 4096);
      const ownerId = text(data.ownerId, 180);
      if (!token || (ownerIds.size > 0 && ownerId && !ownerIds.has(ownerId))) return;
      const existing = entries.get(token);
      entries.set(token, {
        token,
        ownerId: ownerId || existing?.ownerId || '',
        ref: existing?.ref || null,
        globalRef: doc.ref,
        platform: text(data.platform, 40) || existing?.platform || '',
      });
    });
  } catch (error) {
    console.error('Canonical owner token registry lookup failed', error);
  }

  return [...entries.values()];
}

function pushData(eventId, title, body, data) {
  const raw = {
    ...data,
    notificationId: eventId,
    id: eventId,
    title,
    body,
    category: data?.category || 'administrative',
    type: data?.notificationType || 'custom',
    priority: data?.priority || 'high',
    persistence: data?.persistence || 'persistent',
    sourceModule: data?.sourceModule || 'super_admin',
    sourceEntityId: data?.sourceEntityId || data?.applicationId || data?.paymentId || eventId,
    isAutomated: 'true',
    collapseKey: eventId,
  };
  return Object.fromEntries(
    Object.entries(raw)
      .filter(([, value]) => value !== undefined && value !== null && String(value).trim() !== '')
      .map(([key, value]) => [key, text(value, 1000)]),
  );
}

async function deliverPush(ownerDocs, eventId, title, body, data) {
  const entries = await tokenEntriesForOwners(ownerDocs);
  if (entries.length === 0) {
    return {
      status: 'no_tokens',
      attempted: 0,
      successCount: 0,
      failureCount: 0,
      errors: ['No registered SaaS Owner FCM device tokens. Open the owner app on a real device and allow notifications.'],
    };
  }

  let successCount = 0;
  let failureCount = 0;
  const errors = [];
  const removals = [];
  const payloadData = pushData(eventId, title, body, data);

  for (let offset = 0; offset < entries.length; offset += 500) {
    const batch = entries.slice(offset, offset + 500);
    try {
      const response = await admin.messaging().sendEachForMulticast({
        tokens: batch.map((entry) => entry.token),
        notification: { title, body },
        data: payloadData,
        android: {
          priority: 'high',
          notification: {
            channelId: 'school_pulse_important',
            sound: 'default',
            defaultSound: true,
          },
        },
        apns: {
          headers: { 'apns-priority': '10' },
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
              'content-available': 1,
            },
          },
        },
      });
      successCount += response.successCount;
      failureCount += response.failureCount;
      response.responses.forEach((result, index) => {
        if (result.success) return;
        const code = result.error?.code || 'unknown';
        errors.push(code);
        if (INVALID_TOKEN_CODES.has(code)) {
          const entry = batch[index];
          if (entry?.ref) removals.push(entry.ref.delete());
          if (entry?.globalRef) removals.push(entry.globalRef.delete());
        }
      });
    } catch (error) {
      failureCount += batch.length;
      errors.push(text(error?.code || error?.message || error, 400));
    }
  }

  await Promise.allSettled(removals);
  return {
    status: successCount > 0 ? (failureCount > 0 ? 'partial' : 'sent') : 'failed',
    attempted: entries.length,
    successCount,
    failureCount,
    errors: unique(errors).slice(0, 20),
  };
}

function smtpConfig() {
  const host = text(process.env.SMTP_HOST, 200);
  const user = text(process.env.SMTP_USER, 300);
  const pass = String(process.env.SMTP_PASS || '').replace(/\s+/g, '');
  const from = text(process.env.SMTP_FROM, 300) || user;
  if (!host || !user || !pass || !from) return null;
  const port = Number(process.env.SMTP_PORT || 587);
  return { host, port, secure: port === 465, auth: { user, pass }, from };
}

function emailHtml({ title, body, schoolName, eventLabel }) {
  const safe = (value) => text(value, 1000)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
  return `<!doctype html><html><body style="margin:0;background:#f3f6fb;font-family:Arial,sans-serif;color:#0b1935"><table role="presentation" width="100%" cellspacing="0" cellpadding="0"><tr><td align="center" style="padding:32px 16px"><table role="presentation" width="100%" style="max-width:600px;background:#fff;border-radius:18px;border:1px solid #dfe7f2"><tr><td style="padding:30px"><div style="font-size:22px;font-weight:800;color:#1267e8">School Pulse</div><div style="font-size:12px;color:#718096;margin-top:4px">SaaS Owner Alert · Victorbee Technologies</div><div style="margin:28px 0 8px;font-size:12px;font-weight:700;letter-spacing:.08em;color:#1267e8;text-transform:uppercase">${safe(eventLabel)}</div><h1 style="font-size:24px;line-height:1.25;margin:0 0 12px">${safe(title)}</h1>${schoolName ? `<div style="font-size:16px;font-weight:700;margin-bottom:10px">${safe(schoolName)}</div>` : ''}<p style="font-size:15px;line-height:1.6;color:#44546a;margin:0">${safe(body)}</p><div style="margin-top:26px;padding:16px;background:#f5f8fd;border-radius:12px;color:#52647a;font-size:13px">Open the secured School Pulse SaaS Owner app to review and take action. Approval actions are never performed from email.</div><div style="margin-top:28px;font-size:12px;color:#9aa8ba">School Pulse · Victorbee Technologies</div></td></tr></table></td></tr></table></body></html>`;
}

// Transient SMTP failures (network blips, temporary 4xx) are worth a couple
// of bounded retries; permanent auth/recipient failures are not — retrying
// 535 BadCredentials or a rejected recipient just delays the same failure.
const TRANSIENT_SMTP_CODES = new Set(['ETIMEDOUT', 'ECONNRESET', 'ESOCKET', 'ECONNECTION', 'EDNS']);
const MAX_SMTP_ATTEMPTS = 3;

function isTransientSmtpError(error) {
  const code = String(error?.code || '').toUpperCase();
  if (TRANSIENT_SMTP_CODES.has(code)) return true;
  const responseCode = Number(error?.responseCode || 0);
  return responseCode >= 400 && responseCode < 500;
}

async function deliverEmail(ownerDocs, payload) {
  const recipients = unique([
    ...ownerDocs.map((doc) => text(doc.data()?.email, 200).toLowerCase()),
    text(process.env.OWNER_NOTIFICATION_EMAIL || process.env.SAAS_OWNER_NOTIFICATION_EMAIL, 200).toLowerCase(),
  ]);
  if (recipients.length === 0) {
    return { status: 'no_recipients', provider: 'none', recipients: [], sentCount: 0 };
  }

  const config = smtpConfig();
  if (!config) {
    return {
      status: 'not_configured',
      provider: 'smtp',
      recipients,
      sentCount: 0,
      error: 'SMTP is not configured. Set SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS and SMTP_FROM Firebase secrets.',
    };
  }

  const transporter = nodemailer.createTransport({
    host: config.host,
    port: config.port,
    secure: config.secure,
    auth: config.auth,
  });

  try {
    await transporter.verify();
  } catch (error) {
    return {
      status: 'failed',
      stage: 'verify',
      provider: 'smtp',
      recipients,
      sentCount: 0,
      error: text(error?.message || error, 600),
    };
  }

  let lastError;
  for (let attempt = 1; attempt <= MAX_SMTP_ATTEMPTS; attempt += 1) {
    try {
      const info = await transporter.sendMail({
        from: config.from,
        to: recipients.join(', '),
        subject: `[School Pulse] ${payload.title}`,
        text: `${payload.title}\n\n${payload.body}\n\nOpen the School Pulse SaaS Owner app to review this item.`,
        html: emailHtml(payload),
      });
      const accepted = (info.accepted || []).map((value) => text(value, 200).toLowerCase());
      const rejected = (info.rejected || []).map((value) => text(value, 200).toLowerCase());
      const pending = (info.pending || []).map((value) => text(value, 200).toLowerCase());
      return {
        status: accepted.length > 0 ? 'sent' : 'failed',
        stage: 'sendMail',
        provider: 'smtp',
        recipients,
        accepted,
        rejected,
        pending,
        sentCount: accepted.length,
        messageId: text(info.messageId, 300),
        response: text(info.response, 300),
        attempts: attempt,
        ...(accepted.length === 0 ? { error: 'SMTP accepted zero recipients.' } : {}),
      };
    } catch (error) {
      lastError = error;
      if (attempt >= MAX_SMTP_ATTEMPTS || !isTransientSmtpError(error)) break;
      await new Promise((resolve) => setTimeout(resolve, 500 * attempt));
    }
  }

  return {
    status: 'failed',
    stage: 'sendMail',
    provider: 'smtp',
    recipients,
    sentCount: 0,
    attempts: MAX_SMTP_ATTEMPTS,
    error: text(lastError?.message || lastError, 600),
  };
}

function ownerNotificationDocument(eventId, eventType, title, body, schoolName, data) {
  const isPayment = Boolean(data?.paymentId);
  return {
    eventId,
    type: text(data?.type || eventType, 100),
    eventType: text(eventType, 120),
    status: 'unread',
    title: text(title, 240),
    body: text(body, 1000),
    schoolId: text(data?.schoolId, 180),
    schoolName: text(schoolName || data?.schoolName, 180) || 'School Pulse',
    applicationId: text(data?.applicationId, 180),
    paymentId: text(data?.paymentId, 180),
    amountUgx: isPayment ? Math.max(0, Math.round(Number(data?.amount || data?.amountUgx || 0))) : 0,
    method: text(data?.method, 30) || '',
    data: data || {},
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

async function createInAppAlerts(ownerDocs, eventId, payload) {
  const batch = db.batch();

  // Canonical SaaS owner notification centre. The owner UI reads this exact
  // collection. The previous engine only wrote `alerts`, which is why a real
  // application event could be delivered server-side yet never appear in the
  // SaaS Owner Notifications screen.
  const ownerFeedRef = db.collection('super_admin_notifications').doc(eventId);
  batch.set(ownerFeedRef, ownerNotificationDocument(
    eventId,
    payload.eventType,
    payload.title,
    payload.body,
    payload.schoolName,
    payload.data,
  ), { merge: true });

  // Also write user-scoped alerts so the shared notification centre/badge
  // pipeline remains compatible with the rest of the Flutter application.
  for (const ownerDoc of ownerDocs) {
    const ref = db.collection('alerts').doc(`${eventId}_${ownerDoc.id}`);
    batch.set(ref, {
      userId: ownerDoc.id,
      schoolId: text(payload.data?.schoolId, 180),
      title: payload.title,
      body: payload.body,
      description: payload.body,
      data: payload.data || {},
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      readBy: [],
      type: 'Direct',
      source: 'owner_notification_engine',
      sourceModule: 'super_admin',
      sourceEntityId: payload.data?.applicationId || payload.data?.paymentId || eventId,
    }, { merge: true });
  }

  await batch.commit();
  return {
    status: 'sent',
    ownerFeedDocument: eventId,
    userAlertCount: ownerDocs.length,
  };
}

async function notifyOwners({ eventId, eventType, title, body, schoolName = '', data = {} }) {
  if (!eventId) throw new Error('Owner notification eventId is required.');
  const deliveryRef = db.collection('notification_deliveries').doc(eventId);
  const existing = await deliveryRef.get();
  if (existing.exists && existing.data()?.completed === true) return existing.data();

  const owners = await getOwnerDocs();
  const base = {
    eventId,
    eventType,
    title,
    body,
    schoolName,
    data,
    ownerIds: owners.map((doc) => doc.id),
    startedAt: admin.firestore.FieldValue.serverTimestamp(),
    completed: false,
  };
  await deliveryRef.set(base, { merge: true });

  let inApp;
  let push;
  let email;
  try {
    inApp = await createInAppAlerts(owners, eventId, {
      eventType,
      title,
      body,
      schoolName,
      data,
    });
  } catch (error) {
    inApp = { status: 'failed', error: text(error?.message || error, 600) };
  }

  [push, email] = await Promise.all([
    deliverPush(owners, eventId, title, body, data).catch((error) => ({
      status: 'failed',
      attempted: 0,
      successCount: 0,
      failureCount: 0,
      errors: [text(error?.message || error, 600)],
    })),
    deliverEmail(owners, { title, body, schoolName, eventLabel: eventType }).catch((error) => ({
      status: 'failed',
      provider: 'smtp',
      recipients: [],
      sentCount: 0,
      error: text(error?.message || error, 600),
    })),
  ]);

  const completed = {
    inApp,
    push,
    email,
    ownerCount: owners.length,
    completed: true,
    completedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  await deliveryRef.set(completed, { merge: true });

  // Keep the owner-feed document itself diagnostic: when delivery fails, the
  // app can show exactly which external channel needs attention.
  await db.collection('super_admin_notifications').doc(eventId).set({
    delivery: { inApp, push, email },
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });

  console.log('OWNER_NOTIFICATION_RESULT', JSON.stringify({
    eventId,
    ownerCount: owners.length,
    inApp,
    push,
    email,
  }));
  return { ...base, ...completed };
}

module.exports = {
  notifyOwners,
  getOwnerDocs,
  isOwnerData,
};
