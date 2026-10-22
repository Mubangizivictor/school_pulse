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

  // -------------------------------------------------------------------
  // Pending-payment reconciliation queue
  // -------------------------------------------------------------------

  const PENDING_CHANNELS = ["mtn_momo", "airtel_money", "bank", "other"];

  api.claimPendingPayment = onCall(async (request) => {
    const data = request.data || {};
    if (!request.auth) throw new HttpsError("unauthenticated", "Sign-in required.");
    const schoolId = asText(data.schoolId);
    const studentId = asText(data.studentId);
    if (!studentId) throw new HttpsError("invalid-argument", "studentId is required.");
    if (!(await isLinkedParent(request.auth.uid, studentId))) {
      throw new HttpsError("permission-denied", "You are not linked to this learner.");
    }
    const channel = asText(data.channel, 20);
    if (!PENDING_CHANNELS.includes(channel)) {
      throw new HttpsError("invalid-argument", `channel must be one of: ${PENDING_CHANNELS.join(", ")}.`);
    }
    const amountUgx = Number(data.amountUgx);
    if (!Number.isSafeInteger(amountUgx) || amountUgx <= 0) {
      throw new HttpsError("invalid-argument", "amountUgx must be a positive whole number.");
    }
    const evidenceRef = asText(data.evidenceRef, 300) || null;

    const accountSnap = await db.doc(`schools/${schoolId}/student_accounts/${studentId}`).get();
    const paymentCode = accountSnap.exists ? accountSnap.data().paymentCode || null : null;

    const ref = db.collection(`schools/${schoolId}/pending_payments`).doc();
    await ref.set({
      schoolId, studentId, paymentCode, channel,
      providerTransactionId: null, amountUgx,
      claimedByParentUid: request.auth.uid, evidenceRef,
      status: "pending", dedupeKey: null,
      resultingPaymentId: null, rejectionReason: null,
      createdAt: serverTime(), resolvedAt: null, resolvedBy: null,
    });
    return { pendingPaymentId: ref.id };
  });

  // English cardinal-words for UGX amounts. UGX has no minor unit (no
  // cents), which keeps this to whole numbers only - no npm dependency
  // exists in package.json for this, so a small self-contained
  // implementation is used rather than adding one.
  const ONES = ["", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
    "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen",
    "Eighteen", "Nineteen"];
  const TENS = ["", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"];

  function threeDigitsToWords(n) {
    const parts = [];
    if (n >= 100) {
      parts.push(`${ONES[Math.floor(n / 100)]} Hundred`);
      n %= 100;
    }
    if (n >= 20) {
      parts.push(TENS[Math.floor(n / 10)] + (n % 10 ? `-${ONES[n % 10]}` : ""));
    } else if (n > 0) {
      parts.push(ONES[n]);
    }
    return parts.join(" ");
  }

  function amountUgxToWords(amountUgx) {
    if (amountUgx === 0) return "Zero Shillings";
    const scales = ["", "Thousand", "Million", "Billion"];
    let n = Math.round(amountUgx);
    const groups = [];
    while (n > 0) {
      groups.unshift(n % 1000);
      n = Math.floor(n / 1000);
    }
    const words = groups
      .map((g, i) => {
        const scale = scales[groups.length - 1 - i];
        if (g === 0) return "";
        return `${threeDigitsToWords(g)}${scale ? ` ${scale}` : ""}`;
      })
      .filter(Boolean)
      .join(" ");
    return `${words} Shillings Only`;
  }

  async function buildReceiptExtras({ schoolId, receiptId, amountUgx }) {
    const secret = process.env.PAYMENT_RECEIPT_HMAC_SECRET || "school-pulse-payment-receipt";
    const signature = crypto.createHmac("sha256", secret)
      .update(`${schoolId}:${receiptId}`)
      .digest("hex")
      .slice(0, 24);
    const hostingDomain = process.env.HOSTING_DOMAIN || "schoolpulse.app";
    return {
      amountInWords: amountUgxToWords(amountUgx),
      qrVerificationUrl: `https://${hostingDomain}/verify-payment?r=${encodeURIComponent(receiptId)}&s=${signature}`,
    };
  }

  async function nextReceiptNumber(tx, schoolId) {
    const counterRef = db.doc(`schools/${schoolId}/counters/receiptNumber`);
    const counterSnap = await tx.get(counterRef);
    const next = (counterSnap.exists ? Number(counterSnap.data().value || 0) : 0) + 1;
    tx.set(counterRef, { value: next, updatedAt: serverTime() }, { merge: true });
    return `RCT-${String(next).padStart(6, "0")}`;
  }

  // Records the payment/bill-balance side of confirming a pending payment.
  // Duplicates the minimal necessary slice of student_fee_billing.js's
  // recordStudentPayment (that file exports no reusable core function for
  // this, unlike issueStudentBillCore/applyBillAdjustmentCore) rather than
  // modifying its export shape - both routes call the same nextReceiptNumber
  // pattern so receipt numbering stays a single, tamper-proof sequence.
  api.confirmPendingPayment = onCall(async (request) => {
    const data = request.data || {};
    const schoolId = asText(data.schoolId);
    const caller = await callerForFinance(request, schoolId);
    const pendingPaymentId = asText(data.pendingPaymentId);
    const billId = asText(data.billId);
    if (!pendingPaymentId || !billId) {
      throw new HttpsError("invalid-argument", "pendingPaymentId and billId are required.");
    }
    const allocations = Array.isArray(data.allocations)
      ? data.allocations.map((a, index) => {
          const chargeId = asText(a?.chargeId, 160) || null;
          const amt = Number(a?.amountUgx);
          if (!Number.isSafeInteger(amt) || amt < 0) {
            throw new HttpsError("invalid-argument", `Allocation ${index + 1} amount is invalid.`);
          }
          return { chargeId, amountUgx: amt };
        })
      : [];

    const pendingRef = db.doc(`schools/${schoolId}/pending_payments/${pendingPaymentId}`);

    const result = await db.runTransaction(async (tx) => {
      const pendingSnap = await tx.get(pendingRef);
      if (!pendingSnap.exists) throw new HttpsError("not-found", "Pending payment was not found.");
      const pending = pendingSnap.data();
      if (pending.status !== "pending") {
        throw new HttpsError("failed-precondition", "This pending payment has already been resolved.");
      }
      const studentId = pending.studentId;
      const billRef = db.doc(`schools/${schoolId}/student_accounts/${studentId}/bills/${billId}`);
      const billSnap = await tx.get(billRef);
      if (!billSnap.exists || billSnap.data().schoolId !== schoolId) {
        throw new HttpsError("not-found", "Bill was not found for this student.");
      }
      const bill = billSnap.data();
      const amountUgx = pending.amountUgx;
      const newPaidTotal = Number(bill.paidTotalUgx || 0) + amountUgx;
      const newBalance = Number(bill.issuedTotalUgx || 0) - Number(bill.adjustmentTotalUgx || 0) - newPaidTotal;
      if (newBalance < 0) {
        throw new HttpsError("failed-precondition", "This payment exceeds the remaining balance on the bill.");
      }

      const paymentRef = db.collection(`schools/${schoolId}/student_accounts/${studentId}/bills/${billId}/payments`).doc();
      const receiptNumber = await nextReceiptNumber(tx, schoolId);
      const extras = await buildReceiptExtras({ schoolId, receiptId: paymentRef.id, amountUgx });

      const methodByChannel = { mtn_momo: "mobile_money", airtel_money: "mobile_money", bank: "bank_transfer", other: "mobile_money" };
      tx.set(paymentRef, {
        schoolId, studentId, billId, paymentId: paymentRef.id, status: "recorded",
        method: methodByChannel[pending.channel] || "mobile_money", amountUgx, currency: "UGX",
        referenceNumber: pending.providerTransactionId || null, payerName: null,
        payerGuardianId: pending.claimedByParentUid || null,
        allocations, receiptNumber, recordedBy: caller.uid, recordedAt: serverTime(),
        createdAt: serverTime(), reversalOfPaymentId: null,
        amountInWords: extras.amountInWords, qrVerificationUrl: extras.qrVerificationUrl,
        sourcePendingPaymentId: pendingPaymentId,
      });
      tx.update(billRef, {
        paidTotalUgx: newPaidTotal, balanceUgx: newBalance,
        status: newBalance === 0 ? "paid" : bill.status, updatedAt: serverTime(),
      });
      tx.update(pendingRef, {
        status: "confirmed", resultingPaymentId: paymentRef.id,
        resolvedAt: serverTime(), resolvedBy: caller.uid,
      });
      tx.set(db.collection(`schools/${schoolId}/finance_audit_events`).doc(), {
        schoolId, type: "pending_confirmed", actorUid: caller.uid, actorRole: null,
        targetId: pendingPaymentId, occurredAt: serverTime(),
        detail: { paymentId: paymentRef.id, receiptNumber, amountUgx },
      });
      return { paymentId: paymentRef.id, receiptNumber, balanceUgx: newBalance };
    });
    return result;
  });

  api.rejectPendingPayment = onCall(async (request) => {
    const data = request.data || {};
    const schoolId = asText(data.schoolId);
    const caller = await callerForFinance(request, schoolId);
    const pendingPaymentId = asText(data.pendingPaymentId);
    if (!pendingPaymentId) throw new HttpsError("invalid-argument", "pendingPaymentId is required.");
    const reason = asText(data.reason, 500);
    if (!reason) throw new HttpsError("invalid-argument", "reason is required.");

    const pendingRef = db.doc(`schools/${schoolId}/pending_payments/${pendingPaymentId}`);
    await db.runTransaction(async (tx) => {
      const pendingSnap = await tx.get(pendingRef);
      if (!pendingSnap.exists) throw new HttpsError("not-found", "Pending payment was not found.");
      if (pendingSnap.data().status !== "pending") {
        throw new HttpsError("failed-precondition", "This pending payment has already been resolved.");
      }
      tx.update(pendingRef, {
        status: "rejected", rejectionReason: reason,
        resolvedAt: serverTime(), resolvedBy: caller.uid,
      });
      tx.set(db.collection(`schools/${schoolId}/finance_audit_events`).doc(), {
        schoolId, type: "pending_rejected", actorUid: caller.uid, actorRole: null,
        targetId: pendingPaymentId, occurredAt: serverTime(), detail: { reason },
      });
    });
    return { ok: true };
  });

  return api;
};
