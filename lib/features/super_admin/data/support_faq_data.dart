/// Maintained local FAQ data source for the SaaS owner "Help & Support"
/// module. There is no remote FAQ backend/CMS anywhere in this codebase, so
/// per the product spec's explicit allowance for "real FAQ data or a
/// maintained local source", this file is the source of truth. Update it
/// directly to add/edit questions - it is rendered as an expandable list by
/// `HelpSupportHomeScreen`.
class SupportFaqItem {
  final String question;
  final String answer;
  final String topic;

  const SupportFaqItem({
    required this.question,
    required this.answer,
    required this.topic,
  });
}

const List<SupportFaqItem> kSuperAdminSupportFaqs = [
  SupportFaqItem(
    topic: 'Billing',
    question: 'How are schools billed on the platform?',
    answer:
        'Each school is assigned a subscription plan from Plans & Pricing. '
        'Billing periods, manual payment submissions (MTN MoMo and bank '
        'transfer), and invoice status can all be reviewed from the '
        'Billing and Subscriptions screens in the owner console.',
  ),
  SupportFaqItem(
    topic: 'Billing',
    question: 'A school submitted a manual payment - where do I approve it?',
    answer:
        'Go to Payment Review in the owner console. Every manually '
        'submitted payment (MoMo or bank transfer) appears there with proof '
        'of payment for you to approve or reject before it reflects on the '
        "school's subscription.",
  ),
  SupportFaqItem(
    topic: 'Schools',
    question: 'How do I onboard a new school?',
    answer:
        'Use School Management to review incoming applications or create a '
        'school directly. Once approved, the school gets its own tenant '
        'space, and its admin account is provisioned automatically.',
  ),
  SupportFaqItem(
    topic: 'Schools',
    question:
        'Why can\'t I see a school\'s data from another school\'s account?',
    answer:
        'Every school is tenant-isolated at the data layer. Staff, parent, '
        'and student accounts are scoped to their own school and cannot '
        'read or write another school\'s records, even by guessing an ID.',
  ),
  SupportFaqItem(
    topic: 'Payments',
    question: 'What payment methods can schools use to pay their subscription?',
    answer:
        'Manual Payment Methods (in Settings) lets you configure the MTN '
        'MoMo number and bank account details schools are instructed to '
        'pay into. Schools submit proof of payment, which you review under '
        'Payment Review.',
  ),
  SupportFaqItem(
    topic: 'Payments',
    question: 'A payment was approved by mistake - can it be reversed?',
    answer:
        'Payment status changes are logged in Audit Logs. Reach out to '
        'Support with the ticket/transaction reference so a corrected entry '
        'can be made; approved payments are not silently editable from the '
        'client for audit-trail integrity.',
  ),
  SupportFaqItem(
    topic: 'Notifications',
    question: 'Why am I not receiving platform alert notifications?',
    answer:
        'Platform alerts (new applications, payment submissions, system '
        'notices) appear in the owner Notifications center in real time. '
        'Make sure push notifications are enabled for the app in your '
        "device's system settings if you're not seeing background alerts.",
  ),
  SupportFaqItem(
    topic: 'Notifications',
    question: 'Can I control which alert types I get notified about?',
    answer:
        'Notification preferences for the owner console are being '
        'expanded. Today, all platform-level alerts (applications, '
        'payments, system notices) are delivered to every signed-in owner '
        'account.',
  ),
  SupportFaqItem(
    topic: 'Account',
    question: 'How do I reset my owner account password?',
    answer:
        'Use the password reset flow from the login screen. For security, '
        'owner accounts cannot be reset by support staff directly - only '
        'via the email verification flow tied to your account.',
  ),
  SupportFaqItem(
    topic: 'Account',
    question: 'Where can I review recent activity on my account?',
    answer:
        'Audit Logs (under Settings > Security) records platform activity '
        'and owner actions, including logins and configuration changes.',
  ),
];
