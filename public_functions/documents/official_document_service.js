const crypto = require('node:crypto');
const admin = require('firebase-admin');
const { DOCUMENT_TYPES, TYPE_CONFIG } = require('./document_types');
const { renderOfficialPdf } = require('./pdf_renderer');

const db = admin.firestore();
const MONTHS = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
// This is the live Firebase Hosting origin that serves the verifier rewrite.
// Do not use the custom domain until it is attached to this Hosting site; a
// QR must always resolve to the actual read-only verification endpoint.
const VERIFICATION_ORIGIN = 'https://school-pulse-3d95b.web.app/verify';
function asDate(value) { if (!value) return null; if (typeof value.toDate === 'function') return value.toDate(); if (value instanceof Date) return value; if (typeof value === 'number') return new Date(value); const parsed = new Date(value); return Number.isNaN(parsed.valueOf()) ? null : parsed; }
function kampalaParts(value) { const date = asDate(value); if (!date) throw new Error('Missing authoritative timestamp for official document.'); const parts = new Intl.DateTimeFormat('en-GB', { timeZone: 'Africa/Kampala', day: '2-digit', month: '2-digit', year: 'numeric' }).formatToParts(date); const get = (type) => parts.find((part) => part.type === type)?.value; return { day: get('day'), month: Number(get('month')), year: get('year') }; }
function officialDate(value) { const p = kampalaParts(value); return `${p.day} ${MONTHS[p.month - 1]} ${p.year}`; }
function documentKey(type, entityId) { return crypto.createHash('sha256').update(`${type}:${entityId}`).digest('hex').slice(0, 40); }
function clean(value, max = 180) { return String(value ?? '').replace(/[\r\n]+/g, ' ').trim().slice(0, max); }
function amount(value, currency = 'UGX') { const n = Number(value); return Number.isFinite(n) && n >= 0 ? `${clean(currency, 8) || 'UGX'} ${Math.round(n).toLocaleString('en-US')}` : ''; }
function verificationUrl(token) { return `${VERIFICATION_ORIGIN}?token=${encodeURIComponent(token)}`; }
function paidStatus(status) { return ['approved', 'successful', 'success'].includes(clean(status, 40).toLowerCase()); }
function firestoreSafeSnapshot(snapshot) { return { ...snapshot, rows: Array.isArray(snapshot?.rows) ? snapshot.rows.map((row) => Array.isArray(row) ? { label: clean(row[0], 100), value: clean(row[1], 500) } : row) : [] }; }

async function canonicalApplication(applicationId) {
  const snap = await db.collection('public_school_applications').doc(clean(applicationId, 220)).get();
  if (!snap.exists) throw new Error('Cannot issue application approval: canonical application was not found.');
  const app = snap.data() || {};
  if (clean(app.status, 40).toLowerCase() !== 'approved') throw new Error('Cannot issue application approval for a non-approved application.');
  if (!asDate(app.approvedAt)) throw new Error('Cannot issue application approval: authoritative approval timestamp is missing.');
  return app;
}
async function canonicalPayment(paymentId, { requireApproved = true } = {}) {
  const snap = await db.collection('manual_subscription_payments').doc(clean(paymentId, 220)).get();
  if (!snap.exists) throw new Error('Cannot issue payment document: canonical payment was not found.');
  const payment = snap.data() || {}; const status = clean(payment.status, 40).toLowerCase();
  if (requireApproved && !paidStatus(status)) throw new Error('Cannot issue a paid receipt for a non-verified payment.');
  return payment;
}
async function canonicalSubscription(paymentId, payment) {
  const snap = await db.collection('subscription_receipts').doc(clean(paymentId, 220)).get();
  if (!snap.exists) throw new Error('Cannot issue subscription document: canonical subscription receipt was not found.');
  const receipt = snap.data() || {};
  if (!receipt.schoolId || receipt.schoolId !== payment.schoolId) throw new Error('Cannot issue subscription document: tenant relationship is invalid.');
  if (!asDate(receipt.periodStart) || !asDate(receipt.periodEnd)) throw new Error('Cannot issue subscription document: canonical subscription dates are missing.');
  return receipt;
}

async function issueOfficialDocument({ type, entityId, schoolId, effectiveAt, sourceEventId, snapshot }) {
  const config = TYPE_CONFIG[type]; if (!config) throw new Error(`Unknown official document type: ${type}`);
  const effective = asDate(effectiveAt); if (!effective) throw new Error(`Cannot issue ${type}: authoritative event timestamp is missing.`);
  const { year } = kampalaParts(effective); const id = documentKey(type, entityId); const ref = db.collection('official_documents').doc(id);
  const reservation = await db.runTransaction(async (tx) => {
    const existing = await tx.get(ref); if (existing.exists) return { document: existing.data(), existing: true };
    const counterRef = db.collection('official_document_counters').doc(`${year}_${type}`); const counter = await tx.get(counterRef); const number = Number(counter.data()?.lastNumber || 0) + 1;
    const documentNumber = `SP-${config.prefix}-${year}-${String(number).padStart(6, '0')}`; const storageScope = clean(schoolId, 180) || 'platform-applications'; const verificationToken = crypto.randomBytes(24).toString('base64url');
    const issuedSnapshot = firestoreSafeSnapshot({ ...snapshot, verificationUrl: verificationUrl(verificationToken) });
    const document = { schoolId: clean(schoolId, 180) || null, documentType: type, documentNumber, businessEntityId: clean(entityId, 220), sourceEventId: clean(sourceEventId, 260), issuedAt: admin.firestore.FieldValue.serverTimestamp(), effectiveDate: effective, status: 'generating', storagePath: `official_documents/${storageScope}/${year}/${type}/${documentNumber}.pdf`, templateVersion: 2, stampApplied: true, stampDate: officialDate(effective), verificationToken, snapshot: { ...issuedSnapshot, effectiveDate: officialDate(effective), documentNumber }, createdAt: admin.firestore.FieldValue.serverTimestamp() };
    tx.set(counterRef, { lastNumber: number, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true }); tx.create(ref, document); return { document, existing: false };
  });
  if (reservation.existing && reservation.document.status === 'issued') return { id, ...reservation.document };
  const stored = await ref.get(); const document = stored.data() || reservation.document;
  if (!document.verificationToken || !document.snapshot?.verificationUrl) throw new Error('Existing official document cannot be rendered safely without a verification token.');
  const pdf = await renderOfficialPdf({ ...document.snapshot, title: config.title, documentNumber: document.documentNumber, stampDate: document.stampDate, issuedLabel: officialDate(document.effectiveDate) });
  await admin.storage().bucket().file(document.storagePath).save(pdf, { resumable: false, contentType: 'application/pdf', metadata: { cacheControl: 'private, max-age=0' } });
  const checksum = crypto.createHash('sha256').update(pdf).digest('hex'); await ref.set({ status: 'issued', checksum, generatedAt: admin.firestore.FieldValue.serverTimestamp(), byteSize: pdf.length }, { merge: true }); return { id, ...document, status: 'issued' };
}

async function applicationApproval(applicationId) {
  const app = await canonicalApplication(applicationId); const approvedAt = app.approvedAt;
  return issueOfficialDocument({ type: DOCUMENT_TYPES.APPLICATION_APPROVAL, entityId: applicationId, schoolId: app.schoolId, sourceEventId: `application-approved:${applicationId}`, effectiveAt: approvedAt, snapshot: { schoolName: clean(app.school?.name || app.schoolName, 160), rows: [['School', clean(app.school?.name || app.schoolName, 160)], ['Applicant', clean(`${app.administrator?.firstName || ''} ${app.administrator?.lastName || ''}`, 160)], ['Application status', 'APPROVED'], ['Approval date', officialDate(approvedAt)]], notice: 'Your School Pulse application has been approved. Complete the required subscription payment to activate your school environment.' } });
}
async function paymentAcknowledgement(paymentId) {
  const payment = await canonicalPayment(paymentId, { requireApproved: false }); const submittedAt = payment.submittedAt || payment.receivedAt;
  if (!asDate(submittedAt)) throw new Error('Cannot issue payment acknowledgement: authoritative received timestamp is missing.');
  return issueOfficialDocument({ type: DOCUMENT_TYPES.PAYMENT_ACKNOWLEDGEMENT, entityId: paymentId, schoolId: payment.schoolId, sourceEventId: `payment-proof-received:${paymentId}`, effectiveAt: submittedAt, snapshot: { schoolName: clean(payment.schoolName, 160), rows: [['School', clean(payment.schoolName, 160)], ['Amount submitted', amount(payment.submittedAmount || payment.amount, payment.currency)], ['Payment method', clean(payment.method, 80)], ['Payment reference', clean(payment.reference, 120)], ['Received date', officialDate(submittedAt)], ['Status', 'PENDING VERIFICATION']], notice: 'This document confirms receipt of payment information for verification. It does not constitute confirmation that the payment has been verified or settled.' } });
}
async function paymentReceipt(paymentId) {
  const payment = await canonicalPayment(paymentId); const verifiedAt = payment.reviewedAt; if (!asDate(verifiedAt)) throw new Error('Cannot issue payment receipt: authoritative verification timestamp is missing.');
  const subscription = await canonicalSubscription(paymentId, payment); const canonicalAmount = subscription.amountUgx;
  return issueOfficialDocument({ type: DOCUMENT_TYPES.PAYMENT_RECEIPT, entityId: paymentId, schoolId: payment.schoolId, sourceEventId: `payment-receipt:${paymentId}`, effectiveAt: verifiedAt, snapshot: { schoolName: clean(payment.schoolName, 160), rows: [['School', clean(payment.schoolName, 160)], ['Amount paid', amount(canonicalAmount, subscription.currency || payment.currency)], ['Payment method', clean(subscription.method || payment.method || payment.provider, 80)], ['Payment / transaction reference', clean(payment.reference || payment.mtnFinancialTransactionId, 120)], ['Verified date', officialDate(verifiedAt)], ['Plan', clean(subscription.planName || subscription.planId, 80)], ['Payment status', 'PAID / VERIFIED']], notice: 'This receipt confirms that the payment above has been verified and the applicable School Pulse subscription has been processed.' } });
}
async function subscriptionDocument(paymentId) {
  const payment = await canonicalPayment(paymentId); const subscription = await canonicalSubscription(paymentId, payment); const effectiveAt = subscription.periodStart;
  return issueOfficialDocument({ type: DOCUMENT_TYPES.SUBSCRIPTION, entityId: paymentId, schoolId: payment.schoolId, sourceEventId: `subscription-${clean(subscription.paymentType || payment.paymentType, 20) || 'activation'}:${paymentId}`, effectiveAt, snapshot: { schoolName: clean(subscription.schoolName || payment.schoolName, 160), rows: [['School', clean(subscription.schoolName || payment.schoolName, 160)], ['Plan', clean(subscription.planName || subscription.planId, 80)], ['Billing period', subscription.periodStart && subscription.periodEnd ? `${Math.max(1, Math.round((asDate(subscription.periodEnd) - asDate(subscription.periodStart)) / 86400000))} days` : ''], ['Amount', amount(subscription.amountUgx, subscription.currency)], ['Start date', officialDate(subscription.periodStart)], ['Expiry date', officialDate(subscription.periodEnd)], ['Payment reference', clean(payment.reference || payment.mtnFinancialTransactionId, 120)], ['Status', clean(subscription.paymentType || payment.paymentType, 30).toUpperCase() === 'RENEWAL' ? 'RENEWED' : 'ACTIVATED']], notice: 'This document confirms the current School Pulse subscription term associated with the verified payment.' } });
}
function attachmentFor(document) { return { filename: `${document.documentNumber}.pdf`, storagePath: document.storagePath, contentType: 'application/pdf', documentId: document.id }; }
module.exports = { DOCUMENT_TYPES, VERIFICATION_ORIGIN, officialDate, kampalaParts, firestoreSafeSnapshot, verificationUrl, paidStatus, applicationApproval, paymentAcknowledgement, paymentReceipt, subscriptionDocument, attachmentFor, issueOfficialDocument };
