// Firebase Emulator integration test for functions/financial_entitlements.js
// — the Financial Entitlements & NFC Service Access decision point.
//
// Run: `npm run test:financial-entitlements:emulator`
// (firebase emulators:exec --only firestore, JDK 21). Requires
// ENTITLEMENT_CARD_TOKEN_KEY set for the terminal-token path.
//
// The module is required directly with `onCall: h => h` so the real Admin
// SDK transaction logic (policy evaluation, override precedence, terminal
// auth, nonce anti-replay, tap audit) runs against the emulator exactly as
// the deployed function does.
const { beforeEach, describe, test } = require("node:test");
const assert = require("node:assert/strict");

const projectId = "demo-financial-entitlements-test";
process.env.GCLOUD_PROJECT = projectId;
process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || "localhost:8080";
process.env.FIREBASE_CONFIG = JSON.stringify({ projectId });
process.env.ENTITLEMENT_CARD_TOKEN_KEY =
  process.env.ENTITLEMENT_CARD_TOKEN_KEY ||
  "test-only-entitlement-card-token-key-0123456789";

const admin = require("firebase-admin");
admin.initializeApp();
class HttpsError extends Error {
  constructor(code, message) {
    super(message);
    this.code = code;
  }
}
const fns = require("../financial_entitlements")({
  admin,
  onCall: (h) => h,
  HttpsError,
});

const db = admin.firestore();
const SCHOOL = "schoolA";
const OTHER = "schoolB";
const BURSAR = "bursarUid";
const HEAD = "headUid";
const CATERER = "catererUid";
const FOREIGN = "foreignBursarUid";
const STUDENT = "studentA";
const CREDENTIAL = "credA";

const req = (uid, data) => ({ auth: uid ? { uid } : null, data });

async function clearFirestore() {
  const cols = await db.listCollections();
  await Promise.all(cols.map(del));
}
async function del(colRef) {
  const docs = await colRef.listDocuments();
  await Promise.all(
    docs.map(async (d) => {
      const subs = await d.listCollections();
      await Promise.all(subs.map(del));
      await d.delete();
    }),
  );
}

async function seed() {
  await db.doc(`users/${BURSAR}`).set({ role: "bursar", roles: ["bursar"], schoolId: SCHOOL, isActive: true, name: "Bea" });
  await db.doc(`users/${HEAD}`).set({ role: "headTeacher", roles: ["headTeacher"], schoolId: SCHOOL, isActive: true, name: "Hana" });
  await db.doc(`users/${CATERER}`).set({ role: "cateringManager", roles: ["cateringManager"], schoolId: SCHOOL, isActive: true, name: "Cate" });
  await db.doc(`users/${FOREIGN}`).set({ role: "bursar", roles: ["bursar"], schoolId: OTHER, isActive: true, name: "Fred" });
  await db.doc(`schools/${SCHOOL}/credentials/${CREDENTIAL}`).set({
    status: "active", identityType: "student", identityId: STUDENT,
  });
}

async function setPct(pct, balance = 0) {
  await db.doc(`schools/${SCHOOL}/student_financials/${STUDENT}`).set({
    paymentPercentage: pct, balance,
  });
}

beforeEach(async () => {
  await clearFirestore();
  await seed();
});

// ---------------------------------------------------------------------------

describe("policy config", () => {
  test("an unconfigured service is notApplicable regardless of payment", () => {
    assert.deepEqual(
      fns.policyStatus(undefined, { paymentPercentage: 0, balance: 999999 }),
      { status: "notApplicable", reasonCode: "POLICY_DISABLED", source: "feePolicy" },
    );
  });

  test("only finance may save a policy; safety services are rejected", async () => {
    await assert.rejects(
      () => fns.saveFinancialEntitlementPolicy(req(CATERER, { schoolId: SCHOOL, services: {} })),
      /Only finance/,
    );
    await assert.rejects(
      () =>
        fns.saveFinancialEntitlementPolicy(
          req(BURSAR, { schoolId: SCHOOL, services: { nationalExams: { enabled: true } } }),
        ),
      /Safety services cannot be fee-gated/,
    );
  });

  test("finance saves an active dining policy", async () => {
    const r = await fns.saveFinancialEntitlementPolicy(
      req(BURSAR, {
        schoolId: SCHOOL,
        services: { dining: { enabled: true, minimumPaymentPercentage: 75, maximumBalance: 0 } },
      }),
    );
    assert.equal(r.status, "active");
    const doc = await db.doc(`schools/${SCHOOL}/financial_entitlement_policy/current`).get();
    assert.equal(doc.data().services.dining.minimumPaymentPercentage, 75);
    const audit = await db.collection(`schools/${SCHOOL}/financial_entitlement_audit`).where("action", "==", "policy.updated").get();
    assert.equal(audit.size, 1);
  });

  test("leadership approval routes to a proposal, not an active policy", async () => {
    const r = await fns.saveFinancialEntitlementPolicy(
      req(BURSAR, {
        schoolId: SCHOOL,
        requireLeadershipApproval: true,
        services: { dining: { enabled: true, minimumPaymentPercentage: 50 } },
      }),
    );
    assert.equal(r.status, "pendingApproval");
    const cur = await db.doc(`schools/${SCHOOL}/financial_entitlement_policy/current`).get();
    assert.equal(cur.exists, false);
  });
});

describe("compute — payment bands", () => {
  async function enableDining(min = 75) {
    await fns.saveFinancialEntitlementPolicy(
      req(BURSAR, { schoolId: SCHOOL, services: { dining: { enabled: true, minimumPaymentPercentage: min, maximumBalance: 0 } } }),
    );
  }

  test("below the band → blocked; at/above with zero balance → allowed", async () => {
    await enableDining(75);
    await setPct(50);
    let r = await fns.compute({ schoolId: SCHOOL, studentId: STUDENT, service: "dining" });
    assert.equal(r.status, "blocked");
    assert.equal(r.source, "feePolicy");

    await setPct(75);
    r = await fns.compute({ schoolId: SCHOOL, studentId: STUDENT, service: "dining" });
    assert.equal(r.status, "allowed");
  });

  test("a positive balance blocks even at 100%", async () => {
    await enableDining(75);
    await setPct(100, 5001);
    const r = await fns.compute({ schoolId: SCHOOL, studentId: STUDENT, service: "dining" });
    assert.equal(r.status, "blocked");
  });

  test("safety services are always allowed by compute", async () => {
    await enableDining(100);
    await setPct(0, 999999);
    for (const svc of ["nationalExams", "emergencyHealthcare", "guardianRelease", "attendance"]) {
      const r = await fns.compute({ schoolId: SCHOOL, studentId: STUDENT, service: svc });
      assert.equal(r.status, "allowed", `${svc} must never be gated`);
      assert.equal(r.reasonCode, "SAFETY_SERVICE");
    }
  });
});

describe("overrides", () => {
  async function enableDining() {
    await fns.saveFinancialEntitlementPolicy(
      req(BURSAR, { schoolId: SCHOOL, services: { dining: { enabled: true, minimumPaymentPercentage: 100, maximumBalance: 0 } } }),
    );
    await setPct(0, 100000);
  }

  test("an allow override needs a future expiry", async () => {
    await enableDining();
    await assert.rejects(
      () => fns.setFinancialEntitlementOverride(req(BURSAR, { schoolId: SCHOOL, studentId: STUDENT, service: "dining", decision: "allow" })),
      /future expiry/,
    );
  });

  test("a time-bound allow override flips a blocked learner to overrideActive", async () => {
    await enableDining();
    const r = await fns.setFinancialEntitlementOverride(
      req(BURSAR, {
        schoolId: SCHOOL, studentId: STUDENT, service: "dining", decision: "allow",
        reasonCode: "HARDSHIP", note: "matron confirmed", expiresAt: Date.now() + 3600000,
      }),
    );
    assert.equal(r.status, "active");
    const c = await fns.compute({ schoolId: SCHOOL, studentId: STUDENT, service: "dining" });
    assert.equal(c.status, "overrideActive");
    assert.equal(c.source, "bursarTemporaryOverride");
  });

  test("a deny override suspends an otherwise-allowed learner", async () => {
    await fns.saveFinancialEntitlementPolicy(
      req(BURSAR, { schoolId: SCHOOL, services: { dining: { enabled: true, minimumPaymentPercentage: 0, maximumBalance: 999999 } } }),
    );
    await setPct(100);
    await fns.setFinancialEntitlementOverride(
      req(HEAD, { schoolId: SCHOOL, studentId: STUDENT, service: "dining", decision: "deny", reasonCode: "MANUAL_SUSPENSION" }),
    );
    const c = await fns.compute({ schoolId: SCHOOL, studentId: STUDENT, service: "dining" });
    assert.equal(c.status, "suspended");
  });

  test("catering staff cannot set an override; a safety service cannot be overridden", async () => {
    await enableDining();
    await assert.rejects(
      () => fns.setFinancialEntitlementOverride(req(CATERER, { schoolId: SCHOOL, studentId: STUDENT, service: "dining", decision: "deny" })),
      /Only authorised finance or leadership/,
    );
    await assert.rejects(
      () => fns.setFinancialEntitlementOverride(req(BURSAR, { schoolId: SCHOOL, studentId: STUDENT, service: "guardianRelease", decision: "deny" })),
      /non-safety service/,
    );
  });

  test("an expired override no longer applies", async () => {
    await enableDining();
    await db.collection(`schools/${SCHOOL}/financial_entitlement_overrides`).add({
      studentId: STUDENT, service: "dining", decision: "allow", status: "active",
      expiresAt: admin.firestore.Timestamp.fromMillis(Date.now() - 1000),
      createdAt: admin.firestore.Timestamp.now(),
    });
    const c = await fns.compute({ schoolId: SCHOOL, studentId: STUDENT, service: "dining" });
    assert.equal(c.status, "blocked");
  });
});

describe("terminal + card token + tap", () => {
  async function registerTerminal(service = "dining") {
    return fns.registerEntitlementTerminal(req(BURSAR, { schoolId: SCHOOL, service, label: `${service} till` }));
  }
  async function mintToken() {
    return fns.mintEntitlementCardToken(req(BURSAR, { schoolId: SCHOOL, credentialId: CREDENTIAL, ttlMs: 300000 }));
  }
  async function enableDining(min) {
    await fns.saveFinancialEntitlementPolicy(
      req(BURSAR, { schoolId: SCHOOL, services: { dining: { enabled: true, minimumPaymentPercentage: min, maximumBalance: 0 } } }),
    );
  }

  test("only finance registers a terminal; secret is returned once", async () => {
    await assert.rejects(
      () => fns.registerEntitlementTerminal(req(CATERER, { schoolId: SCHOOL, service: "dining" })),
      /Only finance/,
    );
    const t = await registerTerminal();
    assert.ok(t.terminalId && t.terminalSecret);
    const stored = await db.doc(`schools/${SCHOOL}/entitlement_terminals/${t.terminalId}`).get();
    assert.equal(stored.data().secretHash.length, 64); // sha256 hex
    assert.notEqual(stored.data().secretHash, t.terminalSecret); // hash, not raw
  });

  test("an allowed learner gets decision=allow and a tap is logged (no balance in response)", async () => {
    await enableDining(50);
    await setPct(80);
    const t = await registerTerminal();
    const card = await mintToken();
    const res = await fns.checkServiceEntitlement(
      req(null, {
        schoolId: SCHOOL, terminalId: t.terminalId, terminalSecret: t.terminalSecret,
        cardToken: card.cardToken, nonce: "nonce-1", timestamp: Date.now(),
      }),
    );
    assert.equal(res.decision, "allow");
    assert.equal(res.service, "dining");
    assert.equal("balance" in res, false);
    assert.equal("note" in res, false);
    const taps = await db.collection(`schools/${SCHOOL}/entitlement_taps`).get();
    assert.equal(taps.size, 1);
    assert.equal(taps.docs[0].data().decision, "allow");
  });

  test("a blocked learner gets decision=deny", async () => {
    await enableDining(90);
    await setPct(40);
    const t = await registerTerminal();
    const card = await mintToken();
    const res = await fns.checkServiceEntitlement(
      req(null, {
        schoolId: SCHOOL, terminalId: t.terminalId, terminalSecret: t.terminalSecret,
        cardToken: card.cardToken, nonce: "nonce-2", timestamp: Date.now(),
      }),
    );
    assert.equal(res.decision, "deny");
  });

  test("a suspended learner gets needsStaffReview", async () => {
    await enableDining(0);
    await setPct(100);
    await fns.setFinancialEntitlementOverride(
      req(BURSAR, { schoolId: SCHOOL, studentId: STUDENT, service: "dining", decision: "deny", reasonCode: "REVIEW" }),
    );
    const t = await registerTerminal();
    const card = await mintToken();
    const res = await fns.checkServiceEntitlement(
      req(null, {
        schoolId: SCHOOL, terminalId: t.terminalId, terminalSecret: t.terminalSecret,
        cardToken: card.cardToken, nonce: "nonce-3", timestamp: Date.now(),
      }),
    );
    assert.equal(res.decision, "needsStaffReview");
  });

  test("a replayed nonce is denied", async () => {
    await enableDining(0);
    await setPct(100);
    const t = await registerTerminal();
    const card = await mintToken();
    const body = {
      schoolId: SCHOOL, terminalId: t.terminalId, terminalSecret: t.terminalSecret,
      cardToken: card.cardToken, nonce: "dup-nonce", timestamp: Date.now(),
    };
    await fns.checkServiceEntitlement(req(null, body));
    await assert.rejects(() => fns.checkServiceEntitlement(req(null, body)), /Replay denied/);
  });

  test("a wrong terminal secret is rejected", async () => {
    const t = await registerTerminal();
    const card = await mintToken();
    await assert.rejects(
      () =>
        fns.checkServiceEntitlement(
          req(null, {
            schoolId: SCHOOL, terminalId: t.terminalId, terminalSecret: "wrong",
            cardToken: card.cardToken, nonce: "n", timestamp: Date.now(),
          }),
        ),
      /Terminal authentication failed/,
    );
  });

  test("a stale timestamp is rejected", async () => {
    const t = await registerTerminal();
    const card = await mintToken();
    await assert.rejects(
      () =>
        fns.checkServiceEntitlement(
          req(null, {
            schoolId: SCHOOL, terminalId: t.terminalId, terminalSecret: t.terminalSecret,
            cardToken: card.cardToken, nonce: "n2", timestamp: Date.now() - 200000,
          }),
        ),
      /Invalid terminal request/,
    );
  });

  test("a tampered card token is denied", async () => {
    const t = await registerTerminal();
    await assert.rejects(
      () =>
        fns.checkServiceEntitlement(
          req(null, {
            schoolId: SCHOOL, terminalId: t.terminalId, terminalSecret: t.terminalSecret,
            cardToken: "forged.signature", nonce: "n3", timestamp: Date.now(),
          }),
        ),
      /denied/i,
    );
  });
});

describe("tenant isolation", () => {
  test("a foreign-school bursar cannot save this school's policy or override", async () => {
    await assert.rejects(
      () => fns.saveFinancialEntitlementPolicy(req(FOREIGN, { schoolId: SCHOOL, services: {} })),
      /No active membership/,
    );
    await assert.rejects(
      () => fns.setFinancialEntitlementOverride(req(FOREIGN, { schoolId: SCHOOL, studentId: STUDENT, service: "dining", decision: "deny" })),
      /No active membership/,
    );
  });
});
