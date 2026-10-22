/**
 * One-off admin write: sets platform_billing_config/manual with the real
 * mobile money / bank details schools should see on the public payment page
 * (web_marketing/payment.html -> getManualPaymentContext). This mirrors
 * exactly what the owner-only updateManualPaymentConfig callable
 * (public_functions/payments.js) would write, but runs via the Admin SDK
 * since that callable requires an authenticated owner session.
 *
 * Safe to re-run: uses set({ merge: true }), so it only touches these four
 * fields and never disturbs any other billing config already in the doc.
 *
 * Run: node scripts/set_manual_payment_config.js   (from functions/)
 */
const admin = require('firebase-admin');

admin.initializeApp({ projectId: 'school-pulse-3d95b' });
const db = admin.firestore();

async function main() {
  const configRef = db.collection('platform_billing_config').doc('manual');

  await configRef.set({
    mobileMoney: {
      enabled: true,
      network: 'MTN',
      number: '0793128137',
      accountName: 'Victor Mubangizi',
    },
    airtelMoney: {
      enabled: true,
      network: 'Airtel',
      number: '0740116746',
      accountName: 'Victor Mubangizi',
    },
    bank: {
      enabled: true,
      bankName: 'Centenary Bank',
      branch: '',
      accountName: 'Victor Mubangizi',
      accountNumber: '3205381235',
    },
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedBy: 'set_manual_payment_config_script',
  }, { merge: true });

  console.log('platform_billing_config/manual updated: MTN, Airtel, Centenary Bank details set.');
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Failed to set manual payment config:', err);
    process.exit(1);
  });
