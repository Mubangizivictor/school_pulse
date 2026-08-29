// Authoritative Suppliers + Petty Cash operations (audit area 3).
//
// Before this module every write to schools/{id}/finance_suppliers,
// supplier_invoices, petty_cash and petty_cash_ledger was server-only with
// no client path at all — the screens were read-only. These callables add
// the real workflows: supplier create/edit/archive, invoice
// record/approve/reject/return/pay, petty-cash disbursement, and float
// replenishment. Every write is validated, tenant/role checked, idempotent,
// recorded in finance_audit_events, and — for money-moving actions —
// applied in a Firestore transaction that also keeps the running
// balance/float authoritative.
//
// Factory MUST return `api` (see the note atop student_fee_billing.js).
module.exports = ({ admin, onCall, HttpsError }) => {
  const db = admin.firestore();
  const { FieldValue, Timestamp } = require("firebase-admin/firestore");

  const txt = (v, n = 240) => String(v == null ? "" : v).trim().slice(0, n);
  const slug = (v) =>
    txt(v, 80).toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
  const wholeUgx = (v, label) => {
    const n = typeof v === "number" ? v : Number(v);
    if (!Number.isFinite(n) || !Number.isInteger(n) || n <= 0) {
      throw new HttpsError(
        "invalid-argument",
        `${label} must be a positive whole number of UGX.`,
      );
    }
    return n;
  };
  const dateOrNull = (v) => {
    if (!v) return null;
    const d = new Date(v);
    return Number.isNaN(d.getTime())
      ? (() => {
          throw new HttpsError("invalid-argument", "Invalid date.");
        })()
      : Timestamp.fromDate(d);
  };

  const FINANCE_ROLES = new Set([
    "bursar",
    "schoolAdmin",
    "headTeacher",
    "director",
  ]);
  // Day-to-day operators: raise/record, disburse petty cash, mark paid.
  const OPERATOR_ROLES = new Set(["bursar", "schoolAdmin"]);

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
      primaryRole: roles.find((r) => FINANCE_ROLES.has(r)) || roles[0] || "",
    };
  }
  const requireRole = (caller, allowed, action) => {
    if (!caller.roles.some((r) => allowed.has(r))) {
      throw new HttpsError("permission-denied", `Not authorised to ${action}.`);
    }
  };

  const auditRef = (schoolId) =>
    db.collection(`schools/${schoolId}/finance_audit_events`).doc();
  const auditEntry = (module, action, caller, extra) => ({
    module,
    action,
    actorId: caller.uid,
    actorRole: caller.primaryRole,
    ...extra,
    at: FieldValue.serverTimestamp(),
  });

  const api = {};

  // ===================================================================
  //  Suppliers
  // ===================================================================

  // Create or edit a supplier profile. Idempotent on clientRequestId for
  // creates; an explicit supplierId edits in place. Archiving is a separate
  // callable so it can't happen by omission.
  api.saveSupplier = onCall(async (request) => {
    const d = request.data || {};
    const schoolId = txt(d.schoolId);
    const caller = await loadCaller(request, schoolId);
    requireRole(caller, OPERATOR_ROLES, "manage suppliers");

    const name = txt(d.name, 200);
    const category = txt(d.category, 120);
    const phone = d.phone ? txt(d.phone, 40) : null;
    const email = d.email ? txt(d.email, 200) : null;
    const notes = d.notes ? txt(d.notes, 1000) : null;
    if (!name) {
      throw new HttpsError("invalid-argument", "Supplier name is required.");
    }

    const col = db.collection(`schools/${schoolId}/finance_suppliers`);
    const clientRequestId = txt(d.clientRequestId, 180);
    const explicitId = txt(d.supplierId, 180);
    const docId =
      explicitId ||
      (clientRequestId ? `sup_${slug(clientRequestId) || clientRequestId}` : col.doc().id);
    const ref = col.doc(docId);

    return db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (snap.exists && snap.data().archived === true && !d.unarchive) {
        throw new HttpsError(
          "failed-precondition",
          "This supplier is archived. Restore it before editing.",
        );
      }
      const base = snap.exists ? snap.data() : {};
      tx.set(
        ref,
        {
          schoolId,
          name,
          category,
          phone,
          email,
          notes,
          archived: d.unarchive ? false : base.archived || false,
          // payableBalanceUgx is derived from outstanding invoices — never
          // set from the client here.
          payableBalanceUgx: Number.isFinite(base.payableBalanceUgx)
            ? base.payableBalanceUgx
            : 0,
          createdAt: base.createdAt || FieldValue.serverTimestamp(),
          createdBy: base.createdBy || caller.uid,
          updatedAt: FieldValue.serverTimestamp(),
          updatedBy: caller.uid,
        },
        { merge: true },
      );
      tx.set(
        auditRef(schoolId),
        auditEntry("supplier", snap.exists ? "supplier_updated" : "supplier_created", caller, {
          supplierId: docId,
        }),
      );
      return { supplierId: docId, created: !snap.exists };
    });
  });

  api.archiveSupplier = onCall(async (request) => {
    const d = request.data || {};
    const schoolId = txt(d.schoolId);
    const supplierId = txt(d.supplierId, 180);
    const archived = d.archived !== false; // default true
    const caller = await loadCaller(request, schoolId);
    requireRole(caller, OPERATOR_ROLES, "archive suppliers");
    if (!supplierId) {
      throw new HttpsError("invalid-argument", "supplierId is required.");
    }
    const ref = db.doc(`schools/${schoolId}/finance_suppliers/${supplierId}`);
    return db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (!snap.exists) {
        throw new HttpsError("not-found", "Supplier not found.");
      }
      if (archived && Number(snap.data().payableBalanceUgx) > 0) {
        throw new HttpsError(
          "failed-precondition",
          "Settle outstanding invoices before archiving this supplier.",
        );
      }
      if (snap.data().archived === archived) {
        return { supplierId, archived, idempotent: true };
      }
      tx.update(ref, {
        archived,
        updatedAt: FieldValue.serverTimestamp(),
        updatedBy: caller.uid,
      });
      tx.set(
        auditRef(schoolId),
        auditEntry("supplier", archived ? "supplier_archived" : "supplier_restored", caller, {
          supplierId,
        }),
      );
      return { supplierId, archived, idempotent: false };
    });
  });

  // ===================================================================
  //  Supplier invoices
  // ===================================================================

  // Record or amend an invoice. New invoices land as `pending_approval`.
  // Idempotent on clientRequestId; an explicit invoiceId amends while still
  // pending/returned. A duplicate (same supplier + invoiceNumber) that is
  // already live in the workflow is rejected.
  api.recordSupplierInvoice = onCall(async (request) => {
    const d = request.data || {};
    const schoolId = txt(d.schoolId);
    const caller = await loadCaller(request, schoolId);
    requireRole(caller, OPERATOR_ROLES, "record supplier invoices");

    const supplierId = txt(d.supplierId, 180);
    const invoiceNumber = txt(d.invoiceNumber, 120);
    const category = txt(d.category, 120);
    const amountUgx = wholeUgx(d.amountUgx, "Invoice amount");
    const issuedAt = dateOrNull(d.issuedAt);
    const dueAt = dateOrNull(d.dueAt);
    const attachmentPaths = Array.isArray(d.attachmentPaths)
      ? d.attachmentPaths.map((p) => txt(p, 500)).filter(Boolean).slice(0, 20)
      : [];
    const reference = d.reference ? txt(d.reference, 240) : null;
    if (!supplierId || !invoiceNumber) {
      throw new HttpsError(
        "invalid-argument",
        "A supplier and an invoice number are required.",
      );
    }

    const supplierRef = db.doc(`schools/${schoolId}/finance_suppliers/${supplierId}`);
    const col = db.collection(`schools/${schoolId}/supplier_invoices`);
    const clientRequestId = txt(d.clientRequestId, 180);
    const explicitId = txt(d.invoiceId, 180);
    const docId =
      explicitId ||
      (clientRequestId ? `inv_${slug(clientRequestId) || clientRequestId}` : col.doc().id);
    const ref = col.doc(docId);

    return db.runTransaction(async (tx) => {
      const supSnap = await tx.get(supplierRef);
      if (!supSnap.exists) {
        throw new HttpsError("not-found", "Supplier not found.");
      }
      if (supSnap.data().archived === true) {
        throw new HttpsError(
          "failed-precondition",
          "Cannot record an invoice against an archived supplier.",
        );
      }
      const snap = await tx.get(ref);
      if (snap.exists) {
        const cur = snap.data();
        if (!["pending_approval", "returned"].includes(cur.status)) {
          throw new HttpsError(
            "failed-precondition",
            "This invoice can no longer be edited.",
          );
        }
      } else {
        const dup = await tx.get(
          col
            .where("supplierId", "==", supplierId)
            .where("invoiceNumber", "==", invoiceNumber)
            .where("status", "in", [
              "pending_approval",
              "approved",
              "paid",
            ])
            .limit(1),
        );
        if (!dup.empty) {
          throw new HttpsError(
            "already-exists",
            "An invoice with this number for this supplier is already in the workflow.",
          );
        }
      }
      const base = snap.exists ? snap.data() : {};
      tx.set(
        ref,
        {
          schoolId,
          supplierId,
          supplierName: txt(supSnap.data().name, 200),
          invoiceNumber,
          reference,
          category,
          amountUgx,
          issuedAt: issuedAt || base.issuedAt || null,
          dueAt: dueAt || base.dueAt || null,
          attachmentPaths,
          status: "pending_approval",
          approvalHistory: base.approvalHistory || [],
          paidAt: null,
          paymentReference: null,
          clientRequestId: clientRequestId || base.clientRequestId || null,
          createdAt: base.createdAt || FieldValue.serverTimestamp(),
          createdBy: base.createdBy || caller.uid,
          updatedAt: FieldValue.serverTimestamp(),
          updatedBy: caller.uid,
        },
        { merge: true },
      );
      tx.set(
        auditRef(schoolId),
        auditEntry("supplier_invoice", snap.exists ? "invoice_amended" : "invoice_recorded", caller, {
          invoiceId: docId,
          supplierId,
          amountUgx,
        }),
      );
      return { invoiceId: docId, created: !snap.exists };
    });
  });

  // approve | reject | return. Non-recorder finance staff only (four-eyes:
  // whoever recorded it can't approve it). approve bumps the supplier's
  // payable balance.
  api.decideSupplierInvoice = onCall(async (request) => {
    const d = request.data || {};
    const schoolId = txt(d.schoolId);
    const invoiceId = txt(d.invoiceId, 180);
    const decision = txt(d.decision, 16).toLowerCase();
    const comment = txt(d.comment, 1000);
    const caller = await loadCaller(request, schoolId);
    requireRole(caller, FINANCE_ROLES, "decide supplier invoices");
    const NEXT = {
      approve: "approved",
      reject: "rejected",
      return: "returned",
    };
    if (!NEXT[decision]) {
      throw new HttpsError(
        "invalid-argument",
        "decision must be one of: approve, reject, return.",
      );
    }
    if ((decision === "reject" || decision === "return") && !comment) {
      throw new HttpsError(
        "invalid-argument",
        "A comment is required to reject or return an invoice.",
      );
    }

    const ref = db.doc(`schools/${schoolId}/supplier_invoices/${invoiceId}`);
    return db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      if (!snap.exists) {
        throw new HttpsError("not-found", "Invoice not found.");
      }
      const cur = snap.data();
      if (cur.createdBy === caller.uid) {
        throw new HttpsError(
          "permission-denied",
          "You cannot decide an invoice you recorded.",
        );
      }
      const target = NEXT[decision];
      const history = Array.isArray(cur.approvalHistory)
        ? cur.approvalHistory.slice()
        : [];
      const last = history[history.length - 1];
      if (cur.status === target) {
        if (last && last.actorId === caller.uid && last.decision === decision) {
          return { invoiceId, status: cur.status, idempotent: true };
        }
        if (target !== "returned") {
          return { invoiceId, status: cur.status, idempotent: true };
        }
      }
      if (["approved", "rejected", "paid"].includes(cur.status) && cur.status !== target) {
        throw new HttpsError(
          "failed-precondition",
          `Invoice is already ${cur.status}.`,
        );
      }
      history.push({
        id: auditRef(schoolId).id,
        actorId: caller.uid,
        actorName: caller.name,
        actorRole: caller.primaryRole,
        decision,
        comment: comment || null,
        at: Timestamp.now(),
      });
      tx.update(ref, {
        status: target,
        approvalHistory: history,
        decidedAt: FieldValue.serverTimestamp(),
        decidedBy: caller.uid,
        updatedAt: FieldValue.serverTimestamp(),
      });
      if (decision === "approve") {
        const supRef = db.doc(
          `schools/${schoolId}/finance_suppliers/${cur.supplierId}`,
        );
        tx.set(
          supRef,
          {
            payableBalanceUgx: FieldValue.increment(cur.amountUgx),
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      }
      tx.set(
        auditRef(schoolId),
        auditEntry("supplier_invoice", `invoice_${decision}`, caller, {
          invoiceId,
          supplierId: cur.supplierId,
          fromStatus: cur.status,
          toStatus: target,
        }),
      );
      return { invoiceId, status: target, idempotent: false };
    });
  });

  // Pay an approved invoice out of a cash/bank account. Writes a signed
  // bank_ledger entry, decrements the account balance and the supplier
  // payable, flips the invoice to `paid`, and audits — all atomically.
  api.paySupplierInvoice = onCall(async (request) => {
    const d = request.data || {};
    const schoolId = txt(d.schoolId);
    const invoiceId = txt(d.invoiceId, 180);
    const accountId = txt(d.accountId, 180);
    const paymentReference = txt(d.paymentReference, 240);
    const paymentMethod = txt(d.paymentMethod, 60) || "bank_transfer";
    const proofPath = d.proofPath ? txt(d.proofPath, 500) : null;
    const caller = await loadCaller(request, schoolId);
    requireRole(caller, OPERATOR_ROLES, "pay supplier invoices");
    if (!invoiceId || !accountId || !paymentReference) {
      throw new HttpsError(
        "invalid-argument",
        "Invoice, funding account and a payment reference are required.",
      );
    }

    const invRef = db.doc(`schools/${schoolId}/supplier_invoices/${invoiceId}`);
    const accRef = db.doc(`schools/${schoolId}/bank_accounts/${accountId}`);
    return db.runTransaction(async (tx) => {
      const [invSnap, accSnap] = await Promise.all([
        tx.get(invRef),
        tx.get(accRef),
      ]);
      if (!invSnap.exists) {
        throw new HttpsError("not-found", "Invoice not found.");
      }
      if (!accSnap.exists) {
        throw new HttpsError("not-found", "Funding account not found.");
      }
      const inv = invSnap.data();
      if (inv.status === "paid") {
        // Idempotent: same reference → treat as the same payment.
        if (inv.paymentReference === paymentReference) {
          return { invoiceId, status: "paid", idempotent: true };
        }
        throw new HttpsError("failed-precondition", "Invoice is already paid.");
      }
      if (inv.status !== "approved") {
        throw new HttpsError(
          "failed-precondition",
          "Only an approved invoice can be paid.",
        );
      }
      const acc = accSnap.data();
      const newBalance = Number(acc.balanceUgx || 0) - inv.amountUgx;

      const ledgerRef = db
        .collection(`schools/${schoolId}/bank_ledger`)
        .doc();
      tx.set(ledgerRef, {
        schoolId,
        accountId,
        date: FieldValue.serverTimestamp(),
        description: `Supplier payment — ${inv.supplierName} (${inv.invoiceNumber})`,
        type: "Payment",
        amountUgx: -inv.amountUgx,
        balanceUgx: newBalance,
        source: "supplier_invoice",
        sourceId: invoiceId,
        reference: paymentReference,
        reconciled: false,
        createdBy: caller.uid,
      });
      tx.update(accRef, {
        balanceUgx: newBalance,
        updatedAt: FieldValue.serverTimestamp(),
      });
      tx.update(invRef, {
        status: "paid",
        paidAt: FieldValue.serverTimestamp(),
        paidBy: caller.uid,
        paymentReference,
        paymentMethod,
        paymentProofPath: proofPath,
        fundingAccountId: accountId,
        bankLedgerEntryId: ledgerRef.id,
        updatedAt: FieldValue.serverTimestamp(),
      });
      tx.set(
        db.doc(`schools/${schoolId}/finance_suppliers/${inv.supplierId}`),
        {
          payableBalanceUgx: FieldValue.increment(-inv.amountUgx),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      tx.set(
        auditRef(schoolId),
        auditEntry("supplier_invoice", "invoice_paid", caller, {
          invoiceId,
          supplierId: inv.supplierId,
          accountId,
          amountUgx: inv.amountUgx,
          bankLedgerEntryId: ledgerRef.id,
        }),
      );
      return { invoiceId, status: "paid", bankLedgerEntryId: ledgerRef.id };
    });
  });

  // ===================================================================
  //  Petty cash
  // ===================================================================
  //
  // One float doc per location under schools/{id}/petty_cash/{floatId}
  // ("main" by default). Every movement is a schools/{id}/petty_cash_ledger
  // entry (signed amountUgx) written in the same transaction that moves the
  // float, with a running balanceUgx.

  const floatRef = (schoolId, floatId) =>
    db.doc(`schools/${schoolId}/petty_cash/${floatId || "main"}`);
  const pettyLedgerCol = (schoolId) =>
    db.collection(`schools/${schoolId}/petty_cash_ledger`);

  // Record a disbursement (money out). Requires payee, category, amount,
  // date, requester; an approver is required once the amount is over the
  // school's threshold (default 50,000) — passed as `approvedBy`.
  api.recordPettyCashDisbursement = onCall(async (request) => {
    const d = request.data || {};
    const schoolId = txt(d.schoolId);
    const floatId = txt(d.floatId, 60) || "main";
    const caller = await loadCaller(request, schoolId);
    requireRole(caller, OPERATOR_ROLES, "record petty-cash disbursements");

    const payee = txt(d.payee, 200);
    const category = txt(d.category, 120);
    const purpose = txt(d.purpose, 500);
    const amountUgx = wholeUgx(d.amountUgx, "Disbursement amount");
    const spentAt = dateOrNull(d.spentAt) || Timestamp.now();
    const requestedBy = txt(d.requestedBy, 200) || caller.name;
    const receiptPath = d.receiptPath ? txt(d.receiptPath, 500) : null;
    const approvedBy = d.approvedBy ? txt(d.approvedBy, 200) : null;
    if (!payee || !category || !purpose) {
      throw new HttpsError(
        "invalid-argument",
        "Payee, category and purpose are required.",
      );
    }
    const clientRequestId = txt(d.clientRequestId, 180);
    const entryId = clientRequestId
      ? `pcd_${slug(clientRequestId) || clientRequestId}`
      : pettyLedgerCol(schoolId).doc().id;
    const entryRef = pettyLedgerCol(schoolId).doc(entryId);

    return db.runTransaction(async (tx) => {
      const [fSnap, eSnap] = await Promise.all([
        tx.get(floatRef(schoolId, floatId)),
        tx.get(entryRef),
      ]);
      if (eSnap.exists) {
        return {
          entryId,
          balanceUgx: eSnap.data().balanceUgx,
          idempotent: true,
        };
      }
      if (!fSnap.exists) {
        throw new HttpsError(
          "failed-precondition",
          "No petty-cash float exists for this location. Replenish it first.",
        );
      }
      const f = fSnap.data();
      const current = Number(f.currentFloatUgx || 0);
      if (amountUgx > current) {
        throw new HttpsError(
          "failed-precondition",
          "This disbursement exceeds the available float.",
        );
      }
      const threshold = Number(f.approvalThresholdUgx || 50000);
      if (amountUgx > threshold && !approvedBy) {
        throw new HttpsError(
          "failed-precondition",
          `Disbursements over ${threshold} UGX need an approver.`,
        );
      }
      const newBalance = current - amountUgx;
      tx.set(entryRef, {
        schoolId,
        floatId,
        date: spentAt,
        description: `${payee} — ${purpose}`,
        payee,
        category,
        purpose,
        type: "Disbursement",
        amountUgx: -amountUgx,
        balanceUgx: newBalance,
        requestedBy,
        approvedBy,
        recordedBy: caller.uid,
        receiptPath,
        clientRequestId: clientRequestId || null,
        createdAt: FieldValue.serverTimestamp(),
      });
      tx.update(floatRef(schoolId, floatId), {
        currentFloatUgx: newBalance,
        totalOutUgx: FieldValue.increment(amountUgx),
        updatedAt: FieldValue.serverTimestamp(),
      });
      tx.set(
        auditRef(schoolId),
        auditEntry("petty_cash", "petty_cash_disbursed", caller, {
          floatId,
          entryId,
          amountUgx,
        }),
      );
      return { entryId, balanceUgx: newBalance, idempotent: false };
    });
  });

  // Replenish the float from a cash/bank account. Writes a signed
  // bank_ledger entry (money out of the account, into the tin), tops up the
  // float, and writes a petty_cash_ledger "Replenishment" entry — all
  // atomic. Creates the float doc on first replenishment.
  api.replenishPettyCash = onCall(async (request) => {
    const d = request.data || {};
    const schoolId = txt(d.schoolId);
    const floatId = txt(d.floatId, 60) || "main";
    const accountId = txt(d.accountId, 180);
    const amountUgx = wholeUgx(d.amountUgx, "Replenishment amount");
    const reference = txt(d.reference, 240);
    const location = txt(d.location, 120) || "Main Office";
    const caller = await loadCaller(request, schoolId);
    requireRole(caller, OPERATOR_ROLES, "replenish petty cash");
    if (!accountId || !reference) {
      throw new HttpsError(
        "invalid-argument",
        "A funding account and a reference are required.",
      );
    }
    const clientRequestId = txt(d.clientRequestId, 180);
    const entryId = clientRequestId
      ? `pcr_${slug(clientRequestId) || clientRequestId}`
      : pettyLedgerCol(schoolId).doc().id;
    const entryRef = pettyLedgerCol(schoolId).doc(entryId);
    const accRef = db.doc(`schools/${schoolId}/bank_accounts/${accountId}`);

    return db.runTransaction(async (tx) => {
      const [fSnap, aSnap, eSnap] = await Promise.all([
        tx.get(floatRef(schoolId, floatId)),
        tx.get(accRef),
        tx.get(entryRef),
      ]);
      if (eSnap.exists) {
        return {
          entryId,
          floatBalanceUgx: eSnap.data().balanceUgx,
          idempotent: true,
        };
      }
      if (!aSnap.exists) {
        throw new HttpsError("not-found", "Funding account not found.");
      }
      const acc = aSnap.data();
      const newAccBalance = Number(acc.balanceUgx || 0) - amountUgx;
      const currentFloat = fSnap.exists
        ? Number(fSnap.data().currentFloatUgx || 0)
        : 0;
      const newFloat = currentFloat + amountUgx;

      const bankLedgerRef = db
        .collection(`schools/${schoolId}/bank_ledger`)
        .doc();
      tx.set(bankLedgerRef, {
        schoolId,
        accountId,
        date: FieldValue.serverTimestamp(),
        description: `Petty cash replenishment — ${location}`,
        type: "Payment",
        amountUgx: -amountUgx,
        balanceUgx: newAccBalance,
        source: "petty_cash_replenishment",
        sourceId: entryId,
        reference,
        reconciled: false,
        createdBy: caller.uid,
      });
      tx.update(accRef, {
        balanceUgx: newAccBalance,
        updatedAt: FieldValue.serverTimestamp(),
      });
      tx.set(
        floatRef(schoolId, floatId),
        {
          schoolId,
          floatId,
          location,
          currentFloatUgx: newFloat,
          totalInUgx: FieldValue.increment(amountUgx),
          totalOutUgx: fSnap.exists
            ? fSnap.data().totalOutUgx || 0
            : 0,
          approvalThresholdUgx: fSnap.exists
            ? fSnap.data().approvalThresholdUgx || 50000
            : 50000,
          createdAt:
            (fSnap.exists && fSnap.data().createdAt) ||
            FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      tx.set(entryRef, {
        schoolId,
        floatId,
        date: FieldValue.serverTimestamp(),
        description: `Replenishment from ${acc.name || "account"} (${reference})`,
        type: "Replenishment",
        amountUgx,
        balanceUgx: newFloat,
        accountId,
        reference,
        bankLedgerEntryId: bankLedgerRef.id,
        recordedBy: caller.uid,
        clientRequestId: clientRequestId || null,
        createdAt: FieldValue.serverTimestamp(),
      });
      tx.set(
        auditRef(schoolId),
        auditEntry("petty_cash", "petty_cash_replenished", caller, {
          floatId,
          entryId,
          accountId,
          amountUgx,
          bankLedgerEntryId: bankLedgerRef.id,
        }),
      );
      return { entryId, floatBalanceUgx: newFloat, idempotent: false };
    });
  });

  return api;
};
