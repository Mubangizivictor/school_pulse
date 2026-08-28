// Authoritative Cash & Bank reconciliation (audit area 4).
//
// bank_ledger entries are server-write-only. These callables let a bursar
// reconcile them: mark an entry matched (against a bank-statement line
// reference, or paired with another ledger entry of the opposite sign and
// equal magnitude), unmatch a wrongly-matched entry, and post a manual
// adjustment / journal entry with a mandatory narration + reference.
//
// Reconciliation never rewrites history: an entry's amount is immutable, a
// match only sets reconciliation metadata, and every action is recorded in
// finance_audit_events in the same transaction. Duplicate reconciliation
// (matching an already-matched entry, or reusing a statement reference) is
// rejected.
//
// Factory MUST return `api`.
module.exports = ({ admin, onCall, HttpsError }) => {
  const db = admin.firestore();
  const FieldValue = admin.firestore.FieldValue;
  const txt = (v, n = 240) => String(v == null ? "" : v).trim().slice(0, n);
  const wholeUgx = (v, label) => {
    const n = typeof v === "number" ? v : Number(v);
    if (!Number.isFinite(n) || !Number.isInteger(n) || n === 0) {
      throw new HttpsError(
        "invalid-argument",
        `${label} must be a non-zero whole number of UGX.`,
      );
    }
    return n;
  };
  const RECON_ROLES = new Set(["bursar", "schoolAdmin"]);
  const READ_ROLES = new Set([
    "bursar",
    "schoolAdmin",
    "headTeacher",
    "director",
  ]);

  async function loadCaller(request, schoolId) {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Sign-in required.");
    }
    if (!schoolId) {
      throw new HttpsError("invalid-argument", "schoolId is required.");
    }
    const snap = await db.doc(`users/${request.auth.uid}`).get();
    const user = snap.exists ? snap.data() : {};
    const roles = Array.isArray(user.roles)
      ? user.roles
      : [user.role].filter(Boolean);
    if (user.schoolId !== schoolId) {
      throw new HttpsError(
        "permission-denied",
        "You cannot modify another school's finance records.",
      );
    }
    return {
      uid: request.auth.uid,
      roles,
      name: txt(user.displayName || user.name || "", 120),
      primaryRole: roles.find((r) => READ_ROLES.has(r)) || roles[0] || "",
    };
  }
  const requireRecon = (caller) => {
    if (!caller.roles.some((r) => RECON_ROLES.has(r))) {
      throw new HttpsError(
        "permission-denied",
        "Only a bursar or school admin may reconcile.",
      );
    }
  };
  const auditRef = (schoolId) =>
    db.collection(`schools/${schoolId}/finance_audit_events`).doc();
  const audit = (module, action, caller, extra) => ({
    module,
    action,
    actorId: caller.uid,
    actorRole: caller.primaryRole,
    ...extra,
    at: FieldValue.serverTimestamp(),
  });

  const ledgerRef = (schoolId, entryId) =>
    db.doc(`schools/${schoolId}/bank_ledger/${entryId}`);
  const accountRef = (schoolId, accountId) =>
    db.doc(`schools/${schoolId}/bank_accounts/${accountId}`);

  // Recompute an account's unmatched count from its ledger (kept in a
  // separate write, outside the match transaction, so it can't contend).
  async function refreshUnmatched(schoolId, accountId) {
    const unmatched = await db
      .collection(`schools/${schoolId}/bank_ledger`)
      .where("accountId", "==", accountId)
      .where("reconciled", "==", false)
      .count()
      .get();
    await accountRef(schoolId, accountId).set(
      {
        unmatchedCount: unmatched.data().count,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }

  const api = {};

  // Mark a ledger entry reconciled. Either:
  //  - against a bank-statement line: pass `statementReference` (+ optional
  //    `statementDate`), or
  //  - paired with another internal ledger entry: pass `counterEntryId` —
  //    the two must be opposite-signed and equal in magnitude, and both are
  //    marked matched to each other.
  api.matchBankLedgerEntry = onCall(async (request) => {
    const d = request.data || {};
    const schoolId = txt(d.schoolId);
    const entryId = txt(d.entryId, 180);
    const counterEntryId = txt(d.counterEntryId, 180);
    const statementReference = txt(d.statementReference, 200);
    const note = txt(d.note, 1000);
    const caller = await loadCaller(request, schoolId);
    requireRecon(caller);
    if (!entryId) {
      throw new HttpsError("invalid-argument", "entryId is required.");
    }
    if (!counterEntryId && !statementReference) {
      throw new HttpsError(
        "invalid-argument",
        "Provide a statement reference or a counter entry to match against.",
      );
    }

    const result = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ledgerRef(schoolId, entryId));
      if (!snap.exists) {
        throw new HttpsError("not-found", "Ledger entry not found.");
      }
      const entry = snap.data();
      if (entry.reconciled === true) {
        // Idempotent when it's the same match target.
        if (
          (counterEntryId && entry.matchedEntryId === counterEntryId) ||
          (statementReference &&
            entry.statementReference === statementReference)
        ) {
          return { entryId, accountId: entry.accountId, idempotent: true };
        }
        throw new HttpsError(
          "failed-precondition",
          "This entry is already reconciled. Unmatch it first.",
        );
      }

      let counter = null;
      if (counterEntryId) {
        if (counterEntryId === entryId) {
          throw new HttpsError(
            "invalid-argument",
            "An entry cannot be matched to itself.",
          );
        }
        const cSnap = await tx.get(ledgerRef(schoolId, counterEntryId));
        if (!cSnap.exists) {
          throw new HttpsError("not-found", "Counter entry not found.");
        }
        counter = cSnap.data();
        if (counter.accountId !== entry.accountId) {
          throw new HttpsError(
            "failed-precondition",
            "Both entries must belong to the same account.",
          );
        }
        if (counter.reconciled === true) {
          throw new HttpsError(
            "failed-precondition",
            "The counter entry is already reconciled.",
          );
        }
        if (Math.abs(counter.amountUgx) !== Math.abs(entry.amountUgx)) {
          throw new HttpsError(
            "failed-precondition",
            "Matched entries must be equal in amount.",
          );
        }
        if (Math.sign(counter.amountUgx) === Math.sign(entry.amountUgx)) {
          throw new HttpsError(
            "failed-precondition",
            "Matched entries must be opposite in sign.",
          );
        }
      } else {
        // Statement-reference match — guard against reusing a reference on
        // the same account.
        const dup = await tx.get(
          db
            .collection(`schools/${schoolId}/bank_ledger`)
            .where("accountId", "==", entry.accountId)
            .where("statementReference", "==", statementReference)
            .limit(1),
        );
        if (!dup.empty) {
          throw new HttpsError(
            "already-exists",
            "That bank-statement reference is already reconciled against another entry.",
          );
        }
      }

      const matchMeta = {
        reconciled: true,
        reconciledAt: FieldValue.serverTimestamp(),
        reconciledBy: caller.uid,
        reconcileNote: note || null,
      };
      tx.update(snap.ref, {
        ...matchMeta,
        matchedEntryId: counterEntryId || null,
        statementReference: statementReference || null,
        statementDate: d.statementDate
          ? admin.firestore.Timestamp.fromDate(new Date(d.statementDate))
          : null,
      });
      if (counter) {
        tx.update(ledgerRef(schoolId, counterEntryId), {
          ...matchMeta,
          matchedEntryId: entryId,
        });
      }
      tx.set(
        auditRef(schoolId),
        audit("reconciliation", "bank_entry_matched", caller, {
          accountId: entry.accountId,
          entryId,
          counterEntryId: counterEntryId || null,
          statementReference: statementReference || null,
        }),
      );
      return { entryId, accountId: entry.accountId, idempotent: false };
    });
    if (!result.idempotent) {
      await refreshUnmatched(schoolId, result.accountId).catch(() => {});
    }
    return result;
  });

  // Reverse a match. Clears reconciliation metadata on the entry (and its
  // pair, if any). Requires a reason — an audited correction, not a silent
  // undo.
  api.unmatchBankLedgerEntry = onCall(async (request) => {
    const d = request.data || {};
    const schoolId = txt(d.schoolId);
    const entryId = txt(d.entryId, 180);
    const reason = txt(d.reason, 1000);
    const caller = await loadCaller(request, schoolId);
    requireRecon(caller);
    if (!entryId) {
      throw new HttpsError("invalid-argument", "entryId is required.");
    }
    if (!reason) {
      throw new HttpsError(
        "invalid-argument",
        "A reason is required to unmatch a reconciled entry.",
      );
    }

    const result = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ledgerRef(schoolId, entryId));
      if (!snap.exists) {
        throw new HttpsError("not-found", "Ledger entry not found.");
      }
      const entry = snap.data();
      if (entry.reconciled !== true) {
        return { entryId, accountId: entry.accountId, idempotent: true };
      }
      const clear = {
        reconciled: false,
        matchedEntryId: null,
        statementReference: null,
        statementDate: null,
        reconciledAt: null,
        reconciledBy: null,
        unmatchedAt: FieldValue.serverTimestamp(),
        unmatchedBy: caller.uid,
        unmatchReason: reason,
      };
      tx.update(snap.ref, clear);
      if (entry.matchedEntryId) {
        const pairRef = ledgerRef(schoolId, entry.matchedEntryId);
        const pair = await tx.get(pairRef);
        if (pair.exists) tx.update(pairRef, clear);
      }
      tx.set(
        auditRef(schoolId),
        audit("reconciliation", "bank_entry_unmatched", caller, {
          accountId: entry.accountId,
          entryId,
          pairedEntryId: entry.matchedEntryId || null,
          reason,
        }),
      );
      return { entryId, accountId: entry.accountId, idempotent: false };
    });
    if (!result.idempotent) {
      await refreshUnmatched(schoolId, result.accountId).catch(() => {});
    }
    return result;
  });

  // Post a manual adjustment / journal entry to an account's ledger — bank
  // charges, interest, corrections. Signed amount, mandatory narration +
  // reference. Adjusts the account balance in the same transaction.
  // Idempotent on clientRequestId.
  api.recordBankLedgerAdjustment = onCall(async (request) => {
    const d = request.data || {};
    const schoolId = txt(d.schoolId);
    const accountId = txt(d.accountId, 180);
    const amountUgx = wholeUgx(d.amountUgx, "Adjustment amount");
    const description = txt(d.description, 300);
    const reference = txt(d.reference, 200);
    const caller = await loadCaller(request, schoolId);
    requireRecon(caller);
    if (!accountId || !description || !reference) {
      throw new HttpsError(
        "invalid-argument",
        "Account, description and reference are required.",
      );
    }
    const clientRequestId = txt(d.clientRequestId, 180);
    const col = db.collection(`schools/${schoolId}/bank_ledger`);
    const entryId = clientRequestId
      ? `adj_${clientRequestId.replace(/[^a-zA-Z0-9]+/g, "-")}`
      : col.doc().id;
    const entryRef = col.doc(entryId);
    const accRef = accountRef(schoolId, accountId);

    return db.runTransaction(async (tx) => {
      const [eSnap, aSnap] = await Promise.all([
        tx.get(entryRef),
        tx.get(accRef),
      ]);
      if (eSnap.exists) {
        return { entryId, balanceUgx: eSnap.data().balanceUgx, idempotent: true };
      }
      if (!aSnap.exists) {
        throw new HttpsError("not-found", "Account not found.");
      }
      const newBalance = Number(aSnap.data().balanceUgx || 0) + amountUgx;
      tx.set(entryRef, {
        schoolId,
        accountId,
        date: FieldValue.serverTimestamp(),
        description,
        type: amountUgx >= 0 ? "Adjustment (credit)" : "Adjustment (debit)",
        amountUgx,
        balanceUgx: newBalance,
        source: "manual_adjustment",
        reference,
        reconciled: true,
        reconciledAt: FieldValue.serverTimestamp(),
        reconciledBy: caller.uid,
        createdBy: caller.uid,
        clientRequestId: clientRequestId || null,
      });
      tx.update(accRef, {
        balanceUgx: newBalance,
        updatedAt: FieldValue.serverTimestamp(),
      });
      tx.set(
        auditRef(schoolId),
        audit("reconciliation", "bank_ledger_adjustment", caller, {
          accountId,
          entryId,
          amountUgx,
          reference,
        }),
      );
      return { entryId, balanceUgx: newBalance, idempotent: false };
    });
  });

  return api;
};
