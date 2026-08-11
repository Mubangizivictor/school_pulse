const { escapeHtml, formatAmount, humanReference } = require('../email_helpers');
const { STATUS_URL } = require('../branding');

module.exports = {
  payment_proof_received: (data) => {
    const reference = humanReference('payment', data.paymentId);
    return {
      subject: 'Payment proof received — verification pending',
      preheader: `We received your payment for ${data.schoolName}.`,
      eyebrow: 'Payment submitted',
      title: 'Payment proof received',
      status: 'pending',
      bodyText: `We've received your payment submission for ${data.schoolName} and it is now pending verification.`,
      bodyHtml: `<p>We've received your payment submission for <strong>${escapeHtml(data.schoolName)}</strong> and it is now pending verification.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Payment reference', value: reference },
        { label: 'Amount', value: data.amountLabel || formatAmount(data.amount) },
        { label: 'Method', value: data.methodLabel },
        { label: 'Status', value: 'Pending verification' },
      ],
      secondaryText: "We'll email you once your payment has been reviewed.",
      cta: { label: 'View Payment Status', url: STATUS_URL },
    };
  },

  manual_payment_approved: (data) => {
    const reference = humanReference('receipt', data.paymentId);
    return {
      subject: 'Payment confirmed — School Pulse subscription',
      preheader: `Your payment for ${data.schoolName} has been confirmed.`,
      eyebrow: 'Payment confirmed',
      title: 'Payment confirmed',
      status: 'success',
      bodyText: `Your School Pulse subscription payment for ${data.schoolName} has been confirmed and your account is now active.`,
      bodyHtml: `<p>Your School Pulse subscription payment for <strong>${escapeHtml(data.schoolName)}</strong> has been confirmed and your account is now active.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Receipt reference', value: reference },
        { label: 'Amount', value: data.amountLabel || formatAmount(data.amount) },
        { label: 'Plan', value: data.planLabel },
        { label: 'Renews', value: data.expiryLabel },
      ],
      cta: { label: 'View Subscription', url: STATUS_URL },
    };
  },

  manual_payment_rejected: (data) => {
    const reference = humanReference('payment', data.paymentId);
    return {
      subject: 'Payment verification needs attention',
      preheader: `We couldn't verify your payment for ${data.schoolName}.`,
      eyebrow: 'Payment needs attention',
      title: 'Your payment needs attention',
      status: 'error',
      bodyText: `We couldn't verify the payment submitted for ${data.schoolName}.`,
      bodyHtml: `<p>We couldn't verify the payment submitted for <strong>${escapeHtml(data.schoolName)}</strong>.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Payment reference', value: reference },
        { label: 'Amount', value: data.amountLabel || formatAmount(data.amount) },
        { label: 'Reason', value: data.reason },
      ],
      secondaryText: 'Please resubmit your payment with the correct details.',
      cta: { label: 'Resubmit Payment', url: STATUS_URL },
    };
  },

  mobile_money_payment_success: (data) => {
    const reference = humanReference('receipt', data.paymentId);
    return {
      subject: 'Mobile money payment successful',
      preheader: `Your mobile money payment for ${data.schoolName} was successful.`,
      eyebrow: 'Payment successful',
      title: 'Mobile money payment successful',
      status: 'success',
      bodyText: `Your mobile money payment for ${data.schoolName} was successful and your subscription is now active.`,
      bodyHtml: `<p>Your mobile money payment for <strong>${escapeHtml(data.schoolName)}</strong> was successful and your subscription is now active.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Receipt reference', value: reference },
        { label: 'Amount', value: data.amountLabel || formatAmount(data.amount) },
        { label: 'Plan', value: data.planLabel },
      ],
      cta: { label: 'View Subscription', url: STATUS_URL },
    };
  },

  mobile_money_payment_failed: (data) => {
    const reference = humanReference('payment', data.paymentId);
    return {
      subject: 'Mobile money payment failed',
      preheader: `Your mobile money payment for ${data.schoolName} did not go through.`,
      eyebrow: 'Payment failed',
      title: 'Your payment did not go through',
      status: 'error',
      bodyText: `Your mobile money payment for ${data.schoolName} did not go through.`,
      bodyHtml: `<p>Your mobile money payment for <strong>${escapeHtml(data.schoolName)}</strong> did not go through.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Payment reference', value: reference },
        { label: 'Amount', value: data.amountLabel || formatAmount(data.amount) },
        { label: 'Reason', value: data.reason },
      ],
      secondaryText: 'Please try again or use another payment method.',
      cta: { label: 'Try Again', url: STATUS_URL },
    };
  },

  payment_reversed: (data) => {
    const reference = humanReference('payment', data.paymentId);
    return {
      subject: 'Payment reversed',
      preheader: `A payment for ${data.schoolName} has been reversed.`,
      eyebrow: 'Payment reversed',
      title: 'A payment has been reversed',
      status: 'warning',
      bodyText: `A payment previously confirmed for ${data.schoolName} has been reversed.`,
      bodyHtml: `<p>A payment previously confirmed for <strong>${escapeHtml(data.schoolName)}</strong> has been reversed.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Payment reference', value: reference },
        { label: 'Amount', value: data.amountLabel || formatAmount(data.amount) },
        { label: 'Reason', value: data.reason },
      ],
      secondaryText: 'Please contact support if you have questions about this reversal.',
      cta: { label: 'Contact Support', url: STATUS_URL },
    };
  },

  payment_receipt: (data) => {
    const reference = humanReference('receipt', data.paymentId);
    return {
      subject: 'Your School Pulse payment receipt',
      preheader: `Receipt for your payment to ${data.schoolName}.`,
      eyebrow: 'Receipt',
      title: 'Your payment receipt',
      status: 'success',
      bodyText: `Here is your receipt for the payment made to School Pulse for ${data.schoolName}.`,
      bodyHtml: `<p>Here is your receipt for the payment made to School Pulse for <strong>${escapeHtml(data.schoolName)}</strong>.</p>`,
      infoRows: [
        { label: 'School', value: data.schoolName },
        { label: 'Receipt reference', value: reference },
        { label: 'Amount', value: data.amountLabel || formatAmount(data.amount) },
        { label: 'Method', value: data.methodLabel },
        { label: 'Date', value: data.dateLabel },
      ],
      cta: { label: 'View Payment Status', url: STATUS_URL },
    };
  },
};
