const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const INVALID_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

function text(value, max = 500) {
  return String(value ?? '').trim().slice(0, max);
}

function unique(values) {
  return [...new Set(values.filter(Boolean))];
}

async function getOwnerDocs() {
  const owners = new Map();
  const add = (snapshot) => snapshot.docs.forEach((doc) => owners.set(doc.id, doc));

  const queries = await Promise.allSettled([
    db.collection('users').where('role', '==', 'superAdmin').get(),
    db.collection('users').where('roles', 'array-contains', 'superAdmin').get(),
    db.collection('users').where('isSuperAdmin', '==', true).get(),
  ]);
  for (const result of queries) {
    if (result.status === 'fulfilled') add(result.value);
  }

  // Optional fallback for a seeded owner whose role document was migrated.
  const fallbackEmail = text(process.env.OWNER_NOTIFICATION_EMAIL, 200).toLowerCase();
  if (fallbackEmail) {
    const emailSnap = await db.collection('users').where('email', '==', fallbackEmail).limit(3).get();
    add(emailSnap);
  }

  return [...owners.values()].filter((doc) => doc.data()?.isActive !== false);
}

async function tokenEntriesForOwner(ownerDoc) {
  const snapshot = await ownerDoc.ref.collection('tokens').get();
  return snapshot.docs
    .map((doc) => ({
      ref: doc.ref,
      token: text(doc.data()?.token || doc.id, 4096),
      enabled: doc.data()?.enabled !== false,
    }))
    .filter((entry) => entry.enabled && entry.token);
}

async function deliverPush(ownerDocs, title, body, data) {
  const entries = [];
  for (const ownerDoc of ownerDocs) {
    const ownerEntries = await tokenEntriesForOwner(ownerDoc);
    for (const entry of ownerEntries) entries.push({ ...entry, ownerId: ownerDoc.id });
  }

  if (entries.length === 0) {
    return { status: 'no_tokens', attempted: 0, successCount: 0, failureCount: 0 };
  }

  let successCount = 0;
  let failureCount = 0;
  const errors = [];
  const removals = [];

  for (let offset = 0; offset < entries.length; offset += 500) {
    const batch = entries.slice(offset, offset + 500);
    try {
      const response = await admin.messaging().sendEachForMulticast({
        tokens: batch.map((entry) => entry.token),
        notification: { title, body },
        data: Object.fromEntries(
          Object.entries(data || {}).map(([key, value]) => [key, text(value, 1000)]),
        ),
        android: {
          priority: 'high',
          notification: { channelId: 'school_pulse_important', sound: 'default' },
        },
        apns: {
          headers: { 'apns-priority': '10' },
          payload: { aps: { sound: 'default', badge: 1 } },
        },
      });
      successCount += response.successCount;
      failureCount += response.failureCount;
      response.responses.forEach((result, index) => {
        if (result.success) return;
        const code = result.error?.code || 'unknown';
        errors.push(code);
        if (INVALID_TOKEN_CODES.has(code)) removals.push(batch[index]?.ref.delete());
      });
    } catch (error) {
      failureCount += batch.length;
      errors.push(text(error?.code || error?.message || error, 300));
    }
  }

  await Promise.allSettled(removals.filter(Boolean));
  return {
    status: successCount > 0 ? (failureCount > 0 ? 'partial' : 'sent') : 'failed',
    attempted: entries.length,
    successCount,
    failureCount,
    errors: unique(errors).slice(0, 10),
  };
}

function smtpConfig() {
  const host = text(process.env.SMTP_HOST, 200);
  const user = text(process.env.SMTP_USER, 300);
  const pass = String(process.env.SMTP_PASS || '');
  const from = text(process.env.SMTP_FROM, 300);
  if (!host || !user || !pass || !from) return null;
  const port = Number(process.env.SMTP_PORT || 587);
  return { host, port, secure: port === 465, auth: { user, pass }, from };
}

function emailHtml({ title, body, schoolName, eventLabel }) {
  const safe = (value) => text(value, 1000)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  return `<!doctype html><html><body style="margin:0;background:#f3f6fb;font-family:Arial,sans-serif;color:#0b1935"><table role="presentation" width="100%" cellspacing="0" cellpadding="0"><tr><td align="center" style="padding:32px 16px"><table role="presentation" width="100%" style="max-width:600px;background:#fff;border-radius:18px;border:1px solid #dfe7f2"><tr><td style="padding:30px"><div style="font-size:20px;font-weight:800;color:#1267e8">School Pulse</div><div style="font-size:12px;color:#718096;margin-top:4px">SaaS Owner Alert</div><div style="margin:28px 0 8px;font-size:12px;font-weight:700;letter-spacing:.08em;color:#1267e8;text-transform:uppercase">${safe(eventLabel)}</div><h1 style="font-size:24px;line-height:1.25;margin:0 0 12px">${safe(title)}</h1>${schoolName ? `<div style="font-size:16px;font-weight:700;margin-bottom:10px">${safe(schoolName)}</div>` : ''}<p style="font-size:15px;line-height:1.6;color:#44546a;margin:0">${safe(body)}</p><div style="margin-top:26px;padding:16px;background:#f5f8fd;border-radius:12px;color:#52647a;font-size:13px">Open the secured School Pulse SaaS Owner app to review and take action. Approval actions are never performed from email.</div><div style="margin-top:28px;font-size:12px;color:#9aa8ba">Victorbee Technologies · School Pulse</div></td></tr></table></td></tr></table></body></html>`;
}

async function deliverEmail(ownerDocs, payload) {
  const config = smtpConfig();
  const recipients = unique([
    ...ownerDocs.map((doc) => text(doc.data()?.email, 200).toLowerCase()),
    text(process.env.OWNER_NOTIFICATION_EMAIL, 200).toLowerCase(),
  ]);

  if (!config) return { status: 'not_configured', recipients, sentCount: 0 };
  if (recipients.length === 0) return { status: 'no_recipients', recipients: [], sentCount: 0 };

  const transporter = nodemailer.createTransport({
    host: config.host,
    port: config.port,
    secure: config.secure,
    auth: config.auth,
  });

  try {
    const info = await transporter.sendMail({
      from: config.from,
      to: recipients.join(', '),
      subject: `[School Pulse] ${payload.title}`,
      text: `${payload.title}\n\n${payload.body}\n\nOpen the School Pulse SaaS Owner app to review this item.`,
      html: emailHtml(payload),
    });
    return { status: 'sent', recipients, sentCount: recipients.length, messageId: text(info.messageId, 300) };
  } catch (error) {
    return { status: 'failed', recipients, sentCount: 0, error: text(error?.message || error, 500) };
  }
}

async function createInAppAlerts(ownerDocs, eventId, payload) {
  if (ownerDocs.length === 0) return { status: 'no_owner', count: 0 };
  const batch = db.batch();
  for (const ownerDoc of ownerDocs) {
    const ref = db.collection('alerts').doc(`${eventId}_${ownerDoc.id}`);
    batch.set(ref, {
      userId: ownerDoc.id,
      schoolId: payload.data?.schoolId || '',
      title: payload.title,
      body: payload.body,
      data: payload.data || {},
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      readBy: [],
      type: 'Direct',
      source: 'owner_notification_engine',
    }, { merge: true });
  }
  await batch.commit();
  return { status: 'sent', count: ownerDocs.length };
}

async function notifyOwners({ eventId, eventType, title, body, schoolName = '', data = {} }) {
  const deliveryRef = db.collection('notification_deliveries').doc(eventId);
  const existing = await deliveryRef.get();
  if (existing.exists && existing.data()?.completed === true) {
    return existing.data();
  }

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

  const inApp = await createInAppAlerts(owners, eventId, { title, body, data });
  const [push, email] = await Promise.all([
    deliverPush(owners, title, body, data),
    deliverEmail(owners, { title, body, schoolName, eventLabel: eventType }),
  ]);

  const completed = {
    inApp,
    push,
    email,
    completed: true,
    completedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  await deliveryRef.set(completed, { merge: true });
  console.log('Owner notification delivery', eventId, JSON.stringify({ inApp, push, email }));
  return { ...base, ...completed };
}

module.exports = { notifyOwners, getOwnerDocs };
