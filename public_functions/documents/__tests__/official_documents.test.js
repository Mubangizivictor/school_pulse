const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const admin = require('firebase-admin');
if (!admin.apps.length) admin.initializeApp({ projectId: 'school-pulse-test' });
const { STAMP_PATH, STAMP_ASPECT_RATIO, assertStampAsset } = require('../stamp_renderer');
const { officialDate, paidStatus, firestoreSafeSnapshot, verificationUrl } = require('../official_document_service');
const { renderOfficialPdf } = require('../pdf_renderer');
const { __test__: emailTest } = require('../../email/email_service');

let passed = 0;
async function test(name, fn) {
  try { await fn(); passed += 1; console.log(`  ok  - ${name}`); }
  catch (error) { console.error(`FAIL  - ${name}\n        ${error.message}`); process.exitCode = 1; }
}

(async () => {
  console.log('Official documents');
  await test('canonical stamp asset exists and is non-empty', () => {
    assert.equal(assertStampAsset(), STAMP_PATH);
    assert.ok(fs.statSync(STAMP_PATH).size > 1000);
  });
  await test('stamp aspect ratio is retained centrally', () => assert.equal(STAMP_ASPECT_RATIO, 1774 / 887));
  await test('formats authoritative dates in Africa/Kampala', () => {
    assert.equal(officialDate(new Date('2026-08-15T21:30:00.000Z')), '16 AUG 2026');
    assert.equal(officialDate(new Date('2026-01-01T20:59:59.000Z')), '01 JAN 2026');
  });
  await test('missing authoritative timestamp fails safely', () => assert.throws(() => officialDate(null), /Missing authoritative timestamp/));
  await test('pending and rejected payments cannot issue paid receipts', () => {
    for (const status of ['pending_verification', 'rejected', 'failed']) {
      assert.equal(paidStatus(status), false);
    }
    assert.equal(paidStatus('approved'), true);
  });
  await test('issued snapshots contain no Firestore-invalid nested arrays', () => {
    const snapshot = firestoreSafeSnapshot({ rows: [['School', 'Kampala Junior School'], ['Status', 'APPROVED']] });
    assert.deepEqual(snapshot.rows, [{ label: 'School', value: 'Kampala Junior School' }, { label: 'Status', value: 'APPROVED' }]);
    assert.ok(snapshot.rows.every((row) => !Array.isArray(row)));
  });
  await test('attachments are passed through to the existing Resend payload and omitted for normal mail', () => {
    const hosted = { template: { id: 'published-template', variables: {} } };
    const attachment = { filename: 'SP-RCP-2026-000123.pdf', content: Buffer.from('%PDF'), contentType: 'application/pdf' };
    assert.equal(emailTest.applyAttachments({ ...hosted }, []).attachments, undefined);
    assert.deepEqual(emailTest.applyAttachments({ ...hosted }, [attachment]).attachments, [attachment]);
  });
  await test('creates an opaque public verification URL', () => {
    const url = verificationUrl('A'.repeat(32));
    assert.equal(url, 'https://schoolpulse.victorbee.com/verify?token=' + 'A'.repeat(32));
    assert.doesNotMatch(url, /internal-payment-id/);
  });
  await test('renders a real PDF with the official reference and QR verification payload', async () => {
    const bytes = await renderOfficialPdf({ title: 'APPLICATION APPROVAL', documentNumber: 'SP-APP-2026-000123', stampDate: '16 AUG 2026', issuedLabel: '16 AUG 2026', verificationUrl: verificationUrl('A'.repeat(32)), rows: [['School', 'Kampala Junior School'], ['Status', 'APPROVED']], notice: 'Your application has been approved.' });
    assert.ok(bytes.subarray(0, 4).equals(Buffer.from('%PDF')));
    const output = path.join(__dirname, '..', '..', 'tmp', 'pdfs', 'official-document-sample.pdf');
    fs.mkdirSync(path.dirname(output), { recursive: true });
    fs.writeFileSync(output, bytes);
    assert.match(bytes.toString('latin1'), /\(SP-APP-2026-000123\)/);
  });
  console.log(`${passed} passed`);
})();
