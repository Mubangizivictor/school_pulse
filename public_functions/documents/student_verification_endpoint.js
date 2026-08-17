const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

// Public, unauthenticated verification page for a scanned student QR/NFC
// credential - the "is this card real" check a gate guard, a visiting
// examiner, or a parent can run with just a phone camera, no School Pulse
// login. Mirrors verification_endpoint.js (verifyOfficialDocument) as the
// template: same onRequest/europe-west1 shape, same escape-first HTML
// renderer, same "resolve token -> render safe fields only" structure.
//
// This is deliberately a SEPARATE exported name and a separate hosting
// route (/verify-student, not /verify) from the pre-existing
// functions/index.js:verifyStudentCredential - that export is an
// authenticated (request.auth required) onCall used internally by staff
// clients against an older HMAC-signed credential scheme, not a public
// HTTP page. Renaming or repurposing it was out of scope and risked
// breaking whatever staff-side call site already depends on it.

const db = () => admin.firestore();

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, (c) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  }[c]));
}

function token(value) {
  return String(value ?? '').trim();
}

// Matches QrCredentialCodec's token pattern on the Flutter side
// (SPQR1.<base64url 40-128 chars>) - reject anything else before touching
// Firestore at all, same cheap-DoS guard as verifyToken() in
// verification_endpoint.js.
const TOKEN_PATTERN = /^SPQR1\.[A-Za-z0-9_-]{40,128}$/;

function statusLabel(status) {
  switch (status) {
    case 'active': return { valid: true, label: 'Valid credential' };
    case 'replaced': return { valid: false, label: 'Credential replaced - no longer valid' };
    case 'revoked': return { valid: false, label: 'Credential revoked' };
    case 'lost': return { valid: false, label: 'Reported lost - credential blocked' };
    case 'stolen': return { valid: false, label: 'Reported stolen - credential blocked' };
    case 'disabled': return { valid: false, label: 'Credential disabled' };
    default: return { valid: false, label: 'Credential not verified' };
  }
}

function page({ valid, statusText, name = '', schoolName = '', level = '', photoUrl = '', logoUrl = '' }) {
  const accent = valid ? '#16823A' : '#B42318';
  const photo = photoUrl
    ? `<img class="avatar" src="${escapeHtml(photoUrl)}" alt="" />`
    : '<div class="avatar placeholder"></div>';
  const logo = logoUrl ? `<img class="logo" src="${escapeHtml(logoUrl)}" alt="" />` : '';
  const details = valid
    ? `<dl><dt>Name</dt><dd>${escapeHtml(name)}</dd>${level ? `<dt>Class</dt><dd>${escapeHtml(level)}</dd>` : ''}<dt>School</dt><dd>${escapeHtml(schoolName)}</dd></dl>`
    : '<p>This QR code does not identify a currently valid School Pulse student card.</p>';
  return `<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Student card verification | School Pulse</title><style>body{margin:0;background:#f5f7fb;color:#172033;font-family:Arial,sans-serif}.card{max-width:480px;margin:8vh auto;padding:32px;background:#fff;border:1px solid #d8e0ef;border-radius:14px;box-shadow:0 12px 30px #102b7920;text-align:center}${logo ? '.logo{max-height:40px;margin-bottom:14px}' : ''}h1{margin:0 0 9px;color:#102b79;font-size:22px}.state{color:${accent};font-weight:700;margin:0 0 20px}.avatar{width:96px;height:96px;border-radius:50%;object-fit:cover;margin:0 auto 18px;display:block;border:3px solid #eef1f8}.avatar.placeholder{background:#eef1f8}dl{display:grid;grid-template-columns:110px 1fr;gap:10px 14px;margin:0;text-align:left}dt{font-size:12px;text-transform:uppercase;font-weight:700;color:#475467}dd{margin:0;font-weight:600;overflow-wrap:anywhere}footer{margin-top:24px;color:#667085;font-size:12px}</style><main class="card">${logo}<h1>Student card verification</h1><p class="state">${escapeHtml(statusText)}</p>${photo}${details}<footer>School Pulse - A VictorBee Technologies Product</footer></main></html>`;
}

/**
 * Resolves an opaque QR token to the safe public fields only. Mirrors
 * IdentityResolverImpl's credential lookup (schools/{schoolId}/credentials
 * keyed by the raw token, status field decides validity) without pulling
 * in any Flutter-side code - this runs in a completely separate Node
 * project (public_functions) with no dependency on the Flutter app.
 *
 * Deliberately NEVER returns: parent contacts, fees, marks, attendance,
 * medical data, discipline records, or the raw credential token/document
 * id. Only school logo, school name, student photo, student display name,
 * class/level, and verified/card status.
 */
async function resolveStudentCredential(rawToken) {
  if (!TOKEN_PATTERN.test(rawToken)) return null;
  const credentialValue = rawToken.split('.')[1];

  // credentialValue alone is not enough to find the doc without knowing
  // schoolId (credentials live under schools/{schoolId}/credentials), so a
  // collectionGroup query is used - same shape as any other cross-school
  // token lookup in this codebase (see identity_resolver's cache-miss path).
  const found = await db()
    .collectionGroup('credentials')
    .where('credentialValue', '==', credentialValue)
    .limit(1)
    .get();
  if (found.empty) return null;

  const credential = found.docs[0].data() || {};
  if (credential.identityType !== 'student') return null;
  const { valid, label } = statusLabel(credential.status);

  const schoolId = credential.schoolId;
  let schoolName = 'Not published';
  let logoUrl = '';
  if (schoolId) {
    const schoolSnap = await db().collection('schools').doc(schoolId).get();
    const school = schoolSnap.exists ? schoolSnap.data() : {};
    schoolName = school?.name || schoolName;
    logoUrl = school?.logoUrl || '';
  }

  let name = '';
  let photoUrl = '';
  let level = '';
  if (valid) {
    // uniqueSystemId on the credential doc links back to student_identities,
    // which links to the actual students/{id} doc - two hops, but neither
    // ever needs to leave this function or expose more than name/photo/level.
    const identitySnap = await db()
      .collection('student_identities')
      .where('uniqueSystemId', '==', credential.identityId)
      .limit(1)
      .get();
    if (!identitySnap.empty) {
      const identity = identitySnap.docs[0].data() || {};
      const studentSnap = identity.studentId
        ? await db().collection('students').doc(identity.studentId).get()
        : null;
      if (studentSnap?.exists) {
        const student = studentSnap.data() || {};
        name = student.name || '';
        photoUrl = student.photoUrl || '';
        level = student.className || student.classId || '';
      }
    }
  }

  return { valid, statusText: label, name, schoolName, level, photoUrl, logoUrl };
}

exports.verifyStudentQrCredential = onRequest({ region: 'europe-west1' }, async (req, res) => {
  if (req.method !== 'GET') { res.status(405).set('Allow', 'GET').send('Method Not Allowed'); return; }
  res.set('Cache-Control', 'no-store, max-age=0').set('X-Content-Type-Options', 'nosniff');
  try {
    const result = await resolveStudentCredential(token(req.query?.token));
    if (!result) {
      res.status(404).type('html').send(page({ valid: false, statusText: 'Card not verified' }));
      return;
    }
    res.status(result.valid ? 200 : 410).type('html').send(page(result));
  } catch (error) {
    console.error('STUDENT_CREDENTIAL_VERIFICATION_FAILED', error);
    res.status(500).type('html').send(page({ valid: false, statusText: 'Verification unavailable' }));
  }
});

exports.__test__ = { token, page, statusLabel, resolveStudentCredential, TOKEN_PATTERN };
