const crypto = require('node:crypto');
const admin = require('firebase-admin');
const { DOCUMENT_TYPES, TYPE_CONFIG } = require('./document_types');
const { renderOfficialPdf } = require('./pdf_renderer');

const db = admin.firestore();
const MONTHS = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
function asDate(value) {
  if (!value) return null;
  if (typeof value.toDate === 'function') return value.toDate();
  if (value instanceof Date) return value;
  if (typeof value === 'number') return new Date(value);
  const parsed = new Date(value); return Number.isNaN(parsed.valueOf()) ? null : parsed;
}
function kampalaParts(value) {
  const date = asDate(value); if (!date) throw new Error('Missing authoritative timestamp for official document.');
  const parts = new Intl.DateTimeFormat('en-GB', { timeZone: 'Africa/Kampala', day: '2-digit', month: '2-digit', year: 'numeric' }).formatToParts(date);
  const get = (type) => parts.find((part) => part.type === type)?.value;
  return { day: get('day'), month: Number(get('month')), year: get('year') };
}
function officialDate(value) { const p = kampalaParts(value); return `${p.day} ${MONTHS[p.month - 1]} ${p.year}`; }
function documentKey(type, entityId) { return crypto.createHash('sha256').update(`${type}:${entityId}`).digest('hex').slice(0, 40); }
function clean(value, max = 180) { return String(value ?? '').replace(/[\r\n]+/g, ' ').trim().slice(0, max); }
function amount(value, currency = 'UGX') { const n = Number(value); return Number.isFinite(n) ? `${clean(currency, 8) || 'UGX'} ${Math.round(n).toLocaleString('en-US')}` : ''; }
// Firestore forbids arrays nested inside arrays. The renderer accepts either
// shape for backwards compatibility, but persisted official snapshots use
// objects so an event can never fail while writing its immutable record.
function firestoreSafeSnapshot(snapshot) {
  return {
    ...snapshot,
    rows: Array.isArray(snapshot?.rows)
      ? snapshot.rows.map((row) => Array.isArray(row) ? { label: clean(row[0], 100), value: clean(row[1], 500) } : row)
      : [],
  };
}

async function issueOfficialDocument({ type, entityId, schoolId, effectiveAt, sourceEventId, snapshot }) {
  const config = TYPE_CONFIG[type];
  if (!config) throw new Error(`Unknown official document type: ${type}`);
  const effective = asDate(effectiveAt);
  if (!effective) throw new Error(`Cannot issue ${type}: authoritative event timestamp is missing.`);
  const { year } = kampalaParts(effective);
  const id = documentKey(type, entityId);
  const ref = db.collection('official_documents').doc(id);
  const reservation = await db.runTransaction(async (tx) => {
    const existing = await tx.get(ref);
    if (existing.exists) return existing.data();
    const counterRef = db.collection('official_document_counters').doc(`${year}_${type}`);
    const counter = await tx.get(counterRef);
    const number = Number(counter.data()?.lastNumber || 0) + 1;
    const documentNumber = `SP-${config.prefix}-${year}-${String(number).padStart(6, '0')}`;
    tx.set(counterRef, { lastNumber: number, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    const storageScope = clean(schoolId, 180) || 'platform-applications';
    const storagePath = `official_documents/${storageScope}/${year}/${type}/${documentNumber}.pdf`;
    const issuedSnapshot = firestoreSafeSnapshot(snapshot);
    const issued = {
      schoolId: clean(schoolId, 180) || null, documentType: type, documentNumber, businessEntityId: clean(entityId, 220),
      sourceEventId: clean(sourceEventId, 260), issuedAt: admin.firestore.FieldValue.serverTimestamp(), effectiveDate: effective,
      status: 'generating', storagePath, templateVersion: 1, stampApplied: true, stampDate: officialDate(effective),
      snapshot: { ...issuedSnapshot, effectiveDate: officialDate(effective), documentNumber }, createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    tx.create(ref, issued); return issued;
  });
  if (reservation.status === 'issued') return { id, ...reservation };
  const stored = await ref.get();
  const document = stored.data() || reservation;
  const issuedAt = asDate(document.issuedAt) || new Date();
  const pdf = await renderOfficialPdf({ ...document.snapshot, title: config.title, documentNumber: document.documentNumber,
    stampDate: document.stampDate, issuedLabel: officialDate(issuedAt) });
  const file = admin.storage().bucket().file(document.storagePath);
  await file.save(pdf, { resumable: false, contentType: 'application/pdf', metadata: { cacheControl: 'private, max-age=0' } });
  const checksum = crypto.createHash('sha256').update(pdf).digest('hex');
  await ref.set({ status: 'issued', checksum, generatedAt: admin.firestore.FieldValue.serverTimestamp(), byteSize: pdf.length }, { merge: true });
  return { id, ...document, status: 'issued' };
}

function applicationApproval(applicationId, application) {
  const approvedAt = application.approvedAt;
  return issueOfficialDocument({ type: DOCUMENT_TYPES.APPLICATION_APPROVAL, entityId: applicationId, schoolId: application.schoolId,
    sourceEventId: `application-approved:${applicationId}`, effectiveAt: approvedAt,
    snapshot: { schoolName: clean(application.school?.name || application.schoolName, 160) || 'School Pulse applicant',
      rows: [['School', clean(application.school?.name || application.schoolName, 160)], ['Applicant', clean(`${application.administrator?.firstName || ''} ${application.administrator?.lastName || ''}`, 160)], ['Application status', 'APPROVED'], ['Approval date', officialDate(approvedAt)]],
      notice: 'Your School Pulse application has been approved. Complete the required subscription payment to activate your school environment.' } });
}
function paymentAcknowledgement(paymentId, payment) {
  const submittedAt = payment.submittedAt || payment.receivedAt;
  return issueOfficialDocument({ type: DOCUMENT_TYPES.PAYMENT_ACKNOWLEDGEMENT, entityId: paymentId, schoolId: payment.schoolId,
    sourceEventId: `payment-proof-received:${paymentId}`, effectiveAt: submittedAt,
    snapshot: { rows: [['School', clean(payment.schoolName, 160)], ['Amount submitted', amount(payment.submittedAmount || payment.amount, payment.currency)], ['Payment method', clean(payment.method, 80)], ['Payment reference', clean(payment.reference, 120)], ['Received date', officialDate(submittedAt)], ['Status', 'PENDING VERIFICATION']],
      notice: 'This document confirms receipt of payment information for verification. It does not constitute confirmation that the payment has been verified or settled.' } });
}
function paymentReceipt(paymentId, payment, verifiedAt) {
  const status = clean(payment.status, 40).toLowerCase();
  if (!['approved', 'successful', 'success'].includes(status)) throw new Error('Cannot issue a paid receipt for a non-verified payment.');
  return issueOfficialDocument({ type: DOCUMENT_TYPES.PAYMENT_RECEIPT, entityId: paymentId, schoolId: payment.schoolId,
    sourceEventId: `payment-receipt:${paymentId}`, effectiveAt: verifiedAt,
    snapshot: { rows: [['School', clean(payment.schoolName, 160)], ['Amount paid', amount(payment.submittedAmount || payment.realPlanPriceUgx || payment.amount, payment.currency)], ['Payment method', clean(payment.method || payment.provider, 80)], ['Provider / transaction reference', clean(payment.reference || payment.mtnFinancialTransactionId, 120)], ['Verified date', officialDate(verifiedAt)], ['Plan', clean(payment.planName || payment.planId, 80)], ['Payment status', 'PAID / VERIFIED']],
      notice: 'This receipt confirms that the payment above has been verified and the applicable School Pulse subscription has been processed.' } });
}
function subscriptionDocument(paymentId, payment, effectiveAt) {
  return issueOfficialDocument({ type: DOCUMENT_TYPES.SUBSCRIPTION, entityId: paymentId, schoolId: payment.schoolId,
    sourceEventId: `subscription-${clean(payment.paymentType, 20) || 'activation'}:${paymentId}`, effectiveAt,
    snapshot: { rows: [['School', clean(payment.schoolName, 160)], ['Plan', clean(payment.planName || payment.planId, 80)], ['Billing period', clean(payment.termLengthDays, 30) ? `${clean(payment.termLengthDays, 30)} days` : 'Subscription term'], ['Amount', amount(payment.submittedAmount || payment.realPlanPriceUgx || payment.amount, payment.currency)], ['Start date', officialDate(effectiveAt)], ['Expiry date', payment.subscriptionExpiry ? officialDate(payment.subscriptionExpiry) : ''], ['Status', clean(payment.paymentType, 30).toUpperCase() === 'RENEWAL' ? 'RENEWED' : 'ACTIVATED']],
      notice: 'This document confirms the current School Pulse subscription term associated with the verified payment.' } });
}

function attachmentFor(document) { return { filename: `${document.documentNumber}.pdf`, storagePath: document.storagePath, contentType: 'application/pdf', documentId: document.id }; }
module.exports = { DOCUMENT_TYPES, officialDate, kampalaParts, firestoreSafeSnapshot, applicationApproval, paymentAcknowledgement, paymentReceipt, subscriptionDocument, attachmentFor, issueOfficialDocument };
