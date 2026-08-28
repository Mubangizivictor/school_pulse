const crypto = require("node:crypto");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

/**
 * Bursar-managed per-learner payment codes and school payment-channel
 * configuration, for the Parent Payments redesign. School Pulse never
 * accepts money in-app - parents pay through external channels (MTN MoMo,
 * Airtel Money, bank/bank-agent, other) quoting a code the bursar controls.
 */
module.exports = ({ admin, onCall, HttpsError }) => {
  const api = {};
  const db = admin.firestore();
  const serverTime = () => admin.firestore.FieldValue.serverTimestamp();

  const asText = (value, max = 160) => String(value ?? "").trim().slice(0, max);

  async function loadCaller(request, schoolId) {
    if (!request.auth) throw new HttpsError("unauthenticated", "Sign-in required.");
    if (!schoolId) throw new HttpsError("invalid-argument", "schoolId is required.");
    const snap = await db.collection("users").doc(request.auth.uid).get();
    const user = snap.exists ? snap.data() || {} : {};
    const roles = Array.isArray(user.roles) ? user.roles : [user.role].filter(Boolean);
    if (user.schoolId !== schoolId) {
      throw new HttpsError("permission-denied", "You are not allowed to manage this school's payments.");
    }
    return { uid: request.auth.uid, roles };
  }

  // Same finance-leadership set as callerForFinance in student_fee_billing.js
  // (schoolAdmin/director/headTeacher/bursar) - kept in sync by convention
  // rather than a shared import, per this codebase's existing pattern of
  // each domain module owning its own caller-role check.
  async function callerForFinance(request, schoolId) {
    const caller = await loadCaller(request, schoolId);
    if (!caller.roles.some((role) =>
      ["schoolAdmin", "director", "headTeacher", "bursar"].includes(role)
    )) {
      throw new HttpsError("permission-denied", "Only finance leadership can perform this action.");
    }
    return caller;
  }

  async function isLinkedParent(uid, studentId) {
    const snap = await db.collection("users").doc(uid).get();
    if (!snap.exists) return false;
    const user = snap.data() || {};
    if (user.role !== "parent") return false;
    return Array.isArray(user.studentIds) && user.studentIds.includes(studentId);
  }

  // Mirrors schoolPrefixFrom() in index.js and _schoolPrefixFromName() in
  // student_remote_data_source.dart - duplicated here per this codebase's
  // established convention (Cloud Functions can't call Dart, and each
  // functions/*.js domain module keeps its own copy rather than sharing one
  // through index.js's exports surface).
  function schoolPrefixFrom(schoolName) {
    if (!schoolName || !schoolName.trim()) return "SCH";
    return schoolName
      .trim()
      .split(/\s+/)
      .map((w) => w[0])
      .slice(0, 3)
      .join("")
      .toUpperCase();
  }

  // Same alphabet as _accessCodeAlphabet in student_remote_data_source.dart:
  // excludes visually-ambiguous characters (0/O, 1/I/L) since payment codes
  // are read aloud/typed on a phone keypad at a bank teller or USSD menu.
  const CODE_ALPHABET = "23456789ABCDEFGHJKMNPQRSTUVWXYZ";

  function randomCodeChars(length) {
    const bytes = crypto.randomBytes(length);
    let out = "";
    for (let i = 0; i < length; i += 1) {
      out += CODE_ALPHABET[bytes[i] % CODE_ALPHABET.length];
    }
    return out;
  }

  // Format {SCHOOL_PREFIX}-P{7 random chars}, e.g. "VHS-P1234567". The "P"
  // marker visually distinguishes a payment code from staff/admission codes
  // sharing the same prefix convention, at a glance, without needing to
  // parse the whole string.
  async function generateUniquePaymentCode(schoolId, schoolName) {
    const prefix = schoolPrefixFrom(schoolName);
    for (let attempt = 0; attempt < 10; attempt += 1) {
      const candidate = `${prefix}-P${randomCodeChars(7)}`;
      const existing = await db
        .collection(`schools/${schoolId}/student_accounts`)
        .where("paymentCode", "==", candidate)
        .limit(1)
        .get();
      if (existing.empty) return candidate;
    }
    throw new HttpsError("internal", "Could not generate a unique payment code. Try again.");
  }

  async function generatePaymentCodeCore({ schoolId, studentId, actorUid }) {
    if (!studentId) throw new HttpsError("invalid-argument", "studentId is required.");
    const accountRef = db.doc(`schools/${schoolId}/student_accounts/${studentId}`);
    const schoolSnap = await db.collection("schools").doc(schoolId).get();
    const schoolName = schoolSnap.exists ? schoolSnap.data().name : null;

    // Re-check inside no transaction is needed for the read-then-set below:
    // a payment code, once generated, is permanent (this function is only
    // ever called once per student in practice - by the onCreate trigger,
    // or manually as a one-off backfill) and a duplicate call is a safe
    // no-op read, not a race that corrupts money.
    const accountSnap = await accountRef.get();
    if (accountSnap.exists && accountSnap.data().paymentCode) {
      return { paymentCode: accountSnap.data().paymentCode, alreadyExisted: true };
    }

    const paymentCode = await generateUniquePaymentCode(schoolId, schoolName);
    await accountRef.set({
      schoolId, studentId,
      paymentCode,
      paymentCodeGeneratedAt: serverTime(),
      paymentCodeGeneratedBy: actorUid,
    }, { merge: true });
    await db.collection(`schools/${schoolId}/finance_audit_events`).add({
      schoolId, type: "payment_code_generated", actorUid, actorRole: null,
      targetId: studentId, occurredAt: serverTime(), detail: { paymentCode },
    });
    return { paymentCode, alreadyExisted: false };
  }
  api.generatePaymentCodeCore = generatePaymentCodeCore;

  api.generateStudentPaymentCode = onCall(async (request) => {
    const data = request.data || {};
    const schoolId = asText(data.schoolId);
    const caller = await callerForFinance(request, schoolId);
    const studentId = asText(data.studentId);
    const result = await generatePaymentCodeCore({ schoolId, studentId, actorUid: caller.uid });
    return result;
  });

  // Every new learner gets a payment code automatically, regardless of
  // which of the two student-creation entry points (directEnrolLearner in
  // index.js, createStudentWithCapacityCheck in student_capacity.js) was
  // used - rather than relying on every call site remembering to invoke
  // generateStudentPaymentCode. students/{studentId} is top-level (not
  // nested under schools/{schoolId}), matching every other reference to
  // this collection across the functions codebase.
  api.onStudentCreatedGeneratePaymentCode = onDocumentCreated(
    "students/{studentId}",
    async (event) => {
      const snap = event.data;
      if (!snap) return;
      const student = snap.data();
      const schoolId = student.schoolId;
      if (!schoolId) return;
      await generatePaymentCodeCore({
        schoolId, studentId: event.params.studentId, actorUid: "system:onStudentCreated",
      });
    }
  );

  api.updatePaymentChannelConfig = onCall(async (request) => {
    const data = request.data || {};
    const schoolId = asText(data.schoolId);
    const caller = await callerForFinance(request, schoolId);

    const asChannel = (value) => {
      const v = value || {};
      return {
        enabled: Boolean(v.enabled),
        ussdCode: asText(v.ussdCode, 40),
        steps: Array.isArray(v.steps) ? v.steps.map((s) => asText(s, 300)).slice(0, 20) : [],
        merchantLabel: asText(v.merchantLabel, 80),
      };
    };
    const asBankAccount = (value, index) => {
      const v = value || {};
      return {
        id: asText(v.id, 60) || `bank-${index}`,
        bankName: asText(v.bankName, 120),
        accountName: asText(v.accountName, 160),
        accountNumber: asText(v.accountNumber, 60),
        showAccountNumber: Boolean(v.showAccountNumber),
        branchOrAgentNotes: asText(v.branchOrAgentNotes, 500),
        enabled: Boolean(v.enabled),
      };
    };
    const asOtherChannel = (value, index) => {
      const v = value || {};
      return {
        id: asText(v.id, 60) || `other-${index}`,
        label: asText(v.label, 120),
        instructions: asText(v.instructions, 1000),
        enabled: Boolean(v.enabled),
      };
    };

    const config = {
      schoolId,
      schoolDisplayName: asText(data.schoolDisplayName, 160),
      mtnMomo: asChannel(data.mtnMomo),
      airtelMoney: asChannel(data.airtelMoney),
      bankAccounts: Array.isArray(data.bankAccounts)
        ? data.bankAccounts.map(asBankAccount).slice(0, 20)
        : [],
      otherChannels: Array.isArray(data.otherChannels)
        ? data.otherChannels.map(asOtherChannel).slice(0, 20)
        : [],
      updatedAt: serverTime(),
      updatedBy: caller.uid,
    };

    await db.doc(`schools/${schoolId}/payment_config/channels`).set(config, { merge: false });
    await db.collection(`schools/${schoolId}/finance_audit_events`).add({
      schoolId, type: "channel_config_updated", actorUid: caller.uid, actorRole: null,
      targetId: "channels", occurredAt: serverTime(), detail: {},
    });
    return { ok: true };
  });

  return api;
};
