const { after, before, test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const { doc, setDoc, getDoc, runTransaction } = require('firebase/firestore');

const projectId = 'demo-verify-counter-rule';
const rules = fs.readFileSync(path.resolve(__dirname, '../../firestore.rules'), 'utf8');
let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: { rules },
  });
});

after(async () => {
  await testEnv.cleanup();
});

test('schoolAdmin can read+write the admission counter (regression: was silently denied)', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/admin1'), {
      role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: 'sch1', studentIds: [],
    });
  });
  const db = testEnv.authenticatedContext('admin1').firestore();
  const counterRef = doc(db, 'schools/sch1/counters/admission_year1');
  await assertSucceeds(runTransaction(db, async (tx) => {
    const snap = await tx.get(counterRef);
    if (!snap.exists()) { tx.set(counterRef, { count: 1 }); return; }
    tx.update(counterRef, { count: (snap.data().count || 0) + 1 });
  }));
});

test('a teacher without enrollment permission cannot write the admission counter', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/teacher1'), {
      role: 'classTeacher', roles: ['classTeacher'], schoolId: 'sch1', studentIds: [],
    });
  });
  const db = testEnv.authenticatedContext('teacher1').firestore();
  const counterRef = doc(db, 'schools/sch1/counters/admission_year1');
  await assertFails(setDoc(counterRef, { count: 99 }));
});

test('a school A staff member cannot write school B counter', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/adminA'), {
      role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: 'schA', studentIds: [],
    });
  });
  const db = testEnv.authenticatedContext('adminA').firestore();
  const counterRef = doc(db, 'schools/schB/counters/admission_year1');
  await assertFails(setDoc(counterRef, { count: 1 }));
});
