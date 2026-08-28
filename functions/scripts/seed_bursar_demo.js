/**
 * Seeds a complete Bursar / Finance demo for the "School Pulse Academy" demo
 * tenant, directly via the Firebase Admin SDK - every Bursar screen ends up
 * with realistic data so the final UI can be reviewed end to end.
 *
 * Covers: a bursar staff account, ~15 students with mixed fee status,
 * student_financials (dashboard KPIs) + student_accounts/bills/adjustments/
 * payments (statement + receipts), the legacy `payments` collection (recent
 * activity + cash-flow), expenditures (Approvals: pending + history +
 * high-risk), budgets (Budget Details, incl. an overspend), bank_accounts +
 * bank_ledger + bank_reconciliations (Cash & Bank), petty_cash +
 * petty_cash_ledger + petty_cash_vouchers, finance_suppliers +
 * supplier_invoices, payment_vouchers, payroll_runs + payroll_compliance,
 * and finance_audit_events (Audit trail).
 *
 * SAFETY: uses Admin SDK credentials, bypasses security rules. Point it at
 * the LOCAL emulator only:
 *   FIRESTORE_EMULATOR_HOST=localhost:8080 \
 *   FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 \
 *   GCLOUD_PROJECT=school-pulse-3d95b \
 *   node functions/scripts/seed_bursar_demo.js
 *
 * Everything it writes is namespaced under the demo school, so it is easy to
 * delete later (or just wipe the emulator).
 */
const admin = require('firebase-admin');

const PROJECT_ID =
  process.env.GCLOUD_PROJECT ||
  process.env.GOOGLE_CLOUD_PROJECT ||
  'school-pulse-3d95b';

if (!process.env.FIRESTORE_EMULATOR_HOST) {
  console.error(
    '\nRefusing to run: FIRESTORE_EMULATOR_HOST is not set.\n' +
      'This script writes demo data and must only target the local emulator.\n' +
      'Run: FIRESTORE_EMULATOR_HOST=localhost:8080 ' +
      'FIREBASE_AUTH_EMULATOR_HOST=localhost:9099 ' +
      'GCLOUD_PROJECT=school-pulse-3d95b node functions/scripts/seed_bursar_demo.js\n',
  );
  process.exit(1);
}

admin.initializeApp({ projectId: PROJECT_ID });
const db = admin.firestore();
const auth = admin.auth();

const SCHOOL_ID = 'school-pulse-academy';
const SCHOOL_NAME = 'School Pulse Academy';
const ACADEMIC_YEAR_ID = '2026';
const TERM_ID = '2026-t2';
const TERM_NAME = 'Term 2';
const BURSAR_EMAIL = 'bursar@schoolpulse.demo';
const BURSAR_PASSWORD = 'Test@123';
const DEMO_MARKER = { demoSeed: 'seed_bursar_demo' };

const TS = (d) => admin.firestore.Timestamp.fromDate(d);
const now = new Date();
const daysAgo = (n) => new Date(now.getTime() - n * 24 * 60 * 60 * 1000);
const daysAhead = (n) => new Date(now.getTime() + n * 24 * 60 * 60 * 1000);

async function getOrCreateUser(email, displayName) {
  try {
    return await auth.getUserByEmail(email);
  } catch (e) {
    if (e.code === 'auth/user-not-found') {
      return auth.createUser({ email, password: BURSAR_PASSWORD, displayName });
    }
    throw e;
  }
}

// ---------------------------------------------------------------------------

async function seedTenantRoot() {
  await db.collection('schools').doc(SCHOOL_ID).set(
    {
      id: SCHOOL_ID,
      name: SCHOOL_NAME,
      schoolName: SCHOOL_NAME,
      schoolType: 'primary',
      initials: 'SPA',
      isActive: true,
      status: 'active',
      subscriptionExpiry: Date.now() + 365 * 24 * 60 * 60 * 1000,
      subscriptionPlanId: 'standard',
      metadata: {
        hasEverActivated: true,
        subscriptionStatus: 'active',
        source: 'seed_bursar_demo',
      },
      classification: 'primary',
      tenantId: SCHOOL_ID,
      contactEmail: 'admin@schoolpulse.demo',
      createdAt: Date.now(),
    },
    { merge: true },
  );

  await db
    .collection('schools')
    .doc(SCHOOL_ID)
    .collection('config')
    .doc('institution_profile')
    .set(
      {
        displayName: SCHOOL_NAME,
        name: SCHOOL_NAME,
        initials: 'SPA',
        schoolType: 'primary',
        motto: 'Educate. Empower. Excel.',
        brandingVersion: 1,
      },
      { merge: true },
    );

  await db.collection('academic_years').doc(ACADEMIC_YEAR_ID).set({
    schoolId: SCHOOL_ID,
    name: ACADEMIC_YEAR_ID,
    startDate: TS(new Date(2026, 0, 1)),
    endDate: TS(new Date(2026, 11, 4)),
    isCurrent: true,
    isArchived: false,
  });
  await db.collection('academic_terms').doc(TERM_ID).set({
    schoolId: SCHOOL_ID,
    academicYearId: ACADEMIC_YEAR_ID,
    name: TERM_NAME,
    order: 2,
    startDate: TS(new Date(2026, 4, 1)),
    endDate: TS(new Date(2026, 7, 28)),
    isCurrent: true,
  });
  console.log('· tenant root + academic calendar');
}

async function seedBursarAccount() {
  const user = await getOrCreateUser(BURSAR_EMAIL, 'Rehema Bursar');
  const uid = user.uid;

  await auth.setCustomUserClaims(uid, {
    schoolId: SCHOOL_ID,
    role: 'bursar',
    roles: ['bursar'],
  });

  await db.collection('users').doc(uid).set(
    {
      id: uid,
      uid,
      name: 'Rehema Bursar',
      displayName: 'Rehema Bursar',
      email: BURSAR_EMAIL,
      role: 'bursar',
      roles: ['bursar'],
      schoolId: SCHOOL_ID,
      schoolName: SCHOOL_NAME,
      isActive: true,
      status: 'active',
      mustChangePassword: false,
      createdAt: Date.now(),
    },
    { merge: true },
  );

  await db
    .collection('schools')
    .doc(SCHOOL_ID)
    .collection('staff')
    .doc(uid)
    .set(
      {
        id: uid,
        uid,
        name: 'Rehema Bursar',
        email: BURSAR_EMAIL,
        role: 'bursar',
        roles: ['bursar'],
        schoolId: SCHOOL_ID,
        isActive: true,
        status: 'active',
      },
      { merge: true },
    );

  await db
    .collection('schools')
    .doc(SCHOOL_ID)
    .collection('staff_role_assignments')
    .doc(`${uid}_bursar`)
    .set({
      schoolId: SCHOOL_ID,
      staffId: uid,
      uid,
      role: 'bursar',
      roleTemplate: 'bursar',
      status: 'active',
      isActive: true,
      permissions: [
        'finance.dashboard.view',
        'finance.student.balance.read',
        'finance.payment.record',
        'finance.receipt.generate',
        'finance.expenditure.review',
        'finance.budget.view',
      ],
      assignedAt: Date.now(),
    });

  // Active institution membership so isSameSchool() passes for this user.
  await db
    .collection('schools')
    .doc(SCHOOL_ID)
    .collection('memberships')
    .doc(uid)
    .set({
      uid,
      schoolId: SCHOOL_ID,
      role: 'bursar',
      status: 'active',
      isActive: true,
      joinedAt: Date.now(),
    });

  console.log(`· bursar account  ${BURSAR_EMAIL} / ${BURSAR_PASSWORD}`);
  return uid;
}

const CLASSES = ['S.1', 'S.2', 'S.3', 'S.4', 'S.5', 'S.6'];
const FIRST = [
  'Aanyu', 'Abaho', 'Acen', 'Adong', 'Agaba', 'Ajok', 'Akello',
  'Amara', 'Bwire', 'Chandia', 'Draru', 'Ejang', 'Faida', 'Galiwango', 'Hasifa',
];
const LAST = [
  'Sarah', 'Brian', 'Mercy', 'Patrick', 'Ivan', 'Rebecca', 'Faith',
  'Joan', 'Peter', 'Grace', 'Samuel', 'Ann', 'Moses', 'Lydia', 'Ronald',
];

// Fee plan lines shared by every issued bill (whole UGX).
const FEE_LINES = [
  { chargeId: 'tuition', name: 'Tuition Fees', amountUgx: 1200000, required: true },
  { chargeId: 'boarding', name: 'Boarding Fees', amountUgx: 900000, required: true },
  { chargeId: 'development', name: 'Development Levy', amountUgx: 150000, required: true },
  { chargeId: 'activity', name: 'Activity Fees', amountUgx: 100000, required: true },
  { chargeId: 'exam', name: 'Exam Fees', amountUgx: 100000, required: true },
];
const BILL_TOTAL = FEE_LINES.reduce((s, l) => s + l.amountUgx, 0); // 2,450,000

async function seedStudentsAndBilling(bursarUid) {
  const batchStudents = [];
  for (let i = 0; i < 15; i++) {
    const id = `bursar-demo-s${i + 1}`;
    const name = `${FIRST[i]} ${LAST[i]}`;
    const className = CLASSES[i % CLASSES.length];
    const admissionNumber = `ADM${String(200 + i * 3).padStart(4, '0')}`;
    batchStudents.push({ id, name, className, admissionNumber, i });
  }

  let todayCollections = 0;
  const recentPayments = [];

  for (const s of batchStudents) {
    await db.collection('students').doc(s.id).set({
      id: s.id,
      schoolId: SCHOOL_ID,
      name: s.name,
      className: s.className,
      classId: s.className,
      studentId: s.admissionNumber,
      studentCode: s.admissionNumber,
      admissionNumber: s.admissionNumber,
      gender: s.i % 2 === 0 ? 'female' : 'male',
      academicYearId: ACADEMIC_YEAR_ID,
      status: 'active',
      level: 'secondary',
      isBoarder: true,
      residency: 'boarding',
      hasHealthAlert: false,
      ...DEMO_MARKER,
    });

    // Fee status pattern: every 3rd fully paid, every 3rd+1 partial,
    // the rest overdue - matches the reference Student Fees list.
    const mode = s.i % 3; // 0 paid, 1 partial, 2 overdue
    let scholarshipUgx = 0;
    if (s.i === 1) scholarshipUgx = 612500; // 25% scholarship (statement demo)

    const netBill = BILL_TOTAL - scholarshipUgx;
    let paidUgx;
    if (mode === 0) paidUgx = netBill;
    else if (mode === 1) paidUgx = Math.round(netBill * 0.55);
    else paidUgx = 0;
    const balanceUgx = netBill - paidUgx;

    // ---- legacy student_financials (dashboard KPIs + projection service)
    const paymentHistory = [];
    if (paidUgx > 0) {
      // Split into up to 3 instalments over the term.
      const chunks = mode === 0 ? 3 : 1;
      const per = Math.round(paidUgx / chunks);
      for (let c = 0; c < chunks; c++) {
        const amt = c === chunks - 1 ? paidUgx - per * (chunks - 1) : per;
        const date = daysAgo(60 - c * 22 - s.i);
        const receiptNumber = `RCPT-${s.admissionNumber}-${c + 1}`;
        paymentHistory.push({
          id: `${s.id}-p${c + 1}`,
          schoolId: SCHOOL_ID,
          studentId: s.id,
          academicYear: ACADEMIC_YEAR_ID,
          term: TERM_NAME,
          amount: amt,
          date: TS(date),
          method: c % 3 === 0 ? 'Cash' : c % 3 === 1 ? 'Mobile Money' : 'Bank',
          reference: `TXN${1000 + s.i * 7 + c}`,
          receiptNumber,
          feeBreakdown: { tuition: amt },
          recordedBy: bursarUid,
        });
      }
    }

    await db
      .collection('schools')
      .doc(SCHOOL_ID)
      .collection('student_financials')
      .doc(s.id)
      .set({
        studentId: s.id,
        schoolId: SCHOOL_ID,
        academicYear: ACADEMIC_YEAR_ID,
        term: TERM_NAME,
        feeStructureId: 'plan-2026-t2',
        scholarshipAmount: scholarshipUgx,
        discountAmount: 0,
        totalBilled: BILL_TOTAL,
        totalPaid: paidUgx,
        paymentHistory: paymentHistory.map((p) => ({
          ...p,
          date: p.date,
        })),
        applicableRestrictions: balanceUgx > 0 && mode === 2 ? ['exam_hold'] : [],
        ...DEMO_MARKER,
      });

    // ---- legacy `payments` collection (recent activity + cash flow)
    for (const p of paymentHistory) {
      await db
        .collection('schools')
        .doc(SCHOOL_ID)
        .collection('payments')
        .doc(p.id)
        .set(p);
      recentPayments.push(p);
    }

    // ---- Phase-2 student_accounts / bills / adjustments / payments
    const accRef = db
      .collection('schools')
      .doc(SCHOOL_ID)
      .collection('student_accounts')
      .doc(s.id);
    await accRef.set({
      studentId: s.id,
      schoolId: SCHOOL_ID,
      paymentCode: `PY-${s.admissionNumber}`,
      ...DEMO_MARKER,
    });

    const billId = `bill-${s.id}-t2`;
    const billRef = accRef.collection('bills').doc(billId);
    await billRef.set({
      id: billId,
      schoolId: SCHOOL_ID,
      studentId: s.id,
      status: balanceUgx <= 0 ? 'paid' : 'open',
      planId: 'plan-2026-t2',
      planVersionId: 'plan-2026-t2-v1',
      academicYearId: ACADEMIC_YEAR_ID,
      termId: TERM_ID,
      classId: s.className,
      issuedTotalUgx: BILL_TOTAL,
      paidTotalUgx: paidUgx,
      adjustmentTotalUgx: scholarshipUgx,
      balanceUgx,
      lines: FEE_LINES,
      issuedAt: TS(daysAgo(75)),
      ...DEMO_MARKER,
    });

    if (scholarshipUgx > 0) {
      await billRef.collection('adjustments').doc('adj-scholarship').set({
        billId,
        type: 'scholarship',
        amountUgx: scholarshipUgx,
        percentage: 25,
        reason: 'Academic merit scholarship (25%)',
        evidenceReference: 'SCH-2026-014',
        approverId: bursarUid,
        createdAt: TS(daysAgo(74)),
        ...DEMO_MARKER,
      });
    }

    for (let c = 0; c < paymentHistory.length; c++) {
      const src = paymentHistory[c];
      await billRef.collection('payments').doc(`sp-${c + 1}`).set({
        billId,
        status: 'recorded',
        method:
          src.method === 'Cash'
            ? 'cash'
            : src.method === 'Mobile Money'
              ? 'mobile_money'
              : 'bank_transfer',
        amountUgx: src.amount,
        referenceNumber: src.reference,
        payerName: `${s.name} (guardian)`,
        receiptNumber: src.receiptNumber,
        recordedBy: bursarUid,
        recordedAt: src.date,
        amountInWords: 'Amount as recorded',
        qrVerificationUrl: `https://demo.schoolpulse/verify?r=${src.receiptNumber}`,
        ...DEMO_MARKER,
      });
    }

    // "Today's collections" - give a couple of students a payment dated today.
    if (s.i === 4 || s.i === 9) {
      const amt = 250000;
      todayCollections += amt;
      const pid = `${s.id}-today`;
      const p = {
        id: pid,
        schoolId: SCHOOL_ID,
        studentId: s.id,
        academicYear: ACADEMIC_YEAR_ID,
        term: TERM_NAME,
        amount: amt,
        date: TS(now),
        method: 'Cash',
        reference: `TXN-TODAY-${s.i}`,
        receiptNumber: `RCPT-${s.admissionNumber}-T`,
        feeBreakdown: { activity: amt },
        recordedBy: bursarUid,
      };
      await db
        .collection('schools')
        .doc(SCHOOL_ID)
        .collection('payments')
        .doc(pid)
        .set(p);
      recentPayments.push(p);
    }
  }

  console.log(
    `· 15 students + student_financials + student_accounts/bills/payments  ` +
      `(today's collections ~${todayCollections.toLocaleString()})`,
  );
  return recentPayments;
}

async function seedExpenditures(bursarUid) {
  const rows = [
    {
      id: 'exp-1', desc: 'Supplier payment — Office World Ltd', amount: 4950000,
      cat: '2135 - Maintenance & Repairs', supplier: 'Office World Ltd',
      status: 'pending', requester: 'Peter Odongo', days: 2,
    },
    {
      id: 'exp-2', desc: 'Computer accessories', amount: 2750000,
      cat: '2140 - ICT', supplier: null,
      status: 'pending', requester: 'Jane Nakato', days: 2,
    },
    {
      id: 'exp-3', desc: 'Dormitory plumbing materials', amount: 350000,
      cat: '2135 - Maintenance & Repairs', supplier: 'Kampala Hardware Ltd',
      status: 'pending', requester: 'Moses Kato', days: 1,
    },
    {
      id: 'exp-4', desc: 'Generator servicing', amount: 5200000,
      cat: '2135 - Maintenance & Repairs', supplier: 'PowerGen Uganda',
      status: 'pending', requester: 'David Ssali', days: 3,
    },
    {
      id: 'exp-5', desc: 'Term 2 textbooks', amount: 1800000,
      cat: '2110 - Teaching & Learning', supplier: 'Fountain Publishers',
      status: 'approved', requester: 'Grace Atuhaire', days: 9,
      approver: 'Headteacher',
    },
    {
      id: 'exp-6', desc: 'Sports equipment', amount: 640000,
      cat: '2120 - Co-curricular', supplier: 'ProSport Ltd',
      status: 'approved', requester: 'Ronald Mugume', days: 12,
      approver: 'Bursar',
    },
    {
      id: 'exp-7', desc: 'Staff retreat catering', amount: 3200000,
      cat: '2150 - Administration', supplier: 'Serena Events',
      status: 'rejected', requester: 'Lydia Auma', days: 15,
      approver: 'Director', comment: 'Over budget for the quarter',
    },
    {
      id: 'exp-8', desc: 'Laboratory reagents', amount: 920000,
      cat: '2110 - Teaching & Learning', supplier: 'SciChem Uganda',
      status: 'released', requester: 'Samuel Okot', days: 20,
      approver: 'Bursar',
    },
  ];

  for (const r of rows) {
    const history = [];
    if (r.approver) {
      history.push({
        id: `${r.id}-step1`,
        approverId: 'demo-approver',
        approverName: r.approver,
        approverRole: r.approver.toLowerCase().replace(/\s+/g, ''),
        status:
          r.status === 'rejected'
            ? 'Rejected'
            : r.status === 'released'
              ? 'Approved'
              : 'Approved',
        comment: r.comment || null,
        updatedAt: TS(daysAgo(r.days - 1)),
      });
    }
    await db
      .collection('schools')
      .doc(SCHOOL_ID)
      .collection('expenditures')
      .doc(r.id)
      .set({
        schoolId: SCHOOL_ID,
        requesterId: 'demo-requester',
        requesterName: r.requester,
        description: r.desc,
        amount: r.amount,
        budgetCategoryId: r.cat,
        supplierId: r.supplier ? r.supplier.toLowerCase().replace(/\s+/g, '-') : null,
        supplierName: r.supplier,
        status: r.status,
        attachmentUrls:
          r.id === 'exp-3' ? ['gs://demo/invoice_1756.pdf'] : [],
        createdAt: TS(daysAgo(r.days)),
        approvalHistory: history,
        ...(r.approver
          ? {
              approverId: 'demo-approver',
              approverName: r.approver,
              approverRole: r.approver.toLowerCase(),
              approvalComment: r.comment || null,
              approvedAt: TS(daysAgo(r.days - 1)),
            }
          : {}),
        ...DEMO_MARKER,
      });
  }
  console.log('· 8 expenditures (4 pending incl. 2 high-risk, 4 history)');
}

async function seedBudgets() {
  const rows = [
    ['Salaries & Wages', 1600000000, 1312000000],
    ['Teaching & Learning', 1200000000, 804000000],
    ['Maintenance & Repairs', 250000000, 235000000],
    ['Utilities', 178000000, 126000000],
    ['Administration', 148000000, 98000000],
    ['Co-curricular Activities', 100000000, 49000000],
    ['Capital Expenditure', 50000000, 56000000], // overspend
  ];
  for (let i = 0; i < rows.length; i++) {
    const [name, allocated, spent] = rows[i];
    await db
      .collection('schools')
      .doc(SCHOOL_ID)
      .collection('budgets')
      .doc(`budget-t2-${i + 1}`)
      .set({
        schoolId: SCHOOL_ID,
        name,
        academicYear: ACADEMIC_YEAR_ID,
        term: `Term 2`,
        allocatedAmount: allocated,
        spentAmount: spent,
        description: '',
        ...DEMO_MARKER,
      });
  }
  console.log('· 7 budget lines (Capital Expenditure over 100%)');
}

async function seedCashAndBank() {
  const accounts = [
    {
      id: 'cash-on-hand', name: 'Cash on hand', kind: 'cash',
      balanceUgx: 3200000, reconciledPercent: 92, unmatchedCount: 2, sortOrder: 0,
    },
    {
      id: 'stanbic-2314', name: 'Stanbic Bank – 2314', kind: 'bank',
      balanceUgx: 98650000, reconciledPercent: 98, unmatchedCount: 1, sortOrder: 1,
    },
    {
      id: 'mtn-momo', name: 'MTN MoMo – School', kind: 'mobile_money',
      balanceUgx: 5400000, reconciledPercent: 100, unmatchedCount: 0, sortOrder: 2,
    },
  ];
  for (const a of accounts) {
    await db
      .collection('schools')
      .doc(SCHOOL_ID)
      .collection('bank_accounts')
      .doc(a.id)
      .set({ ...a, ...DEMO_MARKER });
  }

  const ledger = [
    ['Tuition – Abaho Brian', 'Receipt', 1250000, 0],
    ['Supplier – Office World', 'Payment', -4950000, 1],
    ['Boarding – Acen Mercy', 'Receipt', 250000, 2],
    ['Bank deposit', 'Deposit', 5000000, 2],
    ['Activity fee – Ajok Rebecca', 'Receipt', 100000, 3],
    ['Generator servicing', 'Payment', -5200000, 4],
    ['Development levy – Adong Patrick', 'Receipt', 150000, 5],
    ['MoMo settlement', 'Deposit', 2200000, 6],
  ];
  let bal = 98650000;
  for (let i = 0; i < ledger.length; i++) {
    const [description, type, amountUgx, days] = ledger[i];
    bal += amountUgx;
    await db
      .collection('schools')
      .doc(SCHOOL_ID)
      .collection('bank_ledger')
      .doc(`bl-${i + 1}`)
      .set({
        description,
        type,
        amountUgx,
        balanceUgx: bal,
        date: TS(daysAgo(days)),
        ...DEMO_MARKER,
      });
  }

  await db
    .collection('schools')
    .doc(SCHOOL_ID)
    .collection('bank_reconciliations')
    .doc('recon-t2-may')
    .set({
      periodLabel: 'May 2026',
      accountId: 'stanbic-2314',
      openingBalanceUgx: 91000000,
      closingBalanceUgx: 98650000,
      matchedCount: 47,
      unmatchedCount: 1,
      status: 'in_progress',
      startedAt: TS(daysAgo(6)),
      ...DEMO_MARKER,
    });
  console.log('· 3 bank/cash accounts + 8 ledger entries + 1 reconciliation');
}

async function seedPettyCash() {
  await db
    .collection('schools')
    .doc(SCHOOL_ID)
    .collection('petty_cash')
    .doc('main')
    .set({
      location: 'Main Office',
      currentFloatUgx: 500000,
      totalInUgx: 1250000,
      totalOutUgx: 1060000,
      ...DEMO_MARKER,
    });

  const entries = [
    ['Office Supplies', -150000, 350000, 12],
    ['Float Received', 500000, 500000, 13],
    ['Transport', -80000, 0, 14],
    ['Refreshments', -40000, 80000, 15],
    ['Stationery', -60000, 120000, 18],
  ];
  for (let i = 0; i < entries.length; i++) {
    const [description, amountUgx, balanceUgx, days] = entries[i];
    await db
      .collection('schools')
      .doc(SCHOOL_ID)
      .collection('petty_cash_ledger')
      .doc(`pc-${i + 1}`)
      .set({
        description,
        type: amountUgx >= 0 ? 'in' : 'out',
        amountUgx,
        balanceUgx,
        date: TS(daysAgo(days)),
        ...DEMO_MARKER,
      });
  }

  await db
    .collection('schools')
    .doc(SCHOOL_ID)
    .collection('petty_cash_vouchers')
    .doc('pcv-1')
    .set({
      number: 'PCV-0012',
      description: 'Transport for sports team',
      amountUgx: 80000,
      status: 'approved',
      requestedBy: 'Games Master',
      createdAt: TS(daysAgo(14)),
      ...DEMO_MARKER,
    });
  console.log('· petty cash float + 5 ledger entries + 1 voucher');
}

async function seedSuppliers() {
  const suppliers = [
    { id: 'office-world-ltd', name: 'Office World Ltd', category: 'Stationery & Office', payable: 4950000, phone: '+256772000111' },
    { id: 'kampala-hardware-ltd', name: 'Kampala Hardware Ltd', category: 'Hardware & Maintenance', payable: 350000, phone: '+256772000222' },
    { id: 'powergen-uganda', name: 'PowerGen Uganda', category: 'Equipment Servicing', payable: 5200000, phone: '+256772000333' },
    { id: 'fountain-publishers', name: 'Fountain Publishers', category: 'Books & Learning', payable: 0, phone: '+256772000444' },
    { id: 'serena-events', name: 'Serena Events', category: 'Catering & Events', payable: 0, phone: '+256772000555' },
  ];
  for (const s of suppliers) {
    await db
      .collection('schools')
      .doc(SCHOOL_ID)
      .collection('finance_suppliers')
      .doc(s.id)
      .set({
        name: s.name,
        category: s.category,
        payableBalanceUgx: s.payable,
        phone: s.phone,
        ...DEMO_MARKER,
      });
  }

  const invoices = [
    ['office-world-ltd', 'Office World Ltd', 'INV-OW-1756', 4950000, 'outstanding', 5],
    ['kampala-hardware-ltd', 'Kampala Hardware Ltd', 'INV-KH-0421', 350000, 'outstanding', 1],
    ['powergen-uganda', 'PowerGen Uganda', 'INV-PG-2210', 5200000, 'overdue', 20],
    ['fountain-publishers', 'Fountain Publishers', 'INV-FP-0099', 1800000, 'paid', 30],
    ['serena-events', 'Serena Events', 'INV-SE-0033', 3200000, 'paid', 45],
  ];
  for (let i = 0; i < invoices.length; i++) {
    const [supplierId, supplierName, reference, amountUgx, status, days] =
      invoices[i];
    await db
      .collection('schools')
      .doc(SCHOOL_ID)
      .collection('supplier_invoices')
      .doc(`si-${i + 1}`)
      .set({
        supplierId,
        supplierName,
        reference,
        amountUgx,
        status,
        issuedAt: TS(daysAgo(days)),
        ...DEMO_MARKER,
      });
  }
  console.log('· 5 suppliers + 5 invoices');
}

async function seedPaymentVouchers() {
  const rows = [
    {
      id: 'pv-1', number: 'PV-2026-041', supplier: 'Kampala Hardware Ltd',
      amount: 350000, vote: '2135 - Maintenance & Repairs',
      account: 'School Operating Account', attachment: 'invoice_1756.pdf',
      route: ['Bursar', 'Headteacher', 'Board'],
      narration: 'Purchase of plumbing materials for dormitory repairs.',
      status: 'submitted', days: 1,
      lines: [
        { description: 'PVC pipes & fittings', amountUgx: 210000 },
        { description: 'Taps and valves', amountUgx: 90000 },
        { description: 'Sealant & labour sundries', amountUgx: 50000 },
      ],
    },
    {
      id: 'pv-2', number: 'PV-2026-040', supplier: 'PowerGen Uganda',
      amount: 5200000, vote: '2135 - Maintenance & Repairs',
      account: 'School Operating Account', attachment: 'quote_pg2210.pdf',
      route: ['Bursar', 'Headteacher', 'Director'],
      narration: 'Annual generator service and parts replacement.',
      status: 'approved', days: 4,
      lines: [
        { description: 'Service labour', amountUgx: 1200000 },
        { description: 'Filters & oil', amountUgx: 900000 },
        { description: 'Alternator rebuild', amountUgx: 3100000 },
      ],
    },
    {
      id: 'pv-3', number: 'PV-2026-039', supplier: 'Fountain Publishers',
      amount: 1800000, vote: '2110 - Teaching & Learning',
      account: 'School Operating Account', attachment: null,
      route: ['Bursar', 'Headteacher'],
      narration: 'Term 2 textbook restock for S.1 and S.2.',
      status: 'paid', days: 20,
      lines: [
        { description: 'Mathematics textbooks (120)', amountUgx: 960000 },
        { description: 'English readers (100)', amountUgx: 840000 },
      ],
    },
  ];
  for (const r of rows) {
    await db
      .collection('schools')
      .doc(SCHOOL_ID)
      .collection('payment_vouchers')
      .doc(r.id)
      .set({
        number: r.number,
        supplierName: r.supplier,
        amountUgx: r.amount,
        budgetVote: r.vote,
        fundingAccount: r.account,
        attachmentName: r.attachment,
        approvalRoute: r.route,
        narration: r.narration,
        status: r.status,
        lines: r.lines,
        createdAt: TS(daysAgo(r.days)),
        ...DEMO_MARKER,
      });
  }
  console.log('· 3 payment vouchers');
}

async function seedPayroll() {
  await db
    .collection('schools')
    .doc(SCHOOL_ID)
    .collection('payroll_runs')
    .doc('run-2026-05')
    .set({
      periodLabel: 'May 2026',
      periodOrder: 202605,
      grossPayUgx: 132450000,
      payeUgx: 18153000,
      nssfEmployerUgx: 10596000,
      nssfEmployeeUgx: 6622500,
      netPayUgx: 103701000,
      staffCount: 68,
      submissionDeadline: TS(daysAhead(3)),
      payeCompliant: true,
      nssfCompliant: true,
      lines: [
        { label: 'Teaching staff', amountUgx: 96000000 },
        { label: 'Non-teaching staff', amountUgx: 28450000 },
        { label: 'Allowances', amountUgx: 8000000 },
      ],
      ...DEMO_MARKER,
    });

  await db
    .collection('schools')
    .doc(SCHOOL_ID)
    .collection('payroll_compliance')
    .doc('2026-05')
    .set({
      periodLabel: 'May 2026',
      paye: { status: 'compliant', filedAt: TS(daysAgo(2)), reference: 'URA-PAYE-556677' },
      nssf: { status: 'compliant', filedAt: TS(daysAgo(2)), reference: 'NSSF-889900' },
      ...DEMO_MARKER,
    });
  console.log('· payroll run + compliance (May 2026)');
}

async function seedAuditTrail(bursarUid) {
  const events = [
    { action: 'Payment recorded', summary: 'Receipt RCPT-ADM0212-1 · Abaho Brian', amount: 1250000, days: 0.1 },
    { action: 'Payment recorded', summary: 'Receipt RCPT-ADM0245-T · Aanyu Sarah', amount: 250000, days: 0.2 },
    { action: 'Expenditure approved', summary: 'Term 2 textbooks · Fountain Publishers', amount: 1800000, days: 9 },
    { action: 'Expenditure rejected', summary: 'Staff retreat catering · Serena Events (over budget)', amount: 3200000, days: 15 },
    { action: 'Bill adjustment applied', summary: 'Scholarship 25% · Abaho Brian', amount: 612500, days: 74 },
    { action: 'Bank deposit posted', summary: 'Stanbic Bank – 2314', amount: 5000000, days: 2 },
    { action: 'Reconciliation started', summary: 'May 2026 · Stanbic Bank – 2314', days: 6 },
    { action: 'Payment reversed', summary: 'Duplicate MoMo entry · Acen Mercy', amount: 100000, days: 11 },
  ];
  for (let i = 0; i < events.length; i++) {
    const e = events[i];
    await db
      .collection('schools')
      .doc(SCHOOL_ID)
      .collection('finance_audit_events')
      .doc(`audit-${i + 1}`)
      .set({
        action: e.action,
        summary: e.summary,
        actor: 'Rehema Bursar',
        actorId: bursarUid,
        amountUgx: e.amount ?? null,
        at: TS(daysAgo(e.days)),
        ...DEMO_MARKER,
      });
  }
  console.log('· 8 finance audit events');
}

// ---------------------------------------------------------------------------

async function main() {
  console.log(`Seeding Bursar demo → project ${PROJECT_ID}`);
  console.log(`  Firestore emulator: ${process.env.FIRESTORE_EMULATOR_HOST}`);
  console.log(
    `  Auth emulator:      ${process.env.FIREBASE_AUTH_EMULATOR_HOST || '(not set)'}`,
  );
  console.log('');

  await seedTenantRoot();
  const bursarUid = await seedBursarAccount();
  await seedStudentsAndBilling(bursarUid);
  await seedExpenditures(bursarUid);
  await seedBudgets();
  await seedCashAndBank();
  await seedPettyCash();
  await seedSuppliers();
  await seedPaymentVouchers();
  await seedPayroll();
  await seedAuditTrail(bursarUid);

  console.log('');
  console.log('Done. Log in to the app (pointed at the emulator) as:');
  console.log(`  ${BURSAR_EMAIL} / ${BURSAR_PASSWORD}`);
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });
