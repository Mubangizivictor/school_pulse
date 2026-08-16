const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { TYPE_CONFIG } = require('./document_types');

const db = admin.firestore();
function escapeHtml(value) { return String(value ?? '').replace(/[&<>"']/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[character])); }
function token(value) { return String(value ?? '').trim(); }
function page({ valid, title, reference = '', type = '', school = '', date = '' }) {
  const accent = valid ? '#16823A' : '#B42318';
  const details = valid ? `<dl><dt>Official reference</dt><dd>${escapeHtml(reference)}</dd><dt>Document type</dt><dd>${escapeHtml(type)}</dd><dt>School</dt><dd>${escapeHtml(school)}</dd><dt>Issued</dt><dd>${escapeHtml(date)}</dd></dl>` : '<p>This QR code does not identify a currently valid School Pulse official document.</p>';
  return `<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${escapeHtml(title)} | School Pulse</title><style>body{margin:0;background:#f5f7fb;color:#172033;font-family:Arial,sans-serif}.card{max-width:560px;margin:8vh auto;padding:32px;background:#fff;border:1px solid #d8e0ef;border-radius:14px;box-shadow:0 12px 30px #102b7920}h1{margin:0 0 9px;color:#102b79;font-size:26px}.state{color:${accent};font-weight:700;margin:0 0 26px}dl{display:grid;grid-template-columns:170px 1fr;gap:13px 18px;margin:0}dt{font-size:12px;text-transform:uppercase;font-weight:700;color:#475467}dd{margin:0;font-weight:600;overflow-wrap:anywhere}footer{margin-top:28px;color:#667085;font-size:13px}</style><main class="card"><h1>School Pulse document verification</h1><p class="state">${valid ? 'Valid official document' : 'Document not verified'}</p>${details}<footer>School Pulse - A VictorBee Technologies Product</footer></main></html>`;
}
async function verifyToken(rawToken) {
  if (!/^[A-Za-z0-9_-]{30,80}$/.test(rawToken)) return null;
  const found = await db.collection('official_documents').where('verificationToken', '==', rawToken).limit(1).get();
  if (found.empty) return null;
  const document = found.docs[0].data() || {};
  if (document.status !== 'issued') return null;
  return document;
}
exports.verifyOfficialDocument = onRequest({ region: 'europe-west1' }, async (req, res) => {
  if (req.method !== 'GET') { res.status(405).set('Allow', 'GET').send('Method Not Allowed'); return; }
  res.set('Cache-Control', 'no-store, max-age=0').set('X-Content-Type-Options', 'nosniff');
  try {
    const document = await verifyToken(token(req.query?.token));
    if (!document) { res.status(404).type('html').send(page({ valid: false, title: 'Document not verified' })); return; }
    const type = TYPE_CONFIG[document.documentType]?.title || 'Official School Pulse document';
    res.status(200).type('html').send(page({ valid: true, title: 'Document verified', reference: document.documentNumber, type, school: document.snapshot?.schoolName || 'Not published', date: document.snapshot?.effectiveDate || document.stampDate || '' }));
  } catch (error) { console.error('OFFICIAL_DOCUMENT_VERIFICATION_FAILED', error); res.status(500).type('html').send(page({ valid: false, title: 'Verification unavailable' })); }
});
exports.__test__ = { token, page };
