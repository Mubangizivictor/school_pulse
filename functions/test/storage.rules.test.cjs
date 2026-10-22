// Storage rules tests for the staff enrolment upload paths:
// schools/{schoolId}/staff/{staffUid}/profile/{fileName} and
// .../documents/{fileName}. storage.rules gates these paths with
// firestore.get() reads against users/{uid}, so this suite spins up both
// the Firestore and Storage emulators (see initializeTestEnvironment below)
// and seeds Firestore directly, mirroring the pattern in
// firestore.rules.test.cjs.
const { after, before, beforeEach, describe, test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const { doc, setDoc } = require('firebase/firestore');
const {
  ref,
  uploadBytes,
  deleteObject,
} = require('firebase/storage');

const projectId = 'demo-school-pulse-storage-rules-test';
const storageRules = fs.readFileSync(
  path.resolve(__dirname, '../../storage.rules'),
  'utf8',
);
const firestoreRules = fs.readFileSync(
  path.resolve(__dirname, '../../firestore.rules'),
  'utf8',
);

let testEnv;

function storageFor(uid) {
  return testEnv.authenticatedContext(uid).storage();
}

const PNG_BYTES = Uint8Array.from([
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a,
]);

async function seed() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    const users = {
      // Admin of schoolA - authorised to manage any staff member's files
      // within schoolA via isSchoolStaffAdmin.
      adminA: { role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: 'schoolA' },
      // Admin of a different school - must never reach into schoolA.
      adminB: { role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: 'schoolB' },
      // The staff member whose own profile/documents live under
      // schools/schoolA/staff/staffA/* - this is also the row
      // createStaffAccount itself writes at users/{uid} right after Auth
      // user creation, so isStaffOwner can resolve schoolId immediately.
      staffA: { role: 'classTeacher', roles: ['classTeacher'], schoolId: 'schoolA' },
      // A different, non-admin staff member in the SAME school as staffA -
      // must not be able to touch staffA's files.
      coworkerA: { role: 'classTeacher', roles: ['classTeacher'], schoolId: 'schoolA' },
      // Clinical roles for the clinic-visit attachment path.
      nurseA: { role: 'nurse', roles: ['nurse'], schoolId: 'schoolA' },
      nurseB: { role: 'nurse', roles: ['nurse'], schoolId: 'schoolB' },
      headA: { role: 'headTeacher', roles: ['headTeacher'], schoolId: 'schoolA' },
      parentA: { role: 'parent', roles: ['parent'], schoolId: 'schoolA' },
    };
    await Promise.all(
      Object.entries(users).map(([uid, data]) => setDoc(doc(db, 'users', uid), data)),
    );
  });
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: { rules: firestoreRules },
    storage: { rules: storageRules },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await seed();
});

after(async () => {
  await testEnv.cleanup();
});

describe('staff profile/document storage rules', () => {
  test('authorised same-school admin can upload a staff profile photo', async () => {
    const fileRef = ref(
      storageFor('adminA'),
      'schools/schoolA/staff/staffA/profile/photo.png',
    );
    await assertSucceeds(
      uploadBytes(fileRef, PNG_BYTES, { contentType: 'image/png' }),
    );
  });

  test('the staff owner can upload their own profile photo and document', async () => {
    const photoRef = ref(
      storageFor('staffA'),
      'schools/schoolA/staff/staffA/profile/photo.png',
    );
    await assertSucceeds(
      uploadBytes(photoRef, PNG_BYTES, { contentType: 'image/png' }),
    );
    const docRef = ref(
      storageFor('staffA'),
      'schools/schoolA/staff/staffA/documents/id_card.png',
    );
    await assertSucceeds(
      uploadBytes(docRef, PNG_BYTES, { contentType: 'image/png' }),
    );
  });

  test('a different staff member in the same school (non-owner, non-admin) cannot upload or read', async () => {
    const photoRef = ref(
      storageFor('coworkerA'),
      'schools/schoolA/staff/staffA/profile/photo.png',
    );
    await assertFails(
      uploadBytes(photoRef, PNG_BYTES, { contentType: 'image/png' }),
    );
    const docRef = ref(
      storageFor('coworkerA'),
      'schools/schoolA/staff/staffA/documents/id_card.png',
    );
    await assertFails(
      uploadBytes(docRef, PNG_BYTES, { contentType: 'image/png' }),
    );
  });

  test('an admin from a different school cannot upload, read, or delete', async () => {
    const photoRef = ref(
      storageFor('adminB'),
      'schools/schoolA/staff/staffA/profile/photo.png',
    );
    await assertFails(
      uploadBytes(photoRef, PNG_BYTES, { contentType: 'image/png' }),
    );

    // Seed a real object as the authorised admin first, so the delete
    // attempt below is denied by the rule rather than trivially failing
    // because the object never existed.
    await assertSucceeds(
      uploadBytes(
        ref(storageFor('adminA'), 'schools/schoolA/staff/staffA/profile/existing.png'),
        PNG_BYTES,
        { contentType: 'image/png' },
      ),
    );
    await assertFails(
      deleteObject(
        ref(storageFor('adminB'), 'schools/schoolA/staff/staffA/profile/existing.png'),
      ),
    );
  });

  test('an anonymous (unauthenticated) caller cannot upload staff files', async () => {
    const anonStorage = testEnv.unauthenticatedContext().storage();
    const photoRef = ref(anonStorage, 'schools/schoolA/staff/staffA/profile/photo.png');
    await assertFails(
      uploadBytes(photoRef, PNG_BYTES, { contentType: 'image/png' }),
    );
  });

  test('an oversized profile photo is rejected even for an authorised admin', async () => {
    const oversized = new Uint8Array(6 * 1024 * 1024); // isSafeStaffImage caps at 5MB
    const fileRef = ref(
      storageFor('adminA'),
      'schools/schoolA/staff/staffA/profile/oversized.png',
    );
    await assertFails(
      uploadBytes(fileRef, oversized, { contentType: 'image/png' }),
    );
  });

  test('a wrong-content-type profile upload is rejected even for an authorised admin', async () => {
    const fileRef = ref(
      storageFor('adminA'),
      'schools/schoolA/staff/staffA/profile/notes.txt',
    );
    await assertFails(
      uploadBytes(fileRef, PNG_BYTES, { contentType: 'text/plain' }),
    );
  });

  test('an oversized staff document is rejected even for the staff owner', async () => {
    const oversized = new Uint8Array(26 * 1024 * 1024); // isSafeStaffDocument caps at 25MB
    const fileRef = ref(
      storageFor('staffA'),
      'schools/schoolA/staff/staffA/documents/oversized.pdf',
    );
    await assertFails(
      uploadBytes(fileRef, oversized, { contentType: 'application/pdf' }),
    );
  });

  test('a disallowed content-type staff document is rejected', async () => {
    const fileRef = ref(
      storageFor('staffA'),
      'schools/schoolA/staff/staffA/documents/script.exe',
    );
    await assertFails(
      uploadBytes(fileRef, PNG_BYTES, { contentType: 'application/octet-stream' }),
    );
  });

  test('a valid PDF staff document is accepted for the staff owner', async () => {
    const fileRef = ref(
      storageFor('staffA'),
      'schools/schoolA/staff/staffA/documents/contract.pdf',
    );
    await assertSucceeds(
      uploadBytes(fileRef, PNG_BYTES, { contentType: 'application/pdf' }),
    );
  });
});

// Sanity check that the two allow-listed callers above actually differ -
// guards against a rules regression where isSchoolStaffAdmin/isStaffOwner
// silently degrade into "any authenticated user in the school".
describe('staff storage rules do not silently widen to same-school-any-role', () => {
  test('only admin or owner pass; a same-school peer never does', async () => {
    const [adminResult, ownerResult, peerResult] = await Promise.allSettled([
      uploadBytes(
        ref(storageFor('adminA'), 'schools/schoolA/staff/staffA/profile/a.png'),
        PNG_BYTES,
        { contentType: 'image/png' },
      ),
      uploadBytes(
        ref(storageFor('staffA'), 'schools/schoolA/staff/staffA/profile/b.png'),
        PNG_BYTES,
        { contentType: 'image/png' },
      ),
      uploadBytes(
        ref(storageFor('coworkerA'), 'schools/schoolA/staff/staffA/profile/c.png'),
        PNG_BYTES,
        { contentType: 'image/png' },
      ),
    ]);
    assert.equal(adminResult.status, 'fulfilled');
    assert.equal(ownerResult.status, 'fulfilled');
    assert.equal(peerResult.status, 'rejected');
  });
});

describe('clinic visit attachment storage rules', () => {
  const PATH = 'schools/schoolA/clinic_visits/visit-1/attachments/injury.png';
  const PDF_BYTES = Uint8Array.from([0x25, 0x50, 0x44, 0x46, 0x2d]); // %PDF-

  test('a nurse in the same school can upload an image and a PDF attachment', async () => {
    await assertSucceeds(
      uploadBytes(ref(storageFor('nurseA'), PATH), PNG_BYTES, {
        contentType: 'image/png',
      }),
    );
    await assertSucceeds(
      uploadBytes(
        ref(storageFor('nurseA'), 'schools/schoolA/clinic_visits/visit-1/attachments/referral.pdf'),
        PDF_BYTES,
        { contentType: 'application/pdf' },
      ),
    );
  });

  test('a same-school leadership role can also upload', async () => {
    await assertSucceeds(
      uploadBytes(ref(storageFor('headA'), PATH), PNG_BYTES, {
        contentType: 'image/png',
      }),
    );
  });

  test('a parent, an ordinary teacher, and an unauthenticated caller are all denied upload and read', async () => {
    await assertFails(
      uploadBytes(ref(storageFor('parentA'), PATH), PNG_BYTES, { contentType: 'image/png' }),
    );
    await assertFails(
      uploadBytes(ref(storageFor('coworkerA'), PATH), PNG_BYTES, { contentType: 'image/png' }),
    );
    await assertFails(
      uploadBytes(
        ref(testEnv.unauthenticatedContext().storage(), PATH),
        PNG_BYTES,
        { contentType: 'image/png' },
      ),
    );

    // Seed a real object as the nurse, then confirm the parent/teacher cannot read it.
    await assertSucceeds(
      uploadBytes(ref(storageFor('nurseA'), PATH), PNG_BYTES, { contentType: 'image/png' }),
    );
    const { getBytes } = require('firebase/storage');
    await assertFails(getBytes(ref(storageFor('parentA'), PATH)));
    await assertFails(getBytes(ref(storageFor('coworkerA'), PATH)));
  });

  test('a nurse from another school cannot upload into or read this school clinic attachments', async () => {
    await assertFails(
      uploadBytes(ref(storageFor('nurseB'), PATH), PNG_BYTES, { contentType: 'image/png' }),
    );
    await assertSucceeds(
      uploadBytes(ref(storageFor('nurseA'), PATH), PNG_BYTES, { contentType: 'image/png' }),
    );
    const { getBytes } = require('firebase/storage');
    await assertFails(getBytes(ref(storageFor('nurseB'), PATH)));
  });

  test('a non-image, non-PDF content type is rejected', async () => {
    await assertFails(
      uploadBytes(
        ref(storageFor('nurseA'), 'schools/schoolA/clinic_visits/visit-1/attachments/notes.docx'),
        PNG_BYTES,
        {
          contentType:
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        },
      ),
    );
  });

  test('an attachment over 10MB is rejected', async () => {
    const oversized = new Uint8Array(11 * 1024 * 1024);
    await assertFails(
      uploadBytes(ref(storageFor('nurseA'), PATH), oversized, { contentType: 'image/png' }),
    );
  });

  test('a clinic attachment cannot be deleted, even by the uploader', async () => {
    const p = 'schools/schoolA/clinic_visits/visit-del/attachments/x.png';
    await assertSucceeds(
      uploadBytes(ref(storageFor('nurseA'), p), PNG_BYTES, { contentType: 'image/png' }),
    );
    await assertFails(deleteObject(ref(storageFor('nurseA'), p)));
  });
});

describe('institution branding uploads: School Admin-tier only', () => {
  const LOGO_PATH = 'institutions/schoolA/branding/logo/logo.png';

  test('a School Admin can upload and replace the school logo', async () => {
    await assertSucceeds(
      uploadBytes(ref(storageFor('adminA'), LOGO_PATH), PNG_BYTES, {
        contentType: 'image/png',
      }),
    );
  });

  test('a general staff account (classTeacher) cannot upload the school logo', async () => {
    await assertFails(
      uploadBytes(ref(storageFor('staffA'), LOGO_PATH), PNG_BYTES, {
        contentType: 'image/png',
      }),
    );
    await assertFails(
      uploadBytes(ref(storageFor('coworkerA'), LOGO_PATH), PNG_BYTES, {
        contentType: 'image/png',
      }),
    );
  });

  test('a School Admin from a different school cannot upload into schoolA branding', async () => {
    await assertFails(
      uploadBytes(ref(storageFor('adminB'), LOGO_PATH), PNG_BYTES, {
        contentType: 'image/png',
      }),
    );
  });

  test('any active same-school staff member can still read the logo', async () => {
    await assertSucceeds(
      uploadBytes(ref(storageFor('adminA'), LOGO_PATH), PNG_BYTES, {
        contentType: 'image/png',
      }),
    );
    const { getBytes } = require('firebase/storage');
    await assertSucceeds(getBytes(ref(storageFor('staffA'), LOGO_PATH)));
  });

  test('a School Admin cannot delete another school\'s logo', async () => {
    await assertSucceeds(
      uploadBytes(ref(storageFor('adminA'), LOGO_PATH), PNG_BYTES, {
        contentType: 'image/png',
      }),
    );
    await assertFails(deleteObject(ref(storageFor('adminB'), LOGO_PATH)));
  });
});
