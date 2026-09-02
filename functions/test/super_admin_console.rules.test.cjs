// Firestore Rules emulator tests for the Super Admin console collections that
// the client reads/writes directly (everything else on the owner console goes
// through owner-only callables):
//   super_admin_support_tickets/{ticketId}         - client create/read/limited-update
//   super_admin_support_tickets/{id}/messages/{m}  - owner appends 'owner' messages
//   super_admin_audit_logs/{id}                    - append-only, superAdmin read/create
//   super_admin_notifications/{id}                  - server-written, per-owner read
//   support_mode_sessions/{ownerId}                - server-written, own-doc read
//
// Standalone from firestore.rules.test.cjs (kept surgical - that file is large
// and owned by another workstream). Same harness convention.
//
// Run:
//   firebase emulators:exec --only firestore \
//     --project demo-school-pulse-superadmin-rules-test \
//     "node --test test/super_admin_console.rules.test.cjs"
const { after, before, beforeEach, describe, test } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');

const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require('@firebase/rules-unit-testing');
const {
  doc, getDoc, setDoc, updateDoc, deleteDoc, collection, addDoc,
} = require('firebase/firestore');

const projectId = 'demo-school-pulse-superadmin-rules-test';
const rules = fs.readFileSync(path.resolve(__dirname, '../../firestore.rules'), 'utf8');

let testEnv;
const OWNER_A = 'ownerA';
const OWNER_B = 'ownerB';
const ADMIN_A = 'adminA';

function dbFor(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}
function anon() {
  return testEnv.unauthenticatedContext().firestore();
}

async function seed() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/ownerA'), { role: 'superAdmin', roles: ['superAdmin'], schoolId: null });
    await setDoc(doc(db, 'users/ownerB'), { role: 'superAdmin', roles: ['superAdmin'], schoolId: null });
    await setDoc(doc(db, 'users/adminA'), { role: 'schoolAdmin', roles: ['schoolAdmin'], schoolId: 'schoolA' });

    // Support tickets: one per owner, plus a message under ownerA's.
    await setDoc(doc(db, 'super_admin_support_tickets/tA'), {
      ticketNumber: 'TKT-2026-AAAAAA', ownerId: OWNER_A, subject: 'A issue',
      description: 'x', priority: 'normal', status: 'open', origin: 'report_problem',
    });
    await setDoc(doc(db, 'super_admin_support_tickets/tB'), {
      ticketNumber: 'TKT-2026-BBBBBB', ownerId: OWNER_B, subject: 'B issue',
      description: 'y', priority: 'high', status: 'open', origin: 'submit_request',
    });
    await setDoc(doc(db, 'super_admin_support_tickets/tA/messages/m1'), {
      sender: 'owner', senderId: OWNER_A, senderName: 'Owner', text: 'hi', createdAt: Date.now(),
    });

    // Audit logs
    await setDoc(doc(db, 'super_admin_audit_logs/logA'), {
      action: 'CREATE_SUBSCRIPTION_PLAN', ownerId: OWNER_A, timestamp: Date.now(),
    });

    // Owner notifications: one for ownerA, one legacy (no ownerId), one for ownerB
    await setDoc(doc(db, 'super_admin_notifications/nA'), { ownerId: OWNER_A, status: 'unread', title: 'A' });
    await setDoc(doc(db, 'super_admin_notifications/nLegacy'), { status: 'unread', title: 'legacy' });
    await setDoc(doc(db, 'super_admin_notifications/nB'), { ownerId: OWNER_B, status: 'unread', title: 'B' });

    // Support-mode session for ownerA
    await setDoc(doc(db, 'support_mode_sessions/ownerA'), { ownerId: OWNER_A, schoolId: 'schoolA', active: true });
  });
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: { rules, host: '127.0.0.1', port: 8080 },
  });
});
after(async () => { await testEnv.cleanup(); });
beforeEach(async () => {
  await testEnv.clearFirestore();
  await seed();
});

describe('super_admin_support_tickets', () => {
  test('an owner reads only their own ticket', async () => {
    await assertSucceeds(getDoc(doc(dbFor(OWNER_A), 'super_admin_support_tickets/tA')));
    await assertFails(getDoc(doc(dbFor(OWNER_A), 'super_admin_support_tickets/tB')));
  });

  test('a school admin (not superAdmin) cannot read any owner ticket', async () => {
    await assertFails(getDoc(doc(dbFor(ADMIN_A), 'super_admin_support_tickets/tA')));
  });

  test('an unauthenticated caller cannot read a ticket', async () => {
    await assertFails(getDoc(doc(anon(), 'super_admin_support_tickets/tA')));
  });

  test('an owner creates a ticket stamped with their own ownerId', async () => {
    await assertSucceeds(setDoc(doc(dbFor(OWNER_A), 'super_admin_support_tickets/tNew'), {
      ticketNumber: 'TKT-2026-NEWNEW', ownerId: OWNER_A, subject: 's', description: 'd',
      priority: 'normal', status: 'open', origin: 'report_problem',
    }));
  });

  test('an owner cannot create a ticket stamped for another owner', async () => {
    await assertFails(setDoc(doc(dbFor(OWNER_A), 'super_admin_support_tickets/tForged'), {
      ticketNumber: 'TKT-2026-FORGED', ownerId: OWNER_B, subject: 's', description: 'd',
      priority: 'normal', status: 'open', origin: 'report_problem',
    }));
  });

  test('a plain ticket update may move only updatedAt', async () => {
    await assertSucceeds(updateDoc(doc(dbFor(OWNER_A), 'super_admin_support_tickets/tA'), { updatedAt: Date.now() }));
    // status change from the client is refused - that path is Admin-SDK only
    await assertFails(updateDoc(doc(dbFor(OWNER_A), 'super_admin_support_tickets/tA'), { status: 'resolved' }));
    // cannot re-parent the ticket
    await assertFails(updateDoc(doc(dbFor(OWNER_A), 'super_admin_support_tickets/tA'), { ownerId: OWNER_B, updatedAt: Date.now() }));
  });

  test('a ticket cannot be deleted by the client', async () => {
    await assertFails(deleteDoc(doc(dbFor(OWNER_A), 'super_admin_support_tickets/tA')));
  });

  test('an owner appends an "owner" message to their own ticket', async () => {
    await assertSucceeds(setDoc(doc(dbFor(OWNER_A), 'super_admin_support_tickets/tA/messages/m2'), {
      sender: 'owner', senderId: OWNER_A, senderName: 'Owner', text: 'follow-up', createdAt: Date.now(),
    }));
  });

  test('an owner cannot post a message into another owner\'s ticket', async () => {
    await assertFails(setDoc(doc(dbFor(OWNER_A), 'super_admin_support_tickets/tB/messages/mX'), {
      sender: 'owner', senderId: OWNER_A, senderName: 'Owner', text: 'intrusion', createdAt: Date.now(),
    }));
  });

  test('an owner cannot forge a message as an agent or with a foreign senderId', async () => {
    await assertFails(setDoc(doc(dbFor(OWNER_A), 'super_admin_support_tickets/tA/messages/mAgent'), {
      sender: 'agent', senderId: OWNER_A, senderName: 'x', text: 'fake agent reply', createdAt: Date.now(),
    }));
    await assertFails(setDoc(doc(dbFor(OWNER_A), 'super_admin_support_tickets/tA/messages/mSpoof'), {
      sender: 'owner', senderId: OWNER_B, senderName: 'x', text: 'spoofed sender', createdAt: Date.now(),
    }));
  });

  test('messages cannot be updated or deleted by the client', async () => {
    await assertFails(updateDoc(doc(dbFor(OWNER_A), 'super_admin_support_tickets/tA/messages/m1'), { text: 'edited' }));
    await assertFails(deleteDoc(doc(dbFor(OWNER_A), 'super_admin_support_tickets/tA/messages/m1')));
  });
});

describe('super_admin_audit_logs (append-only)', () => {
  test('a superAdmin reads and creates audit rows', async () => {
    await assertSucceeds(getDoc(doc(dbFor(OWNER_A), 'super_admin_audit_logs/logA')));
    await assertSucceeds(setDoc(doc(dbFor(OWNER_A), 'super_admin_audit_logs/logNew'), {
      action: 'MANUAL', ownerId: OWNER_A, timestamp: Date.now(),
    }));
  });

  test('a school admin cannot read or write audit rows', async () => {
    await assertFails(getDoc(doc(dbFor(ADMIN_A), 'super_admin_audit_logs/logA')));
    await assertFails(setDoc(doc(dbFor(ADMIN_A), 'super_admin_audit_logs/logHack'), { action: 'x' }));
  });

  test('audit rows are immutable and undeletable, even for a superAdmin', async () => {
    await assertFails(updateDoc(doc(dbFor(OWNER_A), 'super_admin_audit_logs/logA'), { action: 'TAMPERED' }));
    await assertFails(deleteDoc(doc(dbFor(OWNER_A), 'super_admin_audit_logs/logA')));
  });
});

describe('super_admin_notifications (server-written, per-owner read)', () => {
  test('an owner reads their own + legacy (no ownerId) notifications', async () => {
    await assertSucceeds(getDoc(doc(dbFor(OWNER_A), 'super_admin_notifications/nA')));
    await assertSucceeds(getDoc(doc(dbFor(OWNER_A), 'super_admin_notifications/nLegacy')));
  });

  test('an owner cannot read a notification stamped for a different owner', async () => {
    await assertFails(getDoc(doc(dbFor(OWNER_A), 'super_admin_notifications/nB')));
  });

  test('no client may create/update/delete a notification', async () => {
    await assertFails(setDoc(doc(dbFor(OWNER_A), 'super_admin_notifications/nHack'), { ownerId: OWNER_A, title: 'x' }));
    await assertFails(updateDoc(doc(dbFor(OWNER_A), 'super_admin_notifications/nA'), { status: 'read' }));
    await assertFails(deleteDoc(doc(dbFor(OWNER_A), 'super_admin_notifications/nA')));
  });

  test('a school admin cannot read the owner notification feed', async () => {
    await assertFails(getDoc(doc(dbFor(ADMIN_A), 'super_admin_notifications/nA')));
  });
});

describe('super_admin_notification_tokens (owner-only FCM device tokens)', () => {
  test('an owner can write + read their own device token', async () => {
    await assertSucceeds(setDoc(
      doc(dbFor(OWNER_A), 'super_admin_notification_tokens/ownerA/devices/tok1'),
      { token: 'tok1', ownerId: OWNER_A, platform: 'ios', dataOnly: true },
    ));
    await assertSucceeds(getDoc(
      doc(dbFor(OWNER_A), 'super_admin_notification_tokens/ownerA/devices/tok1'),
    ));
    await assertSucceeds(deleteDoc(
      doc(dbFor(OWNER_A), 'super_admin_notification_tokens/ownerA/devices/tok1'),
    ));
  });

  test('an owner cannot touch another owner\'s device tokens', async () => {
    await assertFails(setDoc(
      doc(dbFor(OWNER_A), 'super_admin_notification_tokens/ownerB/devices/x'),
      { token: 'x', ownerId: OWNER_B },
    ));
    await assertFails(getDoc(
      doc(dbFor(OWNER_A), 'super_admin_notification_tokens/ownerB/devices/x'),
    ));
  });

  test('a school admin is denied owner device tokens entirely', async () => {
    await assertFails(setDoc(
      doc(dbFor(ADMIN_A), 'super_admin_notification_tokens/adminA/devices/x'),
      { token: 'x' },
    ));
    await assertFails(getDoc(
      doc(dbFor(ADMIN_A), 'super_admin_notification_tokens/ownerA/devices/tok1'),
    ));
  });

  test('an anonymous client is denied owner device tokens', async () => {
    await assertFails(getDoc(
      doc(anon(), 'super_admin_notification_tokens/ownerA/devices/tok1'),
    ));
  });
});

describe('support_mode_sessions (server-written, own-doc read)', () => {
  test('an owner reads their own support-mode session', async () => {
    await assertSucceeds(getDoc(doc(dbFor(OWNER_A), 'support_mode_sessions/ownerA')));
  });
  test('an owner cannot read another owner\'s support-mode session, and no client writes', async () => {
    await assertFails(getDoc(doc(dbFor(OWNER_B), 'support_mode_sessions/ownerA')));
    await assertFails(setDoc(doc(dbFor(OWNER_A), 'support_mode_sessions/ownerA'), { active: false }));
  });
});
